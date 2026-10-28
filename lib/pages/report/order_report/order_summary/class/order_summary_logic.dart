import 'package:flutter/material.dart';
import 'package:stockall/pages/report/components/report_group_by.dart';
import 'package:stockall/pages/report/order_report/order_report_table/class/order_report_table_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

/// Breakdown tables of the analysis page. Each row opens the
/// table with the matching filter.
enum OrderSummaryDimension {
  customer,
  staff,
  department,
  subStaff,
  channel,
}

class OrderSummaryStats {
  final int orderCount;
  final double totalValue;
  final double deliveredValue;
  final double undeliveredValue;
  final double paid;
  final double balance;
  final int fullyDelivered;
  final int partiallyDelivered;
  final int undelivered;

  /// Orders whose delivery status could not be worked out.
  final int unavailable;

  /// Orders whose stored and receipt quantities disagree.
  final int recordsDisagree;

  /// Null when no order has a cost.
  final double? cost;

  /// Estimated while any counted order is not Fully Delivered.
  final double? profit;
  final bool profitIsEstimate;
  final double? margin;

  final double orderedItems;
  final double deliveredItems;
  final int customers;
  final int staff;

  const OrderSummaryStats({
    required this.orderCount,
    required this.totalValue,
    required this.deliveredValue,
    required this.undeliveredValue,
    required this.paid,
    required this.balance,
    required this.fullyDelivered,
    required this.partiallyDelivered,
    required this.undelivered,
    required this.unavailable,
    required this.recordsDisagree,
    required this.cost,
    required this.profit,
    required this.profitIsEstimate,
    required this.margin,
    required this.orderedItems,
    required this.deliveredItems,
    required this.customers,
    required this.staff,
  });
}

/// One delivery status. Every status is listed, even at 0.
class OrderStatusSummary {
  final OrderDeliveryStatus status;
  final int count;
  final double total;
  final double deliveredValue;
  final double undeliveredValue;
  final double paid;
  final double balance;

  const OrderStatusSummary({
    required this.status,
    required this.count,
    required this.total,
    required this.deliveredValue,
    required this.undeliveredValue,
    required this.paid,
    required this.balance,
  });
}

class OrderSummaryResult {
  final OrderSummaryStats stats;

  /// The orders counted: the same rows the table shows for the
  /// same period and filters.
  final List<OrderReportRow> rows;
  final List<OrderStatusSummary> statusSummaries;

  /// Largest total first; the none row is always last.
  final List<OrderReportGroupRow> customers;
  final List<OrderReportGroupRow> staff;

  /// Empty when departments are off.
  final List<OrderReportGroupRow> departments;

  /// Empty when bulk sale is off.
  final List<OrderReportGroupRow> subStaff;
  final List<OrderReportGroupRow> channels;

  /// Customers with the most undelivered value, at most 5. The
  /// "No customer" group is left out.
  final List<OrderReportGroupRow> topUndeliveredCustomers;

  const OrderSummaryResult({
    required this.stats,
    required this.rows,
    required this.statusSummaries,
    required this.customers,
    required this.staff,
    required this.departments,
    required this.subStaff,
    required this.channels,
    required this.topUndeliveredCustomers,
  });
}

class OrderSummaryBuilder {
  static const int topCustomersCount = 5;

  /// [rows] are already scoped (`OrderReportScope`) and built.
  static OrderSummaryResult build({
    required List<OrderReportRow> rows,
    required ReceiptsReportPeriod period,
    OrderReportFilters? filters,
    required bool departmentsEnabled,
    required bool subStaffEnabled,
    required bool profitVisible,
    TimeOfDay? closingTime,
  }) {
    final counted = OrderReportQuery.filterAndSort(
      rows: rows,
      period: period,
      filters: filters ?? OrderReportFilters(),
      sortField: OrderSortField.createdAt,
      ascending: false,
      departmentsEnabled: departmentsEnabled,
      subStaffEnabled: subStaffEnabled,
      profitVisible: profitVisible,
      closingTime: closingTime,
    );

    final totals = OrderReportTotals.of(counted);
    int full = 0;
    int partial = 0;
    int undelivered = 0;
    int unavailable = 0;
    int disagree = 0;
    bool estimate = false;
    double profitBase = 0;
    double orderedItems = 0;
    double deliveredItems = 0;
    final customers = <String>{};
    final staff = <String>{};
    for (final r in counted) {
      switch (r.status) {
        case OrderDeliveryStatus.full:
          full++;
          break;
        case OrderDeliveryStatus.partial:
          partial++;
          break;
        case OrderDeliveryStatus.undelivered:
          undelivered++;
          break;
        case null:
          unavailable++;
          break;
      }
      if (r.recordsDisagree) disagree++;
      if (r.profit != null) {
        profitBase += r.total;
        if (r.profitIsEstimate) estimate = true;
      }
      orderedItems += r.delivery.orderedItems ?? 0;
      deliveredItems += r.delivery.deliveredItems ?? 0;
      if (r.customerKey != null) customers.add(r.customerKey!);
      if (r.staffKey != null) staff.add(r.staffKey!);
    }

    final stats = OrderSummaryStats(
      orderCount: totals.count,
      totalValue: totals.total,
      deliveredValue: totals.deliveredValue,
      undeliveredValue: totals.undeliveredValue,
      paid: totals.paid,
      balance: totals.balance,
      fullyDelivered: full,
      partiallyDelivered: partial,
      undelivered: undelivered,
      unavailable: unavailable,
      recordsDisagree: disagree,
      cost: totals.cost,
      profit: totals.profit,
      profitIsEstimate: estimate,
      margin:
          (totals.profit != null && profitBase > 0)
              ? (totals.profit! / profitBase) * 100
              : null,
      orderedItems: orderedItems,
      deliveredItems: deliveredItems,
      customers: customers.length,
      staff: staff.length,
    );

    final statusSummaries = [
      for (final s in OrderDeliveryStatus.values)
        _statusSummary(
          s,
          counted.where((r) => r.status == s).toList(),
        ),
    ];

    List<OrderReportGroupRow> byTotal(
      List<OrderReportGroupRow> groups,
    ) => OrderReportGrouping.sort(
      groups,
      field: OrderGroupSortField.total,
      ascending: false,
    );

    final customerGroups = byTotal(
      group(counted, OrderSummaryDimension.customer),
    );

    final topUndelivered =
        customerGroups
            .where((g) => !g.isNone && g.undeliveredValue > 0)
            .toList()
          ..sort((a, b) {
            final c = b.undeliveredValue.compareTo(
              a.undeliveredValue,
            );
            if (c != 0) return c;
            final n = a.label.toLowerCase().compareTo(
              b.label.toLowerCase(),
            );
            return n != 0 ? n : a.key.compareTo(b.key);
          });

    return OrderSummaryResult(
      stats: stats,
      rows: counted,
      statusSummaries: statusSummaries,
      customers: customerGroups,
      staff: byTotal(group(counted, OrderSummaryDimension.staff)),
      departments:
          departmentsEnabled
              ? byTotal(
                group(counted, OrderSummaryDimension.department),
              )
              : const [],
      subStaff:
          subStaffEnabled
              ? byTotal(
                group(counted, OrderSummaryDimension.subStaff),
              )
              : const [],
      channels: byTotal(
        group(counted, OrderSummaryDimension.channel),
      ),
      topUndeliveredCustomers:
          topUndelivered.take(topCustomersCount).toList(),
    );
  }

  static List<OrderReportGroupRow> group(
    List<OrderReportRow> rows,
    OrderSummaryDimension dimension,
  ) {
    switch (dimension) {
      case OrderSummaryDimension.customer:
        return OrderReportGrouping.aggregate(
          rows,
          keyOf: (r) => r.customerKey,
          nameOf: (r) => r.customerName,
          noneLabel: orderNoCustomerLabel,
        );
      case OrderSummaryDimension.staff:
        return OrderReportGrouping.aggregate(
          rows,
          keyOf: (r) => r.staffKey,
          nameOf: (r) => r.staffName,
          noneLabel: orderNoStaffLabel,
        );
      case OrderSummaryDimension.department:
        return OrderReportGrouping.aggregate(
          rows,
          keyOf: (r) => r.departmentKey,
          nameOf: (r) => r.departmentName,
          noneLabel: orderNoDepartmentLabel,
        );
      case OrderSummaryDimension.subStaff:
        return OrderReportGrouping.aggregate(
          rows,
          keyOf: (r) => r.subStaffKey,
          nameOf: (r) => r.subStaffName,
          noneLabel: orderNoSubStaffLabel,
        );
      case OrderSummaryDimension.channel:
        return OrderReportGrouping.build(
          rows,
          ReportGroupBy.channel,
        );
    }
  }

  static OrderStatusSummary _statusSummary(
    OrderDeliveryStatus status,
    List<OrderReportRow> rows,
  ) {
    final t = OrderReportTotals.of(rows);
    return OrderStatusSummary(
      status: status,
      count: t.count,
      total: t.total,
      deliveredValue: t.deliveredValue,
      undeliveredValue: t.undeliveredValue,
      paid: t.paid,
      balance: t.balance,
    );
  }

  /// Filters for the table opened from a breakdown row: the
  /// analysis filters plus the row's key.
  static OrderReportFilters filtersForGroup({
    required OrderReportFilters base,
    required OrderSummaryDimension dimension,
    required OrderReportGroupRow group,
  }) {
    final f = base.copy();
    switch (dimension) {
      case OrderSummaryDimension.customer:
        f.customerKey = group.key;
        break;
      case OrderSummaryDimension.staff:
        f.staffKey = group.key;
        break;
      case OrderSummaryDimension.department:
        f.departmentKey = group.key;
        break;
      case OrderSummaryDimension.subStaff:
        f.subStaffKey = group.key;
        break;
      case OrderSummaryDimension.channel:
        f.channel =
            group.isNone
                ? OrderPaymentChannel.unpaid
                : OrderPaymentChannel.values.byName(group.key);
        break;
    }
    return f;
  }

  static OrderReportFilters filtersForStatus({
    required OrderReportFilters base,
    required OrderDeliveryStatus status,
  }) => base.copy()..deliveryStatus = status;

  static OrderReportFilters filtersForRecordsDisagree({
    required OrderReportFilters base,
  }) => base.copy()..recordsDisagree = true;
}
