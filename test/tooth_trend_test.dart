import 'package:flutter_test/flutter_test.dart';
import 'package:kids_dental_care/domain/models/tooth_record.dart';
import 'package:kids_dental_care/domain/services/tooth_trend.dart';

ToothEvent _e(int code, ToothStatus s, DateTime d) => ToothEvent(
    id: 0,
    childId: 1,
    toothCode: code,
    kind: ToothEventKind.statusChange,
    status: s,
    date: d);

void main() {
  final now = DateTime(2026, 11, 17);

  test('월말 기준으로 누적 상태를 센다', () {
    final points = ToothTrend.monthly([
      _e(55, ToothStatus.caries, DateTime(2026, 6, 10)),
      _e(64, ToothStatus.caries, DateTime(2026, 8, 2)),
      _e(55, ToothStatus.treated, DateTime(2026, 9, 20)),
    ], now: now);

    expect(points, hasLength(12));
    expect(points.first.month, DateTime(2025, 12));
    expect(points.last.month, DateTime(2026, 11));

    int caries(int month) =>
        points.firstWhere((p) => p.month == DateTime(2026, month)).caries;
    int treated(int month) =>
        points.firstWhere((p) => p.month == DateTime(2026, month)).treated;
    expect(caries(5), 0);
    expect(caries(6), 1);
    expect(caries(8), 2);
    expect(caries(9), 1); // 55가 치료됨
    expect(treated(9), 1);
    expect(caries(11), 1);
  });

  test('기간 이전의 이력도 시작 상태에 반영된다', () {
    final points = ToothTrend.monthly(
        [_e(55, ToothStatus.sealant, DateTime(2024, 1, 1))],
        now: now);
    expect(points.first.treated, 1);
  });

  test('건강으로 되돌리면 집계에서 빠지고, 이갈이 기록은 무시한다', () {
    final points = ToothTrend.monthly([
      _e(55, ToothStatus.caries, DateTime(2026, 10, 1)),
      _e(55, ToothStatus.healthy, DateTime(2026, 11, 1)),
      ToothEvent(
          id: 1,
          childId: 1,
          toothCode: 81,
          kind: ToothEventKind.lost,
          date: DateTime(2026, 11, 2)),
    ], now: now);
    expect(points[points.length - 2].caries, 1);
    expect(points.last.caries, 0);
  });
}
