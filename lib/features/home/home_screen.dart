import 'package:flutter/material.dart';

import '../../shared/placeholder_screen.dart';

/// 홈 · 자녀 선택. 기준: DESIGN.md 6-1. (실 구현 M2)
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: '우리 아이 치아',
      icon: Icons.child_care,
      message: '자녀를 등록하면 여기에 표시됩니다.',
    );
  }
}
