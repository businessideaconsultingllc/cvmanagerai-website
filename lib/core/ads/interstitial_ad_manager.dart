import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_helper.dart';

/// Manages interstitial ads that appear between screens/actions
class InterstitialAdManager {
  static InterstitialAd? _interstitialAd;
  static bool _isLoaded = false;

  /// Load an interstitial ad
  static void loadAd() {
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('InterstitialAd loaded successfully');
          _interstitialAd = ad;
          _isLoaded = true;

          // Set up event callbacks
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {
              debugPrint('InterstitialAd showed full screen');
            },
            onAdDismissedFullScreenContent: (ad) {
              debugPrint('InterstitialAd dismissed');
              ad.dispose();
              loadAd(); // Preload next ad
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              debugPrint('InterstitialAd failed to show: $error');
              ad.dispose();
              loadAd(); // Try to load another
            },
          );
        },
        onAdFailedToLoad: (error) {
          debugPrint('InterstitialAd failed to load: $error');
          _isLoaded = false;
        },
      ),
    );
  }

  /// Show the interstitial ad if loaded
  static void showAd() {
    if (_isLoaded && _interstitialAd != null) {
      _interstitialAd!.show();
      _isLoaded = false; // Mark as shown
    } else {
      debugPrint('InterstitialAd not ready to show yet');
    }
  }

  /// Dispose of the ad
  static void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isLoaded = false;
  }
}
