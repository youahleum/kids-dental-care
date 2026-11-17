import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 사용자용 에러 화면. raw 예외는 디버그 모드에서만 노출한다.
class ErrorView extends StatelessWidget {
  const ErrorView({super.key, this.error, this.onRetry});

  final Object? error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline,
                size: 48, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 12),
            const Text('잠시 문제가 생겼어요.', textAlign: TextAlign.center),
            if (kDebugMode && error != null) ...[
              const SizedBox(height: 8),
              Text('$error',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 11, color: Theme.of(context).hintColor)),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              OutlinedButton(onPressed: onRetry, child: const Text('다시 시도')),
            ],
          ],
        ),
      ),
    );
  }
}

/// 빈 화면 안내: 치아 캐릭터 + 제목 + 설명 (+ 버튼).
class MascotEmptyView extends StatelessWidget {
  const MascotEmptyView({
    super.key,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.compact = false,
  });

  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  /// 목록 안에 넣을 때처럼 작게 보여줄지.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 72.0 : 104.0;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(compact ? 16 : 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: size + 28,
              height: size + 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(size * 0.28),
                child: Image.asset('assets/icon/app_icon.png', width: size),
              ),
            ),
            SizedBox(height: compact ? 12 : 18),
            Text(title,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: compact ? 14 : 17, fontWeight: FontWeight.w700)),
            if (message != null) ...[
              const SizedBox(height: 6),
              Text(message!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: Theme.of(context).hintColor)),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 18),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

/// 가족 미등록 시 안내 + 홈 이동 액션.
class NoChildView extends StatelessWidget {
  const NoChildView({super.key, this.onGoHome});

  final VoidCallback? onGoHome;

  @override
  Widget build(BuildContext context) {
    return MascotEmptyView(
      title: '먼저 가족을 등록해 주세요',
      message: '홈에서 가족을 추가하면 여기에 기록이 보여요.',
      actionLabel: onGoHome == null ? null : '홈으로 가기',
      onAction: onGoHome,
    );
  }
}
