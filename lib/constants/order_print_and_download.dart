import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_orders/order_items.dart';
import 'package:stockall/classes/temp_orders/orders.dart';
import 'package:stockall/classes/temp_shop/temp_shop_class.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/generate_barcode.dart';
import 'package:stockall/constants/subscription/sales_auth.dart';
import 'package:stockall/main.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show rootBundle;

// Order roll layout, modelled on _buildPdfRollInvoice so all three
// documents print with the same header, fonts and 58mm/80mm sizing.
Future<Uint8List> _buildPdfRollOrder({
  required Orders order,
  required List<OrderItems> records,
  required String staffName,
  required TempShopClass shop,
  required BuildContext context,
  required int printerType,
}) async {
  double headingText = printerType == 1 ? 12 : 14;
  double parText = printerType == 1 ? 7 : 9;
  double parTextAlt = printerType == 1 ? 5 : 7;
  double totalText = printerType == 1 ? 8 : 10;
  final pdf = pw.Document();
  final ordersProvider = returnOrdersProvider();

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

  // Label above a bold value, as in the invoice info rows.
  pw.Widget infoCell(String label, String value) {
    return pw.Expanded(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            style: pw.TextStyle(
              font: fontRegular,
              fontSize: parText,
            ),
            label,
          ),
          pw.SizedBox(height: 1),
          pw.Text(
            style: pw.TextStyle(
              font: fontBold,
              fontSize: parText,
            ),
            value,
          ),
        ],
      ),
    );
  }

  pw.Widget infoRow(List<pw.Widget> cells) {
    return pw.Column(
      children: [
        pw.SizedBox(height: 3),
        pw.Row(
          mainAxisAlignment:
              pw.MainAxisAlignment.spaceEvenly,
          children: cells,
        ),
      ],
    );
  }

  // Label on the left, amount on the right, as in the invoice totals.
  pw.Widget totalRow(
    String label,
    String value, {
    bool emphasize = false,
  }) {
    return pw.Column(
      children: [
        pw.Row(
          mainAxisAlignment:
              pw.MainAxisAlignment.spaceEvenly,
          children: [
            pw.Expanded(
              flex: 9,
              child: pw.Text(
                style: pw.TextStyle(
                  font: fontRegular,
                  fontSize:
                      emphasize ? parText : parTextAlt,
                ),
                label,
              ),
            ),
            pw.Expanded(
              flex: 7,
              child: pw.Text(
                style: pw.TextStyle(
                  font: emphasize ? fontBold : fontRegular,
                  fontSize:
                      emphasize ? parText : parTextAlt,
                ),
                value,
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 1),
      ],
    );
  }

  pw.Widget shopLine(String text, {bool bold = false}) {
    return pw.Column(
      children: [
        pw.SizedBox(height: 1),
        pw.Text(
          textAlign: pw.TextAlign.center,
          text,
          style: pw.TextStyle(
            font: bold ? fontBold : fontRegular,
            fontSize: bold ? headingText : parText,
          ),
          overflow: pw.TextOverflow.clip,
        ),
      ],
    );
  }

  pw.Widget socialLine(String label, String? handle) {
    return pw.Column(
      children: [
        pw.SizedBox(height: 1),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            pw.Text(
              textAlign: pw.TextAlign.center,
              label,
              style: pw.TextStyle(
                font: fontBold,
                fontSize: handle == null ? 1 : parTextAlt,
              ),
            ),
            pw.Text(
              textAlign: pw.TextAlign.center,
              handle ?? '',
              style: pw.TextStyle(
                font: fontRegular,
                fontSize: handle == null ? 1 : parText,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String money(double amount) {
    return formatMoneyMid(amount: amount, context: context);
  }

  final ticketId =
      order.barcode ?? returnOnlyDigits(order.uuid ?? '');
  final status = order.getOrderStatus();

  pdf.addPage(
    pw.Page(
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
                if (returnShopProvider().selectedLogo !=
                    null)
                  pw.Container(
                    height:
                        (returnShopProvider().imageWidth ??
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
                        returnShopProvider().selectedLogo ??
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
                      textAlign: pw.TextAlign.center,
                      "#Shop Id: ${shopRef()}",
                      style: pw.TextStyle(
                        font: fontBold,
                        fontSize: parText,
                      ),
                    ),
                  ],
                ),
                if (returnShopProvider().selectedLogo !=
                    null)
                  pw.SizedBox(height: 2),
                if (shop.showShopName!)
                  shopLine(shop.name, bold: true),
                if (shop.showEmail! && shop.email != null)
                  shopLine(shop.email ?? ''),
                if (shop.showPhone! &&
                    shop.phoneNumber != null)
                  shopLine(shop.phoneNumber ?? ''),
                if (shop.showAddress! &&
                    shop.shopAddress != null)
                  shopLine(shop.shopAddress ?? ''),
                if (shop.showFacebookTop!)
                  socialLine(
                    'Facebook:',
                    shop.faceBookHandle,
                  ),
                if (shop.showInstaTop!)
                  socialLine(
                    'Instagram:',
                    shop.instaHandle,
                  ),
                pw.SizedBox(height: 3),
                pw.Divider(
                  color: PdfColor.fromHex('#1C1C1C'),
                  thickness: 0.5,
                  height: 4,
                ),
                pw.Row(
                  mainAxisAlignment:
                      pw.MainAxisAlignment.center,
                  children: [
                    pw.Text(
                      textAlign: pw.TextAlign.center,
                      'Order',
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

                // 🔹 ORDER DETAILS
                if (shop.showFirst!)
                  pw.Row(
                    mainAxisAlignment:
                        pw.MainAxisAlignment.spaceEvenly,
                    children: [
                      infoCell('Staff Name:', staffName),
                      infoCell(
                        'Customer Name:',
                        order.customerName ?? 'Not Set',
                      ),
                    ],
                  ),
                if (shop.showSecond! &&
                    order.subStaffName != null)
                  infoRow([
                    infoCell(
                      'Waiter:',
                      order.subStaffName ?? 'Not Set',
                    ),
                    infoCell(
                      'Receipt Id:',
                      order.cartName ?? 'Not Set',
                    ),
                  ]),
                if (shop.showThird!)
                  infoRow([
                    infoCell(
                      'Date:',
                      formatDateTime(order.createdAt),
                    ),
                    infoCell(
                      'Time:',
                      formatTime(order.createdAt),
                    ),
                  ]),
                infoRow([infoCell('#Ticket ID', ticketId)]),
                if (order.comment != null &&
                    order.comment?.isNotEmpty == true)
                  infoRow([
                    infoCell(
                      'Comment:',
                      order.comment ?? 'Comment',
                    ),
                  ]),
                pw.SizedBox(height: 3),
                pw.Divider(thickness: 0.6, height: 6),

                // 🔹 ITEMS
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
                      crossAxisAlignment:
                          pw.CrossAxisAlignment.start,
                      children: [
                        pw.Expanded(
                          flex: 6,
                          child: pw.Column(
                            crossAxisAlignment:
                                pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                style: pw.TextStyle(
                                  fontSize: parText,
                                ),
                                '${record.productName} ',
                              ),
                              // Partly delivered, as flagged on the order item tile.
                              if ((record.remainingQuantity ??
                                      record.quantity) <
                                  record.quantity)
                                pw.Text(
                                  style: pw.TextStyle(
                                    fontSize: parTextAlt,
                                  ),
                                  'Remaining: ${formatLargeNumberDouble(record.remainingQuantity ?? record.quantity)} ${record.getUnit()}',
                                ),
                            ],
                          ),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Text(
                            style: pw.TextStyle(
                              fontSize: parTextAlt,
                            ),
                            '( ${formatLargeNumberDouble(record.quantity)} ${record.getUnit()} ) ',
                          ),
                        ),
                        pw.Expanded(
                          flex: 4,
                          child: pw.Text(
                            style: pw.TextStyle(
                              font: fontRegular,
                              fontSize: parText,
                            ),
                            money(record.getTotalRevenue()),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                pw.SizedBox(height: 3),
                pw.Divider(thickness: 0.6, height: 10),

                // 🔹 TOTALS
                totalRow(
                  'Subtotal:',
                  money(
                    ordersProvider.getOriginalCostOrder(
                      order,
                    ),
                  ),
                ),
                if (order.fixedDiscount != null ||
                    order.generalDiscount != null)
                  totalRow(
                    order.generalDiscount != null
                        ? 'Discount: (${order.generalDiscount}%)'
                        : 'Discount:',
                    money(
                      ordersProvider
                          .getDiscountAmountForOrder(order),
                    ),
                  ),
                if (order.vat != null)
                  totalRow(
                    'VAT: (${order.vat ?? 0}%)',
                    money(
                      ordersProvider.getVATForOrder(order),
                    ),
                  ),
                if (order.getCalculatedRemainingBalance() >
                    0)
                  totalRow(
                    'Balance:',
                    money(
                      order.getCalculatedRemainingBalance(),
                    ),
                  ),
                totalRow(
                  'Paid:',
                  money(
                    ordersProvider.getAmountPaid(
                      order: order,
                    ),
                  ),
                ),
                totalRow(
                  'Status:',
                  status == 0
                      ? 'Unpaid'
                      : status == 1
                      ? 'Partial'
                      : 'Paid',
                ),
                totalRow(
                  'Total:',
                  money(
                    ordersProvider.getTotalMainRevenueOrder(
                      order: order,
                    ),
                  ),
                  emphasize: true,
                ),

                // 🔹 FOOTER
                pw.SizedBox(height: 5),
                pw.Divider(),
                pw.Padding(
                  padding: pw.EdgeInsets.only(right: 10),
                  child: pw.SvgImage(
                    svg: pw.Barcode.ean13().toSvg(
                      ticketId,
                      width: 110,
                      height: 30,
                      fontHeight: 8,
                      drawText: true,
                    ),
                  ),
                ),
                pw.Divider(height: 8),
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
                //   ),
                //   '------------',
                // ),
              ],
            ),
          ),
    ),
  );

  return pdf.save();
}

Future<void> generateAndPreviewPdfRollOrder({
  required Orders order,
  required List<OrderItems> records,
  required String staffName,
  required TempShopClass shop,
  required BuildContext context,
  required int printerType,
}) async {
  SalesAuthAction().printReceiptAction(
    context: context,
    action: () async {
      final Uint8List pdfBytes = await _buildPdfRollOrder(
        order: order,
        records: records,
        staffName: staffName,
        shop: shop,
        context: context,
        printerType: printerType,
      );

      await Printing.layoutPdf(
        onLayout: (_) async => pdfBytes,
      );
    },
  );
}

// Same roll layout as generateAndPreviewPdfRollOrder, returned as PDF
// bytes so Bluetooth printing can rasterize it.
Future<Uint8List> buildOrderRollPdf({
  required Orders order,
  required List<OrderItems> records,
  required String staffName,
  required TempShopClass shop,
  required BuildContext context,
  required int printerType,
}) {
  return _buildPdfRollOrder(
    order: order,
    records: records,
    staffName: staffName,
    shop: shop,
    context: context,
    printerType: printerType,
  );
}
