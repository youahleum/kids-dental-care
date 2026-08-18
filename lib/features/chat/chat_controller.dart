import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/chat/mock_dental_chat_service.dart';
import '../../data/providers.dart';
import '../../domain/models/child.dart';
import '../../domain/services/dental_chat_service.dart';
import '../children/selected_child.dart';
import 'chat_message.dart';

/// LLM 서비스 provider.
/// ★ 여기서 Mock ↔ 진짜 API 구현을 교체한다. UI/컨트롤러는 안 바뀐다.
final dentalChatServiceProvider = Provider<DentalChatService>((ref) {
  return const MockDentalChatService();
  // 나중에: return ClaudeDentalChatService(apiKey: ...);
});

/// 대화 상태(메시지 목록)를 관리하는 컨트롤러.
final chatControllerProvider =
    StateNotifierProvider<ChatController, List<ChatMessage>>((ref) {
  return ChatController(ref);
});

class ChatController extends StateNotifier<List<ChatMessage>> {
  ChatController(this._ref)
      : super(const [
          ChatMessage(
            role: ChatRole.assistant,
            text: '안녕하세요! 우리 아이 치아 관리에 대해 궁금한 점을 물어봐 주세요. '
                '아이의 나이와 기록을 참고해 답변드려요.',
          ),
        ]);

  final Ref _ref;
  bool _busy = false;

  bool get isBusy => _busy;

  Future<void> send(String question) async {
    final text = question.trim();
    if (text.isEmpty || _busy) return;

    _busy = true;
    // 1) 사용자 메시지 + 로딩 자리표시를 즉시 화면에 반영.
    state = [
      ...state,
      ChatMessage(role: ChatRole.user, text: text),
      const ChatMessage(role: ChatRole.assistant, text: '', isLoading: true),
    ];

    try {
      // 2) "앱 데이터 → LLM 컨텍스트" 조립.
      final context = _buildContext();
      final service = _ref.read(dentalChatServiceProvider);

      // 3) LLM 호출(지금은 Mock).
      final answer = context == null
          ? '먼저 홈에서 아이를 등록해 주세요. 등록하면 그 아이에 맞춰 답변드릴 수 있어요.'
          : await service.ask(text, context);

      // 4) 로딩 자리표시를 실제 답변으로 교체.
      state = [
        ...state.sublist(0, state.length - 1),
        ChatMessage(role: ChatRole.assistant, text: answer),
      ];
    } catch (e) {
      state = [
        ...state.sublist(0, state.length - 1),
        const ChatMessage(
          role: ChatRole.assistant,
          text: '죄송해요, 답변을 가져오지 못했어요. 잠시 후 다시 시도해 주세요.',
        ),
      ];
    } finally {
      _busy = false;
    }
  }

  /// 현재 선택된 아이의 앱 데이터를 모아 LLM 컨텍스트로 만든다.
  DentalChatContext? _buildContext() {
    final Child? child = _ref.read(selectedChildProvider);
    if (child == null) return null;

    return DentalChatContext(
      child: child,
      tasks: _ref.read(timelineProvider(child.id)).valueOrNull ?? const [],
      checkups: _ref.read(checkupsProvider(child.id)).valueOrNull ?? const [],
      teeth: _ref.read(toothChartProvider(child.id)).valueOrNull ?? const {},
    );
  }
}
