import 'dart:html' as html;

/// Web implementation to clean OAuth params from URL
void cleanUrlParams() {
  try {
    final uri = Uri.base;
    // Check if we have OAuth params that need cleaning
    if (uri.queryParameters.containsKey('code') ||
        uri.queryParameters.containsKey('access_token')) {
      // Keep the path and fragment (hash), but remove query params
      // Supabase Google Auth redirect is usually: https://domain.com/app/?code=...#/
      // We want: https://domain.com/app/#/

      // Reconstruct URL without query parameters but keeping the fragment
      final cleanUrl = '${uri.origin}${uri.path}${uri.fragment}';

      // silently replace the URL in history
      html.window.history.replaceState(null, '', cleanUrl);
    }
  } catch (e) {
    // Ignore errors
  }
}
