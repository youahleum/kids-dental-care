/// 나이/월령 계산 유틸. 기준 문서: PLAN.md 7장 (ScheduleEngine)
abstract final class AgeUtils {
  /// 생년월일 기준 만 나이(년).
  static int years(DateTime birthDate, {DateTime? now}) {
    final ref = now ?? DateTime.now();
    var age = ref.year - birthDate.year;
    final hadBirthday = (ref.month > birthDate.month) ||
        (ref.month == birthDate.month && ref.day >= birthDate.day);
    if (!hadBirthday) age -= 1;
    return age;
  }

  /// 생년월일 기준 총 개월 수(월령).
  static int totalMonths(DateTime birthDate, {DateTime? now}) {
    final ref = now ?? DateTime.now();
    var months = (ref.year - birthDate.year) * 12 + (ref.month - birthDate.month);
    if (ref.day < birthDate.day) months -= 1;
    return months < 0 ? 0 : months;
  }

  /// "만 O세 O개월" 형태의 라벨.
  static String label(DateTime birthDate, {DateTime? now}) {
    final m = totalMonths(birthDate, now: now);
    final y = m ~/ 12;
    final rem = m % 12;
    if (y == 0) return '만 $rem개월';
    if (rem == 0) return '만 $y세';
    return '만 $y세 $rem개월';
  }

  /// 개월 수 오프셋을 더한 날짜(권장 시기 계산용).
  static DateTime addMonths(DateTime date, int months) {
    final totalMonth = date.month - 1 + months;
    final year = date.year + (totalMonth ~/ 12);
    final month = totalMonth % 12 + 1;
    final day = date.day;
    // 말일 보정
    final lastDay = DateTime(year, month + 1, 0).day;
    return DateTime(year, month, day > lastDay ? lastDay : day);
  }
}
