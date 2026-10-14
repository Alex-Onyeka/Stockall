import 'package:file_picker/file_picker.dart';
import 'package:stockall/bulk_upload/spreadsheet_picker.dart';

/// Opens the native file chooser (Windows, macOS, Linux,
/// Android, iOS). Returns null if the user cancels.
Future<PickedSpreadsheet?> pickSpreadsheetFile() async {
  final picked = await FilePicker.pickFiles(
    type: FileType.custom,
    allowedExtensions: const ['xlsx', 'csv'],
    withData: true,
  );
  if (picked == null || picked.files.isEmpty) return null;
  final file = picked.files.first;
  return PickedSpreadsheet(name: file.name, bytes: file.bytes);
}

