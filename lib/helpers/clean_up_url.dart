// This tells Dart to choose the right file automatically
export 'clean_up_url_stub.dart'
    if (dart.library.js) 'clean_up_url_web.dart';
