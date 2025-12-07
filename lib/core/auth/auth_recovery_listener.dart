import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

/// Listens for PASSWORD_RECOVERY auth events and navigates to reset password screen
class AuthRecoveryListener extends ConsumerStatefulWidget {
  final Widget child;

  const AuthRecoveryListener({required this.child, super.key});

  @override
  ConsumerState<AuthRecoveryListener> createState() =>
      _AuthRecoveryListenerState();
}

class _AuthRecoveryListenerState extends ConsumerState<AuthRecoveryListener> {
  @override
  void initState() {
    super.initState();

    // Listen for auth state changes
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;

      // When PASSWORD_RECOVERY event is detected, navigate to reset password screen
      if (event == AuthChangeEvent.passwordRecovery) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && context.mounted) {
            context.go('/reset-password');
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
