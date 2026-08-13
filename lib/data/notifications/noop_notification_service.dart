import '../../domain/services/notification_scheduler.dart';
import '../../domain/services/notification_service.dart';

/// 웹/테스트용 no-op 구현. (로컬 알림은 네이티브 전용)
class NoopNotificationService implements NotificationService {
  @override
  Future<void> init() async {}

  @override
  Future<bool> requestPermission() async => false;

  @override
  Future<void> reschedule(List<ScheduledNotification> notifications) async {}

  @override
  Future<void> cancelAll() async {}
}
