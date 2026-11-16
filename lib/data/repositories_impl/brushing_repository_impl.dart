import 'package:drift/drift.dart';

import '../../domain/models/brushing.dart';
import '../../domain/repositories/brushing_repository.dart';
import '../local/app_database.dart';

class BrushingRepositoryImpl implements BrushingRepository {
  BrushingRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Stream<Map<DateTime, Set<BrushingSlot>>> watchByChild(int childId) {
    final query = _db.select(_db.brushingLogs)
      ..where((t) => t.childId.equals(childId));
    return query.watch().map((rows) {
      final map = <DateTime, Set<BrushingSlot>>{};
      for (final r in rows) {
        map
            .putIfAbsent(dayOf(r.date), () => <BrushingSlot>{})
            .add(BrushingSlot.values[r.slot]);
      }
      return map;
    });
  }

  @override
  Future<void> setBrushed({
    required int childId,
    required DateTime date,
    required BrushingSlot slot,
    required bool brushed,
  }) async {
    final day = dayOf(date);
    if (brushed) {
      await _db.into(_db.brushingLogs).insert(
            BrushingLogsCompanion.insert(
                childId: childId, date: day, slot: slot.index),
            mode: InsertMode.insertOrIgnore,
          );
    } else {
      await (_db.delete(_db.brushingLogs)
            ..where((t) =>
                t.childId.equals(childId) &
                t.date.equals(day) &
                t.slot.equals(slot.index)))
          .go();
    }
  }
}
