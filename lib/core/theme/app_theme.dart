import 'package:flutter/material.dart';

import 'app_colors.dart';

/// 밝기 모드별 표면·선·글자 색. 화면 코드는 하드코딩 대신 테마(colorScheme)에서 읽는다.
class _Palette {
  const _Palette({
    required this.brightness,
    required this.background,
    required this.surface,
    required this.subtle,
    required this.track,
    required this.outline,
    required this.appBar,
    required this.accentText,
    required this.mutedIcon,
    required this.shadow,
  });

  final Brightness brightness;
  final Color background; // 화면 바탕
  final Color surface; // 카드·시트·하단 탭
  final Color subtle; // 카드 안 옅은 채움 (surfaceContainerLow)
  final Color track; // 진행 막대 바탕 (surfaceContainerHighest)
  final Color outline; // 옅은 테두리 (outlineVariant)
  final Color appBar;
  final Color accentText; // 민트 강조 글자 (tertiary)
  final Color mutedIcon;
  final Color shadow;

  static const light = _Palette(
    brightness: Brightness.light,
    background: AppColors.background,
    surface: AppColors.surface,
    subtle: Color(0xFFF2F8F9),
    track: Color(0xFFEDF2F4),
    outline: Color(0xFFE0E7EA),
    appBar: AppColors.mint,
    accentText: AppColors.mintDark,
    mutedIcon: Color(0xFF78909C),
    shadow: Color(0x334DB6C4),
  );

  static const dark = _Palette(
    brightness: Brightness.dark,
    background: Color(0xFF12191B),
    surface: Color(0xFF1C2528),
    subtle: Color(0xFF232E31),
    track: Color(0xFF2C3A3E),
    outline: Color(0xFF34444A),
    appBar: Color(0xFF1F5F68),
    accentText: Color(0xFF6CC9D3),
    mutedIcon: Color(0xFF8FA3AA),
    shadow: Color(0x66000000),
  );
}

/// 앱 테마. 기준 문서: DESIGN.md (컬러/타이포/토큰)
/// - radius: card 20, chip 20, button 12
/// - spacing: 4의 배수
abstract final class AppTheme {
  static ThemeData get light => _build(_Palette.light);
  static ThemeData get dark => _build(_Palette.dark);

  static ThemeData _build(_Palette p) {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.mint,
          brightness: p.brightness,
          primary: AppColors.mint,
          secondary: AppColors.coral,
          tertiary: p.accentText,
          surface: p.surface,
        ).copyWith(
          surfaceContainerLow: p.subtle,
          surfaceContainerHighest: p.track,
          outlineVariant: p.outline,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: p.brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: p.background,
      appBarTheme: AppBarTheme(
        backgroundColor: p.appBar,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        color: p.surface,
        elevation: 2,
        shadowColor: p.shadow,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.subtle,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: p.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: p.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.mint, width: 1.5),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.mint,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.coral,
        foregroundColor: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shadowColor: const Color(0x22000000),
        indicatorColor: const Color(0x264DB6C4),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
            color: states.contains(WidgetState.selected)
                ? p.accentText
                : p.mutedIcon,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? p.accentText
                : p.mutedIcon,
          ),
        ),
      ),
    );
  }
}
