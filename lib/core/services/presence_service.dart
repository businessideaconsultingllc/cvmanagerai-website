import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final presenceServiceProvider = Provider<PresenceService>((ref) {
  return PresenceService();
});

/// Service to track user presence and update last_seen timestamp
class PresenceService {
  Timer? _heartbeatTimer;
  final SupabaseClient _client = Supabase.instance.client;

  /// Start tracking user presence
  /// Updates last_seen every 2 minutes while app is active
  void startTracking() {
    // Stop any existing timer
    stopTracking();

    // Update immediately
    _updatePresence();

    // Then update every 2 minutes
    _heartbeatTimer = Timer.periodic(
      const Duration(minutes: 2),
      (_) => _updatePresence(),
    );
  }

  /// Stop tracking user presence
  void stopTracking() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  /// Update the user's last_seen timestamp in the database
  Future<void> _updatePresence() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return;

      await _client.from('profiles').update({
        'last_seen': DateTime.now().toIso8601String(),
      }).eq('id', userId);
    } catch (e) {
      // Silently fail - don't interrupt user experience
      // In production, you might want to log this
    }
  }

  /// Manually update presence (useful for important actions)
  Future<void> ping() async {
    await _updatePresence();
  }

  /// Dispose resources
  void dispose() {
    stopTracking();
  }
}
