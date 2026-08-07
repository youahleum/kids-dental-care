import '../models/child.dart';

/// 자녀 프로필 저장소 인터페이스. 구현은 data 계층(로컬/향후 원격).
/// 기준 문서: PLAN.md 5장 (계층 분리 - 클라우드 확장 대비)
abstract interface class ChildRepository {
  /// 자녀 목록 변경을 실시간 반영 (등록순).
  Stream<List<Child>> watchAll();

  Future<List<Child>> getAll();

  /// 새 자녀 추가. 생성된 id 반환.
  Future<int> add({
    required String name,
    required DateTime birthDate,
    required int colorValue,
    String? photoPath,
  });

  Future<void> update(Child child);

  Future<void> delete(int id);
}
