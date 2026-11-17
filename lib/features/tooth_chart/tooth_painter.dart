import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/models/tooth_layout.dart';

/// 치아 종류별 실루엣을 그리는 painter.
/// 위쪽이 크라운(씹는 면), 아래가 뿌리. (위턱 치아는 화면에서 상하 반전해 사용)
class ToothPainter extends CustomPainter {
  ToothPainter({
    required this.kind,
    required this.fill,
    required this.border,
    this.dashed = false,
  });

  final ToothKind kind;
  final Color fill;
  final Color border;

  /// true면 채우지 않고 점선 윤곽만 그린다 (빈자리).
  final bool dashed;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final path = switch (kind) {
      ToothKind.incisor => _incisor(w, h),
      ToothKind.canine => _canine(w, h),
      ToothKind.premolar => _premolar(w, h),
      ToothKind.molar => _molar(w, h),
    };
    if (dashed) {
      final paint = Paint()
        ..color = border
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..strokeCap = StrokeCap.round;
      for (final metric in path.computeMetrics()) {
        for (var d = 0.0; d < metric.length; d += 6) {
          canvas.drawPath(
              metric.extractPath(d, math.min(d + 3, metric.length)), paint);
        }
      }
      return;
    }

    // 바닥 그림자 → 입체감.
    canvas.drawPath(
      path.shift(const Offset(0, 1.2)),
      Paint()
        ..color = const Color(0x33000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.6),
    );
    // 왼쪽 위에서 빛이 드는 그라데이션 채움.
    final hsl = HSLColor.fromColor(fill);
    final shade =
        hsl.withLightness((hsl.lightness - 0.12).clamp(0.0, 1.0)).toColor();
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [fill, shade],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = border
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..strokeJoin = StrokeJoin.round,
    );
    // 크라운 위 작은 광택.
    canvas.drawOval(
      Rect.fromLTWH(w * 0.24, h * 0.13, w * 0.18, h * 0.16),
      Paint()..color = Colors.white.withValues(alpha: 0.55),
    );
  }

  /// 앞니: 넓은 끌 모양 크라운 + 짧은 뿌리.
  Path _incisor(double w, double h) {
    final crownBot = h * 0.55;
    return Path()
      ..moveTo(w * 0.12, h * 0.06)
      ..quadraticBezierTo(w * 0.5, 0, w * 0.88, h * 0.06)
      ..lineTo(w * 0.80, crownBot)
      // 뿌리(아래로 좁아짐)
      ..quadraticBezierTo(w * 0.72, h * 0.92, w * 0.5, h)
      ..quadraticBezierTo(w * 0.28, h * 0.92, w * 0.20, crownBot)
      ..close();
  }

  /// 송곳니: 뾰족한 크라운 + 긴 뿌리.
  Path _canine(double w, double h) {
    final crownBot = h * 0.5;
    return Path()
      ..moveTo(w * 0.5, 0) // 뾰족한 꼭대기
      ..quadraticBezierTo(w * 0.9, h * 0.18, w * 0.82, crownBot)
      ..quadraticBezierTo(w * 0.72, h * 0.94, w * 0.5, h)
      ..quadraticBezierTo(w * 0.28, h * 0.94, w * 0.18, crownBot)
      ..quadraticBezierTo(w * 0.1, h * 0.18, w * 0.5, 0)
      ..close();
  }

  /// 작은어금니(소구치): 얕게 갈라진 작은 혹 2개 크라운 + 한 갈래 뿌리.
  /// 어금니보다 좁고, 뿌리가 갈라지지 않아 한눈에 구분된다.
  Path _premolar(double w, double h) {
    final crownBot = h * 0.52;
    return Path()
      // 왼쪽 혹
      ..moveTo(w * 0.10, h * 0.27)
      ..quadraticBezierTo(w * 0.10, h * 0.03, w * 0.33, h * 0.05)
      // 가운데 얕은 홈
      ..quadraticBezierTo(w * 0.46, h * 0.07, w * 0.5, h * 0.13)
      // 오른쪽 혹
      ..quadraticBezierTo(w * 0.54, h * 0.07, w * 0.67, h * 0.05)
      ..quadraticBezierTo(w * 0.90, h * 0.03, w * 0.90, h * 0.27)
      ..lineTo(w * 0.83, crownBot)
      // 한 갈래 뿌리 (아래로 좁아짐)
      ..quadraticBezierTo(w * 0.74, h * 0.93, w * 0.5, h)
      ..quadraticBezierTo(w * 0.26, h * 0.93, w * 0.17, crownBot)
      ..close();
  }

  /// 어금니: 둥근 혹 2개 크라운 + 두 갈래 뿌리.
  Path _molar(double w, double h) {
    final crownBot = h * 0.5;
    return Path()
      // 왼쪽 혹
      ..moveTo(w * 0.06, h * 0.28)
      ..quadraticBezierTo(w * 0.06, h * 0.02, w * 0.28, h * 0.05)
      ..quadraticBezierTo(w * 0.5, h * 0.10, w * 0.5, h * 0.22)
      // 오른쪽 혹
      ..quadraticBezierTo(w * 0.5, h * 0.10, w * 0.72, h * 0.05)
      ..quadraticBezierTo(w * 0.94, h * 0.02, w * 0.94, h * 0.28)
      ..lineTo(w * 0.88, crownBot)
      // 오른쪽 뿌리
      ..quadraticBezierTo(w * 0.82, h * 0.95, w * 0.66, h)
      ..lineTo(w * 0.58, crownBot * 1.15)
      // 왼쪽 뿌리
      ..lineTo(w * 0.42, crownBot * 1.15)
      ..lineTo(w * 0.34, h)
      ..quadraticBezierTo(w * 0.18, h * 0.95, w * 0.12, crownBot)
      ..close();
  }

  @override
  bool shouldRepaint(ToothPainter old) =>
      old.kind != kind ||
      old.fill != fill ||
      old.border != border ||
      old.dashed != dashed;
}
