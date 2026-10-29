import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:splitbill_frontend/features/notifications/data/models/app_notification.dart';
import 'package:splitbill_frontend/features/notifications/presentation/providers/notification_provider.dart';

class NotificationHistoryScreen extends ConsumerWidget {
  const NotificationHistoryScreen({super.key});

  static const _primary = Color(0xFF176B55);
  static const _background = Color(0xFFF6F8F7);
  static const _text = Color(0xFF172B25);
  static const _muted = Color(0xFF75817C);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsState = ref.watch(notificationsProvider);
    final unreadState = ref.watch(unreadNotificationCountProvider);

    Future<void> refreshNotifications() async {
      ref.invalidate(notificationsProvider);
      ref.invalidate(unreadNotificationCountProvider);
      await ref.read(notificationsProvider.future);
    }

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: _text,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh notifications',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              ref.invalidate(notificationsProvider);
              ref.invalidate(unreadNotificationCountProvider);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: notificationsState.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: _primary)),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_off_outlined, size: 44, color: _muted),
                  const SizedBox(height: 16),
                  const Text(
                    'Could not load notifications',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _text,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: _muted),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: () {
                      ref.invalidate(notificationsProvider);
                      ref.invalidate(unreadNotificationCountProvider);
                    },
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Try again'),
                    style: FilledButton.styleFrom(
                      backgroundColor: _primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        data: (notifications) {
          final unreadCount =
              unreadState.asData?.value ??
              notifications.where((item) => !item.isRead).length;

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: RefreshIndicator(
                color: _primary,
                onRefresh: refreshNotifications,
                child: notifications.isEmpty
                    ? const _EmptyNotifications()
                    : ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                        children: [
                          Container(
                            padding: const EdgeInsets.all(22),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF176B55), Color(0xFF27876B)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(13),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(
                                    Icons.notifications_active_outlined,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Stay up to date',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 19,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        unreadCount == 0
                                            ? 'You are all caught up.'
                                            : 'You have $unreadCount unread ${unreadCount == 1 ? 'notification' : 'notifications'}.',
                                        style: const TextStyle(
                                          color: Color(0xFFD9EEE6),
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (unreadCount > 0)
                                  Container(
                                    constraints: const BoxConstraints(
                                      minWidth: 34,
                                      minHeight: 34,
                                    ),
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 9,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: Text(
                                      unreadCount > 99 ? '99+' : '$unreadCount',
                                      style: const TextStyle(
                                        color: _primary,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 26),
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Recent activity',
                                  style: TextStyle(
                                    color: _text,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Text(
                                '${notifications.length} total',
                                style: const TextStyle(
                                  color: _muted,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          ...notifications.map(
                            (notification) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _NotificationCard(
                                notification: notification,
                                onTap: () async {
                                  if (notification.isRead) return;

                                  try {
                                    await ref
                                        .read(notificationRepositoryProvider)
                                        .markAsRead(notification.id);

                                    ref.invalidate(notificationsProvider);
                                    ref.invalidate(
                                      unreadNotificationCountProvider,
                                    );
                                  } catch (error) {
                                    if (!context.mounted) return;

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(error.toString())),
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.notification, required this.onTap});

  final AppNotification notification;
  final VoidCallback onTap;

  static const _primary = Color(0xFF176B55);
  static const _text = Color(0xFF172B25);
  static const _muted = Color(0xFF75817C);
  static const _border = Color(0xFFE6ECE8);

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime.toLocal());
  }

  IconData _iconForType(String type) {
    switch (type.toLowerCase()) {
      case 'expense_added':
        return Icons.receipt_long_outlined;
      case 'expense_updated':
        return Icons.edit_note_rounded;
      case 'expense_deleted':
        return Icons.delete_outline_rounded;
      case 'settlement_created':
      case 'settlement_completed':
        return Icons.payments_outlined;
      case 'member_added':
        return Icons.person_add_alt_1_rounded;
      case 'member_removed':
        return Icons.person_remove_alt_1_rounded;
      default:
        return Icons.notifications_none_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final normalizedType = notification.type.replaceAll('_', ' ').trim();

    final typeLabel = normalizedType.isEmpty
        ? 'Notification'
        : normalizedType[0].toUpperCase() + normalizedType.substring(1);

    return Material(
      color: notification.isRead ? Colors.white : const Color(0xFFF0F8F4),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: notification.isRead ? _border : const Color(0xFFC9E5D8),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: notification.isRead
                      ? const Color(0xFFF0F3F1)
                      : const Color(0xFFDCEFE5),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  _iconForType(notification.type),
                  color: notification.isRead ? _muted : _primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            typeLabel,
                            style: const TextStyle(
                              color: _text,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (!notification.isRead) ...[
                          const SizedBox(width: 8),
                          Container(
                            margin: const EdgeInsets.only(top: 5),
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: _primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 7),
                    Text(
                      notification.message,
                      style: TextStyle(
                        color: _text,
                        fontSize: 14,
                        height: 1.45,
                        fontWeight: notification.isRead
                            ? FontWeight.normal
                            : FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _formatDateTime(notification.createdAt),
                      style: const TextStyle(color: _muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(28),
      children: const [
        SizedBox(height: 100),
        Icon(
          Icons.notifications_none_rounded,
          size: 58,
          color: Color(0xFF176B55),
        ),
        SizedBox(height: 20),
        Text(
          'No notifications yet',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF172B25),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Updates about expenses, settlements, and group activity will appear here.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF75817C), height: 1.5),
        ),
      ],
    );
  }
}
