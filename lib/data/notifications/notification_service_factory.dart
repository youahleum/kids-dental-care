import 'package:flutter/foundation.dart' show kIsWeb;

import '../../domain/services/notification_service.dart';
import 'local_notification_service.dart';
import 'noop_notification_service.dart';

/// 플랫폼에 맞는 NotificationService를 만든다.
/// 웹은 로컬 알림 미지원 → no-op.
NotificationService createNotificationService() {
  if (kIsWeb) return NoopNotificationService();
  return LocalNotificationService();
}
