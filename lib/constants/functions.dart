import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stockall/classes/currency_class/currency_class.dart';
import 'package:stockall/classes/temp_main_receipt/temp_main_receipt.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/classes/temp_product_slaes_record/temp_product_sale_record.dart';
import 'package:stockall/classes/temp_shop/temp_shop_class.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/generate_barcode.dart';
import 'package:stockall/constants/subscription/sales_auth.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/report/general_report/class/general_report_class.dart';
import 'package:stockall/providers/error_log_provider.dart';
import 'package:universal_html/html.dart' as html;
import 'package:url_launcher/url_launcher.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart'
    show rootBundle, Clipboard, ClipboardData;
import 'dart:io';
import 'package:file_saver/file_saver.dart';

Future<void> copyToClipboard({
  required BuildContext context,
  required String text,
  String message = 'Copied to clipboard',
}) async {
  await Clipboard.setData(ClipboardData(text: text));

  if (!context.mounted) return;

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
}

void openWhatsApp() async {
  final phone = '2347048507587'; // your number
  final message = Uri.encodeComponent(
    "Hello, Stockall Solutions; ",
  );
  final url = 'https://wa.me/$phone?text=$message';

  await launchUrlMain(url);
}

Future<void> launchUrlMain(url) async {
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

TargetPlatform platforms(BuildContext context) {
  return Theme.of(context).platform;
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

double screenWidth(BuildContext context) {
  return MediaQuery.of(context).size.width;
}

double screenHeight(BuildContext context) {
  return MediaQuery.of(context).size.height;
}

class Authorizations {
  String addProduct = 'Add Items';
  String updateProduct = 'Update Items';
  String deleteProduct = 'Delete Items';
  String addCustomer = 'Add Customers';
  String updateCustomer = 'Update Customers';
  String deleteCustomer = 'Delete Customers';
  String makeSale = 'Make Sale';
  String deleteSale = 'Delete Sales';
  String updateSale = 'Update Sales';
  String editReceiptTemplate = 'Edit Receipt Template';
  String makeRefund = 'Make Refund';
  String addEmployee = 'Add Employee';
  String updateEmployee = 'Update Employee';
  String employeePage = 'Employee Page';
  String deleteEmployee = 'Delete Employee';
  String addExpense = 'Add Expenses';
  String updateExpenses = 'Update Expenses';
  String deleteExpenses = 'Delete Expenses';
  String deleteNotification = 'Delete Notification';
  String notificationsPage = 'Notifications Page';
  String contactStockall = 'Contact Stockall';
  String viewDate = 'View Date';
  String switchStores = 'Switch Stores';
  String manageShop = 'Manage Shop';
  String createShop = 'Create Shop';
  String viewAllShops = 'View All Shops';
  String deleteShop = 'Delete Shop';
  String clearCache = 'Clear Cache';
  String generalDiscount = 'General Discount';
  String salesDiscount = 'Sales Discount';
  String manageVAT = 'Manage VAT';
  String generateBarcode = 'Generate Barcode';
  String manageInventoryStorage = 'Manage Invetory Storage';
  String viewItemsSummary = 'View Items Summary';
  String viewAllTransactionRecords =
      'View All Transaction Records';
  String toggleBulkSale = 'Toggle Bulk Sale';
  String manageSubStaff = 'Manage Sub Staff';
  String manageShopDashboard = 'Manage Store Dashboard';
  String toggleUseGroupUnit = 'Toggle Use Group Unit';
  String toggleOnScreenKeyboard =
      'Toggle On Screen Keyboard';
  String togglePrintSalesDocket =
      'Toggle Print Sales Docket';
  String viewAllDepartments = 'View All Departments';
  String updateItemQuantity = 'Update Item Quantity';
  String viewItemQuantity = 'View Item Quantity';
  String setCustomReceiptCreatedDate =
      'Set Custom Receipt Created Date';
  String toggleTrackCart = 'Toggle Track Cart';
  String manageAccessPin = 'Manage Access Pin';
  String manageCostPrice = 'Manage Cost Price';
  String viewGeneralReport = 'View General Report';
  String viewItemsReport = 'View Items Report';
  String viewSalesAndRevenueReport =
      'View Sales And Revenue Report';
  String managePurchases = 'Manage Purchases';
}

bool authorization({required String authorized}) {
  if (currentUser().access.contains(authorized)) {
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
  required String staffName,
  required List<TempProductSaleRecord> records,
  required TempShopClass shop,
  required BuildContext context,
}) async {
  SalesAuthAction().downloadReceiptAction(
    context: context,
    action: () async {
      returnReceiptProvider(
        context,
        listen: false,
      ).toggleIsLoading(true);
      final Uint8List bytes = await _buildPdf(
        receipt,
        staffName,
        records,
        shop,
        context,
      );
      var receiptId = receipt.uuid!.toString().substring(
        0,
        5,
      );
      var name =
          "Stockall_Receipt_$receiptId.${DateTime.now().millisecondsSinceEpoch}";

      if (Platform.isAndroid || Platform.isIOS) {
        await savePdfMobile(bytes, name);
      } else {
        print('Printing For Desktop');
        await savePdfDesktop(bytes, name);
      }

      // 2. Open native print/share/save dialog (cross-platform)
      // await Printing.layoutPdf(onLayout: (_) async => pdfBytes);
      if (context.mounted) {
        returnReceiptProvider(
          context,
          listen: false,
        ).toggleIsLoading(false);
      }
    },
  );
}

Future<void> savePdfDesktop(
  Uint8List bytes,
  String name,
) async {
  await FileSaver.instance.saveFile(
    name: name,
    fileExtension: "pdf",
    bytes: bytes,
    mimeType: MimeType.pdf,
  );
}

Future<void> savePdfMobile(
  Uint8List bytes,
  String name,
) async {
  await Printing.sharePdf(
    bytes: bytes,
    filename: '$name.pdf',
  );
}

Future<void> generateAndPreviewPdfRoll({
  required TempMainReceipt receipt,
  required List<TempProductSaleRecord> records,
  required String staffName,
  required TempShopClass shop,
  required BuildContext context,
  required int printerType,
}) async {
  SalesAuthAction().printReceiptAction(
    context: context,
    action: () async {
      returnReceiptProvider(
        context,
        listen: false,
      ).toggleIsLoading(true);
      final Uint8List pdfBytes = await _buildPdfRoll(
        receipt,
        records,
        staffName,
        shop,
        context,
        printerType,
      );

      await Printing.layoutPdf(
        onLayout: (_) async => pdfBytes,
      );
      if (context.mounted) {
        returnReceiptProvider(
          context,
          listen: false,
        ).toggleIsLoading(false);
      }
    },
  );
}

Future<Uint8List> _buildPdf(
  TempMainReceipt receipt,
  String staffName,
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
          (pw.Context pdfcontext) => pw.Column(
            crossAxisAlignment:
                pw.CrossAxisAlignment.center,
            children: [
              pw.Row(
                mainAxisAlignment:
                    pw.MainAxisAlignment.center,
                children: [
                  pw.Column(
                    children: [
                      pw.Column(
                        children: [
                          pw.Builder(
                            builder: (
                              pw.Context pdfContext,
                            ) {
                              if (returnShopProvider()
                                      .selectedLogo !=
                                  null) {
                                return pw.Container(
                                  height:
                                      (returnShopProvider()
                                                      .imageWidth ??
                                                  0) >
                                              (2 *
                                                  (returnShopProvider()
                                                          .imageHeight ??
                                                      0))
                                          ? 35
                                          : 80,
                                  width: 200,
                                  child: pw.Image(
                                    pw.MemoryImage(
                                      returnShopProvider()
                                              .selectedLogo ??
                                          Uint8List(12),
                                    ),
                                    fit: pw.BoxFit.contain,
                                  ),
                                );
                              } else {
                                return pw.Container();
                              }
                            },
                          ),
                          pw.SizedBox(height: 1),
                          pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.center,
                            children: [
                              pw.Text(
                                textAlign:
                                    pw.TextAlign.center,
                                "#Shop Id: ${shopRef()}",
                                style: pw.TextStyle(
                                  font: fontBold,
                                  fontSize: 9,
                                ),
                                // maxLines: 2,
                              ),
                            ],
                          ),
                          pw.Builder(
                            builder: (
                              pw.Context pdfContext,
                            ) {
                              if (shop.showShopName!) {
                                return pw.Column(
                                  children: [
                                    pw.SizedBox(height: 4),
                                    pw.Container(
                                      width:
                                          PdfPageFormat
                                              .a5
                                              .availableWidth -
                                          60, // match margins
                                      alignment:
                                          pw
                                              .Alignment
                                              .center,
                                      child: pw.Text(
                                        shop.name,
                                        textAlign:
                                            pw
                                                .TextAlign
                                                .center,
                                        style: pw.TextStyle(
                                          font: fontBold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              } else {
                                return pw.Container();
                              }
                            },
                          ),

                          pw.Builder(
                            builder: (
                              pw.Context pdfContext,
                            ) {
                              if (shop.showEmail! &&
                                  shop.email != null) {
                                return pw.Column(
                                  children: [
                                    pw.SizedBox(height: 4),
                                    pw.Container(
                                      width:
                                          PdfPageFormat
                                              .a5
                                              .availableWidth -
                                          60,
                                      alignment:
                                          pw
                                              .Alignment
                                              .center,
                                      child: pw.Text(
                                        shop.email ?? '',
                                        textAlign:
                                            pw
                                                .TextAlign
                                                .center,
                                        style: pw.TextStyle(
                                          font: fontRegular,
                                          fontSize: 9,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              } else {
                                return pw.Container();
                              }
                            },
                          ),

                          pw.Builder(
                            builder: (
                              pw.Context pdfContext,
                            ) {
                              if (shop.showPhone!) {
                                return pw.Column(
                                  children: [
                                    pw.SizedBox(height: 1),

                                    pw.Text(
                                      textAlign:
                                          pw
                                              .TextAlign
                                              .center,
                                      shop.phoneNumber ??
                                          '',
                                      style: pw.TextStyle(
                                        font: fontRegular,
                                        fontSize:
                                            shop.phoneNumber ==
                                                    null
                                                ? 1
                                                : 9,
                                      ),
                                    ),
                                  ],
                                );
                              } else {
                                return pw.Container();
                              }
                            },
                          ),

                          pw.Builder(
                            builder: (
                              pw.Context pdfContext,
                            ) {
                              if (shop.showAddress!) {
                                return pw.Column(
                                  children: [
                                    pw.SizedBox(height: 1),
                                    pw.Container(
                                      width:
                                          PdfPageFormat
                                              .a5
                                              .availableWidth -
                                          60,
                                      alignment:
                                          pw
                                              .Alignment
                                              .center,
                                      child: pw.Text(
                                        shop.shopAddress ??
                                            'Address Not Set',
                                        textAlign:
                                            pw
                                                .TextAlign
                                                .center,
                                        style: pw.TextStyle(
                                          font: fontRegular,
                                          fontSize: 9,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              } else {
                                return pw.Container();
                              }
                            },
                          ),

                          pw.Builder(
                            builder: (
                              pw.Context pdfContext,
                            ) {
                              if (shop.showFacebookTop!) {
                                return pw.Column(
                                  children: [
                                    pw.SizedBox(height: 1),
                                    pw.Container(
                                      width:
                                          PdfPageFormat
                                              .a5
                                              .availableWidth -
                                          60,
                                      alignment:
                                          pw
                                              .Alignment
                                              .center,
                                      child: pw.Row(
                                        mainAxisAlignment:
                                            pw
                                                .MainAxisAlignment
                                                .center,
                                        children: [
                                          pw.Text(
                                            'Facebook: ',
                                            textAlign:
                                                pw
                                                    .TextAlign
                                                    .center,
                                            style: pw.TextStyle(
                                              font:
                                                  fontBold,
                                              fontSize: 7,
                                            ),
                                          ),
                                          pw.Text(
                                            shop.faceBookHandle ??
                                                'Facebook Not Set',
                                            textAlign:
                                                pw
                                                    .TextAlign
                                                    .center,
                                            style: pw.TextStyle(
                                              font:
                                                  fontRegular,
                                              fontSize: 9,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              } else {
                                return pw.Container();
                              }
                            },
                          ),

                          pw.Builder(
                            builder: (
                              pw.Context pdfContext,
                            ) {
                              if (shop.showInstaTop!) {
                                return pw.Column(
                                  children: [
                                    pw.SizedBox(height: 1),
                                    pw.Container(
                                      width:
                                          PdfPageFormat
                                              .a5
                                              .availableWidth -
                                          60,
                                      alignment:
                                          pw
                                              .Alignment
                                              .center,
                                      child: pw.Row(
                                        mainAxisAlignment:
                                            pw
                                                .MainAxisAlignment
                                                .center,
                                        children: [
                                          pw.Text(
                                            'Instagrm: ',
                                            textAlign:
                                                pw
                                                    .TextAlign
                                                    .center,
                                            style: pw.TextStyle(
                                              font:
                                                  fontBold,
                                              fontSize: 7,
                                            ),
                                          ),
                                          pw.Text(
                                            shop.instaHandle ??
                                                'Instagram Not Set',
                                            textAlign:
                                                pw
                                                    .TextAlign
                                                    .center,
                                            style: pw.TextStyle(
                                              font:
                                                  fontRegular,
                                              fontSize: 9,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              } else {
                                return pw.Container();
                              }
                            },
                          ),
                        ],
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
              pw.Column(
                children: [
                  pw.Padding(
                    padding: pw.EdgeInsets.only(right: 10),
                    child: pw.SvgImage(
                      svg: pw.Barcode.ean13().toSvg(
                        receipt.barcode ??
                            returnOnlyDigits(
                              receipt.uuid ?? '',
                            ),
                        width: 110,
                        height: 30,
                        fontHeight: 8,
                        drawText: true,
                      ),
                    ),
                  ),
                ],
              ),
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
                        'Receipt of Payment',
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
                  pw.Builder(
                    builder: (context) {
                      if (shop.showFirst!) {
                        return pw.Column(
                          children: [
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
                                        'Staff Name:',
                                      ),
                                      pw.SizedBox(
                                        height: 5,
                                      ),
                                      pw.Text(
                                        style: pw.TextStyle(
                                          font: fontBold,
                                          fontSize: 10,
                                        ),
                                        staffName,
                                      ),
                                    ],
                                  ),
                                ),
                                pw.Builder(
                                  builder: (context) {
                                    if (receipt
                                            .customerUuid !=
                                        null) {
                                      return pw.Expanded(
                                        child: pw.Column(
                                          crossAxisAlignment:
                                              pw
                                                  .CrossAxisAlignment
                                                  .start,
                                          children: [
                                            pw.Text(
                                              style: pw.TextStyle(
                                                font:
                                                    fontRegular,
                                                fontSize: 9,
                                              ),
                                              'Customer Name:',
                                            ),
                                            pw.SizedBox(
                                              height: 5,
                                            ),
                                            pw.Text(
                                              style: pw.TextStyle(
                                                font:
                                                    fontBold,
                                                fontSize:
                                                    10,
                                              ),
                                              receipt.customerName ??
                                                  'Not Set',
                                            ),
                                          ],
                                        ),
                                      );
                                    } else {
                                      return pw.Container();
                                    }
                                  },
                                ),
                              ],
                            ),
                            pw.Builder(
                              builder: (beansContext) {
                                if (receipt.subStaffName !=
                                    null) {
                                  return pw.Column(
                                    children: [
                                      pw.SizedBox(
                                        height: 10,
                                      ),
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
                                                    font:
                                                        fontRegular,
                                                    fontSize:
                                                        9,
                                                  ),
                                                  'Waiter:',
                                                ),
                                                pw.SizedBox(
                                                  height: 5,
                                                ),
                                                pw.Text(
                                                  style: pw.TextStyle(
                                                    font:
                                                        fontBold,
                                                    fontSize:
                                                        10,
                                                  ),
                                                  receipt.subStaffName ??
                                                      'Not Set',
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
                                                    font:
                                                        fontRegular,
                                                    fontSize:
                                                        9,
                                                  ),
                                                  'Receipt Id:',
                                                ),
                                                pw.SizedBox(
                                                  height: 5,
                                                ),
                                                pw.Text(
                                                  style: pw.TextStyle(
                                                    font:
                                                        fontBold,
                                                    fontSize:
                                                        10,
                                                  ),
                                                  receipt.cartName ??
                                                      'Not Set',
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                } else {
                                  return pw.SizedBox();
                                }
                              },
                            ),
                          ],
                        );
                      } else {
                        return pw.Container();
                      }
                    },
                  ),
                  pw.Builder(
                    builder: (pw.Context pdfContext) {
                      if (shop.showSecond!) {
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
                                      pw.Builder(
                                        builder: (
                                          beansContext,
                                        ) {
                                          if (receipt
                                                  .bank ==
                                              0) {
                                            return pw.Text(
                                              style: pw.TextStyle(
                                                font:
                                                    fontRegular,
                                                fontSize: 8,
                                              ),
                                              'Cash: ${formatMoneyMid(amount: receipt.cashAlt, context: context)}',
                                            );
                                          } else if (receipt
                                                  .cashAlt ==
                                              0) {
                                            return pw.Text(
                                              style: pw.TextStyle(
                                                font:
                                                    fontRegular,
                                                fontSize: 8,
                                              ),
                                              'Bank: ${formatMoneyMid(amount: receipt.bank, context: context)}',
                                            );
                                          } else {
                                            return pw.Column(
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
                                                        8,
                                                  ),
                                                  'Cash: ${formatMoneyMid(amount: receipt.cashAlt, context: context)}',
                                                ),
                                                pw.Text(
                                                  style: pw.TextStyle(
                                                    font:
                                                        fontRegular,
                                                    fontSize:
                                                        8,
                                                  ),
                                                  'Bank: ${formatMoneyMid(amount: receipt.bank, context: context)}',
                                                ),
                                              ],
                                            );
                                          }
                                        },
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
                                        '#Ticket Id:',
                                      ),
                                      pw.SizedBox(
                                        height: 5,
                                      ),
                                      pw.Text(
                                        style: pw.TextStyle(
                                          font: fontBold,
                                          fontSize: 10,
                                        ),
                                        receipt.barcode ??
                                            returnOnlyDigits(
                                              receipt.uuid ??
                                                  '',
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      } else {
                        return pw.Container();
                      }
                    },
                  ),
                  pw.Builder(
                    builder: (pw.Context pdfContext) {
                      if (shop.showThird!) {
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
                                        'Date:',
                                      ),
                                      pw.SizedBox(
                                        height: 5,
                                      ),
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
                                        pw
                                            .CrossAxisAlignment
                                            .start,
                                    children: [
                                      pw.Text(
                                        style: pw.TextStyle(
                                          font: fontRegular,
                                          fontSize: 9,
                                        ),
                                        'Time:',
                                      ),
                                      pw.SizedBox(
                                        height: 5,
                                      ),
                                      pw.Text(
                                        style: pw.TextStyle(
                                          font: fontBold,
                                          fontSize: 10,
                                        ),
                                        formatTime(
                                          receipt.createdAt,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      } else {
                        return pw.Container();
                      }
                    },
                  ),
                  pw.SizedBox(height: 5),
                  pw.Divider(),

                  pw.Row(
                    mainAxisAlignment:
                        pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Expanded(
                        flex: 5,
                        child: pw.Text(
                          'Items:',
                          style: pw.TextStyle(
                            font: fontBold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      pw.Expanded(
                        flex: 1,
                        child: pw.Text(
                          'Qty:',
                          style: pw.TextStyle(
                            font: fontRegular,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      pw.Expanded(
                        flex: 3,
                        child: pw.Text(
                          'Price:',
                          style: pw.TextStyle(
                            font: fontRegular,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 5),

                  ...records.map(
                    (record) => pw.Container(
                      margin: pw.EdgeInsets.symmetric(
                        vertical: 3,
                      ),
                      padding:
                          const pw.EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 5,
                          ),
                      /**alpha: 1, red: 0.961, green: 0.961, blue: 0.961 */
                      decoration: pw.BoxDecoration(
                        color: PdfColor.fromHex('#EFEFEF'),
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
                              style: pw.TextStyle(
                                fontSize: 10,
                              ),
                              '${record.productName} ',
                            ),
                          ),
                          pw.Expanded(
                            flex: 1,
                            child: pw.Text(
                              style: pw.TextStyle(
                                fontSize: 8,
                              ),
                              '[ ${formatLargeNumberDouble(record.quantity)} ] ',
                            ),
                          ),
                          pw.Expanded(
                            flex: 3,
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
                                  formatMoneyMid(
                                    amount:
                                        (receipt.fixedDiscount ==
                                                        null &&
                                                    receipt.generalDiscount ==
                                                        null) &&
                                                record.discount !=
                                                    null
                                            ? ((record.originalCost ??
                                                    0) -
                                                (record.discountedAmount ??
                                                    0))
                                            : (record
                                                    .originalCost ??
                                                0),
                                    context: context,
                                  ),
                                ),
                                pw.Text(
                                  style: pw.TextStyle(
                                    font: fontRegular,
                                    fontSize: 7,
                                  ),
                                  "${formatMoneyMid(amount: ((receipt.fixedDiscount == null && receipt.generalDiscount == null) && record.discount != null ? ((record.originalCost ?? 0) - (record.discountedAmount ?? 0)) : (record.originalCost ?? 0) / record.quantity), context: context)} per 1",
                                ),
                                // pw.Builder(
                                //   builder: (pdfContext) {
                                //     if (record.discount !=
                                //             null &&
                                //         !record
                                //             .customPriceSet &&
                                //         (receipt.fixedDiscount ==
                                //                 null &&
                                //             receipt.generalDiscount ==
                                //                 null)) {
                                //       return pw.Text(
                                //         style: pw.TextStyle(
                                //           font: fontRegular,
                                //           decoration:
                                //               pw
                                //                   .TextDecoration
                                //                   .lineThrough,
                                //           fontSize: 8,
                                //         ),
                                //         formatMoneyMid(
                                //           amount:
                                //               (record.originalCost ??
                                //                   0),
                                //           context: context,
                                //         ),
                                //       );
                                //     } else {
                                //       return pw.Container();
                                //     }
                                //   },
                                // ),
                              ],
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
                            fontSize: 8,
                          ),
                          'Subtotal:',
                        ),
                      ),
                      pw.Expanded(
                        flex: 1,
                        child: pw.Text(
                          style: pw.TextStyle(
                            font: fontRegular,
                            fontSize: 9,
                          ),
                          formatMoneyMid(
                            amount: returnReceiptProvider(
                              context,
                              listen: false,
                            ).getOriginalCostReceipt(
                              receipt,
                            ),
                            context: context,
                          ),
                        ),
                      ),
                    ],
                  ),

                  pw.Builder(
                    builder: (pdfContext) {
                      if (receipt.fixedDiscount != null ||
                          receipt.generalDiscount != null) {
                        return pw.Column(
                          children: [
                            pw.SizedBox(height: 5),
                            pw.Row(
                              mainAxisAlignment:
                                  pw
                                      .MainAxisAlignment
                                      .spaceEvenly,
                              children: [
                                pw.Expanded(
                                  flex: 2,
                                  child: pw.Row(
                                    children: [
                                      pw.Text(
                                        style: pw.TextStyle(
                                          font: fontRegular,
                                          fontSize: 8,
                                        ),
                                        'Discount:',
                                      ),
                                      pw.Text(
                                        style: pw.TextStyle(
                                          font: fontRegular,
                                          fontSize: 8,
                                        ),
                                        receipt.generalDiscount !=
                                                null
                                            ? " (${receipt.generalDiscount}%)"
                                            : '',
                                      ),
                                    ],
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
                                      amount: returnReceiptProvider(
                                        context,
                                        listen: false,
                                      ).getDiscountAmountForReceipt(
                                        receipt,
                                      ),
                                      context: context,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      } else {
                        return pw.Container();
                      }
                    },
                  ),
                  pw.SizedBox(height: 5),
                  pw.Row(
                    mainAxisAlignment:
                        pw.MainAxisAlignment.spaceEvenly,
                    children: [
                      pw.Expanded(
                        flex: 2,
                        child: pw.Row(
                          children: [
                            pw.Text(
                              style: pw.TextStyle(
                                font: fontRegular,
                                fontSize: 8,
                              ),
                              'VAT:',
                            ),
                            pw.Text(
                              style: pw.TextStyle(
                                font: fontRegular,
                                fontSize: 8,
                              ),
                              '(${receipt.vat ?? 0}%)',
                            ),
                          ],
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
                            amount: returnReceiptProvider(
                              context,
                              listen: false,
                            ).getVATForReceipt(receipt),
                            context: context,
                          ),
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 5),
                  pw.Builder(
                    builder: (pdfContext) {
                      if (receipt.balance != null) {
                        return pw.Column(
                          children: [
                            pw.Row(
                              mainAxisAlignment:
                                  pw
                                      .MainAxisAlignment
                                      .spaceEvenly,
                              children: [
                                pw.Expanded(
                                  flex: 2,
                                  child: pw.Row(
                                    children: [
                                      pw.Text(
                                        style: pw.TextStyle(
                                          font: fontRegular,
                                          fontSize: 8,
                                        ),
                                        'Balance:',
                                      ),
                                    ],
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
                                      amount:
                                          (receipt.balance ??
                                              0),
                                      context: context,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            pw.SizedBox(height: 5),
                          ],
                        );
                      } else {
                        return pw.Container();
                      }
                    },
                  ),

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
                            amount: returnReceiptProvider(
                              context,
                              listen: false,
                            ).getTotalMainRevenueReceipt(
                              receipt,
                            ),
                            context: context,
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

Future<Uint8List> _buildPdfRoll(
  TempMainReceipt receipt,
  List<TempProductSaleRecord> records,
  String staffName,
  TempShopClass shop,
  BuildContext context,
  int printerType,
) async {
  double headingText = printerType == 1 ? 11 : 13;
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
      margin: pw.EdgeInsets.only(
        left: kIsWeb ? 2 : 0,
        top: 5,
        right: kIsWeb ? 15 : 25,
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
                      children: [
                        if (returnShopProvider()
                                .selectedLogo !=
                            null)
                          pw.Container(
                            height:
                                (returnShopProvider()
                                                .imageWidth ??
                                            0) >
                                        (2 *
                                            (returnShopProvider()
                                                    .imageHeight ??
                                                0))
                                    ? 25
                                    : 75,
                            width: 200,
                            child: pw.Image(
                              pw.MemoryImage(
                                returnShopProvider()
                                        .selectedLogo ??
                                    Uint8List(12),
                              ),
                              fit: pw.BoxFit.contain,
                            ),
                          ),
                        pw.SizedBox(height: 1),
                        pw.Row(
                          mainAxisAlignment:
                              pw.MainAxisAlignment.center,
                          children: [
                            pw.Text(
                              textAlign:
                                  pw.TextAlign.center,
                              "#Shop Id: ${shopRef()}",
                              style: pw.TextStyle(
                                font: fontBold,
                                fontSize: parText,
                              ),
                              // maxLines: 2,
                            ),
                          ],
                        ),
                        if (returnShopProvider()
                                .selectedLogo !=
                            null)
                          pw.SizedBox(height: 2),
                        pw.Builder(
                          builder: (pw.Context pdfContext) {
                            if (shop.showShopName!) {
                              return pw.Column(
                                children: [
                                  pw.Text(
                                    textAlign:
                                        pw.TextAlign.center,
                                    shop.name,
                                    style: pw.TextStyle(
                                      font: fontBold,
                                      fontSize: headingText,
                                    ),
                                    // maxLines: 2,
                                    overflow:
                                        pw
                                            .TextOverflow
                                            .clip,
                                  ),
                                ],
                              );
                            } else {
                              return pw.Container();
                            }
                          },
                        ),
                        pw.Builder(
                          builder: (pw.Context pdfContext) {
                            if (shop.showEmail! &&
                                shop.email != null) {
                              return pw.Column(
                                children: [
                                  pw.SizedBox(height: 1),
                                  pw.Text(
                                    textAlign:
                                        pw.TextAlign.center,
                                    shop.email ?? '',
                                    style: pw.TextStyle(
                                      font: fontRegular,
                                      fontSize: parText,
                                    ),
                                    overflow:
                                        pw
                                            .TextOverflow
                                            .clip,
                                  ),
                                ],
                              );
                            } else {
                              return pw.Container();
                            }
                          },
                        ),

                        pw.Builder(
                          builder: (pw.Context pdfContext) {
                            if (shop.showPhone!) {
                              return pw.Column(
                                children: [
                                  pw.SizedBox(height: 1),
                                  pw.Text(
                                    textAlign:
                                        pw.TextAlign.center,
                                    shop.phoneNumber ?? '',
                                    style: pw.TextStyle(
                                      font: fontRegular,
                                      fontSize:
                                          shop.phoneNumber ==
                                                  null
                                              ? 1
                                              : parText,
                                    ),
                                  ),
                                ],
                              );
                            } else {
                              return pw.Container();
                            }
                          },
                        ),

                        pw.Builder(
                          builder: (pw.Context pdfContext) {
                            if (shop.showAddress!) {
                              return pw.Column(
                                children: [
                                  pw.SizedBox(height: 1),
                                  pw.Text(
                                    textAlign:
                                        pw.TextAlign.center,
                                    shop.shopAddress ?? '',
                                    style: pw.TextStyle(
                                      font: fontRegular,
                                      fontSize:
                                          shop.shopAddress ==
                                                  null
                                              ? 1
                                              : parText,
                                    ),
                                  ),
                                ],
                              );
                            } else {
                              return pw.Container();
                            }
                          },
                        ),

                        pw.Builder(
                          builder: (pw.Context pdfContext) {
                            if (shop.showFacebookTop!) {
                              return pw.Column(
                                children: [
                                  pw.SizedBox(height: 1),
                                  pw.Row(
                                    mainAxisAlignment:
                                        pw
                                            .MainAxisAlignment
                                            .center,
                                    children: [
                                      pw.Text(
                                        textAlign:
                                            pw
                                                .TextAlign
                                                .center,

                                        'Facebook:',
                                        style: pw.TextStyle(
                                          font: fontBold,
                                          fontSize:
                                              shop.faceBookHandle ==
                                                      null
                                                  ? 1
                                                  : parTextAlt,
                                        ),
                                      ),
                                      pw.Text(
                                        textAlign:
                                            pw
                                                .TextAlign
                                                .center,
                                        shop.faceBookHandle ??
                                            '',
                                        style: pw.TextStyle(
                                          font: fontRegular,
                                          fontSize:
                                              shop.faceBookHandle ==
                                                      null
                                                  ? 1
                                                  : parText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            } else {
                              return pw.Container();
                            }
                          },
                        ),

                        pw.Builder(
                          builder: (pw.Context pdfContext) {
                            if (shop.showInstaTop!) {
                              return pw.Column(
                                children: [
                                  pw.SizedBox(height: 1),
                                  pw.Row(
                                    mainAxisAlignment:
                                        pw
                                            .MainAxisAlignment
                                            .center,
                                    children: [
                                      pw.Text(
                                        textAlign:
                                            pw
                                                .TextAlign
                                                .center,

                                        'Instagram:',
                                        style: pw.TextStyle(
                                          font: fontBold,
                                          fontSize:
                                              shop.instaHandle ==
                                                      null
                                                  ? 1
                                                  : parTextAlt,
                                        ),
                                      ),
                                      pw.Text(
                                        textAlign:
                                            pw
                                                .TextAlign
                                                .center,
                                        shop.instaHandle ??
                                            '',
                                        style: pw.TextStyle(
                                          font: fontRegular,
                                          fontSize:
                                              shop.instaHandle ==
                                                      null
                                                  ? 1
                                                  : parText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            } else {
                              return pw.Container();
                            }
                          },
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
                      'Payment Receipt',
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
                pw.Builder(
                  builder: (context) {
                    if (shop.showFirst!) {
                      return pw.Column(
                        children: [
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
                                      'Staff Name:',
                                    ),
                                    pw.SizedBox(height: 1),
                                    pw.Text(
                                      style: pw.TextStyle(
                                        font: fontBold,
                                        fontSize: parText,
                                      ),
                                      staffName,
                                    ),
                                  ],
                                ),
                              ),
                              pw.Builder(
                                builder: (context) {
                                  if (receipt
                                          .customerUuid !=
                                      null) {
                                    return pw.Expanded(
                                      child: pw.Column(
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
                                                  parText,
                                            ),
                                            'Customer Name:',
                                          ),
                                          pw.SizedBox(
                                            height: 1,
                                          ),
                                          pw.Text(
                                            style: pw.TextStyle(
                                              font:
                                                  fontBold,
                                              fontSize:
                                                  parText,
                                            ),
                                            receipt.customerName ??
                                                'Not Set',
                                          ),
                                        ],
                                      ),
                                    );
                                  } else {
                                    return pw.Container();
                                  }
                                },
                              ),
                            ],
                          ),
                          pw.Builder(
                            builder: (beansContext) {
                              if (receipt.subStaffName !=
                                  null) {
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
                                                  font:
                                                      fontRegular,
                                                  fontSize:
                                                      parText,
                                                ),
                                                'Waiter:',
                                              ),
                                              pw.SizedBox(
                                                height: 1,
                                              ),
                                              pw.Text(
                                                style: pw.TextStyle(
                                                  font:
                                                      fontBold,
                                                  fontSize:
                                                      parText,
                                                ),
                                                receipt.subStaffName ??
                                                    'Not Set',
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
                                                  font:
                                                      fontRegular,
                                                  fontSize:
                                                      parText,
                                                ),
                                                'Receipt Id:',
                                              ),
                                              pw.SizedBox(
                                                height: 1,
                                              ),
                                              pw.Text(
                                                style: pw.TextStyle(
                                                  font:
                                                      fontBold,
                                                  fontSize:
                                                      parText,
                                                ),
                                                receipt.cartName ??
                                                    'Not Set',
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              } else {
                                return pw.SizedBox();
                              }
                            },
                          ),
                        ],
                      );
                    } else {
                      return pw.Container();
                    }
                  },
                ),
                pw.Builder(
                  builder: (pw.Context pdfContext) {
                    if (shop.showSecond!) {
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
                                    pw.Builder(
                                      builder: (
                                        beansContext,
                                      ) {
                                        if (receipt.bank ==
                                            0) {
                                          return pw.Text(
                                            style: pw.TextStyle(
                                              font:
                                                  fontRegular,
                                              fontSize:
                                                  parTextAlt,
                                            ),
                                            'Cash: ${formatMoneyMid(amount: receipt.cashAlt, context: context)}',
                                          );
                                        } else if (receipt
                                                .cashAlt ==
                                            0) {
                                          return pw.Text(
                                            style: pw.TextStyle(
                                              font:
                                                  fontRegular,
                                              fontSize:
                                                  parTextAlt,
                                            ),
                                            'Bank: ${formatMoneyMid(amount: receipt.bank, context: context)}',
                                          );
                                        } else {
                                          return pw.Column(
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
                                                'Cash: ${formatMoneyMid(amount: receipt.cashAlt, context: context)}',
                                              ),
                                              pw.Text(
                                                style: pw.TextStyle(
                                                  font:
                                                      fontRegular,
                                                  fontSize:
                                                      parTextAlt,
                                                ),
                                                'Bank: ${formatMoneyMid(amount: receipt.bank, context: context)}',
                                              ),
                                            ],
                                          );
                                        }
                                      },
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
                                      '#Ticket ID',
                                    ),
                                    pw.SizedBox(height: 1),
                                    pw.Text(
                                      style: pw.TextStyle(
                                        font: fontBold,
                                        fontSize: parText,
                                      ),
                                      receipt.barcode ??
                                          returnOnlyDigits(
                                            receipt.uuid ??
                                                '',
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    } else {
                      return pw.Container();
                    }
                  },
                ),
                pw.Builder(
                  builder: (pw.Context pdfContext) {
                    if (shop.showThird!) {
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
                                      pw
                                          .CrossAxisAlignment
                                          .start,
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
                                      formatTime(
                                        receipt.createdAt,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    } else {
                      return pw.Container();
                    }
                  },
                ),
                pw.SizedBox(height: 3),
                pw.Divider(thickness: 0.6, height: 6),

                pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 6,
                      child: pw.Text(
                        'Items:',
                        style: pw.TextStyle(
                          fontSize: parText,
                          font: fontBold,
                        ),
                      ),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Text(
                        'Qty:',
                        style: pw.TextStyle(
                          fontSize: parText,
                          font: fontBold,
                        ),
                      ),
                    ),
                    pw.Expanded(
                      flex: 4,
                      child: pw.Text(
                        'Price:',
                        style: pw.TextStyle(
                          fontSize: parText,
                          font: fontBold,
                        ),
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
                          flex: 6,
                          child: pw.Text(
                            style: pw.TextStyle(
                              fontSize: parText,
                            ),
                            '${record.productName} ',
                          ),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Text(
                            style: pw.TextStyle(
                              fontSize: parText,
                            ),
                            '[ ${formatLargeNumberDouble(record.quantity)} ] ',
                          ),
                        ),
                        pw.Expanded(
                          flex: 4,
                          child: pw.Column(
                            crossAxisAlignment:
                                pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                style: pw.TextStyle(
                                  fontSize: parText,
                                ),
                                formatMoneyMid(
                                  amount:
                                      (receipt.fixedDiscount ==
                                                      null &&
                                                  receipt.generalDiscount ==
                                                      null) &&
                                              record.discount !=
                                                  null
                                          ? ((record.originalCost ??
                                                  0) -
                                              (record.discountedAmount ??
                                                  0))
                                          : (record
                                                  .originalCost ??
                                              0),
                                  context: context,
                                ),
                              ),
                              // pw.Text(
                              //   style: pw.TextStyle(
                              //     font: fontRegular,
                              //     fontSize: 6,
                              //   ),
                              //   "1x  ${formatMoneyMid(amount: ((receipt.fixedDiscount == null && receipt.generalDiscount == null) && record.discount != null ? ((record.originalCost ?? 0) - (record.discountedAmount ?? 0)) : (record.originalCost ?? 0) / record.quantity), context: context)}",
                              // ),
                              // pw.Builder(
                              //   builder: (pdfContext) {
                              //     if (record.discount !=
                              //             null &&
                              //         !record
                              //             .customPriceSet &&
                              //         (receipt.fixedDiscount ==
                              //                 null &&
                              //             receipt.generalDiscount ==
                              //                 null)) {
                              //       return pw.Text(
                              //         style: pw.TextStyle(
                              //           font: fontRegular,
                              //           decoration:
                              //               pw
                              //                   .TextDecoration
                              //                   .lineThrough,
                              //           fontSize: 6,
                              //         ),
                              //         formatMoneyMid(
                              //           amount:
                              //               (record.originalCost ??
                              //                   0),
                              //           context: context,
                              //         ),
                              //       );
                              //     } else {
                              //       return pw.Container();
                              //     }
                              //   },
                              // ),
                            ],
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
                          fontSize: parTextAlt,
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
                          amount: returnReceiptProvider(
                            context,
                            listen: false,
                          ).getOriginalCostReceipt(receipt),
                          context: context,
                        ),
                      ),
                    ),
                  ],
                ),
                pw.Builder(
                  builder: (pdfContext) {
                    if (receipt.fixedDiscount != null ||
                        receipt.generalDiscount != null) {
                      return pw.Column(
                        children: [
                          pw.SizedBox(height: 1),
                          pw.Row(
                            mainAxisAlignment:
                                pw
                                    .MainAxisAlignment
                                    .spaceEvenly,
                            children: [
                              pw.Expanded(
                                flex: 9,
                                child: pw.Row(
                                  children: [
                                    pw.Text(
                                      style: pw.TextStyle(
                                        font: fontRegular,
                                        fontSize:
                                            parTextAlt,
                                      ),
                                      'Discount:',
                                    ),
                                    pw.Text(
                                      style: pw.TextStyle(
                                        font: fontRegular,
                                        fontSize:
                                            parTextAlt,
                                      ),
                                      receipt.generalDiscount !=
                                              null
                                          ? " (${receipt.generalDiscount}%)"
                                          : '',
                                    ),
                                  ],
                                ),
                              ),
                              pw.Expanded(
                                flex: 7,
                                child: pw.Text(
                                  style: pw.TextStyle(
                                    font: fontRegular,
                                    fontSize: parTextAlt,
                                  ),
                                  formatMoneyMid(
                                    amount: returnReceiptProvider(
                                      context,
                                      listen: false,
                                    ).getDiscountAmountForReceipt(
                                      receipt,
                                    ),
                                    context: context,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    } else {
                      return pw.Container();
                    }
                  },
                ),
                pw.SizedBox(height: 1),

                pw.Builder(
                  builder: (beansContext) {
                    if (receipt.vat != null) {
                      return pw.Column(
                        children: [
                          pw.Row(
                            mainAxisAlignment:
                                pw
                                    .MainAxisAlignment
                                    .spaceEvenly,
                            children: [
                              pw.Expanded(
                                flex: 9,
                                child: pw.Row(
                                  children: [
                                    pw.Text(
                                      style: pw.TextStyle(
                                        font: fontRegular,
                                        fontSize:
                                            parTextAlt,
                                      ),
                                      'VAT:',
                                    ),
                                    pw.Text(
                                      style: pw.TextStyle(
                                        font: fontRegular,
                                        fontSize:
                                            parTextAlt,
                                      ),
                                      '(${receipt.vat ?? 0}%)',
                                    ),
                                  ],
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
                                    amount:
                                        returnReceiptProvider(
                                          context,
                                          listen: false,
                                        ).getVATForReceipt(
                                          receipt,
                                        ),
                                    context: context,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          pw.SizedBox(height: 1),
                        ],
                      );
                    } else {
                      return pw.SizedBox();
                    }
                  },
                ),
                pw.Builder(
                  builder: (pdfContext) {
                    if (receipt.balance != null) {
                      return pw.Column(
                        children: [
                          pw.Row(
                            mainAxisAlignment:
                                pw
                                    .MainAxisAlignment
                                    .spaceEvenly,
                            children: [
                              pw.Expanded(
                                flex: 9,
                                child: pw.Row(
                                  children: [
                                    pw.Text(
                                      style: pw.TextStyle(
                                        font: fontRegular,
                                        fontSize:
                                            parTextAlt,
                                      ),
                                      'Balance:',
                                    ),
                                  ],
                                ),
                              ),
                              pw.Expanded(
                                flex: 7,
                                child: pw.Text(
                                  style: pw.TextStyle(
                                    font: fontRegular,
                                    fontSize: parTextAlt,
                                  ),
                                  formatMoneyMid(
                                    amount:
                                        (receipt.balance ??
                                            0),
                                    context: context,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          pw.SizedBox(height: 1),
                        ],
                      );
                    } else {
                      return pw.Container();
                    }
                  },
                ),
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
                          amount: returnReceiptProvider(
                            context,
                            listen: false,
                          ).getTotalMainRevenueReceipt(
                            receipt,
                          ),
                          context: context,
                        ),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 5),
                pw.Divider(),
                pw.Column(
                  children: [
                    pw.Padding(
                      padding: pw.EdgeInsets.only(
                        right: 10,
                      ),
                      child: pw.SvgImage(
                        svg: pw.Barcode.ean13().toSvg(
                          receipt.barcode ??
                              returnOnlyDigits(
                                receipt.uuid ?? '',
                              ),
                          width: 110,
                          height: 30,
                          fontHeight: 8,
                          drawText: true,
                        ),
                      ),
                    ),
                    pw.Divider(height: 8),
                  ],
                ),
                pw.SizedBox(height: 5),
                pw.Row(
                  mainAxisAlignment:
                      pw.MainAxisAlignment.center,
                  children: [
                    pw.Flexible(
                      child: pw.Text(
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          fontSize: totalText,
                          fontWeight: pw.FontWeight.bold,
                          // color: PdfColor(50, 50, 050),
                        ),
                        shop.bottomText?.toUpperCase() ??
                            'Thank you for shopping with us'
                                .toUpperCase(),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 35),
                pw.Text(
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    fontSize: totalText,
                    fontWeight: pw.FontWeight.bold,
                    // color: PdfColor(50, 50, 050),
                  ),
                  '------------',
                ),
                pw.Builder(
                  builder: (beansContext) {
                    if (records.length > 15) {
                      return pw.Text(
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          fontSize: totalText,
                          fontWeight: pw.FontWeight.bold,
                          // color: PdfColor(50, 50, 050),
                        ),
                        '------------',
                      );
                    } else {
                      return pw.Container();
                    }
                  },
                ),
                pw.Builder(
                  builder: (beansContext) {
                    if (records.length > 15) {
                      return pw.Text(
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                          fontSize: totalText,
                          fontWeight: pw.FontWeight.bold,
                          // color: PdfColor(50, 50, 050),
                        ),
                        '------------',
                      );
                    } else {
                      return pw.Container();
                    }
                  },
                ),
              ],
            ),
          ),

      // pw.Expanded(child: pw.Spacer()),
    ),
  );

  return pdf.save();
}

class PdfPreviewPage extends StatefulWidget {
  final Function() generatePdf;
  const PdfPreviewPage({
    super.key,
    required this.generatePdf,
  });

  @override
  State<PdfPreviewPage> createState() =>
      _PdfPreviewPageState();
}

class _PdfPreviewPageState extends State<PdfPreviewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("PDF Preview")),
      body: PdfPreview(
        build:
            (format) async =>
                (await widget.generatePdf()).save(),
        allowPrinting: true,
        allowSharing: true,
        initialPageFormat: PdfPageFormat.a4,
        pdfFileName: "stockall_receipt.pdf",
      ),
    );
  }
}

void downloadPdfWeb({
  required TempMainReceipt receipt,
  required List<TempProductSaleRecord> records,
  required String staffName,
  required TempShopClass shop,
  required BuildContext context,
  required String filename,
}) async {
  SalesAuthAction().downloadReceiptAction(
    context: context,
    action: () async {
      try {
        final pdfBytes = await _buildPdf(
          receipt,
          staffName,
          records,
          returnShopProvider().userShop()!,
          context,
        );
        final blob = html.Blob([
          pdfBytes,
        ], 'application/pdf');
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
        returnErrorLogProvider().createLog(
          error: 'Error downloading PDF: $e\n$stackTrace',
        );
      }
    },
  );
}

void downloadPdfWebRoll({
  required TempMainReceipt receipt,
  required List<TempProductSaleRecord> records,
  required String staffName,
  required TempShopClass shop,
  required BuildContext context,
  required String filename,
  required int printType,
}) async {
  SalesAuthAction().printReceiptAction(
    context: context,
    action: () async {
      try {
        print('Begin Download');
        final pdfBytes = await _buildPdfRoll(
          receipt,
          records,
          staffName,
          returnShopProvider().userShop()!,
          context,
          printType,
        );

        // ✅ Ensure Uint8List
        final pdfUint8 = Uint8List.fromList(pdfBytes);

        // Step 1: Download
        final blob = html.Blob([
          pdfUint8,
        ], 'application/pdf');
        final url = html.Url.createObjectUrlFromBlob(blob);

        final anchor =
            html.AnchorElement(href: url)
              ..download = filename
              ..style.display = 'none';

        html.document.body?.append(anchor);
        anchor.click();
        anchor.remove();
        html.Url.revokeObjectUrl(url);

        // Step 2: Print (make sure this runs in same click event if possible)
        await Printing.layoutPdf(
          onLayout: (format) async => pdfUint8,
        );

        if (context.mounted) {
          returnReceiptProvider(
            context,
            listen: false,
          ).toggleIsLoading(false);
        }
        // return pdfUint8;
      } catch (e, stackTrace) {
        print(
          '❌ Error downloading/printing PDF: $e\n$stackTrace',
        );
        createErrorLog(
          error:
              'Error downloading/printing PDF: $e\n$stackTrace',
        );
      }
    },
  );
}

// Future<void> printPdfWebRoll(Uint8List pdfUint8) async {
//   await Printing.layoutPdf(
//     onLayout: (format) async => pdfUint8,
//   );
// }

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
  returnData().toggleIsLoading(true);
  final Uint8List pdfBytes = await _buildPdfProducts(
    products,
    shop,
    context,
  );

  // 2. Open native print/share/save dialog (cross-platform)
  await Printing.layoutPdf(onLayout: (_) async => pdfBytes);
  if (context.mounted) {
    returnData().toggleIsLoading(false);
  }
}

Future<Uint8List> _buildPdfProducts(
  List<TempProductClass> products,
  TempShopClass shop,
  BuildContext context,
) async {
  const int productsPerPage = 70;

  // Split products into chunks of 70
  final productChunks = <List<TempProductClass>>[];
  for (
    var i = 0;
    i < products.length;
    i += productsPerPage
  ) {
    productChunks.add(
      products.sublist(
        i,
        i + productsPerPage > products.length
            ? products.length
            : i + productsPerPage,
      ),
    );
  }
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
                        shop.email ?? 'Email not Set',
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
                                    amount:
                                        product
                                            .sellingPrice ??
                                        0,
                                    context: context,
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
                                    amount:
                                        product.costPrice,
                                    context: context,
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
                                  returnCategoriesProvider(
                                            context:
                                                context,
                                          )
                                          .categories()
                                          .where(
                                            (cat) =>
                                                cat.uuid ==
                                                product
                                                    .categoryUuid,
                                          )
                                          .isNotEmpty
                                      ? returnCategoriesProvider(
                                            context:
                                                context,
                                          )
                                          .categories()
                                          .where(
                                            (cat) =>
                                                cat.uuid ==
                                                product
                                                    .categoryUuid,
                                          )
                                          .first
                                          .name
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
                                  amount:
                                      totalSellingPrice(),
                                  context: context,
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
                                  amount: totalCostPrice(),
                                  context: context,
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
      returnShopProvider().userShop()!,
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
      returnData().toggleIsLoading(false);
    }
  } catch (e, stackTrace) {
    print('❌ Error downloading PDF: $e\n$stackTrace');
    createErrorLog(
      error: 'Error downloading PDF: $e\n$stackTrace',
    );
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
  returnSalesProvider().toggleIsLoading(true);
  final Uint8List pdfBytes = await _buildPdfSales(
    records,
    shop,
    context,
  );

  // 2. Open native print/share/save dialog (cross-platform)
  await Printing.layoutPdf(onLayout: (_) async => pdfBytes);
  if (context.mounted) {
    returnData().toggleIsLoading(false);
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
              amount: (record.revenue - record.costPrice!),
              context: context,
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
                        shop.email ?? 'Email Not Set',
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
                                      style: pw.TextStyle(
                                        fontSize: 8,
                                      ),
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
                                        amount:
                                            record.revenue,
                                        context: context,
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
                                        amount:
                                            record
                                                .costPrice ??
                                            0,
                                        context: context,
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
                                      amount:
                                          totalSellingPrice(),
                                      context: context,
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
                                      amount:
                                          totalCostPrice(),
                                      context: context,
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
                                      amount: totalProfit(),
                                      context: context,
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
      returnShopProvider().userShop()!,
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
      returnSalesProvider().toggleIsLoading(false);
    }
  } catch (e, stackTrace) {
    print('❌ Error downloading PDF: $e\n$stackTrace');
    createErrorLog(
      error: 'Error downloading PDF: $e\n$stackTrace',
    );
  }
}

//
//
//
//

Future<void> generateAndPreviewPdfSalesSummary({
  required List<GeneralReportSalesSummaryItem> summary,
  required TempShopClass shop,
  required BuildContext context,
}) async {
  // 1. Build the PDF once (fastest way)
  returnSalesProvider().toggleIsLoading(true);
  final Uint8List pdfBytes = await _buildPdfSalesSummary(
    summary,
    shop,
    context,
  );

  // 2. Open native print/share/save dialog (cross-platform)
  await Printing.layoutPdf(onLayout: (_) async => pdfBytes);
  if (context.mounted) {
    returnData().toggleIsLoading(false);
  }
}

Future<Uint8List> _buildPdfSalesSummary(
  List<GeneralReportSalesSummaryItem> summary,
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
      tempQtty += element.totalCost;
    }
    return tempQtty;
  }

  double totalCostPrice() {
    double tempQtty = 0;
    for (var element in summary) {
      tempQtty += element.costPrice;
    }
    return tempQtty;
  }

  double totalProfit() {
    double tempQtty = 0;
    for (var element in summary) {
      tempQtty += element.totalCost - element.costPrice;
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
                        shop.email ?? 'Email not Set',
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
                                      summ.itemName,
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
                                        amount:
                                            summ.totalCost,
                                        context: context,
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
                                        amount:
                                            summ.costPrice,
                                        context: context,
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
                                        amount:
                                            summ.profit(),
                                        context: context,
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
                                      amount:
                                          totalSellingPrice(),
                                      context: context,
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
                                      amount:
                                          totalCostPrice(),
                                      context: context,
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
                                      amount: totalProfit(),
                                      context: context,
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
  required List<GeneralReportSalesSummaryItem> summary,
  required TempShopClass shop,
  required BuildContext context,
  required String filename,
}) async {
  try {
    print('Begin Download');
    final pdfBytes = await _buildPdfSalesSummary(
      summary,
      returnShopProvider().userShop()!,
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
      returnSalesProvider().toggleIsLoading(false);
    }
  } catch (e, stackTrace) {
    print('❌ Error downloading PDF: $e\n$stackTrace');
    createErrorLog(
      error: 'Error downloading PDF: $e\n$stackTrace',
    );
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

Future<void> downloadApkFromApp({
  required BuildContext context,
}) async {
  final url =
      screenWidth(context) > tabletScreenSmall
          ? Uri.parse(
            'https://apps.microsoft.com/detail/9NKK31W8032C',
            // 'https://github.com/Alex-Onyeka/Stockall/releases/download/desktop-v1.0.1/StockallDesktop.exe',
          )
          : Uri.parse(
            'https://play.google.com/store/apps/details?id=com.stockallsolutions.stockall',
            // 'https://github.com/Alex-Onyeka/Stockall/releases/download/mobile-v1.0.1/stockall.apk',
          );

  if (await canLaunchUrl(url)) {
    await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    );
  } else {
    throw 'Could not launch. $url. Please Try Again';
  }
}
