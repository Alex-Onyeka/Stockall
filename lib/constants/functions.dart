import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stockall/classes/currency_class/currency_class.dart';
import 'package:stockall/classes/temp_main_receipt/temp_main_receipt.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/classes/temp_product_slaes_record/temp_product_sale_record.dart';
import 'package:stockall/classes/temp_shop/temp_shop_class.dart';
import 'package:stockall/components/alert_dialogues/dialog_template.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/generate_barcode.dart';
import 'package:stockall/constants/subscription/branding_watermark.dart';
import 'package:stockall/constants/subscription/sales_auth.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/report/general_report/class/general_report_class.dart';
import 'package:stockall/providers/theme_provider.dart';
import 'package:stockall/services/documents/document_downloads.dart';
import 'package:stockall/services/pos_printing/pos_print_dispatcher.dart';
import 'package:stockall/services/documents/pdf_document_kit.dart'
    show docPageTheme;
import 'package:stockall/services/documents/document_model.dart'
    show DocType;
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
  final phone = getContactPhoneNumber(
    formatIndex: 2,
  ).substring(1); // your number
  final message = Uri.encodeComponent(
    "Hello, Stockall Solutions; ",
  );
  final url = 'https://wa.me/$phone?text=$message';

  await launchUrlMain(url);
}

Future<void> launchUrlMain(
  url, {
  bool sameTab = false,
}) async {
  if (await canLaunchUrl(Uri.parse(url))) {
    await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
      // On web, '_self' navigates the current tab instead of
      // opening a new one (new tabs opened after an async gap
      // are blocked as popups by iOS Safari).
      webOnlyWindowName: sameTab ? '_self' : null,
    );
  } else {
    await mainLocalLog('Could not launch $url');
  }
}

void phoneCall() async {
  final Uri uri = Uri(
    scheme: 'tel',
    path: getContactPhoneNumber(formatIndex: 2),
  );
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    throw 'Could not launch ${getContactPhoneNumber(formatIndex: 2)}';
  }
}

TargetPlatform platforms(BuildContext context) {
  return Theme.of(context).platform;
}

bool usesBluetoothPrint() {
  return !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);
}

bool usesSystemPrintDialog() {
  return !kIsWeb &&
      defaultTargetPlatform == TargetPlatform.windows;
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
  String transferProduct = 'Transfer Items';
  String manageMultipleUnits = 'Manage Multiple Units';
  String selectMultiplePriceDuringSales =
      'Select Multiple Price During Sales';
  String editSellingPrice = 'Edit Selling Price';
  String setCustomPriceDuringSales =
      'Set Custom Price During Sales';
  String sellBelowLowestSellingPrice =
      'Sell Below Lowest Selling Price';
  String addCustomer = 'Add Customers';
  String updateCustomer = 'Update Customers';
  String deleteCustomer = 'Delete Customers';
  String addSupplier = 'Add Suppliers';
  String updateSupplier = 'Update Suppliers';
  String deleteSupplier = 'Delete Suppliers';
  String viewCustomersAccount = 'View Customers Account';
  String deleteCustomersTransactions =
      'Delete Customers Transactions';
  String toggleManageCustomersReward =
      'Toggle Manage Customers Reward';
  String toggleManageCustomersAccount =
      'Toggle Manage Customers Account';
  String redeemCustomersReward = 'Redeem Customers Reward';
  String creditCustomersAccount =
      'Credit Customers Account';
  String debitCustomersAccount = 'Debit Customers Account';
  String makeSalesFromCustomersAccount =
      'Make Sales From Customers Account';
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
  String viewItemsHistory = 'View Items History';
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
  String viewStorageReport = 'View Storage Report';
  String viewReceiptSalesReport =
      'View Receipt Sales Report';
  String viewInvoiceSalesReport =
      'View Invoice Sales Report';
  String viewItemSalesReport = 'View Item Sales Report';
  String managePurchases = 'Manage Purchases';
  String updateInvoice = 'Update Invoice';
  String deleteInvoice = 'Delete Invoice';
  String toggleManageProductions =
      'Toggle Manage Productions';
  String toggleManageProductionsStorage =
      'Toggle Manage Productions Storage';
  String toggleManageProductionItems =
      'Toggle Manage Production Items';
  String viewProductions = 'View Productions';
  String manageProductionsStorage =
      'Manage Productions Storage';
  String addMaterials = 'Add Materials';
  String updateMaterials = 'Update Materials';
  String deleteMaterials = 'Delete Materials';
  String transferMaterials = 'Transfer Materials';
  String updateMaterialQuantity =
      'Update Material Quantity';
  String viewMaterialQuantity = 'View Material Quantity';
  String addProductionItems = 'Add Production Items';
  String updateProductionItems = 'Update Production Items';
  String deleteProductionItems = 'Delete Production Items';
  String transferProductionItems =
      'Transfer Production Items';
  String updateProductionItemQuantity =
      'Update Production Item Quantity';
  String viewProductionItemQuantity =
      'View Production Item Quantity';
  String addProductionRecords = 'Add Production Records';
  String updateProductionRecords =
      'Update Production Records';
  String deleteProductionRecords =
      'Delete Production Records';
  String addMaterialsUsage = 'Add Materials Usage';
  String updateMaterialsUsage = 'Update Materials Usage';
  String deleteMaterialsUsage = 'Delete Materials Usage';
  String manageOrders = 'Manage Orders';
  String addOrders = 'Add Orders';
  String updateOrders = 'Update Orders';
  String deleteOrders = 'Delete Orders';
  String manageLocalServer = 'Manage Local Server';
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
      try {
        final Uint8List bytes = await _buildPdf(
          receipt,
          staffName,
          records,
          shop,
          context,
        );
        final now = DateTime.now();

        // dart:io Platform is not available on web.
        if (kIsWeb) {
          downloadPdfBytesWeb(
            bytes,
            documentWebDownloadName(DocType.receipt, now),
          );
          return;
        }

        var name = documentDownloadName(
          DocType.receipt,
          receipt.uuid,
          now,
        );

        if (Platform.isAndroid || Platform.isIOS) {
          await savePdfMobile(bytes, name);
        } else {
          await mainLocalLog('Printing For Desktop');
          await savePdfDesktop(bytes, name);
        }
      } catch (e, stackTrace) {
        await mainLocalLog(
          '❌ Error downloading receipt PDF: $e\n$stackTrace',
        );
      } finally {
        if (context.mounted) {
          returnReceiptProvider(
            context,
            listen: false,
          ).toggleIsLoading(false);
        }
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
      // Straight to the POS printer on mobile and desktop; the system
      // print dialog on web (lib/services/pos_printing).
      try {
        await printRollDocument(
          context: context,
          document: receiptDownloadDocument(
            receipt: receipt,
            records: records,
            staffName: staffName,
            shop: shop,
            assets: DocShopAssets.current(),
          ),
          format: docFormatFor(shop),
          shopPrintType: printerType,
          rollPdf:
              (type) => _buildPdfRoll(
                receipt,
                records,
                staffName,
                shop,
                context,
                type,
              ),
        );
      } catch (e, stackTrace) {
        await mainLocalLog(
          '❌ Error printing receipt: $e\n$stackTrace',
        );
      } finally {
        if (context.mounted) {
          returnReceiptProvider(
            context,
            listen: false,
          ).toggleIsLoading(false);
        }
      }
    },
  );
}

// Same roll layout as generateAndPreviewPdfRoll, returned as PDF bytes
// so Bluetooth printing can rasterize it.
Future<Uint8List> buildReceiptRollPdf({
  required TempMainReceipt receipt,
  required List<TempProductSaleRecord> records,
  required String staffName,
  required TempShopClass shop,
  required BuildContext context,
  required int printerType,
}) {
  return _buildPdfRoll(
    receipt,
    records,
    staffName,
    shop,
    context,
    printerType,
  );
}

// A4 receipt from the shared document builder (lib/services/documents).
Future<Uint8List> _buildPdf(
  TempMainReceipt receipt,
  String staffName,
  List<TempProductSaleRecord> records,
  TempShopClass shop,
  BuildContext context,
) {
  return salesDocumentA4Pdf(
    receiptDownloadDocument(
      receipt: receipt,
      records: records,
      staffName: staffName,
      shop: shop,
      assets: DocShopAssets.current(),
    ),
    shop,
  );
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
      // White page, so dark-mode PDF viewers don't show it black.
      pageTheme: docPageTheme(
        pageFormat:
            printerType == 1
                ? PdfPageFormat.roll57
                : PdfPageFormat.roll80,
        margin: pw.EdgeInsets.only(
          left: kIsWeb ? 2 : 0,
          top: 5,
          right: kIsWeb ? 15 : 0,
          bottom: 10,
        ),
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
                                        fontSize: parText,
                                      ),
                                      'Payment Method:',
                                    ),
                                    pw.SizedBox(height: 1),
                                    pw.Builder(
                                      builder: (
                                        beansContext,
                                      ) {
                                        return pw.Column(
                                          crossAxisAlignment:
                                              pw
                                                  .CrossAxisAlignment
                                                  .start,
                                          children: [
                                            ...receipt.displayPayments().map(
                                              (
                                                payment,
                                              ) => pw.Text(
                                                style: pw.TextStyle(
                                                  font:
                                                      fontRegular,
                                                  fontSize:
                                                      parTextAlt,
                                                ),
                                                '${payment.method}: ${formatMoneyMid(amount: payment.amount, context: context)}',
                                                softWrap:
                                                    true,
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              pw.Expanded(
                                flex: 2,
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
                pw.Builder(
                  builder: (pw.Context pdfContext) {
                    if (receipt.comment != null &&
                        receipt.comment?.isNotEmpty ==
                            true) {
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
                                      'Comment:',
                                    ),
                                    pw.SizedBox(height: 1),
                                    pw.Text(
                                      style: pw.TextStyle(
                                        font: fontBold,
                                        fontSize: parText,
                                      ),
                                      receipt.comment ??
                                          'Comment',
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
                            '${record.productName}${record.dimensionsLabel()} ${record.wastageNote().isEmpty ? '' : '\n${record.wastageNote()}'}',
                          ),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Text(
                            style: pw.TextStyle(
                              fontSize: parText,
                            ),
                            '[ ${formatLargeNumberDouble(record.quantityType == 2 ? record.displayQuantity() : record.getActualQuantity())} ] ',
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
                              //   "1x  ${formatMoneyMid(amount: ((receipt.fixedDiscount == null && receipt.generalDiscount == null) && record.discount != null ? ((record.originalCost ?? 0) - (record.discountedAmount ?? 0)) : (record.originalCost ?? 0) / record.getActualQuantity()), context: context)}",
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
                pw.SizedBox(height: 20),
                // pw.Text(
                //   textAlign: pw.TextAlign.center,
                //   style: pw.TextStyle(
                //     fontSize: totalText,
                //     fontWeight: pw.FontWeight.bold,
                //     // color: PdfColor(50, 50, 050),
                //   ),
                //   '------------',
                // ),
                // pw.Builder(
                //   builder: (beansContext) {
                //     if (records.length > 15) {
                //       return pw.Text(
                //         textAlign: pw.TextAlign.center,
                //         style: pw.TextStyle(
                //           fontSize: totalText,
                //           fontWeight: pw.FontWeight.bold,
                //           // color: PdfColor(50, 50, 050),
                //         ),
                //         '------------',
                //       );
                //     } else {
                //       return pw.Container();
                //     }
                //   },
                // ),
                // pw.Builder(
                //   builder: (beansContext) {
                //     if (records.length > 15) {
                //       return pw.Text(
                //         textAlign: pw.TextAlign.center,
                //         style: pw.TextStyle(
                //           fontSize: totalText,
                //           fontWeight: pw.FontWeight.bold,
                //           // color: PdfColor(50, 50, 050),
                //         ),
                //         '------------',
                //       );
                //     } else {
                //       return pw.Container();
                //     }
                //   },
                // ),
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
        pdfFileName: "downloaded_receipt.pdf",
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
        downloadPdfBytesWeb(pdfBytes, filename);
      } catch (e, stackTrace) {
        await mainLocalLog(
          '❌ Error downloading PDF: $e\n$stackTrace',
        );
        returnErrorLogProvider().createLog(
          error: 'Error downloading PDF: $e\n$stackTrace',
        );
      } finally {
        if (context.mounted) {
          returnReceiptProvider(
            context,
            listen: false,
          ).toggleIsLoading(false);
        }
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
        await mainLocalLog('Begin Download');
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
        await mainLocalLog(
          '❌ Error downloading/printing PDF: $e\n$stackTrace',
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
      if ((element.getActualQuantity() ?? 0) > 0) {
        tempStock += 1;
      }
    }
    return tempStock;
  }

  int lowStock() {
    int tempStock = 0;
    for (var element in products) {
      if ((element.getActualQuantity() ?? 0) <=
              (element.lowQtty ?? 0) &&
          element.getActualQuantity() != 0) {
        tempStock += 1;
      }
    }
    return tempStock;
  }

  int outOfStock() {
    int tempStock = 0;
    for (var element in products) {
      if (element.getActualQuantity() == 0) {
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
      tempQtty += element.getActualQuantity() ?? 0;
    }
    return tempQtty;
  }

  double totalSellingPrice() {
    double tempQtty = 0;
    for (var element in products) {
      tempQtty += element.getPrimaryPrice().priceValue;
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
                    if (shouldShowBrandingWatermark()) ...[
                      pw.SizedBox(width: 15),
                      pw.Text(
                        'Created by $appName Solutions - ( www.stockallapp.com )',
                        style: pw.TextStyle(
                          font: fontRegular,
                          fontSize: 9,
                        ),
                      ),
                    ],
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
                                  (product.getActualQuantity() ??
                                          0)
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
                                            .getPrimaryPrice()
                                            .priceValue,
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
                                                product
                                                    .categories
                                                    ?.contains(
                                                      cat.uuid,
                                                    ) ==
                                                true,
                                          )
                                          .isNotEmpty
                                      ? returnCategoriesProvider(
                                            context:
                                                context,
                                          )
                                          .categories()
                                          .where(
                                            (cat) =>
                                                product
                                                    .categories
                                                    ?.contains(
                                                      cat.uuid,
                                                    ) ==
                                                true,
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
    await mainLocalLog('Begin Download');
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
    await mainLocalLog(
      '❌ Error downloading PDF: $e\n$stackTrace',
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
      tempQtty +=
          element.quantityType == 2
              ? element.displayQuantity()
              : element.getActualQuantity();
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
                    if (shouldShowBrandingWatermark()) ...[
                      pw.SizedBox(width: 15),
                      pw.Text(
                        'Created by $appName Solutions - ( www.stockallapp.com )',
                        style: pw.TextStyle(
                          font: fontRegular,
                          fontSize: 9,
                        ),
                      ),
                    ],
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
                                      '${record.productName}${record.wastageNote().isEmpty ? '' : '\n${record.wastageNote()}'}',
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
                                      // 2D: sale units with wastage
                                      // (1.1), so not rounded.
                                      record.quantityType ==
                                              2
                                          ? formatLargeNumberDouble(
                                            record
                                                .displayQuantity(),
                                          )
                                          : (record
                                                  .getActualQuantity())
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
    await mainLocalLog('Begin Download');
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
    await mainLocalLog(
      '❌ Error downloading PDF: $e\n$stackTrace',
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
                    if (shouldShowBrandingWatermark()) ...[
                      pw.SizedBox(width: 15),
                      pw.Text(
                        'Created by $appName Solutions - ( www.stockallapp.com )',
                        style: pw.TextStyle(
                          font: fontRegular,
                          fontSize: 9,
                        ),
                      ),
                    ],
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
    await mainLocalLog('Begin Download');
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
    await mainLocalLog(
      '❌ Error downloading PDF: $e\n$stackTrace',
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

Future<void> _launchExternalDownloadUrl(Uri url) async {
  if (await canLaunchUrl(url)) {
    await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    );
  } else {
    throw 'Could not launch. $url. Please Try Again';
  }
}

Future<void> downloadApkFromApp({
  required BuildContext context,
}) async {
  if (screenWidth(context) <= tabletScreenSmall) {
    final url = Uri.parse(
      'https://play.google.com/store/apps/details?id=com.stockallsolutions.stockall',
    );
    await _launchExternalDownloadUrl(url);
    return;
  }

  final utilityProvider = returnUtilityConstantProvider();
  var constants = utilityProvider.utilityConstants;
  constants ??= await utilityProvider.getUtilityConstants();
  if (!context.mounted) return;

  final theme = returnTheme(context, listen: false);
  final githubLink =
      constants?.desktopDownloadLink.trim() ?? '';
  const microsoftStoreUrl =
      'https://apps.microsoft.com/detail/9NKK31W8032C';

  await showDialog(
    context: context,
    builder: (dialogContext) {
      return DialogTemplate(
        theme: theme,
        title: 'Download Update',
        message:
            'Choose how you would like to download the latest Stockall desktop update.',
        action: () {},
        showMainBottomActionButton: false,
        cancelText: 'Close',
        widget: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: [
            _DownloadOptionTile(
              theme: theme,
              icon: Icons.download_rounded,
              title: 'Download from Stockall',
              subtitle:
                  'Download the installer directly from Stockall (GitHub)',
              accentColor: theme.lightModeColor.prColor300,
              onTap: () async {
                Navigator.of(dialogContext).pop();
                if (githubLink.isEmpty) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Direct download link is not available right now. Please try Microsoft Store.',
                        ),
                      ),
                    );
                  }
                  return;
                }
                await _launchExternalDownloadUrl(
                  Uri.parse(githubLink),
                );
              },
            ),
            _DownloadOptionTile(
              theme: theme,
              icon: Icons.storefront_rounded,
              title: 'Download from Microsoft Store',
              subtitle:
                  'Open Stockall on the Microsoft Store',
              accentColor: theme.lightModeColor.secColor200,
              onTap: () async {
                Navigator.of(dialogContext).pop();
                await _launchExternalDownloadUrl(
                  Uri.parse(microsoftStoreUrl),
                );
              },
            ),
          ],
        ),
      );
    },
  );
}

class _DownloadOptionTile extends StatelessWidget {
  final ThemeProvider theme;
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accentColor;
  final VoidCallback onTap;

  const _DownloadOptionTile({
    required this.theme,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        mouseCursor: SystemMouseCursors.click,
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
            color: Colors.grey.shade50,
          ),
          child: Row(
            spacing: 12,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accentColor.withValues(
                    alpha: 0.12,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: accentColor,
                  size: 22,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b2.fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b4.fontSize,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.grey.shade500,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
