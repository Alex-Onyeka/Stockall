export 'printer_service_stub.dart'
    if (dart.library.io) 'printer_service_mobile.dart'
    if (dart.library.js) 'printer_service_web.dart';
