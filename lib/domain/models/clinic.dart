import 'package:flutter/foundation.dart';

/// 단골 치과 정보. 기준 문서: PLAN.md 10장(향후 확장)
@immutable
class Clinic {
  const Clinic({
    required this.id,
    required this.name,
    this.phone,
    this.address,
    this.memo,
    required this.createdAt,
  });

  final int id;
  final String name;
  final String? phone;
  final String? address;
  final String? memo;
  final DateTime createdAt;

  Clinic copyWith({
    String? name,
    String? phone,
    String? address,
    String? memo,
  }) {
    return Clinic(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      memo: memo ?? this.memo,
      createdAt: createdAt,
    );
  }
}
