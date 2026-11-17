import 'dart:math';

import '../../core/utils/age_utils.dart';
import '../../domain/models/preventive_task.dart';
import '../../domain/services/schedule_engine.dart';
import '../../domain/services/dental_chat_service.dart';

/// ─────────────────────────────────────────────────────────────────────
/// ★ 학습 포인트 3 — Mock 구현
///
/// 진짜 Claude API 없이도 "LLM이 있는 것처럼" 동작시키는 가짜 구현.
/// 키워드 규칙 + 구성원의 실제 컨텍스트를 조합해 그럴듯한 답을 만든다.
///
/// 진짜 API로 바꿀 때 할 일은 딱 하나:
///   class ClaudeDentalChatService implements DentalChatService {
///     `Future<String>` ask(q, ctx) async {
///       final res = await http.post(anthropicUrl, body: jsonEncode({
///         'model': 'claude-...',
///         'system': SYSTEM_PROMPT + ctx.toPromptContext(),  // ← 컨텍스트 주입
///         'messages': [{'role':'user','content': q}],
///       }));
///       return parse(res);
///     }
///   }
/// 그리고 providers.dart 에서 Mock 대신 이걸 반환하게 하면 끝.
/// ─────────────────────────────────────────────────────────────────────
class MockDentalChatService implements DentalChatService {
  const MockDentalChatService();

  static const _disclaimer =
      '\n\n※ 이 답변은 일반적인 안내이며, 실제 치료 시기·방법은 치과 전문의 상담으로 결정해 주세요.';

  @override
  Future<String> ask(String question, DentalChatContext context) async {
    // 실제 네트워크 지연을 흉내 내 로딩 UX를 확인할 수 있게 한다.
    await Future<void>.delayed(
        Duration(milliseconds: 500 + Random().nextInt(500)));

    final q = question.toLowerCase();
    final name = context.child.name;
    final isAdult =
        AgeUtils.years(context.child.birthDate) >= ScheduleEngine.adultAge;

    // 미완료 중 가장 임박한 항목(컨텍스트 활용 예시).
    final pending = context.tasks
        .where((t) => t.status == TaskStatus.pending)
        .toList()
      ..sort((a, b) => a.recommendedDate.compareTo(b.recommendedDate));
    final next = pending.isEmpty ? null : pending.first;

    String body;
    if (_has(q, ['불소'])) {
      body = '$name(이)의 나이에는 불소도포가 충치 예방에 도움이 됩니다. '
          '보통 유치 어금니가 난 뒤 3~6개월마다 반복하며, 정기검진 때 함께 받는 경우가 많아요.';
    } else if (_has(q, ['실란트', '홈메우기', '홈 메우기'])) {
      body = '실란트(치아홈메우기)는 영구치 어금니가 난 직후가 적기입니다. '
          '첫 영구 어금니는 보통 만 6세 무렵에 나므로, 그때 치과에서 확인해 보세요.';
    } else if (_has(q, ['충치', '썩', '아파', '아프'])) {
      body = '충치가 의심되면 방치할수록 진행이 빨라 조기 진료가 중요합니다. '
          '$name(이)의 치아차트에 기록해 두고, 가까운 시일에 검진을 받아보시길 권해요.';
    } else if (_has(q, ['스케일링', '치석'])) {
      body = '스케일링은 만 19세 이상이면 건강보험으로 1년에 한 번 받을 수 있어요(매년 1월 초기화). '
          '잇몸 질환 예방에 효과적이니 정기검진 때 함께 받는 것을 권해요.';
    } else if (_has(q, ['양치', '칫솔', '이닦', '이 닦'])) {
      body = isAdult
          ? '하루 2회 이상, 2분씩 잇몸 쪽까지 꼼꼼히 닦아 주세요. '
              '치실·치간칫솔로 치아 사이를 하루 한 번 관리하면 잇몸 질환 예방에 큰 도움이 됩니다.'
          : '이 시기 아이는 스스로 닦기 어려워, 보호자가 마무리 양치를 도와주는 것이 좋습니다. '
              '불소치약을 쌀알~콩알 크기로 사용하고 하루 2회, 자기 전 양치를 꼭 챙겨주세요.';
    } else if (_has(q, ['검진', '언제', '예약', '다음'])) {
      body = next != null
          ? '$name(이)의 다음 권장 항목은 "${next.title}"입니다. '
              '아직 완료하지 않았다면 이 시기에 맞춰 방문을 계획해 보세요.'
          : '$name(이)은 예정된 미완료 항목이 없어요. 보통 6개월마다 정기검진을 권장합니다.';
    } else {
      body = '$name(이)의 현재 상황을 바탕으로 도와드릴게요. '
          '불소도포, 실란트, 스케일링, 양치 습관, 다음 검진 시기 등 궁금한 점을 물어봐 주세요.';
      if (next != null) {
        body += ' 참고로 다음 권장 항목은 "${next.title}"입니다.';
      }
    }

    return body + _disclaimer;
  }

  bool _has(String text, List<String> keywords) =>
      keywords.any(text.contains);
}
