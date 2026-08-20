import 'package:flutter_test/flutter_test.dart';
import 'package:kids_dental_care/domain/models/preventive_task.dart';
import 'package:kids_dental_care/domain/models/tooth_record.dart';
import 'package:kids_dental_care/domain/services/dashboard_stats.dart';

PreventiveTask _task(int id, DateTime date, TaskStatus status) => PreventiveTask(
      id: id,
      childId: 1,
      type: PreventiveType.checkup,
      title: '검진 $id',
      recommendedDate: date,
      status: status,
    );

ToothRecord _tooth(int code, ToothStatus s) => ToothRecord(
      id: code,
      childId: 1,
      toothCode: code,
      status: s,
      updatedAt: DateTime(2026, 1, 1),
    );

void main() {
  final now = DateTime(2026, 8, 20);

  test('완료율 계산', () {
    final stats = DashboardStats.compute(
      tasks: [
        _task(1, DateTime(2025, 1, 1), TaskStatus.done),
        _task(2, DateTime(2025, 6, 1), TaskStatus.done),
        _task(3, DateTime(2027, 1, 1), TaskStatus.pending),
        _task(4, DateTime(2027, 6, 1), TaskStatus.pending),
      ],
      checkups: const [],
      teeth: const {},
      now: now,
    );
    expect(stats.totalTasks, 4);
    expect(stats.doneTasks, 2);
    expect(stats.completionPercent, 50);
  });

  test('overdue: 미완료 중 오늘 이전 항목 수', () {
    final stats = DashboardStats.compute(
      tasks: [
        _task(1, DateTime(2026, 1, 1), TaskStatus.pending), // 지남
        _task(2, DateTime(2026, 3, 1), TaskStatus.pending), // 지남
        _task(3, DateTime(2027, 1, 1), TaskStatus.pending), // 미래
      ],
      checkups: const [],
      teeth: const {},
      now: now,
    );
    expect(stats.overdueTasks, 2);
  });

  test('nextTask: 미래 중 가장 가까운 항목', () {
    final stats = DashboardStats.compute(
      tasks: [
        _task(1, DateTime(2027, 6, 1), TaskStatus.pending),
        _task(2, DateTime(2026, 9, 1), TaskStatus.pending), // 가장 가까운 미래
        _task(3, DateTime(2028, 1, 1), TaskStatus.pending),
      ],
      checkups: const [],
      teeth: const {},
      now: now,
    );
    expect(stats.nextTask?.id, 2);
  });

  test('치아 상태 카운트: 충치 / 치료·실란트', () {
    final stats = DashboardStats.compute(
      tasks: const [],
      checkups: const [],
      teeth: {
        55: _tooth(55, ToothStatus.caries),
        54: _tooth(54, ToothStatus.caries),
        53: _tooth(53, ToothStatus.treated),
        52: _tooth(52, ToothStatus.sealant),
        51: _tooth(51, ToothStatus.healthy),
      },
      now: now,
    );
    expect(stats.cariesCount, 2);
    expect(stats.treatedCount, 2); // treated + sealant
  });

  test('빈 데이터: 완료율 0, nextTask null', () {
    final stats = DashboardStats.compute(
      tasks: const [],
      checkups: const [],
      teeth: const {},
      now: now,
    );
    expect(stats.completionPercent, 0);
    expect(stats.nextTask, isNull);
    expect(stats.lastCheckup, isNull);
  });
}
