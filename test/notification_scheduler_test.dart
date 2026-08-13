import 'package:flutter_test/flutter_test.dart';
import 'package:kids_dental_care/domain/models/preventive_task.dart';
import 'package:kids_dental_care/domain/services/notification_scheduler.dart';

PreventiveTask _task({
  required int id,
  required DateTime date,
  TaskStatus status = TaskStatus.pending,
}) =>
    PreventiveTask(
      id: id,
      childId: 1,
      type: PreventiveType.checkup,
      title: '국가 구강검진',
      recommendedDate: date,
      status: status,
    );

void main() {
  final now = DateTime(2026, 8, 13, 8); // 기준 시각

  group('NotificationScheduler.forTasks', () {
    test('미완료 미래 항목은 7일 전 + 당일 2건 생성', () {
      final tasks = [_task(id: 1, date: DateTime(2026, 9, 1))];
      final result =
          NotificationScheduler.forTasks(tasks, '지호', now: now);
      expect(result, hasLength(2));
      // 7일 전(8/25 09시), 당일(9/1 09시)
      expect(result[0].fireDate, DateTime(2026, 8, 25, 9));
      expect(result[1].fireDate, DateTime(2026, 9, 1, 9));
    });

    test('완료 항목은 제외', () {
      final tasks = [
        _task(id: 1, date: DateTime(2026, 9, 1), status: TaskStatus.done),
      ];
      expect(NotificationScheduler.forTasks(tasks, '지호', now: now), isEmpty);
    });

    test('이미 지난 항목은 제외', () {
      final tasks = [_task(id: 1, date: DateTime(2026, 1, 1))];
      expect(NotificationScheduler.forTasks(tasks, '지호', now: now), isEmpty);
    });

    test('당일만 미래이면 당일 1건', () {
      // 8/13 기준, 8/15 항목 → 7일전(8/8)은 과거, 당일(8/15)만 미래
      final tasks = [_task(id: 1, date: DateTime(2026, 8, 15))];
      final result =
          NotificationScheduler.forTasks(tasks, '지호', now: now);
      expect(result, hasLength(1));
      expect(result.first.fireDate, DateTime(2026, 8, 15, 9));
    });

    test('문구에 자녀 이름과 항목명이 들어간다', () {
      final tasks = [_task(id: 1, date: DateTime(2026, 9, 1))];
      final result =
          NotificationScheduler.forTasks(tasks, '지호', now: now);
      expect(result.first.title, contains('지호'));
      expect(result.last.body, contains('국가 구강검진'));
    });

    test('lead/당일 알림 id가 서로 다르다', () {
      final tasks = [_task(id: 5, date: DateTime(2026, 9, 1))];
      final result =
          NotificationScheduler.forTasks(tasks, '지호', now: now);
      expect(result[0].id, isNot(result[1].id));
    });
  });
}
