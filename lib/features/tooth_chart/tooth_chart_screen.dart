import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../../domain/models/tooth_layout.dart';
import '../../domain/models/tooth_record.dart';
import '../../shared/child_switcher.dart';
import '../../shared/status_views.dart';
import '../children/selected_child.dart';
import '../home/tab_index.dart';
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
          ? NoChildView(
              onGoHome: () => ref.read(tabIndexProvider.notifier).state = 0,
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
      error: (e, _) => ErrorView(error: e),
      data: (records) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Text('위턱 (상악)',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).hintColor)),
                    const SizedBox(height: 6),
                    const _SideGuide(),
                    const SizedBox(height: 6),
                    _Arch(codes: upper, records: records, childId: childId),
                    const SizedBox(height: 20),
                    _Arch(codes: lower, records: records, childId: childId),
                    const SizedBox(height: 6),
                    const _SideGuide(),
                    const SizedBox(height: 6),
                    Text('아래턱 (하악)',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).hintColor)),
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

/// 좌/우 방향 가이드 (화면 기준). 가운데는 앞니, 바깥으로 갈수록 어금니.
class _SideGuide extends StatelessWidget {
  const _SideGuide();

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.primary);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('◀ 오른쪽', style: style),
        Text('가운데', style: TextStyle(fontSize: 10, color: Theme.of(context).hintColor)),
        Text('왼쪽 ▶', style: style),
      ],
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
    // 좌/우 절반 사이에 중앙 구분선을 넣어 방향을 명확히 한다.
    final half = codes.length ~/ 2;
    Widget tooth(int code) => _Tooth(
          code: code,
          status: records[code]?.status ?? ToothStatus.healthy,
          childId: childId,
        );
    // 영구치는 16개라 좁은 화면에서 넘칠 수 있어 가로 스크롤로 감싼다.
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final code in codes.sublist(0, half))
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: tooth(code)),
          Container(
            width: 1,
            height: 30,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            color: Theme.of(context).dividerColor,
          ),
          for (final code in codes.sublist(half))
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: tooth(code)),
        ],
      ),
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
    final pos = code % 10;
    // 앞니는 좁게, 어금니는 넓게 — 종류가 형태로 구분되게.
    final isFront = pos <= 2; // 앞니
    final isMolar = pos >= 4; // 어금니류(작은·큰어금니)
    final width = isFront ? 18.0 : (isMolar ? 26.0 : 22.0);

    return InkWell(
      onTap: () => _openSheet(context, ref),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: width,
            height: 28,
            alignment: Alignment.center,
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
          const SizedBox(height: 2),
          Text(
            ToothLayout.shortMark(code),
            style: TextStyle(
                fontSize: 9, color: Theme.of(context).hintColor),
          ),
        ],
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
