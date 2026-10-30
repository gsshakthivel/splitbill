import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:splitbill_frontend/features/auth/presentation/providers/auth_provider.dart';
import 'package:splitbill_frontend/features/notifications/presentation/providers/notification_provider.dart';
import 'package:splitbill_frontend/features/notifications/presentation/screens/notification_history_screen.dart';

import '../providers/home_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const Color _primary = Color(0xFF176B55);
  static const Color _background = Color(0xFFF6F8F7);
  static const Color _textPrimary = Color(0xFF172B25);
  static const Color _textSecondary = Color(0xFF75817C);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeNotifierProvider);
    final unreadCount = ref.watch(unreadNotificationCountProvider);

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 20,
        title: Row(
          children: [
            SizedBox(
              width: 38,
              height: 38,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/branding/app_icon.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(width: 11),
            const Text(
              'SplitBill',
              style: TextStyle(
                color: _textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.6,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Create Group',
            onPressed: () async {
              final result = await context.push('/create-group');
              if (result == true) {
                await ref.read(homeNotifierProvider.notifier).refreshGroups();
              }
            },
            icon: const Icon(Icons.add_rounded),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: _primary,
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            tooltip: 'Notifications',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const NotificationHistoryScreen(),
                ),
              );
            },
            icon: unreadCount.when(
              loading: () => const Icon(Icons.notifications_none_rounded),
              error: (_, _) => const Icon(Icons.notifications_none_rounded),
              data: (count) => Badge(
                isLabelVisible: count > 0,
                label: Text(count > 99 ? '99+' : '$count'),
                child: const Icon(Icons.notifications_none_rounded),
              ),
            ),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: _textPrimary,
            ),
          ),
          const SizedBox(width: 4),
          PopupMenuButton<String>(
            tooltip: 'Account',
            icon: const Icon(Icons.more_vert_rounded),
            color: Colors.white,
            onSelected: (value) {
              if (value == 'logout') {
                ref.read(authNotifierProvider.notifier).logout();
              } else if (value == 'refresh') {
                ref.read(homeNotifierProvider.notifier).refreshGroups();
              }
            },
            itemBuilder: (context) => [
              if (kIsWeb)
                const PopupMenuItem(
                  value: 'refresh',
                  child: ListTile(
                    leading: Icon(Icons.refresh_rounded),
                    title: Text('Refresh groups'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              const PopupMenuItem(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout_rounded),
                  title: Text('Log out'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        top: false,
        child: homeState.when(
          loading: () =>
              const Center(child: CircularProgressIndicator(color: _primary)),
          error: (error, stackTrace) => _ErrorState(
            message: error.toString(),
            onRetry: () =>
                ref.read(homeNotifierProvider.notifier).refreshGroups(),
          ),
          data: (groups) => RefreshIndicator(
            color: _primary,
            onRefresh: () =>
                ref.read(homeNotifierProvider.notifier).refreshGroups(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              children: [
                const Text(
                  'YOUR OVERVIEW',
                  style: TextStyle(
                    color: _textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.8,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your groups',
                  style: TextStyle(
                    color: _textPrimary,
                    fontSize: 29,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  groups.isEmpty
                      ? 'Start sharing expenses with your people.'
                      : '${groups.length} ${groups.length == 1 ? 'group' : 'groups'} to keep your expenses organized',
                  style: const TextStyle(
                    color: _textSecondary,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                if (groups.isNotEmpty) ...[
                  Row(
                    children: [
                      const Text(
                        'All groups',
                        style: TextStyle(
                          color: _textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${groups.length}',
                        style: const TextStyle(
                          color: _primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(groups.length, (index) {
                    final group = groups[index];
                    final colors = [
                      const Color(0xFFE2F3EA),
                      const Color(0xFFE8ECFF),
                      const Color(0xFFFFEEDB),
                      const Color(0xFFF6E5F2),
                    ];
                    final iconColors = [
                      const Color(0xFF176B55),
                      const Color(0xFF4E5FBF),
                      const Color(0xFFB56A1B),
                      const Color(0xFF9C4F8B),
                    ];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () => context.push('/groups/${group.id}'),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: const Color(0xFFE9EEEB),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: colors[index % colors.length],
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Icon(
                                    Icons.groups_rounded,
                                    color:
                                        iconColors[index % iconColors.length],
                                    size: 27,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        group.name,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: _textPrimary,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          height: 1.3,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        'Group ID: ${group.id}',
                                        style: const TextStyle(
                                          color: _textSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: Color(0xFF9AA7A1),
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ] else
                  const _EmptyGroupsState(),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: homeState.maybeWhen(
        data: (groups) => FloatingActionButton.extended(
          onPressed: () async {
            final result = await context.push('/create-group');
            if (result == true) {
              await ref.read(homeNotifierProvider.notifier).refreshGroups();
            }
          },
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          elevation: 3,
          icon: const Icon(Icons.add_rounded),
          label: const Text(
            'Create group',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        orElse: () => null,
      ),
    );
  }
}

class _EmptyGroupsState extends StatelessWidget {
  const _EmptyGroupsState();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE9EEEB)),
      ),
      child: Column(
        children: [
          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              color: const Color(0xFFE2F3EA),
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Icon(
              Icons.groups_rounded,
              color: Color(0xFF176B55),
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Bring your people together',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF172B25),
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create a group to start tracking shared expenses, splitting bills, and keeping everyone on the same page.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF75817C),
              fontSize: 14,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 22),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color: Color(0xFFB45353),
              size: 44,
            ),
            const SizedBox(height: 16),
            const Text(
              'Couldn’t load your groups',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF75817C), height: 1.5),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF176B55),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
