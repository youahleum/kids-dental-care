import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

part 'app_database.g.dart';

/// 자녀 프로필 테이블. 기준 문서: PLAN.md 6장
class Children extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 20)();
  DateTimeColumn get birthDate => dateTime()();
  IntColumn get colorValue => integer()();
  TextColumn get photoPath => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}

/// 예방치료/검진 항목 테이블. 기준 문서: PLAN.md 6장
/// type/status는 enum 인덱스(int)로 저장한다.
/// (도메인 모델 PreventiveTask와의 이름 충돌을 피해 row 클래스명을 지정)
@DataClassName('PreventiveTaskRow')
class PreventiveTasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get childId =>
      integer().references(Children, #id, onDelete: KeyAction.cascade)();
  IntColumn get type => integer()();
  TextColumn get title => text()();
  DateTimeColumn get recommendedDate => dateTime()();
  IntColumn get status => integer()();
  DateTimeColumn get completedDate => dateTime().nullable()();
  TextColumn get note => text().nullable()();
}

/// 검진 이력 테이블. 기준 문서: PLAN.md 6장
/// (도메인 모델 CheckupRecord와의 이름 충돌을 피해 row 클래스명을 지정)
@DataClassName('CheckupRecordRow')
class CheckupRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get childId =>
      integer().references(Children, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get date => dateTime()();
  TextColumn get clinicName => text().nullable()();
  TextColumn get memo => text().nullable()();
}

@DriftDatabase(tables: [Children, PreventiveTasks, CheckupRecords])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(preventiveTasks);
          }
          if (from < 3) {
            await m.createTable(checkupRecords);
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  static QueryExecutor _openConnection() {
    // drift_flutter: 플랫폼별 로컬 sqlite에 저장.
    // 웹은 sqlite3.wasm + drift_worker.js(web/ 폴더)가 필요하다.
    // 네이티브(iOS/Android)는 web 옵션이 무시된다.
    return driftDatabase(
      name: 'kids_dental_care',
      web: kIsWeb
          ? DriftWebOptions(
              sqlite3Wasm: Uri.parse('sqlite3.wasm'),
              driftWorker: Uri.parse('drift_worker.js'),
            )
          : null,
    );
  }
}
