class StripeConstants {
  // 🔑 STRIPE PUBLISHABLE KEYS (Safe to expose in client)
  // Get these from: https://dashboard.stripe.com/apikeys

  // Test Keys (for development)
  static const String testPublishableKey =
      'pk_test_51OxTPzHsFA1k3qUMlCvCP4vpn555q44dtIcZ9HIVgTsT44zH3p5KgVsplquYTedYeX8KZ5A2aAwIPfXaKHl7i62900DLI3Y8fC';

  // Production Keys (for live app)
  static const String livePublishableKey =
      'pk_live_51OxTPzHsFA1k3qUMqD2IzhGgA6bStHo9D33aSzC0Dg6NcP0J3WX1UfzMFsFZVr5EeZCotEUmFxaF7UqPtBwh8X1P00sLPCk49Q';

  // ⚠️ SECRET KEYS REMOVED FOR SECURITY
  // Secret keys (sk_test_... and sk_live_...) should NEVER be in client code
  // They are only used in Supabase Edge Functions (server-side)
  // Store them as Supabase environment variables instead

  // Use test keys in development, live keys in production
  static const bool useTestMode = false; // Set to false for production

  static String get publishableKey =>
      useTestMode ? testPublishableKey : livePublishableKey;

  // 💰 PRODUCT CONFIGURATION
  static const String credits25PriceId = 'price_1ScOWwHsFA1k3qUMLLTXEl1a';

  // Credit packages (for future expansion)
  static const Map<String, CreditPackage> packages = {
    'starter': CreditPackage(
      credits: 25,
      price: 5.00,
      priceId: credits25PriceId,
      name: 'Starter Pack',
    ),
  };

  // Supabase Edge Function URL for creating checkout sessions
  // This will handle the secret key server-side
  static const String checkoutFunctionUrl =
      'https://https://gjyikixqeqklbdjakmqu.supabase.co/functions/v1/create-checkout-session';

  // Payment Success/Cancel URLs (redirect to app)
  static const String successUrl =
      'https://cvmanagerai.com/app/#/?payment=success';
  static const String cancelUrl =
      'https://cvmanagerai.com/app/#/?payment=cancel';
}

class CreditPackage {
  final int credits;
  final double price;
  final String priceId;
  final String name;

  const CreditPackage({
    required this.credits,
    required this.price,
    required this.priceId,
    required this.name,
  });

  String get displayPrice => '\$${price.toStringAsFixed(2)}';
  String get description => '$credits credits for $displayPrice';
}
