import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../notifications/notification_controller.dart';

/// 설정 화면. 기준: DESIGN.md 6-6 (M6은 알림 on/off. 시각·주기·백업은 M7)
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(notificationsEnabledProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('예방치료·검진 알림'),
            subtitle: const Text('시기가 되면 7일 전과 당일에 알려드려요.'),
            value: enabled,
            onChanged: (v) async {
              ref.read(notificationsEnabledProvider.notifier).state = v;
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
