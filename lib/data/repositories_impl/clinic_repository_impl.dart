import 'package:drift/drift.dart';

import '../../domain/models/clinic.dart';
import '../../domain/repositories/clinic_repository.dart';
import '../local/app_database.dart';

class ClinicRepositoryImpl implements ClinicRepository {
  ClinicRepositoryImpl(this._db);

  final AppDatabase _db;

  Clinic _toModel(ClinicRow row) => Clinic(
        id: row.id,
        name: row.name,
        phone: row.phone,
        address: row.address,
        memo: row.memo,
        createdAt: row.createdAt,
      );

  @override
  Stream<List<Clinic>> watchAll() {
    final query = _db.select(_db.clinics)
      ..orderBy([(t) => OrderingTerm(expression: t.createdAt)]);
    return query.watch().map((rows) => rows.map(_toModel).toList());
  }

  @override
  Future<List<Clinic>> getAll() async {
    final query = _db.select(_db.clinics)
      ..orderBy([(t) => OrderingTerm(expression: t.createdAt)]);
    return (await query.get()).map(_toModel).toList();
  }

  @override
  Future<int> add({
    required String name,
    String? phone,
    String? address,
    String? memo,
  }) {
    return _db.into(_db.clinics).insert(
          ClinicsCompanion.insert(
            name: name,
            phone: Value(phone),
            address: Value(address),
            memo: Value(memo),
            createdAt: DateTime.now(),
          ),
        );
  }

  @override
  Future<void> update(Clinic clinic) {
    return (_db.update(_db.clinics)..where((t) => t.id.equals(clinic.id)))
        .write(
      ClinicsCompanion(
        name: Value(clinic.name),
        phone: Value(clinic.phone),
        address: Value(clinic.address),
        memo: Value(clinic.memo),
      ),
    );
  }

  @override
  Future<void> delete(int id) {
    return (_db.delete(_db.clinics)..where((t) => t.id.equals(id))).go();
  }
}
