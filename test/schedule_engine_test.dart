import 'package:flutter_test/flutter_test.dart';
import 'package:kids_dental_care/domain/models/preventive_task.dart';
import 'package:kids_dental_care/domain/services/schedule_engine.dart';

void main() {
  group('ScheduleEngine.generate', () {
    final birth = DateTime(2024, 4, 12);
    final tasks = ScheduleEngine.generate(birth);

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
}
