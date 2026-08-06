import 'package:flutter_test/flutter_test.dart';
import 'package:kids_dental_care/core/utils/age_utils.dart';

void main() {
  group('AgeUtils', () {
    final birth = DateTime(2024, 4, 12);

    test('years: 생일 지나면 만 나이 +1', () {
      expect(AgeUtils.years(birth, now: DateTime(2026, 4, 12)), 2);
      expect(AgeUtils.years(birth, now: DateTime(2026, 4, 11)), 1);
      expect(AgeUtils.years(birth, now: DateTime(2026, 8, 6)), 2);
    });

    test('totalMonths: 총 개월 계산', () {
      expect(AgeUtils.totalMonths(birth, now: DateTime(2024, 4, 12)), 0);
      expect(AgeUtils.totalMonths(birth, now: DateTime(2025, 4, 12)), 12);
      expect(AgeUtils.totalMonths(birth, now: DateTime(2026, 8, 6)), 27);
    });

    test('label: 사람이 읽는 나이 라벨', () {
      expect(AgeUtils.label(birth, now: DateTime(2024, 12, 12)), '만 8개월');
      expect(AgeUtils.label(birth, now: DateTime(2026, 4, 12)), '만 2세');
      expect(AgeUtils.label(birth, now: DateTime(2026, 8, 6)), '만 2세 3개월');
    });

    test('addMonths: 개월 오프셋 (말일 보정 포함)', () {
      expect(AgeUtils.addMonths(DateTime(2024, 4, 12), 18), DateTime(2025, 10, 12));
      // 1/31 + 1개월 => 2/28 보정
      expect(AgeUtils.addMonths(DateTime(2025, 1, 31), 1), DateTime(2025, 2, 28));
    });
  });
}
