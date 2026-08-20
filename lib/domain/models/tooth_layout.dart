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

  /// 사람이 읽는 치아 이름 (요약). 예: "왼쪽 위 첫째 큰어금니 (영구치)"
  static String label(int code) {
    final quadrant = code ~/ 10;
    final isPrimary = quadrant >= 5;
    final kind = isPrimary ? '유치' : '영구치';
    return '${sideLabel(code)} ${toothTypeName(code)} ($kind)';
  }

  /// 좌/우·위/아래 위치. 예: "왼쪽 위"
  /// (아이 기준 좌우 — 화면상 왼쪽이 아이의 오른쪽이지만,
  ///  일반 사용자에겐 화면 기준이 직관적이라 화면 기준으로 표기)
  static String sideLabel(int code) {
    final quadrant = code ~/ 10;
    return switch (quadrant) {
      1 || 5 => '오른쪽 위',
      2 || 6 => '왼쪽 위',
      3 || 7 => '왼쪽 아래',
      4 || 8 => '오른쪽 아래',
      _ => '',
    };
  }

  /// 치아 종류 이름. FDI 끝자리(중앙→바깥 순서) 기준.
  static String toothTypeName(int code) {
    final quadrant = code ~/ 10;
    final pos = code % 10;
    final isPrimary = quadrant >= 5;
    if (isPrimary) {
      // 유치: 1·2 앞니, 3 송곳니, 4·5 어금니
      return switch (pos) {
        1 => '가운데 앞니',
        2 => '옆 앞니',
        3 => '송곳니',
        4 => '첫째 어금니',
        5 => '둘째 어금니',
        _ => '치아',
      };
    }
    // 영구치: 1·2 앞니, 3 송곳니, 4·5 작은어금니, 6·7·8 큰어금니
    return switch (pos) {
      1 => '가운데 앞니',
      2 => '옆 앞니',
      3 => '송곳니',
      4 => '첫째 작은어금니',
      5 => '둘째 작은어금니',
      6 => '첫째 큰어금니',
      7 => '둘째 큰어금니',
      8 => '사랑니',
      _ => '치아',
    };
  }

  /// 치아 아래 표기할 짧은 이름. 앞니 / 송곳니 / 어금니.
  static String shortMark(int code) => switch (kind(code)) {
        ToothKind.incisor => '앞니',
        ToothKind.canine => '송곳니',
        ToothKind.molar => '어금니',
      };

  /// 형태 분류 (모양 렌더용). 앞니 / 송곳니 / 어금니.
  static ToothKind kind(int code) {
    final pos = code % 10;
    if (pos <= 2) return ToothKind.incisor;
    if (pos == 3) return ToothKind.canine;
    return ToothKind.molar;
  }
}

/// 치아 형태 분류.
enum ToothKind { incisor, canine, molar }
