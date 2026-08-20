import 'package:flutter/material.dart';

import '../../domain/models/tooth_layout.dart';

/// 치아 종류별 실루엣을 그리는 painter.
/// 위쪽이 크라운(씹는 면), 아래가 뿌리.
class ToothPainter extends CustomPainter {
  ToothPainter({
    required this.kind,
    required this.fill,
    required this.border,
  });

  final ToothKind kind;
  final Color fill;
  final Color border;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final path = switch (kind) {
      ToothKind.incisor => _incisor(w, h),
      ToothKind.canine => _canine(w, h),
      ToothKind.molar => _molar(w, h),
    };
    canvas.drawPath(path, Paint()..color = fill..style = PaintingStyle.fill);
    canvas.drawPath(
      path,
      Paint()
        ..color = border
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..strokeJoin = StrokeJoin.round,
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
      old.kind != kind || old.fill != fill || old.border != border;
}
