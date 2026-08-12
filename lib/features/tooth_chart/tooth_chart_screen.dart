import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../../domain/models/tooth_layout.dart';
import '../../domain/models/tooth_record.dart';
import '../../shared/child_switcher.dart';
import '../children/selected_child.dart';
import 'tooth_status_style.dart';

/// 치아별 상태 기록. 기준: DESIGN.md 6-5
class ToothChartScreen extends ConsumerStatefulWidget {
  const ToothChartScreen({super.key});

  @override
  ConsumerState<ToothChartScreen> createState() => _ToothChartScreenState();
}

class _ToothChartScreenState extends ConsumerState<ToothChartScreen> {
  bool _primary = true; // true: 유치, false: 영구치

  @override
  Widget build(BuildContext context) {
    final child = ref.watch(selectedChildProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('치아 차트')),
      body: child == null
          ? Center(
              child: Text('먼저 홈에서 자녀를 등록해 주세요.',
                  style: TextStyle(color: Theme.of(context).hintColor)),
            )
          : Column(
              children: [
                const ChildSwitcher(),
                _KindToggle(
                  primary: _primary,
                  onChanged: (v) => setState(() => _primary = v),
                ),
                Expanded(
                  child: _Chart(childId: child.id, primary: _primary),
                ),
              ],
            ),
    );
  }
}

class _KindToggle extends StatelessWidget {
  const _KindToggle({required this.primary, required this.onChanged});

  final bool primary;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: SegmentedButton<bool>(
        segments: const [
          ButtonSegment(value: true, label: Text('유치')),
          ButtonSegment(value: false, label: Text('영구치')),
        ],
        selected: {primary},
        onSelectionChanged: (s) => onChanged(s.first),
      ),
    );
  }
}

class _Chart extends ConsumerWidget {
  const _Chart({required this.childId, required this.primary});

  final int childId;
  final bool primary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(toothChartProvider(childId));
    final upper = primary ? ToothLayout.primaryUpper : ToothLayout.permanentUpper;
    final lower = primary ? ToothLayout.primaryLower : ToothLayout.permanentLower;

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('오류가 발생했습니다.\n$e')),
      data: (records) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Text('상악 (위)',
                        style: TextStyle(
                            fontSize: 12, color: Theme.of(context).hintColor)),
                    const SizedBox(height: 8),
                    _Arch(codes: upper, records: records, childId: childId),
                    const SizedBox(height: 16),
                    _Arch(codes: lower, records: records, childId: childId),
                    const SizedBox(height: 8),
                    Text('하악 (아래)',
                        style: TextStyle(
                            fontSize: 12, color: Theme.of(context).hintColor)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const _Legend(),
          ],
        );
      },
    );
  }
}

class _Arch extends StatelessWidget {
  const _Arch({
    required this.codes,
    required this.records,
    required this.childId,
  });

  final List<int> codes;
  final Map<int, ToothRecord> records;
  final int childId;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 4,
      runSpacing: 4,
      children: [
        for (final code in codes)
          _Tooth(
            code: code,
            status: records[code]?.status ?? ToothStatus.healthy,
            childId: childId,
          ),
      ],
    );
  }
}

class _Tooth extends ConsumerWidget {
  const _Tooth({
    required this.code,
    required this.status,
    required this.childId,
  });

  final int code;
  final ToothStatus status;
  final int childId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final style = toothStatusStyle(status);
    final isHealthy = status == ToothStatus.healthy;
    return InkWell(
      onTap: () => _openSheet(context, ref),
      child: Container(
        width: 22,
        height: 28,
        decoration: BoxDecoration(
          color: style.color,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(6),
            bottom: Radius.circular(7),
          ),
          border: Border.all(
            color: isHealthy ? const Color(0xFFCFD8DC) : style.color,
            width: 1.4,
          ),
        ),
      ),
    );
  }

  Future<void> _openSheet(BuildContext context, WidgetRef ref) async {
    final picked = await showModalBottomSheet<ToothStatus>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(ToothLayout.label(code),
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
            for (final s in ToothStatus.values)
              ListTile(
                leading: _swatch(s),
                title: Text(toothStatusStyle(s).label),
                selected: s == status,
                onTap: () => Navigator.pop(context, s),
              ),
          ],
        ),
      ),
    );
    if (picked != null) {
      await ref.read(toothRepositoryProvider).setStatus(
            childId: childId,
            toothCode: code,
            status: picked,
          );
    }
  }

  Widget _swatch(ToothStatus s) {
    final style = toothStatusStyle(s);
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: style.color,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFCFD8DC)),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        for (final s in ToothStatus.values)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: toothStatusStyle(s).color,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFCFD8DC)),
                ),
              ),
              const SizedBox(width: 6),
              Text(toothStatusStyle(s).label,
                  style: const TextStyle(fontSize: 12)),
            ],
          ),
      ],
    );
  }
}
