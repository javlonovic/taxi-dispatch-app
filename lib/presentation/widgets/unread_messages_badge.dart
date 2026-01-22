import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/chat_provider.dart';

/// Badge widget to show unread message count
class UnreadMessagesBadge extends ConsumerWidget {
  final String rideId;
  final String userId;
  final Widget child;

  const UnreadMessagesBadge({
    Key? key,
    required this.rideId,
    required this.userId,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCountAsync = ref.watch(
      unreadCountProvider((rideId: rideId, userId: userId)),
    );

    return unreadCountAsync.when(
      data: (count) {
        if (count == 0) {
          return child;
        }

        return Badge(
          label: Text(
            count > 99 ? '99+' : count.toString(),
            style: const TextStyle(fontSize: 10),
          ),
          backgroundColor: Colors.red,
          child: child,
        );
      },
      loading: () => child,
      error: (_, __) => child,
    );
  }
}

/// Simple unread indicator dot
class UnreadIndicatorDot extends ConsumerWidget {
  final String rideId;
  final String userId;

  const UnreadIndicatorDot({
    Key? key,
    required this.rideId,
    required this.userId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCountAsync = ref.watch(
      unreadCountProvider((rideId: rideId, userId: userId)),
    );

    return unreadCountAsync.when(
      data: (count) {
        if (count == 0) {
          return const SizedBox.shrink();
        }

        return Container(
          width: 10,
          height: 10,
          decoration: const BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
