import 'dart:html' as html;

/// Web implementation of URL cleaning logic.
void cleanUrlParams() {
  final uri = Uri.parse(html.window.location.href);
  if (uri.queryParameters.containsKey('code') ||
      uri.queryParameters.containsKey('access_token')) {
    final newUri = uri.replace(queryParameters: {});
    html.window.history.replaceState(null, '', newUri.toString());
  }
}
