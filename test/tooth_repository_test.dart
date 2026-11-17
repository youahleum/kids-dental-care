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

  test('상태를 바꿀 때마다 이력이 쌓인다', () async {
    final childId = await addChild();
    await toothRepo.setStatus(
        childId: childId, toothCode: 55, status: ToothStatus.caries);
    await toothRepo.setStatus(
        childId: childId, toothCode: 55, status: ToothStatus.treated);
    final events = await toothRepo.watchEvents(childId).first;
    expect(events.map((e) => e.status),
        [ToothStatus.caries, ToothStatus.treated]);
    expect(events.every((e) => e.kind == ToothEventKind.statusChange), isTrue);
  });

  test('유치 빠짐 기록: 이력 추가 + 상태가 빠짐으로', () async {
    final childId = await addChild();
    await toothRepo.addEruptionEvent(
        childId: childId,
        toothCode: 81,
        kind: ToothEventKind.lost,
        date: DateTime(2026, 11, 3));
    final events = await toothRepo.watchEvents(childId).first;
    expect(events.where((e) => e.kind == ToothEventKind.lost), hasLength(1));
    expect(events.first.date, DateTime(2026, 11, 3));
    final teeth = await toothRepo.watchByChild(childId).first;
    expect(teeth[81]!.status, ToothStatus.missing);
  });

  test('영구치 남 기록은 상태를 바꾸지 않고, 삭제할 수 있다', () async {
    final childId = await addChild();
    await toothRepo.addEruptionEvent(
        childId: childId,
        toothCode: 41,
        kind: ToothEventKind.erupted,
        date: DateTime(2026, 11, 10));
    expect(await toothRepo.watchByChild(childId).first, isEmpty);
    final e = (await toothRepo.watchEvents(childId).first).single;
    await toothRepo.deleteEvent(e.id);
    expect(await toothRepo.watchEvents(childId).first, isEmpty);
  });
}
