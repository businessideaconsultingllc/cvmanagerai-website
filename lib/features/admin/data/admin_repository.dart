import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/admin_user_model.dart';
import '../domain/system_stats_model.dart';
import '../domain/admin_notification_model.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository(Supabase.instance.client);
});

class AdminRepository {
  final SupabaseClient _client;

  AdminRepository(this._client);

  /// Check if the current user is an admin
  Future<bool> isCurrentUserAdmin() async {
    try {
      final user = _client.auth.currentUser;
      final userId = user?.id;
      final email = user?.email;

      // Emergency fallback for main admin
      // This ensures access even if RLS policies or DB queries fail on some devices
      if (email == 'ahmadkassem511@gmail.com') {
        return true;
      }

      if (userId == null) return false;

      final response = await _client
          .from('profiles')
          .select('is_admin')
          .eq('id', userId)
          .single();

      return response['is_admin'] as bool? ?? false;
    } catch (e) {
      print('Admin check failed: $e');
      return false;
    }
  }

  /// Get all users with their credit balances
  Future<List<AdminUserModel>> getAllUsers() async {
    try {
      // Use the custom function we created in Supabase
      // Note: We might need to update the RPC to include is_suspended
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

  /// Toggle user suspension status
  Future<void> toggleUserSuspension(String userId, bool isSuspended) async {
    try {
      await _client.from('profiles').update({
        'is_suspended': isSuspended,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);
    } catch (e) {
      rethrow;
    }
  }

  /// Toggle user admin status
  Future<void> toggleAdminStatus(String userId, bool isAdmin) async {
    try {
      // Prevent self-demotion if the user is the one performing the action
      final currentUserId = _client.auth.currentUser?.id;
      if (currentUserId == userId && !isAdmin) {
        throw Exception('You cannot revoke your own admin status');
      }

      await _client.from('profiles').update({
        'is_admin': isAdmin,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete a user and all their related data using Edge Function
  Future<void> deleteUser(String userId) async {
    try {
      await _client.functions.invoke(
        'delete-user-account',
        body: {'userId': userId},
        method: HttpMethod.post,
      );
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

  /// Get global system statistics
  Future<SystemStats> getSystemStats() async {
    try {
      final response = await _client.rpc('get_system_stats');
      return SystemStats.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      print('Error getting system stats: $e');
      return SystemStats.empty();
    }
  }

  /// Get recent admin notifications
  Future<List<AdminNotification>> getRecentNotifications(
      {int limit = 20}) async {
    try {
      final response = await _client
          .from('admin_notifications')
          .select()
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) =>
              AdminNotification.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting notifications: $e');
      return [];
    }
  }

  /// Mark notification as read
  Future<void> markNotificationAsRead(String id) async {
    try {
      await _client
          .from('admin_notifications')
          .update({'is_read': true}).eq('id', id);
    } catch (e) {
      rethrow;
    }
  }

  /// Stream of new notifications
  Stream<List<AdminNotification>> watchNotifications() {
    return _client
        .from('admin_notifications')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .limit(20)
        .map((data) =>
            data.map((json) => AdminNotification.fromJson(json)).toList());
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

  /// Get list of users who are currently online (last_seen within 5 minutes)
  Future<List<AdminUserModel>> getOnlineUsers() async {
    try {
      final fiveMinutesAgo =
          DateTime.now().subtract(const Duration(minutes: 5));

      final response = await _client
          .from('profiles')
          .select()
          .gte('last_seen', fiveMinutesAgo.toIso8601String())
          .order('last_seen', ascending: false);

      return (response as List)
          .map((json) => AdminUserModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting online users: $e');
      return [];
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
