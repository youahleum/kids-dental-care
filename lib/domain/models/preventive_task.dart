import 'package:flutter/foundation.dart';

/// 예방치료/검진 항목 종류.
enum PreventiveType {
  firstVisit, // 첫 치과 방문
  checkup, // 국가 구강검진 / 정기검진
  fluoride, // 불소도포
  sealant, // 실란트(치아홈메우기)
}

/// 항목 상태.
enum TaskStatus { pending, done, skipped }

/// 자녀별 예방치료/검진 항목 (시드 템플릿 → 자녀 인스턴스).
/// 기준 문서: PLAN.md 3장(도메인 지식), 6장(데이터 모델)
@immutable
class PreventiveTask {
  const PreventiveTask({
    required this.id,
    required this.childId,
    required this.type,
    required this.title,
    required this.recommendedDate,
    required this.status,
    this.completedDate,
    this.note,
  });

  final int id;
  final int childId;
  final PreventiveType type;
  final String title;
  final DateTime recommendedDate;
  final TaskStatus status;
  final DateTime? completedDate;
  final String? note;

  PreventiveTask copyWith({
    TaskStatus? status,
    DateTime? completedDate,
    String? note,
  }) {
    return PreventiveTask(
      id: id,
      childId: childId,
      type: type,
      title: title,
      recommendedDate: recommendedDate,
      status: status ?? this.status,
      completedDate: completedDate ?? this.completedDate,
      note: note ?? this.note,
    );
  }
}
