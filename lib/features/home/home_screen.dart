import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/age_utils.dart';
import '../../data/providers.dart';
import '../../domain/models/child.dart';
import '../../domain/models/brushing.dart';
import '../../domain/services/dashboard_stats.dart';
import '../../shared/child_avatar.dart';
import '../../shared/status_views.dart';
import '../brushing/brushing_screen.dart';
import '../children/child_edit_screen.dart';
import '../children/selected_child.dart';
import '../settings/settings_screen.dart';
import 'tab_index.dart';

/// 홈 · 가족 구성원 선택. 기준: DESIGN.md 6-1
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _openEdit(BuildContext context, {Child? existing}) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ChildEditScreen(existing: existing)),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, Child child) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('${child.name} 삭제'),
        content: const Text('이 구성원의 모든 기록이 삭제됩니다. 계속할까요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(childRepositoryProvider).delete(child.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final childrenAsync = ref.watch(childrenProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'home-fab',
        onPressed: () => _openEdit(context),
        icon: const Icon(Icons.add),
        label: const Text('가족 추가'),
      ),
      body: Column(
        children: [
          const _HomeHeader(),
          Expanded(
            child: childrenAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => ErrorView(
                error: e,
                onRetry: () => ref.invalidate(childrenProvider),
              ),
              data: (children) {
                if (children.isEmpty) return const _EmptyState();
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                  itemCount: children.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 14),
                  itemBuilder: (context, i) {
                    final c = children[i];
                    return _ChildCard(
                      child: c,
                      onTap: () {
                        ref.read(selectedChildIdProvider.notifier).state = c.id;
                        ref.read(tabIndexProvider.notifier).state = 1; // 타임라인
                      },
                      onEdit: () => _openEdit(context, existing: c),
                      onDelete: () => _confirmDelete(context, ref, c),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// 홈 상단 헤더: 로고 + 인사말 + 설정.
class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 11) return '좋은 아침! 아침 양치 잊지 마세요 ☀️';
    if (h < 18) return '오늘도 반짝반짝 빛나는 치아 ✨';
    return '자기 전 양치, 오늘도 함께해요 🌙';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.mint, Color(0xFF6CC9D3)],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 8, 22),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(16),
                ),
                // 로고 PNG는 여백이 넓어(적응형 아이콘 안전영역) 확대해 보여준다.
                child: Transform.scale(
                  scale: 1.7,
                  child: Image.asset('assets/icon/splash_logo.png'),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '우리 가족 덴탈 관리',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _greeting(),
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.92),
                          fontSize: 13),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined, color: Colors.white),
                tooltip: '설정',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChildCard extends ConsumerWidget {
  const _ChildCard({
    required this.child,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final Child child;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(dashboardStatsProvider(child.id));
    final color = Color(child.colorValue);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: color, width: 5)),
          ),
          padding: const EdgeInsets.fromLTRB(14, 14, 6, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ChildAvatar(child: child, size: 46),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          child.name,
                          style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          AgeUtils.label(child.birthDate),
                          style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).hintColor),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (v) {
                      if (v == 'edit') onEdit();
                      if (v == 'delete') onDelete();
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'edit', child: Text('편집')),
                      PopupMenuItem(value: 'delete', child: Text('삭제')),
                    ],
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    _Progress(stats: stats, color: color),
                    const SizedBox(height: 10),
                    _SummaryRow(stats: stats),
                    const Divider(height: 24),
                    _BrushingRow(child: child),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 예방치료 진행률 막대.
class _Progress extends StatelessWidget {
  const _Progress({required this.stats, required this.color});

  final DashboardStats stats;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('예방치료 진행',
                style: TextStyle(
                    fontSize: 12, color: Theme.of(context).hintColor)),
            const Spacer(),
            Text('${stats.doneTasks}/${stats.totalTasks} · ${stats.completionPercent}%',
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: stats.completionRate,
            minHeight: 8,
            backgroundColor: const Color(0xFFEDF2F4),
            color: color,
          ),
        ),
      ],
    );
  }
}

/// 오늘 양치 체크 + 연속일. 오른쪽을 누르면 스티커 판으로.
class _BrushingRow extends ConsumerWidget {
  const _BrushingRow({required this.child});

  final Child child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(brushingStatsProvider(child.id));
    return Row(
      children: [
        Text('오늘 양치',
            style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor)),
        const SizedBox(width: 8),
        Expanded(
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final slot in BrushingSlot.values)
                BrushingToggle(
                  childId: child.id,
                  date: DateTime.now(),
                  slot: slot,
                  checked: stats.today.contains(slot),
                ),
            ],
          ),
        ),
        TextButton(
          style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: const Size(0, 32)),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => BrushingScreen(child: child)),
          ),
          child: Text(
            stats.streak > 0 ? '🔥 ${stats.streak}일' : '⭐ 스티커',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

/// 구성원 카드 하단 요약: 다음 할 일 + 완료율 + 충치 경고.
class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.stats});

  final DashboardStats stats;

  @override
  Widget build(BuildContext context) {
    final next = stats.nextTask;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    Widget nextBadge;
    if (next == null) {
      nextBadge = _pill('할 일 없음', AppColors.statusNeutral);
    } else {
      final d = DateTime(next.recommendedDate.year, next.recommendedDate.month,
          next.recommendedDate.day);
      final days = d.difference(today).inDays;
      final (label, color) = days < 0
          ? ('지남', AppColors.statusOverdue)
          : days == 0
              ? ('오늘', AppColors.statusUpcoming)
              : ('D-$days', AppColors.statusUpcoming);
      nextBadge = _pill('${next.title} · $label', color);
    }

    return Row(
      children: [
        Flexible(child: nextBadge),
        if (stats.overdueTasks > 0) ...[
          const SizedBox(width: 6),
          _pill('놓친 일정 ${stats.overdueTasks}', AppColors.statusOverdue),
        ],
        if (stats.cariesCount > 0) ...[
          const SizedBox(width: 6),
          _pill('충치 ${stats.cariesCount}', AppColors.toothCaries),
        ],
      ],
    );
  }

  Widget _pill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontSize: 11, fontWeight: FontWeight.w600, color: _darken(color)),
      ),
    );
  }

  Color _darken(Color c) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness - 0.25).clamp(0.0, 1.0)).toColor();
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Image.asset('assets/icon/app_icon.png', width: 120),
            ),
            const SizedBox(height: 16),
            const Text(
              '가족을 등록해 주세요',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              '아이부터 어른까지, 생년월일만 입력하면 나이에 맞는 검진·스케일링·예방치료 일정을 챙겨드려요.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).hintColor),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ChildEditScreen()),
              ),
              child: const Text('가족 추가하기'),
            ),
          ],
        ),
      ),
    );
  }
}
