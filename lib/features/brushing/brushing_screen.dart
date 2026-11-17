import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../data/providers.dart';
import '../../domain/models/brushing.dart';
import '../../domain/models/child.dart';
import '../../domain/services/brushing_stats.dart';
import '../../shared/child_avatar.dart';
import 'celebration.dart';
import '../../shared/gradient_app_bar.dart';

/// 양치 기록 · 칭찬 스티커 판.
class BrushingScreen extends ConsumerWidget {
  const BrushingScreen({super.key, required this.child});

  final Child child;

  /// 스티커 판에 보여줄 기간(주).
  static const _weeks = 4;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(brushingLogsProvider(child.id)).valueOrNull ?? const {};
    final stats = ref.watch(brushingStatsProvider(child.id));

    return Scaffold(
      appBar: GradientAppBar(title: Text('${child.name} 양치 기록')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _TodayCard(child: child, stats: stats),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  emoji: '🔥',
                  value: '${stats.streak}일',
                  label: '연속 양치',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatTile(
                  emoji: '⭐',
                  value: '${stats.stickers}개',
                  label: '모은 스티커',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('칭찬 스티커 판',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text('아침·자기 전 모두 닦은 날에 별이 붙어요. 날짜를 눌러 고칠 수 있어요.',
                      style: TextStyle(
                          fontSize: 12, color: Theme.of(context).hintColor)),
                  const SizedBox(height: 12),
                  _StickerBoard(child: child, logs: logs, weeks: _weeks),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 오늘 양치 체크 (큰 버튼 2개).
class _TodayCard extends ConsumerWidget {
  const _TodayCard({required this.child, required this.stats});

  final Child child;
  final BrushingStats stats;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final done = BrushingStats.isPerfect(stats.today);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                ChildAvatar(child: child, size: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    done ? '오늘 양치 완료! 정말 잘했어요 🎉' : '오늘 양치했나요?',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                for (final slot in BrushingSlot.values) ...[
                  if (slot.index > 0) const SizedBox(width: 12),
                  Expanded(
                    child: BrushingToggle(
                      childId: child.id,
                      date: DateTime.now(),
                      slot: slot,
                      checked: stats.today.contains(slot),
                      large: true,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 시간대별 양치 체크 버튼. 홈 카드와 양치 화면에서 함께 쓴다.
class BrushingToggle extends ConsumerWidget {
  const BrushingToggle({
    super.key,
    required this.childId,
    required this.date,
    required this.slot,
    required this.checked,
    this.large = false,
  });

  final int childId;
  final DateTime date;
  final BrushingSlot slot;
  final bool checked;
  final bool large;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final color = checked ? AppColors.mint : Theme.of(context).hintColor;
    return Material(
      color: checked
          ? AppColors.mint.withValues(alpha: 0.14)
          : scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(large ? 16 : 20),
      child: InkWell(
        borderRadius: BorderRadius.circular(large ? 16 : 20),
        onTap: () async {
          // 이번 체크로 그날 양치가 모두 채워지면 칭찬 효과를 보여준다.
          final already = ref
                  .read(brushingLogsProvider(childId))
                  .valueOrNull?[dayOf(date)] ??
              const <BrushingSlot>{};
          final completes = !checked &&
              already.length == BrushingSlot.values.length - 1;
          await ref.read(brushingRepositoryProvider).setBrushed(
                childId: childId,
                date: date,
                slot: slot,
                brushed: !checked,
              );
          if (completes && context.mounted) showBrushingCelebration(context);
        },
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: large ? 12 : 10, vertical: large ? 16 : 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(large ? 16 : 20),
            border: Border.all(
                color: checked ? AppColors.mint : scheme.outlineVariant),
          ),
          child: Row(
            mainAxisSize: large ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(slot.emoji, style: TextStyle(fontSize: large ? 20 : 13)),
              const SizedBox(width: 6),
              Text(
                slot.label,
                style: TextStyle(
                  fontSize: large ? 15 : 12,
                  fontWeight: FontWeight.w600,
                  color: checked ? scheme.tertiary : color,
                ),
              ),
              if (checked) ...[
                const SizedBox(width: 4),
                Icon(Icons.check_circle,
                    size: large ? 18 : 14, color: AppColors.mint),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile(
      {required this.emoji, required this.value, required this.label});

  final String emoji;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(height: 4),
            Text(value,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            Text(label,
                style: TextStyle(
                    fontSize: 12, color: Theme.of(context).hintColor)),
          ],
        ),
      ),
    );
  }
}

/// 최근 N주 달력. 완벽한 날 ⭐, 한 번만 닦은 날은 반쯤 채운 원.
class _StickerBoard extends ConsumerWidget {
  const _StickerBoard(
      {required this.child, required this.logs, required this.weeks});

  final Child child;
  final Map<DateTime, Set<BrushingSlot>> logs;
  final int weeks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = dayOf(DateTime.now());
    // 이번 주 일요일까지 채우도록 끝을 맞춘다 (월요일 시작).
    final end = today.add(Duration(days: 7 - today.weekday));
    final start = DateTime(end.year, end.month, end.day - weeks * 7 + 1);
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];

    return Column(
      children: [
        Row(
          children: [
            for (final w in weekdays)
              Expanded(
                child: Center(
                  child: Text(w,
                      style: TextStyle(
                          fontSize: 11, color: Theme.of(context).hintColor)),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        for (var w = 0; w < weeks; w++)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                for (var d = 0; d < 7; d++)
                  Expanded(
                    child: _DayCell(
                      child: child,
                      date: DateTime(
                          start.year, start.month, start.day + w * 7 + d),
                      slots: logs[DateTime(
                              start.year, start.month, start.day + w * 7 + d)] ??
                          const {},
                      today: today,
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _DayCell extends ConsumerWidget {
  const _DayCell({
    required this.child,
    required this.date,
    required this.slots,
    required this.today,
  });

  final Child child;
  final DateTime date;
  final Set<BrushingSlot> slots;
  final DateTime today;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final future = date.isAfter(today);
    final isToday = date == today;
    final perfect = BrushingStats.isPerfect(slots);
    final partial = !perfect && slots.isNotEmpty;

    Widget mark;
    if (perfect) {
      mark = const Text('⭐', style: TextStyle(fontSize: 20));
    } else if (partial) {
      mark = Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.mint.withValues(alpha: 0.35),
        ),
      );
    } else {
      mark = Text('${date.day}',
          style: TextStyle(
              fontSize: 12,
              color: future
                  ? Theme.of(context).colorScheme.outlineVariant
                  : Theme.of(context).hintColor));
    }

    return AspectRatio(
      aspectRatio: 1,
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Material(
          color: perfect
              ? const Color(0xFFFFC107).withValues(alpha: 0.18)
              : future
                  ? Colors.transparent
                  : Theme.of(context).colorScheme.surfaceContainerLow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: isToday
                ? const BorderSide(color: AppColors.mint, width: 1.5)
                : BorderSide.none,
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: future ? null : () => _edit(context),
            child: Center(child: mark),
          ),
        ),
      ),
    );
  }

  void _edit(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Consumer(builder: (context, ref, _) {
            final current =
                ref.watch(brushingLogsProvider(child.id)).valueOrNull?[date] ??
                    const <BrushingSlot>{};
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${date.month}월 ${date.day}일 양치',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    for (final slot in BrushingSlot.values) ...[
                      if (slot.index > 0) const SizedBox(width: 12),
                      Expanded(
                        child: BrushingToggle(
                          childId: child.id,
                          date: date,
                          slot: slot,
                          checked: current.contains(slot),
                          large: true,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
