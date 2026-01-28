import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/services.dart';
import 'admin_controller.dart';
import '../domain/admin_notification_model.dart';
import '../../../core/widgets/app_navigation_bar.dart';
import '../../activities/presentation/activity_logs_list.dart';
import '../../feedback/presentation/feedback_list.dart';
import 'widgets/online_users_list.dart';
import '../../activities/data/activity_repository.dart';
import '../../activities/presentation/activity_controller.dart';

class AdminPanelScreen extends ConsumerStatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  ConsumerState<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends ConsumerState<AdminPanelScreen> {
  late FocusNode _focusNode;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Panel'),
          centerTitle: true,
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Dashboard'),
              Tab(text: 'Online'),
              Tab(text: 'Activities'),
              Tab(text: 'Feedback'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                ref.invalidate(systemStatsProvider);
                ref.invalidate(allUsersProvider);
                ref.invalidate(onlineUsersProvider);
                // Also invalidate activities and feedback if possible, but they are in other controllers
                // We can't easily invalidate them here without reading their providers or exposing a refresh method logic
                // For now, these main ones are enough. The individual tabs can pull to refresh if we add that later.
              },
            ),
          ],
        ),
        drawer: const AppNavigationBar(currentRoute: '/admin'),
        body: TabBarView(
          children: [
            _buildDashboard(context),
            const OnlineUsersList(),
            const ActivityLogsList(),
            const FeedbackList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard(BuildContext context) {
    final theme = Theme.of(context);
    final statsAsync = ref.watch(systemStatsProvider);
    final notificationsAsync = ref.watch(adminNotificationsProvider);

    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent || event is KeyRepeatEvent) {
          final double scrollAmount = 100.0;
          if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                _scrollController.offset + scrollAmount,
                duration: const Duration(milliseconds: 100),
                curve: Curves.easeOut,
              );
              return KeyEventResult.handled;
            }
          } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                _scrollController.offset - scrollAmount,
                duration: const Duration(milliseconds: 100),
                curve: Curves.easeOut,
              );
              return KeyEventResult.handled;
            }
          }
        }
        return KeyEventResult.ignored;
      },
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Text(
              'Admin Dashboard',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ).animate().fadeIn().slideX(),
            const SizedBox(height: 8),
            Text(
              'Complete system and user management control',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 32),

            // Statistics Section
            Text(
              'System Overview',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ).animate().fadeIn(delay: 150.ms),
            const SizedBox(height: 16),
            statsAsync.when(
              data: (stats) => Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: 'Total Users',
                          value: '${stats.totalUsers}',
                          subtitle: '${stats.newUsers7d} new (7d)',
                          icon: Icons.people,
                          color: Colors.blue,
                        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _StatCard(
                          title: 'Total CVs',
                          value: '${stats.totalCvs}',
                          subtitle: 'All time',
                          icon: Icons.description,
                          color: Colors.green,
                        ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: 'Cover Letters',
                          value: '${stats.totalCoverLetters}',
                          subtitle: 'All time',
                          icon: Icons.article,
                          color: Colors.orange,
                        ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _StatCard(
                          title: 'Total Credits',
                          value: '${stats.totalCredits}',
                          subtitle: 'Platform total',
                          icon: Icons.bolt,
                          color: Colors.purple,
                        ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),
                      ),
                    ],
                  ),
                ],
              ),
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),

            const SizedBox(height: 32),

            // Feature Usage Section
            Text(
              'Feature Usage Analytics',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ).animate().fadeIn(delay: 550.ms),
            const SizedBox(height: 16),
            ref.watch(featureUsageProvider).when(
                  data: (usage) {
                    if (usage.isEmpty) {
                      return const Center(
                          child: Text('No feature usage data yet.'));
                    }
                    return Column(
                      children: usage.entries.map((entry) {
                        final totalUsage =
                            usage.values.fold(0, (a, b) => a + b);
                        final ratio =
                            totalUsage > 0 ? entry.value / totalUsage : 0.0;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                      entry.key
                                          .replaceAll('_', ' ')
                                          .toUpperCase(),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12)),
                                  Text('${entry.value} times',
                                      style: const TextStyle(fontSize: 12)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: ratio,
                                  minHeight: 8,
                                  backgroundColor: theme.colorScheme.primary
                                      .withOpacity(0.1),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('Error loading usage: $e'),
                ),

            const SizedBox(height: 32),

            // Management
            Text(
              'Management',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ).animate().fadeIn(delay: 550.ms),
            const SizedBox(height: 16),

            _ActionButton(
              title: 'User Management',
              subtitle: 'View, edit, suspend or delete users',
              icon: Icons.manage_accounts,
              color: theme.colorScheme.primary,
              onTap: () => context.push('/admin/users'),
            ).animate().fadeIn(delay: 600.ms).slideX(),

            const SizedBox(height: 32),

            // Notifications Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Activity',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (notificationsAsync.hasValue &&
                    notificationsAsync.value!.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      // Mark all as read feature could go here
                    },
                    child: const Text('View All'),
                  ),
              ],
            ).animate().fadeIn(delay: 700.ms),
            const SizedBox(height: 16),

            notificationsAsync.when(
              data: (notifications) {
                if (notifications.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.dividerColor.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'No recent activity',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  );
                }

                return Column(
                  children: notifications.take(5).map((notification) {
                    return _NotificationItem(
                      notification: notification,
                      onTap: () {
                        ref
                            .read(adminControllerProvider.notifier)
                            .markNotificationAsRead(notification.id);
                      },
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends ConsumerWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 12),
          Text(value, style: theme.textTheme.displaySmall),
          if (title == 'Activities') ...[
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  try {
                    await ref.read(activityRepositoryProvider).logActivity(
                      activityType: 'test_log',
                      details: {'notes': 'Manual log from Admin Panel'},
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Test activity logged!')),
                      );
                    }
                    ref
                        .read(activityControllerProvider.notifier)
                        .loadActivities();
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.bug_report, size: 16),
                label: const Text('Trigger Test Log'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color.withOpacity(0.1),
                  foregroundColor: color,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          ],
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final AdminNotification notification;
  final VoidCallback onTap;

  const _NotificationItem({
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: notification.isRead
              ? theme.dividerColor.withValues(alpha: 0.1)
              : theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor:
              _getColorForType(notification.type).withValues(alpha: 0.1),
          child: Icon(
            _getIconForType(notification.type),
            color: _getColorForType(notification.type),
            size: 20,
          ),
        ),
        title: Text(
          notification.message,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight:
                notification.isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Text(
          _formatTime(notification.createdAt),
          style: theme.textTheme.bodySmall,
        ),
        trailing: notification.isRead
            ? null
            : Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'new_user':
        return Icons.person_add;
      default:
        return Icons.notifications;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'new_user':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${time.day}/${time.month}';
  }
}

class _ActionButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.1),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
