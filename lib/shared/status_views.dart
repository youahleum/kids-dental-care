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

/// 자녀 미등록 시 안내 + 홈 이동 액션.
class NoChildView extends StatelessWidget {
  const NoChildView({super.key, this.onGoHome});

  final VoidCallback? onGoHome;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.child_care,
                size: 48, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text('먼저 자녀를 등록해 주세요.',
                style: TextStyle(color: Theme.of(context).hintColor)),
            if (onGoHome != null) ...[
              const SizedBox(height: 16),
              FilledButton(onPressed: onGoHome, child: const Text('홈으로 가기')),
            ],
          ],
        ),
      ),
    );
  }
}
