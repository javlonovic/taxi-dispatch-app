import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../data/repositories/chat_repository_impl.dart';
import 'repository_providers.dart';

/// Messages stream provider for a specific ride
final messagesStreamProvider = StreamProvider.family<List<Message>, String>(
  (ref, rideId) {
    final repository = ref.watch(chatRepositoryProvider);
    return repository.watchMessages(rideId);
  },
);

/// Unread count provider for a specific ride and user
final unreadCountProvider = FutureProvider.family<int, ({String rideId, String userId})>(
  (ref, params) async {
    final repository = ref.watch(chatRepositoryProvider) as ChatRepositoryImpl;
    return await repository.getUnreadCount(params.rideId, params.userId);
  },
);
