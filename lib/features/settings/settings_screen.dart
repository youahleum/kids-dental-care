import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../notifications/notification_controller.dart';
import 'settings_controller.dart';

/// 설정 화면. 기준: DESIGN.md 6-6
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('예방치료·검진 알림'),
            subtitle: const Text('시기가 되면 7일 전과 당일에 알려드려요.'),
            value: settings.notificationsEnabled,
            onChanged: (v) async {
              await notifier.setNotificationsEnabled(v);
              if (v) {
                final granted = await ref
                    .read(notificationServiceProvider)
                    .requestPermission();
                if (!granted && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('기기 설정에서 알림 권한을 허용해 주세요.'),
                    ),
                  );
                }
              }
              await rescheduleAllNotifications(ref);
            },
          ),
          ListTile(
            enabled: settings.notificationsEnabled,
            leading: const Icon(Icons.schedule),
            title: const Text('알림 시각'),
            trailing: Text(
              '${settings.notificationHour.toString().padLeft(2, '0')}:00',
              style: const TextStyle(fontSize: 16),
            ),
            onTap: settings.notificationsEnabled
                ? () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime:
                          TimeOfDay(hour: settings.notificationHour, minute: 0),
                      helpText: '알림 시각 선택',
                    );
                    if (picked != null) {
                      await notifier.setNotificationHour(picked.hour);
                      await rescheduleAllNotifications(ref);
                    }
                  }
                : null,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.event_repeat),
            title: const Text('검진 주기'),
            subtitle: const Text('다음 검진 예정일 계산 기준'),
            trailing: DropdownButton<int>(
              value: settings.checkupIntervalMonths,
              items: const [3, 4, 6, 12]
                  .map((m) => DropdownMenuItem(value: m, child: Text('$m개월')))
                  .toList(),
              onChanged: (m) {
                if (m != null) notifier.setCheckupIntervalMonths(m);
              },
            ),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('안내'),
            subtitle: Text(
              '이 앱의 일정·안내는 일반적 권고이며, 개별 아동의 실제 치료 시기는 '
              '반드시 치과 전문의 상담으로 결정해야 합니다.',
            ),
          ),
        ],
      ),
    );
  }
}
