import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/subscription_enums.dart';
import '../domain/subscription_model.dart';

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  return SubscriptionRepository(Supabase.instance.client);
});

class SubscriptionRepository {
  final SupabaseClient _client;

  SubscriptionRepository(this._client);

  /// Check if user has premium access (credits > 0)
  Future<bool> isPremiumUser(String userId) async {
    try {
      final response = await _client
          .from('profiles')
          .select('credits_balance')
          .eq('id', userId)
          .single();

      final credits = response['credits_balance'] as int? ?? 0;
      return credits > 0; // Premium = has credits
    } catch (e) {
      return false; // Default to free if error
    }
  }

  /// Get user's subscription tier
  Future<SubscriptionTier> getUserTier(String userId) async {
    try {
      final response = await _client
          .from('profiles')
          .select('subscription_tier')
          .eq('id', userId)
          .single();

      return SubscriptionTier.fromString(
          response['subscription_tier'] as String? ?? 'free');
    } catch (e) {
      return SubscriptionTier.free; // Default to free if error
    }
  }

  /// Get user's full subscription details
  Future<SubscriptionModel?> getUserSubscription(String userId) async {
    try {
      final response = await _client
          .from('subscriptions')
          .select()
          .eq('user_id', userId)
          .eq('status', 'active')
          .maybeSingle();

      if (response == null) return null;
      return SubscriptionModel.fromMap(response);
    } catch (e) {
      return null;
    }
  }

  /// Get subscription tier from profile
  Future<Map<String, dynamic>?> getProfileSubscription(String userId) async {
    try {
      final response = await _client
          .from('profiles')
          .select(
              'subscription_tier, subscription_status, subscription_end_date, stripe_customer_id')
          .eq('id', userId)
          .single();

      return response;
    } catch (e) {
      return null;
    }
  }

  /// Purchase credits (one-time payment)
  Future<void> purchaseCredits({
    required String userId,
    required int creditAmount,
    required String paymentId,
    required double amountPaid,
  }) async {
    await _client.rpc('purchase_credits', params: {
      'p_user_id': userId,
      'p_credits_amount': creditAmount,
      'p_payment_id': paymentId,
      'p_amount_paid': amountPaid,
    });
  }

  /// Downgrade user to free tier
  Future<void> downgradeToFree(String userId) async {
    await _client.rpc('downgrade_to_free', params: {
      'p_user_id': userId,
    });
  }

  /// Update user's subscription tier manually
  Future<void> updateTier(String userId, String tier) async {
    await _client.from('profiles').update({
      'subscription_tier': tier,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', userId);
  }

  /// Create subscription record
  Future<void> createSubscription({
    required String userId,
    required String stripeSubscriptionId,
    required String stripeCustomerId,
    required DateTime periodEnd,
  }) async {
    await _client.from('subscriptions').insert({
      'user_id': userId,
      'stripe_subscription_id': stripeSubscriptionId,
      'stripe_customer_id': stripeCustomerId,
      'tier': 'premium',
      'status': 'active',
      'current_period_end': periodEnd.toIso8601String(),
    });
  }

  /// Update subscription status (for webhooks)
  Future<void> updateSubscriptionStatus({
    required String stripeSubscriptionId,
    required String status,
    DateTime? periodEnd,
  }) async {
    final updateData = <String, dynamic>{
      'status': status,
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (periodEnd != null) {
      updateData['current_period_end'] = periodEnd.toIso8601String();
    }

    await _client
        .from('subscriptions')
        .update(updateData)
        .eq('stripe_subscription_id', stripeSubscriptionId);
  }
}
