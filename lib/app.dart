import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'domain/models/app_settings.dart';
import 'features/settings/settings_controller.dart';

/// 앱 루트 위젯. 테마(밝게/어둡게)와 라우터를 연결한다.
class KidsDentalApp extends ConsumerWidget {
  const KidsDentalApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(settingsProvider.select((s) => s.themeMode));
    return MaterialApp.router(
      title: '우리 가족 덴탈 관리',
      debugShowCheckedModeBanner: false,
      // 날짜 선택 창 등 기본 제공 화면을 한국어로 보여준다.
      locale: const Locale('ko', 'KR'),
      supportedLocales: const [Locale('ko', 'KR')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: switch (mode) {
        AppThemeMode.system => ThemeMode.system,
        AppThemeMode.light => ThemeMode.light,
        AppThemeMode.dark => ThemeMode.dark,
      },
      routerConfig: appRouter,
    );
  }
}
