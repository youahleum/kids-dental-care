import 'package:flutter/foundation.dart';

/// 치아 상태. 기준 문서: DESIGN.md 2장(치아 상태 컬러)
enum ToothStatus {
  healthy, // 건강
  caries, // 충치
  treated, // 치료함
  sealant, // 실란트
  missing, // 빠짐/미맹출
}

/// 치아별 상태 기록. 기준 문서: PLAN.md 6장
/// [toothCode]는 FDI 표기 (유치 51~85, 영구치 11~48).
@immutable
class ToothRecord {
  const ToothRecord({
    required this.id,
    required this.childId,
    required this.toothCode,
    required this.status,
    this.note,
    required this.updatedAt,
  });

  final int id;
  final int childId;
  final int toothCode;
  final ToothStatus status;
  final String? note;
  final DateTime updatedAt;
}
