import 'package:flutter/material.dart';

/// 앱 전역 색상. 기준 문서: DESIGN.md 2장 (컬러 시스템)
abstract final class AppColors {
  // 브랜드
  static const mint = Color(0xFF4DB6C4);
  static const mintDark = Color(0xFF2E8A98);
  static const coral = Color(0xFFFF8A80);
  static const background = Color(0xFFF7FBFC);
  static const surface = Color(0xFFFFFFFF);

  // 상태 (신호등)
  static const statusDone = Color(0xFF66BB6A); // 완료
  static const statusUpcoming = Color(0xFFFFB74D); // 예정
  static const statusOverdue = Color(0xFFEF5350); // 지남(주의)
  static const statusNeutral = Color(0xFFB0BEC5); // 해당없음

  // 치아 상태
  static const toothCaries = Color(0xFFEF5350); // 충치
  static const toothTreated = Color(0xFF42A5F5); // 치료함
  static const toothSealant = Color(0xFF66BB6A); // 실란트
  static const toothMissing = Color(0xFFECEFF1); // 빠짐/미맹출

  /// 자녀 프로필 색상 팔레트 (등록 시 순환 배정)
  static const childPalette = <Color>[
    Color(0xFF4DB6C4),
    Color(0xFFFF8A80),
    Color(0xFF9575CD),
    Color(0xFF4DB6AC),
    Color(0xFFF06292),
    Color(0xFF7986CB),
  ];
}
