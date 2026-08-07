import '../models/checkup_record.dart';

/// 검진 이력 저장소 인터페이스.
abstract interface class CheckupRepository {
  /// 특정 자녀의 검진 이력을 최신순으로 실시간 조회.
  Stream<List<CheckupRecord>> watchByChild(int childId);

  Future<int> add({
    required int childId,
    required DateTime date,
    String? clinicName,
    String? memo,
  });

  Future<void> delete(int id);
}
