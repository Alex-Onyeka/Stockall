import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:stockall/classes/currency_class.dart';
import 'package:stockall/classes/temp_main_receipt.dart';
import 'package:stockall/classes/temp_product_sale_record.dart';
import 'package:stockall/classes/temp_shop_class.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/main.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:universal_html/html.dart' as html;

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

// PDF GENERATOR

Future<void> generateAndPreviewPdf({
  required TempMainReceipt receipt,
  required List<TempProductSaleRecord> records,
  required TempShopClass shop,
  required BuildContext context,
}) async {
  final Uint8List pdfBytes = await buildPdf(
    receipt,
    records,
    shop,
    context,
  );

  await Printing.layoutPdf(
    onLayout: (_) async => pdfBytes,
    name: 'receipt.pdf',
    format: PdfPageFormat.a5,
  );

  if (context.mounted) {
    returnReceiptProvider(
      context,
      listen: false,
    ).toggleIsLoading(false);
  }
}

Future<Uint8List> buildPdf(
  TempMainReceipt receipt,
  List<TempProductSaleRecord> records,
  TempShopClass shop,
  BuildContext context,
) async {
  print('Start Building Pdf');
  final pdf = pw.Document();

  // Load Plus Jakarta Sans from assets
  final fontRegularBytes = await rootBundle.load(
    'assets/fonts/PlusJakartaSans-Regular.ttf',
  );
  print('Loaded Regular Font');

  final fontBoldBytes = await rootBundle.load(
    'assets/fonts/PlusJakartaSans-Bold.ttf',
  );
  print('Loaded Bold Font');

  final fontRegular = pw.Font.ttf(fontRegularBytes);
  final fontBold = pw.Font.ttf(fontBoldBytes);

  print('Adding Page');
  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a5,
      build:
          (pw.Context pdfContext) => pw.DefaultTextStyle(
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
                          shop.phoneNumber ??
                              'Phone Not Set',
                          style: pw.TextStyle(
                            font: fontRegular,
                            fontSize: 9,
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
                            'Payment Method:',
                          ),
                          pw.SizedBox(height: 5),
                          pw.Text(
                            style: pw.TextStyle(
                              font: fontBold,
                              fontSize: 10,
                            ),
                            receipt.paymentMethod,
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
                            'Amount(s):',
                          ),
                          pw.SizedBox(height: 5),
                          pw.Column(
                            crossAxisAlignment:
                                pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                style: pw.TextStyle(
                                  font: fontRegular,
                                  fontSize: 8,
                                ),
                                'Cash: ${formatMoneyMid(2000, context)}',
                              ),
                              pw.Text(
                                style: pw.TextStyle(
                                  font: fontRegular,
                                  fontSize: 8,
                                ),
                                'Bank: ${formatMoneyMid(1000, context)}',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
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
                    padding: const pw.EdgeInsets.symmetric(
                      vertical: 2,
                    ),
                    child: pw.Row(
                      mainAxisAlignment:
                          pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Expanded(
                          flex: 4,
                          child: pw.Text(
                            '${record.productName} ',
                          ),
                        ),
                        pw.Expanded(
                          flex: 1,
                          child: pw.Text(
                            '(${record.quantity.toStringAsFixed(0)}) ',
                          ),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Text(
                            style: pw.TextStyle(
                              font: fontRegular,
                              fontSize: 10,
                            ),
                            ' ${formatMoneyMid(3000, context)}',
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
                        formatMoneyMid(3000, context),
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
                          fontSize: 10,
                        ),
                        formatMoneyMid(5000, context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
    ),
  );
  print('Finished Page');
  try {
    print('Before saving PDF...');
    final data = await pdf.save();
    print('✅ After saving PDF');
    return data;
  } catch (e, stack) {
    print('❌ Error saving PDF: $e');
    print('🪜 Stack Trace:\n$stack');
    rethrow;
  }
}

void downloadPdfWeb(Uint8List pdfBytes, String filename) {
  try {
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
  } catch (e, stackTrace) {
    print('❌ Error downloading PDF: $e\n$stackTrace');
  }
}
