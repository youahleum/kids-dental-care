import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/app_settings.dart';

/// 앱 설정을 SharedPreferences에 저장/로드.
class SettingsRepository {
  static const _kEnabled = 'notifications_enabled';
  static const _kHour = 'notification_hour';
  static const _kInterval = 'checkup_interval_months';
  static const _kBrushEnabled = 'brushing_reminder_enabled';
  static const _kMorningHour = 'morning_brush_hour';
  static const _kNightHour = 'night_brush_hour';

  Future<AppSettings> load() async {
    final p = await SharedPreferences.getInstance();
    return AppSettings(
      notificationsEnabled: p.getBool(_kEnabled) ?? true,
      notificationHour: p.getInt(_kHour) ?? 9,
      checkupIntervalMonths: p.getInt(_kInterval) ?? 6,
      brushingReminderEnabled: p.getBool(_kBrushEnabled) ?? false,
      morningBrushHour: p.getInt(_kMorningHour) ?? 8,
      nightBrushHour: p.getInt(_kNightHour) ?? 21,
    );
  }

  Future<void> save(AppSettings s) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kEnabled, s.notificationsEnabled);
    await p.setInt(_kHour, s.notificationHour);
    await p.setInt(_kInterval, s.checkupIntervalMonths);
    await p.setBool(_kBrushEnabled, s.brushingReminderEnabled);
    await p.setInt(_kMorningHour, s.morningBrushHour);
    await p.setInt(_kNightHour, s.nightBrushHour);
  }
}
