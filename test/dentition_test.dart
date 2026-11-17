import 'package:flutter_test/flutter_test.dart';
import 'package:kids_dental_care/domain/models/tooth_layout.dart';
import 'package:kids_dental_care/domain/models/tooth_record.dart';
import 'package:kids_dental_care/domain/services/dentition.dart';

var _id = 0;
ToothEvent _e(int code, ToothEventKind kind) => ToothEvent(
    id: ++_id, childId: 1, toothCode: code, kind: kind, date: DateTime(2026));

void main() {
  final now = DateTime(2026, 11, 17);
  DateTime born(int years, [int months = 0]) =>
      DateTime(now.year - years, now.month - months, now.day);

  SlotState state(int code, DateTime birth,
          {List<ToothEvent> events = const [],
          Map<int, ToothRecord> records = const {}}) =>
      Dentition.stateOf(code,
          birthDate: birth, events: events, records: records, now: now);

  test('유치·영구치 자리 짝', () {
    expect(Dentition.primaryOf(11), 51);
    expect(Dentition.primaryOf(25), 65);
    expect(Dentition.primaryOf(33), 73);
    expect(Dentition.primaryOf(45), 85);
    expect(Dentition.primaryOf(16), isNull);
    expect(Dentition.permanentOf(51), 11);
    expect(Dentition.permanentOf(85), 45);
  });

  group('나이로 추정', () {
    test('만 3세: 전부 유치, 큰어금니 자리는 숨김', () {
      final slots = Dentition.current(ToothLayout.permanentUpper,
          birthDate: born(3), events: const [], records: const {}, now: now);
      expect(slots, hasLength(10));
      expect(slots.every((s) => s.state == SlotState.primary), isTrue);
    });

    test('만 7세: 아래 앞니·6세 어금니는 영구치, 위 앞니는 아직 유치', () {
      final b = born(7);
      expect(state(41, b), SlotState.permanent);
      expect(state(46, b), SlotState.permanent);
      expect(state(11, b), SlotState.primary);
      expect(state(13, b), SlotState.primary);
    });

    test('만 5세: 6세 어금니 자리가 점선(빈자리)으로 보이기 시작', () {
      final slots = Dentition.current(ToothLayout.permanentLower,
          birthDate: born(5), events: const [], records: const {}, now: now);
      expect(slots, hasLength(12));
      expect(
          slots
              .where((s) => s.state == SlotState.empty)
              .map((s) => s.permanentCode),
          unorderedEquals([46, 36]));
    });

    test('만 6개월: 유치가 아직 안 나서 빈자리', () {
      expect(state(11, born(0, 6)), SlotState.empty);
    });

    test('어른: 사랑니 포함 전부 영구치', () {
      final slots = Dentition.current(ToothLayout.permanentUpper,
          birthDate: born(35), events: const [], records: const {}, now: now);
      expect(slots, hasLength(16));
      expect(slots.every((s) => s.state == SlotState.permanent), isTrue);
    });
  });

  group('이갈이 기록이 추정보다 우선', () {
    final b = born(5); // 추정으로는 전부 유치

    test('유치 빠짐 → 빈자리, 이어서 영구치 남 → 영구치', () {
      final lost = _e(81, ToothEventKind.lost);
      expect(state(41, b, events: [lost]), SlotState.empty);
      expect(state(41, b, events: [lost, _e(41, ToothEventKind.erupted)]),
          SlotState.permanent);
    });

    test('입력 순서가 뒤바뀌어도(남 먼저, 빠짐 나중) 영구치', () {
      final events = [
        _e(41, ToothEventKind.erupted),
        _e(81, ToothEventKind.lost),
      ];
      expect(state(41, b, events: events), SlotState.permanent);
    });

    test('되돌림: 추정이 영구치여도 "아직 유치예요"', () {
      final old = born(9); // 추정으로는 41이 영구치
      expect(state(41, old), SlotState.permanent);
      expect(state(41, old, events: [_e(41, ToothEventKind.markedBack)]),
          SlotState.primary);
    });

    test('되돌림 이후에 다시 기록하면 그 기록을 따른다', () {
      final events = [
        _e(81, ToothEventKind.lost),
        _e(41, ToothEventKind.markedBack),
      ];
      expect(state(41, b, events: events), SlotState.primary);
      expect(
          state(41, b, events: [...events, _e(41, ToothEventKind.erupted)]),
          SlotState.permanent);
    });

    test('큰어금니 되돌림은 "아직 안 났어요" → 빈자리', () {
      expect(state(46, born(8), events: [_e(46, ToothEventKind.markedBack)]),
          SlotState.empty);
    });

    test('다른 자리 기록은 영향 없음', () {
      expect(state(42, b, events: [_e(81, ToothEventKind.lost)]),
          SlotState.primary);
    });
  });

  test('영구치에 상태를 기록해 뒀으면 난 것으로 본다', () {
    final rec = ToothRecord(
        id: 1,
        childId: 1,
        toothCode: 16,
        status: ToothStatus.sealant,
        updatedAt: now);
    expect(state(16, born(5)), SlotState.empty);
    expect(state(16, born(5), records: {16: rec}), SlotState.permanent);
  });
}
