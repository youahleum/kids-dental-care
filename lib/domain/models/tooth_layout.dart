/// 치아 배열 정의 (FDI 표기). 기준 문서: PLAN.md 3-3
///
/// FDI: 첫 자리는 사분면, 둘째 자리는 중앙→바깥 순서.
/// - 영구치 사분면 1(우상) 2(좌상) 3(좌하) 4(우하)
/// - 유치   사분면 5(우상) 6(좌상) 7(좌하) 8(우하)
abstract final class ToothLayout {
  /// 유치 상악 (우상 55~51, 좌상 61~65) — 화면 좌→우 순서.
  static const primaryUpper = [55, 54, 53, 52, 51, 61, 62, 63, 64, 65];

  /// 유치 하악 (우하 85~81, 좌하 71~75) — 화면 좌→우 순서.
  static const primaryLower = [85, 84, 83, 82, 81, 71, 72, 73, 74, 75];

  /// 영구치 상악 (우상 18~11, 좌상 21~28) — 화면 좌→우 순서.
  static const permanentUpper = [
    18, 17, 16, 15, 14, 13, 12, 11, //
    21, 22, 23, 24, 25, 26, 27, 28,
  ];

  /// 영구치 하악 (우하 48~41, 좌하 31~38) — 화면 좌→우 순서.
  static const permanentLower = [
    48, 47, 46, 45, 44, 43, 42, 41, //
    31, 32, 33, 34, 35, 36, 37, 38,
  ];

  /// 사람이 읽는 치아 이름 (요약).
  static String label(int code) {
    final quadrant = code ~/ 10;
    final position = code % 10;
    final isPrimary = quadrant >= 5;
    final side = switch (quadrant) {
      1 || 5 => '우상',
      2 || 6 => '좌상',
      3 || 7 => '좌하',
      4 || 8 => '우하',
      _ => '',
    };
    final kind = isPrimary ? '유치' : '영구치';
    return '$side $position번 $kind';
  }
}
