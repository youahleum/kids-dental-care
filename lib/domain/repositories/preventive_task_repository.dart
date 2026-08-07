import '../models/preventive_task.dart';
import '../services/schedule_engine.dart';

/// 예방치료/검진 항목 저장소 인터페이스.
abstract interface class PreventiveTaskRepository {
  /// 특정 자녀의 항목을 권장일 순으로 실시간 조회.
  Stream<List<PreventiveTask>> watchByChild(int childId);

  /// 계산된 일정을 자녀 항목으로 일괄 저장 (등록 시 1회).
  Future<void> createForChild(int childId, List<GeneratedTask> tasks);

  /// 완료/미완료 토글 (완료일 기록/삭제).
  Future<void> setDone(int taskId, {required bool done});
}
