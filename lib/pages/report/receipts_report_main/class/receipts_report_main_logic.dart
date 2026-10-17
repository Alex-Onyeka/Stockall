import 'package:flutter/material.dart';
import 'package:stockall/classes/payment_entry/payment_entry.dart';
import 'package:stockall/classes/temp_main_receipt/temp_main_receipt.dart';
import 'package:stockall/classes/temp_product_class/units_class/product_units_class.dart';
import 'package:stockall/classes/temp_product_slaes_record/temp_product_sale_record.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/generate_barcode.dart';

/// Page size, same as the Items Report table.
const int receiptsReportPageSize = 100;

/// Filter key for the "unassigned" bucket (no customer, no
/// department, no staff, no sub-staff).
const String receiptsReportNoneKey = '__none__';

enum ReceiptType {
  sales,
  invoicePayment,
  orderDelivery,
  unknown,
}

extension ReceiptTypeLabel on ReceiptType {
  String get label {
    switch (this) {
      case ReceiptType.sales:
        return 'Sales';
      case ReceiptType.invoicePayment:
        return 'Invoice Payment';
      case ReceiptType.orderDelivery:
        return 'Order Delivery';
      case ReceiptType.unknown:
        return 'Unknown';
    }
  }
}

enum ReceiptChannel { cash, bank, customerAccount, split }

extension ReceiptChannelLabel on ReceiptChannel {
  String get label {
    switch (this) {
      case ReceiptChannel.cash:
        return 'Cash';
      case ReceiptChannel.bank:
        return 'Bank';
      case ReceiptChannel.customerAccount:
        return 'Customer Account';
      case ReceiptChannel.split:
        return 'Split';
    }
  }
}

/// Where a receipt's sale lines came from.
enum ReceiptLineSource {
  /// `receipt.items`.
  embedded,

  /// product_sales rows matched by receipt uuid (receipts saved
  /// by app versions that did not write `items`).
  legacy,

  /// No line data: line-based values are unknown, not zero.
  none,
}

enum ReceiptsSortField {
  createdAt,
  customer,
  staff,
  revenue,
  balance,
  profit,
  margin,
  items,
}

/// Type and channel rules, shared by the columns and the filters
/// so a receipt is never classified twice.
class ReceiptsReportClassifier {
  /// `salesTypeIndex` was added after invoice payments existed, so
  /// a null index with an invoice is an Invoice Payment. Order
  /// deliveries were added together with the index.
  static ReceiptType type(TempMainReceipt receipt) {
    switch (receipt.salesTypeIndex) {
      case 1:
        return ReceiptType.sales;
      case 2:
        return ReceiptType.invoicePayment;
      case 3:
        return ReceiptType.orderDelivery;
      case null:
        return receipt.invoiceUuid != null
            ? ReceiptType.invoicePayment
            : ReceiptType.sales;
      default:
        return ReceiptType.unknown;
    }
  }

  /// From the amounts paid, as `PaymentBreakdown.label` does at
  /// checkout. A zero-total receipt falls back to its saved method,
  /// as `TempMainReceipt.displayPayments` does.
  static ReceiptChannel channel(TempMainReceipt receipt) {
    final used = receipt.paymentBreakdown().methodsUsed;
    if (used.length > 1) return ReceiptChannel.split;
    final method =
        used.isNotEmpty
            ? used.first
            : receipt.paymentMethod;
    switch (method) {
      case PaymentMethods.bank:
        return ReceiptChannel.bank;
      case PaymentMethods.account:
        return ReceiptChannel.customerAccount;
      default:
        return ReceiptChannel.cash;
    }
  }
}

/// One table row. Every value is calculated once, when the row is
/// built. `null` means unknown or not applicable (shown as "—").
class ReceiptsReportRow {
  final TempMainReceipt receipt;
  final String displayId;
  final ReceiptType type;
  final ReceiptChannel channel;

  /// `createdAt` in local time.
  final DateTime createdAt;
  final ReceiptLineSource lineSource;

  /// cash + bank + customer account.
  final double revenue;

  /// Remaining invoice / order balance. Sales have none.
  final double? balance;

  /// Null on Invoice Payment / Order Delivery rows: the stored
  /// values belong to the whole invoice / order.
  final double? subtotal;
  final double? discount;
  final double? vat;

  final double? items;

  /// Sum of line (revenue - cost). Null without line data.
  final double? profit;

  /// Sum of line revenue, the margin denominator.
  final double? lineRevenue;

  /// A line had no cost price, so its cost counted as 0.
  final bool costMissing;

  /// profit / lineRevenue * 100. Null when it cannot be calculated.
  final double? margin;

  ReceiptsReportRow({
    required this.receipt,
    required this.displayId,
    required this.type,
    required this.channel,
    required this.createdAt,
    required this.lineSource,
    required this.revenue,
    required this.balance,
    required this.subtotal,
    required this.discount,
    required this.vat,
    required this.items,
    required this.profit,
    required this.lineRevenue,
    required this.costMissing,
    required this.margin,
  });

  String get uuid => receipt.uuid ?? '';

  String? get staffKey => _key(receipt.staffId);
  String? get customerKey => _key(receipt.customerUuid);
  String? get subStaffKey => _key(receipt.subStaffUuid);
  String? get departmentKey =>
      _key(receipt.departmentUuidNew);

  String? get staffName => _name(receipt.staffName);
  String? get customerName => _name(receipt.customerName);
  String? get subStaffName => _name(receipt.subStaffName);
  String? get departmentName =>
      _name(receipt.departmentName);

  String get staffLabel => staffName ?? 'Not Set';
  String get customerLabel => customerName ?? 'Not Set';
  String get subStaffLabel => subStaffName ?? 'Not Set';
  String get departmentLabel =>
      departmentKey == null
          ? 'No Department'
          : departmentName ?? 'No Department';

  /// Null when there is no comment to show.
  String? get comment => _name(receipt.comment);

  /// Subtotal, discount and VAT are hidden on these rows.
  bool get hidesDocumentTotals =>
      type == ReceiptType.invoicePayment ||
      type == ReceiptType.orderDelivery;

  static String? _key(String? value) =>
      (value == null || value.trim().isEmpty)
          ? null
          : value;

  static String? _name(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

/// Builds [ReceiptsReportRow]s. No receipt is modified.
class ReceiptsReportRowBuilder {
  /// product_sales lines grouped by receipt uuid, built once instead
  /// of scanning every line per receipt (`getItems()` fallback).
  static Map<String, List<TempProductSaleRecord>>
  legacyLinesByReceipt(List<TempProductSaleRecord> sales) {
    final map = <String, List<TempProductSaleRecord>>{};
    for (final line in sales) {
      final uuid = line.receiptUuid;
      if (uuid == null || uuid.isEmpty) continue;
      (map[uuid] ??= []).add(line);
    }
    return map;
  }

  /// `#barcode`, or the digits of the uuid, as the printed receipt
  /// and the old receipts table show it.
  /// `returnOnlyDigits` throws for a uuid with under 12 digits;
  /// the uuid itself is shown then, so the row is never dropped.
  static String displayId(TempMainReceipt receipt) {
    final barcode = receipt.barcode;
    if (barcode != null) return '#$barcode';
    final uuid = receipt.uuid ?? '';
    try {
      return '#${returnOnlyDigits(uuid)}';
    } on ArgumentError {
      return '#$uuid';
    }
  }

  /// Same order as checkout's `calcDiscountMain`: fixed amount,
  /// then percentage of the subtotal, then the lines' discounts.
  /// Null when there is no cart discount and no line data.
  static double? discountAmount(
    TempMainReceipt receipt,
    List<TempProductSaleRecord>? lines,
  ) {
    if (receipt.fixedDiscount != null) {
      return receipt.fixedDiscount!;
    }
    if (receipt.generalDiscount != null) {
      return (receipt.originalCost ?? 0) *
          (receipt.generalDiscount! / 100);
    }
    if (lines == null) return null;
    return lines.fold<double>(
      0,
      (sum, line) => sum + (line.discountedAmount ?? 0),
    );
  }

  /// `vat` is the VAT rate. Amount as in `getVATForReceipt`.
  static double vatAmount(TempMainReceipt receipt) =>
      (receipt.originalCost ?? 0) *
      ((receipt.vat ?? 0) / 100);

  /// Unit the line was sold in, without creating placeholder units
  /// (as `getSelectedUnit` does when the list is empty).
  static ProductUnitsClass? _saleUnit(
    TempProductSaleRecord line,
  ) {
    final units = line.unitsList;
    if (units == null || units.isEmpty) return null;
    for (final unit in units) {
      if (unit.uuid == line.unitUuid) return unit;
    }
    for (final unit in units) {
      if (unit.isPrimary) return unit;
    }
    return null;
  }

  /// Sale quantity, without wastage. A 2D line sold in an area
  /// unit is one item: its quantity is an area, not pieces.
  static double lineItemCount(TempProductSaleRecord line) {
    if (line.quantityType == 2 &&
        _saleUnit(line)?.dimensionType ==
            ProductUnitsClass.areaUnit) {
      return 1;
    }
    return line.quantity;
  }

  static bool _lineCostMissing(
    TempProductSaleRecord line,
  ) => (line.costPrice ?? 0) <= 0;

  static ReceiptsReportRow build({
    required TempMainReceipt receipt,
    required Map<String, List<TempProductSaleRecord>>
    legacyLines,
  }) {
    List<TempProductSaleRecord>? lines;
    ReceiptLineSource source;
    final embedded = receipt.items;
    if (embedded != null && embedded.isNotEmpty) {
      lines = embedded;
      source = ReceiptLineSource.embedded;
    } else {
      final legacy = legacyLines[receipt.uuid];
      if (legacy != null && legacy.isNotEmpty) {
        lines = legacy;
        source = ReceiptLineSource.legacy;
      } else {
        source = ReceiptLineSource.none;
      }
    }
    // Void lines were removed from the cart, not sold.
    final sold =
        lines
            ?.where((line) => line.isVoid != true)
            .toList();

    final type = ReceiptsReportClassifier.type(receipt);
    final hidesTotals =
        type == ReceiptType.invoicePayment ||
        type == ReceiptType.orderDelivery;

    double? items;
    double? profit;
    double? lineRevenue;
    bool costMissing = false;
    if (sold != null) {
      // Invoice payments repeat the invoice's full quantities.
      if (type != ReceiptType.invoicePayment) {
        items = sold.fold<double>(
          0,
          (sum, line) => sum + lineItemCount(line),
        );
      }
      double profitSum = 0;
      double revenueSum = 0;
      for (final line in sold) {
        revenueSum += line.revenue;
        // As the items analysis: revenue - cost, missing cost as 0.
        profitSum += line.revenue - (line.costPrice ?? 0);
        if (_lineCostMissing(line)) costMissing = true;
      }
      profit = profitSum;
      lineRevenue = revenueSum;
    }

    final margin =
        (profit != null &&
                lineRevenue != null &&
                lineRevenue > 0)
            ? (profit / lineRevenue) * 100
            : null;

    return ReceiptsReportRow(
      receipt: receipt,
      displayId: displayId(receipt),
      type: type,
      channel: ReceiptsReportClassifier.channel(receipt),
      createdAt: receipt.createdAt.toLocal(),
      lineSource: source,
      revenue: receipt.getTotalRevenue(),
      balance: hidesTotals ? receipt.balance : null,
      subtotal:
          hidesTotals ? null : receipt.originalCost ?? 0,
      discount:
          hidesTotals
              ? null
              : discountAmount(receipt, sold),
      vat: hidesTotals ? null : vatAmount(receipt),
      items: items,
      profit: profit,
      lineRevenue: lineRevenue,
      costMissing: costMissing,
      margin: margin,
    );
  }

  static List<ReceiptsReportRow> buildAll({
    required List<TempMainReceipt> receipts,
    required List<TempProductSaleRecord> legacySales,
  }) {
    final legacy = legacyLinesByReceipt(legacySales);
    final rows = <ReceiptsReportRow>[];
    for (final receipt in receipts) {
      try {
        rows.add(
          build(receipt: receipt, legacyLines: legacy),
        );
      } catch (_) {
        // A single malformed receipt must never break the report.
      }
    }
    return rows;
  }
}

/// Receipts the current user may see. Department rule as
/// `departmentReceipts()`; the own-receipts rule applies with or
/// without departments.
class ReceiptsReportAccess {
  static List<TempMainReceipt> scope({
    required List<TempMainReceipt> receipts,
    required bool departmentsEnabled,
    required bool canViewAllDepartments,
    required String? currentDepartmentUuid,
    required bool canViewAllTransactions,
    required String? currentUserId,
  }) {
    final restrictDepartment =
        departmentsEnabled &&
        (!canViewAllDepartments ||
            currentDepartmentUuid != null);
    return receipts.where((receipt) {
      if (restrictDepartment &&
          receipt.departmentUuidNew !=
              currentDepartmentUuid) {
        return false;
      }
      if (!canViewAllTransactions &&
          receipt.staffId != currentUserId) {
        return false;
      }
      return true;
    }).toList();
  }
}

/// Reporting period. Dates are business days; `null` start means
/// all time (all loaded receipts).
class ReceiptsReportPeriod {
  final DateTime? start;
  final DateTime? end;

  const ReceiptsReportPeriod._(this.start, this.end);

  const ReceiptsReportPeriod.allTime() : this._(null, null);

  factory ReceiptsReportPeriod.day(DateTime day) {
    final d = _dateOnly(day);
    return ReceiptsReportPeriod._(d, d);
  }

  factory ReceiptsReportPeriod.range(
    DateTime first,
    DateTime last,
  ) {
    var s = _dateOnly(first);
    var e = _dateOnly(last);
    if (e.isBefore(s)) {
      final temp = s;
      s = e;
      e = temp;
    }
    return ReceiptsReportPeriod._(s, e);
  }

  /// Today's business day (after the shop's closing time rules).
  factory ReceiptsReportPeriod.today({
    DateTime? now,
    TimeOfDay? closingTime,
  }) {
    return ReceiptsReportPeriod.day(
      resolveBusinessDate(
        now ?? DateTime.now(),
        customClosingTime: closingTime,
      ),
    );
  }

  bool get isAllTime => start == null;

  bool get isSingleDay =>
      start != null &&
      end != null &&
      _sameDay(start!, end!);

  /// Same window as the receipts report: local `createdAt` in
  /// [closing time of start, closing time after end).
  bool contains(
    DateTime createdAt, {
    TimeOfDay? closingTime,
  }) {
    if (isAllTime) return true;
    return isDateTimeInBusinessWindow(
      dateTime: createdAt.toLocal(),
      rangeStartDate: start,
      rangeEndDate: end,
      customClosingTime: closingTime,
    );
  }

  static DateTime _dateOnly(DateTime d) =>
      DateTime(d.year, d.month, d.day);

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year &&
      a.month == b.month &&
      a.day == b.day;
}

/// All user-selectable filters, combined with AND. Keys are the
/// row keys ([ReceiptsReportRow.staffKey] etc.) or
/// [receiptsReportNoneKey], so a summary row can open the table
/// with the same set.
class ReceiptsReportFilters {
  String search;
  String? staffKey;
  String? customerKey;
  String? subStaffKey;
  String? departmentKey;
  ReceiptChannel? channel;
  ReceiptType? type;
  double? profitMin;
  double? profitMax;
  double? revenueMin;
  double? revenueMax;

  ReceiptsReportFilters({
    this.search = '',
    this.staffKey,
    this.customerKey,
    this.subStaffKey,
    this.departmentKey,
    this.channel,
    this.type,
    this.profitMin,
    this.profitMax,
    this.revenueMin,
    this.revenueMax,
  });

  ReceiptsReportFilters copy() => ReceiptsReportFilters(
    search: search,
    staffKey: staffKey,
    customerKey: customerKey,
    subStaffKey: subStaffKey,
    departmentKey: departmentKey,
    channel: channel,
    type: type,
    profitMin: profitMin,
    profitMax: profitMax,
    revenueMin: revenueMin,
    revenueMax: revenueMax,
  );

  /// Message for a min above its max, otherwise null.
  static String? rangeError(double? min, double? max) {
    if (min != null && max != null && min > max) {
      return 'Minimum cannot be more than maximum';
    }
    return null;
  }

  String? get profitRangeError =>
      rangeError(profitMin, profitMax);
  String? get revenueRangeError =>
      rangeError(revenueMin, revenueMax);

  /// Set and valid. An invalid range is not applied.
  bool get profitRangeActive =>
      (profitMin != null || profitMax != null) &&
      profitRangeError == null;
  bool get revenueRangeActive =>
      (revenueMin != null || revenueMax != null) &&
      revenueRangeError == null;

  int get activeCount =>
      (staffKey != null ? 1 : 0) +
      (customerKey != null ? 1 : 0) +
      (subStaffKey != null ? 1 : 0) +
      (departmentKey != null ? 1 : 0) +
      (channel != null ? 1 : 0) +
      (type != null ? 1 : 0) +
      (profitMin != null || profitMax != null ? 1 : 0) +
      (revenueMin != null || revenueMax != null ? 1 : 0);

  bool get hasAnything =>
      activeCount > 0 || search.trim().isNotEmpty;

  void clearAll() {
    search = '';
    clearFiltersOnly();
  }

  void clearFiltersOnly() {
    staffKey = null;
    customerKey = null;
    subStaffKey = null;
    departmentKey = null;
    channel = null;
    type = null;
    profitMin = null;
    profitMax = null;
    revenueMin = null;
    revenueMax = null;
  }

  static bool _keyMatches(
    String? filterKey,
    String? rowKey,
  ) {
    if (filterKey == null) return true;
    if (filterKey == receiptsReportNoneKey) {
      return rowKey == null;
    }
    return rowKey == filterKey;
  }

  static bool _inRange(
    double value,
    double? min,
    double? max,
  ) {
    if (min != null && value < min) return false;
    if (max != null && value > max) return false;
    return true;
  }

  bool matchesSearch(
    ReceiptsReportRow r, {
    required bool departmentsEnabled,
  }) {
    final q = search.trim().toLowerCase();
    if (q.isEmpty) return true;
    bool has(String? s) =>
        s != null && s.toLowerCase().contains(q);
    return has(r.customerName) ||
        has(r.staffName) ||
        (departmentsEnabled && has(r.departmentName)) ||
        has(r.displayId);
  }

  /// [subStaffEnabled] / [departmentsEnabled] / [profitVisible]
  /// switch off the filters that are hidden in the UI. With
  /// [ignoreProfit] the profit range is skipped.
  bool matches(
    ReceiptsReportRow r, {
    required bool departmentsEnabled,
    required bool subStaffEnabled,
    required bool profitVisible,
    bool ignoreProfit = false,
  }) {
    if (!matchesSearch(
      r,
      departmentsEnabled: departmentsEnabled,
    )) {
      return false;
    }
    if (!_keyMatches(staffKey, r.staffKey)) return false;
    if (!_keyMatches(customerKey, r.customerKey)) {
      return false;
    }
    if (subStaffEnabled &&
        !_keyMatches(subStaffKey, r.subStaffKey)) {
      return false;
    }
    if (departmentsEnabled &&
        !_keyMatches(departmentKey, r.departmentKey)) {
      return false;
    }
    if (channel != null && r.channel != channel) {
      return false;
    }
    if (type != null && r.type != type) return false;

    if (!ignoreProfit &&
        profitVisible &&
        profitRangeActive) {
      // Unknown or incomplete profit is never treated as 0.
      if (r.profit == null || r.costMissing) return false;
      if (!_inRange(r.profit!, profitMin, profitMax)) {
        return false;
      }
    }

    if (revenueRangeActive &&
        !_inRange(r.revenue, revenueMin, revenueMax)) {
      return false;
    }
    return true;
  }
}

/// One choice in a staff / customer / sub-staff / department
/// filter.
class ReceiptsFilterOption {
  final String key;
  final String label;

  const ReceiptsFilterOption(this.key, this.label);
}

/// Filter choices taken from the receipts themselves, so staff and
/// customers that were deleted since can still be selected. Each
/// key shows its most recent name.
class ReceiptsReportOptions {
  static List<ReceiptsFilterOption> _build(
    List<ReceiptsReportRow> rows, {
    required String? Function(ReceiptsReportRow) key,
    required String? Function(ReceiptsReportRow) name,
    required String fallbackName,
    required String noneLabel,
  }) {
    final newestFirst = List<ReceiptsReportRow>.from(rows)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final labels = <String, String>{};
    var hasNone = false;
    for (final r in newestFirst) {
      final k = key(r);
      if (k == null) {
        hasNone = true;
        continue;
      }
      labels.putIfAbsent(k, () => name(r) ?? fallbackName);
    }
    final options =
        labels.entries
            .map(
              (e) => ReceiptsFilterOption(e.key, e.value),
            )
            .toList()
          ..sort((a, b) {
            final c = a.label.toLowerCase().compareTo(
              b.label.toLowerCase(),
            );
            return c != 0 ? c : a.key.compareTo(b.key);
          });
    if (hasNone) {
      options.add(
        ReceiptsFilterOption(
          receiptsReportNoneKey,
          noneLabel,
        ),
      );
    }
    return options;
  }

  static List<ReceiptsFilterOption> staff(
    List<ReceiptsReportRow> rows,
  ) => _build(
    rows,
    key: (r) => r.staffKey,
    name: (r) => r.staffName,
    fallbackName: 'Not Set',
    noneLabel: 'No Staff',
  );

  static List<ReceiptsFilterOption> customers(
    List<ReceiptsReportRow> rows,
  ) => _build(
    rows,
    key: (r) => r.customerKey,
    name: (r) => r.customerName,
    fallbackName: 'Not Set',
    noneLabel: 'No Customer',
  );

  static List<ReceiptsFilterOption> subStaff(
    List<ReceiptsReportRow> rows,
  ) => _build(
    rows,
    key: (r) => r.subStaffKey,
    name: (r) => r.subStaffName,
    fallbackName: 'Not Set',
    noneLabel: 'No Sub-Staff',
  );

  static List<ReceiptsFilterOption> departments(
    List<ReceiptsReportRow> rows,
  ) => _build(
    rows,
    key: (r) => r.departmentKey,
    name: (r) => r.departmentName,
    fallbackName: 'No Department',
    noneLabel: 'No Department',
  );
}

/// Result of [ReceiptsReportQuery.paginate].
class ReceiptsReportPage {
  final List<ReceiptsReportRow> rows;
  final int totalCount;
  final int page; // 1-based, already clamped
  final int totalPages;

  const ReceiptsReportPage({
    required this.rows,
    required this.totalCount,
    required this.page,
    required this.totalPages,
  });

  int get firstIndex =>
      totalCount == 0
          ? 0
          : (page - 1) * receiptsReportPageSize + 1;
  int get lastIndex =>
      firstIndex == 0 ? 0 : firstIndex + rows.length - 1;
}

class ReceiptsReportQuery {
  static int _cmp<T extends Comparable>(
    T? a,
    T? b,
    bool asc,
  ) {
    // Null values always sink to the bottom, in both directions.
    if (a == null && b == null) return 0;
    if (a == null) return 1;
    if (b == null) return -1;
    final c = a.compareTo(b);
    return asc ? c : -c;
  }

  /// Rows in [period], then search and filters, then sorted. The
  /// whole set is sorted before pagination.
  static List<ReceiptsReportRow> filterAndSort({
    required List<ReceiptsReportRow> rows,
    required ReceiptsReportPeriod period,
    required ReceiptsReportFilters filters,
    required ReceiptsSortField sortField,
    required bool ascending,
    required bool departmentsEnabled,
    required bool subStaffEnabled,
    required bool profitVisible,
    TimeOfDay? closingTime,
  }) {
    final out =
        rows
            .where(
              (r) =>
                  period.contains(
                    r.createdAt,
                    closingTime: closingTime,
                  ) &&
                  filters.matches(
                    r,
                    departmentsEnabled: departmentsEnabled,
                    subStaffEnabled: subStaffEnabled,
                    profitVisible: profitVisible,
                  ),
            )
            .toList();

    int compare(ReceiptsReportRow a, ReceiptsReportRow b) {
      int c;
      switch (sortField) {
        case ReceiptsSortField.createdAt:
          c = _cmp(a.createdAt, b.createdAt, ascending);
          break;
        case ReceiptsSortField.customer:
          c = _cmp(
            a.customerName?.toLowerCase(),
            b.customerName?.toLowerCase(),
            ascending,
          );
          break;
        case ReceiptsSortField.staff:
          c = _cmp(
            a.staffName?.toLowerCase(),
            b.staffName?.toLowerCase(),
            ascending,
          );
          break;
        case ReceiptsSortField.revenue:
          c = _cmp(a.revenue, b.revenue, ascending);
          break;
        case ReceiptsSortField.balance:
          c = _cmp(a.balance, b.balance, ascending);
          break;
        case ReceiptsSortField.profit:
          c = _cmp(a.profit, b.profit, ascending);
          break;
        case ReceiptsSortField.margin:
          c = _cmp(a.margin, b.margin, ascending);
          break;
        case ReceiptsSortField.items:
          c = _cmp(a.items, b.items, ascending);
          break;
      }
      if (c != 0) return c;
      // Deterministic tie-breakers keep pagination stable.
      final t = b.createdAt.compareTo(a.createdAt);
      return t != 0 ? t : a.uuid.compareTo(b.uuid);
    }

    out.sort(compare);
    return out;
  }

  /// Rows the profit range left out only because their profit is
  /// unknown or has a missing cost. 0 when the range is not set.
  static int profitExcludedCount({
    required List<ReceiptsReportRow> rows,
    required ReceiptsReportPeriod period,
    required ReceiptsReportFilters filters,
    required bool departmentsEnabled,
    required bool subStaffEnabled,
    required bool profitVisible,
    TimeOfDay? closingTime,
  }) {
    if (!profitVisible || !filters.profitRangeActive) {
      return 0;
    }
    return rows
        .where(
          (r) =>
              (r.profit == null || r.costMissing) &&
              period.contains(
                r.createdAt,
                closingTime: closingTime,
              ) &&
              filters.matches(
                r,
                departmentsEnabled: departmentsEnabled,
                subStaffEnabled: subStaffEnabled,
                profitVisible: profitVisible,
                ignoreProfit: true,
              ),
        )
        .length;
  }

  static ReceiptsReportPage paginate(
    List<ReceiptsReportRow> sorted,
    int requestedPage,
  ) {
    final total = sorted.length;
    final pages =
        total == 0
            ? 1
            : (total / receiptsReportPageSize).ceil();
    final page = requestedPage.clamp(1, pages);
    final start = (page - 1) * receiptsReportPageSize;
    final end =
        (start + receiptsReportPageSize) > total
            ? total
            : start + receiptsReportPageSize;
    return ReceiptsReportPage(
      rows:
          total == 0
              ? const []
              : sorted.sublist(start, end),
      totalCount: total,
      page: page,
      totalPages: pages,
    );
  }
}
