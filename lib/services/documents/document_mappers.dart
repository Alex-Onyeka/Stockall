import 'dart:math' as math;
import 'dart:typed_data';

import 'package:stockall/classes/temp_invoices/temp_invoices.dart';
import 'package:stockall/classes/temp_item_purchase_record/temp_item_purchase_record.dart';
import 'package:stockall/classes/temp_main_receipt/temp_main_receipt.dart';
import 'package:stockall/classes/temp_orders/order_items.dart';
import 'package:stockall/classes/temp_orders/orders.dart';
import 'package:stockall/classes/temp_product_class/units_class/product_units_class.dart';
import 'package:stockall/classes/temp_product_slaes_record/temp_product_sale_record.dart';
import 'package:stockall/classes/temp_purchase/temp_purchase.dart';
import 'package:stockall/classes/temp_shop/temp_shop_class.dart';
import 'package:stockall/constants/calculations.dart'
    show formatDimensionsLabel;
import 'package:stockall/constants/generate_barcode.dart'
    show returnOnlyDigits;
import 'package:stockall/services/documents/document_model.dart';
import 'package:stockall/services/documents/document_sections.dart';

// Pure mapping from saved records to SalesDocument. Everything a
// document needs is passed in (linked receipts, payments, logo): these
// functions read no provider, so they can be tested on their own.
//
// Kept the same as the current prints:
// - quantities: the unit sold and its name; sized items in their area
//   with wastage (receipts, invoices), orders in the unit ordered;
// - a line's own discount only counts when the document has no
//   discount of its own (as the cart applies it);
// - totals are the saved totals.
// Changed on purpose:
// - "per 1" is the line value / its price quantity, also for lines
//   with their own discount (it showed the line total);
// - VAT is worked out as the cart charged it (cartVat): rate x
//   (subtotal - the lines' own discounts). The invoice print treated a
//   percentage discount as money; the receipt and order prints ignored
//   the lines' own discounts.

const String receiptDocumentTitle = 'SALES RECEIPT';
const String invoiceDocumentTitle = 'INVOICE';
const String orderDocumentTitle = 'SALES ORDER';
const String purchaseDocumentTitle = 'PURCHASE RECORD';

const double _cent = 0.005;

// Shop identity for the page header. Contact lines follow the shop's
// receipt settings (the same switches the current receipt uses).
DocShop docShopFrom(
  TempShopClass shop, {
  Uint8List? logo,
  bool logoIsWide = false,
  String? reference,
}) {
  bool shows(bool? flag, bool fallback) => flag ?? fallback;
  final lines = <String>[
    if (shows(shop.showAddress, false) && _hasText(shop.shopAddress))
      shop.shopAddress!.trim(),
    if (shows(shop.showPhone, false) && _hasText(shop.phoneNumber))
      shop.phoneNumber!.trim(),
    if (shows(shop.showEmail, true) && _hasText(shop.email))
      shop.email!.trim(),
    if (shows(shop.showFacebookTop, false) &&
        _hasText(shop.faceBookHandle))
      'Facebook: ${shop.faceBookHandle!.trim()}',
    if (shows(shop.showInstaTop, false) && _hasText(shop.instaHandle))
      'Instagram: ${shop.instaHandle!.trim()}',
  ];
  return DocShop(
    name: shop.name.trim(),
    showName: shows(shop.showShopName, true),
    logo: (logo == null || logo.isEmpty) ? null : logo,
    logoIsWide: logoIsWide,
    contactLines: lines,
    reference: _hasText(reference) ? 'Shop ID: ${reference!.trim()}' : null,
  );
}

// A sale, a payment on an invoice (salesTypeIndex 2) or a delivery on
// an order (3). Payment and delivery receipts keep the invoice's or
// order's subtotal, discount and VAT but their total is only what was
// paid on them, so their page shows the lines on the receipt, the
// amount paid and what is left on the invoice or order instead.
// parentNumber: the invoice's or order's number, when it has a saved
// barcode; otherwise it comes from its uuid, as on its own document.
SalesDocument receiptDocument({
  required TempMainReceipt receipt,
  required List<TempProductSaleRecord> records,
  required String staffName,
  required DocShop shop,
  required DocFormat fmt,
  String? footerText,
  String? parentNumber,
}) {
  final kind = receiptKindOf(receipt);
  if (kind != DocReceiptKind.sale) {
    return _paymentReceiptDocument(
      receipt: receipt,
      kind: kind,
      records: records,
      staffName: staffName,
      shop: shop,
      fmt: fmt,
      footerText: footerText,
      parentNumber: parentNumber,
    );
  }
  final documentDiscount =
      receipt.fixedDiscount != null || receipt.generalDiscount != null;
  final lines = [
    for (final record in records)
      saleDocLine(record, documentDiscount: documentDiscount),
  ];
  final subtotal = receipt.originalCost ?? _sumAmounts(lines);
  final discount = _discount(
    fmt: fmt,
    fixed: receipt.fixedDiscount,
    rate: receipt.generalDiscount,
    subtotal: subtotal,
  );
  final number = _documentNumber(receipt.barcode, receipt.uuid);

  final info = <DocField>[];
  _add(info, 'Receipt No', number);
  _add(info, 'Date', fmt.dateTime(receipt.createdAt));
  _add(info, 'Staff', staffName);
  _add(info, 'Customer', receipt.customerName);
  _add(info, 'Waiter', receipt.subStaffName);
  _add(info, 'Cart', receipt.cartName);
  _add(info, 'Department', receipt.departmentName);

  return SalesDocument(
    type: DocType.receipt,
    title: receiptDocumentTitle,
    number: number,
    date: receipt.createdAt,
    shop: shop,
    info: info,
    lines: lines,
    totals: DocTotals(
      subtotal: subtotal,
      itemDiscounts: _itemDiscounts(lines),
      discount: discount.$1,
      discountLabel: discount.$2,
      vatRate: receipt.vat,
      vat: cartVat(
        subtotal: subtotal,
        lineDiscounts: records.map((r) => r.discountedAmount),
        rate: receipt.vat,
      ),
      total: receipt.getTotalRevenue(),
      receiptBalance: receipt.balance,
    ),
    payments: [
      for (final payment in receipt.displayPayments())
        DocPayment(method: payment.method, amount: payment.amount),
    ],
    notes: _text(receipt.comment),
    barcode: _barcode(number),
    footerText: _text(footerText),
  );
}

DocReceiptKind receiptKindOf(TempMainReceipt receipt) {
  switch (receipt.getSalesTypeIndex()) {
    case 2 when receipt.invoiceUuid != null:
      return DocReceiptKind.invoicePayment;
    case 3 when receipt.orderUuid != null:
      return DocReceiptKind.orderDelivery;
    default:
      return DocReceiptKind.sale;
  }
}

SalesDocument _paymentReceiptDocument({
  required TempMainReceipt receipt,
  required DocReceiptKind kind,
  required List<TempProductSaleRecord> records,
  required String staffName,
  required DocShop shop,
  required DocFormat fmt,
  required String? footerText,
  required String? parentNumber,
}) {
  final isPayment = kind == DocReceiptKind.invoicePayment;
  final parent =
      parentNumber ??
      _documentNumber(
        null,
        isPayment ? receipt.invoiceUuid : receipt.orderUuid,
      );
  final number = _documentNumber(receipt.barcode, receipt.uuid);
  final paid = receipt.getTotalRevenue();

  final info = <DocField>[];
  _add(info, 'Receipt No', number);
  _add(info, 'Date', fmt.dateTime(receipt.createdAt));
  _add(info, 'Staff', staffName);
  _add(info, isPayment ? 'Invoice No' : 'Order No', parent);
  _add(info, 'Customer', receipt.customerName);
  _add(info, 'Waiter', receipt.subStaffName);
  _add(info, 'Cart', receipt.cartName);
  _add(info, 'Department', receipt.departmentName);

  return SalesDocument(
    type: DocType.receipt,
    receiptKind: kind,
    title: receiptDocumentTitle,
    titleLine:
        isPayment ? 'Payment for Invoice #$parent' : 'Delivery for Order #$parent',
    number: number,
    date: receipt.createdAt,
    shop: shop,
    info: info,
    lines: [
      for (final record in records)
        saleDocLine(
          record,
          documentDiscount:
              receipt.fixedDiscount != null ||
              receipt.generalDiscount != null,
        ),
    ],
    // Only the payment: it is the saved total, with nothing to add up.
    totals: DocTotals(
      subtotal: paid,
      itemDiscounts: 0,
      discount: 0,
      discountLabel: 'Discount',
      vatRate: null,
      vat: 0,
      total: paid,
      receiptBalance: receipt.balance,
    ),
    payments: [
      for (final payment in receipt.displayPayments())
        DocPayment(method: payment.method, amount: payment.amount),
    ],
    notes: _text(receipt.comment),
    barcode: _barcode(number),
    footerText: _text(footerText),
  );
}

// receipts: the payments made against the invoice (receipts whose
// invoiceUuid is the invoice's). Others in the list are ignored.
SalesDocument invoiceDocument({
  required TempInvoice invoice,
  required List<TempProductSaleRecord> records,
  required List<TempMainReceipt> receipts,
  required DocShop shop,
  required DocFormat fmt,
  String? staffName,
  String? footerText,
}) {
  final documentDiscount =
      invoice.fixedDiscount != null || invoice.generalDiscount != null;
  final lines = [
    for (final record in records)
      saleDocLine(record, documentDiscount: documentDiscount),
  ];
  final subtotal = invoice.originalCost ?? _sumAmounts(lines);
  final discount = _discount(
    fmt: fmt,
    fixed: invoice.fixedDiscount,
    rate: invoice.generalDiscount,
    subtotal: subtotal,
  );
  final total = invoice.getTotalMainRevenueInvoice();
  final linked = _linkedReceipts(
    receipts,
    (receipt) => receipt.invoiceUuid,
    invoice.uuid,
  );
  final paid = _sum(linked.map((receipt) => receipt.getTotalRevenue()));
  final status = docPaymentStatus(total: total, paid: paid);
  final number = _documentNumber(invoice.barcode, invoice.uuid);

  final info = <DocField>[];
  _add(info, 'Invoice No', number);
  _add(info, 'Date', fmt.dateTime(invoice.createdAt));
  _add(info, 'Staff', staffName ?? invoice.staffName);
  _add(info, 'Customer', invoice.customerName);
  _add(info, 'Waiter', invoice.subStaffName);
  _add(info, 'Cart', invoice.cartName);
  _add(info, 'Department', invoice.departmentName);
  _add(info, 'Status', status.label);

  return SalesDocument(
    type: DocType.invoice,
    title: invoiceDocumentTitle,
    number: number,
    date: invoice.createdAt,
    shop: shop,
    info: info,
    status: status,
    lines: lines,
    totals: DocTotals(
      subtotal: subtotal,
      itemDiscounts: _itemDiscounts(lines),
      discount: discount.$1,
      discountLabel: discount.$2,
      vatRate: invoice.vat,
      vat: cartVat(
        subtotal: subtotal,
        lineDiscounts: records.map((r) => r.discountedAmount),
        rate: invoice.vat,
      ),
      total: total,
      paid: paid,
      balance: math.max(0.0, total - paid),
    ),
    payments: _receiptPayments(linked),
    notes: _text(invoice.comment),
    barcode: _barcode(number),
    footerText: _text(footerText),
  );
}

// receipts: the order's delivery/payment receipts (orderUuid is the
// order's). Others in the list are ignored. items defaults to
// order.orderItems.
SalesDocument orderDocument({
  required Orders order,
  required List<TempMainReceipt> receipts,
  required DocShop shop,
  required DocFormat fmt,
  List<OrderItems>? items,
  String? footerText,
}) {
  final documentDiscount =
      order.fixedDiscount != null || order.generalDiscount != null;
  final orderItems = items ?? order.orderItems;
  final lines = [
    for (final item in orderItems)
      orderDocLine(item, fmt: fmt, documentDiscount: documentDiscount),
  ];
  final subtotal = order.originalCost ?? _sumAmounts(lines);
  final discount = _discount(
    fmt: fmt,
    fixed: order.fixedDiscount,
    rate: order.generalDiscount,
    subtotal: subtotal,
  );
  final total = order.total ?? 0;
  final linked = _linkedReceipts(
    receipts,
    (receipt) => receipt.orderUuid,
    order.uuid,
  );
  final paid = _sum(linked.map((receipt) => receipt.getTotalRevenue()));
  final status = docPaymentStatus(total: total, paid: paid);
  final number = _documentNumber(order.barcode, order.uuid);

  final info = <DocField>[];
  _add(info, 'Order No', number);
  _add(info, 'Date', fmt.dateTime(order.createdAt));
  _add(info, 'Staff', order.staffName);
  _add(info, 'Customer', order.customerName);
  _add(info, 'Waiter', order.subStaffName);
  _add(info, 'Cart', order.cartName);
  _add(info, 'Department', order.departmentName);
  _add(info, 'Payment', status.label);
  _add(info, 'Delivery', orderDeliveryLabel(lines));

  return SalesDocument(
    type: DocType.order,
    title: orderDocumentTitle,
    number: number,
    date: order.createdAt,
    shop: shop,
    info: info,
    status: status,
    lines: lines,
    totals: DocTotals(
      subtotal: subtotal,
      itemDiscounts: _itemDiscounts(lines),
      discount: discount.$1,
      discountLabel: discount.$2,
      vatRate: order.vat,
      vat: cartVat(
        subtotal: subtotal,
        lineDiscounts: orderItems.map((i) => i.discountedAmount),
        rate: order.vat,
      ),
      total: total,
      paid: paid,
      balance: math.max(0.0, total - paid),
    ),
    payments: _receiptPayments(linked),
    notes: _text(order.comment),
    barcode: _barcode(number),
    footerText: _text(footerText),
  );
}

SalesDocument purchaseDocument({
  required TempPurchase purchase,
  required List<TempItemPurchaseRecord> items,
  required DocShop shop,
  required DocFormat fmt,
  String? footerText,
}) {
  final lines = [
    for (final item in items) purchaseDocLine(item),
  ];
  final subtotal = _sumAmounts(lines);
  final total = purchase.total ?? subtotal;
  final adjustment = total - subtotal;
  final payments = [...purchase.purchasePayments]
    ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  final paid = _sum(payments.map((payment) => payment.amount));
  final status = docPaymentStatus(total: total, paid: paid);
  final number = _documentNumber(null, purchase.uuid);

  final info = <DocField>[];
  _add(info, 'Purchase No', number);
  _add(info, 'Date', fmt.dateTime(purchase.createdAt));
  _add(info, 'Staff', purchase.staffName);
  _add(info, 'Supplier', purchase.supplierName);
  _add(info, 'Department', purchase.departmentName);
  _add(info, 'Status', status.label);

  return SalesDocument(
    type: DocType.purchase,
    title: purchaseDocumentTitle,
    number: number,
    date: purchase.createdAt,
    shop: shop,
    info: info,
    status: status,
    lines: lines,
    totals: DocTotals(
      subtotal: subtotal,
      itemDiscounts: 0,
      discount: 0,
      discountLabel: 'Discount',
      vatRate: null,
      vat: 0,
      adjustment: adjustment.abs() < _cent ? null : adjustment,
      total: total,
      paid: paid,
      balance: math.max(0.0, total - paid),
    ),
    payments: [
      for (final payment in payments)
        DocPayment(
          method: payment.paymentMethod,
          amount: payment.amount,
          date: payment.createdAt,
          staff: _text(payment.staffName),
        ),
    ],
    barcode: _barcode(number),
    footerText: _text(footerText),
  );
}

// One receipt or invoice line.
DocLine saleDocLine(
  TempProductSaleRecord record, {
  required bool documentDiscount,
}) {
  final sized = record.quantityType == 2;
  // Lines saved without a units list: the saved quantity and unit, as
  // the unit helpers would need the signed-in user to build one.
  final hasUnits = (record.unitsList ?? const []).isNotEmpty;
  final useUnits = hasUnits || sized;

  final quantity = useUnits ? record.displayQuantity() : record.quantity;
  final unit = docUnitName(
    useUnits ? record.displayUnitName() : record.unit,
  );
  final priceQuantity = useUnits ? record.priceQuantity() : record.quantity;
  final amount = record.originalCost ?? 0;
  final discount = _ownDiscount(
    documentDiscount: documentDiscount,
    discounted: record.discountedAmount,
  );

  final notes = <String>[];
  final wastage = record.wastageNote();
  if (wastage.isNotEmpty) notes.add(wastage);
  if (hasUnits && !sized) {
    final note = _equivalentNote(
      selected: record.getSelectedUnit(),
      primary: record.getPrimaryUnit(),
      baseQuantity: record.getActualQuantity(),
    );
    if (note != null) notes.add(note);
  }

  return DocLine(
    name: '${record.productName.trim()}${record.dimensionsLabel()}',
    quantity: quantity,
    unit: unit,
    unitPrice: priceQuantity > 0 ? amount / priceQuantity : null,
    amount: amount,
    discount: discount,
    discountRate: _discountRate(
      discount: discount,
      amount: amount,
      rate: record.fixedDiscount == null ? record.discount : null,
    ),
    notes: notes,
  );
}

// One order line, in the unit it was ordered in, with what has been
// delivered and what is still outstanding.
DocLine orderDocLine(
  OrderItems item, {
  required DocFormat fmt,
  required bool documentDiscount,
}) {
  final hasUnits = (item.unitsList ?? const []).isNotEmpty;
  final sized = item.quantityType == 2;
  final quantity = item.quantity;
  final unit = docUnitName(
    hasUnits ? item.getSelectedUnit().name : item.unit,
  );

  // originalCost is saved per base unit.
  double amount;
  try {
    amount =
        hasUnits
            ? item.getTotalOriginalSellingPrice()
            : (item.originalCost ?? 0) * quantity;
  } on StateError {
    amount = (item.originalCost ?? 0) * quantity;
  }
  final discount = _ownDiscount(
    documentDiscount: documentDiscount,
    discounted: item.discountedAmount,
  );

  final outstanding = (item.remainingQuantity ?? quantity)
      .clamp(0.0, math.max(0.0, quantity))
      .toDouble();
  final delivered = math.max(0.0, quantity - outstanding);

  final notes = <String>[];
  if (hasUnits && sized) {
    final wastage = item.wastageNote();
    if (item.hasCustomDimensions) {
      notes.add(
        '= ${fmt.quantity(item.displayQuantity(), docUnitName(item.displayUnitName()))}',
      );
    }
    if (wastage.isNotEmpty) notes.add(wastage);
  }
  if (hasUnits && !sized) {
    try {
      final note = _equivalentNote(
        selected: item.getSelectedUnit(),
        primary: item.getPrimaryUnit(),
        baseQuantity: item.getActualQuantity(),
      );
      if (note != null) notes.add(note);
    } on StateError {
      // A unit without a usable conversion: no equivalent to show.
    }
  }

  return DocLine(
    name: '${item.productName.trim()}${item.dimensionsLabel()}',
    quantity: quantity,
    unit: unit,
    unitPrice: quantity > 0 ? amount / quantity : null,
    amount: amount,
    discount: discount,
    discountRate: _discountRate(
      discount: discount,
      amount: amount,
      rate: item.fixedDiscount == null ? item.discount : null,
    ),
    notes: notes,
    delivered: delivered,
    outstanding: outstanding,
  );
}

// One purchase line: quantity in the unit bought, its total and the
// cost of one unit.
DocLine purchaseDocLine(TempItemPurchaseRecord item) {
  final hasUnits = (item.unitsList ?? const []).isNotEmpty;
  final quantity = item.quantity ?? 0;
  final amount = item.total ?? 0;
  final notes = <String>[];
  String unit = docUnitName(item.unit);
  if (hasUnits) {
    final selected = item.getSelectedUnit();
    unit = docUnitName(selected.name);
    final note = _equivalentNote(
      selected: selected,
      primary: item.getPrimaryUnit(),
      baseQuantity: quantity * selected.conversion,
    );
    if (note != null) notes.add(note);
  }
  final name = (item.itemName ?? '').trim();
  return DocLine(
    name:
        '${name.isEmpty ? 'Item' : name}'
        '${formatDimensionsLabel(item.widthDimension, item.heightDimension)}',
    quantity: quantity,
    unit: unit,
    unitPrice: quantity > 0 ? amount / quantity : null,
    amount: amount,
    notes: notes,
  );
}

// VAT as the cart charged it (SalesProvider.calcVatAmount): rate x
// (each line's value - its own discount), summed. That is rate x
// (subtotal - the lines' own discounts). The lines' own discounts are
// taken off even when a document discount replaced them on the total,
// as the cart does.
double cartVat({
  required double subtotal,
  required Iterable<double?> lineDiscounts,
  required double? rate,
}) {
  if (rate == null) return 0;
  final own = _sum(lineDiscounts.map((d) => d ?? 0));
  return (subtotal - own) * rate / 100;
}

DocPaymentStatus docPaymentStatus({
  required double total,
  required double paid,
}) {
  if (total - paid < _cent) return DocPaymentStatus.paid;
  if (paid < _cent) return DocPaymentStatus.unpaid;
  return DocPaymentStatus.partPaid;
}

String orderDeliveryLabel(List<DocLine> lines) {
  final ordered = lines.where((line) => line.quantity > 0);
  if (ordered.isEmpty) return 'Nothing to deliver';
  if (ordered.every((line) => (line.outstanding ?? 0) < 0.0005)) {
    return 'Delivered';
  }
  if (ordered.every((line) => (line.delivered ?? 0) < 0.0005)) {
    return 'Not delivered';
  }
  return 'Partly delivered';
}

String docUnitName(String? name) {
  final trimmed = name?.trim() ?? '';
  if (trimmed.isEmpty || trimmed == 'Others') return 'Unit(s)';
  return trimmed;
}

// "= 24 Each" when the line was sold in a unit other than the primary.
String? _equivalentNote({
  required ProductUnitsClass selected,
  required ProductUnitsClass primary,
  required double baseQuantity,
}) {
  if (selected.uuid == primary.uuid) return null;
  if ((selected.conversion - primary.conversion).abs() < 1e-9) return null;
  if (!(primary.conversion > 0) || !baseQuantity.isFinite) return null;
  return '= ${docNumber(baseQuantity / primary.conversion)} '
      '${docUnitName(primary.name)}';
}

double _ownDiscount({
  required bool documentDiscount,
  required double? discounted,
}) {
  if (documentDiscount) return 0;
  final value = discounted ?? 0;
  return value > 0.0005 ? value : 0;
}

// The rate, only when the discount is that percentage of the line.
double? _discountRate({
  required double discount,
  required double amount,
  required double? rate,
}) {
  if (discount <= 0 || rate == null || rate <= 0) return null;
  return (discount - amount * rate / 100).abs() < 0.01 ? rate : null;
}

// The document's own discount, as SalesProvider.calcDiscountMain.
(double, String) _discount({
  required DocFormat fmt,
  required double? fixed,
  required double? rate,
  required double subtotal,
}) {
  if (fixed != null) return (fixed, 'Discount');
  if (rate != null) {
    return (subtotal * rate / 100, 'Discount (${fmt.rate(rate)})');
  }
  return (0, 'Discount');
}

// The lines' own discounts that count on this document (none when the
// document has a discount of its own).
double _itemDiscounts(List<DocLine> lines) =>
    _sum(lines.map((line) => line.discount));

List<TempMainReceipt> _linkedReceipts(
  List<TempMainReceipt> receipts,
  String? Function(TempMainReceipt receipt) link,
  String? uuid,
) {
  final linked =
      uuid == null
          ? [...receipts]
          : receipts.where((receipt) => link(receipt) == uuid).toList();
  linked.sort((a, b) => a.createdAt.compareTo(b.createdAt));
  return linked;
}

// One row per channel paid on each receipt.
List<DocPayment> _receiptPayments(List<TempMainReceipt> receipts) {
  return [
    for (final receipt in receipts)
      for (final payment in receipt.payments())
        if (payment.amount > 0.0005)
          DocPayment(
            method: payment.method,
            amount: payment.amount,
            date: receipt.createdAt,
            staff: _text(receipt.staffName),
          ),
  ];
}

// The ticket number the current prints use: the saved barcode, else
// digits from the uuid.
String _documentNumber(String? barcode, String? uuid) {
  if (_hasText(barcode)) return barcode!.trim();
  try {
    return returnOnlyDigits(uuid ?? '');
  } on ArgumentError {
    final id = uuid ?? '';
    return id.length > 8 ? id.substring(0, 8).toUpperCase() : id;
  }
}

String? _barcode(String number) =>
    RegExp(r'^\d{12,13}$').hasMatch(number) ? number : null;

void _add(List<DocField> info, String label, String? value) {
  final text = _text(value);
  if (text != null) info.add(DocField(label, text));
}

String? _text(String? value) {
  final trimmed = value?.trim();
  return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
}

bool _hasText(String? value) => _text(value) != null;

double _sum(Iterable<double> values) =>
    values.fold<double>(0, (a, b) => a + b);

double _sumAmounts(List<DocLine> lines) =>
    _sum(lines.map((line) => line.amount));
