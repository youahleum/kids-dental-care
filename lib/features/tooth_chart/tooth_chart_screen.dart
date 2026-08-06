import 'package:flutter/material.dart';

import '../../shared/placeholder_screen.dart';

/// 치아별 상태 기록. 기준: DESIGN.md 6-5. (실 구현 M5)
class ToothChartScreen extends StatelessWidget {
  const ToothChartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: '치아 차트',
      icon: Icons.medical_services_outlined,
    );
  }
}
