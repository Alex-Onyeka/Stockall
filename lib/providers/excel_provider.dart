import 'dart:io';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';
import 'package:universal_html/html.dart' as html;

class ExcelProvider with ChangeNotifier {
  static final ExcelProvider _instance =
      ExcelProvider._internal();
  factory ExcelProvider() => _instance;
  ExcelProvider._internal();

  void styleHeader({
    required List items,
    required Worksheet sheet,
  }) {
    var header = headerRange(items: items, sheet: sheet);
    header.cellStyle.backColor = '#D9EAD3';
    header.cellStyle.bold = true;
    header.cellStyle.fontSize = 14;
    header.cellStyle.fontColor = '#FF0000';
    header.cellStyle.hAlign = HAlignType.center;
    header.cellStyle.vAlign = VAlignType.center;
    header.cellStyle.borders.all.lineStyle = LineStyle.thin;
    header.rowHeight = 30;
    allVerticalColumnsRange(items: items, sheet: sheet)
        .columnWidth = 30;
    // header.isAutoFitText = true;
  }

  void styleFooter({
    required List items,
    required Worksheet sheet,
  }) {
    var footer = footerRange(items: items, sheet: sheet);
    footer.cellStyle.backColor = '#D9EAD3';
    footer.cellStyle.bold = true;
    footer.cellStyle.fontSize = 14;
    footer.cellStyle.fontColor = '#FF0000';
    footer.cellStyle.hAlign = HAlignType.center;
    footer.cellStyle.vAlign = VAlignType.center;
    footer.cellStyle.borders.all.lineStyle =
        LineStyle.thick;
  }

  Range headerRange({
    required List items,
    required Worksheet sheet,
  }) {
    return sheet.getRangeByIndex(
      1,
      1,
      1,
      headers(items: items).length,
    );
  }

  Range footerRange({
    required List items,
    required Worksheet sheet,
  }) {
    return sheet.getRangeByIndex(
      items.length + 2,
      1,
      items.length + 2,
      headers(items: items).length,
    );
  }

  Range allVerticalColumnsRange({
    required List items,
    required Worksheet sheet,
  }) {
    return sheet.getRangeByIndex(
      1,
      1,
      items.length,
      headers(items: items).length,
    );
  }

  Range bodyRange({
    required List items,
    required Worksheet sheet,
  }) {
    return sheet.getRangeByIndex(
      2,
      1,
      items.length,
      headers(items: items).length,
    );
  }

  List<String> headers({required List items}) {
    return items.first.toMap().keys.toList();
  }

  List<dynamic> values({required dynamic item}) {
    return item.toMap().values.toList();
  }

  Future<bool> save({
    required List<int> bytes,
    required String name,
  }) async {
    var fileName =
        '$name #${uuidGen().substring(0, 5).toUpperCase()}';
    try {
      if (kIsWeb) {
        await downloadExcelWeb(
          bytes: bytes,
          fileName: fileName,
        );
      } else {
        final Uint8List uint8Bytes = Uint8List.fromList(
          bytes,
        );

        if (Platform.isAndroid || Platform.isIOS) {
          await shareExcel(
            bytes: bytes,
            fileName: fileName,
          );
        } else {
          await FileSaver.instance.saveFile(
            name: fileName,
            fileExtension: "xlsx",
            bytes: uint8Bytes,
            mimeType: MimeType.microsoftExcel,
          );
        }
      }

      return true;
    } catch (e) {
      debugPrint('Error Saving Excel File: $e');
      return false;
    }
  }

  Future<void> downloadExcelWeb({
    required List<int> bytes,
    required String fileName,
  }) async {
    final blob = html.Blob(
      [bytes],
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    );

    final url = html.Url.createObjectUrlFromBlob(blob);

    final anchor =
        html.AnchorElement(href: url)
          ..download = '$fileName.xlsx'
          ..style.display = 'none';

    html.document.body?.append(anchor);

    anchor.click();

    anchor.remove();

    html.Url.revokeObjectUrl(url);
  }

  Future<void> shareExcel({
    required List<int> bytes,
    required String fileName,
  }) async {
    final directory = await getTemporaryDirectory();

    final file = File('${directory.path}/$fileName.xlsx');

    await file.writeAsBytes(bytes);

    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)]),
    );
  }
}
