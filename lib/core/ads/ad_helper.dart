import 'package:flutter/foundation.dart' show kIsWeb;

/// Helper class for managing ad unit IDs across different platforms
/// Web-safe implementation - returns empty strings on web
class AdHelper {
  // TODO: Before production, replace test IDs with your real AdMob ad unit IDs

  /// Banner ad unit ID
  /// Test ID is currently being used - replace with production ID from AdMob
  static String get bannerAdUnitId {
    if (kIsWeb) {
      return ''; // Web doesn't use AdMob
    }

    // For mobile platforms, return test ID
    // On Android: return Android test ID
    // On iOS: return iOS test ID
    // Since we can't use Platform.isAndroid on web, we'll use a single test ID
    return 'ca-app-pub-3940256099942544/6300978111'; // Android Test ID
    // TODO: Replace with production ID: 'ca-app-pub-XXXXXXXXXXXXXXXX/ZZZZZZZZZZ'
  }

  /// Interstitial ad unit ID
  /// Test ID is currently being used - replace with production ID from AdMob
  static String get interstitialAdUnitId {
    if (kIsWeb) {
      return ''; // Web doesn't use AdMob
    }

    return 'ca-app-pub-3940256099942544/1033173712'; // Android Test ID
    // TODO: Replace with production ID: 'ca-app-pub-XXXXXXXXXXXXXXXX/ZZZZZZZZZZ'
  }
}
