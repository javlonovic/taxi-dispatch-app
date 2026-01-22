import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/chat_repository.dart';

/// Message DTO for Firestore
class MessageDto {
  final String id;
  final String senderId;
  final String receiverId;
  final String message;
  final Timestamp timestamp;
  final bool read;

  MessageDto({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.timestamp,
    this.read = false,
  });

  /// Convert from Firestore document
  factory MessageDto.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MessageDto(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      receiverId: data['receiverId'] ?? '',
      message: data['message'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
      read: data['read'] ?? false,
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'timestamp': timestamp,
      'read': read,
    };
  }

  /// Convert to domain entity
  Message toDomain() {
    return Message(
      id: id,
      senderId: senderId,
      receiverId: receiverId,
      message: message,
      timestamp: timestamp.toDate(),
      read: read,
    );
  }

  /// Convert from domain entity
  factory MessageDto.fromDomain(Message message) {
    return MessageDto(
      id: message.id,
      senderId: message.senderId,
      receiverId: message.receiverId,
      message: message.message,
      timestamp: Timestamp.fromDate(message.timestamp),
      read: message.read,
    );
  }
}
