import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../data/providers.dart';
import '../../domain/models/checkup_record.dart';
import '../../domain/services/checkup_scheduler.dart';
import '../../shared/child_switcher.dart';
import '../children/selected_child.dart';
import '../settings/settings_controller.dart';
import 'checkup_add_screen.dart';

/// 검진 기록 · 이력. 기준: DESIGN.md 6-4
class CheckupsScreen extends ConsumerWidget {
  const CheckupsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final child = ref.watch(selectedChildProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('검진 기록')),
      floatingActionButton: child == null
          ? null
          : FloatingActionButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CheckupAddScreen(childId: child.id),
                ),
              ),
              child: const Icon(Icons.add),
            ),
      body: child == null
          ? _noChild(context)
          : Column(
              children: [
                const ChildSwitcher(),
                Expanded(child: _CheckupList(childId: child.id)),
              ],
            ),
    );
  }

  Widget _noChild(BuildContext context) => Center(
        child: Text(
          '먼저 홈에서 자녀를 등록해 주세요.',
          style: TextStyle(color: Theme.of(context).hintColor),
        ),
      );
}

class _CheckupList extends ConsumerWidget {
  const _CheckupList({required this.childId});

  final int childId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(checkupsProvider(childId));
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('오류가 발생했습니다.\n$e')),
      data: (records) {
        final interval = ref.watch(
            settingsProvider.select((s) => s.checkupIntervalMonths));
        final nextDate =
            CheckupScheduler.nextDate(records, intervalMonths: interval);
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          children: [
            _NextCard(nextDate: nextDate),
            const SizedBox(height: 12),
            Text('지난 이력',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).hintColor)),
            const SizedBox(height: 8),
            if (records.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text('아직 검진 기록이 없습니다.',
                      style: TextStyle(color: Theme.of(context).hintColor)),
                ),
              )
            else
              for (final r in records)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _CheckupCard(
                    record: r,
                    onDelete: () => ref
                        .read(checkupRepositoryProvider)
                        .delete(r.id),
                  ),
                ),
          ],
        );
      },
    );
  }
}

class _NextCard extends StatelessWidget {
  const _NextCard({required this.nextDate});

  final DateTime? nextDate;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.mint, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('다음 검진 예정',
                      style: TextStyle(
                          fontSize: 12, color: Theme.of(context).hintColor)),
                  const SizedBox(height: 4),
                  Text(
                    nextDate == null
                        ? '검진 기록을 추가하면 계산됩니다'
                        : DateFormat('yyyy-MM-dd').format(nextDate!),
                    style: TextStyle(
                      fontSize: nextDate == null ? 14 : 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            if (nextDate != null) _DdayChip(date: nextDate!),
          ],
        ),
      ),
    );
  }
}

class _DdayChip extends StatelessWidget {
  const _DdayChip({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final days = target.difference(today).inDays;
    final (label, color) = days < 0
        ? ('지남', AppColors.statusOverdue)
        : days == 0
            ? ('오늘', AppColors.statusUpcoming)
            : ('D-$days', AppColors.statusUpcoming);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

class _CheckupCard extends StatelessWidget {
  const _CheckupCard({required this.record, required this.onDelete});

  final CheckupRecord record;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(DateFormat('yyyy-MM-dd').format(record.date),
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600)),
                      if (record.clinicName != null) ...[
                        const Spacer(),
                        Text(record.clinicName!,
                            style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).hintColor)),
                      ],
                    ],
                  ),
                  if (record.memo != null) ...[
                    const SizedBox(height: 5),
                    Text(record.memo!,
                        style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).hintColor)),
                  ],
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
