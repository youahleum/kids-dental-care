import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_dental_care/data/local/app_database.dart';
import 'package:kids_dental_care/data/repositories_impl/brushing_repository_impl.dart';
import 'package:kids_dental_care/data/repositories_impl/child_repository_impl.dart';
import 'package:kids_dental_care/domain/models/brushing.dart';
import 'package:kids_dental_care/domain/services/brushing_stats.dart';

void main() {
  group('BrushingRepository', () {
    late AppDatabase db;
    late BrushingRepositoryImpl repo;
    late int childId;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      repo = BrushingRepositoryImpl(db);
      childId = await ChildRepositoryImpl(db).add(
          name: '지호', birthDate: DateTime(2024, 4, 12), colorValue: 0);
    });

    tearDown(() async => db.close());

    test('체크하면 날짜(0시 기준)별로 묶여 조회된다', () async {
      await repo.setBrushed(
          childId: childId,
          date: DateTime(2026, 11, 16, 8, 30),
          slot: BrushingSlot.morning,
          brushed: true);
      await repo.setBrushed(
          childId: childId,
          date: DateTime(2026, 11, 16, 21),
          slot: BrushingSlot.night,
          brushed: true);
      final logs = await repo.watchByChild(childId).first;
      expect(logs[DateTime(2026, 11, 16)],
          {BrushingSlot.morning, BrushingSlot.night});
    });

    test('같은 칸을 두 번 체크해도 하나만 남고, 해제하면 지워진다', () async {
      final day = DateTime(2026, 11, 16);
      for (var i = 0; i < 2; i++) {
        await repo.setBrushed(
            childId: childId,
            date: day,
            slot: BrushingSlot.night,
            brushed: true);
      }
      expect((await db.select(db.brushingLogs).get()), hasLength(1));
      await repo.setBrushed(
          childId: childId, date: day, slot: BrushingSlot.night, brushed: false);
      expect(await repo.watchByChild(childId).first, isEmpty);
    });
  });

  group('BrushingStats', () {
    final all = BrushingSlot.values.toSet();
    final now = DateTime(2026, 11, 16, 12);

    test('오늘까지 연속으로 다 닦으면 오늘 포함해 센다', () {
      final s = BrushingStats.compute({
        DateTime(2026, 11, 14): all,
        DateTime(2026, 11, 15): all,
        DateTime(2026, 11, 16): all,
      }, now: now);
      expect(s.streak, 3);
      expect(s.stickers, 3);
    });

    test('오늘이 아직 미완성이면 어제까지의 연속일을 유지한다', () {
      final s = BrushingStats.compute({
        DateTime(2026, 11, 15): all,
        DateTime(2026, 11, 16): {BrushingSlot.morning},
      }, now: now);
      expect(s.streak, 1);
      expect(s.today, {BrushingSlot.morning});
    });

    test('하루라도 빠지면 연속이 끊긴다 (스티커는 누적)', () {
      final s = BrushingStats.compute({
        DateTime(2026, 11, 10): all,
        DateTime(2026, 11, 11): all,
        DateTime(2026, 11, 13): {BrushingSlot.night},
        DateTime(2026, 11, 15): all,
      }, now: now);
      expect(s.streak, 1);
      expect(s.stickers, 3);
    });

    test('기록이 없으면 0', () {
      final s = BrushingStats.compute({}, now: now);
      expect(s.streak, 0);
      expect(s.stickers, 0);
      expect(s.today, isEmpty);
    });
  });
}
