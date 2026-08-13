import '../models/preventive_task.dart';

/// 예약할 알림 1건.
class ScheduledNotification {
  const ScheduledNotification({
    required this.id,
    required this.fireDate,
    required this.title,
    required this.body,
  });

  /// 안정적 알림 id (같은 항목·시점이면 항상 같은 값 → 재예약 시 갱신).
  final int id;
  final DateTime fireDate;
  final String title;
  final String body;
}

/// 예방치료/검진 항목에서 로컬 알림 예약 목록을 계산한다.
/// 순수 로직 — 플랫폼 비의존. 기준 문서: DESIGN.md 7장
abstract final class NotificationScheduler {
  /// 알림 시각(시). 설정에서 변경 가능(향후).
  static const defaultHour = 9;

  /// 임박 알림을 며칠 전에 보낼지.
  static const leadDays = 7;

  /// 미완료 항목에 대해 (7일 전, 당일) 알림을 만든다.
  /// 이미 지난 시각은 제외한다.
  static List<ScheduledNotification> forTasks(
    List<PreventiveTask> tasks,
    String childName, {
    int hour = defaultHour,
    DateTime? now,
  }) {
    final ref = now ?? DateTime.now();
    final result = <ScheduledNotification>[];

    for (final task in tasks) {
      if (task.status == TaskStatus.done) continue;

      final at = _atHour(task.recommendedDate, hour);
      final lead = _atHour(
        task.recommendedDate.subtract(const Duration(days: leadDays)),
        hour,
      );

      if (lead.isAfter(ref)) {
        result.add(ScheduledNotification(
          id: _idFor(task.id, isLead: true),
          fireDate: lead,
          title: '$childName 치과 예방 안내',
          body: '$leadDays일 뒤 "${task.title}" 시기예요. 예약해볼까요? 🦷',
        ));
      }
      if (at.isAfter(ref)) {
        result.add(ScheduledNotification(
          id: _idFor(task.id, isLead: false),
          fireDate: at,
          title: '$childName 치과 예방 안내',
          body: '오늘은 "${task.title}" 권장 시기예요. 🦷',
        ));
      }
    }
    return result;
  }

  static DateTime _atHour(DateTime date, int hour) =>
      DateTime(date.year, date.month, date.day, hour);

  /// task id 하나에서 두 알림(lead/당일)의 안정적 id를 만든다.
  static int _idFor(int taskId, {required bool isLead}) =>
      taskId * 2 + (isLead ? 0 : 1);
}
