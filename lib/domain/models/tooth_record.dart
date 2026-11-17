import 'package:flutter/foundation.dart';

/// 치아 상태. 기준 문서: DESIGN.md 2장(치아 상태 컬러)
enum ToothStatus {
  healthy, // 건강
  caries, // 충치
  treated, // 치료함
  sealant, // 실란트
  missing, // 빠짐/미맹출
}

/// 치아 이력 종류. DB에 인덱스로 저장되므로 순서를 바꾸지 말 것.
enum ToothEventKind {
  statusChange('상태 변경'), // 충치·치료 등 상태가 바뀜
  lost('빠짐'), // 유치가 빠짐
  erupted('남'), // 영구치가 남
  // 앞선 빠짐·남 기록을 무효로 하고 그 자리를 이전 상태로 되돌림
  // ("아직 유치예요" / "아직 안 났어요"). 영구치 코드에 기록한다.
  markedBack('되돌림');

  const ToothEventKind(this.label);

  final String label;
}

/// 치아 이력 1건.
@immutable
class ToothEvent {
  const ToothEvent({
    required this.id,
    required this.childId,
    required this.toothCode,
    required this.kind,
    this.status,
    required this.date,
  });

  final int id;
  final int childId;
  final int toothCode;
  final ToothEventKind kind;

  /// [ToothEventKind.statusChange]일 때 바뀐 뒤 상태.
  final ToothStatus? status;
  final DateTime date;
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
