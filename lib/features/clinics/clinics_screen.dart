import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../../domain/models/clinic.dart';
import '../../shared/status_views.dart';

/// 단골 치과 관리. 기준: PLAN.md 10장
class ClinicsScreen extends ConsumerWidget {
  const ClinicsScreen({super.key});

  Future<void> _edit(BuildContext context, WidgetRef ref, {Clinic? existing}) {
    return showDialog(
      context: context,
      builder: (_) => _ClinicDialog(existing: existing),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, Clinic c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('${c.name} 삭제'),
        content: const Text('이 치과 정보를 삭제할까요?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('취소')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('삭제')),
        ],
      ),
    );
    if (ok == true) await ref.read(clinicRepositoryProvider).delete(c.id);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(clinicsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('단골 치과')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _edit(context, ref),
        child: const Icon(Icons.add),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorView(error: e),
        data: (clinics) {
          if (clinics.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.local_hospital_outlined,
                        size: 48,
                        color: Theme.of(context).colorScheme.primary),
                    const SizedBox(height: 12),
                    Text('자주 가는 치과를 등록해 두세요.',
                        style: TextStyle(color: Theme.of(context).hintColor)),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => _edit(context, ref),
                      child: const Text('치과 추가'),
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: clinics.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final c = clinics[i];
              return Card(
                child: ListTile(
                  title: Text(c.name),
                  subtitle: Text([
                    if (c.phone != null) c.phone!,
                    if (c.address != null) c.address!,
                    if (c.memo != null) c.memo!,
                  ].join('\n')),
                  isThreeLine: c.address != null || c.memo != null,
                  onTap: () => _edit(context, ref, existing: c),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _confirmDelete(context, ref, c),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _ClinicDialog extends ConsumerStatefulWidget {
  const _ClinicDialog({this.existing});
  final Clinic? existing;

  @override
  ConsumerState<_ClinicDialog> createState() => _ClinicDialogState();
}

class _ClinicDialogState extends ConsumerState<_ClinicDialog> {
  late final _name = TextEditingController(text: widget.existing?.name ?? '');
  late final _phone = TextEditingController(text: widget.existing?.phone ?? '');
  late final _address =
      TextEditingController(text: widget.existing?.address ?? '');
  late final _memo = TextEditingController(text: widget.existing?.memo ?? '');

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _address.dispose();
    _memo.dispose();
    super.dispose();
  }

  String? _v(TextEditingController c) =>
      c.text.trim().isEmpty ? null : c.text.trim();

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) return;
    final repo = ref.read(clinicRepositoryProvider);
    if (widget.existing != null) {
      await repo.update(widget.existing!.copyWith(
        name: name,
        phone: _v(_phone),
        address: _v(_address),
        memo: _v(_memo),
      ));
    } else {
      await repo.add(
        name: name,
        phone: _v(_phone),
        address: _v(_address),
        memo: _v(_memo),
      );
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existing == null ? '치과 추가' : '치과 편집'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _name,
              decoration: const InputDecoration(labelText: '이름'),
            ),
            TextField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: '연락처 (선택)'),
            ),
            TextField(
              controller: _address,
              decoration: const InputDecoration(labelText: '주소 (선택)'),
            ),
            TextField(
              controller: _memo,
              decoration: const InputDecoration(labelText: '메모 (선택)'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소')),
        FilledButton(onPressed: _save, child: const Text('저장')),
      ],
    );
  }
}
