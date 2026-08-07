import 'package:drift/drift.dart';

import '../../domain/models/child.dart';
import '../../domain/repositories/child_repository.dart';
import '../local/app_database.dart';

/// ChildRepository의 로컬(Drift) 구현.
class ChildRepositoryImpl implements ChildRepository {
  ChildRepositoryImpl(this._db);

  final AppDatabase _db;

  Child _toModel(ChildrenData row) => Child(
        id: row.id,
        name: row.name,
        birthDate: row.birthDate,
        colorValue: row.colorValue,
        photoPath: row.photoPath,
        createdAt: row.createdAt,
      );

  @override
  Stream<List<Child>> watchAll() {
    final query = _db.select(_db.children)
      ..orderBy([(t) => OrderingTerm(expression: t.createdAt)]);
    return query.watch().map((rows) => rows.map(_toModel).toList());
  }

  @override
  Future<List<Child>> getAll() async {
    final query = _db.select(_db.children)
      ..orderBy([(t) => OrderingTerm(expression: t.createdAt)]);
    final rows = await query.get();
    return rows.map(_toModel).toList();
  }

  @override
  Future<int> add({
    required String name,
    required DateTime birthDate,
    required int colorValue,
    String? photoPath,
  }) {
    return _db.into(_db.children).insert(
          ChildrenCompanion.insert(
            name: name,
            birthDate: birthDate,
            colorValue: colorValue,
            photoPath: Value(photoPath),
            createdAt: DateTime.now(),
          ),
        );
  }

  @override
  Future<void> update(Child child) {
    return (_db.update(_db.children)..where((t) => t.id.equals(child.id)))
        .write(
      ChildrenCompanion(
        name: Value(child.name),
        birthDate: Value(child.birthDate),
        colorValue: Value(child.colorValue),
        photoPath: Value(child.photoPath),
      ),
    );
  }

  @override
  Future<void> delete(int id) {
    return (_db.delete(_db.children)..where((t) => t.id.equals(id))).go();
  }
}
