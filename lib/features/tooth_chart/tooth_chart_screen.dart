import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/age_utils.dart';
import '../../data/providers.dart';
import '../../domain/models/tooth_layout.dart';
import '../../domain/models/tooth_record.dart';
import '../../shared/child_switcher.dart';
import '../../shared/status_views.dart';
import '../children/selected_child.dart';
import '../home/tab_index.dart';
import 'caries_trend_chart.dart';
import 'tooth_painter.dart';
import 'tooth_status_style.dart';
import '../../shared/gradient_app_bar.dart';

/// 치아별 상태 기록. 기준: DESIGN.md 6-5
class ToothChartScreen extends ConsumerStatefulWidget {
  const ToothChartScreen({super.key});

  @override
  ConsumerState<ToothChartScreen> createState() => _ToothChartScreenState();
}

class _ToothChartScreenState extends ConsumerState<ToothChartScreen> {
  /// 사용자가 고른 유치/영구치 (구성원 id별). 고르기 전에는 나이로 정한다.
  final Map<int, bool> _primaryByMember = {};

  /// 만 12세 무렵이면 유치가 거의 빠지므로 그 이상은 영구치로 시작.
  static bool _defaultPrimary(DateTime birthDate) =>
      AgeUtils.years(birthDate) < 12;

  @override
  Widget build(BuildContext context) {
    final child = ref.watch(selectedChildProvider);

    return Scaffold(
      appBar: GradientAppBar(title: const Text('치아 차트')),
      body: child == null
          ? NoChildView(
              onGoHome: () => ref.read(tabIndexProvider.notifier).state = 0,
            )
          : Builder(builder: (context) {
              final primary = _primaryByMember[child.id] ??
                  _defaultPrimary(child.birthDate);
              return Column(
                children: [
                  const ChildSwitcher(),
                  _KindToggle(
                    primary: primary,
                    onChanged: (v) =>
                        setState(() => _primaryByMember[child.id] = v),
                  ),
                  Expanded(
                    child: _Chart(childId: child.id, primary: primary),
                  ),
                ],
              );
            }),
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
                    _Arch(
                        codes: upper,
                        records: records,
                        childId: childId,
                        upper: true),
                    const SizedBox(height: 14),
                    _Arch(codes: lower, records: records, childId: childId),
                    const SizedBox(height: 10),
                    Text('치아를 누르면 이름을 보고 상태를 기록할 수 있어요.',
                        style: TextStyle(
                            fontSize: 11, color: Theme.of(context).hintColor)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const _Legend(),
            const SizedBox(height: 16),
            CariesTrendCard(childId: childId),
            const SizedBox(height: 16),
            _EruptionLog(childId: childId),
          ],
        );
      },
    );
  }
}

/// 치아를 실제 턱처럼 U자(아치)로 배치한다. 위턱은 ∩, 아래턱은 ∪ 모양이고
/// 뿌리가 바깥, 씹는 면이 안쪽을 향하도록 치아를 돌려 놓는다.
/// 폭에 맞춰 크기를 정하므로 영구치 16개도 옆으로 밀지 않고 한눈에 보인다.
class _Arch extends StatelessWidget {
  const _Arch({
    required this.codes,
    required this.records,
    required this.childId,
    this.upper = false,
  });

  final List<int> codes;
  final Map<int, ToothRecord> records;
  final int childId;
  final bool upper;

  static const _toothH = 34.0;
  static const _gap = 2.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final w = math.min(c.maxWidth, 360.0);
      // 치아 중심이 지나는 반타원. 치아 높이의 절반만큼 안쪽으로 들인다.
      final a = w / 2 - _toothH / 2 - 2;
      final b = a * 0.88;
      final height = b + _toothH / 2 + 4;
      final cx = c.maxWidth / 2;
      final cy = upper ? height : 0.0;

      // 반타원을 잘게 나눠 호 길이를 구한다 (치아를 폭에 비례해 고르게 놓기 위해).
      const steps = 240;
      Offset at(double t) {
        final th = math.pi * (1 - t); // t=0 왼쪽 끝 → t=1 오른쪽 끝
        return Offset(
          cx + a * math.cos(th),
          upper ? cy - b * math.sin(th) : cy + b * math.sin(th),
        );
      }

      final cum = <double>[0];
      for (var i = 1; i <= steps; i++) {
        cum.add(cum.last + (at(i / steps) - at((i - 1) / steps)).distance);
      }
      final arcLen = cum.last;

      // 종류별 폭: 어금니 > 작은어금니 > 앞니·송곳니.
      double baseWidth(int code) => switch (ToothLayout.kind(code)) {
            ToothKind.molar => 28.0,
            ToothKind.premolar => 23.0,
            _ => 20.0,
          };
      final needed = codes.fold<double>(0, (sum, code) => sum + baseWidth(code)) +
          _gap * (codes.length - 1);
      // 호에 딱 맞게 줄이되, 유치처럼 여유가 있으면 조금만 키운다.
      final scale = math.min(arcLen / needed, 1.25);

      double tAt(double len) {
        var i = cum.indexWhere((v) => v >= len);
        if (i <= 0) i = 1;
        final seg = cum[i] - cum[i - 1];
        return (i - 1 + (seg == 0 ? 0 : (len - cum[i - 1]) / seg)) / steps;
      }

      final children = <Widget>[];
      var cursor = (arcLen - needed * scale) / 2;
      for (final code in codes) {
        final tw = baseWidth(code) * scale;
        final th = _toothH * math.min(scale, 1.1);
        final t = tAt(cursor + tw / 2);
        cursor += tw + _gap * scale;

        final pos = at(t);
        final ang = math.pi * (1 - t);
        // 타원의 바깥 방향(법선). 뿌리가 이쪽을 향한다.
        var nx = math.cos(ang) / a;
        var ny = (upper ? -1 : 1) * math.sin(ang) / b;
        final nl = math.sqrt(nx * nx + ny * ny);
        nx /= nl;
        ny /= nl;

        children.add(Positioned(
          left: pos.dx - tw / 2,
          top: pos.dy - th / 2,
          child: Transform.rotate(
            angle: math.atan2(-nx, ny),
            child: _Tooth(
              code: code,
              status: records[code]?.status ?? ToothStatus.healthy,
              childId: childId,
              size: Size(tw, th),
            ),
          ),
        ));
      }

      final hint = Theme.of(context).hintColor;
      return SizedBox(
        height: height,
        width: c.maxWidth,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // 아치 안쪽 안내: 어느 턱인지 + 좌우.
            Positioned(
              left: 0,
              right: 0,
              top: upper ? height - 46 : 12,
              child: Column(
                children: [
                  Text(upper ? '위턱' : '아래턱',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: hint)),
                  const SizedBox(height: 2),
                  Text('◀ 오른쪽 · 왼쪽 ▶',
                      style: TextStyle(fontSize: 10, color: hint)),
                ],
              ),
            ),
            ...children,
          ],
        ),
      );
    });
  }
}

class _Tooth extends ConsumerWidget {
  const _Tooth({
    required this.code,
    required this.status,
    required this.childId,
    required this.size,
  });

  final int code;
  final ToothStatus status;
  final int childId;
  final Size size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final style = toothStatusStyle(status);
    final isHealthy = status == ToothStatus.healthy;

    return Semantics(
      button: true,
      label: '${ToothLayout.label(code)}, ${style.label}',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _openSheet(context, ref),
        child: CustomPaint(
          size: size,
          painter: ToothPainter(
            kind: ToothLayout.kind(code),
            fill: style.color,
            border: isHealthy ? const Color(0xFFB0BEC5) : style.color,
          ),
        ),
      ),
    );
  }

  Future<void> _openSheet(BuildContext context, WidgetRef ref) async {
    final isPrimary = code ~/ 10 >= 5;
    final eruptionKind =
        isPrimary ? ToothEventKind.lost : ToothEventKind.erupted;
    final picked = await showModalBottomSheet<Object>(
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
            const Divider(height: 1),
            ListTile(
              leading: Text(isPrimary ? '🦷' : '✨',
                  style: const TextStyle(fontSize: 20)),
              title: Text(isPrimary ? '빠진 날 기록 (이갈이)' : '난 날 기록'),
              subtitle: Text(isPrimary
                  ? '빠진 날짜를 남기면 상태가 \'빠짐\'으로 바뀌어요.'
                  : '영구치가 올라온 날짜를 남겨요.'),
              onTap: () => Navigator.pop(context, eruptionKind),
            ),
          ],
        ),
      ),
    );
    if (picked is ToothStatus) {
      await ref.read(toothRepositoryProvider).setStatus(
            childId: childId,
            toothCode: code,
            status: picked,
          );
    } else if (picked is ToothEventKind && context.mounted) {
      final date = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime.now(),
        helpText: picked == ToothEventKind.lost ? '빠진 날' : '난 날',
      );
      if (date != null) {
        await ref.read(toothRepositoryProvider).addEruptionEvent(
              childId: childId,
              toothCode: code,
              kind: picked,
              date: date,
            );
      }
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
                  border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant),
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

/// 이갈이 기록: 유치가 빠진 날·영구치가 난 날 목록.
class _EruptionLog extends ConsumerWidget {
  const _EruptionLog({required this.childId});

  final int childId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = (ref.watch(toothEventsProvider(childId)).valueOrNull ??
            const <ToothEvent>[])
        .where((e) => e.kind != ToothEventKind.statusChange)
        .toList()
        .reversed
        .toList();
    final lost = events.where((e) => e.kind == ToothEventKind.lost).length;
    final erupted = events.length - lost;
    final hint = Theme.of(context).hintColor;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('이갈이 기록',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text('유치 빠짐 $lost · 영구치 남 $erupted',
                      style: TextStyle(fontSize: 12, color: hint)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            if (events.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text('치아를 누르고 \'빠진 날 기록\'이나 \'난 날 기록\'을 선택해 보세요.',
                    style: TextStyle(fontSize: 12, color: hint)),
              )
            else
              for (final e in events)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Text(e.kind == ToothEventKind.lost ? '🦷' : '✨',
                      style: const TextStyle(fontSize: 18)),
                  title: Text(
                      '${ToothLayout.label(e.toothCode)} ${e.kind.label}'),
                  subtitle: Text(
                      '${e.date.year}.${e.date.month}.${e.date.day}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    tooltip: '기록 삭제',
                    onPressed: () =>
                        ref.read(toothRepositoryProvider).deleteEvent(e.id),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
