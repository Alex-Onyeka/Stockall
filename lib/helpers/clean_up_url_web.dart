// ignore: avoid_web_libraries_in_flutter
import 'package:web/web.dart' as web;

// Used only on web
void cleanUpUrl() {
  web.window.history.replaceState(null, '', '/');
}
