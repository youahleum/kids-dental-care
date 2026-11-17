import 'package:flutter_test/flutter_test.dart';
import 'package:kids_dental_care/domain/models/tooth_layout.dart';

void main() {
  test('영구치 4·5번은 작은어금니, 6~8번은 어금니', () {
    for (final code in [14, 15, 24, 25, 34, 35, 44, 45]) {
      expect(ToothLayout.kind(code), ToothKind.premolar, reason: '$code');
    }
    for (final code in [16, 17, 18, 26, 36, 48]) {
      expect(ToothLayout.kind(code), ToothKind.molar, reason: '$code');
    }
  });

  test('유치 4·5번은 작은어금니가 아니라 어금니', () {
    for (final code in [54, 55, 64, 65, 74, 75, 84, 85]) {
      expect(ToothLayout.kind(code), ToothKind.molar, reason: '$code');
    }
  });

  test('앞니·송곳니 분류는 그대로', () {
    expect(ToothLayout.kind(11), ToothKind.incisor);
    expect(ToothLayout.kind(52), ToothKind.incisor);
    expect(ToothLayout.kind(23), ToothKind.canine);
    expect(ToothLayout.kind(83), ToothKind.canine);
  });
}
