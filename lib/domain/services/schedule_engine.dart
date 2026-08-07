import '../../core/utils/age_utils.dart';
import '../../data/seed/schedule_seed.dart';
import '../models/preventive_task.dart';

/// 자녀 생년월일 기준으로 표준 예방치료/검진 일정을 계산한다.
/// 순수 로직 — DB/Flutter 비의존. 기준 문서: PLAN.md 7장
abstract final class ScheduleEngine {
  /// 시드 일정을 생일 기준 권장일로 변환한 항목 목록.
  /// 저장 전 단계이므로 id/childId/status는 호출측에서 채운다.
  static List<GeneratedTask> generate(DateTime birthDate) {
    return [
      for (final seed in scheduleSeed)
        GeneratedTask(
          type: seed.type,
          title: seed.title,
          recommendedDate: AgeUtils.addMonths(birthDate, seed.offsetMonths),
        ),
    ]..sort((a, b) => a.recommendedDate.compareTo(b.recommendedDate));
  }
}

/// 저장 전 계산 결과 (id 없음).
class GeneratedTask {
  const GeneratedTask({
    required this.type,
    required this.title,
    required this.recommendedDate,
  });

  final PreventiveType type;
  final String title;
  final DateTime recommendedDate;
}
