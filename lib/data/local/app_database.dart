import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

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

@DriftDatabase(tables: [Children])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    // drift_flutter: 플랫폼별 로컬 sqlite 파일에 저장
    return driftDatabase(name: 'kids_dental_care');
  }
}
