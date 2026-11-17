import '../models/tooth_record.dart';

/// 한 달의 치아 상태 집계 (그달 말 기준).
class TrendPoint {
  const TrendPoint(
      {required this.month, required this.caries, required this.treated});

  /// 그달 1일.
  final DateTime month;
  final int caries;

  /// 치료·실란트로 처치된 치아 수.
  final int treated;
}

/// 치아 이력에서 월별 충치/처치 개수를 계산한다. 순수 계산 — UI/DB 비의존.
abstract final class ToothTrend {
  static List<TrendPoint> monthly(
    List<ToothEvent> events, {
    int months = 12,
    DateTime? now,
  }) {
    final ref = now ?? DateTime.now();
    final changes = events
        .where((e) => e.kind == ToothEventKind.statusChange && e.status != null)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    final current = <int, ToothStatus>{};
    var i = 0;
    final points = <TrendPoint>[];
    for (var m = months - 1; m >= 0; m--) {
      final month = DateTime(ref.year, ref.month - m);
      final end = DateTime(month.year, month.month + 1);
      while (i < changes.length && changes[i].date.isBefore(end)) {
        current[changes[i].toothCode] = changes[i].status!;
        i++;
      }
      points.add(TrendPoint(
        month: month,
        caries: current.values.where((s) => s == ToothStatus.caries).length,
        treated: current.values
            .where((s) => s == ToothStatus.treated || s == ToothStatus.sealant)
            .length,
      ));
    }
    return points;
  }
}
