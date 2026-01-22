import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import '../../domain/repositories/payment_repository.dart';

/// Payment method DTO
class PaymentMethodDto {
  final String id;
  final String type;
  final String last4;
  final String? brand;
  final int? expMonth;
  final int? expYear;

  PaymentMethodDto({
    required this.id,
    required this.type,
    required this.last4,
    this.brand,
    this.expMonth,
    this.expYear,
  });

  /// Convert to domain model
  PaymentMethod toDomain() {
    return PaymentMethod(
      id: id,
      type: type,
      last4: last4,
    );
  }

  /// Convert from domain model
  factory PaymentMethodDto.fromDomain(PaymentMethod method) {
    return PaymentMethodDto(
      id: method.id,
      type: method.type,
      last4: method.last4,
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'type': type,
      'last4': last4,
      'brand': brand,
      'expMonth': expMonth,
      'expYear': expYear,
    };
  }

  /// Convert from Firestore map
  factory PaymentMethodDto.fromFirestore(Map<String, dynamic> data) {
    return PaymentMethodDto(
      id: data['id'] as String,
      type: data['type'] as String,
      last4: data['last4'] as String,
      brand: data['brand'] as String?,
      expMonth: data['expMonth'] as int?,
      expYear: data['expYear'] as int?,
    );
  }
}

/// Payment DTO
class PaymentDto {
  final String id;
  final String rideId;
  final String userId;
  final double amount;
  final String currency;
  final String status;
  final String? paymentMethodId;
  final String? stripePaymentIntentId;
  final DateTime timestamp;

  PaymentDto({
    required this.id,
    required this.rideId,
    required this.userId,
    required this.amount,
    required this.currency,
    required this.status,
    this.paymentMethodId,
    this.stripePaymentIntentId,
    required this.timestamp,
  });

  /// Convert to domain model
  Payment toDomain() {
    return Payment(
      id: id,
      rideId: rideId,
      amount: amount,
      timestamp: timestamp,
    );
  }

  /// Convert from domain model
  factory PaymentDto.fromDomain(Payment payment, {
    required String userId,
    required String currency,
    required String status,
    String? paymentMethodId,
    String? stripePaymentIntentId,
  }) {
    return PaymentDto(
      id: payment.id,
      rideId: payment.rideId,
      userId: userId,
      amount: payment.amount,
      currency: currency,
      status: status,
      paymentMethodId: paymentMethodId,
      stripePaymentIntentId: stripePaymentIntentId,
      timestamp: payment.timestamp,
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'rideId': rideId,
      'userId': userId,
      'amount': amount,
      'currency': currency,
      'status': status,
      'paymentMethodId': paymentMethodId,
      'stripePaymentIntentId': stripePaymentIntentId,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  /// Convert from Firestore document
  factory PaymentDto.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PaymentDto(
      id: doc.id,
      rideId: data['rideId'] as String,
      userId: data['userId'] as String,
      amount: (data['amount'] as num).toDouble(),
      currency: data['currency'] as String,
      status: data['status'] as String,
      paymentMethodId: data['paymentMethodId'] as String?,
      stripePaymentIntentId: data['stripePaymentIntentId'] as String?,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }
}

/// Receipt DTO
class ReceiptDto {
  final String id;
  final String paymentId;
  final String rideId;
  final double amount;
  final String currency;
  final DateTime timestamp;
  final String? pickupAddress;
  final String? destinationAddress;
  final double? distance;
  final int? duration;

  ReceiptDto({
    required this.id,
    required this.paymentId,
    required this.rideId,
    required this.amount,
    required this.currency,
    required this.timestamp,
    this.pickupAddress,
    this.destinationAddress,
    this.distance,
    this.duration,
  });

  /// Convert to domain model
  Receipt toDomain() {
    return Receipt(
      id: id,
      paymentId: paymentId,
      amount: amount,
      timestamp: timestamp,
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'paymentId': paymentId,
      'rideId': rideId,
      'amount': amount,
      'currency': currency,
      'timestamp': Timestamp.fromDate(timestamp),
      'pickupAddress': pickupAddress,
      'destinationAddress': destinationAddress,
      'distance': distance,
      'duration': duration,
    };
  }

  /// Convert from Firestore document
  factory ReceiptDto.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReceiptDto(
      id: doc.id,
      paymentId: data['paymentId'] as String,
      rideId: data['rideId'] as String,
      amount: (data['amount'] as num).toDouble(),
      currency: data['currency'] as String,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      pickupAddress: data['pickupAddress'] as String?,
      destinationAddress: data['destinationAddress'] as String?,
      distance: (data['distance'] as num?)?.toDouble(),
      duration: data['duration'] as int?,
    );
  }
}

/// Transaction DTO
class TransactionDto {
  final String id;
  final String userId;
  final double amount;
  final DateTime timestamp;
  final String type;
  final String? rideId;
  final String? description;

  TransactionDto({
    required this.id,
    required this.userId,
    required this.amount,
    required this.timestamp,
    required this.type,
    this.rideId,
    this.description,
  });

  /// Convert to domain model
  Transaction toDomain() {
    return Transaction(
      id: id,
      amount: amount,
      timestamp: timestamp,
      type: type,
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'amount': amount,
      'timestamp': Timestamp.fromDate(timestamp),
      'type': type,
      'rideId': rideId,
      'description': description,
    };
  }

  /// Convert from Firestore document
  factory TransactionDto.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TransactionDto(
      id: doc.id,
      userId: data['userId'] as String,
      amount: (data['amount'] as num).toDouble(),
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      type: data['type'] as String,
      rideId: data['rideId'] as String?,
      description: data['description'] as String?,
    );
  }
}
