// Bluetooth roll printing for report exports. The io version uses
// bluetooth_print_plus; web gets the stub so that code stays out of web
// builds (same pattern as helpers/clean_up_url/).
export 'report_export_bluetooth_stub.dart'
    if (dart.library.io) 'report_export_bluetooth_io.dart';
