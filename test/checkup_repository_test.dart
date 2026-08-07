import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_dental_care/data/local/app_database.dart';
import 'package:kids_dental_care/data/repositories_impl/checkup_repository_impl.dart';
import 'package:kids_dental_care/data/repositories_impl/child_repository_impl.dart';

void main() {
  late AppDatabase db;
  late ChildRepositoryImpl childRepo;
  late CheckupRepositoryImpl checkupRepo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    childRepo = ChildRepositoryImpl(db);
    checkupRepo = CheckupRepositoryImpl(db);
  });

  tearDown(() async => db.close());

  Future<int> addChild() => childRepo.add(
        name: '지호',
        birthDate: DateTime(2024, 4, 12),
        colorValue: 1,
      );

  test('add → watch: 저장한 검진이 조회된다', () async {
    final childId = await addChild();
    await checkupRepo.add(
      childId: childId,
      date: DateTime(2026, 5, 5),
      clinicName: '해맑은치과',
      memo: '충치 없음',
    );
    final list = await checkupRepo.watchByChild(childId).first;
    expect(list, hasLength(1));
    expect(list.first.clinicName, '해맑은치과');
    expect(list.first.memo, '충치 없음');
  });

  test('최신순 정렬', () async {
    final childId = await addChild();
    await checkupRepo.add(childId: childId, date: DateTime(2025, 11, 10));
    await checkupRepo.add(childId: childId, date: DateTime(2026, 5, 5));
    final list = await checkupRepo.watchByChild(childId).first;
    expect(list.map((r) => r.date), [
      DateTime(2026, 5, 5),
      DateTime(2025, 11, 10),
    ]);
  });

  test('delete: 검진이 삭제된다', () async {
    final childId = await addChild();
    final id = await checkupRepo.add(childId: childId, date: DateTime(2026, 5, 5));
    await checkupRepo.delete(id);
    expect(await checkupRepo.watchByChild(childId).first, isEmpty);
  });

  test('자녀 삭제 시 검진도 cascade 삭제', () async {
    final childId = await addChild();
    await checkupRepo.add(childId: childId, date: DateTime(2026, 5, 5));
    await childRepo.delete(childId);
    expect(await checkupRepo.watchByChild(childId).first, isEmpty);
  });
}
