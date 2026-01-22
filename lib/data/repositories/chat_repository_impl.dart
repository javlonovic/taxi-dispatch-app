import '../../domain/repositories/chat_repository.dart';
import '../datasources/firestore_chat_datasource.dart';
import '../models/message_dto.dart';

/// Chat repository implementation
class ChatRepositoryImpl implements ChatRepository {
  final FirestoreChatDataSource _dataSource;

  ChatRepositoryImpl({required FirestoreChatDataSource dataSource})
      : _dataSource = dataSource;

  @override
  Future<void> sendMessage(String rideId, Message message) async {
    final messageDto = MessageDto.fromDomain(message);
    await _dataSource.sendMessage(rideId, messageDto);
  }

  @override
  Stream<List<Message>> watchMessages(String rideId) {
    return _dataSource.watchMessages(rideId).map((dtos) {
      return dtos.map((dto) => dto.toDomain()).toList();
    });
  }

  @override
  Future<void> markAsRead(String rideId, String messageId) async {
    await _dataSource.markAsRead(rideId, messageId);
  }

  /// Get unread message count for a user in a ride
  Future<int> getUnreadCount(String rideId, String userId) async {
    return await _dataSource.getUnreadCount(rideId, userId);
  }
}
