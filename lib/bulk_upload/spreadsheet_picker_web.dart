import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:stockall/bulk_upload/spreadsheet_picker.dart';
import 'package:web/web.dart' as web;

/// Opens the browser's file chooser.
///
/// The hidden `<input type="file">` is added to the page and clicked
/// synchronously (inside the user's tap, which browsers require), and
/// is kept in the DOM until the user picks a file or cancels. Removing
/// it straight after `click()` makes Safari and mobile browsers drop
/// the dialog.
///
/// Returns null if the user cancels.
Future<PickedSpreadsheet?> pickSpreadsheetFile() {
  final completer = Completer<PickedSpreadsheet?>();

  final input =
      web.HTMLInputElement()
        ..type = 'file'
        ..multiple = false
        ..accept =
            '.xlsx,.csv,'
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet,'
            'text/csv,application/csv,text/comma-separated-values'
        ..style.display = 'none';

  void finish(PickedSpreadsheet? value) {
    input.remove();
    if (!completer.isCompleted) completer.complete(value);
  }

  input.addEventListener(
    'change',
    ((web.Event _) {
      final file = input.files?.item(0);
      if (file == null) {
        finish(null);
        return;
      }
      file
          .arrayBuffer()
          .toDart
          .then((buffer) {
            finish(
              PickedSpreadsheet(
                name: file.name,
                bytes: buffer.toDart.asUint8List(),
              ),
            );
          })
          .catchError((Object e) {
            input.remove();
            if (!completer.isCompleted) {
              completer.completeError(e);
            }
          });
    }).toJS,
  );

  input.addEventListener(
    'cancel',
    ((web.Event _) => finish(null)).toJS,
  );

  web.document.body!.append(input);
  input.click();

  return completer.future;
}

