// 타임라인 기능 QA 케이스 실행본. 케이스 ID는 qa/02-테스트케이스-타임라인.md 와 같다.
// 실행: flutter test qa/timeline_cases_test.dart
// 기대 결과를 그대로 적었으므로, 결함이 있는 케이스는 실패한다(의도된 실패).
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_dental_care/core/utils/age_utils.dart';
import 'package:kids_dental_care/data/local/app_database.dart';
import 'package:kids_dental_care/data/repositories_impl/child_repository_impl.dart';
import 'package:kids_dental_care/data/repositories_impl/preventive_task_repository_impl.dart';
import 'package:kids_dental_care/domain/models/preventive_task.dart';
import 'package:kids_dental_care/domain/services/notification_scheduler.dart';
import 'package:kids_dental_care/domain/services/schedule_engine.dart';
import 'package:kids_dental_care/features/timeline/task_status_view.dart';

DateTime _dateOf(List<GeneratedTask> tasks, String titlePart) =>
    tasks.firstWhere((t) => t.title.contains(titlePart)).recommendedDate;

PreventiveTask _task(DateTime date, {TaskStatus status = TaskStatus.pending}) =>
    PreventiveTask(
      id: 1,
      childId: 1,
      type: PreventiveType.checkup,
      title: '검진',
      recommendedDate: date,
      status: status,
    );

void main() {
  group('A. 아이 일정 날짜 계산 (경계값)', () {
    test('TC-A02 윤년 2/29 출생', () {
      final t = ScheduleEngine.generate(DateTime(2024, 2, 29),
          now: DateTime(2024, 3, 1));
      expect(_dateOf(t, '첫 치과'), DateTime(2025, 2, 28));
      expect(_dateOf(t, '1차'), DateTime(2025, 8, 29));
      expect(_dateOf(t, '6세'), DateTime(2030, 2, 28));
      expect(_dateOf(t, '12세'), DateTime(2036, 2, 29));
    });

    test('TC-A03 8/31 출생 — 2월 말일 보정', () {
      final t = ScheduleEngine.generate(DateTime(2024, 8, 31),
          now: DateTime(2024, 9, 1));
      expect(_dateOf(t, '1차'), DateTime(2026, 2, 28));
      expect(_dateOf(t, '3차'), DateTime(2028, 2, 29));
    });

    test('TC-A04 12/31 출생 — 연도 넘김', () {
      final t = ScheduleEngine.generate(DateTime(2024, 12, 31),
          now: DateTime(2025, 1, 1));
      expect(_dateOf(t, '1차'), DateTime(2026, 6, 30));
      expect(_dateOf(t, '첫 치과'), DateTime(2025, 12, 31));
    });

    test('TC-A05 오늘 태어난 아이 — 8개 모두 미래', () {
      final now = DateTime(2026, 11, 25);
      final t = ScheduleEngine.generate(now, now: now);
      expect(t, hasLength(8));
      expect(t.every((x) => x.recommendedDate.isAfter(now)), isTrue);
    });

    test('TC-A06 권장일 당일의 월령 라벨이 일정과 일치 (8/31 출생, 18개월)', () {
      final birth = DateTime(2024, 8, 31);
      final due = AgeUtils.addMonths(birth, 18); // 2026-02-28
      expect(AgeUtils.totalMonths(birth, now: due), 18);
    });
  });

  group('B. 아이/어른 경계 (동등 분할 + 경계값)', () {
    final now = DateTime(2026, 11, 25);
    bool hasChildSeeds(List<GeneratedTask> t) =>
        t.any((x) => x.type == PreventiveType.sealant);
    List<GeneratedTask> scaling(List<GeneratedTask> t) =>
        t.where((x) => x.type == PreventiveType.scaling).toList();

    test('TC-B01 만 19세 생일 당일 → 어른', () {
      final t = ScheduleEngine.generate(DateTime(2007, 11, 25), now: now);
      expect(hasChildSeeds(t), isFalse);
      expect(scaling(t).first.recommendedDate, now);
    });

    test('TC-B02 만 19세 생일 하루 전 → 아이 일정 + 내일 날짜 스케일링', () {
      final t = ScheduleEngine.generate(DateTime(2007, 11, 26), now: now);
      expect(hasChildSeeds(t), isTrue);
      expect(scaling(t).first.recommendedDate, DateTime(2026, 11, 26));
    });

    test('TC-B03 만 18세(올해 19세 안 됨) → 올해 스케일링 없음', () {
      final t = ScheduleEngine.generate(DateTime(2008, 6, 1), now: now);
      expect(scaling(t).map((x) => x.recommendedDate.year), [2027, 2028]);
    });

    test('TC-B04 국가검진: 만 20세 되는 해 + 출생연도와 짝홀 일치', () {
      List<int> national(DateTime birth) => ScheduleEngine.generate(birth,
              now: now)
          .where((x) => x.title.contains('국가건강검진'))
          .map((x) => x.recommendedDate.year)
          .toList();
      expect(national(DateTime(2006, 3, 1)), [2026, 2028]); // 올해 만 20세, 짝수
      expect(national(DateTime(2007, 3, 1)), [2027]); // 내년 만 20세, 홀수
      expect(national(DateTime(2008, 3, 1)), [2028]); // 2028년에 만 20세
    });

    test('TC-B05 어른, 올해 생일이 아직 안 지남 → 생일 날짜', () {
      final t = ScheduleEngine.generate(DateTime(1990, 12, 10), now: now);
      expect(scaling(t).first.recommendedDate, DateTime(2026, 12, 10));
    });

    test('TC-B06 어른 2/29 출생, 평년 → 2/28', () {
      final t = ScheduleEngine.generate(DateTime(1992, 2, 29),
          now: DateTime(2027, 1, 10));
      expect(scaling(t).first.recommendedDate, DateTime(2027, 2, 28));
    });

    test('TC-B07 1920년생(입력 하한) → 오류 없이 어른 일정', () {
      final t = ScheduleEngine.generate(DateTime(1920, 1, 1), now: now);
      expect(scaling(t), hasLength(3));
      expect(hasChildSeeds(t), isFalse);
    });

    test('TC-B08 2/29 출생: 스케일링 권장일에 앱도 만 19세로 판단', () {
      final birth = DateTime(2008, 2, 29);
      final due = AgeUtils.addMonths(birth, 19 * 12); // 2027-02-28
      expect(AgeUtils.years(birth, now: due), 19);
    });
  });

  group('C. 상태 칩 (경계값)', () {
    final n = DateTime.now();
    DateTime day(int offset) => DateTime(n.year, n.month, n.day + offset);
    String label(int offset, {TaskStatus s = TaskStatus.pending}) =>
        TaskStatusView.resolve(_task(day(offset), status: s)).$1;

    test('TC-C01 -1일=지남 / 0일=오늘 / +1일=D-1', () {
      expect(label(-1), '지남');
      expect(label(0), '오늘');
      expect(label(1), '예정 D-1');
    });

    test('TC-C02 +60일=D-60 / +61일=이후', () {
      expect(label(60), '예정 D-60');
      expect(label(61), '이후');
    });

    test('TC-C03 완료 항목은 날짜와 무관하게 완료', () {
      expect(label(-30, s: TaskStatus.done), '완료');
      expect(label(30, s: TaskStatus.done), '완료');
    });
  });

  group('D. 알림 예약 (결정 테이블)', () {
    final due = DateTime(2026, 12, 10);
    int count(DateTime now, {TaskStatus s = TaskStatus.pending}) =>
        NotificationScheduler.forTasks([_task(due, status: s)], '지호', now: now)
            .length;

    test('TC-D01 8일 전 → 7일 전 알림 + 당일 알림', () {
      expect(count(DateTime(2026, 12, 2, 12)), 2);
    });

    test('TC-D02 7일 전 08:59 → 2건 / 09:00 → 1건', () {
      expect(count(DateTime(2026, 12, 3, 8, 59)), 2);
      expect(count(DateTime(2026, 12, 3, 9, 0)), 1);
    });

    test('TC-D03 당일 08:59 → 1건 / 09:00 → 0건', () {
      expect(count(DateTime(2026, 12, 10, 8, 59)), 1);
      expect(count(DateTime(2026, 12, 10, 9, 0)), 0);
    });

    test('TC-D04 권장일이 지남 → 0건', () {
      expect(count(DateTime(2026, 12, 11)), 0);
    });

    test('TC-D05 완료 항목 → 0건', () {
      expect(count(DateTime(2026, 12, 1), s: TaskStatus.done), 0);
    });

    test('TC-D06 건너뜀(skipped) 항목 → 0건', () {
      expect(count(DateTime(2026, 12, 1), s: TaskStatus.skipped), 0);
    });
  });

  group('E. 저장·수명 주기 (상태 전이)', () {
    late AppDatabase db;
    late ChildRepositoryImpl childRepo;
    late PreventiveTaskRepositoryImpl taskRepo;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      childRepo = ChildRepositoryImpl(db);
      taskRepo = PreventiveTaskRepositoryImpl(db);
    });
    tearDown(() async => db.close());

    Future<int> register(DateTime birth, {DateTime? now}) async {
      final id =
          await childRepo.add(name: '지호', birthDate: birth, colorValue: 1);
      await taskRepo.createForChild(
          id, ScheduleEngine.generate(birth, now: now));
      return id;
    }

    test('TC-E01 미완료 → 완료 → 미완료 전이와 완료일', () async {
      final id = await register(DateTime(2024, 4, 12));
      final first = (await taskRepo.watchByChild(id).first).first;

      await taskRepo.setDone(first.id, done: true);
      var t = (await taskRepo.watchByChild(id).first).first;
      expect(t.status, TaskStatus.done);
      expect(t.completedDate, isNotNull);

      await taskRepo.setDone(first.id, done: false);
      t = (await taskRepo.watchByChild(id).first).first;
      expect(t.status, TaskStatus.pending);
      expect(t.completedDate, isNull);
    });

    test('TC-E02 구성원 삭제 → 일정도 함께 삭제', () async {
      final id = await register(DateTime(2024, 4, 12));
      await childRepo.delete(id);
      expect(await taskRepo.watchByChild(id).first, isEmpty);
    });

    test('TC-E03 구성원 2명 — 서로의 일정이 섞이지 않음', () async {
      final a = await register(DateTime(2024, 4, 12));
      final b = await register(DateTime(1990, 3, 5));
      final ta = await taskRepo.watchByChild(a).first;
      final tb = await taskRepo.watchByChild(b).first;
      expect(ta.every((t) => t.childId == a), isTrue);
      expect(tb.every((t) => t.childId == b), isTrue);
      expect(ta.any((t) => t.type == PreventiveType.scaling), isFalse);
    });

    test('TC-E04 생년월일 수정 → 일정이 새 생일 기준으로 바뀜', () async {
      // 화면의 수정 저장 경로(child_edit_screen _save 의 _isEdit 분기)와 같은 호출.
      final id = await register(DateTime(2024, 4, 12));
      final child = (await childRepo.getAll()).first;
      await childRepo.update(child.copyWith(birthDate: DateTime(2025, 4, 12)));

      final first = (await taskRepo.watchByChild(id).first).first;
      expect(first.recommendedDate, DateTime(2026, 4, 12)); // 새 생일 + 12개월
    });

    test('TC-E05 만 10세 아이 등록 → 대상 나이가 지난 영유아 항목은 지남으로 쌓이지 않음',
        () async {
      final now = DateTime(2026, 11, 25);
      final id = await register(DateTime(2016, 11, 25), now: now);
      final overdue = (await taskRepo.watchByChild(id).first)
          .where((t) => t.recommendedDate.isBefore(now))
          .length;
      expect(overdue, 0);
    });

    test('TC-E06 어른 등록 3년 뒤에도 그해 스케일링 항목이 있음', () async {
      final id = await register(DateTime(1990, 3, 5),
          now: DateTime(2026, 11, 25));
      // 등록 이후 일정을 추가로 만드는 경로가 없어, 저장된 항목이 전부다.
      final years = (await taskRepo.watchByChild(id).first)
          .where((t) => t.type == PreventiveType.scaling)
          .map((t) => t.recommendedDate.year);
      expect(years, contains(2029));
    });
  });
}
