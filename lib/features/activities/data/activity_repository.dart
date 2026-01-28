import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/user_activity_model.dart';

final activityRepositoryProvider = Provider<ActivityRepository>((ref) {
  return ActivityRepository(Supabase.instance.client);
});

class ActivityRepository {
  final SupabaseClient _client;

  ActivityRepository(this._client);

  /// Log a user activity
  Future<void> logActivity({
    required String activityType,
    Map<String, dynamic>? details,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return;

      await _client.from('user_activities').insert({
        'user_id': userId,
        'activity_type': activityType,
        'details': details,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error logging activity: $e');
    }
  }

  /// Get all activities (Admin only)
  Future<List<UserActivity>> getAllActivities() async {
    try {
      final response = await _client
          .from('user_activities')
          .select('*, profiles(email, full_name)')
          .order('created_at', ascending: false)
          .limit(100);

      return (response as List)
          .map((json) => UserActivity.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching activities: $e');
      // Fallback without join
      try {
        final fallback = await _client
            .from('user_activities')
            .select()
            .order('created_at', ascending: false)
            .limit(100);
        return (fallback as List)
            .map((json) => UserActivity.fromJson(json as Map<String, dynamic>))
            .toList();
      } catch (innerE) {
        return [];
      }
    }
  }

  /// Get feature usage counts (Admin only)
  Future<Map<String, int>> getFeatureUsage() async {
    try {
      final response =
          await _client.from('user_activities').select('activity_type');

      final usage = <String, int>{};
      for (final item in response as List) {
        final type = item['activity_type'] as String;
        usage[type] = (usage[type] ?? 0) + 1;
      }
      return usage;
    } catch (e) {
      print('Error getting feature usage: $e');
      return {};
    }
  }
}
