import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/checkup_record.dart';
import '../domain/models/child.dart';
import '../domain/models/preventive_task.dart';
import '../domain/models/tooth_record.dart';
import '../domain/repositories/checkup_repository.dart';
import '../domain/repositories/child_repository.dart';
import '../domain/repositories/preventive_task_repository.dart';
import '../domain/repositories/tooth_repository.dart';
import '../domain/services/notification_service.dart';
import 'backup/backup_service.dart';
import 'local/app_database.dart';
import 'notifications/notification_service_factory.dart';
import 'repositories_impl/checkup_repository_impl.dart';
import 'repositories_impl/child_repository_impl.dart';
import 'repositories_impl/preventive_task_repository_impl.dart';
import 'repositories_impl/tooth_repository_impl.dart';

/// 앱 전역 데이터 provider. 기준: PLAN.md 5장 (계층 분리)

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final childRepositoryProvider = Provider<ChildRepository>((ref) {
  return ChildRepositoryImpl(ref.watch(appDatabaseProvider));
});

/// 자녀 목록 실시간 스트림.
final childrenProvider = StreamProvider<List<Child>>((ref) {
  return ref.watch(childRepositoryProvider).watchAll();
});

final preventiveTaskRepositoryProvider =
    Provider<PreventiveTaskRepository>((ref) {
  return PreventiveTaskRepositoryImpl(ref.watch(appDatabaseProvider));
});

/// 특정 자녀의 예방치료/검진 타임라인 실시간 스트림.
final timelineProvider =
    StreamProvider.family<List<PreventiveTask>, int>((ref, childId) {
  return ref.watch(preventiveTaskRepositoryProvider).watchByChild(childId);
});

final checkupRepositoryProvider = Provider<CheckupRepository>((ref) {
  return CheckupRepositoryImpl(ref.watch(appDatabaseProvider));
});

/// 특정 자녀의 검진 이력(최신순) 실시간 스트림.
final checkupsProvider =
    StreamProvider.family<List<CheckupRecord>, int>((ref, childId) {
  return ref.watch(checkupRepositoryProvider).watchByChild(childId);
});

final toothRepositoryProvider = Provider<ToothRepository>((ref) {
  return ToothRepositoryImpl(ref.watch(appDatabaseProvider));
});

/// 특정 자녀의 치아 상태(toothCode→기록) 실시간 스트림.
final toothChartProvider =
    StreamProvider.family<Map<int, ToothRecord>, int>((ref, childId) {
  return ref.watch(toothRepositoryProvider).watchByChild(childId);
});

/// 로컬 알림 서비스 (웹/테스트는 no-op).
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return createNotificationService();
});

/// 데이터 백업/복원 서비스.
final backupServiceProvider = Provider<BackupService>((ref) {
  return BackupService(ref.watch(appDatabaseProvider));
});
