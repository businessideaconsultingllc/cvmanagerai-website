import 'package:flutter/foundation.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/stripe_constants.dart';

/// Service to handle Stripe payments for credit purchases
/// Supports both web (redirect to Checkout) and mobile (Payment Sheet)
class StripePaymentService {
  /// Initialize Stripe with publishable key
  static Future<void> initialize() async {
    if (kIsWeb) {
      // Web doesn't need Stripe.instance initialization
      return;
    }

    // Mobile: Initialize Stripe
    Stripe.publishableKey = StripeConstants.publishableKey;
    await Stripe.instance.applySettings();
  }

  /// Create Stripe Checkout Session via Supabase Edge Function
  /// This keeps the secret key server-side for security
  static Future<Map<String, dynamic>?> createCheckoutSession({
    required String userId,
    required String userEmail,
    required int credits,
    required double amount,
    String? priceId,
  }) async {
    try {
      // Call Supabase Edge Function to create checkout session
      // The Edge Function has the secret key stored securely
      final response = await Supabase.instance.client.functions.invoke(
        'create-checkout-session',
        body: {
          'userId': userId,
          'userEmail': userEmail,
          'credits': credits,
          'amount': amount,
          if (priceId != null) 'priceId': priceId,
        },
      );

      if (response.status == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      } else {
        debugPrint('Error creating checkout session: ${response.data}');
        return null;
      }
    } catch (e) {
      debugPrint('Error in createCheckoutSession: $e');
      return null;
    }
  }

  /// Launch web checkout (redirect to Stripe Checkout page)
  static Future<bool> launchWebCheckout(String checkoutUrl) async {
    try {
      final uri = Uri.parse(checkoutUrl);
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      return false;
    } catch (e) {
      debugPrint('Error launching checkout: $e');
      return false;
    }
  }

  /// Complete payment flow - handles both web and mobile
  static Future<PaymentResult> purchaseCredits({
    required String userId,
    required String userEmail,
    required int credits,
    required double amount,
    String? priceId,
  }) async {
    try {
      // Step 1: Create Checkout Session
      final session = await createCheckoutSession(
        userId: userId,
        userEmail: userEmail,
        credits: credits,
        amount: amount,
        priceId: priceId,
      );

      if (session == null) {
        return PaymentResult.failure('Failed to create payment session');
      }

      final checkoutUrl = session['url'] as String;

      // Redirect to Stripe Checkout (works for both web and mobile)
      final launched = await launchWebCheckout(checkoutUrl);
      if (launched) {
        return PaymentResult.success('Redirecting to payment...');
      } else {
        return PaymentResult.failure('Could not open payment page');
      }
    } catch (e) {
      return PaymentResult.failure('Payment error: $e');
    }
  }
}

/// Payment result class
class PaymentResult {
  final bool success;
  final String message;

  PaymentResult.success(this.message) : success = true;
  PaymentResult.failure(this.message) : success = false;
}
