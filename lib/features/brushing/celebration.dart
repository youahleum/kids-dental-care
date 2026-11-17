import 'dart:math' as math;

import 'package:flutter/material.dart';

/// 하루 양치를 모두 마쳤을 때 화면 가운데에서 별이 터지는 짧은 칭찬 효과.
void showBrushingCelebration(BuildContext context) {
  final overlay = Overlay.maybeOf(context);
  if (overlay == null) return;
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _Celebration(onDone: () => entry.remove()),
  );
  overlay.insert(entry);
}

class _Celebration extends StatefulWidget {
  const _Celebration({required this.onDone});

  final VoidCallback onDone;

  @override
  State<_Celebration> createState() => _CelebrationState();
}

class _CelebrationState extends State<_Celebration>
    with SingleTickerProviderStateMixin {
  static const _stars = 14;

  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  )..forward().whenComplete(widget.onDone);

  // 별마다 방향·거리·크기를 조금씩 다르게 (고정 시드라 매번 같은 모양).
  final _rand = math.Random(7);
  late final _specs = List.generate(_stars, (i) {
    final angle = 2 * math.pi * i / _stars + _rand.nextDouble() * 0.4;
    return (
      angle: angle,
      dist: 90 + _rand.nextDouble() * 80,
      size: 18 + _rand.nextDouble() * 16,
    );
  });

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Material로 감싸 기본 글자 스타일을 준다 (없으면 글자에 노란 밑줄이 생김).
    return IgnorePointer(
      child: Material(
        type: MaterialType.transparency,
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            final t = _c.value;
            final fly = Curves.easeOutCubic.transform(t);
            final fade = t < 0.6 ? 1.0 : 1 - (t - 0.6) / 0.4;
            final pop = Curves.elasticOut.transform((t / 0.6).clamp(0.0, 1.0));
            return Stack(
              alignment: Alignment.center,
              children: [
                for (final s in _specs)
                  Transform.translate(
                    offset:
                        Offset(math.cos(s.angle), math.sin(s.angle)) *
                        (s.dist * fly),
                    child: Opacity(
                      opacity: fade,
                      child: Transform.rotate(
                        angle: fly * 1.5,
                        child: Text('⭐', style: TextStyle(fontSize: s.size)),
                      ),
                    ),
                  ),
                Opacity(
                  opacity: fade,
                  child: Transform.scale(
                    scale: pop,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFC107),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x40000000),
                            blurRadius: 16,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Text(
                        '⭐ 참 잘했어요! 스티커 획득',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF4E3B00),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
