// ignore: avoid_web_libraries_in_flutter
import 'package:web/web.dart' as web;

/// Removes the query parameters from the current URL (used on Flutter Web).
void cleanUpUrl() {
  final cleanPath = web.window.location.pathname;

  // This updates the browser history without reloading the page
  // web.window.open(link, '_blank');
  web.window.history.replaceState(null, '', cleanPath);
}

// // Used only on web
// void cleanUpUrl() {
//   web.window.history.replaceState(null, '', '/');
// }

void performRestart() {
  web.window.location.reload();
}
