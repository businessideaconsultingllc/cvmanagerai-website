import 'web_navigation_stub.dart'
    if (dart.library.html) 'web_navigation_web.dart';

/// Forces a hard reload of the page to the specified URL on Web.
void forceWebReload(String url) => hardReload(url);

/// Removes query parameters from the browser URL on Web.
/// Used to clear 'type=recovery' so the router provides standard behavior.
void removeUrlParams() => cleanUrl();
