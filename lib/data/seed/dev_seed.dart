import '../../domain/services/schedule_engine.dart';
import '../local/app_database.dart';
import '../repositories_impl/checkup_repository_impl.dart';
import '../repositories_impl/child_repository_impl.dart';
import '../repositories_impl/preventive_task_repository_impl.dart';

/// 개발용 샘플 데이터 시드. `--dart-define=SEED=true`일 때만 실행되며,
/// DB가 비어있을 때 한 번만 채운다. (프로덕션 미포함)
Future<void> runDevSeed(AppDatabase db) async {
  final childRepo = ChildRepositoryImpl(db);
  final existing = await childRepo.getAll();
  if (existing.isNotEmpty) return;

  final taskRepo = PreventiveTaskRepositoryImpl(db);
  final checkupRepo = CheckupRepositoryImpl(db);

  // 자녀 1: 김지호 (만 2세)
  final jihoBirth = DateTime(2024, 4, 12);
  final jihoId = await childRepo.add(
    name: '김지호',
    birthDate: jihoBirth,
    colorValue: 0xFF4DB6C4,
  );
  await taskRepo.createForChild(jihoId, ScheduleEngine.generate(jihoBirth));
  await checkupRepo.add(
    childId: jihoId,
    date: DateTime(2025, 4, 20),
    clinicName: '해맑은치과',
    memo: '첫 방문 · 이상 없음',
  );

  // 자녀 2: 김서아 (만 5세)
  final seoaBirth = DateTime(2021, 6, 3);
  final seoaId = await childRepo.add(
    name: '김서아',
    birthDate: seoaBirth,
    colorValue: 0xFFFF8A80,
  );
  await taskRepo.createForChild(seoaId, ScheduleEngine.generate(seoaBirth));
  await checkupRepo.add(
    childId: seoaId,
    date: DateTime(2025, 11, 10),
    clinicName: '해맑은치과',
    memo: '정기검진 · 6세 어금니 관찰',
  );
  await checkupRepo.add(
    childId: seoaId,
    date: DateTime(2026, 5, 5),
    clinicName: '해맑은치과',
    memo: '불소도포 · 충치 없음',
  );
}
