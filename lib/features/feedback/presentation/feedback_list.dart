import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'feedback_controller.dart';

class FeedbackList extends ConsumerWidget {
  const FeedbackList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedbackAsync = ref.watch(feedbackControllerProvider);

    return feedbackAsync.when(
      data: (feedbackList) {
        if (feedbackList.isEmpty) {
          return const Center(child: Text('No feedback yet'));
        }
        return ListView.builder(
          itemCount: feedbackList.length,
          itemBuilder: (context, index) {
            final feedback = feedbackList[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: feedback.isRead ? Colors.grey : Colors.blue,
                  child: Icon(
                    Icons.feedback,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                title: Text(
                  feedback.message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight:
                        feedback.isRead ? FontWeight.normal : FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'From: ${feedback.profileName ?? feedback.userEmail ?? "Anonymous"}',
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                    if (feedback.rating != null)
                      Row(
                        children: List.generate(5, (i) {
                          return Icon(
                            i < feedback.rating!
                                ? Icons.star
                                : Icons.star_border,
                            size: 14,
                            color: Colors.amber,
                          );
                        }),
                      ),
                    Text(
                      DateFormat('MMM d, h:mm a').format(feedback.createdAt),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                trailing: !feedback.isRead
                    ? IconButton(
                        icon: const Icon(Icons.check_circle_outline),
                        onPressed: () {
                          ref
                              .read(feedbackControllerProvider.notifier)
                              .markAsRead(feedback.id);
                        },
                      )
                    : const Icon(Icons.check, color: Colors.green),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}
