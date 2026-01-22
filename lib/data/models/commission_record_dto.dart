import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/commission_record.dart';

/// Commission record DTO for Firestore serialization
class CommissionRecordDto {
  final String id;
  final String rideId;
  final String companyId;
  final String driverId;
  final double amount;
  final double commission;
  final double driverEarnings;
  final Timestamp timestamp;

  CommissionRecordDto({
    required this.id,
    required this.rideId,
    required this.companyId,
    required this.driverId,
    required this.amount,
    required this.commission,
    required this.driverEarnings,
    required this.timestamp,
  });

  /// Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'rideId': rideId,
      'companyId': companyId,
      'driverId': driverId,
      'amount': amount,
      'commission': commission,
      'driverEarnings': driverEarnings,
      'timestamp': timestamp,
    };
  }

  /// Create from Firestore document
  factory CommissionRecordDto.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CommissionRecordDto(
      id: doc.id,
      rideId: data['rideId'] as String,
      companyId: data['companyId'] as String,
      driverId: data['driverId'] as String,
      amount: (data['amount'] as num).toDouble(),
      commission: (data['commission'] as num).toDouble(),
      driverEarnings: (data['driverEarnings'] as num).toDouble(),
      timestamp: data['timestamp'] as Timestamp,
    );
  }

  /// Create from map
  factory CommissionRecordDto.fromMap(String id, Map<String, dynamic> map) {
    return CommissionRecordDto(
      id: id,
      rideId: map['rideId'] as String,
      companyId: map['companyId'] as String,
      driverId: map['driverId'] as String,
      amount: (map['amount'] as num).toDouble(),
      commission: (map['commission'] as num).toDouble(),
      driverEarnings: (map['driverEarnings'] as num).toDouble(),
      timestamp: map['timestamp'] as Timestamp,
    );
  }

  /// Convert to domain entity
  CommissionRecord toEntity() {
    return CommissionRecord(
      id: id,
      rideId: rideId,
      companyId: companyId,
      driverId: driverId,
      amount: amount,
      commission: commission,
      driverEarnings: driverEarnings,
      timestamp: timestamp.toDate(),
    );
  }

  /// Create from domain entity
  factory CommissionRecordDto.fromEntity(CommissionRecord record) {
    return CommissionRecordDto(
      id: record.id,
      rideId: record.rideId,
      companyId: record.companyId,
      driverId: record.driverId,
      amount: record.amount,
      commission: record.commission,
      driverEarnings: record.driverEarnings,
      timestamp: Timestamp.fromDate(record.timestamp),
    );
  }
}
