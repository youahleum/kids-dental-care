import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../../domain/models/child.dart';

/// 현재 선택된 자녀 id. null이면 미선택(첫 자녀 자동 선택).
final selectedChildIdProvider = StateProvider<int?>((ref) => null);

/// 선택된 자녀 객체. 미선택 시 목록의 첫 자녀로 폴백.
final selectedChildProvider = Provider<Child?>((ref) {
  final children = ref.watch(childrenProvider).valueOrNull ?? const [];
  if (children.isEmpty) return null;
  final selectedId = ref.watch(selectedChildIdProvider);
  if (selectedId == null) return children.first;
  return children.where((c) => c.id == selectedId).firstOrNull ?? children.first;
});
