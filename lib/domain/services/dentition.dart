import '../../core/utils/age_utils.dart';
import '../models/tooth_record.dart';

/// 한 자리에 지금 있는 치아.
enum SlotState {
  primary, // 유치
  permanent, // 영구치
  empty, // 빈자리 (빠졌거나 아직 안 남)
}

/// 입안의 한 자리. 자리는 영구치 코드로 구분한다 (유치 20개는 영구치 1~5번 자리와 짝).
class ToothSlot {
  const ToothSlot({
    required this.permanentCode,
    required this.primaryCode,
    required this.state,
  });

  final int permanentCode;

  /// 이 자리의 유치 코드. 큰어금니(6~8번) 자리는 유치가 없어 null.
  final int? primaryCode;
  final SlotState state;

  /// 지금 화면에 그릴 치아 코드. 빈자리는 앞으로 날 영구치 모양으로 그린다.
  int get shownCode =>
      state == SlotState.primary ? primaryCode! : permanentCode;
}

/// '지금 입안' 계산: 나이에 따른 평균 맹출 시기를 기본값으로 하고,
/// 이갈이 기록(빠짐·남·되돌림)이 있으면 그 기록을 따른다. 순수 계산 — UI/DB 비의존.
abstract final class Dentition {
  /// 영구치 자리의 유치 코드 (1~5번만). 예: 11 → 51, 36 → null.
  static int? primaryOf(int permanentCode) {
    final pos = permanentCode % 10;
    if (pos > 5) return null;
    return (permanentCode ~/ 10 + 4) * 10 + pos;
  }

  /// 유치 코드가 속한 영구치 자리. 예: 51 → 11.
  static int permanentOf(int primaryCode) =>
      (primaryCode ~/ 10 - 4) * 10 + primaryCode % 10;

  static bool _isUpper(int permanentCode) => permanentCode ~/ 10 <= 2;

  /// 영구치가 나는 평균 시기(개월). 개인차가 커서 기본값으로만 쓴다.
  static int permanentEruptionMonths(int permanentCode) {
    final years = _isUpper(permanentCode)
        ? const [7.5, 8.5, 11.5, 10.5, 11.0, 6.5, 12.5, 19.0]
        : const [6.5, 7.5, 10.0, 11.0, 11.5, 6.5, 12.0, 19.0];
    return (years[permanentCode % 10 - 1] * 12).round();
  }

  /// 유치가 나는 평균 시기(개월).
  static int primaryEruptionMonths(int primaryCode) {
    final upper = primaryCode ~/ 10 <= 6;
    final months =
        upper ? const [10, 11, 19, 16, 29] : const [8, 13, 19, 16, 27];
    return months[primaryCode % 10 - 1];
  }

  /// 아직 안 난 큰어금니 자리를 점선으로 보여주기 시작하는 나이(개월).
  /// 그 전에는 자리 자체를 숨긴다.
  static const _molarSlotVisibleMonths = {6: 5 * 12, 7: 10 * 12, 8: 16 * 12};

  /// 한 자리의 현재 상태.
  static SlotState stateOf(
    int permanentCode, {
    required DateTime birthDate,
    required List<ToothEvent> events,
    required Map<int, ToothRecord> records,
    DateTime? now,
  }) {
    final primaryCode = primaryOf(permanentCode);

    // 이 자리에 해당하는 이갈이 기록만 추린다.
    final mine = events.where((e) =>
        (e.kind == ToothEventKind.erupted && e.toothCode == permanentCode) ||
        (e.kind == ToothEventKind.markedBack && e.toothCode == permanentCode) ||
        (e.kind == ToothEventKind.lost && e.toothCode == primaryCode));
    // 가장 나중에 입력한 '되돌림' 이후의 기록만 유효하다.
    final backId = mine
        .where((e) => e.kind == ToothEventKind.markedBack)
        .fold<int?>(null, (m, e) => m == null || e.id > m ? e.id : m);
    final valid = mine.where((e) => backId == null || e.id > backId);

    if (valid.any((e) => e.kind == ToothEventKind.erupted)) {
      return SlotState.permanent;
    }
    if (valid.any((e) => e.kind == ToothEventKind.lost)) {
      return SlotState.empty;
    }
    if (backId != null) {
      return primaryCode != null ? SlotState.primary : SlotState.empty;
    }

    // 영구치에 상태(충치 등)를 기록해 뒀다면 이미 난 것으로 본다.
    final rec = records[permanentCode];
    if (rec != null && rec.status != ToothStatus.missing) {
      return SlotState.permanent;
    }

    // 기록이 없으면 나이로 추정.
    final months = AgeUtils.totalMonths(birthDate, now: now);
    if (months >= permanentEruptionMonths(permanentCode)) {
      return SlotState.permanent;
    }
    if (primaryCode != null && months >= primaryEruptionMonths(primaryCode)) {
      return SlotState.primary;
    }
    return SlotState.empty;
  }

  /// 주어진 영구치 자리들(화면 순서) 중 지금 보여줄 자리의 목록.
  /// 아직 한참 뒤에 날 큰어금니 자리는 뺀다.
  static List<ToothSlot> current(
    List<int> permanentCodes, {
    required DateTime birthDate,
    required List<ToothEvent> events,
    required Map<int, ToothRecord> records,
    DateTime? now,
  }) {
    final months = AgeUtils.totalMonths(birthDate, now: now);
    final slots = <ToothSlot>[];
    for (final code in permanentCodes) {
      final state = stateOf(code,
          birthDate: birthDate, events: events, records: records, now: now);
      final visibleFrom = _molarSlotVisibleMonths[code % 10];
      if (state == SlotState.empty &&
          visibleFrom != null &&
          months < visibleFrom) {
        continue;
      }
      slots.add(ToothSlot(
        permanentCode: code,
        primaryCode: primaryOf(code),
        state: state,
      ));
    }
    return slots;
  }
}
