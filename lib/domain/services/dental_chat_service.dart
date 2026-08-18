import '../models/checkup_record.dart';
import '../models/child.dart';
import '../models/preventive_task.dart';
import '../models/tooth_record.dart';
import '../../core/utils/age_utils.dart';

/// ─────────────────────────────────────────────────────────────────────
/// LLM 연동의 "계약(interface)".
///
/// ★ 학습 포인트 1 — 서비스 추상화
///   화면(UI)은 이 인터페이스에만 의존한다. 실제 응답이 Mock에서 오든
///   진짜 Claude API에서 오든 UI는 몰라도 된다.
///   → 지금은 [MockDentalChatService]를 연결하고, 나중에 준비되면
///     `ClaudeDentalChatService`(HTTP로 Anthropic API 호출)로 갈아끼우기만
///     하면 앱 전체가 실제 LLM으로 동작한다. UI 코드는 한 줄도 안 바뀐다.
/// ─────────────────────────────────────────────────────────────────────
abstract interface class DentalChatService {
  /// 사용자 질문 [question]에 답한다.
  /// [context]는 "지금 이 아이의 상황"을 담은 개인화 컨텍스트.
  Future<String> ask(String question, DentalChatContext context);
}

/// ─────────────────────────────────────────────────────────────────────
/// ★ 학습 포인트 2 — "앱 데이터 → LLM 컨텍스트" (RAG의 축소판)
///
/// LLM 활용의 본질은 "좋은 질문 + 좋은 맥락"을 넣는 것이다.
/// 이 클래스는 앱이 이미 가진 데이터(아이 나이·검진 이력·치아 상태·
/// 예방치료 진행상황)를 모아, LLM이 이해할 수 있는 "프롬프트용 요약 문자열"로
/// 만든다. 이 요약을 시스템 프롬프트에 끼워 넣으면, LLM이 마치 이 아이를
/// 아는 것처럼 개인화된 답을 하게 된다.
///
///   질문 그대로 LLM에 → "일반론"만 답함
///   질문 + 이 컨텍스트 → "이 아이 맞춤" 답변   ← 우리가 원하는 것
/// ─────────────────────────────────────────────────────────────────────
class DentalChatContext {
  const DentalChatContext({
    required this.child,
    required this.tasks,
    required this.checkups,
    required this.teeth,
    this.now,
  });

  final Child child;
  final List<PreventiveTask> tasks;
  final List<CheckupRecord> checkups;
  final Map<int, ToothRecord> teeth;
  final DateTime? now;

  /// 앱 데이터를 LLM이 읽기 좋은 자연어 요약으로 직렬화한다.
  /// (진짜 API를 붙일 때 이 문자열을 system 프롬프트에 그대로 넣으면 된다.)
  String toPromptContext() {
    final ref = now ?? DateTime.now();
    final ageLabel = AgeUtils.label(child.birthDate, now: ref);
    final months = AgeUtils.totalMonths(child.birthDate, now: ref);

    final pending =
        tasks.where((t) => t.status == TaskStatus.pending).toList();
    final done = tasks.where((t) => t.status == TaskStatus.done).toList();

    // 미완료 중 권장일이 가장 가까운 항목(임박 할 일).
    PreventiveTask? nextTask;
    for (final t in pending) {
      if (nextTask == null ||
          t.recommendedDate.isBefore(nextTask.recommendedDate)) {
        nextTask = t;
      }
    }

    final lastCheckup = checkups.isEmpty ? null : checkups.first;

    final caries = teeth.values
        .where((t) => t.status == ToothStatus.caries)
        .length;
    final treated = teeth.values
        .where((t) =>
            t.status == ToothStatus.treated ||
            t.status == ToothStatus.sealant)
        .length;

    final b = StringBuffer()
      ..writeln('# 아이 정보')
      ..writeln('- 이름: ${child.name}')
      ..writeln('- 나이: $ageLabel (총 $months개월)')
      ..writeln('# 예방치료/검진 진행')
      ..writeln('- 완료 ${done.length}건 / 미완료 ${pending.length}건');
    if (nextTask != null) {
      final d = nextTask.recommendedDate;
      b.writeln('- 다음 할 일: ${nextTask.title} '
          '(권장 ${d.year}.${d.month}.${d.day})');
    }
    b.writeln('# 검진 이력');
    if (lastCheckup != null) {
      final d = lastCheckup.date;
      b.writeln('- 최근 검진: ${d.year}.${d.month}.${d.day}'
          '${lastCheckup.clinicName != null ? ' @${lastCheckup.clinicName}' : ''}');
    } else {
      b.writeln('- 아직 검진 기록 없음');
    }
    b
      ..writeln('# 치아 상태')
      ..writeln('- 충치 $caries개 / 치료·실란트 $treated개 기록됨');
    return b.toString();
  }
}
