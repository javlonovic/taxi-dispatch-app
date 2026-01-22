import 'package:cloud_firestore/cloud_firestore.dart';

/// TopUpRecord entity
class TopUpRecord {
  final String id;
  final String companyId;
  final String adminId;
  final double amount;
  final DateTime timestamp;
  final String? notes;
  final String? adminName;
  final String? companyName;

  TopUpRecord({
    required this.id,
    required this.companyId,
    required this.adminId,
    required this.amount,
    required this.timestamp,
    this.notes,
    this.adminName,
    this.companyName,
  });
}

/// TopUpRecord DTO for Firestore serialization
class TopUpRecordDto {
  final String id;
  final String companyId;
  final String adminId;
  final double amount;
  final Timestamp timestamp;
  final String? notes;
  final String? adminName;
  final String? companyName;

  TopUpRecordDto({
    required this.id,
    required this.companyId,
    required this.adminId,
    required this.amount,
    required this.timestamp,
    this.notes,
    this.adminName,
    this.companyName,
  });

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'companyId': companyId,
      'adminId': adminId,
      'amount': amount,
      'timestamp': timestamp,
      'notes': notes,
      'adminName': adminName,
      'companyName': companyName,
    };
  }

  /// Convert from Firestore document
  factory TopUpRecordDto.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TopUpRecordDto(
      id: doc.id,
      companyId: data['companyId'] as String,
      adminId: data['adminId'] as String,
      amount: (data['amount'] as num).toDouble(),
      timestamp: data['timestamp'] as Timestamp,
      notes: data['notes'] as String?,
      adminName: data['adminName'] as String?,
      companyName: data['companyName'] as String?,
    );
  }

  /// Convert to domain entity
  TopUpRecord toEntity() {
    return TopUpRecord(
      id: id,
      companyId: companyId,
      adminId: adminId,
      amount: amount,
      timestamp: timestamp.toDate(),
      notes: notes,
      adminName: adminName,
      companyName: companyName,
    );
  }

  /// Convert from domain entity
  factory TopUpRecordDto.fromEntity(TopUpRecord record) {
    return TopUpRecordDto(
      id: record.id,
      companyId: record.companyId,
      adminId: record.adminId,
      amount: record.amount,
      timestamp: Timestamp.fromDate(record.timestamp),
      notes: record.notes,
      adminName: record.adminName,
      companyName: record.companyName,
    );
  }
}
