import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_dental_care/data/local/app_database.dart';
import 'package:kids_dental_care/data/repositories_impl/child_repository_impl.dart';

void main() {
  late AppDatabase db;
  late ChildRepositoryImpl repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = ChildRepositoryImpl(db);
  });

  tearDown(() async => db.close());

  test('add → getAll: 저장한 자녀가 조회된다', () async {
    final id = await repo.add(
      name: '김지호',
      birthDate: DateTime(2024, 4, 12),
      colorValue: 0xFF4DB6C4,
    );
    final all = await repo.getAll();
    expect(all, hasLength(1));
    expect(all.first.id, id);
    expect(all.first.name, '김지호');
    expect(all.first.birthDate, DateTime(2024, 4, 12));
  });

  test('여러 명 등록 순서 유지', () async {
    await repo.add(name: 'A', birthDate: DateTime(2020, 1, 1), colorValue: 1);
    await repo.add(name: 'B', birthDate: DateTime(2021, 1, 1), colorValue: 2);
    final all = await repo.getAll();
    expect(all.map((c) => c.name), ['A', 'B']);
  });

  test('update: 이름/색상이 갱신된다', () async {
    final id = await repo.add(
        name: '옛이름', birthDate: DateTime(2022, 5, 5), colorValue: 1);
    final child = (await repo.getAll()).first;
    await repo.update(child.copyWith(name: '새이름', colorValue: 99));
    final updated = (await repo.getAll()).first;
    expect(updated.id, id);
    expect(updated.name, '새이름');
    expect(updated.colorValue, 99);
  });

  test('delete: 자녀가 삭제된다', () async {
    final id = await repo.add(
        name: '삭제대상', birthDate: DateTime(2022, 5, 5), colorValue: 1);
    await repo.delete(id);
    expect(await repo.getAll(), isEmpty);
  });

  test('watchAll: 추가 시 스트림이 갱신된다', () async {
    expectLater(
      repo.watchAll().map((list) => list.length),
      emitsThrough(1),
    );
    await repo.add(name: 'X', birthDate: DateTime(2022, 1, 1), colorValue: 1);
  });

  test('아바타 이모지: 저장·변경·이름 글자로 되돌리기', () async {
    await repo.add(
        name: '지호',
        birthDate: DateTime(2024, 4, 12),
        colorValue: 1,
        avatarEmoji: '🐰');
    var c = (await repo.getAll()).single;
    expect(c.avatarEmoji, '🐰');

    await repo.update(c.withAvatar('🦊'));
    c = (await repo.getAll()).single;
    expect(c.avatarEmoji, '🦊');

    // 이름만 바꿔도 아바타는 유지된다.
    await repo.update(c.copyWith(name: '지호야'));
    c = (await repo.getAll()).single;
    expect(c.avatarEmoji, '🦊');

    await repo.update(c.withAvatar(null));
    expect((await repo.getAll()).single.avatarEmoji, isNull);
  });
}
