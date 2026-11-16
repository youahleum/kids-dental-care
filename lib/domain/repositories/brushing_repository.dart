import '../models/brushing.dart';

/// 양치 기록 저장소 인터페이스.
abstract interface class BrushingRepository {
  /// 자녀의 양치 기록: 날짜(0시) → 양치한 시간대 집합.
  Stream<Map<DateTime, Set<BrushingSlot>>> watchByChild(int childId);

  /// 해당 날짜·시간대의 양치 여부를 설정한다.
  Future<void> setBrushed({
    required int childId,
    required DateTime date,
    required BrushingSlot slot,
    required bool brushed,
  });
}
