import 'package:cloud_firestore/cloud_firestore.dart';

/// Branch entity representing a company's physical location
class Branch {
  final String id;
  final String companyId;
  final String name;
  final String address;
  final GeoPoint location;
  final bool isHeadquarters;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Branch({
    required this.id,
    required this.companyId,
    required this.name,
    required this.address,
    required this.location,
    this.isHeadquarters = false,
    required this.createdAt,
    this.updatedAt,
  });

  /// Create a copy of this branch with updated fields
  Branch copyWith({
    String? id,
    String? companyId,
    String? name,
    String? address,
    GeoPoint? location,
    bool? isHeadquarters,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Branch(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      name: name ?? this.name,
      address: address ?? this.address,
      location: location ?? this.location,
      isHeadquarters: isHeadquarters ?? this.isHeadquarters,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Branch &&
        other.id == id &&
        other.companyId == companyId &&
        other.name == name &&
        other.address == address &&
        other.location.latitude == location.latitude &&
        other.location.longitude == location.longitude &&
        other.isHeadquarters == isHeadquarters;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        companyId.hashCode ^
        name.hashCode ^
        address.hashCode ^
        location.hashCode ^
        isHeadquarters.hashCode;
  }

  @override
  String toString() {
    return 'Branch(id: $id, name: $name, address: $address, isHeadquarters: $isHeadquarters)';
  }
}
