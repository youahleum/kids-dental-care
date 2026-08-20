import 'dart:convert';

import 'package:drift/drift.dart';

import '../local/app_database.dart';

/// 전체 데이터를 JSON으로 내보내기/가져오기.
/// 기기 교체·백업 대비. 기준 문서: PLAN.md 10장(향후 확장)
class BackupService {
  BackupService(this._db);

  final AppDatabase _db;

  /// 백업 포맷 버전. 향후 스키마 변경 시 마이그레이션 분기용.
  static const formatVersion = 1;

  int _ms(DateTime d) => d.millisecondsSinceEpoch;
  DateTime _dt(int ms) => DateTime.fromMillisecondsSinceEpoch(ms);

  /// 전체 데이터를 JSON Map으로 직렬화.
  Future<Map<String, dynamic>> exportToMap() async {
    final children = await _db.select(_db.children).get();
    final tasks = await _db.select(_db.preventiveTasks).get();
    final checkups = await _db.select(_db.checkupRecords).get();
    final teeth = await _db.select(_db.toothRecords).get();
    final clinics = await _db.select(_db.clinics).get();

    return {
      'formatVersion': formatVersion,
      'clinics': [
        for (final c in clinics)
          {
            'id': c.id,
            'name': c.name,
            'phone': c.phone,
            'address': c.address,
            'memo': c.memo,
            'createdAt': _ms(c.createdAt),
          },
      ],
      'children': [
        for (final c in children)
          {
            'id': c.id,
            'name': c.name,
            'birthDate': _ms(c.birthDate),
            'colorValue': c.colorValue,
            'photoPath': c.photoPath,
            'createdAt': _ms(c.createdAt),
          },
      ],
      'preventiveTasks': [
        for (final t in tasks)
          {
            'id': t.id,
            'childId': t.childId,
            'type': t.type,
            'title': t.title,
            'recommendedDate': _ms(t.recommendedDate),
            'status': t.status,
            'completedDate':
                t.completedDate == null ? null : _ms(t.completedDate!),
            'note': t.note,
          },
      ],
      'checkupRecords': [
        for (final r in checkups)
          {
            'id': r.id,
            'childId': r.childId,
            'date': _ms(r.date),
            'clinicName': r.clinicName,
            'memo': r.memo,
          },
      ],
      'toothRecords': [
        for (final t in teeth)
          {
            'id': t.id,
            'childId': t.childId,
            'toothCode': t.toothCode,
            'status': t.status,
            'note': t.note,
            'updatedAt': _ms(t.updatedAt),
          },
      ],
    };
  }

  /// JSON 문자열로 내보내기 (파일 저장·공유용).
  Future<String> exportToJson() async =>
      jsonEncode(await exportToMap());

  /// JSON Map에서 복원. 기존 데이터를 모두 지우고 교체(replace).
  /// 트랜잭션으로 원자적 처리 — 실패 시 롤백된다.
  Future<void> importFromMap(Map<String, dynamic> data) async {
    final version = data['formatVersion'];
    if (version != formatVersion) {
      throw FormatException('지원하지 않는 백업 버전입니다: $version');
    }

    await _db.transaction(() async {
      // FK cascade 순서 상관없이 안전하게 자식부터 삭제.
      await _db.delete(_db.toothRecords).go();
      await _db.delete(_db.checkupRecords).go();
      await _db.delete(_db.preventiveTasks).go();
      await _db.delete(_db.children).go();
      await _db.delete(_db.clinics).go();

      final children = (data['children'] as List).cast<Map<String, dynamic>>();
      for (final c in children) {
        await _db.into(_db.children).insert(
              ChildrenCompanion.insert(
                id: Value(c['id'] as int),
                name: c['name'] as String,
                birthDate: _dt(c['birthDate'] as int),
                colorValue: c['colorValue'] as int,
                photoPath: Value(c['photoPath'] as String?),
                createdAt: _dt(c['createdAt'] as int),
              ),
            );
      }

      final clinics =
          (data['clinics'] as List? ?? const []).cast<Map<String, dynamic>>();
      for (final c in clinics) {
        await _db.into(_db.clinics).insert(
              ClinicsCompanion.insert(
                id: Value(c['id'] as int),
                name: c['name'] as String,
                phone: Value(c['phone'] as String?),
                address: Value(c['address'] as String?),
                memo: Value(c['memo'] as String?),
                createdAt: _dt(c['createdAt'] as int),
              ),
            );
      }

      final tasks =
          (data['preventiveTasks'] as List).cast<Map<String, dynamic>>();
      for (final t in tasks) {
        await _db.into(_db.preventiveTasks).insert(
              PreventiveTasksCompanion.insert(
                id: Value(t['id'] as int),
                childId: t['childId'] as int,
                type: t['type'] as int,
                title: t['title'] as String,
                recommendedDate: _dt(t['recommendedDate'] as int),
                status: t['status'] as int,
                completedDate: Value(t['completedDate'] == null
                    ? null
                    : _dt(t['completedDate'] as int)),
                note: Value(t['note'] as String?),
              ),
            );
      }

      final checkups =
          (data['checkupRecords'] as List).cast<Map<String, dynamic>>();
      for (final r in checkups) {
        await _db.into(_db.checkupRecords).insert(
              CheckupRecordsCompanion.insert(
                id: Value(r['id'] as int),
                childId: r['childId'] as int,
                date: _dt(r['date'] as int),
                clinicName: Value(r['clinicName'] as String?),
                memo: Value(r['memo'] as String?),
              ),
            );
      }

      final teeth =
          (data['toothRecords'] as List).cast<Map<String, dynamic>>();
      for (final t in teeth) {
        await _db.into(_db.toothRecords).insert(
              ToothRecordsCompanion.insert(
                id: Value(t['id'] as int),
                childId: t['childId'] as int,
                toothCode: t['toothCode'] as int,
                status: t['status'] as int,
                note: Value(t['note'] as String?),
                updatedAt: _dt(t['updatedAt'] as int),
              ),
            );
      }
    });
  }

  /// JSON 문자열에서 복원.
  Future<void> importFromJson(String json) async {
    final data = jsonDecode(json) as Map<String, dynamic>;
    await importFromMap(data);
  }
}
