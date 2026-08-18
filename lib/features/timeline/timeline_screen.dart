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
      appBar: AppBar(title: const Text('타임라인')),
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
          return const Center(child: Text('표시할 항목이 없습니다.'));
        }

        // 임박 항목: 미완료 중 권장일이 가장 가까운(오늘 이후 우선) 것.
        final next = _nextTask(all);

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          children: [
            const _DisclaimerBanner(),
            if (next != null && filter != _Filter.done) ...[
              _TaskCard(task: next, highlight: true),
              const SizedBox(height: 8),
              const Divider(),
            ],
            for (final t in tasks)
              if (t.id != next?.id || filter == _Filter.done)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _TaskCard(task: t),
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
    final now = DateTime.now();
    final upcoming = pending.where((t) => !t.recommendedDate.isBefore(now)).toList()
      ..sort((a, b) => a.recommendedDate.compareTo(b.recommendedDate));
    if (upcoming.isNotEmpty) return upcoming.first;
    // 모두 지난 경우 가장 최근에 지난 것
    pending.sort((a, b) => b.recommendedDate.compareTo(a.recommendedDate));
    return pending.first;
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
              Icon(_iconFor(task.type), color: AppColors.mintDark),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('yyyy-MM-dd').format(task.recommendedDate),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.statusUpcoming.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: AppColors.statusUpcoming.withValues(alpha: 0.4)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, size: 16, color: Color(0xFF8A5A00)),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              '실제 치료 시기는 치과 상담으로 결정하세요.',
              style: TextStyle(fontSize: 12, color: Color(0xFF8A5A00)),
            ),
          ),
        ],
      ),
    );
  }
}

