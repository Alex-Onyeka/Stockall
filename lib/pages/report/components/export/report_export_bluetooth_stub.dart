// Web: no Bluetooth printing (the roll goes through the browser print
// dialog instead).
import 'dart:typed_data';

import 'package:flutter/widgets.dart';

Future<bool> reportPrintBluetooth(
  BuildContext context,
  List<Uint8List> chunks, {
  required VoidCallback beforeUi,
}) async {
  return false;
}
