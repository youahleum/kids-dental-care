import 'package:drift/drift.dart';

import '../../domain/models/preventive_task.dart';
import '../../domain/repositories/preventive_task_repository.dart';
import '../../domain/services/schedule_engine.dart';
import '../local/app_database.dart';

class PreventiveTaskRepositoryImpl implements PreventiveTaskRepository {
  PreventiveTaskRepositoryImpl(this._db);

  final AppDatabase _db;

  PreventiveTask _toModel(PreventiveTaskRow row) => PreventiveTask(
        id: row.id,
        childId: row.childId,
        type: PreventiveType.values[row.type],
        title: row.title,
        recommendedDate: row.recommendedDate,
        status: TaskStatus.values[row.status],
        completedDate: row.completedDate,
        note: row.note,
      );

  @override
  Stream<List<PreventiveTask>> watchByChild(int childId) {
    final query = _db.select(_db.preventiveTasks)
      ..where((t) => t.childId.equals(childId))
      ..orderBy([(t) => OrderingTerm(expression: t.recommendedDate)]);
    return query.watch().map((rows) => rows.map(_toModel).toList());
  }

  @override
  Future<void> createForChild(int childId, List<GeneratedTask> tasks) async {
    await _db.batch((b) {
      b.insertAll(
        _db.preventiveTasks,
        [
          for (final t in tasks)
            PreventiveTasksCompanion.insert(
              childId: childId,
              type: t.type.index,
              title: t.title,
              recommendedDate: t.recommendedDate,
              status: TaskStatus.pending.index,
            ),
        ],
      );
    });
  }

  @override
  Future<void> setDone(int taskId, {required bool done}) {
    return (_db.update(_db.preventiveTasks)..where((t) => t.id.equals(taskId)))
        .write(
      PreventiveTasksCompanion(
        status: Value(done ? TaskStatus.done.index : TaskStatus.pending.index),
        completedDate: Value(done ? DateTime.now() : null),
      ),
    );
  }
}
