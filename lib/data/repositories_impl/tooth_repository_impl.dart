import 'package:drift/drift.dart';

import '../../domain/models/tooth_record.dart';
import '../../domain/repositories/tooth_repository.dart';
import '../local/app_database.dart';

class ToothRepositoryImpl implements ToothRepository {
  ToothRepositoryImpl(this._db);

  final AppDatabase _db;

  ToothRecord _toModel(ToothRecordRow row) => ToothRecord(
        id: row.id,
        childId: row.childId,
        toothCode: row.toothCode,
        status: ToothStatus.values[row.status],
        note: row.note,
        updatedAt: row.updatedAt,
      );

  @override
  Stream<Map<int, ToothRecord>> watchByChild(int childId) {
    final query = _db.select(_db.toothRecords)
      ..where((t) => t.childId.equals(childId));
    return query.watch().map((rows) => {
          for (final r in rows) r.toothCode: _toModel(r),
        });
  }

  @override
  Future<void> setStatus({
    required int childId,
    required int toothCode,
    required ToothStatus status,
    String? note,
  }) async {
    final delete = _db.delete(_db.toothRecords)
      ..where((t) => t.childId.equals(childId) & t.toothCode.equals(toothCode));

    // healthy = 기본값이므로 기록을 지운다.
    if (status == ToothStatus.healthy) {
      await delete.go();
      return;
    }

    // 충돌 타깃을 (childId, toothCode) unique로 명시해야 UPDATE로 잡힌다.
    // (기본값은 PK인 id라 unique 충돌이 UPDATE되지 않고 예외 발생)
    await _db.into(_db.toothRecords).insert(
          ToothRecordsCompanion.insert(
            childId: childId,
            toothCode: toothCode,
            status: status.index,
            note: Value(note),
            updatedAt: DateTime.now(),
          ),
          onConflict: DoUpdate(
            (old) => ToothRecordsCompanion.custom(
              status: Variable(status.index),
              note: Variable(note),
              updatedAt: Variable(DateTime.now()),
            ),
            target: [_db.toothRecords.childId, _db.toothRecords.toothCode],
          ),
        );
  }
}
