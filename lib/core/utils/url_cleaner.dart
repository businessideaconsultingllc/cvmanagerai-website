import 'url_cleaner_stub.dart' if (dart.library.html) 'url_cleaner_web.dart'
    as impl;

class UrlCleaner {
  /// Cleans OAuth parameters (code, access_token) from the browser URL.
  /// Safe to call on all platforms (no-op on mobile).
  static void clean() {
    impl.cleanUrlParams();
  }
}
