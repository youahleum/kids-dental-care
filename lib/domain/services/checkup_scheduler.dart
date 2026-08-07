import '../../core/utils/age_utils.dart';
import '../models/checkup_record.dart';

/// 검진 예정일 계산. 순수 로직. 기준 문서: PLAN.md 7장
abstract final class CheckupScheduler {
  /// 기본 검진 주기(개월). 설정에서 변경 가능(향후).
  static const defaultIntervalMonths = 6;

  /// 이력 목록에서 다음 검진 예정일을 계산.
  /// 가장 최근 검진일 + 주기. 이력이 없으면 null.
  static DateTime? nextDate(
    List<CheckupRecord> records, {
    int intervalMonths = defaultIntervalMonths,
  }) {
    if (records.isEmpty) return null;
    final latest = records
        .map((r) => r.date)
        .reduce((a, b) => a.isAfter(b) ? a : b);
    return AgeUtils.addMonths(latest, intervalMonths);
  }
}
