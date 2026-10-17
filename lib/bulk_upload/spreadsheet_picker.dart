import 'dart:typed_data';

export 'spreadsheet_picker_io.dart'
    if (dart.library.js_interop) 'spreadsheet_picker_web.dart';

/// A spreadsheet (.xlsx / .csv) file chosen by the user.
class PickedSpreadsheet {
  const PickedSpreadsheet({
    required this.name,
    required this.bytes,
  });

  final String name;
  final Uint8List? bytes;
}

