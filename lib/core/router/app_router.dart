import 'package:go_router/go_router.dart';

import '../../features/home/home_shell.dart';

/// 앱 라우터. 기준: PLAN.md 5장 (아키텍처)
/// 향후 자녀 등록/편집 등 라우트를 여기에 추가한다.
final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeShell(),
    ),
  ],
);
