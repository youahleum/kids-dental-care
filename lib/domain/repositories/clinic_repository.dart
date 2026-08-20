import '../models/clinic.dart';

/// 단골 치과 저장소 인터페이스.
abstract interface class ClinicRepository {
  Stream<List<Clinic>> watchAll();
  Future<List<Clinic>> getAll();

  Future<int> add({
    required String name,
    String? phone,
    String? address,
    String? memo,
  });

  Future<void> update(Clinic clinic);
  Future<void> delete(int id);
}
