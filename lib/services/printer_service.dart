// import 'dart:async';
// import 'dart:typed_data';

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart' show rootBundle;
// import 'package:pdf/widgets.dart' as pw;
// import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
// import 'package:flutter_thermal_printer/utils/printer.dart';
// import 'package:pdf/pdf.dart';
// import 'package:printing/printing.dart' show Printing;
// import 'package:stockall/classes/temp_main_receipt.dart';
// import 'package:stockall/classes/temp_product_sale_record.dart';
// import 'package:stockall/classes/temp_shop_class.dart';
// import 'package:image/image.dart' as img;
// import 'package:stockall/constants/calculations.dart';
// import 'package:stockall/main.dart';
// import 'package:stockall/services/auth_service.dart'; // for utf8.encode
// import 'dart:ui' as ui;
// import 'package:flutter/services.dart';

// scanBluetoothPrinters(BuildContext context) {
//   var safeContext = context;
//   FlutterThermalPrinter.instance.getPrinters(
//     connectionTypes: [ConnectionType.BLE],
//   );

//   late StreamSubscription<List<Printer>> subscription;

//   subscription = FlutterThermalPrinter
//       .instance
//       .devicesStream
//       .listen((List<Printer> printers) {
//         FlutterThermalPrinter.instance.stopScan();
//         subscription.cancel();

//         showDialog(
//           context: context,
//           builder: (context) {
//             return AlertDialog(
//               backgroundColor: Colors.white,
//               title: Text('Select Printer'),
//               content: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children:
//                     printers
//                         .map(
//                           (printer) => ListTile(
//                             title: Row(
//                               children: [
//                                 Icon(Icons.print),
//                                 Text(
//                                   style: TextStyle(
//                                     fontWeight:
//                                         FontWeight.bold,
//                                   ),
//                                   printer.name ?? 'Unnamed',
//                                 ),
//                               ],
//                             ),
//                             subtitle: Text(
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 10,
//                               ),
//                               printer.address ??
//                                   'No Address',
//                             ),
//                             onTap: () {
//                               // Navigator.pop(context);
//                               connectToPrinter(
//                                 printer,
//                                 safeContext,
//                               );
//                             },
//                           ),
//                         )
//                         .toList(),
//               ),
//             );
//           },
//         );
//       });
// }

// void connectToPrinter(
//   Printer printer,
//   BuildContext safeContext,
// ) async {
//   var shop =
//       returnShopProvider(
//         safeContext,
//         listen: false,
//       ).userShop!;
//   final result = await FlutterThermalPrinter.instance
//       .connect(printer);
//   print(
//     result
//         ? '✅ Connected to ${printer.name}'
//         : '❌ Failed to connect',
//   );
//   // printTestReceipt(printer, 333);
//   printReceiptAsImage(
//     context: safeContext,
//     printer: printer,
//     receipt: TempMainReceipt(
//       createdAt: DateTime.now(),
//       shopId: shop.shopId!,
//       staffId: AuthService().currentUser!.id,
//       staffName: 'Alex Onyeka',
//       paymentMethod: 'Cash',
//       bank: 0,
//       cashAlt: 2000,
//       isInvoice: false,
//     ),
//     records: [
//       TempProductSaleRecord(
//         createdAt: DateTime.now(),
//         productId: 22,
//         productName: 'Mango',
//         shopId: shop.shopId!,
//         staffId: AuthService().currentUser!.id,
//         staffName: 'Alex Onyeka',
//         recepitId: 2,
//         quantity: 2,
//         revenue: 3000,
//         discountedAmount: 0,
//         originalCost: 3000,
//         discount: 0,
//         customPriceSet: false,
//       ),
//     ],
//     shop: shop,
//   );

//   // final bytes = utf8.encode(plainText);
//   // const chunkSize = 244;
//   // for (int i = 0; i < bytes.length; i += chunkSize) {
//   //   final chunk = bytes.sublist(
//   //     i,
//   //     i + chunkSize > bytes.length
//   //         ? bytes.length
//   //         : i + chunkSize,
//   //   );
//   //   await FlutterThermalPrinter.instance.printData(
//   //     printer,
//   //     chunk,
//   //   );
//   //   await Future.delayed(
//   //     const Duration(milliseconds: 100),
//   //   ); // prevent overflow
//   // }
//   // await FlutterThermalPrinter.instance.printData(
//   //   printer,
//   //   bytes,
//   // );
// }

// Future<Uint8List> convertUiImageToBytes(
//   ui.Image image,
// ) async {
//   final byteData = await image.toByteData(
//     format: ui.ImageByteFormat.png,
//   );
//   return byteData!.buffer.asUint8List();
// }

// Future<void> writeInChunks({
//   required List<int> bytes,
//   required Printer printer,
//   required int chunkSize,
// }) async {
//   final totalLength = bytes.length;
//   int offset = 0;

//   while (offset < totalLength) {
//     final end =
//         (offset + chunkSize < totalLength)
//             ? offset + chunkSize
//             : totalLength;
//     final chunk = bytes.sublist(offset, end);
//     await FlutterThermalPrinter.instance.writeBytes(
//       bytes: chunk,
//       printer: printer,
//     );
//     offset = end;
//     await Future.delayed(
//       const Duration(milliseconds: 30),
//     ); // small delay to be safe
//   }
// }

// Future<void> printReceiptAsImage({
//   required Printer printer,
//   required TempMainReceipt receipt,
//   required List<TempProductSaleRecord> records,
//   required TempShopClass shop,
//   required BuildContext context,
// }) async {
//   // 1. Generate the PDF document
//   final Uint8List pdfBytes = await _buildPdfRoll(
//     receipt,
//     records,
//     shop,
//     context,
//   );

//   // 2. Rasterize the first page
//   final pdfPages = await Printing.raster(
//     pdfBytes,
//     pages: [0],
//     dpi: 203,
//   );
//   final raster = await pdfPages.first;

//   // Step 3: Convert raster to ui.Image
//   final uiImage = await raster.toImage();

//   // Step 4: Convert ui.Image to PNG bytes
//   final Uint8List pngBytes = await convertUiImageToBytes(
//     uiImage,
//   );

//   // Step 5: Send to printer
//   await FlutterThermalPrinter.instance.printImageBytes(
//     imageBytes: pngBytes,
//     printer: printer,
//     paperSize: PaperSize.mm58,
//     printOnBle: true,
//   );
// }

// Future<Uint8List> _buildPdfRoll(
//   TempMainReceipt receipt,
//   List<TempProductSaleRecord> records,
//   TempShopClass shop,
//   BuildContext context,
// ) async {
//   final pdf = pw.Document();

//   // Load Plus Jakarta Sans from assets
//   final fontRegular = pw.Font.ttf(
//     await rootBundle.load(
//       'assets/fonts/PlusJakartaSans-Regular.ttf',
//     ),
//   );
//   final fontBold = pw.Font.ttf(
//     await rootBundle.load(
//       'assets/fonts/PlusJakartaSans-Bold.ttf',
//     ),
//   );

//   pdf.addPage(
//     pw.Page(
//       pageFormat: PdfPageFormat.roll57,
//       margin: const pw.EdgeInsets.only(
//         left: 15,
//         top: 15,
//         right: 15,
//         bottom: 10,
//       ),

//       // 🔹 HEADER
//       build:
//           (pw.Context pdfContext) => pw.DefaultTextStyle(
//             style: pw.TextStyle(
//               font: fontRegular,
//               fontSize: 10,
//             ),
//             child: pw.Column(
//               crossAxisAlignment:
//                   pw.CrossAxisAlignment.center,
//               children: [
//                 pw.Column(
//                   crossAxisAlignment:
//                       pw.CrossAxisAlignment.center,
//                   children: [
//                     pw.Row(
//                       mainAxisAlignment:
//                           pw.MainAxisAlignment.center,
//                       children: [
//                         pw.Column(
//                           children: [
//                             pw.Text(
//                               textAlign:
//                                   pw.TextAlign.center,
//                               shop.name,
//                               style: pw.TextStyle(
//                                 font: fontBold,
//                                 fontSize: 7,
//                               ),
//                             ),
//                             pw.SizedBox(height: 1),
//                             pw.Text(
//                               textAlign:
//                                   pw.TextAlign.center,
//                               shop.email,
//                               style: pw.TextStyle(
//                                 font: fontRegular,
//                                 fontSize: parText,
//                               ),
//                             ),
//                             pw.SizedBox(height: 1),

//                             pw.Text(
//                               textAlign:
//                                   pw.TextAlign.center,
//                               shop.phoneNumber ?? '',
//                               style: pw.TextStyle(
//                                 font: fontRegular,
//                                 fontSize:
//                                     shop.phoneNumber == null
//                                         ? 1
//                                         : parText,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                     pw.SizedBox(height: 3),
//                     pw.Divider(
//                       color: PdfColor.fromHex('#D3D3D3'),
//                       thickness: 0.5,
//                       height: 4,
//                     ),
//                   ],
//                 ),
//                 pw.Row(
//                   mainAxisAlignment:
//                       pw.MainAxisAlignment.center,
//                   children: [
//                     pw.Text(
//                       textAlign: pw.TextAlign.center,
//                       receipt.isInvoice
//                           ? 'Generated Invoice'
//                           : 'Payment Receipt',
//                       style: pw.TextStyle(
//                         font: fontRegular,
//                         fontSize: parText,
//                       ),
//                     ),
//                   ],
//                 ),
//                 pw.SizedBox(height: 2),
//                 pw.Divider(
//                   color: PdfColor.fromHex('#D3D3D3'),
//                   thickness: 0.5,
//                   height: 3,
//                 ),
//                 pw.SizedBox(height: 2),
//                 pw.Row(
//                   mainAxisAlignment:
//                       pw.MainAxisAlignment.spaceEvenly,
//                   children: [
//                     pw.Expanded(
//                       child: pw.Column(
//                         crossAxisAlignment:
//                             pw.CrossAxisAlignment.start,
//                         children: [
//                           pw.Text(
//                             style: pw.TextStyle(
//                               font: fontRegular,
//                               fontSize: parText,
//                             ),
//                             'Staff Name:',
//                           ),
//                           pw.SizedBox(height: 1),
//                           pw.Text(
//                             style: pw.TextStyle(
//                               font: fontBold,
//                               fontSize: parText,
//                             ),
//                             receipt.staffName,
//                           ),
//                         ],
//                       ),
//                     ),
//                     pw.Expanded(
//                       child: pw.Column(
//                         crossAxisAlignment:
//                             pw.CrossAxisAlignment.start,
//                         children: [
//                           pw.Text(
//                             style: pw.TextStyle(
//                               font: fontRegular,
//                               fontSize: parText,
//                             ),
//                             'Customer Name:',
//                           ),
//                           pw.SizedBox(height: 1),
//                           pw.Text(
//                             style: pw.TextStyle(
//                               font: fontBold,
//                               fontSize: parText,
//                             ),
//                             receipt.customerName ??
//                                 'Not Set',
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//                 pw.Builder(
//                   builder: (pw.Context pdfContext) {
//                     if (receipt.isInvoice) {
//                       return pw.Container();
//                     } else {
//                       return pw.Column(
//                         children: [
//                           pw.SizedBox(height: 3),
//                           pw.Row(
//                             mainAxisAlignment:
//                                 pw
//                                     .MainAxisAlignment
//                                     .spaceEvenly,
//                             children: [
//                               pw.Expanded(
//                                 child: pw.Column(
//                                   crossAxisAlignment:
//                                       pw
//                                           .CrossAxisAlignment
//                                           .start,
//                                   children: [
//                                     pw.Text(
//                                       style: pw.TextStyle(
//                                         font: fontRegular,
//                                         fontSize: parText,
//                                       ),
//                                       'Payment Method:',
//                                     ),
//                                     pw.SizedBox(height: 1),
//                                     pw.Text(
//                                       style: pw.TextStyle(
//                                         font: fontBold,
//                                         fontSize: parText,
//                                       ),
//                                       receipt.paymentMethod,
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               pw.Expanded(
//                                 child: pw.Column(
//                                   crossAxisAlignment:
//                                       pw
//                                           .CrossAxisAlignment
//                                           .start,
//                                   children: [
//                                     pw.Text(
//                                       style: pw.TextStyle(
//                                         font: fontRegular,
//                                         fontSize: parText,
//                                       ),
//                                       'Amount(s):',
//                                     ),
//                                     pw.SizedBox(height: 1),
//                                     pw.Column(
//                                       crossAxisAlignment:
//                                           pw
//                                               .CrossAxisAlignment
//                                               .start,
//                                       children: [
//                                         pw.Text(
//                                           style: pw.TextStyle(
//                                             font:
//                                                 fontRegular,
//                                             fontSize: 4,
//                                           ),
//                                           'Cash: ${formatMoneyMid(receipt.cashAlt, context)}',
//                                         ),
//                                         pw.Text(
//                                           style: pw.TextStyle(
//                                             font:
//                                                 fontRegular,
//                                             fontSize: 4,
//                                           ),
//                                           'Bank: ${formatMoneyMid(receipt.bank, context)}',
//                                         ),
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       );
//                     }
//                   },
//                 ),
//                 pw.SizedBox(height: 3),
//                 pw.Row(
//                   mainAxisAlignment:
//                       pw.MainAxisAlignment.spaceEvenly,
//                   children: [
//                     pw.Expanded(
//                       child: pw.Column(
//                         crossAxisAlignment:
//                             pw.CrossAxisAlignment.start,
//                         children: [
//                           pw.Text(
//                             style: pw.TextStyle(
//                               font: fontRegular,
//                               fontSize: parText,
//                             ),
//                             'Date:',
//                           ),
//                           pw.SizedBox(height: 1),
//                           pw.Text(
//                             style: pw.TextStyle(
//                               font: fontBold,
//                               fontSize: parText,
//                             ),
//                             formatDateTime(
//                               receipt.createdAt,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     pw.Expanded(
//                       child: pw.Column(
//                         crossAxisAlignment:
//                             pw.CrossAxisAlignment.start,
//                         children: [
//                           pw.Text(
//                             style: pw.TextStyle(
//                               font: fontRegular,
//                               fontSize: parText,
//                             ),
//                             'Time:',
//                           ),
//                           pw.SizedBox(height: 1),
//                           pw.Text(
//                             style: pw.TextStyle(
//                               font: fontBold,
//                               fontSize: parText,
//                             ),
//                             formatTime(receipt.createdAt),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//                 pw.SizedBox(height: 3),
//                 pw.Divider(thickness: 0.6, height: 6),

//                 pw.Row(
//                   children: [
//                     pw.Text(
//                       'Items:',
//                       style: pw.TextStyle(
//                         fontSize: 6,
//                         font: fontBold,
//                       ),
//                     ),
//                   ],
//                 ),
//                 pw.SizedBox(height: 1),

//                 ...records.map(
//                   (record) => pw.Padding(
//                     padding: const pw.EdgeInsets.symmetric(
//                       vertical: 2,
//                     ),
//                     child: pw.Row(
//                       mainAxisAlignment:
//                           pw.MainAxisAlignment.spaceBetween,
//                       children: [
//                         pw.Expanded(
//                           flex: 5,
//                           child: pw.Text(
//                             style: pw.TextStyle(
//                               fontSize: 5,
//                             ),
//                             '${record.productName} ',
//                           ),
//                         ),
//                         pw.Expanded(
//                           flex: 1,
//                           child: pw.Text(
//                             style: pw.TextStyle(
//                               fontSize: 5,
//                             ),
//                             '( ${record.quantity.toStringAsFixed(0)} ) ',
//                           ),
//                         ),
//                         pw.Expanded(
//                           flex: 3,
//                           child: pw.Text(
//                             style: pw.TextStyle(
//                               fontSize: 5,
//                             ),
//                             formatMoneyMid(
//                               record.revenue,
//                               context,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),

//                 pw.SizedBox(height: 3),
//                 pw.Divider(thickness: 0.6, height: 6),

//                 pw.Row(
//                   mainAxisAlignment:
//                       pw.MainAxisAlignment.spaceEvenly,
//                   children: [
//                     pw.Expanded(
//                       flex: 2,
//                       child: pw.Text(
//                         style: pw.TextStyle(
//                           font: fontRegular,
//                           fontSize: parText,
//                         ),
//                         'Subtotal:',
//                       ),
//                     ),
//                     pw.Expanded(
//                       flex: 1,
//                       child: pw.Text(
//                         style: pw.TextStyle(
//                           font: fontRegular,
//                           fontSize: parText,
//                         ),
//                         formatMoneyMid(
//                           returnReceiptProvider(
//                             context,
//                             listen: false,
//                           ).getSubTotalRevenueForReceipt(
//                             context,
//                             records,
//                           ),
//                           context,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 pw.SizedBox(height: 1),
//                 pw.Row(
//                   mainAxisAlignment:
//                       pw.MainAxisAlignment.spaceEvenly,
//                   children: [
//                     pw.Expanded(
//                       flex: 2,
//                       child: pw.Text(
//                         style: pw.TextStyle(
//                           font: fontRegular,
//                           fontSize: parText,
//                         ),
//                         'Discount:',
//                       ),
//                     ),
//                     pw.Expanded(
//                       flex: 1,
//                       child: pw.Text(
//                         style: pw.TextStyle(
//                           font: fontRegular,
//                           fontSize: parText,
//                         ),
//                         formatMoneyMid(
//                           returnReceiptProvider(
//                                 context,
//                                 listen: false,
//                               ).getTotalMainRevenueReceipt(
//                                 records,
//                                 context,
//                               ) -
//                               returnReceiptProvider(
//                                 context,
//                                 listen: false,
//                               ).getSubTotalRevenueForReceipt(
//                                 context,
//                                 records,
//                               ),
//                           context,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 pw.SizedBox(height: 1),
//                 pw.Row(
//                   mainAxisAlignment:
//                       pw.MainAxisAlignment.spaceEvenly,
//                   children: [
//                     pw.Expanded(
//                       flex: 2,
//                       child: pw.Text(
//                         style: pw.TextStyle(
//                           font: fontRegular,
//                           fontSize: parText,
//                         ),
//                         'Total:',
//                       ),
//                     ),
//                     pw.Expanded(
//                       flex: 1,
//                       child: pw.Text(
//                         style: pw.TextStyle(
//                           font: fontBold,
//                           fontSize: parText,
//                         ),
//                         formatMoneyMid(
//                           returnReceiptProvider(
//                             context,
//                             listen: false,
//                           ).getTotalMainRevenueReceipt(
//                             records,
//                             context,
//                           ),
//                           context,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 pw.SizedBox(height: 10),
//               ],
//             ),
//           ),

//       // pw.Expanded(child: pw.Spacer()),
//     ),
//   );

//   return pdf.save();
// }

// const double parText = 5;
// // String generatePlainTextReceipt({
// //   required TempMainReceipt receipt,
// //   required List<TempProductSaleRecord> records,
// //   required TempShopClass shop,
// //   required BuildContext context,
// // }) {
// //   final buffer = StringBuffer();
// //   buffer.writeln('=== ${shop.name} ===');
// //   buffer.writeln(shop.email);
// //   if (shop.phoneNumber != null) {
// //     buffer.writeln(shop.phoneNumber);
// //   }
// //   buffer.writeln('');
// //   buffer.writeln(
// //     receipt.isInvoice
// //         ? 'Generated Invoice'
// //         : 'Payment Receipt',
// //   );
// //   buffer.writeln('------------------------------');
// //   buffer.writeln('Staff: ${receipt.staffName}');
// //   buffer.writeln(
// //     'Customer: ${receipt.customerName ?? 'Not Set'}',
// //   );
// //   if (!receipt.isInvoice) {
// //     buffer.writeln(
// //       'Payment Method: ${receipt.paymentMethod}',
// //     );
// //     buffer.writeln(
// //       'Cash: ${formatMoneyMid(receipt.cashAlt, context)}',
// //     );
// //     buffer.writeln(
// //       'Bank: ${formatMoneyMid(receipt.bank, context)}',
// //     );
// //   }

// //   buffer.writeln(
// //     'Date: ${formatDateTime(receipt.createdAt)}',
// //   );
// //   buffer.writeln('Time: ${formatTime(receipt.createdAt)}');
// //   buffer.writeln('------------------------------');
// //   buffer.writeln('Items:');

// //   for (final item in records) {
// //     final name = item.productName.padRight(12);
// //     final qty = item.quantity.toStringAsFixed(0).padLeft(3);
// //     final price = formatMoneyMid(
// //       item.revenue,
// //       context,
// //     ).padLeft(8);
// //     buffer.writeln('$name $qty $price');
// //   }
// //   buffer.writeln('------------------------------');
// //   final subtotal = returnReceiptProvider(
// //     context,
// //     listen: false,
// //   ).getSubTotalRevenueForReceipt(context, records);
// //   final total = returnReceiptProvider(
// //     context,
// //     listen: false,
// //   ).getTotalMainRevenueReceipt(records, context);
// //   final discount = total - subtotal;

// //   buffer.writeln(
// //     'Subtotal: ${formatMoneyMid(subtotal, context)}',
// //   );
// //   buffer.writeln(
// //     'Discount: ${formatMoneyMid(discount, context)}',
// //   );
// //   buffer.writeln(
// //     'Total:    ${formatMoneyMid(total, context)}',
// //   );
// //   buffer.writeln('');
// //   buffer.writeln('Thanks for shopping with us!');

// //   return buffer.toString();
// // }

// // void printTestReceipt(Printer device, int number) async {
// //   // const bean = number;
// //   var sampleText = '''
// // STOCKALL RECEIPT

// // Thanks for shopping!

// // ------------------------
// // Item       Qty   Price
// // Apple      2     NGN$number
// // Orange     1     \$ 300
// // ------------------------

// // Total: NGN1300

// // Visit Again!
// // ''';

// //   // Convert the text to bytes (use utf8 to support special chars)
// //   final bytes = utf8.encode(sampleText);

// //   // Send to printer
// //   await FlutterThermalPrinter.instance.printData(
// //     device,
// //     bytes,
// //   );

// //   // print(result ? '✅ Printed successfully' : '❌ Print failed');
// // }
