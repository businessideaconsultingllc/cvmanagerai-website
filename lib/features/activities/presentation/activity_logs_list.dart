import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'activity_controller.dart';

class ActivityLogsList extends ConsumerWidget {
  const ActivityLogsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activitiesAsync = ref.watch(activityControllerProvider);

    return activitiesAsync.when(
      data: (activities) {
        if (activities.isEmpty) {
          return const Center(child: Text('No activity logs found'));
        }
        return ListView.separated(
          itemCount: activities.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final activity = activities[index];
            final email = activity.userEmail ?? 'Unknown';
            final name = activity.userName ?? 'User';
            final type = activity.activityType;
            final date = activity.createdAt;
            final details = activity.details;

            return ListTile(
              leading: Icon(_getIconForType(type)),
              title: Text('$name ($email)'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Action: $type'),
                  Text(DateFormat('MMM d, h:mm a').format(date.toLocal())),
                  if (details != null && details.isNotEmpty)
                    Text(
                      'Details: $details',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                ],
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'generate_cv':
        return Icons.description;
      case 'optimize_cv':
        return Icons.auto_fix_high;
      case 'tailor_cv':
        return Icons.content_cut;
      default:
        return Icons.history;
    }
  }
}
