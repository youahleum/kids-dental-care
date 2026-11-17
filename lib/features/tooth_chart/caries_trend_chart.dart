import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../../domain/services/tooth_trend.dart';

/// 차트 색. 색각이상 구분(ΔE)·대비를 검증한 값 — 밝기 모드마다 따로 정했다.
({Color caries, Color treated}) _seriesColors(Brightness b) =>
    b == Brightness.dark
        ? (caries: const Color(0xFFEF5350), treated: const Color(0xFF3F9AE6))
        : (caries: const Color(0xFFE53935), treated: const Color(0xFF1E88E5));

/// 최근 12개월 충치·치료 개수 추이 (선 그래프). 점을 누르면 그달 값을 보여준다.
class CariesTrendCard extends ConsumerStatefulWidget {
  const CariesTrendCard({super.key, required this.childId});

  final int childId;

  @override
  ConsumerState<CariesTrendCard> createState() => _CariesTrendCardState();
}

class _CariesTrendCardState extends ConsumerState<CariesTrendCard> {
  int? _selected;

  @override
  Widget build(BuildContext context) {
    final events =
        ref.watch(toothEventsProvider(widget.childId)).valueOrNull ?? const [];
    final points = ToothTrend.monthly(events);
    final theme = Theme.of(context);
    final colors = _seriesColors(theme.brightness);
    final hint = theme.hintColor;
    final hasData = points.any((p) => p.caries > 0 || p.treated > 0);
    final sel = _selected == null ? points.last : points[_selected!];
    final yearAgo = points.first.caries;
    final diff = points.last.caries - yearAgo;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('충치 추이 (최근 12개월)',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(
              !hasData
                  ? '치아 상태를 기록하면 달마다 충치·치료 개수가 그래프로 쌓여요.'
                  : diff == 0
                      ? '지금 충치 ${points.last.caries}개 · 1년 전과 같아요'
                      : '지금 충치 ${points.last.caries}개 · 1년 전보다 '
                          '${diff.abs()}개 ${diff > 0 ? '늘었어요' : '줄었어요'}',
              style: TextStyle(fontSize: 12, color: hint),
            ),
            if (hasData) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  _LegendDot(color: colors.caries, label: '충치'),
                  const SizedBox(width: 14),
                  _LegendDot(color: colors.treated, label: '치료·실란트'),
                  const Spacer(),
                  Text(
                    '${sel.month.year}.${sel.month.month} · '
                    '충치 ${sel.caries} · 치료 ${sel.treated}',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LayoutBuilder(builder: (context, c) {
                void pick(Offset p) {
                  final step = (c.maxWidth -
                          _TrendPainter.leftPad -
                          _TrendPainter.rightPad) /
                      (points.length - 1);
                  final i = ((p.dx - _TrendPainter.leftPad) / step)
                      .round()
                      .clamp(0, points.length - 1);
                  setState(() => _selected = i);
                }

                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (d) => pick(d.localPosition),
                  onHorizontalDragUpdate: (d) => pick(d.localPosition),
                  child: CustomPaint(
                    size: Size(c.maxWidth, 150),
                    painter: _TrendPainter(
                      points: points,
                      selected: _selected,
                      caries: colors.caries,
                      treated: colors.treated,
                      surface: theme.cardTheme.color ?? theme.colorScheme.surface,
                      grid: theme.dividerColor.withValues(alpha: 0.5),
                      labelStyle: (theme.textTheme.bodySmall ?? const TextStyle())
                          .copyWith(fontSize: 10, color: hint),
                    ),
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 5),
      Text(label, style: const TextStyle(fontSize: 12)),
    ]);
  }
}

class _TrendPainter extends CustomPainter {
  _TrendPainter({
    required this.points,
    required this.selected,
    required this.caries,
    required this.treated,
    required this.surface,
    required this.grid,
    required this.labelStyle,
  });

  static const leftPad = 22.0;
  static const rightPad = 12.0;
  static const bottomPad = 20.0;
  static const topPad = 8.0;

  final List<TrendPoint> points;
  final int? selected;
  final Color caries;
  final Color treated;
  final Color surface;
  final Color grid;
  final TextStyle labelStyle;

  @override
  void paint(Canvas canvas, Size size) {
    final maxV = math.max(
        2, points.map((p) => math.max(p.caries, p.treated)).reduce(math.max));
    final plotH = size.height - bottomPad - topPad;
    final step = (size.width - leftPad - rightPad) / (points.length - 1);
    double x(int i) => leftPad + i * step;
    double y(int v) => topPad + plotH - v / maxV * plotH;

    // 가로 눈금선(정수) — 연하게.
    final gridPaint = Paint()
      ..color = grid
      ..strokeWidth = 1;
    final tickStep = math.max(1, (maxV / 4).ceil());
    for (var v = 0; v <= maxV; v += tickStep) {
      canvas.drawLine(
          Offset(leftPad, y(v)), Offset(size.width - rightPad, y(v)), gridPaint);
      _text(canvas, '$v', Offset(0, y(v) - 7), 10, width: leftPad - 6,
          align: TextAlign.right);
    }

    // 월 라벨: 2달 간격 + 마지막 달.
    for (var i = 0; i < points.length; i++) {
      if ((points.length - 1 - i).isOdd) continue;
      _text(canvas, '${points[i].month.month}월',
          Offset(x(i) - 14, size.height - bottomPad + 5), 10,
          width: 28, align: TextAlign.center);
    }

    // 선택한 달 세로선.
    if (selected != null) {
      canvas.drawLine(Offset(x(selected!), topPad),
          Offset(x(selected!), topPad + plotH), gridPaint..strokeWidth = 1.5);
    }

    void series(Color color, int Function(TrendPoint) v) {
      final path = Path()..moveTo(x(0), y(v(points[0])));
      for (var i = 1; i < points.length; i++) {
        path.lineTo(x(i), y(v(points[i])));
      }
      canvas.drawPath(
          path,
          Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..strokeJoin = StrokeJoin.round);
      // 마지막 달(또는 선택한 달)에만 점: 표면색 테두리 + 색 점.
      final i = selected ?? points.length - 1;
      final c = Offset(x(i), y(v(points[i])));
      canvas.drawCircle(c, 5.5, Paint()..color = surface);
      canvas.drawCircle(c, 4, Paint()..color = color);
    }

    series(treated, (p) => p.treated);
    series(caries, (p) => p.caries);
  }

  void _text(Canvas canvas, String s, Offset at, double size,
      {required double width, TextAlign align = TextAlign.left}) {
    final tp = TextPainter(
      text: TextSpan(text: s, style: labelStyle.copyWith(fontSize: size)),
      textAlign: align,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: width, maxWidth: width);
    tp.paint(canvas, at);
  }

  @override
  bool shouldRepaint(_TrendPainter old) =>
      old.points != points ||
      old.selected != selected ||
      old.caries != caries ||
      old.surface != surface;
}
