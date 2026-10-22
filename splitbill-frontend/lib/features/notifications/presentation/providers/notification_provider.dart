import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splitbill_frontend/features/auth/presentation/providers/auth_provider.dart';
import 'package:splitbill_frontend/features/notifications/data/models/app_notification.dart';
import 'package:splitbill_frontend/features/notifications/data/repositories/notification_repository.dart';
import 'package:splitbill_frontend/features/notifications/presentation/providers/socket_provider.dart';
import 'package:splitbill_frontend/features/expenses/presentation/providers/expense_provider.dart';
import 'package:splitbill_frontend/features/groups/presentation/providers/group_provider.dart';
import 'package:splitbill_frontend/features/groups/presentation/notifiers/group_details_notifier.dart';
import 'package:splitbill_frontend/features/settlements/presentation/providers/settlement_provider.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return NotificationRepository(apiClient);
});

final notificationsProvider = FutureProvider<List<AppNotification>>((
  ref,
) async {
  final repository = ref.watch(notificationRepositoryProvider);
  return repository.getNotifications();
});

final unreadNotificationCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(notificationRepositoryProvider);
  return repository.getUnreadCount();
});

void _refreshDataForNotification(Ref ref, dynamic data) {
  if (data is! Map) return;

  final groupId = data['groupId'];
  final type = data['type'];

  if (groupId is! int || type is! String) return;

  switch (type) {
    case 'expense_created':
    case 'expense_updated':
    case 'expense_participant_added':
    case 'expense_participant_removed':
    case 'expense_deleted':
      ref.invalidate(expensesProvider(groupId));
      ref.invalidate(groupBalancesProvider(groupId));
      ref.invalidate(groupDetailsProvider(groupId));
      break;

    case 'settlement_created':
      ref.invalidate(groupBalancesProvider(groupId));
      ref.invalidate(settlementsProvider(groupId));
      break;

    case 'member_added':
    case 'member_removed':
      ref.invalidate(groupDetailsProvider(groupId));
      ref.invalidate(groupBalancesProvider(groupId));
      break;
  }
}

/// Connects the socket and refreshes notification data when an event arrives.
/// Watch this provider only while the user is authenticated.
final notificationSocketListenerProvider = Provider<void>((ref) {
  final socketService = ref.watch(socketServiceProvider);
  final storage = ref.watch(secureStorageProvider);

  Future<void> connect() async {
    final token = await storage.getToken();

    if (!ref.mounted || token == null || token.isEmpty) {
      return;
    }

    socketService.connect(
      baseUrl: 'https://splitbill-7uls.onrender.com',
      token: token,

      onNotification: (data) {
        ref.invalidate(notificationsProvider);
        ref.invalidate(unreadNotificationCountProvider);

        _refreshDataForNotification(ref, data);
      },
      onReconnect: () {
        ref.invalidate(notificationsProvider);
        ref.invalidate(unreadNotificationCountProvider);
      },
    );
  }

  connect();

  ref.onDispose(socketService.disconnect);
});
