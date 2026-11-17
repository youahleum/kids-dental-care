import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../clinics/clinics_screen.dart';
import '../notifications/notification_controller.dart';
import '../../domain/models/brushing.dart';
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
          SwitchListTile(
            title: const Text('양치 알림'),
            subtitle: const Text('매일 아침·자기 전에 양치 시간을 알려드려요.'),
            value: settings.brushingReminderEnabled,
            onChanged: (v) async {
              await notifier.setBrushingReminderEnabled(v);
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
          for (final slot in BrushingSlot.values)
            ListTile(
              enabled: settings.brushingReminderEnabled,
              leading: Text(slot.emoji, style: const TextStyle(fontSize: 20)),
              title: Text('${slot.label} 알림 시각'),
              trailing: Text(
                '${(slot == BrushingSlot.morning ? settings.morningBrushHour : settings.nightBrushHour).toString().padLeft(2, '0')}:00',
                style: const TextStyle(fontSize: 16),
              ),
              onTap: settings.brushingReminderEnabled
                  ? () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay(
                            hour: slot == BrushingSlot.morning
                                ? settings.morningBrushHour
                                : settings.nightBrushHour,
                            minute: 0),
                        helpText: '${slot.label} 양치 알림 시각',
                      );
                      if (picked != null) {
                        await notifier.setBrushHour(slot, picked.hour);
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
          ListTile(
            leading: const Icon(Icons.local_hospital_outlined),
            title: const Text('단골 치과'),
            subtitle: const Text('자주 가는 치과 정보 관리'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ClinicsScreen()),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.upload_file_outlined),
            title: const Text('백업 만들기'),
            subtitle: const Text('모든 기록을 백업 코드로 복사해요. 메모장·메신저에 붙여넣어 보관하세요.'),
            onTap: () => _exportBackup(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('백업에서 복원'),
            subtitle: const Text('보관한 백업 코드를 붙여넣어 기록을 되살려요.'),
            onTap: () => _importBackup(context, ref),
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

  Future<void> _exportBackup(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final json = await ref.read(backupServiceProvider).exportToJson();
      await Clipboard.setData(ClipboardData(text: json));
      messenger.showSnackBar(
        const SnackBar(content: Text('백업 코드를 복사했어요. 안전한 곳에 붙여넣어 보관하세요.')),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('백업에 실패했어요: $e')));
    }
  }

  Future<void> _importBackup(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('백업에서 복원'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('지금 앱에 있는 기록은 모두 백업 내용으로 바뀌어요.'),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: '백업 코드를 붙여넣으세요',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('복원'),
          ),
        ],
      ),
    );
    final text = controller.text.trim();
    controller.dispose();
    if (ok != true || text.isEmpty || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(backupServiceProvider).importFromJson(text);
      await rescheduleAllNotifications(ref);
      messenger.showSnackBar(const SnackBar(content: Text('복원했어요.')));
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('백업 코드가 올바르지 않아요. 기존 기록은 그대로예요.')),
      );
    }
  }
}
