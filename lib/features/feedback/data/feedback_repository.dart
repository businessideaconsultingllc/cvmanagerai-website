import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/user_feedback_model.dart';

final feedbackRepositoryProvider = Provider<FeedbackRepository>((ref) {
  return FeedbackRepository(Supabase.instance.client);
});

class FeedbackRepository {
  final SupabaseClient _client;

  FeedbackRepository(this._client);

  /// Submit feedback
  Future<void> submitFeedback({
    required String message,
    int? rating,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      // Depending on policy, userId might be required

      await _client.from('user_feedback').insert({
        'user_id': userId,
        'message': message,
        'rating': rating,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error submitting feedback: $e');
      rethrow;
    }
  }

  /// Get all feedback (Admin only)
  Future<List<UserFeedback>> getAllFeedback() async {
    try {
      // Standard join using the profiles table
      final response = await _client
          .from('user_feedback')
          .select('*, profiles(email, full_name)')
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => UserFeedback.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching feedback: $e');
      // If the join fails, try fetching without join as fallback
      try {
        final fallback = await _client
            .from('user_feedback')
            .select()
            .order('created_at', ascending: false);
        return (fallback as List)
            .map((json) => UserFeedback.fromJson(json as Map<String, dynamic>))
            .toList();
      } catch (innerE) {
        return [];
      }
    }
  }

  /// Mark feedback as read (Admin only)
  Future<void> markAsRead(String feedbackId) async {
    try {
      await _client
          .from('user_feedback')
          .update({'is_read': true}).eq('id', feedbackId);
    } catch (e) {
      rethrow;
    }
  }
}
