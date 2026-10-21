import 'dart:typed_data';
import 'package:flutter/material.dart';

Future<bool> sendReceiptToPrinter(
  Uint8List receiptBytes,
) async {
  return true;
}

Future<bool> checkPrint({
  required BuildContext context,
  required Uint8List receiptBytes,
}) async {
  return true;
}

Future<bool> printerSelectionDialog({
  required BuildContext context,
  String? title,
  String? message,
}) async {
  return false;
}
