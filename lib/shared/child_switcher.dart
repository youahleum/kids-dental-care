import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/utils/age_utils.dart';
import '../data/providers.dart';
import '../features/children/selected_child.dart';
import 'child_avatar.dart';

/// 상단 자녀 전환기. 탭하면 자녀 선택 시트. 기준: DESIGN.md 5장
class ChildSwitcher extends ConsumerWidget {
  const ChildSwitcher({super.key});

  Future<void> _pick(BuildContext context, WidgetRef ref) async {
    final children = ref.read(childrenProvider).valueOrNull ?? const [];
    if (children.length <= 1) return;
    final picked = await showModalBottomSheet<int>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final c in children)
              ListTile(
                leading: ChildAvatar(child: c, size: 32),
                title: Text(c.name),
                subtitle: Text(AgeUtils.label(c.birthDate)),
                onTap: () => Navigator.pop(context, c.id),
              ),
          ],
        ),
      ),
    );
    if (picked != null) {
      ref.read(selectedChildIdProvider.notifier).state = picked;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final child = ref.watch(selectedChildProvider);
    final childCount =
        (ref.watch(childrenProvider).valueOrNull ?? const []).length;
    if (child == null) return const SizedBox.shrink();

    return InkWell(
      onTap: childCount > 1 ? () => _pick(context, ref) : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Row(
          children: [
            ChildAvatar(child: child, size: 28),
            const SizedBox(width: 8),
            Text(
              '${child.name} · ${AgeUtils.label(child.birthDate)}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            if (childCount > 1) const Icon(Icons.expand_more, size: 20),
          ],
        ),
      ),
    );
  }
}
