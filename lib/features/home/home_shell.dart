import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../checkups/checkups_screen.dart';
import '../timeline/timeline_screen.dart';
import '../tooth_chart/tooth_chart_screen.dart';
import 'home_screen.dart';
import 'tab_index.dart';

/// 하단 4탭 셸. 기준: DESIGN.md 5장 (내비게이션 구조)
class HomeShell extends ConsumerWidget {
  const HomeShell({super.key});

  static const _tabs = <Widget>[
    HomeScreen(),
    TimelineScreen(),
    CheckupsScreen(),
    ToothChartScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(tabIndexProvider);
    return Scaffold(
      body: IndexedStack(index: index, children: _tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) =>
            ref.read(tabIndexProvider.notifier).state = i,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: '홈',
          ),
          NavigationDestination(
            icon: Icon(Icons.timeline_outlined),
            selectedIcon: Icon(Icons.timeline),
            label: '타임라인',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_available_outlined),
            selectedIcon: Icon(Icons.event_available),
            label: '검진기록',
          ),
          NavigationDestination(
            icon: Icon(Icons.medical_services_outlined),
            selectedIcon: Icon(Icons.medical_services),
            label: '치아차트',
          ),
        ],
      ),
    );
  }
}
