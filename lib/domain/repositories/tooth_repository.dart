import '../models/tooth_record.dart';

/// 치아 상태 저장소 인터페이스.
abstract interface class ToothRepository {
  /// 특정 자녀의 치아 상태를 toothCode→기록 맵으로 실시간 조회.
  /// 기록이 없는 치아는 맵에 없음(= 건강 기본).
  Stream<Map<int, ToothRecord>> watchByChild(int childId);

  /// 치아 상태 설정 (upsert). status가 healthy면 기록 삭제(기본값 복귀).
  Future<void> setStatus({
    required int childId,
    required int toothCode,
    required ToothStatus status,
    String? note,
  });
}
