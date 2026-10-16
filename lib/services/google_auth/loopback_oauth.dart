// Picks the dart:io loopback implementation on desktop/mobile and a stub on web.
export 'loopback_oauth_stub.dart'
    if (dart.library.io) 'loopback_oauth_io.dart';
