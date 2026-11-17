import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'data/local/app_database.dart';
import 'data/local/preview_db.dart';
import 'data/providers.dart';
import 'data/seed/dev_seed.dart';
import 'data/settings/settings_repository.dart';
import 'features/settings/settings_controller.dart';

/// 개발용 샘플 데이터 시드 플래그. `flutter run --dart-define=SEED=true`
const _seed = bool.fromEnvironment('SEED');

/// 미리보기용 메모리 DB 플래그(웹 전용). `--dart-define=MEMDB=true`
/// 공유 워커가 막힌 미리보기 환경에서 화면 확인용으로만 쓴다.
const _memDb = bool.fromEnvironment('MEMDB');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final overrides = <Override>[];

  // 저장된 앱 설정을 로드해 초기값으로 주입. 실패해도 기본값으로 진행.
  try {
    final settings = await SettingsRepository().load();
    overrides.add(initialSettingsProvider.overrideWithValue(settings));
  } catch (e, st) {
    debugPrint('settings load failed, using defaults: $e\n$st');
  }

  if (_seed || _memDb) {
    final db = AppDatabase(_memDb ? await openPreviewExecutor() : null);
    if (_seed) {
      try {
        await runDevSeed(db);
      } catch (e, st) {
        // 시드 실패가 앱 시작을 막지 않도록 한다 (dev 편의 기능).
        debugPrint('dev seed skipped: $e\n$st');
      }
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
