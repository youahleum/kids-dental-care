import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/age_utils.dart';
import '../../data/providers.dart';
import '../../domain/models/child.dart';
import '../../domain/models/tooth_layout.dart';
import '../../domain/models/tooth_record.dart';
import '../../domain/services/dentition.dart';
import '../../shared/child_switcher.dart';
import '../../shared/status_views.dart';
import '../children/selected_child.dart';
import '../home/tab_index.dart';
import 'caries_trend_chart.dart';
import 'tooth_painter.dart';
import 'tooth_status_style.dart';
import '../../shared/gradient_app_bar.dart';

/// 치아 차트에서 무엇을 볼지.
enum _View {
  current('지금 입안'),
  primary('유치 전체'),
  permanent('영구치 전체');

  const _View(this.label);

  final String label;
}

/// 치아별 상태 기록. 기준: DESIGN.md 6-5
class ToothChartScreen extends ConsumerStatefulWidget {
  const ToothChartScreen({super.key});

  @override
  ConsumerState<ToothChartScreen> createState() => _ToothChartScreenState();
}

class _ToothChartScreenState extends ConsumerState<ToothChartScreen> {
  /// 사용자가 고른 보기 (구성원 id별).
  final Map<int, _View> _viewByMember = {};

  /// 만 13세부터는 유치가 남아 있지 않으므로 영구치만 보여준다(보기 전환 숨김).
  static bool _mixedAge(DateTime birthDate) => AgeUtils.years(birthDate) < 13;

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
              final mixed = _mixedAge(child.birthDate);
              final view = mixed
                  ? (_viewByMember[child.id] ?? _View.current)
                  : _View.permanent;
              return Column(
                children: [
                  const ChildSwitcher(),
                  if (mixed)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      child: SegmentedButton<_View>(
                        showSelectedIcon: false,
                        segments: [
                          for (final v in _View.values)
                            ButtonSegment(value: v, label: Text(v.label)),
                        ],
                        selected: {view},
                        onSelectionChanged: (s) => setState(
                            () => _viewByMember[child.id] = s.first),
                      ),
                    ),
                  Expanded(child: _Chart(member: child, view: view)),
                ],
              );
            }),
    );
  }
}

/// 아치에 그릴 치아 하나.
class _ArchTooth {
  const _ArchTooth({required this.code, required this.state, this.slot});

  /// 그릴 치아 코드 (빈자리는 앞으로 날 영구치).
  final int code;
  final SlotState state;

  /// '지금 입안' 보기일 때만 있다 (자리 정보).
  final ToothSlot? slot;
}

class _Chart extends ConsumerWidget {
  const _Chart({required this.member, required this.view});

  final Child member;
  final _View view;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(toothChartProvider(member.id));
    final events =
        ref.watch(toothEventsProvider(member.id)).valueOrNull ?? const [];

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => ErrorView(error: e),
      data: (records) {
        List<_ArchTooth> teeth(bool upper) => switch (view) {
              _View.current => [
                  for (final slot in Dentition.current(
                    upper
                        ? ToothLayout.permanentUpper
                        : ToothLayout.permanentLower,
                    birthDate: member.birthDate,
                    events: events,
                    records: records,
                  ))
                    _ArchTooth(
                        code: slot.shownCode, state: slot.state, slot: slot),
                ],
              _View.primary => [
                  for (final code in upper
                      ? ToothLayout.primaryUpper
                      : ToothLayout.primaryLower)
                    _ArchTooth(code: code, state: SlotState.primary),
                ],
              _View.permanent => [
                  for (final code in upper
                      ? ToothLayout.permanentUpper
                      : ToothLayout.permanentLower)
                    _ArchTooth(code: code, state: SlotState.permanent),
                ],
            };
        final mixed = view == _View.current;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _JawCard(
              upper: true,
              teeth: teeth(true),
              records: records,
              childId: member.id,
              mixed: mixed,
            ),
            const SizedBox(height: 12),
            _JawCard(
              upper: false,
              teeth: teeth(false),
              records: records,
              childId: member.id,
              mixed: mixed,
            ),
            const SizedBox(height: 14),
            _Legend(mixed: mixed),
            const SizedBox(height: 16),
            CariesTrendCard(childId: member.id),
            const SizedBox(height: 16),
            _EruptionLog(childId: member.id),
          ],
        );
      },
    );
  }
}

/// 위턱 또는 아래턱 카드: 색 띠 제목 + 아치.
class _JawCard extends StatelessWidget {
  const _JawCard({
    required this.upper,
    required this.teeth,
    required this.records,
    required this.childId,
    required this.mixed,
  });

  final bool upper;
  final List<_ArchTooth> teeth;
  final Map<int, ToothRecord> records;
  final int childId;
  final bool mixed;

  @override
  Widget build(BuildContext context) {
    final tint = upper ? AppColors.mint : AppColors.statusUpcoming;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: tint.withValues(alpha: 0.16),
            child: Text(
              upper ? '▲ 위턱 (윗니)' : '▼ 아래턱 (아랫니)',
              textAlign: TextAlign.center,
              style:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: _Arch(
              teeth: teeth,
              records: records,
              childId: childId,
              upper: upper,
              mixed: mixed,
            ),
          ),
        ],
      ),
    );
  }
}

/// 치아를 실제 턱처럼 U자(아치)로 배치한다. 위턱은 ∩, 아래턱은 ∪ 모양이고
/// 뿌리가 바깥, 씹는 면이 안쪽을 향하도록 치아를 돌려 놓는다.
/// 폭에 맞춰 크기를 정하므로 영구치 16개도 옆으로 밀지 않고 한눈에 보인다.
class _Arch extends StatelessWidget {
  const _Arch({
    required this.teeth,
    required this.records,
    required this.childId,
    required this.mixed,
    this.upper = false,
  });

  final List<_ArchTooth> teeth;
  final Map<int, ToothRecord> records;
  final int childId;
  final bool upper;

  /// '지금 입안' 보기: 유치를 작게 그리고 '유' 표시를 붙인다.
  final bool mixed;

  static const _toothH = 34.0;
  static const _gap = 2.0;

  /// '유' 표시가 들어갈 바깥 여백.
  static const _badgeSpace = 15.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final w = math.min(c.maxWidth, 360.0);
      final outer = mixed ? _badgeSpace : 0.0;
      // 치아 중심이 지나는 반타원. 치아 높이의 절반(+표시 여백)만큼 안쪽으로 들인다.
      final a = w / 2 - _toothH / 2 - 2 - outer;
      final b = a * 0.8;
      final height = b + _toothH / 2 + 4 + outer;
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

      bool small(_ArchTooth t) => mixed && t.state == SlotState.primary;

      // 종류별 폭: 어금니 > 작은어금니 > 앞니·송곳니. 섞여 있을 때 유치는 조금 작게.
      double baseWidth(_ArchTooth t) =>
          switch (ToothLayout.kind(t.code)) {
            ToothKind.molar => 28.0,
            ToothKind.premolar => 23.0,
            _ => 20.0,
          } *
          (small(t) ? 0.84 : 1);
      final needed = teeth.fold<double>(0, (sum, t) => sum + baseWidth(t)) +
          _gap * (teeth.length - 1);
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
      for (final tooth in teeth) {
        final tw = baseWidth(tooth) * scale;
        final th = _toothH * math.min(scale, 1.1) * (small(tooth) ? 0.86 : 1);
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
              tooth: tooth,
              status: records[tooth.code]?.status ?? ToothStatus.healthy,
              childId: childId,
              size: Size(tw, th),
            ),
          ),
        ));

        if (small(tooth)) {
          // 뿌리 바깥쪽에 '유' 표시.
          const r = 6.5;
          final bc = pos + Offset(nx, ny) * (th / 2 + r + 1.5);
          children.add(Positioned(
            left: bc.dx - r,
            top: bc.dy - r,
            child: IgnorePointer(
              child: Container(
                width: r * 2,
                height: r * 2,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                    color: AppColors.statusUpcoming, shape: BoxShape.circle),
                child: const Text('유',
                    style: TextStyle(
                        fontSize: 8.5,
                        height: 1,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
            ),
          ));
        }
      }

      return SizedBox(
        height: height,
        width: c.maxWidth,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // 아치 안쪽 안내: 화면 기준 좌우.
            Positioned(
              left: 0,
              right: 0,
              top: upper ? height - 22 : 6,
              child: Text('◀ 오른쪽 · 왼쪽 ▶',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 10, color: Theme.of(context).hintColor)),
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
    required this.tooth,
    required this.status,
    required this.childId,
    required this.size,
  });

  final _ArchTooth tooth;
  final ToothStatus status;
  final int childId;
  final Size size;

  int get code => tooth.code;
  bool get _empty => tooth.state == SlotState.empty;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final style = toothStatusStyle(status);
    final isHealthy = status == ToothStatus.healthy;

    return Semantics(
      button: true,
      label: _empty
          ? '${ToothLayout.label(code)} 자리, 빈자리'
          : '${ToothLayout.label(code)}, ${style.label}',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _openSheet(context, ref),
        child: CustomPaint(
          size: size,
          painter: ToothPainter(
            kind: ToothLayout.kind(code),
            fill: style.color,
            border: isHealthy || _empty ? const Color(0xFFB0BEC5) : style.color,
            dashed: _empty,
          ),
        ),
      ),
    );
  }

  Future<void> _openSheet(BuildContext context, WidgetRef ref) async {
    final slot = tooth.slot;
    final isPrimary = code ~/ 10 >= 5;

    // 이갈이 메뉴: (아이콘, 제목, 설명, 선택값)
    final actions = <(String, String, String, _SlotAction)>[
      if (slot == null) ...[
        // 전체 보기: 그 치아 자체에 대한 기록만.
        if (isPrimary)
          ('🦷', '빠진 날 기록 (이갈이)', '빠진 날짜를 남기면 상태가 \'빠짐\'으로 바뀌어요.', _SlotAction.lost)
        else
          ('✨', '난 날 기록', '영구치가 올라온 날짜를 남겨요.', _SlotAction.erupted),
      ] else if (tooth.state == SlotState.primary) ...[
        ('🦷', '유치가 빠졌어요', '빠진 날짜를 남기면 이 자리가 빈자리로 바뀌어요.', _SlotAction.lost),
        ('✨', '영구치로 바뀌었어요', '영구치가 난 날짜를 남겨요.', _SlotAction.erupted),
      ] else if (tooth.state == SlotState.empty) ...[
        ('✨', '영구치가 났어요', '난 날짜를 남기면 영구치로 바뀌어요.', _SlotAction.erupted),
        if (slot.primaryCode != null)
          ('↩️', '아직 유치가 있어요', '이 자리를 유치로 되돌려요.', _SlotAction.back),
      ] else ...[
        if (slot.primaryCode != null)
          ('↩️', '아직 유치예요', '이 자리를 유치로 되돌려요.', _SlotAction.back)
        else
          ('↩️', '아직 안 났어요', '이 자리를 빈자리로 되돌려요.', _SlotAction.back),
      ],
    ];

    final picked = await showModalBottomSheet<Object>(
      context: context,
      isScrollControlled: true,
      builder: (_) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: Text(
                  _empty
                      ? '${ToothLayout.label(code)} 자리 · 빈자리'
                      : ToothLayout.label(code),
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
              if (!_empty)
                for (final s in ToothStatus.values)
                  ListTile(
                    dense: true,
                    leading: _swatch(s),
                    title: Text(toothStatusStyle(s).label),
                    selected: s == status,
                    onTap: () => Navigator.pop(context, s),
                  ),
              if (!_empty) const Divider(height: 1),
              for (final (icon, title, sub, action) in actions)
                ListTile(
                  leading: Text(icon, style: const TextStyle(fontSize: 20)),
                  title: Text(title),
                  subtitle: Text(sub),
                  onTap: () => Navigator.pop(context, action),
                ),
            ],
          ),
        ),
      ),
    );

    final repo = ref.read(toothRepositoryProvider);
    if (picked is ToothStatus) {
      await repo.setStatus(childId: childId, toothCode: code, status: picked);
      return;
    }
    if (picked is! _SlotAction || !context.mounted) return;

    if (picked == _SlotAction.back) {
      // 되돌림은 날짜가 필요 없다. 유치가 '빠짐'으로 남아 있으면 건강으로 되돌린다.
      await repo.addEruptionEvent(
        childId: childId,
        toothCode: slot!.permanentCode,
        kind: ToothEventKind.markedBack,
        date: DateTime.now(),
      );
      final primaryCode = slot.primaryCode;
      if (primaryCode != null) {
        await repo.setStatus(
            childId: childId,
            toothCode: primaryCode,
            status: ToothStatus.healthy);
      }
      return;
    }

    final lost = picked == _SlotAction.lost;
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      helpText: lost ? '빠진 날' : '난 날',
    );
    if (date == null) return;
    await repo.addEruptionEvent(
      childId: childId,
      // 빠짐은 유치 코드에, 남은 영구치 코드에 기록한다.
      toothCode: lost
          ? (slot?.primaryCode ?? code)
          : (slot?.permanentCode ?? code),
      kind: lost ? ToothEventKind.lost : ToothEventKind.erupted,
      date: date,
    );
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

/// 치아 시트에서 고른 이갈이 동작.
enum _SlotAction { lost, erupted, back }

class _Legend extends StatelessWidget {
  const _Legend({required this.mixed});

  /// '지금 입안' 보기면 유치·빈자리 표시도 설명한다.
  final bool mixed;

  @override
  Widget build(BuildContext context) {
    final outline = Theme.of(context).colorScheme.outlineVariant;
    Widget item(Widget mark, String label) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            mark,
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        );
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        for (final s in ToothStatus.values)
          item(
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: toothStatusStyle(s).color,
                shape: BoxShape.circle,
                border: Border.all(color: outline),
              ),
            ),
            toothStatusStyle(s).label,
          ),
        if (mixed) ...[
          item(
            Container(
              width: 14,
              height: 14,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                  color: AppColors.statusUpcoming, shape: BoxShape.circle),
              child: const Text('유',
                  style: TextStyle(
                      fontSize: 9,
                      height: 1,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ),
            '유치',
          ),
          item(
            CustomPaint(
              size: const Size(12, 16),
              painter: ToothPainter(
                kind: ToothKind.incisor,
                fill: Colors.white,
                border: const Color(0xFF90A4AE),
                dashed: true,
              ),
            ),
            '빈자리 (빠졌거나 나는 중)',
          ),
        ],
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
        .where((e) =>
            e.kind == ToothEventKind.lost || e.kind == ToothEventKind.erupted)
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
                child: Text('치아를 누르고 \'유치가 빠졌어요\'나 \'영구치가 났어요\'를 선택해 보세요.',
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
