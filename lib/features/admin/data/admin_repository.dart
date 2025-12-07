import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/admin_user_model.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository(Supabase.instance.client);
});

class AdminRepository {
  final SupabaseClient _client;

  AdminRepository(this._client);

  /// Check if the current user is an admin
  Future<bool> isCurrentUserAdmin() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return false;

      final response = await _client
          .from('profiles')
          .select('is_admin')
          .eq('id', userId)
          .single();

      return response['is_admin'] as bool? ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Get all users with their credit balances
  Future<List<AdminUserModel>> getAllUsers() async {
    try {
      // Use the custom function we created in Supabase
      final response =
          await _client.rpc('get_all_users_with_credits') as List<dynamic>;

      return response
          .map((json) => AdminUserModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Update user profile data
  Future<void> updateUser(AdminUserModel user) async {
    try {
      await _client.from('profiles').update({
        'full_name': user.fullName,
        'first_name': user.firstName,
        'last_name': user.lastName,
        'phone': user.phone,
        'address': user.address,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', user.id);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete a user and all their related data
  Future<void> deleteUser(String userId) async {
    try {
      // Note: You may need to handle cascading deletes in Supabase
      // or manually delete related records (CVs, cover letters, etc.)

      // Delete credit transactions
      await _client.from('credit_transactions').delete().eq('user_id', userId);

      // Delete CVs
      await _client.from('cvs').delete().eq('user_id', userId);

      // Delete cover letters
      await _client.from('cover_letters').delete().eq('user_id', userId);

      // Finally, delete the profile
      await _client.from('profiles').delete().eq('id', userId);
    } catch (e) {
      rethrow;
    }
  }

  /// Adjust user credits (add or subtract)
  Future<void> adjustUserCredits({
    required String userId,
    required int amount,
    required String reason,
  }) async {
    try {
      // Get current balance from profiles
      final profile = await _client
          .from('profiles')
          .select('credits_balance')
          .eq('id', userId)
          .single();

      final currentBalance = (profile['credits_balance'] as num?)?.toInt() ?? 0;
      final newBalance = currentBalance + amount;

      // Update balance in profiles
      await _client.from('profiles').update({
        'credits_balance': newBalance,
      }).eq('id', userId);

      // Log transaction
      await _client.from('credit_transactions').insert({
        'user_id': userId,
        'operation_type': 'admin_adjustment',
        'credits_used': -amount, // Negative if adding, positive if subtracting
        'balance_after': newBalance,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Get user's current credit balance
  Future<int> getUserCreditBalance(String userId) async {
    try {
      final response = await _client
          .from('profiles')
          .select('credits_balance')
          .eq('id', userId)
          .single();

      return (response['credits_balance'] as num?)?.toInt() ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Get count of users who are currently online (last_seen within 5 minutes)
  Future<int> getOnlineUsersCount() async {
    try {
      final fiveMinutesAgo =
          DateTime.now().subtract(const Duration(minutes: 5));

      final response = await _client
          .from('profiles')
          .select('id')
          .gte('last_seen', fiveMinutesAgo.toIso8601String());

      return (response as List).length;
    } catch (e) {
      return 0;
    }
  }
}
