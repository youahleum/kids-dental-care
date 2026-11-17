import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../../domain/services/notification_scheduler.dart';
import '../settings/settings_controller.dart';

/// 모든 자녀의 미완료 항목을 모아 로컬 알림을 재예약한다.
/// 앱 시작 시 + 설정/데이터 변경 시 호출한다.
///
/// id 충돌 방지: 자녀별로 알림 id 공간을 분리(childId * 1000 오프셋).
Future<void> rescheduleAllNotifications(WidgetRef ref) async {
  final service = ref.read(notificationServiceProvider);
  final settings = ref.read(settingsProvider);

  if (!settings.notificationsEnabled && !settings.brushingReminderEnabled) {
    await service.cancelAll();
    return;
  }

  await service.init();

  final all = <ScheduledNotification>[
    if (settings.brushingReminderEnabled)
      ...NotificationScheduler.forBrushing(
        morningHour: settings.morningBrushHour,
        nightHour: settings.nightBrushHour,
      ),
  ];

  final children = settings.notificationsEnabled
      ? await ref.read(childRepositoryProvider).getAll()
      : const [];
  final taskRepo = ref.read(preventiveTaskRepositoryProvider);

  for (final child in children) {
    final tasks = await taskRepo.watchByChild(child.id).first;
    final scheduled = NotificationScheduler.forTasks(
      tasks,
      child.name,
      hour: settings.notificationHour,
    );
    // 자녀별 id 공간 분리
    for (final n in scheduled) {
      all.add(ScheduledNotification(
        id: child.id * 1000 + (n.id % 1000),
        fireDate: n.fireDate,
        title: n.title,
        body: n.body,
      ));
    }
  }

  await service.reschedule(all);
}
