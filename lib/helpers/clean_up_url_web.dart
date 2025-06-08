// ignore: avoid_web_libraries_in_flutter
// import 'package:web/web.dart' as web;

// /// Removes the query parameters from the current URL (used on Flutter Web).
// void cleanUpUrl(String link) {
//   final cleanPath = web.window.location.pathname;

//   // This updates the browser history without reloading the page
//   // web.window.open(link, '_blank');
//   web.window.history.replaceState(null, '', cleanPath);
// }

import 'package:web/web.dart' as web;

/// Removes query parameters and fragments from the current URL (used on Flutter Web),
/// while keeping the path and domain intact.
void cleanUpUrl() {
  final origin =
      web
          .window
          .location
          .origin; // e.g. https://yourdomain.com
  final pathname =
      web.window.location.pathname; // e.g. /reset-password

  // Rebuild clean URL
  final cleanUrl = '$origin$pathname';

  // Replace current URL in browser without reloading
  web.window.history.replaceState(null, '', cleanUrl);
}
