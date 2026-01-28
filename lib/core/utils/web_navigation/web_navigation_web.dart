import 'dart:html' as html;

void hardReload(String url) {
  // Force browser to load the new URL, clearing current state
  html.window.location.href = url;
}

void cleanUrl() {
  // Remove query parameters and fragments to clean the URL
  // This prevents 'type=recovery' from sticking around and confusing the router
  // Remove query parameters and fragments to clean the URL
  // This prevents 'type=recovery' from sticking around and confusing the router

  // We want to keep the hash path if it exists, but strict cleaning is safer for now.
  // Actually, for Flutter Hash routing, we need to preserve the hash but remove params AFTER the hash?
  // Or just params?
  // Let's just strip 'type=recovery' and 'code'.

  // Safer approach: Use replaceState to current path without search/hash if they contain recovery params
  // But Flutter manages the hash.

  // Simplest for this issue:
  // If we are at .../app/#/reset-password?type=recovery... or similar
  // We want .../app/#/reset-password

  // Let's interpret the current hash.
  final hash =
      html.window.location.hash; // e.g. #/reset-password?type=recovery...
  if (hash.contains('?')) {
    final cleanHash = hash.split('?')[0];
    html.window.history
        .replaceState(null, '', html.window.location.pathname! + cleanHash);
  } else {
    // Check search params (before hash)
    if (html.window.location.search!.isNotEmpty) {
      html.window.history.replaceState(
          null, '', html.window.location.pathname! + html.window.location.hash);
    }
  }
}
