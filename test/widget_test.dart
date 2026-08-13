import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kids_dental_care/app.dart';
import 'package:kids_dental_care/data/notifications/noop_notification_service.dart';
import 'package:kids_dental_care/data/providers.dart';
import 'package:kids_dental_care/domain/models/child.dart';
import 'package:kids_dental_care/domain/models/tooth_record.dart';

/// children/timeline provider를 직접 오버라이드하면 Drift/DB 계층을 태우지 않으므로
/// 위젯 렌더만 순수하게 검증할 수 있다. (영속성은 repository 테스트에서 검증)
Widget _app(List<Child> children) {
  return ProviderScope(
    overrides: [
      childrenProvider.overrideWith((ref) => Stream.value(children)),
      // IndexedStack이 타임라인/검진/치아 화면을 미리 빌드하므로 DB 접근을 차단한다.
      timelineProvider.overrideWith((ref, childId) => Stream.value(const [])),
      checkupsProvider.overrideWith((ref, childId) => Stream.value(const [])),
      toothChartProvider
          .overrideWith((ref, childId) => Stream.value(const <int, ToothRecord>{})),
      // 알림 재예약이 진짜 DB/플랫폼을 태우지 않도록 차단한다.
      notificationServiceProvider.overrideWithValue(NoopNotificationService()),
      notificationsEnabledProvider.overrideWith((ref) => false),
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
