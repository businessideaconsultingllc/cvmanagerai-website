import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/profile_repository.dart';

final profileProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final authState = ref.watch(authStateProvider);
  final user = authState.valueOrNull?.session?.user;

  if (user == null) return null;

  final profileRepo = ref.watch(profileRepositoryProvider);
  return await profileRepo.getProfile(user.id);
});

class ProfileController extends StateNotifier<AsyncValue<void>> {
  final ProfileRepository _repository;
  final Ref _ref;

  ProfileController(this._repository, this._ref)
      : super(const AsyncValue.data(null));

  Future<void> updateProfile({
    required String firstName,
    required String lastName,
    required String phone,
    required String address,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = _ref.read(authRepositoryProvider).currentUser;
      if (user == null) throw Exception('User not logged in');

      await _repository.updateProfile(
        userId: user.id,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        address: address,
      );

      // Invalidate the profile provider to refresh data
      _ref.invalidate(profileProvider);

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final profileControllerProvider =
    StateNotifierProvider<ProfileController, AsyncValue<void>>((ref) {
  return ProfileController(ref.watch(profileRepositoryProvider), ref);
});
