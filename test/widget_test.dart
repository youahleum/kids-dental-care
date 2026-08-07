import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kids_dental_care/app.dart';
import 'package:kids_dental_care/data/providers.dart';
import 'package:kids_dental_care/domain/models/child.dart';

/// childrenProvider를 직접 오버라이드하면 Drift/DB 계층을 태우지 않으므로
/// 위젯 렌더만 순수하게 검증할 수 있다. (영속성은 child_repository_test 에서 검증)
Widget _app(List<Child> children) {
  return ProviderScope(
    overrides: [
      childrenProvider.overrideWith((ref) => Stream.value(children)),
    ],
    child: const KidsDentalApp(),
  );
}

void main() {
  testWidgets('자녀가 없으면 빈 상태 + 4탭', (WidgetTester tester) async {
    await tester.pumpWidget(_app(const []));
    await tester.pump();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('타임라인'), findsOneWidget);
    expect(find.text('검진기록'), findsOneWidget);
    expect(find.text('치아차트'), findsOneWidget);
    expect(find.text('첫 아이를 등록해 주세요'), findsOneWidget);
  });

  testWidgets('자녀가 있으면 카드가 표시된다', (WidgetTester tester) async {
    final child = Child(
      id: 1,
      name: '김지호',
      birthDate: DateTime(2024, 4, 12),
      colorValue: 0xFF4DB6C4,
      createdAt: DateTime(2024, 4, 12),
    );
    await tester.pumpWidget(_app([child]));
    await tester.pump();

    expect(find.text('김지호'), findsOneWidget);
    expect(find.text('첫 아이를 등록해 주세요'), findsNothing);
  });
}
