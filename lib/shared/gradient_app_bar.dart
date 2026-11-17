import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// 헤더 그라데이션 색 (홈 헤더와 모든 화면 상단 바가 함께 쓴다).
List<Color> headerGradient(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
        ? const [Color(0xFF1F5F68), Color(0xFF2A7F8C)]
        : const [AppColors.mint, Color(0xFF6CC9D3)];

/// 홈 헤더와 같은 느낌의 상단 바: 민트 그라데이션 + 아래 모서리 둥글게.
class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  const GradientAppBar({super.key, required this.title, this.actions});

  final Widget title;
  final List<Widget>? actions;

  static const _radius = BorderRadius.vertical(bottom: Radius.circular(24));

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: title,
      actions: actions,
      toolbarHeight: 64,
      backgroundColor: Colors.transparent,
      scrolledUnderElevation: 0,
      shape: const RoundedRectangleBorder(borderRadius: _radius),
      flexibleSpace: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: _radius,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: headerGradient(context),
          ),
        ),
      ),
    );
  }
}
