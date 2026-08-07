import 'package:flutter_test/flutter_test.dart';
import 'package:kids_dental_care/domain/models/checkup_record.dart';
import 'package:kids_dental_care/domain/services/checkup_scheduler.dart';

CheckupRecord _rec(DateTime date) =>
    CheckupRecord(id: 0, childId: 1, date: date);

void main() {
  group('CheckupScheduler.nextDate', () {
    test('이력이 없으면 null', () {
      expect(CheckupScheduler.nextDate(const []), isNull);
    });

    test('가장 최근 검진 + 6개월', () {
      final next = CheckupScheduler.nextDate([_rec(DateTime(2026, 5, 5))]);
      expect(next, DateTime(2026, 11, 5));
    });

    test('여러 이력 중 최신 기준으로 계산 (순서 무관)', () {
      final next = CheckupScheduler.nextDate([
        _rec(DateTime(2025, 11, 10)),
        _rec(DateTime(2026, 5, 5)),
        _rec(DateTime(2025, 1, 1)),
      ]);
      expect(next, DateTime(2026, 11, 5));
    });

    test('주기를 바꾸면 반영된다', () {
      final next = CheckupScheduler.nextDate(
        [_rec(DateTime(2026, 1, 31))],
        intervalMonths: 3,
      );
      expect(next, DateTime(2026, 4, 30)); // 4/31 없음 → 4/30 말일 보정
    });
  });
}
