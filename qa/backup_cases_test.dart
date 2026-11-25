// 백업/복원 기능 QA 케이스 실행본. 케이스 ID는 qa/05-테스트케이스-백업복원.md 와 같다.
// 실행: flutter test qa/backup_cases_test.dart
// 기대 결과를 그대로 적었으므로, 결함이 있는 케이스는 실패한다(의도된 실패).
import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_dental_care/data/backup/backup_service.dart';
import 'package:kids_dental_care/data/local/app_database.dart';
import 'package:kids_dental_care/data/repositories_impl/brushing_repository_impl.dart';
import 'package:kids_dental_care/data/repositories_impl/checkup_repository_impl.dart';
import 'package:kids_dental_care/data/repositories_impl/child_repository_impl.dart';
import 'package:kids_dental_care/data/repositories_impl/clinic_repository_impl.dart';
import 'package:kids_dental_care/data/repositories_impl/preventive_task_repository_impl.dart';
import 'package:kids_dental_care/data/repositories_impl/tooth_repository_impl.dart';
import 'package:kids_dental_care/domain/models/brushing.dart';
import 'package:kids_dental_care/domain/models/tooth_record.dart';
import 'package:kids_dental_care/domain/services/schedule_engine.dart';

void main() {
  late AppDatabase db;
  late BackupService backup;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    backup = BackupService(db);
  });
  tearDown(() async => db.close());

  /// 구성원 1명과 모든 종류의 기록을 하나씩 넣는다. 구성원 id 를 돌려준다.
  Future<int> seed({String name = '지호'}) async {
    final birth = DateTime(2024, 4, 12);
    final childId = await ChildRepositoryImpl(db)
        .add(name: name, birthDate: birth, colorValue: 0xFF4DB6C4);
    final taskRepo = PreventiveTaskRepositoryImpl(db);
    await taskRepo.createForChild(
        childId, ScheduleEngine.generate(birth, now: DateTime(2026, 11, 25)));
    final first = (await taskRepo.watchByChild(childId).first).first;
    await taskRepo.setDone(first.id, done: true);
    await CheckupRepositoryImpl(db).add(
        childId: childId,
        date: DateTime(2025, 4, 20),
        clinicName: '해맑은치과',
        memo: '이상 없음');
    await ToothRepositoryImpl(db)
        .setStatus(childId: childId, toothCode: 55, status: ToothStatus.caries);
    await ClinicRepositoryImpl(db).add(name: '해맑은치과', phone: '02-123-4567');
    await BrushingRepositoryImpl(db).setBrushed(
        childId: childId,
        date: DateTime(2026, 11, 1),
        slot: BrushingSlot.night,
        brushed: true);
    return childId;
  }

  Future<String> snapshot() => backup.exportToJson();

  /// 복원이 실패하고, 기존 기록이 그대로인지 확인한다.
  Future<void> expectRejected(String code) async {
    final before = await snapshot();
    await expectLater(backup.importFromJson(code), throwsA(anything));
    expect(await snapshot(), before, reason: '실패한 복원은 기존 기록을 바꾸면 안 된다');
  }

  /// 정상 백업을 Map 으로 만든 뒤 [edit] 로 망가뜨린 코드를 돌려준다.
  Future<String> tampered(void Function(Map<String, dynamic> m) edit) async {
    final m = jsonDecode(await snapshot()) as Map<String, dynamic>;
    edit(m);
    return jsonEncode(m);
  }

  Map<String, dynamic> firstOf(Map<String, dynamic> m, String key) =>
      (m[key] as List).first as Map<String, dynamic>;

  group('F. 왕복 보존 (동등 분할)', () {
    test('TC-F01 7개 표의 모든 값이 복원 뒤에도 같다', () async {
      await seed();
      final before = await snapshot();
      await backup.importFromJson(before);
      expect(await snapshot(), before);
    });

    test('TC-F02 특수문자 이름·메모 (따옴표, 역슬래시, 줄바꿈, 이모지)', () async {
      const name = '지"호\\ \n😀';
      final id = await seed(name: name);
      await CheckupRepositoryImpl(db).add(
          childId: id, date: DateTime(2026, 1, 1), memo: '첫 줄\n둘째 줄 {"a":1}');
      await backup.importFromJson(await snapshot());
      expect((await db.select(db.children).get()).first.name, name);
      expect((await db.select(db.checkupRecords).get()).last.memo,
          '첫 줄\n둘째 줄 {"a":1}');
    });

    test('TC-F03 기록이 하나도 없는 상태의 백업·복원', () async {
      final code = await snapshot();
      await backup.importFromJson(code);
      expect(await db.select(db.children).get(), isEmpty);
    });

    test('TC-F04 비어 있는 선택 항목(완료일, 비용, 메모)은 빈 채로 복원', () async {
      await seed();
      await backup.importFromJson(await snapshot());
      final tasks = await db.select(db.preventiveTasks).get();
      expect(tasks.where((t) => t.completedDate == null), hasLength(7));
      expect((await db.select(db.checkupRecords).get()).first.cost, isNull);
    });

    test('TC-F05 앞뒤 공백·줄바꿈이 붙은 코드', () async {
      await seed();
      final code = await snapshot();
      await backup.importFromJson('\n  $code  \n');
      expect(await snapshot(), code);
    });

    test('TC-F06 양치 기록 3년 치(2명, 약 4,400건)', () async {
      final a = await seed();
      final b = await seed(name: '서아');
      final repo = BrushingRepositoryImpl(db);
      for (final id in [a, b]) {
        for (var d = 0; d < 1095; d++) {
          for (final slot in BrushingSlot.values) {
            await repo.setBrushed(
                childId: id,
                date: DateTime(2023, 1, 1 + d),
                slot: slot,
                brushed: true);
          }
        }
      }
      final code = await snapshot();
      final rows = (await db.select(db.brushingLogs).get()).length;
      await backup.importFromJson(code);
      expect((await db.select(db.brushingLogs).get()).length, rows);
      // ignore: avoid_print
      print('TC-F06 양치 $rows건, 백업 코드 길이 ${code.length}자');
    });

    test('TC-F07 복원 뒤 새 구성원을 추가해도 번호가 겹치지 않음', () async {
      await seed();
      await backup.importFromJson(await snapshot());
      final id = await seed(name: '서아');
      expect(await db.select(db.children).get(), hasLength(2));
      expect(id, isNot(1));
    });
  });

  group('G. 잘못된 코드 (동등 분할 + 경계값)', () {
    setUp(() => seed());

    test('TC-G01 빈 문자열', () => expectRejected(''));
    test('TC-G02 JSON 이 아닌 글', () => expectRejected('안녕하세요'));
    test('TC-G03 중간에 잘린 코드', () async {
      final code = await snapshot();
      await expectRejected(code.substring(0, code.length ~/ 2));
    });
    test('TC-G04 마지막 한 글자만 잘린 코드', () async {
      final code = await snapshot();
      await expectRejected(code.substring(0, code.length - 1));
    });
    test('TC-G05 객체가 아닌 JSON (배열, 숫자)', () async {
      await expectRejected('[]');
      await expectRejected('123');
    });
    test('TC-G06 메신저가 따옴표를 둥근 따옴표로 바꾼 코드', () async {
      final code = await snapshot();
      await expectRejected(code.replaceAll('"', '”'));
    });

    test('TC-G07 버전 경계: 0, 2, 없음, 문자열 "1" 은 거부', () async {
      for (final v in [0, 2, null, '1']) {
        await expectRejected(await tampered((m) => m['formatVersion'] = v));
      }
    });

    test('TC-G08 필수 표(구성원)가 없는 코드', () async {
      await expectRejected(await tampered((m) => m.remove('children')));
    });

    test('TC-G09 값의 자료형이 다름 (이름이 숫자)', () async {
      await expectRejected(
          await tampered((m) => firstOf(m, 'children')['name'] = 123));
    });

    test('TC-G10 없는 구성원을 가리키는 기록', () async {
      await expectRejected(await tampered(
          (m) => firstOf(m, 'checkupRecords')['childId'] = 9999));
    });

    test('TC-G11 번호가 겹치는 구성원 2명', () async {
      await expectRejected(await tampered((m) {
        final list = m['children'] as List;
        list.add(Map<String, dynamic>.from(list.first as Map));
      }));
    });

    test('TC-G12 마지막 표(치아 이력)만 깨진 코드 — 앞에서 넣은 것도 되돌림', () async {
      await expectRejected(await tampered((m) => m['toothEvents'] = [
            {'id': 1, 'childId': 1, 'toothCode': 55}
          ]));
    });

    test('TC-G13 표현할 수 없는 날짜 값', () async {
      await expectRejected(await tampered(
          (m) => firstOf(m, 'children')['birthDate'] = 99999999999999999));
    });

    test('TC-G14 모르는 항목이 더 들어 있는 코드는 무시하고 복원', () async {
      final before = await snapshot();
      await backup.importFromJson(await tampered((m) => m['extra'] = 'x'));
      expect(await snapshot(), before);
    });

    test('TC-G15 범위를 벗어난 종류 번호(예방치료 type=99)는 거부', () async {
      await expectRejected(
          await tampered((m) => firstOf(m, 'preventiveTasks')['type'] = 99));
    });

    test('TC-G16 범위를 벗어난 종류 번호로 복원돼도 타임라인 조회는 됨', () async {
      final code =
          await tampered((m) => firstOf(m, 'preventiveTasks')['type'] = 99);
      try {
        await backup.importFromJson(code);
      } catch (_) {
        return; // 거부했다면 조회할 것이 없다.
      }
      await PreventiveTaskRepositoryImpl(db).watchByChild(1).first;
    });

    test('TC-G17 범위를 벗어난 치아 상태 번호(status=99)는 거부', () async {
      await expectRejected(
          await tampered((m) => firstOf(m, 'toothRecords')['status'] = 99));
    });

    test('TC-G18 미래 생년월일은 거부 (등록 화면에서는 선택 불가)', () async {
      final future = DateTime(2100, 1, 1).millisecondsSinceEpoch;
      await expectRejected(await tampered(
          (m) => firstOf(m, 'children')['birthDate'] = future));
    });
  });

  group('H. 교체 동작 (상태 전이)', () {
    test('TC-H01 다른 기록이 있는 상태에서 복원 → 백업 내용만 남음', () async {
      await seed();
      final code = await snapshot();
      await seed(name: '서아');
      await seed(name: '엄마');
      await backup.importFromJson(code);
      expect(await snapshot(), code);
    });

    test('TC-H02 기록이 없는 백업으로 복원 → 기존 기록이 모두 지워짐(설계대로)', () async {
      final empty = await snapshot();
      await seed();
      await backup.importFromJson(empty);
      expect(await db.select(db.children).get(), isEmpty);
      expect(await db.select(db.clinics).get(), isEmpty);
    });

    test('TC-H03 치과·양치·치아 이력 표가 없는 옛 백업', () async {
      await seed();
      final code = await tampered((m) => m
        ..remove('clinics')
        ..remove('brushingLogs')
        ..remove('toothEvents'));
      await backup.importFromJson(code);
      expect(await db.select(db.children).get(), hasLength(1));
      expect(await db.select(db.clinics).get(), isEmpty);
    });

    test('TC-H04 실패한 복원 뒤 바로 정상 복원', () async {
      await seed();
      final code = await snapshot();
      await expectRejected('깨진 코드');
      await backup.importFromJson(code);
      expect(await snapshot(), code);
    });
  });
}
