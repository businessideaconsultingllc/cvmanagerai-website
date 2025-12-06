import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/presence_service.dart';

/// Widget that manages user presence tracking based on app lifecycle
class AppLifecycleObserver extends ConsumerStatefulWidget {
  final Widget child;

  const AppLifecycleObserver({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<AppLifecycleObserver> createState() =>
      _AppLifecycleObserverState();
}

class _AppLifecycleObserverState extends ConsumerState<AppLifecycleObserver>
    with WidgetsBindingObserver {
  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Start tracking if user is already logged in
    if (_supabase.auth.currentUser != null) {
      ref.read(presenceServiceProvider).startTracking();
    }

    // Listen to auth state changes
    _supabase.auth.onAuthStateChange.listen((data) async {
      final session = data.session;
      if (session != null) {
        // User logged in - start tracking
        ref.read(presenceServiceProvider).startTracking();
      } else {
        // User logged out - stop tracking (await to ensure DB update completes)
        await ref.read(presenceServiceProvider).stopTracking();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    ref.read(presenceServiceProvider).stopTracking();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Update presence when app becomes active
    if (state == AppLifecycleState.resumed &&
        _supabase.auth.currentUser != null) {
      ref.read(presenceServiceProvider).ping();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
