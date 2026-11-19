import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:stockall/classes/payment_entry/payment_entry.dart';
import 'package:stockall/classes/temp_main_receipt/temp_main_receipt.dart';
import 'package:stockall/classes/temp_orders/order_items.dart';
import 'package:stockall/classes/temp_orders/orders.dart';
import 'package:stockall/classes/temp_product_slaes_record/temp_product_sale_record.dart';
import 'package:stockall/pages/report/components/report_group_by.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/components/report_department_scope.dart';

/// Page size, same as the Invoice and Receipts report tables.
const int orderReportPageSize = 100;

/// Filter key for the "unassigned" bucket (no staff, no customer,
/// no sub-staff, no department).
const String orderReportNoneKey = '__none__';

const String orderNoStaffLabel = 'No staff';
const String orderNoCustomerLabel = 'No customer';
const String orderNoSubStaffLabel = 'No sub-staff';
const String orderNoDepartmentLabel = 'No Department';

/// Same tolerance as `areOrderDeliveryQuantitiesValid`, scaled
/// for large quantities.
const double orderDeliveryEpsilon = 1e-9;

bool _near(double a, double b) {
  final scale = math.max(1.0, math.max(a.abs(), b.abs()));
  return (a - b).abs() <= orderDeliveryEpsilon * scale;
}

enum OrderDeliveryStatus { undelivered, partial, full }

extension OrderDeliveryStatusLabel on OrderDeliveryStatus {
  String get label {
    switch (this) {
      case OrderDeliveryStatus.undelivered:
        return 'Undelivered';
      case OrderDeliveryStatus.partial:
        return 'Partially Delivered';
      case OrderDeliveryStatus.full:
        return 'Fully Delivered';
    }
  }
}

/// From the amounts paid on the order's delivery receipts.
enum OrderPaymentChannel { cash, bank, account, split, unpaid }

extension OrderPaymentChannelLabel on OrderPaymentChannel {
  String get label {
    switch (this) {
      case OrderPaymentChannel.cash:
        return PaymentMethods.cash;
      case OrderPaymentChannel.bank:
        return PaymentMethods.bank;
      case OrderPaymentChannel.account:
        return PaymentMethods.account;
      case OrderPaymentChannel.split:
        return PaymentMethods.split;
      case OrderPaymentChannel.unpaid:
        return 'Unpaid';
    }
  }
}

enum OrderSortField {
  id,
  createdAt,
  staff,
  subStaff,
  customer,
  department,
  items,
  delivered,
  status,
  channel,
  total,
  deliveredValue,
  undeliveredValue,
  paid,
  balance,
  cost,
  profit,
  margin,
}

/// One product of an order, in primary units. Lines of the same
/// product are added together, because delivery receipt lines
/// only carry the product uuid.
class OrderProductDelivery {
  final String productUuid;
  final String productName;
  final double ordered;

  /// From the order lines' remaining quantity.
  final double stored;

  /// From the delivery receipt lines. Null when a delivery
  /// receipt of the order has no line data.
  final double? fromReceipts;

  /// Sum of the lines' total revenue.
  final double value;

  const OrderProductDelivery({
    required this.productUuid,
    required this.productName,
    required this.ordered,
    required this.stored,
    required this.fromReceipts,
    required this.value,
  });

  double get effective =>
      fromReceipts == null
          ? stored
          : math.max(stored, fromReceipts!);

  bool get isOverDelivered =>
      effective > ordered && !_near(effective, ordered);

  bool get recordsDisagree =>
      isOverDelivered ||
      (fromReceipts != null && !_near(stored, fromReceipts!));

  bool get isFullyDelivered =>
      effective >= ordered || _near(effective, ordered);

  bool get hasDelivery => effective > 0 && !_near(effective, 0);

  /// Share of the product delivered, capped at 1.
  double get deliveredShare {
    if (ordered <= 0) return 1;
    if (isFullyDelivered) return 1;
    return math.max(0.0, effective) / ordered;
  }
}

/// Delivery state of one order. Every value is calculated once.
class OrderDeliverySummary {
  final List<OrderProductDelivery> products;

  /// Null when a unit conversion failed or the order has no
  /// quantities to deliver.
  final OrderDeliveryStatus? status;

  /// Stored and receipt quantities differ, a receipt delivered a
  /// product the order doesn't have, or a product was delivered
  /// beyond what was ordered.
  final bool recordsDisagree;

  /// A delivery receipt had no line data, so only the stored
  /// quantities were used.
  final bool receiptLinesUnavailable;

  /// A line's unit conversion failed.
  final bool quantitiesUnavailable;

  /// Share of the order value delivered, 0 to 1. Null with
  /// [status].
  final double? deliveredFraction;

  final double? orderedItems;
  final double? deliveredItems;

  const OrderDeliverySummary({
    required this.products,
    required this.status,
    required this.recordsDisagree,
    required this.receiptLinesUnavailable,
    required this.quantitiesUnavailable,
    required this.deliveredFraction,
    required this.orderedItems,
    required this.deliveredItems,
  });
}

class OrderDeliveryCalculator {
  /// [receipts] are the order's delivery receipts.
  /// [legacySalesByReceipt] holds product_sales rows for receipts
  /// saved before `items` existed, keyed by receipt uuid.
  static OrderDeliverySummary compute({
    required Orders order,
    required List<TempMainReceipt> receipts,
    Map<String, List<TempProductSaleRecord>>
        legacySalesByReceipt = const {},
  }) {
    final names = <String, String>{};
    final ordered = <String, double>{};
    final stored = <String, double>{};
    final value = <String, double>{};
    bool quantitiesUnavailable = false;

    for (final OrderItems line in order.orderItems) {
      final key = line.productUuid;
      names.putIfAbsent(key, () => line.productName);
      try {
        final qty = line.getActualQuantity();
        final remaining = line.getActualRemainingQuantity();
        ordered[key] = (ordered[key] ?? 0) + qty;
        stored[key] =
            (stored[key] ?? 0) + math.max(0.0, qty - remaining);
        value[key] = (value[key] ?? 0) + line.getTotalRevenue();
      } on StateError {
        quantitiesUnavailable = true;
      }
    }

    bool linesUnavailable = false;
    final fromReceipts = <String, double>{};
    for (final receipt in receipts) {
      var lines = receipt.items ?? const [];
      if (lines.isEmpty) {
        lines =
            legacySalesByReceipt[receipt.uuid ?? ''] ??
            const [];
      }
      if (lines.isEmpty) {
        linesUnavailable = true;
        continue;
      }
      for (final line in lines) {
        if (line.isVoid == true) continue;
        final key = line.productUuid ?? '';
        try {
          fromReceipts[key] =
              (fromReceipts[key] ?? 0) +
              line.getActualQuantity();
        } on StateError {
          quantitiesUnavailable = true;
        }
      }
    }

    final products = <OrderProductDelivery>[
      for (final key in ordered.keys)
        OrderProductDelivery(
          productUuid: key,
          productName: names[key] ?? '',
          ordered: ordered[key]!,
          stored: stored[key] ?? 0,
          fromReceipts:
              linesUnavailable ? null : (fromReceipts[key] ?? 0),
          value: value[key] ?? 0,
        ),
    ];

    final unmatchedReceiptProduct =
        !linesUnavailable &&
        fromReceipts.entries.any(
          (e) =>
              !ordered.containsKey(e.key) && !_near(e.value, 0),
        );
    final disagree =
        unmatchedReceiptProduct ||
        products.any((p) => p.recordsDisagree);

    final measurable =
        products.where((p) => p.ordered > 0).toList();
    if (quantitiesUnavailable || measurable.isEmpty) {
      return OrderDeliverySummary(
        products: products,
        status: null,
        recordsDisagree: disagree,
        receiptLinesUnavailable: linesUnavailable,
        quantitiesUnavailable: quantitiesUnavailable,
        deliveredFraction: null,
        orderedItems: quantitiesUnavailable ? null : 0,
        deliveredItems: quantitiesUnavailable ? null : 0,
      );
    }

    final OrderDeliveryStatus status;
    if (measurable.every((p) => p.isFullyDelivered)) {
      status = OrderDeliveryStatus.full;
    } else if (measurable.any((p) => p.hasDelivery)) {
      status = OrderDeliveryStatus.partial;
    } else {
      status = OrderDeliveryStatus.undelivered;
    }

    final double fraction;
    switch (status) {
      case OrderDeliveryStatus.full:
        fraction = 1;
        break;
      case OrderDeliveryStatus.undelivered:
        fraction = 0;
        break;
      case OrderDeliveryStatus.partial:
        final totalValue = measurable.fold<double>(
          0,
          (s, p) => s + p.value,
        );
        if (totalValue > 0) {
          fraction =
              measurable.fold<double>(
                0,
                (s, p) => s + p.value * p.deliveredShare,
              ) /
              totalValue;
        } else {
          // Free items only: weigh by quantity instead.
          final totalQty = measurable.fold<double>(
            0,
            (s, p) => s + p.ordered,
          );
          fraction =
              measurable.fold<double>(
                0,
                (s, p) => s + p.ordered * p.deliveredShare,
              ) /
              totalQty;
        }
        break;
    }

    return OrderDeliverySummary(
      products: products,
      status: status,
      recordsDisagree: disagree,
      receiptLinesUnavailable: linesUnavailable,
      quantitiesUnavailable: false,
      deliveredFraction: fraction,
      orderedItems: products.fold<double>(
        0,
        (s, p) => s + p.ordered,
      ),
      deliveredItems: products.fold<double>(
        0,
        (s, p) => s + p.effective,
      ),
    );
  }
}

/// One table row. `null` means unknown or not applicable (shown
/// as "—").
class OrderReportRow {
  final Orders order;
  final String displayId;

  /// `createdAt` in local time.
  final DateTime createdAt;

  final OrderDeliverySummary delivery;

  /// The order's delivery receipts.
  final int deliveryCount;

  final double discountAmount;
  final double vatAmount;

  /// `order.total`, after discount and with VAT.
  final double total;

  final double? deliveredValue;
  final double? undeliveredValue;

  /// cash + bank + customer account over the delivery receipts.
  final double paid;

  /// `total - paid`, never below 0.
  final double balance;

  final OrderPaymentChannel channel;
  final String channelLabel;

  /// Null when no line has a cost price.
  final double? cost;

  /// `total - cost`, VAT included in revenue as in the Receipts
  /// report. An estimate until the order is Fully Delivered.
  final double? profit;
  final double? margin;

  OrderReportRow({
    required this.order,
    required this.displayId,
    required this.createdAt,
    required this.delivery,
    required this.deliveryCount,
    required this.discountAmount,
    required this.vatAmount,
    required this.total,
    required this.deliveredValue,
    required this.undeliveredValue,
    required this.paid,
    required this.balance,
    required this.channel,
    String? channelLabel,
    required this.cost,
    required this.profit,
    required this.margin,
  }) : channelLabel = channelLabel ?? channel.label;

  String get uuid => order.uuid ?? '';
  String? get barcode => order.barcode;

  OrderDeliveryStatus? get status => delivery.status;
  bool get recordsDisagree => delivery.recordsDisagree;
  bool get profitIsEstimate =>
      delivery.status != OrderDeliveryStatus.full;

  String? get staffKey => _key(order.staffId);
  String? get customerKey => _key(order.customerId);
  String? get subStaffKey => _key(order.subStaffUuid);
  String? get departmentKey => _key(order.departmentUuid);

  String? get staffName => _name(order.staffName);
  String? get customerName => _name(order.customerName);
  String? get subStaffName => _name(order.subStaffName);
  String? get departmentName => _name(order.departmentName);
  String? get comment => _name(order.comment);

  String get staffLabel => staffName ?? 'Not Set';
  String get customerLabel => customerName ?? 'Not Set';
  String get subStaffLabel => subStaffName ?? 'Not Set';
  String get departmentLabel =>
      departmentKey == null
          ? orderNoDepartmentLabel
          : departmentName ?? orderNoDepartmentLabel;

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

class OrderReportRowBuilder {
  /// Payments are the receipts whose `orderUuid` is the order's,
  /// as `Orders.getTotalPayment` counts them.
  static List<OrderReportRow> buildAll({
    required List<Orders> orders,
    required List<TempMainReceipt> allReceipts,
    List<TempProductSaleRecord> allProductSales = const [],
  }) {
    final receiptsByOrder = <String, List<TempMainReceipt>>{};
    for (final r in allReceipts) {
      final u = r.orderUuid;
      if (u != null && u.isNotEmpty) {
        (receiptsByOrder[u] ??= []).add(r);
      }
    }
    final salesByReceipt =
        <String, List<TempProductSaleRecord>>{};
    for (final s in allProductSales) {
      final u = s.receiptUuid;
      if (u != null && u.isNotEmpty) {
        (salesByReceipt[u] ??= []).add(s);
      }
    }
    return [
      for (final o in orders)
        buildSingle(
          order: o,
          receipts: receiptsByOrder[o.uuid ?? ''] ?? const [],
          legacySalesByReceipt: salesByReceipt,
        ),
    ];
  }

  /// [receipts] are every receipt carrying the order's uuid: all
  /// of them count as payments, only delivery receipts
  /// (`salesTypeIndex == 3`) count as deliveries.
  static OrderReportRow buildSingle({
    required Orders order,
    required List<TempMainReceipt> receipts,
    Map<String, List<TempProductSaleRecord>>
        legacySalesByReceipt = const {},
  }) {
    final deliveries =
        receipts.where((r) => r.salesTypeIndex == 3).toList();
    final delivery = OrderDeliveryCalculator.compute(
      order: order,
      receipts: deliveries,
      legacySalesByReceipt: legacySalesByReceipt,
    );

    double cash = 0;
    double bank = 0;
    double account = 0;
    for (final r in receipts) {
      cash += r.cashAlt;
      bank += r.bank;
      account += r.customerAccount ?? 0;
    }
    final paid = cash + bank + account;
    final used =
        PaymentBreakdown.fromAmounts(
          cash: cash,
          bank: bank,
          account: account,
        ).methodsUsed;
    final OrderPaymentChannel channel;
    if (used.isEmpty) {
      channel = OrderPaymentChannel.unpaid;
    } else if (used.length > 1) {
      channel = OrderPaymentChannel.split;
    } else if (used.first == PaymentMethods.bank) {
      channel = OrderPaymentChannel.bank;
    } else if (used.first == PaymentMethods.account) {
      channel = OrderPaymentChannel.account;
    } else {
      channel = OrderPaymentChannel.cash;
    }
    String channelLabel = channel.label;
    if (channel == OrderPaymentChannel.bank) {
      final bankLabels = <String>{};
      for (final r in receipts) {
        if (r.bank <= 0) continue;
        final bLabel = r.paymentBreakdown().label.trim();
        if (bLabel.isNotEmpty &&
            PaymentMethods.isBankMethod(bLabel) &&
            bLabel.toLowerCase() != 'bank') {
          bankLabels.add(bLabel);
        } else if (r.selectedBank != null &&
            r.selectedBank!.displayName.trim().isNotEmpty) {
          bankLabels.add(r.selectedBank!.displayName.trim());
        } else if (PaymentMethods.isBankMethod(r.paymentMethod) &&
            r.paymentMethod.trim().isNotEmpty &&
            r.paymentMethod.trim().toLowerCase() != 'bank') {
          bankLabels.add(r.paymentMethod.trim());
        }
      }
      if (bankLabels.length == 1) {
        channelLabel = bankLabels.first;
      }
    }

    final total = order.total ?? 0;
    final balance = math.max(0.0, total - paid);

    final fraction = delivery.deliveredFraction;
    final deliveredValue =
        fraction == null ? null : total * fraction;
    final undeliveredValue =
        deliveredValue == null ? null : total - deliveredValue;

    double? cost;
    try {
      for (final line in order.orderItems) {
        if (line.costPrice == null) continue;
        cost = (cost ?? 0) + line.getTotalCostPrice();
      }
    } on StateError {
      cost = null;
    }
    final profit = cost == null ? null : total - cost;
    final margin =
        (profit != null && total > 0)
            ? (profit / total) * 100
            : null;

    final subtotal = order.originalCost ?? 0;
    final double discountAmount;
    if (order.fixedDiscount != null &&
        order.fixedDiscount! > 0) {
      discountAmount = order.fixedDiscount!;
    } else if (order.generalDiscount != null &&
        order.generalDiscount! > 0) {
      discountAmount =
          subtotal * (order.generalDiscount! / 100);
    } else {
      discountAmount = 0;
    }
    final vatAmount =
        (order.vat != null && order.vat! > 0)
            ? subtotal * (order.vat! / 100)
            : 0.0;

    return OrderReportRow(
      order: order,
      displayId: _displayId(order),
      createdAt: order.createdAt.toLocal(),
      delivery: delivery,
      deliveryCount: deliveries.length,
      discountAmount: discountAmount,
      vatAmount: vatAmount,
      total: total,
      deliveredValue: deliveredValue,
      undeliveredValue: undeliveredValue,
      paid: paid,
      balance: balance,
      channel: channel,
      channelLabel: channelLabel,
      cost: cost,
      profit: profit,
      margin: margin,
    );
  }

  static String _displayId(Orders order) {
    final barcode = order.barcode?.trim();
    if (barcode != null && barcode.isNotEmpty) {
      return '#$barcode';
    }
    final uuid = order.uuid?.trim();
    if (uuid != null && uuid.isNotEmpty) {
      final digits = uuid.replaceAll(RegExp(r'\D'), '');
      return '#${digits.isNotEmpty ? digits : (uuid.length > 8 ? uuid.substring(0, 8) : uuid)}';
    }
    return '—';
  }
}

class OrderReportFilterOption {
  final String key;
  final String label;

  const OrderReportFilterOption(this.key, this.label);
}

/// Filter choices taken from the orders themselves, so staff and
/// customers that were deleted since can still be selected. Each
/// key shows its most recent name; the none option is last.
class OrderReportOptions {
  static List<OrderReportFilterOption> _build(
    List<OrderReportRow> rows, {
    required String? Function(OrderReportRow) key,
    required String? Function(OrderReportRow) name,
    required String noneLabel,
  }) {
    final newestFirst = List<OrderReportRow>.from(rows)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final labels = <String, String>{};
    var hasNone = false;
    for (final r in newestFirst) {
      final k = key(r);
      if (k == null) {
        hasNone = true;
        continue;
      }
      labels.putIfAbsent(k, () => name(r) ?? 'Not Set');
    }
    final options =
        labels.entries
            .map((e) => OrderReportFilterOption(e.key, e.value))
            .toList()
          ..sort((a, b) {
            final c = a.label.toLowerCase().compareTo(
              b.label.toLowerCase(),
            );
            return c != 0 ? c : a.key.compareTo(b.key);
          });
    if (hasNone) {
      options.add(
        OrderReportFilterOption(orderReportNoneKey, noneLabel),
      );
    }
    return options;
  }

  static List<OrderReportFilterOption> staff(
    List<OrderReportRow> rows,
  ) => _build(
    rows,
    key: (r) => r.staffKey,
    name: (r) => r.staffName,
    noneLabel: orderNoStaffLabel,
  );

  static List<OrderReportFilterOption> customers(
    List<OrderReportRow> rows,
  ) => _build(
    rows,
    key: (r) => r.customerKey,
    name: (r) => r.customerName,
    noneLabel: orderNoCustomerLabel,
  );

  static List<OrderReportFilterOption> subStaff(
    List<OrderReportRow> rows,
  ) => _build(
    rows,
    key: (r) => r.subStaffKey,
    name: (r) => r.subStaffName,
    noneLabel: orderNoSubStaffLabel,
  );

  static List<OrderReportFilterOption> departments(
    List<OrderReportRow> rows,
  ) => _build(
    rows,
    key: (r) => r.departmentKey,
    name: (r) => r.departmentName,
    noneLabel: orderNoDepartmentLabel,
  );

  static String labelFor(
    List<OrderReportFilterOption> options,
    String key,
    String fallback,
  ) {
    for (final o in options) {
      if (o.key == key) return o.label;
    }
    return fallback;
  }
}

/// Department access, as the Invoice Report Table applies it.
class OrderReportScope {
  static List<Orders> scope({
    required List<Orders> orders,
    required int shopId,
    required bool departmentsEnabled,
    required bool canViewAllDepartments,
    required String? currentDepartmentUuid,
  }) {
    final shopOrders =
        orders.where((o) => o.shopId == shopId).toList();
    // Without "view all departments": the current department, or
    // with none (staff assigned to no department) only orders in no
    // department.
    if (departmentsEnabled && !canViewAllDepartments) {
      return shopOrders
          .where(
            (o) => reportDepartmentMatches(
              o.departmentUuid,
              currentDepartmentUuid,
            ),
          )
          .toList();
    }
    return shopOrders;
  }
}

/// All user-selectable filters, combined with AND. Keys are the
/// row keys ([OrderReportRow.staffKey] etc.) or
/// [orderReportNoneKey], so an analysis row can open the table
/// with the same set. Group by and the period are view options,
/// so Reset All ([clearAll]) keeps them.
class OrderReportFilters {
  String search;
  String? staffKey;
  String? customerKey;
  String? subStaffKey;
  String? departmentKey;
  OrderPaymentChannel? channel;
  OrderDeliveryStatus? deliveryStatus;

  /// Only orders whose stored and receipt quantities disagree.
  bool recordsDisagree;

  double? totalMin;
  double? totalMax;
  double? paidMin;
  double? paidMax;
  double? balanceMin;
  double? balanceMax;
  double? profitMin;
  double? profitMax;

  OrderReportFilters({
    this.search = '',
    this.staffKey,
    this.customerKey,
    this.subStaffKey,
    this.departmentKey,
    this.channel,
    this.deliveryStatus,
    this.recordsDisagree = false,
    this.totalMin,
    this.totalMax,
    this.paidMin,
    this.paidMax,
    this.balanceMin,
    this.balanceMax,
    this.profitMin,
    this.profitMax,
  });

  OrderReportFilters copy() => OrderReportFilters(
    search: search,
    staffKey: staffKey,
    customerKey: customerKey,
    subStaffKey: subStaffKey,
    departmentKey: departmentKey,
    channel: channel,
    deliveryStatus: deliveryStatus,
    recordsDisagree: recordsDisagree,
    totalMin: totalMin,
    totalMax: totalMax,
    paidMin: paidMin,
    paidMax: paidMax,
    balanceMin: balanceMin,
    balanceMax: balanceMax,
    profitMin: profitMin,
    profitMax: profitMax,
  );

  /// Message for a min above its max, otherwise null.
  static String? rangeError(double? min, double? max) {
    if (min != null && max != null && min > max) {
      return 'Minimum cannot be more than maximum';
    }
    return null;
  }

  String? get totalRangeError => rangeError(totalMin, totalMax);
  String? get paidRangeError => rangeError(paidMin, paidMax);
  String? get balanceRangeError =>
      rangeError(balanceMin, balanceMax);
  String? get profitRangeError =>
      rangeError(profitMin, profitMax);

  int get activeCount =>
      (staffKey != null ? 1 : 0) +
      (customerKey != null ? 1 : 0) +
      (subStaffKey != null ? 1 : 0) +
      (departmentKey != null ? 1 : 0) +
      (channel != null ? 1 : 0) +
      (deliveryStatus != null ? 1 : 0) +
      (recordsDisagree ? 1 : 0) +
      (totalMin != null || totalMax != null ? 1 : 0) +
      (paidMin != null || paidMax != null ? 1 : 0) +
      (balanceMin != null || balanceMax != null ? 1 : 0) +
      (profitMin != null || profitMax != null ? 1 : 0);

  bool get hasAnything =>
      activeCount > 0 || search.trim().isNotEmpty;

  void clearAll() {
    search = '';
    staffKey = null;
    customerKey = null;
    subStaffKey = null;
    departmentKey = null;
    channel = null;
    deliveryStatus = null;
    recordsDisagree = false;
    totalMin = null;
    totalMax = null;
    paidMin = null;
    paidMax = null;
    balanceMin = null;
    balanceMax = null;
    profitMin = null;
    profitMax = null;
  }

  /// Null [filterKey] matches all; [orderReportNoneKey] matches a
  /// null [rowKey].
  static bool keyMatches(String? filterKey, String? rowKey) {
    if (filterKey == null) return true;
    if (filterKey == orderReportNoneKey) return rowKey == null;
    return rowKey == filterKey;
  }

  /// An invalid range (min above max) is not applied.
  static bool _inRange(double? value, double? min, double? max) {
    if (min == null && max == null) return true;
    if (rangeError(min, max) != null) return true;
    if (value == null) return false;
    if (min != null && value < min) return false;
    if (max != null && value > max) return false;
    return true;
  }

  bool matchesSearch(
    OrderReportRow r, {
    required bool departmentsEnabled,
  }) {
    final q = search.trim().toLowerCase();
    if (q.isEmpty) return true;
    bool has(String? s) =>
        s != null && s.toLowerCase().contains(q);
    return has(r.displayId) ||
        has(r.barcode) ||
        has(r.customerName) ||
        has(r.staffName) ||
        (departmentsEnabled && has(r.departmentName));
  }

  bool matches(
    OrderReportRow r, {
    required bool departmentsEnabled,
    required bool subStaffEnabled,
    required bool profitVisible,
  }) {
    if (!matchesSearch(r, departmentsEnabled: departmentsEnabled)) {
      return false;
    }
    if (!keyMatches(staffKey, r.staffKey)) return false;
    if (!keyMatches(customerKey, r.customerKey)) return false;
    if (subStaffEnabled &&
        !keyMatches(subStaffKey, r.subStaffKey)) {
      return false;
    }
    if (departmentsEnabled &&
        !keyMatches(departmentKey, r.departmentKey)) {
      return false;
    }
    if (channel != null && r.channel != channel) return false;
    if (deliveryStatus != null && r.status != deliveryStatus) {
      return false;
    }
    if (recordsDisagree && !r.recordsDisagree) return false;
    if (!_inRange(r.total, totalMin, totalMax)) return false;
    if (!_inRange(r.paid, paidMin, paidMax)) return false;
    if (!_inRange(r.balance, balanceMin, balanceMax)) {
      return false;
    }
    if (profitVisible &&
        !_inRange(r.profit, profitMin, profitMax)) {
      return false;
    }
    return true;
  }
}

/// Totals cover every filtered row, not just this page.
class OrderReportTotals {
  final int count;
  final double total;
  final double deliveredValue;
  final double undeliveredValue;
  final double paid;
  final double balance;

  /// Null when no row has a cost.
  final double? cost;
  final double? profit;

  /// A counted profit belongs to an order not Fully Delivered.
  final bool profitIsEstimate;

  const OrderReportTotals({
    required this.count,
    required this.total,
    required this.deliveredValue,
    required this.undeliveredValue,
    required this.paid,
    required this.balance,
    required this.cost,
    required this.profit,
    this.profitIsEstimate = false,
  });

  /// Unknown delivered / undelivered values count as 0, as the
  /// invoice totals treat an unknown total.
  factory OrderReportTotals.of(Iterable<OrderReportRow> rows) {
    int count = 0;
    double total = 0;
    double delivered = 0;
    double undelivered = 0;
    double paid = 0;
    double balance = 0;
    double? cost;
    double? profit;
    bool estimate = false;
    for (final r in rows) {
      count++;
      total += r.total;
      delivered += r.deliveredValue ?? 0;
      undelivered += r.undeliveredValue ?? 0;
      paid += r.paid;
      balance += r.balance;
      if (r.cost != null) cost = (cost ?? 0) + r.cost!;
      if (r.profit != null) {
        profit = (profit ?? 0) + r.profit!;
        if (r.profitIsEstimate) estimate = true;
      }
    }
    return OrderReportTotals(
      count: count,
      total: total,
      deliveredValue: delivered,
      undeliveredValue: undelivered,
      paid: paid,
      balance: balance,
      cost: cost,
      profit: profit,
      profitIsEstimate: estimate,
    );
  }
}

class OrderReportPage {
  final List<OrderReportRow> rows;
  final int totalCount;
  final int page;
  final int pageSize;
  final int totalPages;
  final OrderReportTotals totals;

  const OrderReportPage({
    required this.rows,
    required this.totalCount,
    required this.page,
    required this.pageSize,
    required this.totalPages,
    required this.totals,
  });

  int get firstIndex =>
      totalCount == 0 ? 0 : (page - 1) * pageSize + 1;
  int get lastIndex =>
      totalCount == 0 ? 0 : (page - 1) * pageSize + rows.length;
}

class OrderReportQuery {
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
  static List<OrderReportRow> filterAndSort({
    required List<OrderReportRow> rows,
    required ReceiptsReportPeriod period,
    required OrderReportFilters filters,
    required OrderSortField sortField,
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

    int compare(OrderReportRow a, OrderReportRow b) {
      final asc = ascending;
      int c;
      switch (sortField) {
        case OrderSortField.id:
          c = _cmp(a.displayId, b.displayId, asc);
          break;
        case OrderSortField.createdAt:
          c = _cmp(a.createdAt, b.createdAt, asc);
          break;
        case OrderSortField.staff:
          c = _cmp(
            a.staffName?.toLowerCase(),
            b.staffName?.toLowerCase(),
            asc,
          );
          break;
        case OrderSortField.subStaff:
          c = _cmp(
            a.subStaffName?.toLowerCase(),
            b.subStaffName?.toLowerCase(),
            asc,
          );
          break;
        case OrderSortField.customer:
          c = _cmp(
            a.customerName?.toLowerCase(),
            b.customerName?.toLowerCase(),
            asc,
          );
          break;
        case OrderSortField.department:
          c = _cmp(
            a.departmentLabel.toLowerCase(),
            b.departmentLabel.toLowerCase(),
            asc,
          );
          break;
        case OrderSortField.items:
          c = _cmp(
            a.delivery.orderedItems,
            b.delivery.orderedItems,
            asc,
          );
          break;
        case OrderSortField.delivered:
          c = _cmp(
            a.delivery.deliveredItems,
            b.delivery.deliveredItems,
            asc,
          );
          break;
        case OrderSortField.status:
          c = _cmp(a.status?.index, b.status?.index, asc);
          break;
        case OrderSortField.channel:
          c = _cmp(a.channel.index, b.channel.index, asc);
          break;
        case OrderSortField.total:
          c = _cmp(a.total, b.total, asc);
          break;
        case OrderSortField.deliveredValue:
          c = _cmp(a.deliveredValue, b.deliveredValue, asc);
          break;
        case OrderSortField.undeliveredValue:
          c = _cmp(a.undeliveredValue, b.undeliveredValue, asc);
          break;
        case OrderSortField.paid:
          c = _cmp(a.paid, b.paid, asc);
          break;
        case OrderSortField.balance:
          c = _cmp(a.balance, b.balance, asc);
          break;
        case OrderSortField.cost:
          c = _cmp(a.cost, b.cost, asc);
          break;
        case OrderSortField.profit:
          c = _cmp(a.profit, b.profit, asc);
          break;
        case OrderSortField.margin:
          c = _cmp(a.margin, b.margin, asc);
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

  static OrderReportPage paginate(
    List<OrderReportRow> sorted,
    int requestedPage, {
    int pageSize = orderReportPageSize,
  }) {
    final total = sorted.length;
    final pages = total == 0 ? 1 : (total / pageSize).ceil();
    final page = requestedPage.clamp(1, pages);
    final start = (page - 1) * pageSize;
    final end = math.min(start + pageSize, total);
    return OrderReportPage(
      rows:
          total == 0
              ? <OrderReportRow>[]
              : sorted.sublist(start, end),
      totalCount: total,
      page: page,
      pageSize: pageSize,
      totalPages: pages,
      totals: OrderReportTotals.of(sorted),
    );
  }
}

enum OrderGroupSortField {
  name,
  count,
  total,
  deliveredValue,
  undeliveredValue,
  paid,
  balance,
}

/// Every order of one staff member, customer, channel, and so on.
class OrderReportGroupRow {
  /// The filter key: the row key, or [orderReportNoneKey].
  final String key;

  /// "No staff", "No customer", Unpaid and the like: always last.
  final bool isNone;
  final String _noneLabel;

  /// Most recent name in the group. Null when none was saved.
  String? name;

  int count = 0;
  double total = 0;
  double deliveredValue = 0;
  double undeliveredValue = 0;
  double paid = 0;
  double balance = 0;
  double? profit;

  /// A counted profit belongs to an order not Fully Delivered.
  bool profitIsEstimate = false;
  DateTime? lastOrderAt;

  OrderReportGroupRow({
    required this.key,
    required this.isNone,
    required this.name,
    String noneLabel = '',
  }) : _noneLabel = noneLabel;

  String get label => isNone ? _noneLabel : (name ?? 'Not Set');

  /// Same null rules as [OrderReportTotals.of].
  void add(OrderReportRow r) {
    count++;
    total += r.total;
    deliveredValue += r.deliveredValue ?? 0;
    undeliveredValue += r.undeliveredValue ?? 0;
    paid += r.paid;
    balance += r.balance;
    if (r.profit != null) {
      profit = (profit ?? 0) + r.profit!;
      if (r.profitIsEstimate) profitIsEstimate = true;
    }
    if (lastOrderAt == null || r.createdAt.isAfter(lastOrderAt!)) {
      lastOrderAt = r.createdAt;
    }
  }
}

class OrderReportGroupPage {
  final List<OrderReportGroupRow> rows;
  final int totalCount;
  final int page;
  final int pageSize;
  final int totalPages;

  /// Every group, not just this page.
  final OrderReportTotals totals;

  const OrderReportGroupPage({
    required this.rows,
    required this.totalCount,
    required this.page,
    required this.pageSize,
    required this.totalPages,
    required this.totals,
  });

  int get firstIndex =>
      totalCount == 0 ? 0 : (page - 1) * pageSize + 1;
  int get lastIndex =>
      totalCount == 0 ? 0 : (page - 1) * pageSize + rows.length;
}

class OrderReportGrouping {
  /// Groups [rows] by [keyOf]; a null key is the none group.
  /// Each group shows its most recent name.
  static List<OrderReportGroupRow> aggregate(
    List<OrderReportRow> rows, {
    required String? Function(OrderReportRow r) keyOf,
    required String? Function(OrderReportRow r) nameOf,
    required String noneLabel,
  }) {
    final newestFirst = List<OrderReportRow>.from(rows)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final groups = <String, OrderReportGroupRow>{};
    for (final r in newestFirst) {
      final key = keyOf(r);
      final name = nameOf(r);
      final k = key ?? orderReportNoneKey;
      final g = groups.putIfAbsent(
        k,
        () => OrderReportGroupRow(
          key: k,
          isNone: key == null,
          name: name,
          noneLabel: noneLabel,
        ),
      );
      // Newest first, so only fill a name the newer ones lacked.
      g.name ??= name;
      g.add(r);
    }
    return groups.values.toList();
  }

  /// Table "Group by". Channel's none group is Unpaid.
  static List<OrderReportGroupRow> build(
    List<OrderReportRow> rows,
    ReportGroupBy by,
  ) {
    switch (by) {
      case ReportGroupBy.off:
        return [];
      case ReportGroupBy.staff:
        return aggregate(
          rows,
          keyOf: (r) => r.staffKey,
          nameOf: (r) => r.staffName,
          noneLabel: orderNoStaffLabel,
        );
      case ReportGroupBy.customer:
        return aggregate(
          rows,
          keyOf: (r) => r.customerKey,
          nameOf: (r) => r.customerName,
          noneLabel: orderNoCustomerLabel,
        );
      case ReportGroupBy.channel:
        return aggregate(
          rows,
          keyOf:
              (r) =>
                  r.channel == OrderPaymentChannel.unpaid
                      ? null
                      : r.channel.name,
          nameOf: (r) => r.channel.label,
          noneLabel: OrderPaymentChannel.unpaid.label,
        );
    }
  }

  /// Sorted copy. The none row is always last; ties: label, then
  /// key.
  static List<OrderReportGroupRow> sort(
    List<OrderReportGroupRow> groups, {
    required OrderGroupSortField field,
    required bool ascending,
  }) {
    int compare(OrderReportGroupRow a, OrderReportGroupRow b) {
      if (a.isNone != b.isNone) return a.isNone ? 1 : -1;
      int c;
      switch (field) {
        case OrderGroupSortField.name:
          c = a.label.toLowerCase().compareTo(
            b.label.toLowerCase(),
          );
          break;
        case OrderGroupSortField.count:
          c = a.count.compareTo(b.count);
          break;
        case OrderGroupSortField.total:
          c = a.total.compareTo(b.total);
          break;
        case OrderGroupSortField.deliveredValue:
          c = a.deliveredValue.compareTo(b.deliveredValue);
          break;
        case OrderGroupSortField.undeliveredValue:
          c = a.undeliveredValue.compareTo(b.undeliveredValue);
          break;
        case OrderGroupSortField.paid:
          c = a.paid.compareTo(b.paid);
          break;
        case OrderGroupSortField.balance:
          c = a.balance.compareTo(b.balance);
          break;
      }
      if (!ascending) c = -c;
      if (c != 0) return c;
      final n = a.label.toLowerCase().compareTo(
        b.label.toLowerCase(),
      );
      return n != 0 ? n : a.key.compareTo(b.key);
    }

    return List<OrderReportGroupRow>.from(groups)..sort(compare);
  }

  /// [rows] are the filtered rows the groups were built from, so
  /// the totals match the ungrouped table.
  static OrderReportGroupPage paginate(
    List<OrderReportGroupRow> sorted,
    List<OrderReportRow> rows,
    int requestedPage, {
    int pageSize = orderReportPageSize,
  }) {
    final total = sorted.length;
    final pages = total == 0 ? 1 : (total / pageSize).ceil();
    final page = requestedPage.clamp(1, pages);
    final start = (page - 1) * pageSize;
    final end = math.min(start + pageSize, total);
    return OrderReportGroupPage(
      rows:
          total == 0
              ? <OrderReportGroupRow>[]
              : sorted.sublist(start, end),
      totalCount: total,
      page: page,
      pageSize: pageSize,
      totalPages: pages,
      totals: OrderReportTotals.of(rows),
    );
  }
}
