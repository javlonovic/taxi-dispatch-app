import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/branch.dart';

/// Branch DTO for Firestore serialization
class BranchDto {
  final String id;
  final String companyId;
  final String name;
  final String address;
  final GeoPoint location;
  final bool isHeadquarters;
  final Timestamp createdAt;
  final Timestamp? updatedAt;

  BranchDto({
    required this.id,
    required this.companyId,
    required this.name,
    required this.address,
    required this.location,
    this.isHeadquarters = false,
    required this.createdAt,
    this.updatedAt,
  });

  /// Convert DTO to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'companyId': companyId,
      'name': name,
      'address': address,
      'location': location,
      'isHeadquarters': isHeadquarters,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  /// Create DTO from Firestore document
  factory BranchDto.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BranchDto.fromMap(doc.id, data);
  }

  /// Create DTO from map with document ID
  factory BranchDto.fromMap(String id, Map<String, dynamic> map) {
    return BranchDto(
      id: id,
      companyId: map['companyId'] as String,
      name: map['name'] as String,
      address: map['address'] as String,
      location: map['location'] as GeoPoint,
      isHeadquarters: map['isHeadquarters'] as bool? ?? false,
      createdAt: map['createdAt'] as Timestamp,
      updatedAt: map['updatedAt'] as Timestamp?,
    );
  }

  /// Create DTO from entity
  factory BranchDto.fromEntity(Branch branch) {
    return BranchDto(
      id: branch.id,
      companyId: branch.companyId,
      name: branch.name,
      address: branch.address,
      location: branch.location,
      isHeadquarters: branch.isHeadquarters,
      createdAt: Timestamp.fromDate(branch.createdAt),
      updatedAt: branch.updatedAt != null 
          ? Timestamp.fromDate(branch.updatedAt!) 
          : null,
    );
  }

  /// Convert DTO to entity
  Branch toEntity() {
    return Branch(
      id: id,
      companyId: companyId,
      name: name,
      address: address,
      location: location,
      isHeadquarters: isHeadquarters,
      createdAt: createdAt.toDate(),
      updatedAt: updatedAt?.toDate(),
    );
  }

  /// Create a copy with updated fields
  BranchDto copyWith({
    String? id,
    String? companyId,
    String? name,
    String? address,
    GeoPoint? location,
    bool? isHeadquarters,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return BranchDto(
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
  String toString() {
    return 'BranchDto(id: $id, name: $name, address: $address, isHeadquarters: $isHeadquarters)';
  }
}
