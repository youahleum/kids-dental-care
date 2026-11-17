import '../../core/utils/age_utils.dart';
import '../../data/seed/schedule_seed.dart';
import '../models/preventive_task.dart';

/// 구성원 생년월일 기준으로 표준 예방치료/검진 일정을 계산한다.
/// 순수 로직 — DB/Flutter 비의존. 기준 문서: PLAN.md 7장
abstract final class ScheduleEngine {
  /// 어른 기준 나이. 이 나이 이상이면 아이용 일정 대신 어른 일정을 만든다.
  /// (스케일링 건강보험 적용: 만 19세 이상)
  static const adultAge = 19;

  /// 국가건강검진(구강검진) 대상 나이: 만 20세 이상, 2년마다.
  static const nationalCheckupAge = 20;

  /// 어른 일정을 미리 만들어 두는 기간(올해 포함 N년).
  static const adultYears = 3;

  /// 생일 기준 권장일 목록. 저장 전 단계이므로 id/childId/status는 호출측에서 채운다.
  ///
  /// - 아이(만 19세 미만): 영유아 구강검진·불소·실란트 시드 일정
  /// - 어른 나이에 해당하는 해: 스케일링(매년), 국가건강검진 구강검진(출생연도와 짝/홀이 같은 해)
  static List<GeneratedTask> generate(DateTime birthDate, {DateTime? now}) {
    final ref = now ?? DateTime.now();
    final isAdult = AgeUtils.years(birthDate, now: ref) >= adultAge;
    return [
      if (!isAdult)
        for (final seed in scheduleSeed)
          GeneratedTask(
            type: seed.type,
            title: seed.title,
            recommendedDate: AgeUtils.addMonths(birthDate, seed.offsetMonths),
          ),
      ..._adultTasks(birthDate, ref),
    ]..sort((a, b) => a.recommendedDate.compareTo(b.recommendedDate));
  }

  static List<GeneratedTask> _adultTasks(DateTime birthDate, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final tasks = <GeneratedTask>[];
    for (var year = now.year; year < now.year + adultYears; year++) {
      final age = year - birthDate.year; // 그해 생일에 되는 만 나이
      // 그해 생일 무렵으로 안내. 올해 생일이 이미 지났으면 오늘로(지남 대신 '지금 할 일').
      var date = AgeUtils.addMonths(birthDate, age * 12);
      if (date.isBefore(today)) date = today;

      if (age >= adultAge) {
        tasks.add(GeneratedTask(
          type: PreventiveType.scaling,
          title: '스케일링 ($year년 · 건강보험 연 1회)',
          recommendedDate: date,
        ));
      }
      if (age >= nationalCheckupAge && year % 2 == birthDate.year % 2) {
        tasks.add(GeneratedTask(
          type: PreventiveType.checkup,
          title: '국가건강검진 구강검진 ($year년)',
          recommendedDate: date,
        ));
      }
    }
    return tasks;
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
