import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../data/providers.dart';
import '../../domain/models/preventive_task.dart';
import '../../shared/child_switcher.dart';
import '../../shared/status_views.dart';
import '../children/selected_child.dart';
import '../home/tab_index.dart';
import 'task_status_view.dart';
import '../../shared/gradient_app_bar.dart';

enum _Filter { all, pending, done }

/// 예방치료 타임라인. 기준: DESIGN.md 6-3
class TimelineScreen extends ConsumerStatefulWidget {
  const TimelineScreen({super.key});

  @override
  ConsumerState<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends ConsumerState<TimelineScreen> {
  _Filter _filter = _Filter.all;

  @override
  Widget build(BuildContext context) {
    final child = ref.watch(selectedChildProvider);

    return Scaffold(
      appBar: GradientAppBar(title: const Text('타임라인')),
      body: child == null
          ? NoChildView(
              onGoHome: () =>
                  ref.read(tabIndexProvider.notifier).state = 0,
            )
          : Column(
              children: [
                const ChildSwitcher(),
                _FilterBar(
                  filter: _filter,
                  onChanged: (f) => setState(() => _filter = f),
                ),
                Expanded(child: _TimelineList(childId: child.id, filter: _filter)),
              ],
            ),
    );
  }
}

class _TimelineList extends ConsumerWidget {
  const _TimelineList({required this.childId, required this.filter});

  final int childId;
  final _Filter filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(timelineProvider(childId));
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => ErrorView(error: e),
      data: (all) {
        final tasks = switch (filter) {
          _Filter.all => all,
          _Filter.pending => all.where((t) => t.status != TaskStatus.done).toList(),
          _Filter.done => all.where((t) => t.status == TaskStatus.done).toList(),
        };
        if (tasks.isEmpty) {
          return MascotEmptyView(
            title: switch (filter) {
              _Filter.done => '아직 완료한 항목이 없어요',
              _Filter.pending => '남은 일정이 없어요. 잘하고 있어요!',
              _Filter.all => '표시할 일정이 없어요',
            },
            message: filter == _Filter.done
                ? '검진·예방치료를 받고 항목을 눌러 완료로 표시해 보세요.'
                : null,
          );
        }

        // 임박 항목: 미완료 중 권장일이 가장 가까운(오늘 이후 우선) 것.
        final next = _nextTask(all);

        final showNext = next != null && filter != _Filter.done;
        final rows = [
          for (final t in tasks)
            if (!showNext || t.id != next.id) t,
        ];

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          children: [
            const _DisclaimerBanner(),
            if (showNext) ...[
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 6),
                child: Text('다음 할 일',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.tertiary)),
              ),
              _TaskCard(task: next, highlight: true),
              const SizedBox(height: 16),
            ],
            for (var i = 0; i < rows.length; i++)
              _TimelineRow(
                task: rows[i],
                isFirst: i == 0,
                isLast: i == rows.length - 1,
              ),
          ],
        );
      },
    );
  }

  PreventiveTask? _nextTask(List<PreventiveTask> all) {
    final pending =
        all.where((t) => t.status != TaskStatus.done).toList();
    if (pending.isEmpty) return null;
    // 오늘 날짜(0시) 기준 — 현재 시각과 비교하면 '오늘' 항목이 빠진다.
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final upcoming = pending.where((t) => !t.recommendedDate.isBefore(today)).toList()
      ..sort((a, b) => a.recommendedDate.compareTo(b.recommendedDate));
    if (upcoming.isNotEmpty) return upcoming.first;
    // 모두 지난 경우 가장 최근에 지난 것
    pending.sort((a, b) => b.recommendedDate.compareTo(a.recommendedDate));
    return pending.first;
  }
}

/// 타임라인 한 줄: 왼쪽 세로선·상태 점 + 오른쪽 카드.
class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.task,
    required this.isFirst,
    required this.isLast,
  });

  final PreventiveTask task;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final (_, color) = TaskStatusView.resolve(task);
    final done = task.status == TaskStatus.done;
    final line = Theme.of(context).colorScheme.outlineVariant;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 30,
            child: Column(
              children: [
                Container(
                    width: 2,
                    height: 24,
                    color: isFirst ? Colors.transparent : line),
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: done ? color : Theme.of(context).cardTheme.color,
                    border: Border.all(color: color, width: 3),
                  ),
                  child: done
                      ? const Icon(Icons.check, size: 11, color: Colors.white)
                      : null,
                ),
                Expanded(
                  child: Container(
                      width: 2, color: isLast ? Colors.transparent : line),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _TaskCard(task: task),
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskCard extends ConsumerWidget {
  const _TaskCard({required this.task, this.highlight = false});

  final PreventiveTask task;
  final bool highlight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final done = task.status == TaskStatus.done;
    return Card(
      shape: highlight
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.mint, width: 1.5),
            )
          : null,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => ref
            .read(preventiveTaskRepositoryProvider)
            .setDone(task.id, done: !done),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(_iconFor(task.type),
                  color: Theme.of(context).colorScheme.tertiary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        decoration: done ? TextDecoration.lineThrough : null,
                        color: done ? Theme.of(context).hintColor : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('yyyy.M.d').format(task.recommendedDate),
                      style: TextStyle(
                          fontSize: 11, color: Theme.of(context).hintColor),
                    ),
                  ],
                ),
              ),
              TaskStatusView(task: task),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconFor(PreventiveType type) => switch (type) {
        PreventiveType.firstVisit => Icons.emoji_people,
        PreventiveType.checkup => Icons.medical_services_outlined,
        PreventiveType.fluoride => Icons.water_drop_outlined,
        PreventiveType.sealant => Icons.shield_outlined,
        PreventiveType.scaling => Icons.cleaning_services_outlined,
      };
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.filter, required this.onChanged});

  final _Filter filter;
  final ValueChanged<_Filter> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: SegmentedButton<_Filter>(
        segments: const [
          ButtonSegment(value: _Filter.all, label: Text('전체')),
          ButtonSegment(value: _Filter.pending, label: Text('예정')),
          ButtonSegment(value: _Filter.done, label: Text('완료')),
        ],
        selected: {filter},
        onSelectionChanged: (s) => onChanged(s.first),
      ),
    );
  }
}

class _DisclaimerBanner extends StatelessWidget {
  const _DisclaimerBanner();

  @override
  Widget build(BuildContext context) {
    final ink = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFFFFCC80)
        : const Color(0xFF8A5A00);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.statusUpcoming.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: AppColors.statusUpcoming.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 16, color: ink),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '실제 치료 시기는 치과 상담으로 결정하세요.',
              style: TextStyle(fontSize: 12, color: ink),
            ),
          ),
        ],
      ),
    );
  }
}

