import 'package:drift/drift.dart';

import '../../domain/models/checkup_record.dart';
import '../../domain/repositories/checkup_repository.dart';
import '../local/app_database.dart';

class CheckupRepositoryImpl implements CheckupRepository {
  CheckupRepositoryImpl(this._db);

  final AppDatabase _db;

  CheckupRecord _toModel(CheckupRecordRow row) => CheckupRecord(
        id: row.id,
        childId: row.childId,
        date: row.date,
        clinicName: row.clinicName,
        memo: row.memo,
      );

  @override
  Stream<List<CheckupRecord>> watchByChild(int childId) {
    final query = _db.select(_db.checkupRecords)
      ..where((t) => t.childId.equals(childId))
      ..orderBy([
        (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc),
      ]);
    return query.watch().map((rows) => rows.map(_toModel).toList());
  }

  @override
  Future<int> add({
    required int childId,
    required DateTime date,
    String? clinicName,
    String? memo,
  }) {
    return _db.into(_db.checkupRecords).insert(
          CheckupRecordsCompanion.insert(
            childId: childId,
            date: date,
            clinicName: Value(clinicName),
            memo: Value(memo),
          ),
        );
  }

  @override
  Future<void> delete(int id) {
    return (_db.delete(_db.checkupRecords)..where((t) => t.id.equals(id))).go();
  }
}
