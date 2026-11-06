import 'package:intl/intl.dart';
import 'package:stockall/services/documents/document_sections.dart';

// A sales document (receipt, invoice, order or purchase) as plain data:
// the values the A4 page shows, already worked out from the saved
// records. Amounts stay numbers here; DocFormat turns them into text.

enum DocType { receipt, invoice, order, purchase }

enum DocPaymentStatus { unpaid, partPaid, paid }

extension DocPaymentStatusLabel on DocPaymentStatus {
  String get label {
    switch (this) {
      case DocPaymentStatus.unpaid:
        return 'Unpaid';
      case DocPaymentStatus.partPaid:
        return 'Part-paid';
      case DocPaymentStatus.paid:
        return 'Paid';
    }
  }
}

class DocLine {
  // Item name with its size, e.g. "Glass (2m x 3m)".
  final String name;
  final double quantity;
  final String unit;

  // Price of one unit before the line's own discount. Null when the
  // quantity is zero.
  final double? unitPrice;

  // Line value before the line's own discount.
  final double amount;

  // The line's own discount, when it was applied to this document.
  final double discount;
  final double? discountRate;

  // Wastage, unit equivalents and similar, printed under the name.
  final List<String> notes;

  // Orders only, in the line's unit.
  final double? delivered;
  final double? outstanding;

  const DocLine({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
    required this.amount,
    this.discount = 0,
    this.discountRate,
    this.notes = const [],
    this.delivered,
    this.outstanding,
  });
}

class DocPayment {
  final String method;
  final double amount;
  final DateTime? date;
  final String? staff;

  const DocPayment({
    required this.method,
    required this.amount,
    this.date,
    this.staff,
  });
}

// Subtotal - itemDiscounts - discount + vat (+ adjustment) is the saved
// total, as the cart works it out.
class DocTotals {
  final double subtotal;

  // The lines' own discounts, when the document has no discount.
  final double itemDiscounts;

  // The document's discount (fixed, or a percentage of the subtotal).
  // The cart applies it instead of the lines' own discounts.
  final double discount;
  final String discountLabel;

  final double? vatRate;
  final double vat;

  // Purchases: difference between the saved total and the lines.
  final double? adjustment;

  final double total;

  // Invoices, orders and purchases.
  final double? paid;
  final double? balance;

  // The receipt's own saved balance field, printed as before.
  final double? receiptBalance;

  const DocTotals({
    required this.subtotal,
    required this.itemDiscounts,
    required this.discount,
    required this.discountLabel,
    required this.vatRate,
    required this.vat,
    required this.total,
    this.adjustment,
    this.paid,
    this.balance,
    this.receiptBalance,
  });
}

// What a receipt is for: a sale, a payment on an invoice, or a delivery
// on an order (TempMainReceipt.salesTypeIndex 1, 2 and 3).
enum DocReceiptKind { sale, invoicePayment, orderDelivery }

class SalesDocument {
  final DocType type;
  final String title;

  // A line under the title, e.g. "Payment for Invoice #2111222233331".
  final String? titleLine;

  // Receipts only.
  final DocReceiptKind receiptKind;
  final String number;
  final DateTime date;
  final DocShop shop;
  final List<DocField> info;
  final DocPaymentStatus? status;
  final List<DocLine> lines;
  final DocTotals totals;
  final List<DocPayment> payments;
  final String? notes;
  final String? barcode;
  final String? footerText;

  const SalesDocument({
    required this.type,
    required this.title,
    required this.number,
    required this.date,
    required this.shop,
    required this.info,
    required this.lines,
    required this.totals,
    this.titleLine,
    this.receiptKind = DocReceiptKind.sale,
    this.status,
    this.payments = const [],
    this.notes,
    this.barcode,
    this.footerText,
  });

  String? infoValue(String label) {
    for (final field in info) {
      if (field.label == label) return field.value;
    }
    return null;
  }
}

// Text for amounts, quantities, rates and dates on a document.
class DocFormat {
  final String currency;

  DocFormat({required String currency})
    : currency = pdfCurrencySymbol(currency);

  static final NumberFormat _money = NumberFormat('#,##0.00');
  static final DateFormat _dateTime = DateFormat(
    'd MMM yyyy, hh:mm a',
  );
  static final DateFormat _date = DateFormat('d MMM yyyy');

  String money(double value) {
    final rounded = value.abs() < 0.005 ? 0.0 : value;
    final text = '$currency${_money.format(rounded.abs())}';
    return rounded < 0 ? '-$text' : text;
  }

  // A discount or other amount taken off, e.g. "-₦500.00".
  String minus(double value) => money(-value.abs());

  String number(double value) => docNumber(value);

  String quantity(double value, String unit) =>
      '${number(value)} $unit';

  String rate(double value) => '${number(value)}%';

  String dateTime(DateTime value) => _dateTime.format(value);

  String date(DateTime value) => _date.format(value);
}

final NumberFormat _docNumber = NumberFormat('#,##0.###');

// Quantities and rates: up to 3 decimals, no trailing zeros (2, 2.5).
String docNumber(double value) =>
    _docNumber.format(value.abs() < 0.0005 ? 0 : value);

// The currency symbol as the PDF can draw it. The bundled font has no
// Arabic glyphs, so the dirham sign is written AED. Letter codes
// (KSh, FCFA, AED) get a space before the amount.
String pdfCurrencySymbol(String symbol) {
  final trimmed = symbol.trim();
  if (trimmed == 'د.إ') return 'AED ';
  if (trimmed.length > 1 &&
      RegExp(r'[A-Za-z]$').hasMatch(trimmed)) {
    return '$trimmed ';
  }
  return trimmed;
}
