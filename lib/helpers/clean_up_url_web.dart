// ignore: avoid_web_libraries_in_flutter
import 'package:web/web.dart' as web;

/// Removes the query parameters from the current URL (used on Flutter Web).
void cleanUpUrl() {
  final currentUrl = web.window.location;
  final pathOnly = currentUrl.pathname;

  // This updates the browser history without reloading the page
  web.window.history.replaceState(null, '', pathOnly);
}

// // Used only on web
// void cleanUpUrl() {
//   web.window.history.replaceState(null, '', '/');
// }
