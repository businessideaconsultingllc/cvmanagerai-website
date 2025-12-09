import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/subscription_repository.dart';
import '../domain/subscription_enums.dart';

/// Provider to check if current user is premium
final isPremiumProvider = FutureProvider<bool>((ref) async {
  final userId = ref.watch(authStateProvider).value?.session?.user.id;
  if (userId == null) return false;

  return ref.read(subscriptionRepositoryProvider).isPremiumUser(userId);
});

/// Provider to get current user's subscription tier
final userSubscriptionTierProvider =
    FutureProvider<SubscriptionTier>((ref) async {
  final userId = ref.watch(authStateProvider).value?.session?.user.id;
  if (userId == null) return SubscriptionTier.free;

  return ref.read(subscriptionRepositoryProvider).getUserTier(userId);
});

/// Provider to get full subscription details
final userSubscriptionProvider = FutureProvider((ref) async {
  final userId = ref.watch(authStateProvider).value?.session?.user.id;
  if (userId == null) return null;

  return ref.read(subscriptionRepositoryProvider).getUserSubscription(userId);
});

/// Provider to check if user can access premium features
final canAccessPremiumFeaturesProvider = FutureProvider<bool>((ref) async {
  return await ref.watch(isPremiumProvider.future);
});
