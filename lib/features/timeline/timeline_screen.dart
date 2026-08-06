import 'package:flutter/material.dart';

import '../../shared/placeholder_screen.dart';

/// 예방치료 타임라인. 기준: DESIGN.md 6-3. (실 구현 M3)
class TimelineScreen extends StatelessWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: '타임라인',
      icon: Icons.timeline,
    );
  }
}
