import 'package:flutter/material.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

/// 앱 루트 위젯. 테마와 라우터를 연결한다.
class KidsDentalApp extends StatelessWidget {
  const KidsDentalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '키즈 덴탈 케어',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: appRouter,
    );
  }
}
