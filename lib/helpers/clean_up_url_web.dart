// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

// Used only on web
void cleanUpUrl() {
  html.window.history.replaceState(null, '', '/');
}
