import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/admin_repository.dart';
import '../domain/admin_user_model.dart';
import '../domain/system_stats_model.dart';
import '../domain/admin_notification_model.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../activities/data/activity_repository.dart';

final featureUsageProvider = FutureProvider<Map<String, int>>((ref) async {
  final repository = ref.watch(activityRepositoryProvider);
  return repository.getFeatureUsage();
});

// Provider to check if current user is admin
final isAdminProvider = FutureProvider<bool>((ref) async {
  // Watch auth state so this provider invalidates when user logs in/out
  ref.watch(authStateProvider);
  final adminRepo = ref.watch(adminRepositoryProvider);
  return await adminRepo.isCurrentUserAdmin();
});

// Provider to get all users
final allUsersProvider = FutureProvider<List<AdminUserModel>>((ref) async {
  final adminRepo = ref.watch(adminRepositoryProvider);
  return await adminRepo.getAllUsers();
});

// Provider for global system statistics
final systemStatsProvider = FutureProvider<SystemStats>((ref) async {
  final adminRepo = ref.watch(adminRepositoryProvider);
  return await adminRepo.getSystemStats();
});

// Stream provider for admin notifications
final adminNotificationsProvider =
    StreamProvider<List<AdminNotification>>((ref) {
  final adminRepo = ref.watch(adminRepositoryProvider);
  return adminRepo.watchNotifications();
});

// State notifier for admin operations
class AdminController extends StateNotifier<AsyncValue<void>> {
  final AdminRepository _repository;
  final Ref _ref;

  AdminController(this._repository, this._ref)
      : super(const AsyncValue.data(null));

  Future<void> updateUser(AdminUserModel user) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateUser(user);
      _ref.invalidate(allUsersProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> toggleUserSuspension(String userId, bool isSuspended) async {
    state = const AsyncValue.loading();
    try {
      await _repository.toggleUserSuspension(userId, isSuspended);
      _ref.invalidate(allUsersProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> toggleAdminStatus(String userId, bool isAdmin) async {
    state = const AsyncValue.loading();
    try {
      await _repository.toggleAdminStatus(userId, isAdmin);
      _ref.invalidate(allUsersProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteUser(String userId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteUser(userId);
      _ref.invalidate(allUsersProvider);
      _ref.invalidate(systemStatsProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> adjustCredits({
    required String userId,
    required int amount,
    required String reason,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repository.adjustUserCredits(
        userId: userId,
        amount: amount,
        reason: reason,
      );
      _ref.invalidate(allUsersProvider);
      _ref.invalidate(systemStatsProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _repository.markNotificationAsRead(notificationId);
    } catch (e) {
      // Don't set global error state for this minor action
      print('Error marking notification as read: $e');
    }
  }
}

final adminControllerProvider =
    StateNotifierProvider<AdminController, AsyncValue<void>>((ref) {
  return AdminController(ref.watch(adminRepositoryProvider), ref);
});

// Provider to get count of online users
final onlineUsersCountProvider = FutureProvider<int>((ref) async {
  final adminRepo = ref.watch(adminRepositoryProvider);
  return await adminRepo.getOnlineUsersCount();
});

// Provider to get list of online users
final onlineUsersProvider = FutureProvider<List<AdminUserModel>>((ref) async {
  final adminRepo = ref.watch(adminRepositoryProvider);
  return await adminRepo.getOnlineUsers();
});
