import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:stockall/classes/currency_class.dart';
import 'package:stockall/classes/product_report_summary.dart';
import 'package:stockall/classes/temp_main_receipt.dart';
import 'package:stockall/classes/temp_product_class.dart';
import 'package:stockall/classes/temp_product_sale_record.dart';
import 'package:stockall/classes/temp_shop_class.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:universal_html/html.dart' as html;
import 'package:url_launcher/url_launcher.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

void openWhatsApp() async {
  final phone = '2347048507587'; // your number
  final message = Uri.encodeComponent(
    "Hello, Stockall Solutions; ",
  );
  final url = 'https://wa.me/$phone?text=$message';

  if (await canLaunchUrl(Uri.parse(url))) {
    await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
  } else {
    print('Could not launch $url');
  }
}

void phoneCall() async {
  final Uri uri = Uri(
    scheme: 'tel',
    path: '+2347048507587',
  );
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    throw 'Could not launch +2347048507587';
  }
}

bool isValidEmail(String email) {
  final emailRegex = RegExp(
    r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$",
  );
  return emailRegex.hasMatch(email);
}

int getDayDifference(DateTime inputDate) {
  final today = DateTime.now();
  final todayDateOnly = DateTime(
    today.year,
    today.month,
    today.day,
  );
  final inputDateOnly = DateTime(
    inputDate.year,
    inputDate.month,
    inputDate.day,
  );
  return inputDateOnly.difference(todayDateOnly).inDays;
}

List empSetup =
    employees
        .where((emp) => emp['position'] != 'Owner')
        .toList();

List<Map<String, dynamic>> employees = [
  {
    'position': 'Owner',
    'auths': [
      'Add Products',
      'Update Products',
      'Delete Products',
      'Add Customers',
      'Update Customers',
      'Delete Customers',
      'Make Sale',
      'Make Refund',
      'Delete Sales',
      'Add Employee',
      'Employee Page',
      'Update Employee',
      'Delete Employee',
      'Add Expenses',
      'Update Expenses',
      'Delete Expenses',
      'Manage Shop',
      'Notifications Page',
      'Delete Notification',
      'Contact Stockall',
      'View Date',
    ],
  },
  {
    'position': 'General Manager',
    'auths': [
      'Add Products',
      'Update Products',
      'Delete Products',
      'Add Customers',
      'Update Customers',
      'Delete Customers',
      'Make Sale',
      'Make Refund',
      'Delete Sales',
      'Add Employee',
      'Update Employee',
      'Employee Page',
      'Delete Employee',
      'Add Expenses',
      'Update Expenses',
      'Delete Expenses',
      'Notifications Page',
      'Contact Stockall',
      'View Date',
    ],
  },
  {
    'position': 'Manager',
    'auths': [
      'Add Customers',
      'Update Customers',
      'Delete Customers',
      'Make Sale',
      'Make Refund',
      'Delete Sales',
      'Add Expenses',
      'Update Expenses',
      'Notifications Page',
      'Delete Expenses',
    ],
  },
  {
    'position': 'Asst. Manager',
    'auths': [
      'Add Products',
      'Add Customers',
      'Update Customers',
      'Delete Customers',
      'Make Sale',
      'View Daily Sales',
      'Add Expenses',
      'Update Expenses',
      'Delete Expenses',
    ],
  },
  {
    'position': 'Cashier',
    'auths': [
      'Add Customers',
      'Make Sale',
      'View Products',
      'View Daily Sales',
      'Add Expenses',
      'Update Expenses',
    ],
  },
];

class Authorizations {
  String addProduct = 'Add Products';
  String updateProduct = 'Update Products';
  String deleteProduct = 'Delete Products';
  String addCustomer = 'Add Customers';
  String updateCustomer = 'Update Customers';
  String deleteCustomer = 'Delete Customers';
  String makeSale = 'Make Sale';
  String deleteSale = 'Delete Sales';
  String makeRefund = 'Make Refund';
  String addEmployee = 'Add Employee';
  String updateEmployee = 'Update Employees';
  String employeePage = 'Employee Page';
  String deleteEmployee = 'Delete Employees';
  String addExpense = 'Add Expenses';
  String updateExpenses = 'Update Expenses';
  String deleteExpenses = 'Delete Expenses';
  String manageShop = 'Manage Shop';
  String deleteNotification = 'Delete Notification';
  String notificationsPage = 'Notifications Page';
  String contactStockall = 'Contact Stockall';
  String viewDate = 'View Date';
}

bool authorization({
  required String authorized,
  required BuildContext context,
}) {
  Map<String, dynamic> emp = employees.firstWhere(
    (emp) =>
        emp['position'] ==
        userGeneral(context, listen: false).role,
  );
  if (emp['auths'].contains(authorized)) {
    return true;
  } else {
    return false;
  }
}

final List<CurrencyClass> currencies = [
  CurrencyClass(
    country: 'Nigeria',
    currency: 'Naira',
    symbol: '₦',
  ),
  CurrencyClass(
    country: 'Cameroon',
    currency: 'Central African CFA Franc',
    symbol: 'FCFA',
  ),
  CurrencyClass(
    country: 'United States',
    currency: 'US Dollar',
    symbol: '\$',
  ),
  CurrencyClass(
    country: 'United Kingdom',
    currency: 'British Pound',
    symbol: '£',
  ),
  CurrencyClass(
    country: 'European Union',
    currency: 'Euro',
    symbol: '€',
  ),
  CurrencyClass(
    country: 'Ghana',
    currency: 'Ghanaian Cedi',
    symbol: '₵',
  ),
  CurrencyClass(
    country: 'Kenya',
    currency: 'Kenyan Shilling',
    symbol: 'KSh',
  ),
  CurrencyClass(
    country: 'South Africa',
    currency: 'South African Rand',
    symbol: 'R',
  ),
  CurrencyClass(
    country: 'Canada',
    currency: 'Canadian Dollar',
    symbol: 'C\$',
  ),
  CurrencyClass(
    country: 'India',
    currency: 'Indian Rupee',
    symbol: '₹',
  ),
  CurrencyClass(
    country: 'Australia',
    currency: 'Australian Dollar',
    symbol: 'A\$',
  ),
  CurrencyClass(
    country: 'China',
    currency: 'Yuan Renminbi',
    symbol: '¥',
  ),
  CurrencyClass(
    country: 'Japan',
    currency: 'Japanese Yen',
    symbol: '¥',
  ),
  CurrencyClass(
    country: 'Brazil',
    currency: 'Brazilian Real',
    symbol: 'R\$',
  ),
  CurrencyClass(
    country: 'Mexico',
    currency: 'Mexican Peso',
    symbol: '\$',
  ),
  CurrencyClass(
    country: 'Egypt',
    currency: 'Egyptian Pound',
    symbol: 'E£',
  ),
  CurrencyClass(
    country: 'Tanzania',
    currency: 'Tanzanian Shilling',
    symbol: 'TSh',
  ),
  CurrencyClass(
    country: 'Uganda',
    currency: 'Ugandan Shilling',
    symbol: 'USh',
  ),
  CurrencyClass(
    country: 'Rwanda',
    currency: 'Rwandan Franc',
    symbol: 'FRw',
  ),
  CurrencyClass(
    country: 'Turkey',
    currency: 'Turkish Lira',
    symbol: '₺',
  ),
  CurrencyClass(
    country: 'United Arab Emirates',
    currency: 'Dirham',
    symbol: 'د.إ',
  ),
];

//
//
//
//
//
//
//
//
// PDF RECEIPT GENERATOR
Future<void> generateAndPreviewPdf({
  required TempMainReceipt receipt,
  required List<TempProductSaleRecord> records,
  required TempShopClass shop,
  required BuildContext context,
}) async {
  // 1. Build the PDF once (fastest way)
  returnReceiptProvider(
    context,
    listen: false,
  ).toggleIsLoading(true);
  final Uint8List pdfBytes = await _buildPdf(
    receipt,
    records,
    shop,
    context,
  );

  // 2. Open native print/share/save dialog (cross-platform)
  await Printing.layoutPdf(onLayout: (_) async => pdfBytes);
  if (context.mounted) {
    returnReceiptProvider(
      context,
      listen: false,
    ).toggleIsLoading(false);
  }
}

Future<void> generateAndPreviewPdfRoll({
  required TempMainReceipt receipt,
  required List<TempProductSaleRecord> records,
  required TempShopClass shop,
  required BuildContext context,
  required int printerType,
}) async {
  // 1. Build the PDF once (fastest way)
  returnReceiptProvider(
    context,
    listen: false,
  ).toggleIsLoading(true);
  final Uint8List pdfBytes = await _buildPdfRoll(
    receipt,
    records,
    shop,
    context,
    printerType,
  );

  // 2. Open native print/share/save dialog (cross-platform)
  await Printing.layoutPdf(onLayout: (_) async => pdfBytes);
  if (context.mounted) {
    returnReceiptProvider(
      context,
      listen: false,
    ).toggleIsLoading(false);
  }
}

Future<Uint8List> _buildPdf(
  TempMainReceipt receipt,
  List<TempProductSaleRecord> records,
  TempShopClass shop,
  BuildContext context,
) async {
  final pdf = pw.Document();

  // Load Plus Jakarta Sans from assets
  final fontRegular = pw.Font.ttf(
    await rootBundle.load(
      'assets/fonts/PlusJakartaSans-Regular.ttf',
    ),
  );
  final fontBold = pw.Font.ttf(
    await rootBundle.load(
      'assets/fonts/PlusJakartaSans-Bold.ttf',
    ),
  );

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a5,
      margin: const pw.EdgeInsets.only(
        left: 30,
        top: 30,
        right: 30,
        bottom: 10,
      ),
      // 🔹 HEADER
      header:
          (context) => pw.Column(
            crossAxisAlignment:
                pw.CrossAxisAlignment.center,
            children: [
              pw.Row(
                mainAxisAlignment:
                    pw.MainAxisAlignment.center,
                children: [
                  pw.Column(
                    children: [
                      pw.Text(
                        textAlign: pw.TextAlign.center,
                        shop.name,
                        style: pw.TextStyle(
                          font: fontBold,
                          fontSize: 16,
                        ),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        textAlign: pw.TextAlign.center,
                        shop.email,
                        style: pw.TextStyle(
                          font: fontRegular,
                          fontSize: 9,
                        ),
                      ),
                      pw.SizedBox(height: 5),

                      pw.Text(
                        textAlign: pw.TextAlign.center,
                        shop.phoneNumber ?? '',
                        style: pw.TextStyle(
                          font: fontRegular,
                          fontSize:
                              shop.phoneNumber == null
                                  ? 1
                                  : 9,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 5),
              pw.Divider(
                color: PdfColor.fromHex('#D3D3D3'),
                thickness: 0.5,
              ),
            ],
          ),
      // 🔹 FOOTER
      footer:
          (context) => pw.Column(
            children: [
              pw.Divider(),
              pw.SizedBox(height: 5),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Row(
                  mainAxisAlignment:
                      pw.MainAxisAlignment.center,
                  children: [
                    pw.Text(
                      '( Page ${context.pageNumber} of ${context.pagesCount} )',
                      style: pw.TextStyle(
                        font: fontRegular,
                        fontSize: 9,
                      ),
                    ),
                    pw.SizedBox(width: 15),
                    pw.Text(
                      'Created by $appName Solutions - ( www.stockallapp.com )',
                      style: pw.TextStyle(
                        font: fontRegular,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
      build:
          (pw.Context pdfContext) => [
            pw.DefaultTextStyle(
              style: pw.TextStyle(
                font: fontRegular,
                fontSize: 12,
              ),
              child: pw.Column(
                crossAxisAlignment:
                    pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment:
                        pw.MainAxisAlignment.center,
                    children: [
                      pw.Text(
                        textAlign: pw.TextAlign.center,
                        receipt.isInvoice
                            ? 'Generated Invoice'
                            : 'Receipt of Payment',
                        style: pw.TextStyle(
                          font: fontRegular,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  pw.Divider(
                    color: PdfColor.fromHex('#D3D3D3'),
                    thickness: 0.5,
                  ),
                  pw.SizedBox(height: 5),
                  pw.Row(
                    mainAxisAlignment:
                        pw.MainAxisAlignment.spaceEvenly,
                    children: [
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment:
                              pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              style: pw.TextStyle(
                                font: fontRegular,
                                fontSize: 9,
                              ),
                              'Staff Name:',
                            ),
                            pw.SizedBox(height: 5),
                            pw.Text(
                              style: pw.TextStyle(
                                font: fontBold,
                                fontSize: 10,
                              ),
                              receipt.staffName,
                            ),
                          ],
                        ),
                      ),
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment:
                              pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              style: pw.TextStyle(
                                font: fontRegular,
                                fontSize: 9,
                              ),
                              'Customer Name:',
                            ),
                            pw.SizedBox(height: 5),
                            pw.Text(
                              style: pw.TextStyle(
                                font: fontBold,
                                fontSize: 10,
                              ),
                              receipt.customerName ??
                                  'Not Set',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  pw.Builder(
                    builder: (pw.Context pdfContext) {
                      if (receipt.isInvoice) {
                        return pw.Container();
                      } else {
                        return pw.Column(
                          children: [
                            pw.SizedBox(height: 10),
                            pw.Row(
                              mainAxisAlignment:
                                  pw
                                      .MainAxisAlignment
                                      .spaceEvenly,
                              children: [
                                pw.Expanded(
                                  child: pw.Column(
                                    crossAxisAlignment:
                                        pw
                                            .CrossAxisAlignment
                                            .start,
                                    children: [
                                      pw.Text(
                                        style: pw.TextStyle(
                                          font: fontRegular,
                                          fontSize: 9,
                                        ),
                                        'Payment Method:',
                                      ),
                                      pw.SizedBox(
                                        height: 5,
                                      ),
                                      pw.Text(
                                        style: pw.TextStyle(
                                          font: fontBold,
                                          fontSize: 10,
                                        ),
                                        receipt
                                            .paymentMethod,
                                      ),
                                    ],
                                  ),
                                ),
                                pw.Expanded(
                                  child: pw.Column(
                                    crossAxisAlignment:
                                        pw
                                            .CrossAxisAlignment
                                            .start,
                                    children: [
                                      pw.Text(
                                        style: pw.TextStyle(
                                          font: fontRegular,
                                          fontSize: 9,
                                        ),
                                        'Amount(s):',
                                      ),
                                      pw.SizedBox(
                                        height: 5,
                                      ),
                                      pw.Column(
                                        crossAxisAlignment:
                                            pw
                                                .CrossAxisAlignment
                                                .start,
                                        children: [
                                          pw.Text(
                                            style: pw.TextStyle(
                                              font:
                                                  fontRegular,
                                              fontSize: 8,
                                            ),
                                            'Cash: ${formatMoneyMid(receipt.cashAlt, context)}',
                                          ),
                                          pw.Text(
                                            style: pw.TextStyle(
                                              font:
                                                  fontRegular,
                                              fontSize: 8,
                                            ),
                                            'Bank: ${formatMoneyMid(receipt.bank, context)}',
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      }
                    },
                  ),
                  pw.SizedBox(height: 10),
                  pw.Row(
                    mainAxisAlignment:
                        pw.MainAxisAlignment.spaceEvenly,
                    children: [
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment:
                              pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              style: pw.TextStyle(
                                font: fontRegular,
                                fontSize: 9,
                              ),
                              'Date:',
                            ),
                            pw.SizedBox(height: 5),
                            pw.Text(
                              style: pw.TextStyle(
                                font: fontBold,
                                fontSize: 10,
                              ),
                              formatDateTime(
                                receipt.createdAt,
                              ),
                            ),
                          ],
                        ),
                      ),
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment:
                              pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              style: pw.TextStyle(
                                font: fontRegular,
                                fontSize: 9,
                              ),
                              'Time:',
                            ),
                            pw.SizedBox(height: 5),
                            pw.Text(
                              style: pw.TextStyle(
                                font: fontBold,
                                fontSize: 10,
                              ),
                              formatTime(receipt.createdAt),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 5),
                  pw.Divider(),

                  pw.Text(
                    'Items:',
                    style: pw.TextStyle(font: fontBold),
                  ),
                  pw.SizedBox(height: 5),

                  ...records.map(
                    (record) => pw.Padding(
                      padding:
                          const pw.EdgeInsets.symmetric(
                            vertical: 3,
                          ),
                      child: pw.Row(
                        mainAxisAlignment:
                            pw
                                .MainAxisAlignment
                                .spaceBetween,
                        children: [
                          pw.Expanded(
                            flex: 5,
                            child: pw.Text(
                              '${record.productName} ',
                            ),
                          ),
                          pw.Expanded(
                            flex: 1,
                            child: pw.Text(
                              '( ${record.quantity.toStringAsFixed(0)} ) ',
                            ),
                          ),
                          pw.Expanded(
                            flex: 3,
                            child: pw.Text(
                              style: pw.TextStyle(
                                font: fontRegular,
                                fontSize: 10,
                              ),
                              formatMoneyMid(
                                record.revenue,
                                context,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  pw.SizedBox(height: 12),
                  pw.Divider(),

                  pw.Row(
                    mainAxisAlignment:
                        pw.MainAxisAlignment.spaceEvenly,
                    children: [
                      pw.Expanded(
                        flex: 2,
                        child: pw.Text(
                          style: pw.TextStyle(
                            font: fontRegular,
                            fontSize: 9,
                          ),
                          'Subtotal:',
                        ),
                      ),
                      pw.Expanded(
                        flex: 1,
                        child: pw.Text(
                          style: pw.TextStyle(
                            font: fontRegular,
                            fontSize: 10,
                          ),
                          formatMoneyMid(
                            returnReceiptProvider(
                              context,
                              listen: false,
                            ).getSubTotalRevenueForReceipt(
                              context,
                              records,
                            ),
                            context,
                          ),
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 5),
                  pw.Row(
                    mainAxisAlignment:
                        pw.MainAxisAlignment.spaceEvenly,
                    children: [
                      pw.Expanded(
                        flex: 2,
                        child: pw.Text(
                          style: pw.TextStyle(
                            font: fontRegular,
                            fontSize: 9,
                          ),
                          'Discount:',
                        ),
                      ),
                      pw.Expanded(
                        flex: 1,
                        child: pw.Text(
                          style: pw.TextStyle(
                            font: fontRegular,
                            fontSize: 10,
                          ),
                          formatMoneyMid(
                            returnReceiptProvider(
                                  context,
                                  listen: false,
                                ).getTotalMainRevenueReceipt(
                                  records,
                                  context,
                                ) -
                                returnReceiptProvider(
                                  context,
                                  listen: false,
                                ).getSubTotalRevenueForReceipt(
                                  context,
                                  records,
                                ),
                            context,
                          ),
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 5),
                  pw.Row(
                    mainAxisAlignment:
                        pw.MainAxisAlignment.spaceEvenly,
                    children: [
                      pw.Expanded(
                        flex: 2,
                        child: pw.Text(
                          style: pw.TextStyle(
                            font: fontRegular,
                            fontSize: 10,
                          ),
                          'Total:',
                        ),
                      ),
                      pw.Expanded(
                        flex: 1,
                        child: pw.Text(
                          style: pw.TextStyle(
                            font: fontBold,
                            fontSize: 12,
                          ),
                          formatMoneyMid(
                            returnReceiptProvider(
                              context,
                              listen: false,
                            ).getTotalMainRevenueReceipt(
                              records,
                              context,
                            ),
                            context,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            pw.Expanded(child: pw.Spacer()),
          ],
    ),
  );

  return pdf.save();
}

Future<void> printWithRawBT(
// Uint8List pdfBytes,
{
  required String fileName,
  required TempMainReceipt receipt,
  required List<TempProductSaleRecord> records,
  required TempShopClass shop,
  required BuildContext context,
  required int printerType,
}) async {
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/$fileName.pdf');

  var pdfBytes = await _buildPdfRoll(
    receipt,
    records,
    shop,
    context,
    printerType,
  );

  await file.writeAsBytes(pdfBytes);

  // This will prompt Android to open the file with available apps (including RawBT)
  final result = await OpenFile.open(file.path);
  print(
    result.message,
  ); // Optional: See what app handled it
}

Future<Uint8List> _buildPdfRoll(
  TempMainReceipt receipt,
  List<TempProductSaleRecord> records,
  TempShopClass shop,
  BuildContext context,
  int printerType,
) async {
  double headingText = printerType == 1 ? 12 : 14;
  double parText = printerType == 1 ? 7 : 9;
  double parTextAlt = printerType == 1 ? 5 : 7;
  double totalText = printerType == 1 ? 8 : 10;
  final pdf = pw.Document();

  // Load Plus Jakarta Sans from assets
  final fontRegular = pw.Font.ttf(
    await rootBundle.load(
      'assets/fonts/PlusJakartaSans-Regular.ttf',
    ),
  );
  final fontBold = pw.Font.ttf(
    await rootBundle.load(
      'assets/fonts/PlusJakartaSans-Bold.ttf',
    ),
  );

  pdf.addPage(
    pw.Page(
      pageFormat:
          printerType == 1
              ? PdfPageFormat.roll57
              : PdfPageFormat.roll80,
      margin: const pw.EdgeInsets.only(
        left: 15,
        top: 15,
        right: 15,
        bottom: 10,
      ),

      // 🔹 HEADER
      build:
          (pw.Context pdfContext) => pw.DefaultTextStyle(
            style: pw.TextStyle(
              font: fontRegular,
              fontSize: 10,
            ),
            child: pw.Column(
              crossAxisAlignment:
                  pw.CrossAxisAlignment.center,
              children: [
                pw.Column(
                  crossAxisAlignment:
                      pw.CrossAxisAlignment.center,
                  children: [
                    pw.Column(
                      // mainAxisAlignment:
                      //     pw.MainAxisAlignment.start,
                      children: [
                        pw.Text(
                          textAlign: pw.TextAlign.center,
                          shop.name,
                          style: pw.TextStyle(
                            font: fontBold,
                            fontSize: headingText,
                          ),
                          // maxLines: 2,
                          overflow: pw.TextOverflow.clip,
                        ),
                        pw.SizedBox(height: 1),
                        pw.Text(
                          textAlign: pw.TextAlign.center,
                          shop.email,
                          style: pw.TextStyle(
                            font: fontRegular,
                            fontSize: parText,
                          ),
                          overflow: pw.TextOverflow.clip,
                        ),
                        pw.SizedBox(height: 1),

                        pw.Text(
                          textAlign: pw.TextAlign.center,
                          shop.phoneNumber ?? '',
                          style: pw.TextStyle(
                            font: fontRegular,
                            fontSize:
                                shop.phoneNumber == null
                                    ? 1
                                    : parText,
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 3),
                    pw.Divider(
                      color: PdfColor.fromHex('#1C1C1C'),
                      thickness: 0.5,
                      height: 4,
                    ),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment:
                      pw.MainAxisAlignment.center,
                  children: [
                    pw.Text(
                      textAlign: pw.TextAlign.center,
                      receipt.isInvoice
                          ? 'Generated Invoice'
                          : 'Payment Receipt',
                      style: pw.TextStyle(
                        font: fontRegular,
                        fontSize: parText,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 2),
                pw.Divider(
                  color: PdfColor.fromHex('#1C1C1C'),
                  thickness: 0.5,
                  height: 3,
                ),
                pw.SizedBox(height: 2),
                pw.Row(
                  mainAxisAlignment:
                      pw.MainAxisAlignment.spaceEvenly,
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment:
                            pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            style: pw.TextStyle(
                              font: fontRegular,
                              fontSize: parText,
                            ),
                            'Staff Name:',
                          ),
                          pw.SizedBox(height: 1),
                          pw.Text(
                            style: pw.TextStyle(
                              font: fontBold,
                              fontSize: parText,
                            ),
                            receipt.staffName,
                          ),
                        ],
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment:
                            pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            style: pw.TextStyle(
                              font: fontRegular,
                              fontSize: parText,
                            ),
                            'Customer Name:',
                          ),
                          pw.SizedBox(height: 1),
                          pw.Text(
                            style: pw.TextStyle(
                              font: fontBold,
                              fontSize: parText,
                            ),
                            receipt.customerName ??
                                'Not Set',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                pw.Builder(
                  builder: (pw.Context pdfContext) {
                    if (receipt.isInvoice) {
                      return pw.Container();
                    } else {
                      return pw.Column(
                        children: [
                          pw.SizedBox(height: 3),
                          pw.Row(
                            mainAxisAlignment:
                                pw
                                    .MainAxisAlignment
                                    .spaceEvenly,
                            children: [
                              pw.Expanded(
                                child: pw.Column(
                                  crossAxisAlignment:
                                      pw
                                          .CrossAxisAlignment
                                          .start,
                                  children: [
                                    pw.Text(
                                      style: pw.TextStyle(
                                        font: fontRegular,
                                        fontSize: parText,
                                      ),
                                      'Payment Method:',
                                    ),
                                    pw.SizedBox(height: 1),
                                    pw.Text(
                                      style: pw.TextStyle(
                                        font: fontBold,
                                        fontSize: parText,
                                      ),
                                      receipt.paymentMethod,
                                    ),
                                  ],
                                ),
                              ),
                              pw.Expanded(
                                child: pw.Column(
                                  crossAxisAlignment:
                                      pw
                                          .CrossAxisAlignment
                                          .start,
                                  children: [
                                    pw.Text(
                                      style: pw.TextStyle(
                                        font: fontRegular,
                                        fontSize: parText,
                                      ),
                                      'Amount(s):',
                                    ),
                                    pw.SizedBox(height: 1),
                                    pw.Column(
                                      crossAxisAlignment:
                                          pw
                                              .CrossAxisAlignment
                                              .start,
                                      children: [
                                        pw.Text(
                                          style: pw.TextStyle(
                                            font:
                                                fontRegular,
                                            fontSize:
                                                parTextAlt,
                                          ),
                                          'Cash: ${formatMoneyMid(receipt.cashAlt, context)}',
                                        ),
                                        pw.Text(
                                          style: pw.TextStyle(
                                            font:
                                                fontRegular,
                                            fontSize:
                                                parTextAlt,
                                          ),
                                          'Bank: ${formatMoneyMid(receipt.bank, context)}',
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    }
                  },
                ),
                pw.SizedBox(height: 3),
                pw.Row(
                  mainAxisAlignment:
                      pw.MainAxisAlignment.spaceEvenly,
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment:
                            pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            style: pw.TextStyle(
                              font: fontRegular,
                              fontSize: parText,
                            ),
                            'Date:',
                          ),
                          pw.SizedBox(height: 1),
                          pw.Text(
                            style: pw.TextStyle(
                              font: fontBold,
                              fontSize: parText,
                            ),
                            formatDateTime(
                              receipt.createdAt,
                            ),
                          ),
                        ],
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment:
                            pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            style: pw.TextStyle(
                              font: fontRegular,
                              fontSize: parText,
                            ),
                            'Time:',
                          ),
                          pw.SizedBox(height: 1),
                          pw.Text(
                            style: pw.TextStyle(
                              font: fontBold,
                              fontSize: parText,
                            ),
                            formatTime(receipt.createdAt),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 3),
                pw.Divider(thickness: 0.6, height: 6),

                pw.Row(
                  children: [
                    pw.Text(
                      'Items:',
                      style: pw.TextStyle(
                        fontSize: parText,
                        font: fontBold,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 1),

                ...records.map(
                  (record) => pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(
                      vertical: 2,
                    ),
                    child: pw.Row(
                      mainAxisAlignment:
                          pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Expanded(
                          flex: 5,
                          child: pw.Text(
                            style: pw.TextStyle(
                              fontSize: parText,
                            ),
                            '${record.productName} ',
                          ),
                        ),
                        pw.Expanded(
                          flex: 1,
                          child: pw.Text(
                            style: pw.TextStyle(
                              fontSize: parText,
                            ),
                            '( ${record.quantity.toStringAsFixed(0)} ) ',
                          ),
                        ),
                        pw.Expanded(
                          flex: 3,
                          child: pw.Text(
                            style: pw.TextStyle(
                              fontSize: parText,
                            ),
                            formatMoneyMid(
                              record.revenue,
                              context,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                pw.SizedBox(height: 3),
                pw.Divider(thickness: 0.6, height: 10),

                pw.Row(
                  mainAxisAlignment:
                      pw.MainAxisAlignment.spaceEvenly,
                  children: [
                    pw.Expanded(
                      flex: 9,
                      child: pw.Text(
                        style: pw.TextStyle(
                          font: fontRegular,
                          fontSize: parText,
                        ),
                        'Subtotal:',
                      ),
                    ),
                    pw.Expanded(
                      flex: 7,
                      child: pw.Text(
                        style: pw.TextStyle(
                          font: fontRegular,
                          fontSize: parText,
                        ),
                        formatMoneyMid(
                          returnReceiptProvider(
                            context,
                            listen: false,
                          ).getSubTotalRevenueForReceipt(
                            context,
                            records,
                          ),
                          context,
                        ),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 1),
                pw.Row(
                  mainAxisAlignment:
                      pw.MainAxisAlignment.spaceEvenly,
                  children: [
                    pw.Expanded(
                      flex: 9,
                      child: pw.Text(
                        style: pw.TextStyle(
                          font: fontRegular,
                          fontSize: parText,
                        ),
                        'Discount:',
                      ),
                    ),
                    pw.Expanded(
                      flex: 7,
                      child: pw.Text(
                        style: pw.TextStyle(
                          font: fontRegular,
                          fontSize: parText,
                        ),
                        formatMoneyMid(
                          returnReceiptProvider(
                                context,
                                listen: false,
                              ).getTotalMainRevenueReceipt(
                                records,
                                context,
                              ) -
                              returnReceiptProvider(
                                context,
                                listen: false,
                              ).getSubTotalRevenueForReceipt(
                                context,
                                records,
                              ),
                          context,
                        ),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 1),
                pw.Row(
                  mainAxisAlignment:
                      pw.MainAxisAlignment.spaceEvenly,
                  children: [
                    pw.Expanded(
                      flex: 9,
                      child: pw.Text(
                        style: pw.TextStyle(
                          font: fontRegular,
                          fontSize: parText,
                        ),
                        'Total:',
                      ),
                    ),
                    pw.Expanded(
                      flex: 7,
                      child: pw.Text(
                        style: pw.TextStyle(
                          font: fontBold,
                          fontSize: totalText,
                        ),
                        formatMoneyMid(
                          returnReceiptProvider(
                            context,
                            listen: false,
                          ).getTotalMainRevenueReceipt(
                            records,
                            context,
                          ),
                          context,
                        ),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 10),
              ],
            ),
          ),

      // pw.Expanded(child: pw.Spacer()),
    ),
  );

  return pdf.save();
}

void downloadPdfWeb({
  required TempMainReceipt receipt,
  required List<TempProductSaleRecord> records,
  required TempShopClass shop,
  required BuildContext context,
  required String filename,
}) async {
  try {
    print('Begin Download');
    final pdfBytes = await _buildPdf(
      receipt,
      records,
      returnShopProvider(context, listen: false).userShop!,
      context,
    );
    final blob = html.Blob([pdfBytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);

    final anchor =
        html.AnchorElement(href: url)
          ..download = filename
          ..style.display = 'none';

    html.document.body?.append(anchor);
    anchor.click();
    anchor.remove();

    html.Url.revokeObjectUrl(url);

    if (context.mounted) {
      returnReceiptProvider(
        context,
        listen: false,
      ).toggleIsLoading(false);
    }
  } catch (e, stackTrace) {
    print('❌ Error downloading PDF: $e\n$stackTrace');
  }
}

void downloadPdfWebRoll({
  required TempMainReceipt receipt,
  required List<TempProductSaleRecord> records,
  required TempShopClass shop,
  required BuildContext context,
  required String filename,
  required int printType,
}) async {
  try {
    print('Begin Download');
    final pdfBytes = await _buildPdfRoll(
      receipt,
      records,
      returnShopProvider(context, listen: false).userShop!,
      context,
      printType,
    );
    final blob = html.Blob([pdfBytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);

    final anchor =
        html.AnchorElement(href: url)
          ..download = filename
          ..target = 'blank'
          ..style.display = 'none';

    html.document.body?.append(anchor);
    anchor.click();
    anchor.remove();

    html.Url.revokeObjectUrl(url);
    if (context.mounted) {
      returnReceiptProvider(
        context,
        listen: false,
      ).toggleIsLoading(false);
    }
  } catch (e, stackTrace) {
    print('❌ Error downloading PDF: $e\n$stackTrace');
  }
}

//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
// PRODUCT RECORD PDF GENERATOR

Future<void> generateAndPreviewPdfProducts({
  required List<TempProductClass> products,
  required TempShopClass shop,
  required BuildContext context,
}) async {
  // 1. Build the PDF once (fastest way)
  returnData(context, listen: false).toggleIsLoading(true);
  final Uint8List pdfBytes = await _buildPdfProducts(
    products,
    shop,
    context,
  );

  // 2. Open native print/share/save dialog (cross-platform)
  await Printing.layoutPdf(onLayout: (_) async => pdfBytes);
  if (context.mounted) {
    returnData(
      context,
      listen: false,
    ).toggleIsLoading(false);
  }
}

Future<Uint8List> _buildPdfProducts(
  List<TempProductClass> products,
  TempShopClass shop,
  BuildContext context,
) async {
  int inStock() {
    int tempStock = 0;
    for (var element in products) {
      if ((element.quantity ?? 0) > 0) {
        tempStock += 1;
      }
    }
    return tempStock;
  }

  int lowStock() {
    int tempStock = 0;
    for (var element in products) {
      if ((element.quantity ?? 0) <=
              (element.lowQtty ?? 0) &&
          element.quantity != 0) {
        tempStock += 1;
      }
    }
    return tempStock;
  }

  int outOfStock() {
    int tempStock = 0;
    for (var element in products) {
      if (element.quantity == 0) {
        tempStock += 1;
      }
    }
    return tempStock;
  }

  int isManaged() {
    int tempStock = 0;
    for (var element in products) {
      if (element.isManaged) {
        tempStock += 1;
      }
    }
    return tempStock;
  }

  int unManaged() {
    int tempStock = 0;
    for (var element in products) {
      if (!element.isManaged) {
        tempStock += 1;
      }
    }
    return tempStock;
  }

  double totalQuantity() {
    double tempQtty = 0;
    for (var element in products) {
      tempQtty += element.quantity ?? 0;
    }
    return tempQtty;
  }

  double totalSellingPrice() {
    double tempQtty = 0;
    for (var element in products) {
      tempQtty += element.sellingPrice ?? 0;
    }
    return tempQtty;
  }

  double totalCostPrice() {
    double tempQtty = 0;
    for (var element in products) {
      tempQtty += element.costPrice;
    }
    return tempQtty;
  }

  final pdf = pw.Document();

  // Load Plus Jakarta Sans from assets
  final fontRegular = pw.Font.ttf(
    await rootBundle.load(
      'assets/fonts/PlusJakartaSans-Regular.ttf',
    ),
  );
  final fontBold = pw.Font.ttf(
    await rootBundle.load(
      'assets/fonts/PlusJakartaSans-Bold.ttf',
    ),
  );

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4.landscape,
      margin: const pw.EdgeInsets.only(
        left: 30,
        top: 30,
        right: 30,
        bottom: 10,
      ),
      // 🔹 HEADER
      header:
          (context) => pw.Column(
            crossAxisAlignment:
                pw.CrossAxisAlignment.center,
            children: [
              pw.Row(
                mainAxisAlignment:
                    pw.MainAxisAlignment.center,
                children: [
                  pw.Column(
                    children: [
                      pw.Text(
                        textAlign: pw.TextAlign.center,
                        shop.name,
                        style: pw.TextStyle(
                          font: fontBold,
                          fontSize: 16,
                        ),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        textAlign: pw.TextAlign.center,
                        shop.email,
                        style: pw.TextStyle(
                          font: fontRegular,
                          fontSize: 9,
                        ),
                      ),
                      pw.SizedBox(height: 5),

                      pw.Text(
                        textAlign: pw.TextAlign.center,
                        shop.phoneNumber ?? '',
                        style: pw.TextStyle(
                          font: fontRegular,
                          fontSize:
                              shop.phoneNumber == null
                                  ? 1
                                  : 9,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 5),
              pw.Divider(
                color: PdfColor.fromHex('#D3D3D3'),
                thickness: 0.5,
              ),
            ],
          ),
      // 🔹 FOOTER
      footer:
          (context) => pw.Column(
            children: [
              pw.Divider(),
              pw.SizedBox(height: 5),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Row(
                  mainAxisAlignment:
                      pw.MainAxisAlignment.center,
                  children: [
                    pw.Text(
                      '( Page ${context.pageNumber} of ${context.pagesCount} )',
                      style: pw.TextStyle(
                        font: fontRegular,
                        fontSize: 9,
                      ),
                    ),
                    pw.SizedBox(width: 15),
                    pw.Text(
                      'Created by $appName Solutions - ( www.stockallapp.com )',
                      style: pw.TextStyle(
                        font: fontRegular,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
      build:
          (pw.Context pdfContext) => [
            pw.DefaultTextStyle(
              style: pw.TextStyle(
                font: fontRegular,
                fontSize: 12,
              ),
              child: pw.Column(
                crossAxisAlignment:
                    pw.CrossAxisAlignment.start,
                children: [
                  pw.Padding(
                    padding: pw.EdgeInsets.symmetric(
                      horizontal: 15,
                    ),
                    child: pw.Row(
                      mainAxisAlignment:
                          pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Column(
                          children: [
                            pw.Text('Total Products'),
                            pw.Text(
                              style: pw.TextStyle(
                                font: fontBold,
                                fontSize: 15,
                              ),
                              products.length.toString(),
                            ),
                          ],
                        ),
                        pw.Column(
                          children: [
                            pw.Text('Total In Stock'),
                            pw.Text(
                              style: pw.TextStyle(
                                font: fontBold,
                                fontSize: 15,
                              ),
                              inStock().toString(),
                            ),
                          ],
                        ),
                        pw.Column(
                          children: [
                            pw.Text('Low On Stock'),
                            pw.Text(
                              style: pw.TextStyle(
                                font: fontBold,
                                fontSize: 15,
                              ),
                              lowStock().toString(),
                            ),
                          ],
                        ),
                        pw.Column(
                          children: [
                            pw.Text('Out of Stock'),
                            pw.Text(
                              style: pw.TextStyle(
                                font: fontBold,
                                fontSize: 15,
                              ),
                              outOfStock().toString(),
                            ),
                          ],
                        ),
                        pw.Column(
                          children: [
                            pw.Text('Is Managed'),
                            pw.Text(
                              style: pw.TextStyle(
                                font: fontBold,
                                fontSize: 15,
                              ),
                              isManaged().toString(),
                            ),
                          ],
                        ),
                        pw.Column(
                          children: [
                            pw.Text('Not Managed'),
                            pw.Text(
                              style: pw.TextStyle(
                                font: fontBold,
                                fontSize: 15,
                              ),
                              unManaged().toString(),
                            ),
                          ],
                        ),
                        pw.Column(
                          children: [
                            pw.Text('Expired'),
                            pw.Text(
                              style: pw.TextStyle(
                                font: fontBold,
                                fontSize: 15,
                              ),
                              products
                                  .where(
                                    (item) =>
                                        item.expiryDate !=
                                            null &&
                                        getDayDifference(
                                              item.expiryDate ??
                                                  DateTime.now(),
                                            ) ==
                                            0,
                                  )
                                  .toList()
                                  .length
                                  .toString(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Divider(
                    color: PdfColor.fromHex('#D3D3D3'),
                    thickness: 0.5,
                  ),
                  pw.SizedBox(height: 10),

                  pw.Container(
                    child: pw.Table(
                      columnWidths: {
                        0: pw.FlexColumnWidth(1.2),
                        1: pw.FlexColumnWidth(6),
                        2: pw.FlexColumnWidth(2),
                        3: pw.FlexColumnWidth(5),
                        4: pw.FlexColumnWidth(5),
                        5: pw.FlexColumnWidth(3),
                        6: pw.FlexColumnWidth(3),
                        7: pw.FlexColumnWidth(3),
                        8: pw.FlexColumnWidth(2.5),
                      },
                      border: pw.TableBorder.all(),
                      children: [
                        pw.TableRow(
                          verticalAlignment:
                              pw
                                  .TableCellVerticalAlignment
                                  .middle,
                          children: [
                            pw.Padding(
                              padding: pw
                                  .EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 10,
                              ),
                              child: pw.Text(
                                style: pw.TextStyle(
                                  font: fontBold,
                                ),
                                'S/N',
                              ),
                            ),
                            pw.Padding(
                              padding: pw
                                  .EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 10,
                              ),
                              child: pw.Text(
                                style: pw.TextStyle(
                                  font: fontBold,
                                ),
                                'Item Name',
                              ),
                            ),
                            pw.Padding(
                              padding: pw
                                  .EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 10,
                              ),
                              child: pw.Text(
                                style: pw.TextStyle(
                                  font: fontBold,
                                ),
                                'Qtty',
                              ),
                            ),
                            pw.Padding(
                              padding: pw
                                  .EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 10,
                              ),
                              child: pw.Text(
                                style: pw.TextStyle(
                                  font: fontBold,
                                ),
                                'Selling Price',
                              ),
                            ),
                            pw.Padding(
                              padding: pw
                                  .EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 10,
                              ),
                              child: pw.Text(
                                style: pw.TextStyle(
                                  font: fontBold,
                                ),
                                'Cost Price',
                              ),
                            ),
                            pw.Padding(
                              padding: pw
                                  .EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 10,
                              ),
                              child: pw.Text(
                                style: pw.TextStyle(
                                  font: fontBold,
                                ),
                                'Unit',
                              ),
                            ),
                            pw.Padding(
                              padding: pw
                                  .EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 10,
                              ),
                              child: pw.Text(
                                style: pw.TextStyle(
                                  font: fontBold,
                                ),
                                'Category',
                              ),
                            ),
                            pw.Padding(
                              padding: pw
                                  .EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 10,
                              ),
                              child: pw.Text(
                                style: pw.TextStyle(
                                  font: fontBold,
                                ),
                                'Expiry Date',
                              ),
                            ),
                            pw.Padding(
                              padding: pw
                                  .EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 10,
                              ),
                              child: pw.Text(
                                style: pw.TextStyle(
                                  font: fontBold,
                                ),
                                'Managed',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  pw.Table(
                    columnWidths: {
                      0: pw.FlexColumnWidth(1.2),
                      1: pw.FlexColumnWidth(6),
                      2: pw.FlexColumnWidth(2),
                      3: pw.FlexColumnWidth(5),
                      4: pw.FlexColumnWidth(5),
                      5: pw.FlexColumnWidth(3),
                      6: pw.FlexColumnWidth(3),
                      7: pw.FlexColumnWidth(3),
                      8: pw.FlexColumnWidth(2.5),
                    },
                    border: pw.TableBorder.all(),
                    children:
                        products.map((product) {
                          return pw.TableRow(
                            verticalAlignment:
                                pw
                                    .TableCellVerticalAlignment
                                    .middle,
                            children: [
                              pw.Padding(
                                padding: pw
                                    .EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 5,
                                ),
                                child: pw.Text(
                                  (products.indexOf(
                                            product,
                                          ) +
                                          1)
                                      .toString(),
                                ),
                              ),
                              pw.Padding(
                                padding: pw
                                    .EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 5,
                                ),
                                child: pw.Text(
                                  product.name,
                                ),
                              ),
                              pw.Padding(
                                padding: pw
                                    .EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 5,
                                ),
                                child: pw.Text(
                                  (product.quantity ?? 0)
                                      .toStringAsFixed(0),
                                ),
                              ),
                              pw.Padding(
                                padding: pw
                                    .EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 5,
                                ),
                                child: pw.Text(
                                  formatMoneyMid(
                                    product.sellingPrice ??
                                        0,
                                    context,
                                  ),
                                ),
                              ),
                              pw.Padding(
                                padding: pw
                                    .EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 5,
                                ),
                                child: pw.Text(
                                  formatMoneyMid(
                                    product.costPrice,
                                    context,
                                  ),
                                ),
                              ),
                              pw.Padding(
                                padding: pw
                                    .EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 5,
                                ),
                                child: pw.Text(
                                  product.unit,
                                ),
                              ),
                              pw.Padding(
                                padding: pw
                                    .EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 5,
                                ),
                                child: pw.Text(
                                  product.category ??
                                      'Not Set',
                                ),
                              ),
                              pw.Padding(
                                padding: pw
                                    .EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 5,
                                ),
                                child: pw.Text(
                                  product.expiryDate != null
                                      ? getDayDifference(
                                                product.expiryDate ??
                                                    DateTime.now(),
                                              ) >=
                                              1
                                          ? formatDateTime(
                                            product.expiryDate ??
                                                DateTime.now(),
                                          )
                                          : 'Expired'
                                      : 'Not Set',
                                ),
                              ),
                              pw.Padding(
                                padding: pw
                                    .EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 5,
                                ),
                                child: pw.Text(
                                  product.isManaged
                                      .toString(),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                  ),
                  pw.Container(
                    child: pw.Table(
                      columnWidths: {
                        0: pw.FlexColumnWidth(1.2),
                        1: pw.FlexColumnWidth(6),
                        2: pw.FlexColumnWidth(2),
                        3: pw.FlexColumnWidth(5),
                        4: pw.FlexColumnWidth(5),
                        5: pw.FlexColumnWidth(3),
                        6: pw.FlexColumnWidth(3),
                        7: pw.FlexColumnWidth(3),
                        8: pw.FlexColumnWidth(2.5),
                      },
                      border: pw.TableBorder.all(),
                      children: [
                        pw.TableRow(
                          verticalAlignment:
                              pw
                                  .TableCellVerticalAlignment
                                  .middle,
                          children: [
                            pw.Padding(
                              padding: pw
                                  .EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 10,
                              ),
                              child: pw.Text(
                                style: pw.TextStyle(
                                  font: fontBold,
                                ),
                                '',
                              ),
                            ),
                            pw.Padding(
                              padding: pw
                                  .EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 10,
                              ),
                              child: pw.Text(
                                style: pw.TextStyle(
                                  font: fontBold,
                                  fontSize: 20,
                                ),
                                'Total',
                              ),
                            ),
                            pw.Padding(
                              padding: pw
                                  .EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 10,
                              ),
                              child: pw.Text(
                                style: pw.TextStyle(
                                  font: fontBold,
                                ),
                                totalQuantity()
                                    .toStringAsFixed(0),
                              ),
                            ),
                            pw.Padding(
                              padding: pw
                                  .EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 10,
                              ),
                              child: pw.Text(
                                style: pw.TextStyle(
                                  font: fontBold,
                                ),
                                formatMoneyMid(
                                  totalSellingPrice(),
                                  context,
                                ),
                              ),
                            ),
                            pw.Padding(
                              padding: pw
                                  .EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 10,
                              ),
                              child: pw.Text(
                                style: pw.TextStyle(
                                  font: fontBold,
                                ),
                                formatMoneyMid(
                                  totalCostPrice(),
                                  context,
                                ),
                              ),
                            ),
                            pw.Padding(
                              padding: pw
                                  .EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 10,
                              ),
                              child: pw.Text(
                                style: pw.TextStyle(
                                  font: fontBold,
                                ),
                                '',
                              ),
                            ),
                            pw.Padding(
                              padding: pw
                                  .EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 10,
                              ),
                              child: pw.Text(
                                style: pw.TextStyle(
                                  font: fontBold,
                                ),
                                '',
                              ),
                            ),
                            pw.Padding(
                              padding: pw
                                  .EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 10,
                              ),
                              child: pw.Text(
                                style: pw.TextStyle(
                                  font: fontBold,
                                ),
                                '',
                              ),
                            ),
                            pw.Padding(
                              padding: pw
                                  .EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 10,
                              ),
                              child: pw.Text(
                                style: pw.TextStyle(
                                  font: fontBold,
                                ),
                                '',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            pw.Expanded(child: pw.Spacer()),
          ],
    ),
  );

  return pdf.save();
}

void downloadPdfWebProducts({
  required List<TempProductClass> products,
  required TempShopClass shop,
  required BuildContext context,
  required String filename,
}) async {
  try {
    print('Begin Download');
    final pdfBytes = await _buildPdfProducts(
      products,
      returnShopProvider(context, listen: false).userShop!,
      context,
    );
    final blob = html.Blob([pdfBytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);

    final anchor =
        html.AnchorElement(href: url)
          ..download = filename
          ..target = 'blank'
          ..style.display = 'none';

    html.document.body?.append(anchor);
    anchor.click();
    anchor.remove();

    html.Url.revokeObjectUrl(url);
    if (context.mounted) {
      returnData(
        context,
        listen: false,
      ).toggleIsLoading(false);
    }
  } catch (e, stackTrace) {
    print('❌ Error downloading PDF: $e\n$stackTrace');
  }
}

//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
// SALES RECORD PDF GENERATOR

Future<void> generateAndPreviewPdfSales({
  required List<TempProductSaleRecord> records,
  required TempShopClass shop,
  required BuildContext context,
}) async {
  // 1. Build the PDF once (fastest way)
  returnSalesProvider(
    context,
    listen: false,
  ).toggleIsLoading(true);
  final Uint8List pdfBytes = await _buildPdfSales(
    records,
    shop,
    context,
  );

  // 2. Open native print/share/save dialog (cross-platform)
  await Printing.layoutPdf(onLayout: (_) async => pdfBytes);
  if (context.mounted) {
    returnData(
      context,
      listen: false,
    ).toggleIsLoading(false);
  }
}

Future<Uint8List> _buildPdfSales(
  List<TempProductSaleRecord> records,
  TempShopClass shop,
  BuildContext context,
) async {
  double totalQuantity() {
    double tempQtty = 0;
    for (var element in records) {
      tempQtty += element.quantity;
    }
    return tempQtty;
  }

  double totalSellingPrice() {
    double tempQtty = 0;
    for (var element in records) {
      tempQtty += element.revenue;
    }
    return tempQtty;
  }

  double totalCostPrice() {
    double tempQtty = 0;
    for (var element in records) {
      tempQtty += element.costPrice ?? 0;
    }
    return tempQtty;
  }

  double totalProfit() {
    double tempQtty = 0;
    for (var element in records) {
      if (element.costPrice != null) {
        tempQtty += element.revenue - element.costPrice!;
      }
    }
    return tempQtty;
  }

  String profit(
    TempProductSaleRecord record,
    BuildContext context,
  ) {
    String tempQtty =
        record.costPrice != null
            ? formatMoneyMid(
              (record.revenue - record.costPrice!),
              context,
            )
            : 'Nill';
    return tempQtty;
  }

  final pdf = pw.Document();

  // Load Plus Jakarta Sans from assets
  final fontRegular = pw.Font.ttf(
    await rootBundle.load(
      'assets/fonts/PlusJakartaSans-Regular.ttf',
    ),
  );
  final fontBold = pw.Font.ttf(
    await rootBundle.load(
      'assets/fonts/PlusJakartaSans-Bold.ttf',
    ),
  );

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4.landscape,
      margin: const pw.EdgeInsets.only(
        left: 30,
        top: 30,
        right: 30,
        bottom: 10,
      ),
      // 🔹 HEADER
      header:
          (context) => pw.Column(
            crossAxisAlignment:
                pw.CrossAxisAlignment.center,
            children: [
              pw.Row(
                mainAxisAlignment:
                    pw.MainAxisAlignment.center,
                children: [
                  pw.Column(
                    children: [
                      pw.Text(
                        textAlign: pw.TextAlign.center,
                        shop.name,
                        style: pw.TextStyle(
                          font: fontBold,
                          fontSize: 16,
                        ),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        textAlign: pw.TextAlign.center,
                        shop.email,
                        style: pw.TextStyle(
                          font: fontRegular,
                          fontSize: 9,
                        ),
                      ),
                      pw.SizedBox(height: 5),

                      pw.Text(
                        textAlign: pw.TextAlign.center,
                        shop.phoneNumber ?? '',
                        style: pw.TextStyle(
                          font: fontRegular,
                          fontSize:
                              shop.phoneNumber == null
                                  ? 1
                                  : 9,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 5),
              pw.Divider(
                color: PdfColor.fromHex('#D3D3D3'),
                thickness: 0.5,
              ),
            ],
          ),
      // 🔹 FOOTER
      footer:
          (context) => pw.Column(
            children: [
              pw.Divider(),
              pw.SizedBox(height: 5),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Row(
                  mainAxisAlignment:
                      pw.MainAxisAlignment.center,
                  children: [
                    pw.Text(
                      '( Page ${context.pageNumber} of ${context.pagesCount} )',
                      style: pw.TextStyle(
                        font: fontRegular,
                        fontSize: 9,
                      ),
                    ),
                    pw.SizedBox(width: 15),
                    pw.Text(
                      'Created by $appName Solutions - ( www.stockallapp.com )',
                      style: pw.TextStyle(
                        font: fontRegular,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
      build:
          (pw.Context pdfContext) => [
            pw.Builder(
              builder: (pw.Context pdfContext) {
                return pw.DefaultTextStyle(
                  style: pw.TextStyle(
                    font: fontRegular,
                    fontSize: 12,
                  ),
                  child: pw.Column(
                    crossAxisAlignment:
                        pw.CrossAxisAlignment.start,
                    children: [
                      pw.SizedBox(height: 10),
                      pw.Container(
                        child: pw.Table(
                          columnWidths: {
                            0: pw.FlexColumnWidth(1.2),
                            1: pw.FlexColumnWidth(6),
                            2: pw.FlexColumnWidth(2),
                            3: pw.FlexColumnWidth(5),
                            4: pw.FlexColumnWidth(5),
                            5: pw.FlexColumnWidth(5),
                            6: pw.FlexColumnWidth(3),
                            7: pw.FlexColumnWidth(3),
                          },
                          border: pw.TableBorder.all(),
                          children: [
                            pw.TableRow(
                              verticalAlignment:
                                  pw
                                      .TableCellVerticalAlignment
                                      .middle,
                              children: [
                                pw.Padding(
                                  padding: pw
                                      .EdgeInsets.symmetric(
                                    horizontal: 5,
                                    vertical: 10,
                                  ),
                                  child: pw.Text(
                                    style: pw.TextStyle(
                                      font: fontBold,
                                    ),
                                    'S/N',
                                  ),
                                ),
                                pw.Padding(
                                  padding: pw
                                      .EdgeInsets.symmetric(
                                    horizontal: 5,
                                    vertical: 10,
                                  ),
                                  child: pw.Text(
                                    style: pw.TextStyle(
                                      font: fontBold,
                                    ),
                                    'Item Name',
                                  ),
                                ),
                                pw.Padding(
                                  padding: pw
                                      .EdgeInsets.symmetric(
                                    horizontal: 5,
                                    vertical: 10,
                                  ),
                                  child: pw.Text(
                                    style: pw.TextStyle(
                                      font: fontBold,
                                    ),
                                    'Qtty',
                                  ),
                                ),
                                pw.Padding(
                                  padding: pw
                                      .EdgeInsets.symmetric(
                                    horizontal: 5,
                                    vertical: 10,
                                  ),
                                  child: pw.Text(
                                    style: pw.TextStyle(
                                      font: fontBold,
                                    ),
                                    'Selling Price',
                                  ),
                                ),
                                pw.Padding(
                                  padding: pw
                                      .EdgeInsets.symmetric(
                                    horizontal: 5,
                                    vertical: 10,
                                  ),
                                  child: pw.Text(
                                    style: pw.TextStyle(
                                      font: fontBold,
                                    ),
                                    'Cost Price',
                                  ),
                                ),
                                pw.Padding(
                                  padding: pw
                                      .EdgeInsets.symmetric(
                                    horizontal: 5,
                                    vertical: 10,
                                  ),
                                  child: pw.Text(
                                    style: pw.TextStyle(
                                      font: fontBold,
                                    ),
                                    'Profit',
                                  ),
                                ),
                                pw.Padding(
                                  padding: pw
                                      .EdgeInsets.symmetric(
                                    horizontal: 5,
                                    vertical: 10,
                                  ),
                                  child: pw.Text(
                                    style: pw.TextStyle(
                                      font: fontBold,
                                    ),
                                    'Date',
                                  ),
                                ),
                                pw.Padding(
                                  padding: pw
                                      .EdgeInsets.symmetric(
                                    horizontal: 5,
                                    vertical: 10,
                                  ),
                                  child: pw.Text(
                                    style: pw.TextStyle(
                                      font: fontBold,
                                    ),
                                    'Time',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      pw.Table(
                        columnWidths: {
                          0: pw.FlexColumnWidth(1.2),
                          1: pw.FlexColumnWidth(6),
                          2: pw.FlexColumnWidth(2),
                          3: pw.FlexColumnWidth(5),
                          4: pw.FlexColumnWidth(5),
                          5: pw.FlexColumnWidth(5),
                          6: pw.FlexColumnWidth(3),
                          7: pw.FlexColumnWidth(3),
                        },
                        border: pw.TableBorder.all(),
                        children:
                            records.map((record) {
                              return pw.TableRow(
                                verticalAlignment:
                                    pw
                                        .TableCellVerticalAlignment
                                        .middle,
                                children: [
                                  pw.Padding(
                                    padding: pw
                                        .EdgeInsets.symmetric(
                                      horizontal: 5,
                                      vertical: 5,
                                    ),
                                    child: pw.Text(
                                      (records.indexOf(
                                                record,
                                              ) +
                                              1)
                                          .toString(),
                                    ),
                                  ),
                                  pw.Padding(
                                    padding: pw
                                        .EdgeInsets.symmetric(
                                      horizontal: 5,
                                      vertical: 5,
                                    ),
                                    child: pw.Text(
                                      record.productName,
                                    ),
                                  ),
                                  pw.Padding(
                                    padding: pw
                                        .EdgeInsets.symmetric(
                                      horizontal: 5,
                                      vertical: 5,
                                    ),
                                    child: pw.Text(
                                      (record.quantity)
                                          .toStringAsFixed(
                                            0,
                                          ),
                                    ),
                                  ),
                                  pw.Padding(
                                    padding: pw
                                        .EdgeInsets.symmetric(
                                      horizontal: 5,
                                      vertical: 5,
                                    ),
                                    child: pw.Text(
                                      formatMoneyMid(
                                        record.revenue,
                                        context,
                                      ),
                                    ),
                                  ),
                                  pw.Padding(
                                    padding: pw
                                        .EdgeInsets.symmetric(
                                      horizontal: 5,
                                      vertical: 5,
                                    ),
                                    child: pw.Text(
                                      formatMoneyMid(
                                        record.costPrice ??
                                            0,
                                        context,
                                      ),
                                    ),
                                  ),
                                  pw.Padding(
                                    padding: pw
                                        .EdgeInsets.symmetric(
                                      horizontal: 5,
                                      vertical: 5,
                                    ),
                                    child: pw.Text(
                                      profit(
                                        record,
                                        context,
                                      ),
                                    ),
                                  ),
                                  pw.Padding(
                                    padding: pw
                                        .EdgeInsets.symmetric(
                                      horizontal: 5,
                                      vertical: 5,
                                    ),
                                    child: pw.Text(
                                      formatDateWithoutYear(
                                        record.createdAt,
                                      ),
                                    ),
                                  ),
                                  pw.Padding(
                                    padding: pw
                                        .EdgeInsets.symmetric(
                                      horizontal: 5,
                                      vertical: 5,
                                    ),
                                    child: pw.Text(
                                      formatTime(
                                        record.createdAt,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                      ),
                      pw.Container(
                        child: pw.Table(
                          columnWidths: {
                            0: pw.FlexColumnWidth(1.2),
                            1: pw.FlexColumnWidth(6),
                            2: pw.FlexColumnWidth(2),
                            3: pw.FlexColumnWidth(5),
                            4: pw.FlexColumnWidth(5),
                            5: pw.FlexColumnWidth(5),
                            6: pw.FlexColumnWidth(3),
                            7: pw.FlexColumnWidth(3),
                          },
                          border: pw.TableBorder.all(),
                          children: [
                            pw.TableRow(
                              verticalAlignment:
                                  pw
                                      .TableCellVerticalAlignment
                                      .middle,
                              children: [
                                pw.Padding(
                                  padding: pw
                                      .EdgeInsets.symmetric(
                                    horizontal: 5,
                                    vertical: 10,
                                  ),
                                  child: pw.Text(
                                    style: pw.TextStyle(
                                      font: fontBold,
                                    ),
                                    '',
                                  ),
                                ),
                                pw.Padding(
                                  padding: pw
                                      .EdgeInsets.symmetric(
                                    horizontal: 5,
                                    vertical: 10,
                                  ),
                                  child: pw.Text(
                                    style: pw.TextStyle(
                                      font: fontBold,
                                      fontSize: 20,
                                    ),
                                    'Total',
                                  ),
                                ),
                                pw.Padding(
                                  padding: pw
                                      .EdgeInsets.symmetric(
                                    horizontal: 5,
                                    vertical: 10,
                                  ),
                                  child: pw.Text(
                                    style: pw.TextStyle(
                                      font: fontBold,
                                    ),
                                    totalQuantity()
                                        .toStringAsFixed(0),
                                  ),
                                ),
                                pw.Padding(
                                  padding: pw
                                      .EdgeInsets.symmetric(
                                    horizontal: 5,
                                    vertical: 10,
                                  ),
                                  child: pw.Text(
                                    style: pw.TextStyle(
                                      font: fontBold,
                                    ),
                                    formatMoneyMid(
                                      totalSellingPrice(),
                                      context,
                                    ),
                                  ),
                                ),
                                pw.Padding(
                                  padding: pw
                                      .EdgeInsets.symmetric(
                                    horizontal: 5,
                                    vertical: 10,
                                  ),
                                  child: pw.Text(
                                    style: pw.TextStyle(
                                      font: fontBold,
                                    ),
                                    formatMoneyMid(
                                      totalCostPrice(),
                                      context,
                                    ),
                                  ),
                                ),
                                pw.Padding(
                                  padding: pw
                                      .EdgeInsets.symmetric(
                                    horizontal: 5,
                                    vertical: 10,
                                  ),
                                  child: pw.Text(
                                    style: pw.TextStyle(
                                      font: fontBold,
                                    ),
                                    formatMoneyMid(
                                      totalProfit(),
                                      context,
                                    ),
                                  ),
                                ),
                                pw.Padding(
                                  padding: pw
                                      .EdgeInsets.symmetric(
                                    horizontal: 5,
                                    vertical: 10,
                                  ),
                                  child: pw.Text(
                                    style: pw.TextStyle(
                                      font: fontBold,
                                    ),
                                    '',
                                  ),
                                ),
                                pw.Padding(
                                  padding: pw
                                      .EdgeInsets.symmetric(
                                    horizontal: 5,
                                    vertical: 10,
                                  ),
                                  child: pw.Text(
                                    style: pw.TextStyle(
                                      font: fontBold,
                                    ),
                                    '',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            pw.Expanded(child: pw.Spacer()),
          ],
    ),
  );

  return pdf.save();
}

void downloadPdfWebSales({
  required List<TempProductSaleRecord> records,
  required TempShopClass shop,
  required BuildContext context,
  required String filename,
}) async {
  try {
    print('Begin Download');
    final pdfBytes = await _buildPdfSales(
      records,
      returnShopProvider(context, listen: false).userShop!,
      context,
    );
    final blob = html.Blob([pdfBytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);

    final anchor =
        html.AnchorElement(href: url)
          ..download = filename
          ..target = 'blank'
          ..style.display = 'none';

    html.document.body?.append(anchor);
    anchor.click();
    anchor.remove();

    html.Url.revokeObjectUrl(url);
    if (context.mounted) {
      returnSalesProvider(
        context,
        listen: false,
      ).toggleIsLoading(false);
    }
  } catch (e, stackTrace) {
    print('❌ Error downloading PDF: $e\n$stackTrace');
  }
}

//
//
//
//

Future<void> generateAndPreviewPdfSalesSummary({
  required List<ProductReportSummary> summary,
  required TempShopClass shop,
  required BuildContext context,
}) async {
  // 1. Build the PDF once (fastest way)
  returnSalesProvider(
    context,
    listen: false,
  ).toggleIsLoading(true);
  final Uint8List pdfBytes = await _buildPdfSalesSummary(
    summary,
    shop,
    context,
  );

  // 2. Open native print/share/save dialog (cross-platform)
  await Printing.layoutPdf(onLayout: (_) async => pdfBytes);
  if (context.mounted) {
    returnData(
      context,
      listen: false,
    ).toggleIsLoading(false);
  }
}

Future<Uint8List> _buildPdfSalesSummary(
  List<ProductReportSummary> summary,
  TempShopClass shop,
  BuildContext context,
) async {
  double totalQuantity() {
    double tempQtty = 0;
    for (var element in summary) {
      tempQtty += element.quantity;
    }
    return tempQtty;
  }

  double totalSellingPrice() {
    double tempQtty = 0;
    for (var element in summary) {
      tempQtty += element.total;
    }
    return tempQtty;
  }

  double totalCostPrice() {
    double tempQtty = 0;
    for (var element in summary) {
      tempQtty += element.costTotal;
    }
    return tempQtty;
  }

  double totalProfit() {
    double tempQtty = 0;
    for (var element in summary) {
      tempQtty += element.total - element.costTotal;
    }
    return tempQtty;
  }

  final pdf = pw.Document();

  // Load Plus Jakarta Sans from assets
  final fontRegular = pw.Font.ttf(
    await rootBundle.load(
      'assets/fonts/PlusJakartaSans-Regular.ttf',
    ),
  );
  final fontBold = pw.Font.ttf(
    await rootBundle.load(
      'assets/fonts/PlusJakartaSans-Bold.ttf',
    ),
  );

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4.landscape,
      margin: const pw.EdgeInsets.only(
        left: 30,
        top: 30,
        right: 30,
        bottom: 10,
      ),
      // 🔹 HEADER
      header:
          (context) => pw.Column(
            crossAxisAlignment:
                pw.CrossAxisAlignment.center,
            children: [
              pw.Row(
                mainAxisAlignment:
                    pw.MainAxisAlignment.center,
                children: [
                  pw.Column(
                    children: [
                      pw.Text(
                        textAlign: pw.TextAlign.center,
                        shop.name,
                        style: pw.TextStyle(
                          font: fontBold,
                          fontSize: 16,
                        ),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        textAlign: pw.TextAlign.center,
                        shop.email,
                        style: pw.TextStyle(
                          font: fontRegular,
                          fontSize: 9,
                        ),
                      ),
                      pw.SizedBox(height: 5),

                      pw.Text(
                        textAlign: pw.TextAlign.center,
                        shop.phoneNumber ?? '',
                        style: pw.TextStyle(
                          font: fontRegular,
                          fontSize:
                              shop.phoneNumber == null
                                  ? 1
                                  : 9,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 5),
              pw.Divider(
                color: PdfColor.fromHex('#D3D3D3'),
                thickness: 0.5,
              ),
            ],
          ),
      // 🔹 FOOTER
      footer:
          (context) => pw.Column(
            children: [
              pw.Divider(),
              pw.SizedBox(height: 5),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Row(
                  mainAxisAlignment:
                      pw.MainAxisAlignment.center,
                  children: [
                    pw.Text(
                      '( Page ${context.pageNumber} of ${context.pagesCount} )',
                      style: pw.TextStyle(
                        font: fontRegular,
                        fontSize: 9,
                      ),
                    ),
                    pw.SizedBox(width: 15),
                    pw.Text(
                      'Created by $appName Solutions - ( www.stockallapp.com )',
                      style: pw.TextStyle(
                        font: fontRegular,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
      build:
          (pw.Context pdfContext) => [
            pw.Builder(
              builder: (pw.Context pdfContext) {
                return pw.DefaultTextStyle(
                  style: pw.TextStyle(
                    font: fontRegular,
                    fontSize: 12,
                  ),
                  child: pw.Column(
                    crossAxisAlignment:
                        pw.CrossAxisAlignment.start,
                    children: [
                      pw.SizedBox(height: 10),
                      pw.Container(
                        child: pw.Table(
                          columnWidths: {
                            0: pw.FlexColumnWidth(1.2),
                            1: pw.FlexColumnWidth(6),
                            2: pw.FlexColumnWidth(2),
                            3: pw.FlexColumnWidth(5),
                            4: pw.FlexColumnWidth(5),
                            5: pw.FlexColumnWidth(5),
                          },
                          border: pw.TableBorder.all(),
                          children: [
                            pw.TableRow(
                              verticalAlignment:
                                  pw
                                      .TableCellVerticalAlignment
                                      .middle,
                              children: [
                                pw.Padding(
                                  padding: pw
                                      .EdgeInsets.symmetric(
                                    horizontal: 5,
                                    vertical: 10,
                                  ),
                                  child: pw.Text(
                                    style: pw.TextStyle(
                                      font: fontBold,
                                    ),
                                    'S/N',
                                  ),
                                ),
                                pw.Padding(
                                  padding: pw
                                      .EdgeInsets.symmetric(
                                    horizontal: 5,
                                    vertical: 10,
                                  ),
                                  child: pw.Text(
                                    style: pw.TextStyle(
                                      font: fontBold,
                                    ),
                                    'Item Name',
                                  ),
                                ),
                                pw.Padding(
                                  padding: pw
                                      .EdgeInsets.symmetric(
                                    horizontal: 5,
                                    vertical: 10,
                                  ),
                                  child: pw.Text(
                                    style: pw.TextStyle(
                                      font: fontBold,
                                    ),
                                    'Qtty',
                                  ),
                                ),
                                pw.Padding(
                                  padding: pw
                                      .EdgeInsets.symmetric(
                                    horizontal: 5,
                                    vertical: 10,
                                  ),
                                  child: pw.Text(
                                    style: pw.TextStyle(
                                      font: fontBold,
                                    ),
                                    'Selling Price',
                                  ),
                                ),
                                pw.Padding(
                                  padding: pw
                                      .EdgeInsets.symmetric(
                                    horizontal: 5,
                                    vertical: 10,
                                  ),
                                  child: pw.Text(
                                    style: pw.TextStyle(
                                      font: fontBold,
                                    ),
                                    'Cost Price',
                                  ),
                                ),
                                pw.Padding(
                                  padding: pw
                                      .EdgeInsets.symmetric(
                                    horizontal: 5,
                                    vertical: 10,
                                  ),
                                  child: pw.Text(
                                    style: pw.TextStyle(
                                      font: fontBold,
                                    ),
                                    'Profit',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      pw.Table(
                        columnWidths: {
                          0: pw.FlexColumnWidth(1.2),
                          1: pw.FlexColumnWidth(6),
                          2: pw.FlexColumnWidth(2),
                          3: pw.FlexColumnWidth(5),
                          4: pw.FlexColumnWidth(5),
                          5: pw.FlexColumnWidth(5),
                        },
                        border: pw.TableBorder.all(),
                        children:
                            summary.map((summ) {
                              return pw.TableRow(
                                verticalAlignment:
                                    pw
                                        .TableCellVerticalAlignment
                                        .middle,
                                children: [
                                  pw.Padding(
                                    padding: pw
                                        .EdgeInsets.symmetric(
                                      horizontal: 5,
                                      vertical: 5,
                                    ),
                                    child: pw.Text(
                                      (summary.indexOf(
                                                summ,
                                              ) +
                                              1)
                                          .toString(),
                                    ),
                                  ),
                                  pw.Padding(
                                    padding: pw
                                        .EdgeInsets.symmetric(
                                      horizontal: 5,
                                      vertical: 5,
                                    ),
                                    child: pw.Text(
                                      summ.productName,
                                    ),
                                  ),
                                  pw.Padding(
                                    padding: pw
                                        .EdgeInsets.symmetric(
                                      horizontal: 5,
                                      vertical: 5,
                                    ),
                                    child: pw.Text(
                                      (summ.quantity)
                                          .toStringAsFixed(
                                            0,
                                          ),
                                    ),
                                  ),
                                  pw.Padding(
                                    padding: pw
                                        .EdgeInsets.symmetric(
                                      horizontal: 5,
                                      vertical: 5,
                                    ),
                                    child: pw.Text(
                                      formatMoneyMid(
                                        summ.total,
                                        context,
                                      ),
                                    ),
                                  ),
                                  pw.Padding(
                                    padding: pw
                                        .EdgeInsets.symmetric(
                                      horizontal: 5,
                                      vertical: 5,
                                    ),
                                    child: pw.Text(
                                      formatMoneyMid(
                                        summ.costTotal,
                                        context,
                                      ),
                                    ),
                                  ),
                                  pw.Padding(
                                    padding: pw
                                        .EdgeInsets.symmetric(
                                      horizontal: 5,
                                      vertical: 5,
                                    ),
                                    child: pw.Text(
                                      formatMoneyMid(
                                        summ.profit,
                                        context,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                      ),
                      pw.Container(
                        child: pw.Table(
                          columnWidths: {
                            0: pw.FlexColumnWidth(1.2),
                            1: pw.FlexColumnWidth(6),
                            2: pw.FlexColumnWidth(2),
                            3: pw.FlexColumnWidth(5),
                            4: pw.FlexColumnWidth(5),
                            5: pw.FlexColumnWidth(5),
                          },
                          border: pw.TableBorder.all(),
                          children: [
                            pw.TableRow(
                              verticalAlignment:
                                  pw
                                      .TableCellVerticalAlignment
                                      .middle,
                              children: [
                                pw.Padding(
                                  padding: pw
                                      .EdgeInsets.symmetric(
                                    horizontal: 5,
                                    vertical: 10,
                                  ),
                                  child: pw.Text(
                                    style: pw.TextStyle(
                                      font: fontBold,
                                    ),
                                    '',
                                  ),
                                ),
                                pw.Padding(
                                  padding: pw
                                      .EdgeInsets.symmetric(
                                    horizontal: 5,
                                    vertical: 10,
                                  ),
                                  child: pw.Text(
                                    style: pw.TextStyle(
                                      font: fontBold,
                                      fontSize: 20,
                                    ),
                                    'Total',
                                  ),
                                ),
                                pw.Padding(
                                  padding: pw
                                      .EdgeInsets.symmetric(
                                    horizontal: 5,
                                    vertical: 10,
                                  ),
                                  child: pw.Text(
                                    style: pw.TextStyle(
                                      font: fontBold,
                                    ),
                                    totalQuantity()
                                        .toStringAsFixed(0),
                                  ),
                                ),
                                pw.Padding(
                                  padding: pw
                                      .EdgeInsets.symmetric(
                                    horizontal: 5,
                                    vertical: 10,
                                  ),
                                  child: pw.Text(
                                    style: pw.TextStyle(
                                      font: fontBold,
                                    ),
                                    formatMoneyMid(
                                      totalSellingPrice(),
                                      context,
                                    ),
                                  ),
                                ),
                                pw.Padding(
                                  padding: pw
                                      .EdgeInsets.symmetric(
                                    horizontal: 5,
                                    vertical: 10,
                                  ),
                                  child: pw.Text(
                                    style: pw.TextStyle(
                                      font: fontBold,
                                    ),
                                    formatMoneyMid(
                                      totalCostPrice(),
                                      context,
                                    ),
                                  ),
                                ),
                                pw.Padding(
                                  padding: pw
                                      .EdgeInsets.symmetric(
                                    horizontal: 5,
                                    vertical: 10,
                                  ),
                                  child: pw.Text(
                                    style: pw.TextStyle(
                                      font: fontBold,
                                    ),
                                    formatMoneyMid(
                                      totalProfit(),
                                      context,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            pw.Expanded(child: pw.Spacer()),
          ],
    ),
  );

  return pdf.save();
}

void downloadPdfWebSalesSummary({
  required List<ProductReportSummary> summary,
  required TempShopClass shop,
  required BuildContext context,
  required String filename,
}) async {
  try {
    print('Begin Download');
    final pdfBytes = await _buildPdfSalesSummary(
      summary,
      returnShopProvider(context, listen: false).userShop!,
      context,
    );
    final blob = html.Blob([pdfBytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);

    final anchor =
        html.AnchorElement(href: url)
          ..download = filename
          ..target = 'blank'
          ..style.display = 'none';

    html.document.body?.append(anchor);
    anchor.click();
    anchor.remove();

    html.Url.revokeObjectUrl(url);
    if (context.mounted) {
      returnSalesProvider(
        context,
        listen: false,
      ).toggleIsLoading(false);
    }
  } catch (e, stackTrace) {
    print('❌ Error downloading PDF: $e\n$stackTrace');
  }
}

//
//
//
//
//
//
//
//
//
//
//

Future<void> downloadApkFromApp() async {
  final url = Uri.parse(
    'https://stockallapp.com/downloads/stockall.apk',
  );

  if (await canLaunchUrl(url)) {
    await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    );
  } else {
    throw 'Could not launch $url';
  }
}
