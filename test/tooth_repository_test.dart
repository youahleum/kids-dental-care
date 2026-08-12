import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_dental_care/data/local/app_database.dart';
import 'package:kids_dental_care/data/repositories_impl/child_repository_impl.dart';
import 'package:kids_dental_care/data/repositories_impl/tooth_repository_impl.dart';
import 'package:kids_dental_care/domain/models/tooth_record.dart';

void main() {
  late AppDatabase db;
  late ChildRepositoryImpl childRepo;
  late ToothRepositoryImpl toothRepo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    childRepo = ChildRepositoryImpl(db);
    toothRepo = ToothRepositoryImpl(db);
  });

  tearDown(() async => db.close());

  Future<int> addChild() => childRepo.add(
        name: '지호',
        birthDate: DateTime(2024, 4, 12),
        colorValue: 1,
      );

  test('setStatus → watch: 상태가 저장된다', () async {
    final childId = await addChild();
    await toothRepo.setStatus(
        childId: childId, toothCode: 55, status: ToothStatus.caries);
    final map = await toothRepo.watchByChild(childId).first;
    expect(map[55]?.status, ToothStatus.caries);
  });

  test('같은 치아 재설정 시 덮어쓴다 (upsert, 중복 안 생김)', () async {
    final childId = await addChild();
    await toothRepo.setStatus(
        childId: childId, toothCode: 55, status: ToothStatus.caries);
    await toothRepo.setStatus(
        childId: childId, toothCode: 55, status: ToothStatus.treated);
    final map = await toothRepo.watchByChild(childId).first;
    expect(map[55]?.status, ToothStatus.treated);
    expect(map.length, 1);
  });

  test('healthy로 설정하면 기록이 삭제된다(기본값 복귀)', () async {
    final childId = await addChild();
    await toothRepo.setStatus(
        childId: childId, toothCode: 55, status: ToothStatus.sealant);
    await toothRepo.setStatus(
        childId: childId, toothCode: 55, status: ToothStatus.healthy);
    final map = await toothRepo.watchByChild(childId).first;
    expect(map.containsKey(55), isFalse);
  });

  test('자녀 삭제 시 치아 기록도 cascade 삭제', () async {
    final childId = await addChild();
    await toothRepo.setStatus(
        childId: childId, toothCode: 55, status: ToothStatus.caries);
    await childRepo.delete(childId);
    expect(await toothRepo.watchByChild(childId).first, isEmpty);
  });
}
