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
    // 한국 이름은 첫 글자가 성이라 형제끼리 겹친다 → 이름(마지막 두 글자)을 표시.
    final chars = child.name.characters;
    final initial = chars.isEmpty
        ? '?'
        : chars.length >= 3
            ? chars.skip(chars.length - 2).string
            : chars.first;
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
          fontSize: size * (initial.length > 1 ? 0.32 : 0.42),
        ),
      ),
    );
  }
}
