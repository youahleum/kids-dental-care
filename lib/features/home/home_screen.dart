import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/age_utils.dart';
import '../../data/providers.dart';
import '../../domain/models/child.dart';
import '../../shared/child_avatar.dart';
import '../children/child_edit_screen.dart';
import '../children/selected_child.dart';
import 'tab_index.dart';

/// 홈 · 자녀 선택. 기준: DESIGN.md 6-1
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
        content: const Text('이 자녀의 모든 기록이 삭제됩니다. 계속할까요?'),
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
      appBar: AppBar(title: const Text('우리 아이 치아')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEdit(context),
        child: const Icon(Icons.add),
      ),
      body: childrenAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('오류가 발생했습니다.\n$e')),
        data: (children) {
          if (children.isEmpty) return const _EmptyState();
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: children.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
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
    );
  }
}

class _ChildCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ChildAvatar(child: child),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      child.name,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AgeUtils.label(child.birthDate),
                      style: TextStyle(
                          fontSize: 12, color: Theme.of(context).hintColor),
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
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.child_care, size: 64, color: primary),
            const SizedBox(height: 16),
            const Text(
              '첫 아이를 등록해 주세요',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              '생년월일만 입력하면 나이에 맞는 검진·예방치료 일정을 자동으로 챙겨드려요.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).hintColor),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ChildEditScreen()),
              ),
              child: const Text('자녀 추가하기'),
            ),
          ],
        ),
      ),
    );
  }
}
