import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/settings/settings_repository.dart';
import '../../domain/models/app_settings.dart';

final settingsRepositoryProvider = Provider((ref) => SettingsRepository());

/// 앱 시작 시 로드한 초기 설정. main에서 override로 주입한다.
/// (미override 시 기본값 — 테스트 등)
final initialSettingsProvider = Provider<AppSettings>((ref) {
  return const AppSettings();
});

/// 앱 설정 상태.
final settingsProvider =
    NotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);

class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() => ref.read(initialSettingsProvider);

  Future<void> _persist() async {
    await ref.read(settingsRepositoryProvider).save(state);
  }

  Future<void> setNotificationsEnabled(bool v) async {
    state = state.copyWith(notificationsEnabled: v);
    await _persist();
  }

  Future<void> setNotificationHour(int hour) async {
    state = state.copyWith(notificationHour: hour);
    await _persist();
  }

  Future<void> setCheckupIntervalMonths(int months) async {
    state = state.copyWith(checkupIntervalMonths: months);
    await _persist();
  }
}
