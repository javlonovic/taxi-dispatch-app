/// Chat repository interface
abstract class ChatRepository {
  /// Send a message
  Future<void> sendMessage(String rideId, Message message);

  /// Watch messages for a ride
  Stream<List<Message>> watchMessages(String rideId);

  /// Mark message as read
  Future<void> markAsRead(String rideId, String messageId);
}

/// Message
class Message {
  final String id;
  final String senderId;
  final String receiverId;
  final String message;
  final DateTime timestamp;
  final bool read;

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.timestamp,
    this.read = false,
  });
}
