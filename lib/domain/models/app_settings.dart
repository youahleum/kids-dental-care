import 'package:flutter/foundation.dart';

/// 앱 설정. 기준 문서: DESIGN.md 6-6
@immutable
class AppSettings {
  const AppSettings({
    this.notificationsEnabled = true,
    this.notificationHour = 9,
    this.checkupIntervalMonths = 6,
  });

  /// 알림 on/off.
  final bool notificationsEnabled;

  /// 알림 시각(시, 0~23).
  final int notificationHour;

  /// 검진 주기(개월).
  final int checkupIntervalMonths;

  AppSettings copyWith({
    bool? notificationsEnabled,
    int? notificationHour,
    int? checkupIntervalMonths,
  }) {
    return AppSettings(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      notificationHour: notificationHour ?? this.notificationHour,
      checkupIntervalMonths:
          checkupIntervalMonths ?? this.checkupIntervalMonths,
    );
  }
}
