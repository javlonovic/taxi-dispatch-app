import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message_dto.dart';
import '../../core/exceptions/app_exception.dart';

/// Firestore chat data source
class FirestoreChatDataSource {
  final FirebaseFirestore _firestore;

  FirestoreChatDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Get messages collection reference for a ride
  CollectionReference _getMessagesCollection(String rideId) {
    return _firestore.collection('chats').doc(rideId).collection('messages');
  }

  /// Send a message
  Future<void> sendMessage(String rideId, MessageDto message) async {
    try {
      final messagesRef = _getMessagesCollection(rideId);
      
      // If message has an ID, use it; otherwise let Firestore generate one
      if (message.id.isNotEmpty) {
        await messagesRef.doc(message.id).set(message.toFirestore());
      } else {
        await messagesRef.add(message.toFirestore());
      }
    } on FirebaseException catch (e) {
      throw NetworkException('Failed to send message: ${e.message}');
    } catch (e) {
      throw GeneralException('Unexpected error sending message: $e');
    }
  }

  /// Watch messages for a ride (real-time stream)
  Stream<List<MessageDto>> watchMessages(String rideId) {
    try {
      return _getMessagesCollection(rideId)
          .orderBy('timestamp', descending: false)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => MessageDto.fromFirestore(doc))
            .toList();
      });
    } catch (e) {
      throw GeneralException('Failed to watch messages: $e');
    }
  }

  /// Mark a message as read
  Future<void> markAsRead(String rideId, String messageId) async {
    try {
      await _getMessagesCollection(rideId)
          .doc(messageId)
          .update({'read': true});
    } on FirebaseException catch (e) {
      throw NetworkException('Failed to mark message as read: ${e.message}');
    } catch (e) {
      throw GeneralException('Unexpected error marking message as read: $e');
    }
  }

  /// Get unread message count for a ride
  Future<int> getUnreadCount(String rideId, String userId) async {
    try {
      final snapshot = await _getMessagesCollection(rideId)
          .where('receiverId', isEqualTo: userId)
          .where('read', isEqualTo: false)
          .get();
      
      return snapshot.docs.length;
    } on FirebaseException catch (e) {
      throw NetworkException('Failed to get unread count: ${e.message}');
    } catch (e) {
      throw GeneralException('Unexpected error getting unread count: $e');
    }
  }
}
