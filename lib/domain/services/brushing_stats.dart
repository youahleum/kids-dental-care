import '../models/brushing.dart';

/// 양치 기록 요약. 순수 계산 — UI/DB 비의존.
class BrushingStats {
  const BrushingStats({
    required this.today,
    required this.streak,
    required this.stickers,
  });

  /// 오늘 양치한 시간대.
  final Set<BrushingSlot> today;

  /// 연속 '완벽한 날'(모든 시간대 양치) 수. 오늘이 아직 미완성이면 어제까지로 센다.
  final int streak;

  /// 지금까지 모은 칭찬 스티커 수 (= 완벽한 날 수).
  final int stickers;

  static bool isPerfect(Set<BrushingSlot>? slots) =>
      slots != null && slots.length == BrushingSlot.values.length;

  static BrushingStats compute(
    Map<DateTime, Set<BrushingSlot>> logs, {
    DateTime? now,
  }) {
    final today = dayOf(now ?? DateTime.now());

    var cursor = isPerfect(logs[today])
        ? today
        : today.subtract(const Duration(days: 1));
    var streak = 0;
    while (isPerfect(logs[cursor])) {
      streak++;
      cursor = DateTime(cursor.year, cursor.month, cursor.day - 1);
    }

    return BrushingStats(
      today: logs[today] ?? const {},
      streak: streak,
      stickers: logs.values.where(isPerfect).length,
    );
  }
}
