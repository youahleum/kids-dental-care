import 'package:flutter/foundation.dart';

/// 실제 다녀온 검진 이력. 기준 문서: PLAN.md 6장(데이터 모델), DESIGN.md 6-4
@immutable
class CheckupRecord {
  const CheckupRecord({
    required this.id,
    required this.childId,
    required this.date,
    this.clinicName,
    this.memo,
  });

  final int id;
  final int childId;
  final DateTime date;
  final String? clinicName;
  final String? memo;

  CheckupRecord copyWith({
    DateTime? date,
    String? clinicName,
    String? memo,
  }) {
    return CheckupRecord(
      id: id,
      childId: childId,
      date: date ?? this.date,
      clinicName: clinicName ?? this.clinicName,
      memo: memo ?? this.memo,
    );
  }
}
