import 'package:flutter/foundation.dart';

/// 자녀 프로필 도메인 모델. Drift/DB에 의존하지 않는 순수 모델.
/// 기준 문서: PLAN.md 6장 (데이터 모델)
@immutable
class Child {
  const Child({
    required this.id,
    required this.name,
    required this.birthDate,
    required this.colorValue,
    this.photoPath,
    required this.createdAt,
  });

  final int id;
  final String name;
  final DateTime birthDate;

  /// 프로필 색상 (ARGB int). 팔레트: AppColors.childPalette
  final int colorValue;
  final String? photoPath;
  final DateTime createdAt;

  Child copyWith({
    String? name,
    DateTime? birthDate,
    int? colorValue,
    String? photoPath,
  }) {
    return Child(
      id: id,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      colorValue: colorValue ?? this.colorValue,
      photoPath: photoPath ?? this.photoPath,
      createdAt: createdAt,
    );
  }
}
