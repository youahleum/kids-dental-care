import 'package:flutter/material.dart';

import '../../shared/placeholder_screen.dart';

/// 검진 기록 · 이력. 기준: DESIGN.md 6-4. (실 구현 M4)
class CheckupsScreen extends StatelessWidget {
  const CheckupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: '검진 기록',
      icon: Icons.event_available,
    );
  }
}
