import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/models/preventive_task.dart';

/// 항목 상태 칩. 완료 / 예정 D-N / 지남 / 이후. 기준: DESIGN.md 4장(StatusChip)
class TaskStatusView extends StatelessWidget {
  const TaskStatusView({super.key, required this.task});

  final PreventiveTask task;

  @override
  Widget build(BuildContext context) {
    final (label, color) = _resolve();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: _darken(color),
        ),
      ),
    );
  }

  (String, Color) _resolve() {
    if (task.status == TaskStatus.done) {
      return ('완료', AppColors.statusDone);
    }
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(task.recommendedDate.year,
        task.recommendedDate.month, task.recommendedDate.day);
    final days = target.difference(today).inDays;

    if (days < 0) return ('지남', AppColors.statusOverdue);
    if (days == 0) return ('오늘', AppColors.statusUpcoming);
    if (days <= 60) return ('예정 D-$days', AppColors.statusUpcoming);
    return ('이후', AppColors.statusNeutral);
  }

  Color _darken(Color c) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness - 0.25).clamp(0.0, 1.0)).toColor();
  }
}
