import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/models/tooth_record.dart';

/// 치아 상태 → 색상/라벨. 기준: DESIGN.md 2장(치아 상태 컬러)
({Color color, String label}) toothStatusStyle(ToothStatus status) {
  return switch (status) {
    ToothStatus.healthy => (color: Colors.white, label: '건강'),
    ToothStatus.caries => (color: AppColors.toothCaries, label: '충치'),
    ToothStatus.treated => (color: AppColors.toothTreated, label: '치료함'),
    ToothStatus.sealant => (color: AppColors.toothSealant, label: '실란트'),
    ToothStatus.missing => (color: AppColors.toothMissing, label: '빠짐'),
  };
}
