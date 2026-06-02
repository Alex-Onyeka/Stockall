export 'receipt_printing_import_stub.dart'
    if (dart.library.io) 'receipt_printing_import_desktop.dart'
    if (dart.library.js) 'receipt_printing_import_web.dart';
