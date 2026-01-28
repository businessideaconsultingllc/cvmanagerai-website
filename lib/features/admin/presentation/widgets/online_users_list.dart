import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../admin_controller.dart';
// import '../../domain/admin_user_model.dart';

class OnlineUsersList extends ConsumerWidget {
  const OnlineUsersList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onlineUsersAsync = ref.watch(onlineUsersProvider);

    return onlineUsersAsync.when(
      data: (users) {
        if (users.isEmpty) {
          return const Center(child: Text('No users online right now'));
        }
        return ListView.separated(
          itemCount: users.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final user = users[index];
            final name = user.displayName; // Use the model's getter
            final email = user.email;

            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.green.withValues(alpha: 0.1),
                child: const Icon(Icons.circle, color: Colors.green, size: 12),
              ),
              title: Text(name),
              subtitle: Text(email),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon:
                        const Icon(Icons.mail_outlined, color: Colors.blueGrey),
                    tooltip: 'Request Feedback',
                    onPressed: () => _sendFeedbackRequest(context, email, name),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
              onTap: () {
                // Navigate to user details (if applicable) or show sheet
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Future<void> _sendFeedbackRequest(
      BuildContext context, String email, String name) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
      query: _encodeQueryParameters(<String, String>{
        'subject': 'We value your feedback - CV Manager AI',
        'body':
            'Hi $name,\n\nWe sort of noticed you\'ve been using CV Manager AI. We would love to hear your thoughts!\n\nBest,\nThe Team',
      }),
    );

    try {
      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open email client')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error launching email: $e')),
        );
      }
    }
  }

  String? _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }
}
