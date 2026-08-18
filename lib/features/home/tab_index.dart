import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 하단 탭 인덱스. 0:홈 1:타임라인 2:검진기록 3:AI상담 4:치아차트
final tabIndexProvider = StateProvider<int>((ref) => 0);
