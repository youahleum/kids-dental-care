import 'package:flutter/material.dart';

import '../domain/models/child.dart';

/// 자녀 아바타. 사진 없으면 이니셜(이름 첫 글자). 기준: DESIGN.md 4장
class ChildAvatar extends StatelessWidget {
  const ChildAvatar({super.key, required this.child, this.size = 36});

  final Child child;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = Color(child.colorValue);
    final initial = child.name.isNotEmpty ? child.name.characters.first : '?';
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Text(
        initial,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: size * 0.42,
        ),
      ),
    );
  }
}
