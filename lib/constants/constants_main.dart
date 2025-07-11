import 'package:flutter/material.dart';
import 'package:stockall/main.dart';

const String mainLogoIcon =
    'assets/images/logos/logo_icon.png';

const String logoIconWhite =
    'assets/images/logos/icon_white.png';

const String mainLogo =
    'assets/images/logos/icon_white.png';

const String appMockUp = 'assets/images/logos/App_Png.png';

const String backGroundImage =
    'assets/images/main_images/sign_up_background.jpg';

const String profileIconImage =
    'assets/images/small_images/image_icon.png';

const String shopIconImage =
    'assets/images/small_images/shop_icon.png';

const String cctvImage =
    'assets/images/small_images/cctv.png';

//
//
//
//

//
//
//
//
// J S O N

const String mainLoader =
    'assets/animations/main_loader.json';

const String successAnim =
    'assets/animations/check_animation.json';

const String shopSetup =
    'assets/animations/shop_setup_icon.json';

const String profitAnim = 'assets/animations/profit.json';

const String welcomeRobot =
    'assets/animations/welcome_robot.json';

const String welcomeLady = 'assets/animations/welcome.json';

//
//
//
//

//
//
//
//
// S V G ' S

const String checkIconSvg = 'assets/svgs/check_icon.svg';

const String notifIconSvg = 'assets/svgs/notif_icon.svg';

const String customersIconSvg =
    'assets/svgs/customers_icon.svg';

const String pulseIconSvg = 'assets/svgs/pulse_icon.svg';

const String productIconSvg =
    'assets/svgs/product_icon.svg';

const String salesIconSvg = 'assets/svgs/sales_icon.svg';

const String custBookIconSvg =
    'assets/svgs/cust_book_icon.svg';

const String employeesIconSvg =
    'assets/svgs/employees_icon.svg';

const String expensesIconSvg =
    'assets/svgs/expenses_icon.svg';

const String reportIconSvg = 'assets/svgs/report_icon.svg';

const String makeSalesIconSvg =
    'assets/svgs/make_sales_button.svg';

const String nairaIconSvg = 'assets/svgs/naira_icon.svg';

const String addIconSvg = 'assets/svgs/add_icon.svg';

const String editIconSvg = 'assets/svgs/edit_icon.svg';

const String deleteIconSvg = 'assets/svgs/delete_icon.svg';

const String receiptIconSvg =
    'assets/svgs/receipt_icon.svg';

const String plusIconSvg = 'assets/svgs/plus_icon.svg';

const String whatsappIconSvg =
    'assets/svgs/whatsapp_logo_icon.svg';

String currencySymbol(BuildContext context) {
  return returnShopProvider(
        context,
        listen: false,
      ).userShop?.currency ??
      '';
}

const String appName = 'Stockall';

const int currentUpdate = 7;

// Future<void> generateAndPreviewPdf({
//   required TempMainReceipt receipt,
//   required List<TempProductSaleRecord> records,
//   required TempShopClass shop,
//   required BuildContext context,
//   required Uint8List pdfBytes,
// }) async {
//   print('Printing');
//   final Uint8List pdfBytes = await buildPdf(
//     receipt,
//     records,
//     shop,
//     context,
//   );

//   await Printing.layoutPdf(
//     onLayout: (_) async => pdfBytes,
//     name: 'receipt.pdf',
//     format: PdfPageFormat.a5,
//   );
//   print('Finished Printing');

//   if (context.mounted) {
//     returnReceiptProvider(
//       context,
//       listen: false,
//     ).toggleIsLoading(false);
//   }
// }

// Future<Uint8List> buildPdf(
//   TempMainReceipt receipt,
//   List<TempProductSaleRecord> records,
//   TempShopClass shop,
//   BuildContext context,
// ) async {
//   print('Start Building Pdf');
//   final pdf = pw.Document();

//   // Load Plus Jakarta Sans from assets
//   final fontRegularBytes = await rootBundle.load(
//     'assets/fonts/PlusJakartaSans-Regular.ttf',
//   );
//   print('Loaded Regular Font');

//   final fontBoldBytes = await rootBundle.load(
//     'assets/fonts/PlusJakartaSans-Bold.ttf',
//   );
//   print('Loaded Bold Font');

//   final fontRegular = pw.Font.ttf(fontRegularBytes);
//   final fontBold = pw.Font.ttf(fontBoldBytes);

//   print('Adding Page');
//   pdf.addPage(
//     pw.Page(
//       pageFormat: PdfPageFormat.a5,
//       build: (pw.Context pdfContext) {
//         return pw.Center(
//           child: pw.Text(
//             style: pw.TextStyle(font: fontBold),
//             'Beans and Rice',
//           ),
//         );
//         // return pw.DefaultTextStyle(
//         //   style: pw.TextStyle(
//         //     font: fontRegular,
//         //     fontSize: 12,
//         //   ),
//         //   child: pw.Column(
//         //     crossAxisAlignment: pw.CrossAxisAlignment.start,
//         //     children: [
//         //       pw.Row(
//         //         mainAxisAlignment:
//         //             pw.MainAxisAlignment.center,
//         //         children: [
//         //           pw.Column(
//         //             children: [
//         //               pw.Text(
//         //                 textAlign: pw.TextAlign.center,
//         //                 shop.name,
//         //                 style: pw.TextStyle(
//         //                   font: fontBold,
//         //                   fontSize: 16,
//         //                 ),
//         //               ),
//         //               pw.SizedBox(height: 5),
//         //               pw.Text(
//         //                 textAlign: pw.TextAlign.center,
//         //                 shop.email,
//         //                 style: pw.TextStyle(
//         //                   font: fontRegular,
//         //                   fontSize: 9,
//         //                 ),
//         //               ),
//         //               pw.SizedBox(height: 5),
//         //               pw.Text(
//         //                 textAlign: pw.TextAlign.center,
//         //                 shop.phoneNumber ?? 'Phone Not Set',
//         //                 style: pw.TextStyle(
//         //                   font: fontRegular,
//         //                   fontSize: 9,
//         //                 ),
//         //               ),
//         //             ],
//         //           ),
//         //         ],
//         //       ),
//         //       pw.SizedBox(height: 5),
//         //       pw.Divider(
//         //         color: PdfColor.fromHex('#D3D3D3'),
//         //         thickness: 0.5,
//         //       ),
//         //       pw.SizedBox(height: 5),
//         //       pw.Row(
//         //         mainAxisAlignment:
//         //             pw.MainAxisAlignment.spaceEvenly,
//         //         children: [
//         //           pw.Expanded(
//         //             child: pw.Column(
//         //               crossAxisAlignment:
//         //                   pw.CrossAxisAlignment.start,
//         //               children: [
//         //                 pw.Text(
//         //                   style: pw.TextStyle(
//         //                     font: fontRegular,
//         //                     fontSize: 9,
//         //                   ),
//         //                   'Staff Name:',
//         //                 ),
//         //                 pw.SizedBox(height: 5),
//         //                 pw.Text(
//         //                   style: pw.TextStyle(
//         //                     font: fontBold,
//         //                     fontSize: 10,
//         //                   ),
//         //                   receipt.staffName,
//         //                 ),
//         //               ],
//         //             ),
//         //           ),
//         //           pw.Expanded(
//         //             child: pw.Column(
//         //               crossAxisAlignment:
//         //                   pw.CrossAxisAlignment.start,
//         //               children: [
//         //                 pw.Text(
//         //                   style: pw.TextStyle(
//         //                     font: fontRegular,
//         //                     fontSize: 9,
//         //                   ),
//         //                   'Customer Name:',
//         //                 ),
//         //                 pw.SizedBox(height: 5),
//         //                 pw.Text(
//         //                   style: pw.TextStyle(
//         //                     font: fontBold,
//         //                     fontSize: 10,
//         //                   ),
//         //                   receipt.customerName ?? 'Not Set',
//         //                 ),
//         //               ],
//         //             ),
//         //           ),
//         //         ],
//         //       ),
//         //       pw.SizedBox(height: 10),
//         //       pw.Row(
//         //         mainAxisAlignment:
//         //             pw.MainAxisAlignment.spaceEvenly,
//         //         children: [
//         //           pw.Expanded(
//         //             child: pw.Column(
//         //               crossAxisAlignment:
//         //                   pw.CrossAxisAlignment.start,
//         //               children: [
//         //                 pw.Text(
//         //                   style: pw.TextStyle(
//         //                     font: fontRegular,
//         //                     fontSize: 9,
//         //                   ),
//         //                   'Payment Method:',
//         //                 ),
//         //                 pw.SizedBox(height: 5),
//         //                 pw.Text(
//         //                   style: pw.TextStyle(
//         //                     font: fontBold,
//         //                     fontSize: 10,
//         //                   ),
//         //                   receipt.paymentMethod,
//         //                 ),
//         //               ],
//         //             ),
//         //           ),
//         //           pw.Expanded(
//         //             child: pw.Column(
//         //               crossAxisAlignment:
//         //                   pw.CrossAxisAlignment.start,
//         //               children: [
//         //                 pw.Text(
//         //                   style: pw.TextStyle(
//         //                     font: fontRegular,
//         //                     fontSize: 9,
//         //                   ),
//         //                   'Amount(s):',
//         //                 ),
//         //                 pw.SizedBox(height: 5),
//         //                 pw.Column(
//         //                   crossAxisAlignment:
//         //                       pw.CrossAxisAlignment.start,
//         //                   children: [
//         //                     pw.Text(
//         //                       style: pw.TextStyle(
//         //                         font: fontRegular,
//         //                         fontSize: 8,
//         //                       ),
//         //                       'Cash: ${formatMoneyMid(receipt.cashAlt, context)}',
//         //                     ),
//         //                     pw.Text(
//         //                       style: pw.TextStyle(
//         //                         font: fontRegular,
//         //                         fontSize: 8,
//         //                       ),
//         //                       'Bank: ${formatMoneyMid(receipt.bank, context)}',
//         //                     ),
//         //                   ],
//         //                 ),
//         //               ],
//         //             ),
//         //           ),
//         //         ],
//         //       ),
//         //       pw.SizedBox(height: 10),
//         //       pw.Row(
//         //         mainAxisAlignment:
//         //             pw.MainAxisAlignment.spaceEvenly,
//         //         children: [
//         //           pw.Expanded(
//         //             child: pw.Column(
//         //               crossAxisAlignment:
//         //                   pw.CrossAxisAlignment.start,
//         //               children: [
//         //                 pw.Text(
//         //                   style: pw.TextStyle(
//         //                     font: fontRegular,
//         //                     fontSize: 9,
//         //                   ),
//         //                   'Date:',
//         //                 ),
//         //                 pw.SizedBox(height: 5),
//         //                 pw.Text(
//         //                   style: pw.TextStyle(
//         //                     font: fontBold,
//         //                     fontSize: 10,
//         //                   ),
//         //                   formatDateTime(receipt.createdAt),
//         //                 ),
//         //               ],
//         //             ),
//         //           ),
//         //           pw.Expanded(
//         //             child: pw.Column(
//         //               crossAxisAlignment:
//         //                   pw.CrossAxisAlignment.start,
//         //               children: [
//         //                 pw.Text(
//         //                   style: pw.TextStyle(
//         //                     font: fontRegular,
//         //                     fontSize: 9,
//         //                   ),
//         //                   'Time:',
//         //                 ),
//         //                 pw.SizedBox(height: 5),
//         //                 pw.Text(
//         //                   style: pw.TextStyle(
//         //                     font: fontBold,
//         //                     fontSize: 10,
//         //                   ),
//         //                   formatTime(receipt.createdAt),
//         //                 ),
//         //               ],
//         //             ),
//         //           ),
//         //         ],
//         //       ),
//         //       pw.SizedBox(height: 5),
//         //       pw.Divider(),

//         //       pw.Text(
//         //         'Items:',
//         //         style: pw.TextStyle(font: fontBold),
//         //       ),
//         //       pw.SizedBox(height: 5),

//         //       ...records.map(
//         //         (record) => pw.Padding(
//         //           padding: const pw.EdgeInsets.symmetric(
//         //             vertical: 2,
//         //           ),
//         //           child: pw.Row(
//         //             mainAxisAlignment:
//         //                 pw.MainAxisAlignment.spaceBetween,
//         //             children: [
//         //               pw.Expanded(
//         //                 flex: 4,
//         //                 child: pw.Text(
//         //                   '${record.productName} ',
//         //                 ),
//         //               ),
//         //               pw.Expanded(
//         //                 flex: 1,
//         //                 child: pw.Text(
//         //                   '(${record.quantity.toStringAsFixed(0)}) ',
//         //                 ),
//         //               ),
//         //               pw.Expanded(
//         //                 flex: 2,
//         //                 child: pw.Text(
//         //                   style: pw.TextStyle(
//         //                     font: fontRegular,
//         //                     fontSize: 10,
//         //                   ),
//         //                   ' ${formatMoneyMid(record.revenue, context)}',
//         //                 ),
//         //               ),
//         //             ],
//         //           ),
//         //         ),
//         //       ),

//         //       pw.SizedBox(height: 12),
//         //       pw.Divider(),

//         //       pw.Row(
//         //         mainAxisAlignment:
//         //             pw.MainAxisAlignment.spaceEvenly,
//         //         children: [
//         //           pw.Expanded(
//         //             flex: 2,
//         //             child: pw.Text(
//         //               style: pw.TextStyle(
//         //                 font: fontRegular,
//         //                 fontSize: 9,
//         //               ),
//         //               'Subtotal:',
//         //             ),
//         //           ),
//         //           pw.Expanded(
//         //             flex: 1,
//         //             child: pw.Text(
//         //               style: pw.TextStyle(
//         //                 font: fontRegular,
//         //                 fontSize: 10,
//         //               ),
//         //               formatMoneyMid(
//         //                 returnReceiptProvider(
//         //                   context,
//         //                   listen: false,
//         //                 ).getSubTotalRevenueForReceipt(
//         //                   context,
//         //                   records,
//         //                 ),
//         //                 context,
//         //               ),
//         //             ),
//         //           ),
//         //         ],
//         //       ),
//         //       pw.SizedBox(height: 5),
//         //       pw.Row(
//         //         mainAxisAlignment:
//         //             pw.MainAxisAlignment.spaceEvenly,
//         //         children: [
//         //           pw.Expanded(
//         //             flex: 2,
//         //             child: pw.Text(
//         //               style: pw.TextStyle(
//         //                 font: fontRegular,
//         //                 fontSize: 9,
//         //               ),
//         //               'Discount:',
//         //             ),
//         //           ),
//         //           pw.Expanded(
//         //             flex: 1,
//         //             child: pw.Text(
//         //               style: pw.TextStyle(
//         //                 font: fontRegular,
//         //                 fontSize: 10,
//         //               ),
//         //               formatMoneyMid(
//         //                 returnReceiptProvider(
//         //                       context,
//         //                       listen: false,
//         //                     ).getTotalMainRevenueReceipt(
//         //                       records,
//         //                       context,
//         //                     ) -
//         //                     returnReceiptProvider(
//         //                       context,
//         //                       listen: false,
//         //                     ).getSubTotalRevenueForReceipt(
//         //                       context,
//         //                       records,
//         //                     ),
//         //                 context,
//         //               ),
//         //             ),
//         //           ),
//         //         ],
//         //       ),
//         //       pw.SizedBox(height: 5),
//         //       pw.Row(
//         //         mainAxisAlignment:
//         //             pw.MainAxisAlignment.spaceEvenly,
//         //         children: [
//         //           pw.Expanded(
//         //             flex: 2,
//         //             child: pw.Text(
//         //               style: pw.TextStyle(
//         //                 font: fontRegular,
//         //                 fontSize: 10,
//         //               ),
//         //               'Total:',
//         //             ),
//         //           ),
//         //           pw.Expanded(
//         //             flex: 1,
//         //             child: pw.Text(
//         //               style: pw.TextStyle(
//         //                 font: fontBold,
//         //                 fontSize: 10,
//         //               ),
//         //               formatMoneyMid(
//         //                 returnReceiptProvider(
//         //                   context,
//         //                   listen: false,
//         //                 ).getTotalMainRevenueReceipt(
//         //                   records,
//         //                   context,
//         //                 ),
//         //                 context,
//         //               ),
//         //             ),
//         //           ),
//         //         ],
//         //       ),
//         //     ],
//         //   ),
//         // );
//       },
//     ),
//   );
//   print('Finished Page');
//   try {
//     print('Before saving PDF...');
//     final data = pdf.save();
//     print('✅ After saving PDF');
//     return data;
//   } catch (e, stack) {
//     print('❌ Error saving PDF: $e');
//     print('🪜 Stack Trace:\n$stack');
//     rethrow;
//   }
// }

// void downloadPdfWeb(Uint8List pdfBytes, String filename) {
//   try {
//     final blob = html.Blob([pdfBytes]);
//     final url = html.Url.createObjectUrlFromBlob(blob);

//     final anchor =
//         html.AnchorElement(href: url)
//           ..download = filename
//           ..target = 'blank'
//           ..style.display = 'none';

//     html.document.body?.append(anchor);
//     anchor.click();
//     anchor.remove();

//     html.Url.revokeObjectUrl(url);
//   } catch (e, stackTrace) {
//     print('❌ Error downloading PDF: $e\n$stackTrace');
//   }
// }
