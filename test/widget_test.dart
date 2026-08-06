import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kids_dental_care/app.dart';

void main() {
  testWidgets('앱이 4탭 셸과 함께 뜬다', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: KidsDentalApp()),
    );
    await tester.pumpAndSettle();

    // 하단 4탭이 존재
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('홈'), findsOneWidget);
    expect(find.text('타임라인'), findsOneWidget);
    expect(find.text('검진기록'), findsOneWidget);
    expect(find.text('치아차트'), findsOneWidget);
  });
}
