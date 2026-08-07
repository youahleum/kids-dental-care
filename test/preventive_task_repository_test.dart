import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_dental_care/data/local/app_database.dart';
import 'package:kids_dental_care/data/repositories_impl/child_repository_impl.dart';
import 'package:kids_dental_care/data/repositories_impl/preventive_task_repository_impl.dart';
import 'package:kids_dental_care/domain/models/preventive_task.dart';
import 'package:kids_dental_care/domain/services/schedule_engine.dart';

void main() {
  late AppDatabase db;
  late ChildRepositoryImpl childRepo;
  late PreventiveTaskRepositoryImpl taskRepo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    childRepo = ChildRepositoryImpl(db);
    taskRepo = PreventiveTaskRepositoryImpl(db);
  });

  tearDown(() async => db.close());

  Future<int> addChild() => childRepo.add(
        name: '지호',
        birthDate: DateTime(2024, 4, 12),
        colorValue: 1,
      );

  test('createForChild: 시드 일정이 저장된다', () async {
    final childId = await addChild();
    final tasks = ScheduleEngine.generate(DateTime(2024, 4, 12));
    await taskRepo.createForChild(childId, tasks);

    final saved = await taskRepo.watchByChild(childId).first;
    expect(saved, hasLength(8));
    // 권장일 순 정렬 확인
    expect(saved.first.recommendedDate.isBefore(saved.last.recommendedDate),
        isTrue);
  });

  test('setDone: 완료 상태가 영속화된다', () async {
    final childId = await addChild();
    await taskRepo.createForChild(
        childId, ScheduleEngine.generate(DateTime(2024, 4, 12)));
    final task = (await taskRepo.watchByChild(childId).first).first;

    await taskRepo.setDone(task.id, done: true);
    final afterDone =
        (await taskRepo.watchByChild(childId).first).firstWhere((t) => t.id == task.id);
    expect(afterDone.status, TaskStatus.done);
    expect(afterDone.completedDate, isNotNull);

    await taskRepo.setDone(task.id, done: false);
    final afterUndo =
        (await taskRepo.watchByChild(childId).first).firstWhere((t) => t.id == task.id);
    expect(afterUndo.status, TaskStatus.pending);
    expect(afterUndo.completedDate, isNull);
  });

  test('자녀 삭제 시 항목도 cascade 삭제된다', () async {
    final childId = await addChild();
    await taskRepo.createForChild(
        childId, ScheduleEngine.generate(DateTime(2024, 4, 12)));
    expect(await taskRepo.watchByChild(childId).first, isNotEmpty);

    await childRepo.delete(childId);
    expect(await taskRepo.watchByChild(childId).first, isEmpty);
  });
}
