/// 양치 시간대. 소아치과 권고: 하루 2번 이상, 특히 자기 전.
enum BrushingSlot {
  morning('아침', '☀️'),
  night('자기 전', '🌙');

  const BrushingSlot(this.label, this.emoji);

  final String label;
  final String emoji;
}

/// 날짜를 그날 0시(로컬)로 정규화.
DateTime dayOf(DateTime d) => DateTime(d.year, d.month, d.day);
