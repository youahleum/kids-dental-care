import 'package:flutter/foundation.dart';

/// 앱 설정. 기준 문서: DESIGN.md 6-6
@immutable
class AppSettings {
  const AppSettings({
    this.notificationsEnabled = true,
    this.notificationHour = 9,
    this.checkupIntervalMonths = 6,
    this.brushingReminderEnabled = false,
    this.morningBrushHour = 8,
    this.nightBrushHour = 21,
  });

  /// 알림 on/off.
  final bool notificationsEnabled;

  /// 알림 시각(시, 0~23).
  final int notificationHour;

  /// 검진 주기(개월).
  final int checkupIntervalMonths;

  /// 양치 알림 on/off (매일 아침·자기 전).
  final bool brushingReminderEnabled;

  /// 아침 양치 알림 시각(시).
  final int morningBrushHour;

  /// 자기 전 양치 알림 시각(시).
  final int nightBrushHour;

  AppSettings copyWith({
    bool? notificationsEnabled,
    int? notificationHour,
    int? checkupIntervalMonths,
    bool? brushingReminderEnabled,
    int? morningBrushHour,
    int? nightBrushHour,
  }) {
    return AppSettings(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      notificationHour: notificationHour ?? this.notificationHour,
      checkupIntervalMonths:
          checkupIntervalMonths ?? this.checkupIntervalMonths,
      brushingReminderEnabled:
          brushingReminderEnabled ?? this.brushingReminderEnabled,
      morningBrushHour: morningBrushHour ?? this.morningBrushHour,
      nightBrushHour: nightBrushHour ?? this.nightBrushHour,
    );
  }
}
