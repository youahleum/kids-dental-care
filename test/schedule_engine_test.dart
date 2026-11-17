import 'package:flutter_test/flutter_test.dart';
import 'package:kids_dental_care/domain/models/preventive_task.dart';
import 'package:kids_dental_care/domain/services/schedule_engine.dart';

void main() {
  group('ScheduleEngine.generate', () {
    final birth = DateTime(2024, 4, 12);
    final tasks = ScheduleEngine.generate(birth, now: DateTime(2026, 11, 16));

    test('시드 항목 수만큼 생성된다', () {
      expect(tasks, hasLength(8));
    });

    test('권장일 오름차순으로 정렬된다', () {
      for (var i = 1; i < tasks.length; i++) {
        expect(
          tasks[i].recommendedDate.isBefore(tasks[i - 1].recommendedDate),
          isFalse,
        );
      }
    });

    test('첫 방문은 생후 12개월', () {
      final first =
          tasks.firstWhere((t) => t.type == PreventiveType.firstVisit);
      expect(first.recommendedDate, DateTime(2025, 4, 12));
    });

    test('국가 구강검진 1차는 생후 18개월(만 2세)', () {
      final checkup1 =
          tasks.firstWhere((t) => t.title.contains('1차'));
      expect(checkup1.recommendedDate, DateTime(2025, 10, 12));
      expect(checkup1.type, PreventiveType.checkup);
    });

    test('6세 어금니 실란트는 생후 72개월', () {
      final sealant =
          tasks.firstWhere((t) => t.title.contains('6세 어금니'));
      expect(sealant.recommendedDate, DateTime(2030, 4, 12));
      expect(sealant.type, PreventiveType.sealant);
    });

    test('검진이 4회 포함된다', () {
      final checkups =
          tasks.where((t) => t.type == PreventiveType.checkup).length;
      expect(checkups, 4);
    });
  });

  group('ScheduleEngine.generate (어른)', () {
    // 1990년생(짝수년), 기준일 2026-11-16 → 만 36세
    final birth = DateTime(1990, 3, 5);
    final now = DateTime(2026, 11, 16);
    final tasks = ScheduleEngine.generate(birth, now: now);

    test('어른은 영유아 일정이 생기지 않는다', () {
      expect(tasks.any((t) => t.type == PreventiveType.sealant), isFalse);
      expect(tasks.any((t) => t.type == PreventiveType.firstVisit), isFalse);
    });

    test('스케일링이 올해부터 3년치 매년 생긴다', () {
      final scaling =
          tasks.where((t) => t.type == PreventiveType.scaling).toList();
      expect(scaling.map((t) => t.recommendedDate.year), [2026, 2027, 2028]);
    });

    test('올해 생일이 지났으면 오늘, 이후 해는 생일 무렵', () {
      final scaling =
          tasks.where((t) => t.type == PreventiveType.scaling).toList();
      expect(scaling[0].recommendedDate, DateTime(2026, 11, 16));
      expect(scaling[1].recommendedDate, DateTime(2027, 3, 5));
    });

    test('국가 구강검진은 출생연도와 짝/홀이 같은 해에만', () {
      final national = tasks
          .where((t) => t.title.contains('국가건강검진'))
          .map((t) => t.recommendedDate.year)
          .toList();
      expect(national, [2026, 2028]);
    });

    test('곧 만 19세가 되는 청소년은 아이 일정 + 해당 해부터 스케일링', () {
      final teen = ScheduleEngine.generate(DateTime(2008, 6, 1), now: now);
      expect(teen.any((t) => t.type == PreventiveType.sealant), isTrue);
      expect(
          teen
              .where((t) => t.type == PreventiveType.scaling)
              .map((t) => t.recommendedDate.year),
          [2027, 2028]);
    });

    test('아이에게는 어른 일정이 없다', () {
      final kid = ScheduleEngine.generate(DateTime(2024, 4, 12), now: now);
      expect(kid.any((t) => t.type == PreventiveType.scaling), isFalse);
    });
  });
}
