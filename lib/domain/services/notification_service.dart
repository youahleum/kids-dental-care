import 'notification_scheduler.dart';

/// 로컬 알림 플랫폼 계층 추상화.
/// 구현은 flutter_local_notifications(네이티브). 웹/테스트는 no-op.
abstract interface class NotificationService {
  /// 초기화 + 권한 요청.
  Future<void> init();

  /// 사용자 알림 허용 여부.
  Future<bool> requestPermission();

  /// 기존 예약을 모두 지우고 주어진 목록으로 다시 예약.
  Future<void> reschedule(List<ScheduledNotification> notifications);

  /// 모든 예약 취소.
  Future<void> cancelAll();
}
