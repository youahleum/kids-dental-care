import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_dental_care/data/backup/backup_service.dart';
import 'package:kids_dental_care/data/local/app_database.dart';
import 'package:kids_dental_care/data/repositories_impl/checkup_repository_impl.dart';
import 'package:kids_dental_care/data/repositories_impl/child_repository_impl.dart';
import 'package:kids_dental_care/data/repositories_impl/clinic_repository_impl.dart';
import 'package:kids_dental_care/data/repositories_impl/preventive_task_repository_impl.dart';
import 'package:kids_dental_care/data/repositories_impl/tooth_repository_impl.dart';
import 'package:kids_dental_care/domain/models/tooth_record.dart';
import 'package:kids_dental_care/domain/services/schedule_engine.dart';

void main() {
  late AppDatabase db;
  late BackupService backup;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    backup = BackupService(db);
  });

  tearDown(() async => db.close());

  Future<void> seed() async {
    final childRepo = ChildRepositoryImpl(db);
    final taskRepo = PreventiveTaskRepositoryImpl(db);
    final checkupRepo = CheckupRepositoryImpl(db);
    final toothRepo = ToothRepositoryImpl(db);

    final childId = await childRepo.add(
      name: '지호',
      birthDate: DateTime(2024, 4, 12),
      colorValue: 0xFF4DB6C4,
    );
    await taskRepo.createForChild(
        childId, ScheduleEngine.generate(DateTime(2024, 4, 12)));
    await checkupRepo.add(
      childId: childId,
      date: DateTime(2025, 4, 20),
      clinicName: '해맑은치과',
      memo: '이상 없음',
    );
    await toothRepo.setStatus(
        childId: childId, toothCode: 55, status: ToothStatus.caries);
    // 완료 처리된 task도 하나 만들어 상태 보존 확인.
    final firstTask = (await taskRepo.watchByChild(childId).first).first;
    await taskRepo.setDone(firstTask.id, done: true);

    // 단골 치과도 하나
    final clinicRepo = ClinicRepositoryImpl(db);
    await clinicRepo.add(name: '해맑은치과', phone: '02-123-4567');
  }

  Future<Map<String, int>> counts() async => {
        'children': (await db.select(db.children).get()).length,
        'tasks': (await db.select(db.preventiveTasks).get()).length,
        'checkups': (await db.select(db.checkupRecords).get()).length,
        'teeth': (await db.select(db.toothRecords).get()).length,
        'clinics': (await db.select(db.clinics).get()).length,
      };

  test('export → import 라운드트립: 데이터가 동일하게 복원된다', () async {
    await seed();
    final before = await counts();
    final json = await backup.exportToJson();

    // 전부 지우고 복원.
    await db.delete(db.toothRecords).go();
    await db.delete(db.checkupRecords).go();
    await db.delete(db.preventiveTasks).go();
    await db.delete(db.children).go();
    await db.delete(db.clinics).go();
    expect((await counts())['children'], 0);

    await backup.importFromJson(json);
    final after = await counts();
    expect(after, before);
  });

  test('복원 후 세부 값이 보존된다 (이름·상태·메모)', () async {
    await seed();
    final json = await backup.exportToJson();
    await backup.importFromJson(json);

    final child = (await db.select(db.children).get()).first;
    expect(child.name, '지호');
    expect(child.colorValue, 0xFF4DB6C4);

    final checkup = (await db.select(db.checkupRecords).get()).first;
    expect(checkup.clinicName, '해맑은치과');
    expect(checkup.memo, '이상 없음');

    final tooth = (await db.select(db.toothRecords).get()).first;
    expect(tooth.toothCode, 55);
    expect(tooth.status, ToothStatus.caries.index);

    // 완료 상태 보존
    final doneTasks = (await db.select(db.preventiveTasks).get())
        .where((t) => t.completedDate != null);
    expect(doneTasks, isNotEmpty);
  });

  test('import는 기존 데이터를 교체한다 (중복 누적 안 함)', () async {
    await seed();
    final json = await backup.exportToJson();
    final before = await counts();

    // 같은 백업을 두 번 import 해도 개수가 그대로여야 한다.
    await backup.importFromJson(json);
    await backup.importFromJson(json);
    expect(await counts(), before);
  });

  test('지원하지 않는 버전은 예외', () async {
    expect(
      () => backup.importFromMap({'formatVersion': 999, 'children': []}),
      throwsA(isA<FormatException>()),
    );
  });
}
