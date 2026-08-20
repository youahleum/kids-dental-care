import '../models/checkup_record.dart';
import '../models/preventive_task.dart';
import '../models/tooth_record.dart';

/// 자녀 한 명의 통계 요약. 순수 계산 — UI/DB 비의존.
class DashboardStats {
  const DashboardStats({
    required this.totalTasks,
    required this.doneTasks,
    required this.overdueTasks,
    required this.nextTask,
    required this.cariesCount,
    required this.treatedCount,
    required this.lastCheckup,
  });

  final int totalTasks;
  final int doneTasks;
  final int overdueTasks;

  /// 미완료 중 가장 임박한 항목(없으면 null).
  final PreventiveTask? nextTask;

  final int cariesCount;

  /// 치료·실란트 등 처치된 치아 수.
  final int treatedCount;

  final CheckupRecord? lastCheckup;

  /// 예방치료 완료율(0.0~1.0). 항목이 없으면 0.
  double get completionRate =>
      totalTasks == 0 ? 0 : doneTasks / totalTasks;

  int get completionPercent => (completionRate * 100).round();

  static DashboardStats compute({
    required List<PreventiveTask> tasks,
    required List<CheckupRecord> checkups,
    required Map<int, ToothRecord> teeth,
    DateTime? now,
  }) {
    final ref = now ?? DateTime.now();
    final today = DateTime(ref.year, ref.month, ref.day);

    final done = tasks.where((t) => t.status == TaskStatus.done).length;
    final pending =
        tasks.where((t) => t.status != TaskStatus.done).toList();

    final overdue = pending
        .where((t) => t.recommendedDate.isBefore(today))
        .length;

    // 미완료 중 권장일이 가장 가까운(오늘 이후 우선) 항목.
    PreventiveTask? next;
    final upcoming = pending
        .where((t) => !t.recommendedDate.isBefore(today))
        .toList()
      ..sort((a, b) => a.recommendedDate.compareTo(b.recommendedDate));
    if (upcoming.isNotEmpty) {
      next = upcoming.first;
    } else if (pending.isNotEmpty) {
      pending.sort((a, b) => b.recommendedDate.compareTo(a.recommendedDate));
      next = pending.first;
    }

    final caries =
        teeth.values.where((t) => t.status == ToothStatus.caries).length;
    final treated = teeth.values
        .where((t) =>
            t.status == ToothStatus.treated ||
            t.status == ToothStatus.sealant)
        .length;

    final lastCheckup = checkups.isEmpty
        ? null
        : (checkups.toList()
              ..sort((a, b) => b.date.compareTo(a.date)))
            .first;

    return DashboardStats(
      totalTasks: tasks.length,
      doneTasks: done,
      overdueTasks: overdue,
      nextTask: next,
      cariesCount: caries,
      treatedCount: treated,
      lastCheckup: lastCheckup,
    );
  }
}
