import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/admin_repository.dart';
import '../domain/admin_user_model.dart';

// Provider to check if current user is admin
final isAdminProvider = FutureProvider<bool>((ref) async {
  final adminRepo = ref.watch(adminRepositoryProvider);
  return await adminRepo.isCurrentUserAdmin();
});

// Provider to get all users
final allUsersProvider = FutureProvider<List<AdminUserModel>>((ref) async {
  final adminRepo = ref.watch(adminRepositoryProvider);
  return await adminRepo.getAllUsers();
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

      // Refresh the users list
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

      // Refresh the users list
      _ref.invalidate(allUsersProvider);

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

      // Refresh the users list to update credit balances
      _ref.invalidate(allUsersProvider);

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
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
