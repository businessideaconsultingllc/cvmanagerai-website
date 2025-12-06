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
  /// Updates last_seen every 1 minute while app is active
  void startTracking() {
    // Cancel any existing timer
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;

    // Update immediately
    _updatePresence();

    // Update every 1 minute (reduced from 2 minutes for faster offline detection)
    _heartbeatTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _updatePresence(),
    );
  }

  /// Stop tracking user presence and mark user as offline
  Future<void> stopTracking() async {
    // Capture user ID BEFORE canceling timer or clearing session
    final userId = _client.auth.currentUser?.id;

    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;

    // Mark user as offline by setting last_seen to now minus 10 minutes
    await _markOffline(userId);
  }

  /// Mark user as offline by setting last_seen to past timestamp
  Future<void> _markOffline([String? userId]) async {
    try {
      // Use provided userId or get current one
      final uid = userId ?? _client.auth.currentUser?.id;

      if (uid != null) {
        print('DEBUG: Marking user $uid as offline'); // Debug logging
        // Set last_seen to now minus 10 minutes to ensure they show as offline
        final result = await _client.from('profiles').update({
          'last_seen': DateTime.now()
              .subtract(const Duration(minutes: 10))
              .toIso8601String(),
        }).eq('id', uid);
        print('DEBUG: Update result: $result'); // Debug logging
      } else {
        print('DEBUG: No userId available to mark offline'); // Debug logging
      }
    } catch (e) {
      print('DEBUG: Error marking offline: $e'); // Debug logging
    }
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
