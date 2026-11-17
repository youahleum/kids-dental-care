import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../domain/models/preventive_task.dart';

/// 항목 상태 칩. 완료 / 예정 D-N / 지남 / 이후. 기준: DESIGN.md 4장(StatusChip)
class TaskStatusView extends StatelessWidget {
  const TaskStatusView({super.key, required this.task});

  final PreventiveTask task;

  @override
  Widget build(BuildContext context) {
    final (label, color) = resolve(task);
    final dark = Theme.of(context).brightness == Brightness.dark;
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
          color: _ink(color, dark),
        ),
      ),
    );
  }

  /// 항목의 상태 라벨과 색. 타임라인 점 색에도 쓴다.
  static (String, Color) resolve(PreventiveTask task) {
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

  /// 글자색: 밝은 모드는 어둡게, 어두운 모드는 밝게.
  Color _ink(Color c, bool dark) {
    final hsl = HSLColor.fromColor(c);
    final l = dark ? hsl.lightness + 0.15 : hsl.lightness - 0.25;
    return hsl.withLightness(l.clamp(0.0, 1.0)).toColor();
  }
}
