import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:stockall/classes/payment_entry/payment_entry.dart';
import 'package:stockall/classes/temp_invoices/temp_invoices.dart';
import 'package:stockall/classes/temp_main_receipt/temp_main_receipt.dart';
import 'package:stockall/classes/temp_orders/order_items.dart';
import 'package:stockall/classes/temp_orders/orders.dart';
import 'package:stockall/classes/temp_product_slaes_record/temp_product_sale_record.dart';
import 'package:stockall/classes/temp_shop/temp_shop_class.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/generate_barcode.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/pos_printer/device_service.dart';
import 'package:stockall/services/printing/escpos_builder.dart';
import 'package:stockall/services/printing/pdf_escpos_raster.dart';

// ESC/POS versions of the roll PDFs (_buildPdfRoll, _buildPdfRollInvoice,
// _buildPdfRollOrder) for Bluetooth printers. Sections, labels and
// conditions follow the PDFs; sizes map to bold, double height and Font B.

// Name / qty / price, as the flex 6 / 2 / 4 rows in the PDFs.
const List<int> _itemFlex = [6, 2, 4];

// PDF points to printer dots at 203 dpi.
const double _pointsToDots = 203 / 72;

int _paperDots(int printerType) =>
    printerType == 1 ? dots58mm : dots80mm;

EscPosBuilder buildReceiptEscPos({
  required TempMainReceipt receipt,
  required List<TempProductSaleRecord> records,
  required String staffName,
  required TempShopClass shop,
  required BuildContext context,
  required int printerType,
  bool printLogo = true,
}) {
  final b = EscPosBuilder(
    paperDots: _paperDots(printerType),
  );
  final receiptsProvider = returnReceiptProvider(
    context,
    listen: false,
  );
  String money(double amount) =>
      formatMoneyMid(amount: amount, context: context);
  final ticketId =
      receipt.barcode ??
      returnOnlyDigits(receipt.uuid ?? '');
  final noReceiptDiscount =
      receipt.fixedDiscount == null &&
      receipt.generalDiscount == null;

  _shopHeader(
    b,
    shop,
    'Payment Receipt',
    printLogo: printLogo,
  );

  if (shop.showFirst!) {
    _infoRow(b, [
      ('Staff Name:', staffName),
      if (receipt.customerUuid != null)
        (
          'Customer Name:',
          receipt.customerName ?? 'Not Set',
        ),
    ]);
    if (receipt.subStaffName != null) {
      _infoRow(b, [
        ('Waiter:', receipt.subStaffName ?? 'Not Set'),
        ('Receipt Id:', receipt.cartName ?? 'Not Set'),
      ]);
    }
  }
    if (shop.showSecond!) {
    final String payment = receipt
        .displayPayments()
        .map((p) => '${p.method}: ${money(p.amount)}')
        .join('\n');
    b.columns([
      EscCol('Payment Method:', flex: 2),
      EscCol('#Ticket ID', flex: 1, align: EscAlign.right),
    ]);
    b.columns([
      EscCol(payment, flex: 2),
      EscCol(ticketId, bold: true, flex: 1, align: EscAlign.right),
    ]);
  }
  if (shop.showThird!) {
    _infoRow(b, [
      ('Date:', formatDateTime(receipt.createdAt)),
      ('Time:', formatTime(receipt.createdAt)),
    ]);
  }
  if (receipt.comment != null &&
      receipt.comment?.isNotEmpty == true) {
    _infoRow(b, [
      ('Comment:', receipt.comment ?? 'Comment'),
    ]);
  }

  b.divider();
  b.columns([
    EscCol('Items:', flex: _itemFlex[0], bold: true),
    EscCol('Qty:', flex: _itemFlex[1], bold: true),
    EscCol('Price:', flex: _itemFlex[2], bold: true),
  ]);
  for (final record in records) {
    _itemRow(
      b,
      '${record.productName}${record.dimensionsLabel()}',
      '[${formatLargeNumberDouble(record.displayQuantity())}]',
      money(
        noReceiptDiscount && record.discount != null
            ? ((record.originalCost ?? 0) -
                (record.discountedAmount ?? 0))
            : (record.originalCost ?? 0),
      ),
    );
    if (record.wastageNote().isNotEmpty) {
      b.smallUnderColumn(
        record.wastageNote(),
        _itemFlex,
        0,
      );
    }
  }

  b.divider();
  _totalRow(
    b,
    'Subtotal:',
    money(receiptsProvider.getOriginalCostReceipt(receipt)),
  );
  if (!noReceiptDiscount) {
    _totalRow(
      b,
      receipt.generalDiscount != null
          ? 'Discount: (${receipt.generalDiscount}%)'
          : 'Discount:',
      money(
        receiptsProvider.getDiscountAmountForReceipt(
          receipt,
        ),
      ),
    );
  }
  if (receipt.vat != null) {
    _totalRow(
      b,
      'VAT: (${receipt.vat ?? 0}%)',
      money(receiptsProvider.getVATForReceipt(receipt)),
    );
  }
  if (receipt.balance != null) {
    _totalRow(b, 'Balance:', money(receipt.balance ?? 0));
  }
  _totalRow(
    b,
    'Total:',
    money(
      receiptsProvider.getTotalMainRevenueReceipt(receipt),
    ),
    emphasize: true,
  );

  _footer(b, shop, ticketId);
  return b;
}

EscPosBuilder buildInvoiceEscPos({
  required TempInvoice invoice,
  required List<TempProductSaleRecord> records,
  required String staffName,
  required TempShopClass shop,
  required BuildContext context,
  required int printerType,
  bool printLogo = true,
}) {
  final b = EscPosBuilder(
    paperDots: _paperDots(printerType),
  );
  String money(double amount) =>
      formatMoneyMid(amount: amount, context: context);
  final ticketId =
      invoice.barcode ??
      returnOnlyDigits(invoice.uuid ?? '');
  final noInvoiceDiscount =
      invoice.fixedDiscount == null &&
      invoice.generalDiscount == null;

  _shopHeader(
    b,
    shop,
    'Invoice Receipt',
    printLogo: printLogo,
  );

  if (shop.showFirst!) {
    _infoRow(b, [
      ('Staff Name:', staffName),
      ('Customer Name:', invoice.customerName ?? 'Not Set'),
    ]);
  }
    if (shop.showSecond!) {
    b.columns([
      EscCol('Payment Method:', flex: 2),
      EscCol('Amount(s):', flex: 1, align: EscAlign.right),
    ]);
    final invBankName =
        invoice.selectedBank?.displayName ??
        (PaymentMethods.isBankMethod(invoice.paymentMethod)
            ? invoice.paymentMethod
            : 'Bank');
    final amounts = invoice.cashAlt == 0
        ? '$invBankName: ${money(invoice.bank)}'
        : invoice.bank == 0
            ? 'Cash: ${money(invoice.cashAlt)}'
            : 'Cash: ${money(invoice.cashAlt)}\n$invBankName: ${money(invoice.bank)}';
    b.columns([
      EscCol(
        invoice.selectedBank?.displayName ??
            invoice.paymentMethod,
        bold: true,
        flex: 2,
      ),
      EscCol(
        amounts,
        flex: 1,
        align: EscAlign.right,
      ),
    ]);
    if (invoice.subStaffName != null) {
      _infoRow(b, [
        ('Waiter:', invoice.subStaffName ?? 'Not Set'),
        ('Receipt Id:', invoice.cartName ?? 'Not Set'),
      ]);
    }
  }
  if (shop.showThird!) {
    _infoRow(b, [
      ('Date:', formatDateTime(invoice.createdAt)),
      ('Time:', formatTime(invoice.createdAt)),
    ]);
  }
  _infoRow(b, [('#Ticket ID', ticketId)]);
  if (invoice.comment != null &&
      invoice.comment?.isNotEmpty == true) {
    _infoRow(b, [
      ('Comment:', invoice.comment ?? 'Comment'),
    ]);
  }

  b.divider();
  b.text('Items:', bold: true);
  for (final record in records) {
    _itemRow(
      b,
      '${record.productName}${record.dimensionsLabel()}',
      '(${formatLargeNumberDouble(record.displayQuantity())})',
      money(
        noInvoiceDiscount && record.discount != null
            ? ((record.originalCost ?? 0) -
                (record.discountedAmount ?? 0))
            : (record.originalCost ?? 0),
      ),
    );
    if (record.wastageNote().isNotEmpty) {
      b.smallUnderColumn(
        record.wastageNote(),
        _itemFlex,
        0,
      );
    }
    // The PDF strikes through the original price; ESC/POS can't.
    if (record.discount != null &&
        !record.customPriceSet &&
        noInvoiceDiscount) {
      b.smallUnderColumn(
        'was ${money(record.originalCost ?? 0)}',
        _itemFlex,
        2,
      );
    }
  }

  b.divider();
  _totalRow(
    b,
    'Subtotal:',
    money(invoice.getOriginalCostInvoice()),
  );
  if (!noInvoiceDiscount) {
    _totalRow(
      b,
      invoice.generalDiscount != null
          ? 'Discount: (${invoice.generalDiscount}%)'
          : 'Discount:',
      money(invoice.getDiscountAmountForInvoice()),
    );
  }
  if (invoice.vat != null) {
    _totalRow(
      b,
      'VAT: (${invoice.vat ?? 0}%)',
      money(invoice.getVATInvoice()),
    );
  }
  if (invoice.getBalance() > 0) {
    _totalRow(b, 'Balance:', money(invoice.getBalance()));
  }
  _totalRow(b, 'Paid:', money(invoice.getAmountPaid()));
  _totalRow(
    b,
    'Total:',
    money(invoice.getTotalMainRevenueInvoice()),
    emphasize: true,
  );

  _footer(b, shop, ticketId);
  return b;
}

EscPosBuilder buildOrderEscPos({
  required Orders order,
  required List<OrderItems> records,
  required String staffName,
  required TempShopClass shop,
  required BuildContext context,
  required int printerType,
  bool printLogo = true,
}) {
  final b = EscPosBuilder(
    paperDots: _paperDots(printerType),
  );
  final ordersProvider = returnOrdersProvider();
  String money(double amount) =>
      formatMoneyMid(amount: amount, context: context);
  final ticketId =
      order.barcode ?? returnOnlyDigits(order.uuid ?? '');
  final status = order.getOrderStatus();

  _shopHeader(b, shop, 'Order', printLogo: printLogo);

  if (shop.showFirst!) {
    _infoRow(b, [
      ('Staff Name:', staffName),
      ('Customer Name:', order.customerName ?? 'Not Set'),
    ]);
  }
  if (shop.showSecond! && order.subStaffName != null) {
    _infoRow(b, [
      ('Waiter:', order.subStaffName ?? 'Not Set'),
      ('Receipt Id:', order.cartName ?? 'Not Set'),
    ]);
  }
  if (shop.showThird!) {
    _infoRow(b, [
      ('Date:', formatDateTime(order.createdAt)),
      ('Time:', formatTime(order.createdAt)),
    ]);
  }
  _infoRow(b, [('#Ticket ID', ticketId)]);
  if (order.comment != null &&
      order.comment?.isNotEmpty == true) {
    _infoRow(b, [('Comment:', order.comment ?? 'Comment')]);
  }

  b.divider();
  b.text('Items:', bold: true);
  for (final record in records) {
    _itemRow(
      b,
      '${record.productName}${record.dimensionsLabel()}',
      '(${formatLargeNumberDouble(record.quantity)} ${record.getUnit()})',
      money(record.getTotalRevenue()),
    );
    // Partly delivered, as flagged on the order item tile.
    if ((record.remainingQuantity ?? record.quantity) <
        record.quantity) {
      b.smallUnderColumn(
        'Remaining: ${formatLargeNumberDouble(record.remainingQuantity ?? record.quantity)} ${record.getUnit()}',
        _itemFlex,
        0,
      );
    }
  }

  b.divider();
  _totalRow(
    b,
    'Subtotal:',
    money(ordersProvider.getOriginalCostOrder(order)),
  );
  if (order.fixedDiscount != null ||
      order.generalDiscount != null) {
    _totalRow(
      b,
      order.generalDiscount != null
          ? 'Discount: (${order.generalDiscount}%)'
          : 'Discount:',
      money(
        ordersProvider.getDiscountAmountForOrder(order),
      ),
    );
  }
  if (order.vat != null) {
    _totalRow(
      b,
      'VAT: (${order.vat ?? 0}%)',
      money(ordersProvider.getVATForOrder(order)),
    );
  }
  if (order.getCalculatedRemainingBalance() > 0) {
    _totalRow(
      b,
      'Balance:',
      money(order.getCalculatedRemainingBalance()),
    );
  }
  _totalRow(
    b,
    'Paid:',
    money(ordersProvider.getAmountPaid(order: order)),
  );
  _totalRow(
    b,
    'Status:',
    status == 0
        ? 'Unpaid'
        : status == 1
        ? 'Partial'
        : 'Paid',
  );
  _totalRow(
    b,
    'Total:',
    money(
      ordersProvider.getTotalMainRevenueOrder(order: order),
    ),
    emphasize: true,
  );

  _footer(b, shop, ticketId);
  return b;
}

// Logo, shop details and the document title between dividers.
void _shopHeader(
  EscPosBuilder b,
  TempShopClass shop,
  String title, {
  required bool printLogo,
}) {
  if (printLogo) {
    final logo = _logoBands(b.paperDots);
    if (logo != null) b.raster(logo);
  }
  b.text(
    '#Shop Id: ${shopRef()}',
    align: EscAlign.center,
    bold: true,
  );
  if (shop.showShopName!) {
    // Double width only when the name still fits on one line.
    b.text(
      shop.name,
      align: EscAlign.center,
      bold: true,
      doubleHeight: true,
      doubleWidth:
          escPosSafe(shop.name).length <=
          b.charsPerLine(doubleWidth: true),
    );
  }
  if (shop.showEmail! && shop.email != null) {
    b.text(shop.email ?? '', align: EscAlign.center);
  }
  if (shop.showPhone! &&
      (shop.phoneNumber ?? '').isNotEmpty) {
    b.text(shop.phoneNumber ?? '', align: EscAlign.center);
  }
  if (shop.showAddress! &&
      (shop.shopAddress ?? '').isNotEmpty) {
    b.text(shop.shopAddress ?? '', align: EscAlign.center);
  }
  if (shop.showFacebookTop! &&
      shop.faceBookHandle != null) {
    b.centeredLabel('Facebook:', shop.faceBookHandle ?? '');
  }
  if (shop.showInstaTop! && shop.instaHandle != null) {
    b.centeredLabel('Instagram:', shop.instaHandle ?? '');
  }
  b.divider();
  b.text(title, align: EscAlign.center);
  b.divider();
}

// Labels on one line, bold values below, side by side.
void _infoRow(
  EscPosBuilder b,
  List<(String, String)> cells,
) {
  b.columns([for (final cell in cells) EscCol(cell.$1)]);
  b.columns([
    for (final cell in cells) EscCol(cell.$2, bold: true),
  ]);
}

void _itemRow(
  EscPosBuilder b,
  String name,
  String quantity,
  String price,
) {
  b.columns([
    EscCol(name, flex: _itemFlex[0]),
    EscCol(quantity, flex: _itemFlex[1]),
    EscCol(price, flex: _itemFlex[2]),
  ]);
}

// Label and amount in flex 9 / 7, as in the PDF totals.
void _totalRow(
  EscPosBuilder b,
  String label,
  String value, {
  bool emphasize = false,
}) {
  b.columns([
    EscCol(label, flex: 9),
    EscCol(value, flex: 7, bold: emphasize),
  ], doubleHeight: emphasize);
}

void _footer(
  EscPosBuilder b,
  TempShopClass shop,
  String ticketId,
) {
  b.divider();
  b.ean13(ticketId);
  b.divider();
  b.text(
    shop.bottomText?.toUpperCase() ??
        'Thank you for shopping with us'.toUpperCase(),
    align: EscAlign.center,
    bold: true,
  );
  b.feed(DeviceService.isPos ? 5 : 4);
}

Uint8List? _logoSource;
int? _logoPaperDots;
List<Uint8List>? _logoCache;

// The shop logo as raster bands, sized like the PDF logo box (200pt
// wide, 25pt tall for wide logos and 75pt otherwise). Decoded once and
// reused until the logo or the paper width changes.
List<Uint8List>? _logoBands(int paperDots) {
  final source = returnShopProvider().selectedLogo;
  if (source == null) return null;
  if (identical(source, _logoSource) &&
      paperDots == _logoPaperDots) {
    return _logoCache;
  }
  _logoSource = source;
  _logoPaperDots = paperDots;
  _logoCache = null;

  img.Image? decoded;
  try {
    decoded = img.decodeImage(source);
  } catch (_) {
    decoded = null;
  }
  if (decoded == null) return null;

  final boxWidth = min(
    paperDots,
    (200 * _pointsToDots).round(),
  );
  final boxHeight =
      ((decoded.width > 2 * decoded.height ? 25 : 75) *
              _pointsToDots)
          .round();
  final scale = min(
    boxWidth / decoded.width,
    boxHeight / decoded.height,
  );
  final logo = img.copyResize(
    decoded,
    width: max(1, (decoded.width * scale).round()),
    height: max(1, (decoded.height * scale).round()),
    interpolation: img.Interpolation.average,
  );

  // Pad with white on the left to centre it; not every printer applies
  // ESC a alignment to raster images.
  final left = (paperDots - logo.width) ~/ 2;
  final canvas = img.Image(
    width: left + logo.width,
    height: logo.height,
    numChannels: 4,
  );
  img.fill(
    canvas,
    color: img.ColorRgba8(255, 255, 255, 255),
  );
  img.compositeImage(canvas, logo, dstX: left);

  _logoCache = rasterImageBands(canvas);
  return _logoCache;
}
