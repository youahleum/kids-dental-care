import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'data/local/app_database.dart';
import 'data/providers.dart';
import 'data/seed/dev_seed.dart';

/// 개발용 샘플 데이터 시드 플래그. `flutter run --dart-define=SEED=true`
const _seed = bool.fromEnvironment('SEED');

Future<void> main() async {
  final overrides = <Override>[];

  if (_seed) {
    WidgetsFlutterBinding.ensureInitialized();
    final db = AppDatabase();
    try {
      await runDevSeed(db);
    } catch (e, st) {
      // 시드 실패가 앱 시작을 막지 않도록 한다 (dev 편의 기능).
      debugPrint('dev seed skipped: $e\n$st');
    }
    overrides.add(appDatabaseProvider.overrideWithValue(db));
  }

  runApp(
    ProviderScope(
      overrides: overrides,
      child: const KidsDentalApp(),
    ),
  );
}
