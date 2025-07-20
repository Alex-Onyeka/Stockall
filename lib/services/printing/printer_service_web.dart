// import 'dart:async';
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
// import 'package:flutter_thermal_printer/utils/printer.dart'
//     show ConnectionType, Printer;
// import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart' show Printing;

// // Your createPdfImage function (this is fine as is)
// Future<Uint8List> createPdfImage() async {
//   // Step 1: Create a simple PDF
//   final doc = pw.Document();

//   doc.addPage(
//     pw.Page(
//       build:
//           (context) => pw.Center(
//             child: pw.Text(
//               'Hello from Flutter PDF!',
//               style: pw.TextStyle(fontSize: 30),
//             ),
//           ),
//     ),
//   );

//   final pdfBytes = await doc.save();

//   // Step 2: Convert the first page of the PDF to PNG image
//   // Consider matching the DPI to your printer's physical DPI (e.g., 203 DPI)
//   // and ensure the output width isn't excessively large for the thermal paper.
//   final rasterStream = Printing.raster(
//     pdfBytes,
//     pages: [0],
//     dpi:
//         2, // Common for thermal printers. Adjust if your printer has higher/lower.
//   );
//   final rasterPage = await rasterStream.first;
//   final pngImage = await rasterPage.toPng(); // Uint8List

//   print(
//     'Generated PNG image size: ${pngImage.lengthInBytes} bytes',
//   );
//   return pngImage;
// }

// // Your scanBluetoothPrinters function (this is fine as is)
// scanBluetoothPrinters({required BuildContext context}) {
//   var safeContext = context;
//   FlutterThermalPrinter.instance.getPrinters(
//     connectionTypes: [
//       ConnectionType.BLE,
//     ], // Scanning for BLE (Bluetooth Low Energy)
//   );

//   late StreamSubscription<List<Printer>> subscription;

//   subscription = FlutterThermalPrinter
//       .instance
//       .devicesStream
//       .listen((List<Printer> printers) {
//         FlutterThermalPrinter.instance
//             .stopScan(); // Stop scanning once devices are found
//         subscription.cancel(); // Cancel the subscription

//         if (printers.isEmpty) {
//           ScaffoldMessenger.of(safeContext).showSnackBar(
//             const SnackBar(
//               content: Text('No Bluetooth printers found.'),
//             ),
//           );
//           print('⚠️ No Bluetooth printers found.');
//           return;
//         }

//         showDialog(
//           context: safeContext,
//           builder: (context) {
//             return AlertDialog(
//               backgroundColor: Colors.white,
//               title: const Text('Select Printer'),
//               content: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children:
//                     printers
//                         .map(
//                           (printer) => ListTile(
//                             title: Row(
//                               children: [
//                                 const Icon(Icons.print),
//                                 Text(
//                                   printer.name ?? 'Unnamed',
//                                   style: const TextStyle(
//                                     fontWeight:
//                                         FontWeight.bold,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             subtitle: Text(
//                               printer.address ??
//                                   'No Address',
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 10,
//                               ),
//                             ),
//                             onTap: () {
//                               Navigator.pop(
//                                 context,
//                               ); // Close dialog
//                               connectToPrinter(
//                                 printer: printer,
//                                 safeContext: safeContext,
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

// // Modified connectToPrinter function
// void connectToPrinter({
//   required Printer printer,
//   required BuildContext safeContext,
// }) async {
//   print(
//     'Attempting to connect to printer: ${printer.name} (${printer.address})',
//   );
//   try {
//     final bool connected = await FlutterThermalPrinter
//         .instance
//         .connect(printer);

//     if (connected) {
//       print('✅ Connected to ${printer.name}');
//       ScaffoldMessenger.of(safeContext).showSnackBar(
//         SnackBar(
//           content: Text(
//             'Connected to ${printer.name ?? 'printer'}!',
//           ),
//         ),
//       );

//       // --- Print Image ---
//       print('Creating PDF image for printing...');
//       final Uint8List image = await createPdfImage();

//       print(
//         'Sending image (size: ${image.lengthInBytes} bytes) to printer...',
//       );
//       await FlutterThermalPrinter.instance.printImageBytes(
//         imageBytes: image,
//         printer: printer,
//         printOnBle: true, // This is crucial for BLE
//       );

//       // if (printResult) {
//       //   print('✅ Print successful!');
//       //   ScaffoldMessenger.of(safeContext).showSnackBar(
//       //     const SnackBar(content: Text('Print successful!')),
//       //   );
//       // } else {
//       //   print('❌ Print failed. FlutterThermalPrinter.printImageBytes returned false.');
//       //   ScaffoldMessenger.of(safeContext).showSnackBar(
//       //     const SnackBar(content: Text('Print failed. Try again.')),
//       //   );
//       // }
//     } else {
//       print('❌ Failed to connect to ${printer.name}');
//       ScaffoldMessenger.of(safeContext).showSnackBar(
//         SnackBar(
//           content: Text(
//             'Failed to connect to ${printer.name ?? 'printer'}.',
//           ),
//         ),
//       );
//     }
//   } catch (e) {
//     print('Error during connection or printing: $e');
//     ScaffoldMessenger.of(safeContext).showSnackBar(
//       SnackBar(
//         content: Text('An error occurred: ${e.toString()}'),
//       ),
//     );
//   } finally {
//     // Optionally disconnect after printing, or keep connection for multiple prints
//     // if (FlutterThermalPrinter.instance.isConnected) {
//     //   await FlutterThermalPrinter.instance.disconnect();
//     //   print('Disconnected from printer.');
//     // }
//   }
// }

// // Example of how to trigger this flow from a button
// class PrintButton extends StatelessWidget {
//   const PrintButton({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return ElevatedButton(
//       onPressed: () {
//         scanBluetoothPrinters(context: context);
//       },
//       child: const Text('Scan & Print PDF (BLE)'),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_main_receipt.dart';
import 'package:stockall/classes/temp_product_sale_record.dart';
import 'package:stockall/classes/temp_shop_class.dart';

void scanBluetoothPrinters({
  required TempMainReceipt receipt,
  required List<TempProductSaleRecord> records,
  required TempShopClass shop,
  required BuildContext context,
}) {}
