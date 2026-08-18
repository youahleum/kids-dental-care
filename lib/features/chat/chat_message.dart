import 'package:flutter/foundation.dart';

/// 대화 한 줄. LLM 대화의 표준 형태(role + content)를 따른다.
@immutable
class ChatMessage {
  const ChatMessage({
    required this.role,
    required this.text,
    this.isLoading = false,
  });

  final ChatRole role;
  final String text;

  /// AI 응답을 기다리는 중인 자리표시 메시지 여부.
  final bool isLoading;

  bool get isUser => role == ChatRole.user;
}

enum ChatRole { user, assistant }
