import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_dental_care/data/local/app_database.dart';
import 'package:kids_dental_care/data/repositories_impl/clinic_repository_impl.dart';

void main() {
  late AppDatabase db;
  late ClinicRepositoryImpl repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = ClinicRepositoryImpl(db);
  });

  tearDown(() async => db.close());

  test('add → getAll: 저장한 치과가 조회된다', () async {
    final id = await repo.add(
      name: '해맑은치과',
      phone: '02-123-4567',
      address: '서울시 강남구',
      memo: '주차 가능',
    );
    final all = await repo.getAll();
    expect(all, hasLength(1));
    expect(all.first.id, id);
    expect(all.first.name, '해맑은치과');
    expect(all.first.phone, '02-123-4567');
  });

  test('update: 정보가 갱신된다', () async {
    await repo.add(name: '옛치과');
    final c = (await repo.getAll()).first;
    await repo.update(c.copyWith(name: '새치과', phone: '010-0000-0000'));
    final updated = (await repo.getAll()).first;
    expect(updated.name, '새치과');
    expect(updated.phone, '010-0000-0000');
  });

  test('delete: 치과가 삭제된다', () async {
    final id = await repo.add(name: '삭제치과');
    await repo.delete(id);
    expect(await repo.getAll(), isEmpty);
  });
}
