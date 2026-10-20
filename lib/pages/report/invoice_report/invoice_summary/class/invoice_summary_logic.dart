import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_main_receipt/temp_main_receipt.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/pages/report/invoice_report/invoice_report_table/class/invoice_report_table_logic.dart';

/// Predefined reporting periods matching Stockall conventions.
enum InvoiceSummaryPeriod {
  today,
  thisWeek,
  thisMonth,
  allTime,
  custom,
}

extension InvoiceSummaryPeriodExt on InvoiceSummaryPeriod {
  String get label {
    switch (this) {
      case InvoiceSummaryPeriod.today:
        return 'Today';
      case InvoiceSummaryPeriod.thisWeek:
        return 'This Week';
      case InvoiceSummaryPeriod.thisMonth:
        return 'This Month';
      case InvoiceSummaryPeriod.allTime:
        return 'All Time';
      case InvoiceSummaryPeriod.custom:
        return 'Custom Range';
    }
  }
}

/// Filter criteria container for the Invoice Summary page.
class InvoiceSummaryFilters {
  String? staffId;
  String? customerUuid;
  String? departmentKey;
  String? subStaffUuid;
  InvoicePaymentChannelFilter paymentChannel =
      InvoicePaymentChannelFilter.all;
  InvoicePaymentStatusFilter paymentStatus =
      InvoicePaymentStatusFilter.all;

  InvoiceSummaryFilters({
    this.staffId,
    this.customerUuid,
    this.departmentKey,
    this.subStaffUuid,
    this.paymentChannel = InvoicePaymentChannelFilter.all,
    this.paymentStatus = InvoicePaymentStatusFilter.all,
  });

  bool get hasAnything =>
      staffId != null ||
      customerUuid != null ||
      departmentKey != null ||
      subStaffUuid != null ||
      paymentChannel != InvoicePaymentChannelFilter.all ||
      paymentStatus != InvoicePaymentStatusFilter.all;

  int get activeCount {
    int c = 0;
    if (staffId != null) c++;
    if (customerUuid != null) c++;
    if (departmentKey != null) c++;
    if (subStaffUuid != null) c++;
    if (paymentChannel != InvoicePaymentChannelFilter.all)
      c++;
    if (paymentStatus != InvoicePaymentStatusFilter.all)
      c++;
    return c;
  }

  void clearAll() {
    staffId = null;
    customerUuid = null;
    departmentKey = null;
    subStaffUuid = null;
    paymentChannel = InvoicePaymentChannelFilter.all;
    paymentStatus = InvoicePaymentStatusFilter.all;
  }
}

/// 4.2 Summary Statistics container.
class InvoiceSummaryStats {
  final int totalInvoices;
  final double totalInvoiceValue;
  final double totalAmountPaid;
  final double totalOutstandingBalance;
  final int fullyPaidInvoices;
  final int partiallyPaidInvoices;
  final int unpaidInvoices;
  final int unresolvedInvoices;
  final double averageInvoiceValue;
  final double totalDiscounts;
  final double totalVat;
  final double? totalCost;
  final double? totalProfitLoss;
  final double? averageProfitMargin;
  final double totalItemsInvoiced;
  final int totalCustomers;
  final int totalStaffInvolved;
  final int cashPaymentTransactions;
  final int bankPaymentTransactions;
  final int splitPaymentTransactions;
  final double totalCollectionsInPeriod;
  final int totalPaymentReceiptsInPeriod;

  const InvoiceSummaryStats({
    required this.totalInvoices,
    required this.totalInvoiceValue,
    required this.totalAmountPaid,
    required this.totalOutstandingBalance,
    required this.fullyPaidInvoices,
    required this.partiallyPaidInvoices,
    required this.unpaidInvoices,
    required this.unresolvedInvoices,
    required this.averageInvoiceValue,
    required this.totalDiscounts,
    required this.totalVat,
    required this.totalCost,
    required this.totalProfitLoss,
    required this.averageProfitMargin,
    required this.totalItemsInvoiced,
    required this.totalCustomers,
    required this.totalStaffInvolved,
    required this.cashPaymentTransactions,
    required this.bankPaymentTransactions,
    required this.splitPaymentTransactions,
    required this.totalCollectionsInPeriod,
    required this.totalPaymentReceiptsInPeriod,
  });

  static const empty = InvoiceSummaryStats(
    totalInvoices: 0,
    totalInvoiceValue: 0,
    totalAmountPaid: 0,
    totalOutstandingBalance: 0,
    fullyPaidInvoices: 0,
    partiallyPaidInvoices: 0,
    unpaidInvoices: 0,
    unresolvedInvoices: 0,
    averageInvoiceValue: 0,
    totalDiscounts: 0,
    totalVat: 0,
    totalCost: null,
    totalProfitLoss: null,
    averageProfitMargin: null,
    totalItemsInvoiced: 0,
    totalCustomers: 0,
    totalStaffInvolved: 0,
    cashPaymentTransactions: 0,
    bankPaymentTransactions: 0,
    splitPaymentTransactions: 0,
    totalCollectionsInPeriod: 0,
    totalPaymentReceiptsInPeriod: 0,
  );
}

/// Represents an aggregated customer record for Section 4.3, 4.4, & 4.7.
class CustomerInvoiceSummary {
  final String customerKey;
  final String? customerUuid;
  final String customerName;
  final int invoiceCount;
  final double totalInvoiceValue;
  final double amountPaid;
  final double outstandingBalance;
  final double? totalProfit;
  final double averageInvoiceValue;
  final DateTime? lastInvoiceDate;
  final DateTime? lastPaymentDate;

  CustomerInvoiceSummary({
    required this.customerKey,
    required this.customerUuid,
    required this.customerName,
    required this.invoiceCount,
    required this.totalInvoiceValue,
    required this.amountPaid,
    required this.outstandingBalance,
    required this.totalProfit,
    required this.averageInvoiceValue,
    required this.lastInvoiceDate,
    required this.lastPaymentDate,
  });
}

/// Represents an aggregated staff record for Section 4.5 & 4.8.
class StaffInvoiceSummary {
  final String staffId;
  final String staffName;
  final int invoiceCount;
  final double totalInvoiceValue;
  final double amountPaid;
  final double outstandingBalance;
  final double? totalProfit;
  final double averageInvoiceValue;
  final double percentageOfTotalValue;

  StaffInvoiceSummary({
    required this.staffId,
    required this.staffName,
    required this.invoiceCount,
    required this.totalInvoiceValue,
    required this.amountPaid,
    required this.outstandingBalance,
    required this.totalProfit,
    required this.averageInvoiceValue,
    required this.percentageOfTotalValue,
  });
}

/// Represents an aggregated department record for Section 4.6.
class DepartmentInvoiceSummary {
  final String? departmentKey;
  final String departmentName;
  final int invoiceCount;
  final double totalInvoiceValue;
  final double amountPaid;
  final double outstandingBalance;
  final double? totalProfit;
  final double averageInvoiceValue;
  final double percentageOfInvoiceValue;

  DepartmentInvoiceSummary({
    required this.departmentKey,
    required this.departmentName,
    required this.invoiceCount,
    required this.totalInvoiceValue,
    required this.amountPaid,
    required this.outstandingBalance,
    required this.totalProfit,
    required this.averageInvoiceValue,
    required this.percentageOfInvoiceValue,
  });
}

/// Represents an aggregated sub-staff record for Section 4.14.
class SubStaffInvoiceSummary {
  final String? subStaffUuid;
  final String subStaffName;
  final int invoiceCount;
  final double totalInvoiceValue;
  final double amountPaid;
  final double outstandingBalance;
  final double? totalProfit;

  SubStaffInvoiceSummary({
    required this.subStaffUuid,
    required this.subStaffName,
    required this.invoiceCount,
    required this.totalInvoiceValue,
    required this.amountPaid,
    required this.outstandingBalance,
    required this.totalProfit,
  });
}

/// Represents a payment channel collection line for Section 4.9.
class PaymentChannelCollectionSummary {
  final String channelName;
  final int transactionCount;
  final double amountCollected;
  final double percentageOfTransactions;
  final double percentageOfAmount;

  PaymentChannelCollectionSummary({
    required this.channelName,
    required this.transactionCount,
    required this.amountCollected,
    required this.percentageOfTransactions,
    required this.percentageOfAmount,
  });
}

/// Represents an invoice payment status line for Section 4.10.
class InvoicePaymentStatusSummary {
  final String statusName;
  final int statusCode;
  final int invoiceCount;
  final double totalInvoiceValue;
  final double amountPaid;
  final double outstandingBalance;
  final double percentageOfInvoices;

  InvoicePaymentStatusSummary({
    required this.statusName,
    required this.statusCode,
    required this.invoiceCount,
    required this.totalInvoiceValue,
    required this.amountPaid,
    required this.outstandingBalance,
    required this.percentageOfInvoices,
  });
}

/// Represents an activity line for Section 4.11.
class InvoiceActivitySummaryRow {
  final String activityType;
  final int activityCount;
  final double? invoiceValue;
  final double? amountCollected;
  final double? outstandingBalance;

  InvoiceActivitySummaryRow({
    required this.activityType,
    required this.activityCount,
    required this.invoiceValue,
    required this.amountCollected,
    required this.outstandingBalance,
  });
}

/// Trend data point for Section 4.12 & 4.13.
class InvoiceTrendPoint {
  final DateTime date;
  final String label;
  final double invoiceValue;
  final double amountCollected;
  final double outstandingBalance;
  final double? profit;
  final int invoicesCreated;
  final int fullyPaidCount;
  final int partiallyPaidCount;
  final int unpaidCount;

  InvoiceTrendPoint({
    required this.date,
    required this.label,
    required this.invoiceValue,
    required this.amountCollected,
    required this.outstandingBalance,
    required this.profit,
    required this.invoicesCreated,
    required this.fullyPaidCount,
    required this.partiallyPaidCount,
    required this.unpaidCount,
  });
}

/// Container for all computed results for the Invoice Summary page.
class InvoiceSummaryResult {
  final InvoiceSummaryStats stats;
  final List<InvoiceReportRow> qualifyingRows;
  final List<CustomerInvoiceSummary> top3Customers;
  final List<CustomerInvoiceSummary> least3Customers;
  final List<CustomerInvoiceSummary> topCreditors;
  final List<CustomerInvoiceSummary> leastCreditors;
  final List<CustomerInvoiceSummary> allCustomerSummaries;
  final List<StaffInvoiceSummary> top3Staff;
  final List<StaffInvoiceSummary> allStaffSummaries;
  final List<DepartmentInvoiceSummary> departmentSummaries;
  final List<SubStaffInvoiceSummary> subStaffSummaries;
  final List<PaymentChannelCollectionSummary>
  paymentChannelSummaries;
  final List<InvoicePaymentStatusSummary> statusSummaries;
  final List<InvoiceActivitySummaryRow> activitySummaries;
  final List<InvoiceTrendPoint> trends;

  const InvoiceSummaryResult({
    required this.stats,
    required this.qualifyingRows,
    required this.top3Customers,
    required this.least3Customers,
    required this.topCreditors,
    required this.leastCreditors,
    required this.allCustomerSummaries,
    required this.top3Staff,
    required this.allStaffSummaries,
    required this.departmentSummaries,
    required this.subStaffSummaries,
    required this.paymentChannelSummaries,
    required this.statusSummaries,
    required this.activitySummaries,
    required this.trends,
  });

  static const empty = InvoiceSummaryResult(
    stats: InvoiceSummaryStats.empty,
    qualifyingRows: [],
    top3Customers: [],
    least3Customers: [],
    topCreditors: [],
    leastCreditors: [],
    allCustomerSummaries: [],
    top3Staff: [],
    allStaffSummaries: [],
    departmentSummaries: [],
    subStaffSummaries: [],
    paymentChannelSummaries: [],
    statusSummaries: [],
    activitySummaries: [],
    trends: [],
  );
}

/// Calculation engine for Invoice Summary and Analysis.
class InvoiceSummaryBuilder {
  /// Date range cutoff resolver adhering to Stockall business-day boundaries.
  static DateTimeRange resolveDateRange({
    required InvoiceSummaryPeriod period,
    required DateTime businessNow,
    DateTimeRange? customRange,
  }) {
    final today = DateTime(
      businessNow.year,
      businessNow.month,
      businessNow.day,
    );
    switch (period) {
      case InvoiceSummaryPeriod.today:
        return DateTimeRange(start: today, end: today);
      case InvoiceSummaryPeriod.thisWeek:
        final weekday = today.weekday;
        final startOfWeek = today.subtract(
          Duration(days: weekday - 1),
        );
        return DateTimeRange(
          start: startOfWeek,
          end: today,
        );
      case InvoiceSummaryPeriod.thisMonth:
        final startOfMonth = DateTime(
          today.year,
          today.month,
          1,
        );
        return DateTimeRange(
          start: startOfMonth,
          end: today,
        );
      case InvoiceSummaryPeriod.allTime:
        final distantPast = DateTime(2000, 1, 1);
        return DateTimeRange(
          start: distantPast,
          end: today,
        );
      case InvoiceSummaryPeriod.custom:
        if (customRange != null) return customRange;
        return DateTimeRange(start: today, end: today);
    }
  }

  /// Builds all aggregated summaries, rankings, trends, and statistics.
  static InvoiceSummaryResult build({
    required List<InvoiceReportRow> allRows,
    required List<TempMainReceipt> allReceipts,
    required InvoiceSummaryPeriod period,
    required DateTime businessNow,
    DateTimeRange? customRange,
    InvoiceSummaryFilters? filters,
    required bool departmentsEnabled,
    required bool bulkSaleEnabled,
  }) {
    final range = resolveDateRange(
      period: period,
      businessNow: businessNow,
      customRange: customRange,
    );

    final bool isAllTime =
        period == InvoiceSummaryPeriod.allTime;
    final DateTime startCutoff = fourAm(range.start);
    final DateTime endCutoff = fourAmNextDay(range.end);

    final activeFilters =
        filters ?? InvoiceSummaryFilters();

    // 1. Filter qualifying invoices (attributed to creation date & active filters)
    final List<InvoiceReportRow> qualifyingRows = [];
    for (final row in allRows) {
      // Date cutoff check (business day)
      if (!isAllTime) {
        final created = row.createdAt.toLocal();
        if (created.isBefore(startCutoff) ||
            created.isAfter(endCutoff)) {
          continue;
        }
      }

      // Filter by Staff
      if (activeFilters.staffId != null &&
          activeFilters.staffId!.isNotEmpty) {
        if (row.invoice.staffId != activeFilters.staffId) {
          continue;
        }
      }

      // Filter by Customer
      if (activeFilters.customerUuid != null &&
          activeFilters.customerUuid!.isNotEmpty) {
        if (row.invoice.customerUuid !=
            activeFilters.customerUuid) {
          continue;
        }
      }

      // Filter by Department (when enabled)
      if (departmentsEnabled &&
          activeFilters.departmentKey != null &&
          activeFilters.departmentKey!.isNotEmpty) {
        if (activeFilters.departmentKey ==
            invoiceReportNoDepartmentKey) {
          if (row.departmentKey != null &&
              row.departmentKey!.isNotEmpty) {
            continue;
          }
        } else {
          if (row.departmentKey !=
              activeFilters.departmentKey) {
            continue;
          }
        }
      }

      // Filter by Sub-Staff (when bulk sale enabled)
      if (bulkSaleEnabled &&
          activeFilters.subStaffUuid != null &&
          activeFilters.subStaffUuid!.isNotEmpty) {
        if (row.invoice.subStaffUuid !=
            activeFilters.subStaffUuid) {
          continue;
        }
      }

      // Filter by Payment Channel
      if (activeFilters.paymentChannel !=
          InvoicePaymentChannelFilter.all) {
        switch (activeFilters.paymentChannel) {
          case InvoicePaymentChannelFilter.cash:
            if (row.paymentChannel != 'Cash') continue;
            break;
          case InvoicePaymentChannelFilter.bank:
            if (row.paymentChannel != 'Bank') continue;
            break;
          case InvoicePaymentChannelFilter.split:
            if (row.paymentChannel != 'Split') continue;
            break;
          case InvoicePaymentChannelFilter.unpaid:
            if (row.paymentChannel != 'Unpaid') continue;
            break;
          case InvoicePaymentChannelFilter.all:
            break;
        }
      }

      // Filter by Payment Status
      if (activeFilters.paymentStatus !=
          InvoicePaymentStatusFilter.all) {
        switch (activeFilters.paymentStatus) {
          case InvoicePaymentStatusFilter.unpaid:
            if (row.status != 0) continue;
            break;
          case InvoicePaymentStatusFilter.partial:
            if (row.status != 1) continue;
            break;
          case InvoicePaymentStatusFilter.paid:
            if (row.status != 2) continue;
            break;
          case InvoicePaymentStatusFilter.all:
            break;
        }
      }

      qualifyingRows.add(row);
    }

    // Set of qualifying invoice UUIDs for payment cross-referencing
    final Set<String> qualifyingInvoiceUuids = {
      for (final r in qualifyingRows)
        if (r.uuid.isNotEmpty) r.uuid,
    };

    // 2. Identify qualifying payment receipts (attributed to actual payment receipt date)
    // Map of invoiceUuid -> list of receipts for quick payment date resolution
    final Map<String, List<TempMainReceipt>>
    invoiceReceiptsMap = {};
    final List<TempMainReceipt> qualifyingPeriodReceipts =
        [];

    for (final rec in allReceipts) {
      final invUuid = rec.invoiceUuid;
      if (invUuid != null && invUuid.isNotEmpty) {
        (invoiceReceiptsMap[invUuid] ??= []).add(rec);

        // Check if receipt falls within reporting period
        bool dateMatches = true;
        if (!isAllTime) {
          final pDate = rec.createdAt.toLocal();
          if (pDate.isBefore(startCutoff) ||
              pDate.isAfter(endCutoff)) {
            dateMatches = false;
          }
        }

        if (dateMatches) {
          // If invoice filters are active, only include receipt if it belongs to qualifying invoices
          if (activeFilters.hasAnything) {
            if (qualifyingInvoiceUuids.contains(invUuid)) {
              qualifyingPeriodReceipts.add(rec);
            }
          } else {
            qualifyingPeriodReceipts.add(rec);
          }
        }
      }
    }

    // 3. Compute Headline Summary Statistics (4.2 & 4.2.1)
    int totalInvoices = qualifyingRows.length;
    double totalInvoiceValue = 0;
    double totalAmountPaid = 0;
    double totalOutstandingBalance = 0;
    int fullyPaidInvoices = 0;
    int partiallyPaidInvoices = 0;
    int unpaidInvoices = 0;
    int unresolvedInvoices = 0;
    double totalDiscounts = 0;
    double totalVat = 0;
    double sumCost = 0;
    bool hasAnyCost = false;
    double sumProfit = 0;
    bool hasAnyProfit = false;
    double totalNetRevenueForMargin = 0;
    double totalItemsInvoiced = 0;

    int cashPaymentTransactions = 0;
    int bankPaymentTransactions = 0;
    int splitPaymentTransactions = 0;

    int reliableTotalCount = 0;
    final Set<String> distinctCustomerKeys = {};
    final Set<String> distinctStaffKeys = {};

    for (final row in qualifyingRows) {
      if (row.invoiceTotal != null) {
        totalInvoiceValue += row.invoiceTotal!;
        reliableTotalCount++;
        final double netRev =
            row.invoiceTotal! - row.vatAmount;
        if (netRev > 0) {
          totalNetRevenueForMargin += netRev;
        }
      }
      totalAmountPaid += row.amountPaid;
      if (row.balance != null) {
        totalOutstandingBalance += row.balance!;
      }

      switch (row.status) {
        case 2:
          fullyPaidInvoices++;
          break;
        case 1:
          partiallyPaidInvoices++;
          break;
        case 0:
          unpaidInvoices++;
          break;
        default:
          unresolvedInvoices++;
          break;
      }

      totalDiscounts += row.discountAmount;
      totalVat += row.vatAmount;

      if (row.cost != null) {
        sumCost += row.cost!;
        hasAnyCost = true;
      }
      if (row.profit != null) {
        sumProfit += row.profit!;
        hasAnyProfit = true;
      }
      if (row.totalItems != null) {
        totalItemsInvoiced += row.totalItems!;
      }

      // Payment channel breakdown on invoice population
      switch (row.paymentChannel) {
        case 'Cash':
          cashPaymentTransactions++;
          break;
        case 'Bank':
          bankPaymentTransactions++;
          break;
        case 'Split':
          splitPaymentTransactions++;
          break;
      }

      // Distinct customers: use UUID if present; if null/walk-in, keep separate
      final custUuid = row.invoice.customerUuid;
      if (custUuid != null && custUuid.isNotEmpty) {
        distinctCustomerKeys.add('uuid:$custUuid');
      } else if (row.customerName != 'Walk-in Customer' &&
          row.customerName.isNotEmpty &&
          row.customerName != '—') {
        distinctCustomerKeys.add(
          'name:${row.customerName}',
        );
      } else {
        // Individual unregistered walk-in
        distinctCustomerKeys.add('walkin:${row.displayId}');
      }

      // Distinct staff
      final sId = row.invoice.staffId;
      if (sId.isNotEmpty) {
        distinctStaffKeys.add('id:$sId');
      } else if (row.staffName.isNotEmpty &&
          row.staffName != '—') {
        distinctStaffKeys.add('name:${row.staffName}');
      }
    }

    final double averageInvoiceValue =
        reliableTotalCount > 0
            ? totalInvoiceValue / reliableTotalCount
            : 0;

    final double? totalCost = hasAnyCost ? sumCost : null;
    final double? totalProfitLoss =
        hasAnyProfit ? sumProfit : null;
    final double? averageProfitMargin =
        (totalProfitLoss != null &&
                totalNetRevenueForMargin > 0)
            ? (totalProfitLoss / totalNetRevenueForMargin) *
                100
            : null;

    // Actual Collections in Period (4.9.2)
    double totalCollectionsInPeriod = 0;
    for (final rec in qualifyingPeriodReceipts) {
      totalCollectionsInPeriod +=
          (rec.bank +
              rec.cashAlt +
              (rec.customerAccount ?? 0));
    }

    final stats = InvoiceSummaryStats(
      totalInvoices: totalInvoices,
      totalInvoiceValue: totalInvoiceValue,
      totalAmountPaid: totalAmountPaid,
      totalOutstandingBalance: totalOutstandingBalance,
      fullyPaidInvoices: fullyPaidInvoices,
      partiallyPaidInvoices: partiallyPaidInvoices,
      unpaidInvoices: unpaidInvoices,
      unresolvedInvoices: unresolvedInvoices,
      averageInvoiceValue: averageInvoiceValue,
      totalDiscounts: totalDiscounts,
      totalVat: totalVat,
      totalCost: totalCost,
      totalProfitLoss: totalProfitLoss,
      averageProfitMargin: averageProfitMargin,
      totalItemsInvoiced: totalItemsInvoiced,
      totalCustomers: distinctCustomerKeys.length,
      totalStaffInvolved: distinctStaffKeys.length,
      cashPaymentTransactions: cashPaymentTransactions,
      bankPaymentTransactions: bankPaymentTransactions,
      splitPaymentTransactions: splitPaymentTransactions,
      totalCollectionsInPeriod: totalCollectionsInPeriod,
      totalPaymentReceiptsInPeriod:
          qualifyingPeriodReceipts.length,
    );

    // 4. Customer Aggregation (4.3, 4.4, & 4.7)
    final Map<String, List<InvoiceReportRow>>
    customerGroups = {};
    for (final row in qualifyingRows) {
      final custUuid = row.invoice.customerUuid;
      final String groupKey;
      if (custUuid != null && custUuid.isNotEmpty) {
        groupKey = 'uuid:$custUuid';
      } else if (row.customerName != 'Walk-in Customer' &&
          row.customerName.isNotEmpty &&
          row.customerName != '—') {
        groupKey = 'name:${row.customerName}';
      } else {
        // Handle anonymous unregistered transactions separately per Section 4.3.1
        groupKey = 'walkin:${row.displayId}';
      }
      (customerGroups[groupKey] ??= []).add(row);
    }

    final List<CustomerInvoiceSummary>
    allCustomerSummaries = [];
    customerGroups.forEach((key, rows) {
      final first = rows.first;
      final String displayName =
          key.startsWith('walkin:')
              ? 'Walk-in (${first.displayId})'
              : first.customerName;

      int invCount = rows.length;
      double invValue = 0;
      double amtPaid = 0;
      double bal = 0;
      double sumCustProfit = 0;
      bool hasCustProfit = false;
      int countWithTotal = 0;
      DateTime? latestInvDate;

      final Set<String> rowUuids = {};

      for (final r in rows) {
        if (r.invoiceTotal != null) {
          invValue += r.invoiceTotal!;
          countWithTotal++;
        }
        amtPaid += r.amountPaid;
        if (r.balance != null) bal += r.balance!;
        if (r.profit != null) {
          sumCustProfit += r.profit!;
          hasCustProfit = true;
        }
        if (latestInvDate == null ||
            r.createdAt.isAfter(latestInvDate)) {
          latestInvDate = r.createdAt;
        }
        if (r.uuid.isNotEmpty) rowUuids.add(r.uuid);
      }

      // Calculate last payment date from actual payment receipts (4.7)
      DateTime? latestPaymentDate;
      for (final u in rowUuids) {
        final recs = invoiceReceiptsMap[u];
        if (recs != null) {
          for (final rec in recs) {
            final pDate = rec.createdAt;
            if (latestPaymentDate == null ||
                pDate.isAfter(latestPaymentDate)) {
              latestPaymentDate = pDate;
            }
          }
        }
      }

      final double avgValue =
          countWithTotal > 0
              ? invValue / countWithTotal
              : 0;

      allCustomerSummaries.add(
        CustomerInvoiceSummary(
          customerKey: key,
          customerUuid: first.invoice.customerUuid,
          customerName: displayName,
          invoiceCount: invCount,
          totalInvoiceValue: invValue,
          amountPaid: amtPaid,
          outstandingBalance: bal,
          totalProfit: hasCustProfit ? sumCustProfit : null,
          averageInvoiceValue: avgValue,
          lastInvoiceDate: latestInvDate,
          lastPaymentDate: latestPaymentDate,
        ),
      );
    });

    // Top 3 Customers (Descending Total Invoice Value, tie-break by count, then name)
    final List<CustomerInvoiceSummary> topCustomersSorted =
        List.from(allCustomerSummaries)..sort((a, b) {
          int cmp = b.totalInvoiceValue.compareTo(
            a.totalInvoiceValue,
          );
          if (cmp == 0) {
            cmp = b.invoiceCount.compareTo(a.invoiceCount);
          }
          if (cmp == 0) {
            cmp = a.customerName.compareTo(b.customerName);
          }
          return cmp;
        });
    final List<CustomerInvoiceSummary> top3Customers =
        topCustomersSorted.take(3).toList();

    // Least 3 Performing Customers (Ascending Total Invoice Value, only eligible customers)
    final List<CustomerInvoiceSummary>
    leastCustomersSorted = List.from(allCustomerSummaries)
      ..sort((a, b) {
        int cmp = a.totalInvoiceValue.compareTo(
          b.totalInvoiceValue,
        );
        if (cmp == 0) {
          cmp = a.invoiceCount.compareTo(b.invoiceCount);
        }
        if (cmp == 0) {
          cmp = a.customerName.compareTo(b.customerName);
        }
        return cmp;
      });
    final List<CustomerInvoiceSummary> least3Customers =
        leastCustomersSorted.take(3).toList();

    // Creditors Aggregation: Customers with positive outstanding balance
    final List<CustomerInvoiceSummary> creditors =
        allCustomerSummaries
            .where((c) => c.outstandingBalance > 0)
            .toList();

    // Top Creditors: Ranked by highest balance down to lowest
    final List<CustomerInvoiceSummary> topCreditorsSorted =
        List.from(creditors)..sort((a, b) {
          int cmp = b.outstandingBalance.compareTo(
            a.outstandingBalance,
          );
          if (cmp == 0) {
            cmp = b.totalInvoiceValue.compareTo(
              a.totalInvoiceValue,
            );
          }
          if (cmp == 0) {
            cmp = a.customerName.compareTo(b.customerName);
          }
          return cmp;
        });
    final List<CustomerInvoiceSummary> topCreditors =
        topCreditorsSorted.take(3).toList();

    // Least Creditors: Ranked by lowest positive balance up to highest
    final List<CustomerInvoiceSummary>
    leastCreditorsSorted = List.from(creditors)
      ..sort((a, b) {
        int cmp = a.outstandingBalance.compareTo(
          b.outstandingBalance,
        );
        if (cmp == 0) {
          cmp = a.totalInvoiceValue.compareTo(
            b.totalInvoiceValue,
          );
        }
        if (cmp == 0) {
          cmp = a.customerName.compareTo(b.customerName);
        }
        return cmp;
      });
    final List<CustomerInvoiceSummary> leastCreditors =
        leastCreditorsSorted.take(3).toList();

    // 5. Staff Aggregation (4.5 & 4.8)
    final Map<String, List<InvoiceReportRow>> staffGroups =
        {};
    for (final row in qualifyingRows) {
      final sId = row.invoice.staffId;
      final groupKey =
          sId.isNotEmpty
              ? sId
              : (row.staffName.isNotEmpty
                  ? row.staffName
                  : '—');
      (staffGroups[groupKey] ??= []).add(row);
    }

    final List<StaffInvoiceSummary> allStaffSummaries = [];
    staffGroups.forEach((key, rows) {
      final first = rows.first;
      int invCount = rows.length;
      double invValue = 0;
      double amtPaid = 0;
      double bal = 0;
      double sumStaffProfit = 0;
      bool hasStaffProfit = false;
      int countWithTotal = 0;

      for (final r in rows) {
        if (r.invoiceTotal != null) {
          invValue += r.invoiceTotal!;
          countWithTotal++;
        }
        amtPaid += r.amountPaid;
        if (r.balance != null) bal += r.balance!;
        if (r.profit != null) {
          sumStaffProfit += r.profit!;
          hasStaffProfit = true;
        }
      }

      final double avgValue =
          countWithTotal > 0
              ? invValue / countWithTotal
              : 0;
      final double pctTotal =
          totalInvoiceValue > 0
              ? (invValue / totalInvoiceValue) * 100
              : 0;

      allStaffSummaries.add(
        StaffInvoiceSummary(
          staffId: first.invoice.staffId,
          staffName: first.staffName,
          invoiceCount: invCount,
          totalInvoiceValue: invValue,
          amountPaid: amtPaid,
          outstandingBalance: bal,
          totalProfit:
              hasStaffProfit ? sumStaffProfit : null,
          averageInvoiceValue: avgValue,
          percentageOfTotalValue: pctTotal,
        ),
      );
    });

    // Top 3 Staff (Descending Total Invoice Value)
    final List<StaffInvoiceSummary> staffSorted = List.from(
      allStaffSummaries,
    )..sort((a, b) {
      int cmp = b.totalInvoiceValue.compareTo(
        a.totalInvoiceValue,
      );
      if (cmp == 0) {
        cmp = b.invoiceCount.compareTo(a.invoiceCount);
      }
      if (cmp == 0) {
        cmp = a.staffName.compareTo(b.staffName);
      }
      return cmp;
    });
    final List<StaffInvoiceSummary> top3Staff =
        staffSorted.take(3).toList();

    // 6. Department Aggregation (4.6)
    final List<DepartmentInvoiceSummary>
    departmentSummaries = [];
    if (departmentsEnabled) {
      final Map<String, List<InvoiceReportRow>> deptGroups =
          {};
      for (final row in qualifyingRows) {
        final dKey =
            row.departmentKey != null &&
                    row.departmentKey!.isNotEmpty
                ? row.departmentKey!
                : invoiceReportNoDepartmentKey;
        (deptGroups[dKey] ??= []).add(row);
      }

      deptGroups.forEach((key, rows) {
        final isOthers =
            key == invoiceReportNoDepartmentKey;
        final String deptName =
            isOthers ? 'Others' : rows.first.departmentName;

        int invCount = rows.length;
        double invValue = 0;
        double amtPaid = 0;
        double bal = 0;
        double sumDeptProfit = 0;
        bool hasDeptProfit = false;
        int countWithTotal = 0;

        for (final r in rows) {
          if (r.invoiceTotal != null) {
            invValue += r.invoiceTotal!;
            countWithTotal++;
          }
          amtPaid += r.amountPaid;
          if (r.balance != null) bal += r.balance!;
          if (r.profit != null) {
            sumDeptProfit += r.profit!;
            hasDeptProfit = true;
          }
        }

        final double avgValue =
            countWithTotal > 0
                ? invValue / countWithTotal
                : 0;
        final double pctTotal =
            totalInvoiceValue > 0
                ? (invValue / totalInvoiceValue) * 100
                : 0;

        departmentSummaries.add(
          DepartmentInvoiceSummary(
            departmentKey: isOthers ? null : key,
            departmentName: deptName,
            invoiceCount: invCount,
            totalInvoiceValue: invValue,
            amountPaid: amtPaid,
            outstandingBalance: bal,
            totalProfit:
                hasDeptProfit ? sumDeptProfit : null,
            averageInvoiceValue: avgValue,
            percentageOfInvoiceValue: pctTotal,
          ),
        );
      });

      departmentSummaries.sort(
        (a, b) => b.totalInvoiceValue.compareTo(
          a.totalInvoiceValue,
        ),
      );
    }

    // 7. Sub-Staff Aggregation (4.14)
    final List<SubStaffInvoiceSummary> subStaffSummaries =
        [];
    if (bulkSaleEnabled) {
      final Map<String, List<InvoiceReportRow>>
      subStaffGroups = {};
      for (final row in qualifyingRows) {
        final subUuid = row.invoice.subStaffUuid;
        final groupKey =
            subUuid != null && subUuid.isNotEmpty
                ? subUuid
                : (row.subStaffName != '—'
                    ? row.subStaffName
                    : 'Unassigned');
        (subStaffGroups[groupKey] ??= []).add(row);
      }

      subStaffGroups.forEach((key, rows) {
        final first = rows.first;
        final bool isUnassigned = key == 'Unassigned';
        final String name =
            isUnassigned
                ? 'Unassigned'
                : first.subStaffName;

        int invCount = rows.length;
        double invValue = 0;
        double amtPaid = 0;
        double bal = 0;
        double sumSubProfit = 0;
        bool hasSubProfit = false;

        for (final r in rows) {
          if (r.invoiceTotal != null) {
            invValue += r.invoiceTotal!;
          }
          amtPaid += r.amountPaid;
          if (r.balance != null) bal += r.balance!;
          if (r.profit != null) {
            sumSubProfit += r.profit!;
            hasSubProfit = true;
          }
        }

        subStaffSummaries.add(
          SubStaffInvoiceSummary(
            subStaffUuid:
                isUnassigned
                    ? null
                    : first.invoice.subStaffUuid,
            subStaffName: name,
            invoiceCount: invCount,
            totalInvoiceValue: invValue,
            amountPaid: amtPaid,
            outstandingBalance: bal,
            totalProfit: hasSubProfit ? sumSubProfit : null,
          ),
        );
      });

      subStaffSummaries.sort(
        (a, b) => b.totalInvoiceValue.compareTo(
          a.totalInvoiceValue,
        ),
      );
    }

    // 8. Payment Collection Summary (4.9 & 4.9.1)
    // Uses actual payments received in the reporting period
    int pureCashCount = 0;
    double pureCashAmount = 0;
    int pureBankCount = 0;
    double pureBankAmount = 0;
    int splitCount = 0;
    double splitAmount = 0;
    double splitCashComponent = 0;
    double splitBankComponent = 0;
    int accountCount = 0;
    double accountAmount = 0;

    for (final rec in qualifyingPeriodReceipts) {
      final double c = rec.cashAlt;
      final double b = rec.bank;
      final double a = rec.customerAccount ?? 0;
      final double tot = c + b + a;

      int channelsUsed = 0;
      if (c > 0) channelsUsed++;
      if (b > 0) channelsUsed++;
      if (a > 0) channelsUsed++;

      if (channelsUsed > 1) {
        splitCount++;
        splitAmount += tot;
        splitCashComponent += c;
        splitBankComponent += b;
      } else if (b > 0) {
        pureBankCount++;
        pureBankAmount += b;
      } else if (c > 0) {
        pureCashCount++;
        pureCashAmount += c;
      } else if (a > 0) {
        accountCount++;
        accountAmount += a;
      } else {
        pureCashCount++;
      }
    }

    final int totalPaymentTransactions =
        qualifyingPeriodReceipts.length;
    final double totalPaymentAmount =
        totalCollectionsInPeriod;

    final List<PaymentChannelCollectionSummary>
    paymentChannelSummaries = [
      PaymentChannelCollectionSummary(
        channelName: 'Cash',
        transactionCount: pureCashCount,
        amountCollected:
            pureCashAmount + splitCashComponent,
        percentageOfTransactions:
            totalPaymentTransactions > 0
                ? (pureCashCount /
                        totalPaymentTransactions) *
                    100
                : 0,
        percentageOfAmount:
            totalPaymentAmount > 0
                ? ((pureCashAmount + splitCashComponent) /
                        totalPaymentAmount) *
                    100
                : 0,
      ),
      PaymentChannelCollectionSummary(
        channelName: 'Bank',
        transactionCount: pureBankCount,
        amountCollected:
            pureBankAmount + splitBankComponent,
        percentageOfTransactions:
            totalPaymentTransactions > 0
                ? (pureBankCount /
                        totalPaymentTransactions) *
                    100
                : 0,
        percentageOfAmount:
            totalPaymentAmount > 0
                ? ((pureBankAmount + splitBankComponent) /
                        totalPaymentAmount) *
                    100
                : 0,
      ),
      PaymentChannelCollectionSummary(
        channelName: 'Split',
        transactionCount: splitCount,
        amountCollected: splitAmount,
        percentageOfTransactions:
            totalPaymentTransactions > 0
                ? (splitCount / totalPaymentTransactions) *
                    100
                : 0,
        percentageOfAmount:
            totalPaymentAmount > 0
                ? (splitAmount / totalPaymentAmount) * 100
                : 0,
      ),
      if (accountCount > 0 || accountAmount > 0)
        PaymentChannelCollectionSummary(
          channelName: 'Customer Account',
          transactionCount: accountCount,
          amountCollected: accountAmount,
          percentageOfTransactions:
              totalPaymentTransactions > 0
                  ? (accountCount /
                          totalPaymentTransactions) *
                      100
                  : 0,
          percentageOfAmount:
              totalPaymentAmount > 0
                  ? (accountAmount / totalPaymentAmount) *
                      100
                  : 0,
        ),
    ];

    // 9. Invoice Payment Status Summary (4.10)
    double fullyPaidValue = 0;
    double fullyPaidPaid = 0;
    double partiallyPaidValue = 0;
    double partiallyPaidPaid = 0;
    double partiallyPaidBalance = 0;
    double unpaidValue = 0;
    double unpaidBalance = 0;
    double unresolvedValue = 0;
    double unresolvedPaid = 0;
    double unresolvedBalance = 0;

    for (final r in qualifyingRows) {
      final v = r.invoiceTotal ?? 0;
      final p = r.amountPaid;
      final b = r.balance ?? 0;

      switch (r.status) {
        case 2:
          fullyPaidValue += v;
          fullyPaidPaid += p;
          break;
        case 1:
          partiallyPaidValue += v;
          partiallyPaidPaid += p;
          partiallyPaidBalance += b;
          break;
        case 0:
          unpaidValue += v;
          unpaidBalance += b;
          break;
        default:
          unresolvedValue += v;
          unresolvedPaid += p;
          unresolvedBalance += b;
          break;
      }
    }

    final double totalInvoicesDbl =
        totalInvoices > 0 ? totalInvoices.toDouble() : 1.0;

    final List<InvoicePaymentStatusSummary>
    statusSummaries = [
      InvoicePaymentStatusSummary(
        statusName: 'Fully Paid',
        statusCode: 2,
        invoiceCount: fullyPaidInvoices,
        totalInvoiceValue: fullyPaidValue,
        amountPaid: fullyPaidPaid,
        outstandingBalance: 0,
        percentageOfInvoices:
            (fullyPaidInvoices / totalInvoicesDbl) * 100,
      ),
      InvoicePaymentStatusSummary(
        statusName: 'Partially Paid',
        statusCode: 1,
        invoiceCount: partiallyPaidInvoices,
        totalInvoiceValue: partiallyPaidValue,
        amountPaid: partiallyPaidPaid,
        outstandingBalance: partiallyPaidBalance,
        percentageOfInvoices:
            (partiallyPaidInvoices / totalInvoicesDbl) *
            100,
      ),
      InvoicePaymentStatusSummary(
        statusName: 'Unpaid',
        statusCode: 0,
        invoiceCount: unpaidInvoices,
        totalInvoiceValue: unpaidValue,
        amountPaid: 0,
        outstandingBalance: unpaidBalance,
        percentageOfInvoices:
            (unpaidInvoices / totalInvoicesDbl) * 100,
      ),
      if (unresolvedInvoices > 0)
        InvoicePaymentStatusSummary(
          statusName: 'Unresolved',
          statusCode: -1,
          invoiceCount: unresolvedInvoices,
          totalInvoiceValue: unresolvedValue,
          amountPaid: unresolvedPaid,
          outstandingBalance: unresolvedBalance,
          percentageOfInvoices:
              (unresolvedInvoices / totalInvoicesDbl) * 100,
        ),
    ];

    // 10. Invoice Creation & Payment Activity Summary (4.11)
    final List<InvoiceActivitySummaryRow>
    activitySummaries = [
      InvoiceActivitySummaryRow(
        activityType: 'Invoices Created',
        activityCount: totalInvoices,
        invoiceValue: totalInvoiceValue,
        amountCollected: totalAmountPaid,
        outstandingBalance: totalOutstandingBalance,
      ),
      InvoiceActivitySummaryRow(
        activityType: 'Invoice Payments Received',
        activityCount: qualifyingPeriodReceipts.length,
        invoiceValue: null,
        amountCollected: totalCollectionsInPeriod,
        outstandingBalance: null,
      ),
      InvoiceActivitySummaryRow(
        activityType: 'Invoices Fully Paid',
        activityCount: fullyPaidInvoices,
        invoiceValue: fullyPaidValue,
        amountCollected: fullyPaidPaid,
        outstandingBalance: 0,
      ),
      InvoiceActivitySummaryRow(
        activityType: 'Invoices Partially Paid',
        activityCount: partiallyPaidInvoices,
        invoiceValue: partiallyPaidValue,
        amountCollected: partiallyPaidPaid,
        outstandingBalance: partiallyPaidBalance,
      ),
      InvoiceActivitySummaryRow(
        activityType: 'Invoices Remaining Unpaid',
        activityCount: unpaidInvoices,
        invoiceValue: unpaidValue,
        amountCollected: 0,
        outstandingBalance: unpaidBalance,
      ),
    ];

    // 11. Generate Time-Series Trends (4.12 & 4.13)
    final List<InvoiceTrendPoint> trends = _buildTrends(
      period: period,
      range: range,
      qualifyingRows: qualifyingRows,
      periodReceipts: qualifyingPeriodReceipts,
    );

    return InvoiceSummaryResult(
      stats: stats,
      qualifyingRows: qualifyingRows,
      top3Customers: top3Customers,
      least3Customers: least3Customers,
      topCreditors: topCreditors,
      leastCreditors: leastCreditors,
      allCustomerSummaries: allCustomerSummaries,
      top3Staff: top3Staff,
      allStaffSummaries: allStaffSummaries,
      departmentSummaries: departmentSummaries,
      subStaffSummaries: subStaffSummaries,
      paymentChannelSummaries: paymentChannelSummaries,
      statusSummaries: statusSummaries,
      activitySummaries: activitySummaries,
      trends: trends,
    );
  }

  /// Builds trend points bucketed by time interval.
  static List<InvoiceTrendPoint> _buildTrends({
    required InvoiceSummaryPeriod period,
    required DateTimeRange range,
    required List<InvoiceReportRow> qualifyingRows,
    required List<TempMainReceipt> periodReceipts,
  }) {
    final List<InvoiceTrendPoint> points = [];

    if (period == InvoiceSummaryPeriod.today) {
      // 2-hour buckets: 04:00, 06:00, 08:00, ..., 22:00
      final start = DateTime(
        range.start.year,
        range.start.month,
        range.start.day,
        4,
      );
      for (int i = 0; i < 10; i++) {
        final bStart = start.add(Duration(hours: i * 2));
        final bEnd = bStart.add(const Duration(hours: 2));
        final label =
            '${bStart.hour.toString().padLeft(2, '0')}:00';

        double val = 0;
        double col = 0;
        double bal = 0;
        double? prof;
        bool hasProf = false;
        double sumProf = 0;
        int created = 0;
        int paid = 0;
        int partial = 0;
        int unpaid = 0;

        for (final r in qualifyingRows) {
          final t = r.createdAt.toLocal();
          if ((t.isAfter(bStart) ||
                  t.isAtSameMomentAs(bStart)) &&
              t.isBefore(bEnd)) {
            created++;
            val += (r.invoiceTotal ?? 0);
            bal += (r.balance ?? 0);
            if (r.profit != null) {
              sumProf += r.profit!;
              hasProf = true;
            }
            if (r.status == 2) paid++;
            if (r.status == 1) partial++;
            if (r.status == 0) unpaid++;
          }
        }

        for (final rec in periodReceipts) {
          final t = rec.createdAt.toLocal();
          if ((t.isAfter(bStart) ||
                  t.isAtSameMomentAs(bStart)) &&
              t.isBefore(bEnd)) {
            col +=
                (rec.bank +
                    rec.cashAlt +
                    (rec.customerAccount ?? 0));
          }
        }

        if (hasProf) prof = sumProf;

        points.add(
          InvoiceTrendPoint(
            date: bStart,
            label: label,
            invoiceValue: val,
            amountCollected: col,
            outstandingBalance: bal,
            profit: prof,
            invoicesCreated: created,
            fullyPaidCount: paid,
            partiallyPaidCount: partial,
            unpaidCount: unpaid,
          ),
        );
      }
    } else {
      // Daily buckets (from range.start to range.end)
      final daysCount =
          range.end.difference(range.start).inDays + 1;

      if (daysCount <= 31) {
        for (int i = 0; i < daysCount; i++) {
          final day = range.start.add(Duration(days: i));
          final bStart = fourAm(day);
          final bEnd = fourAmNextDay(day);
          final label = '${day.day}/${day.month}';

          double val = 0;
          double col = 0;
          double bal = 0;
          double? prof;
          bool hasProf = false;
          double sumProf = 0;
          int created = 0;
          int paid = 0;
          int partial = 0;
          int unpaid = 0;

          for (final r in qualifyingRows) {
            final t = r.createdAt.toLocal();
            if ((t.isAfter(bStart) ||
                    t.isAtSameMomentAs(bStart)) &&
                t.isBefore(bEnd)) {
              created++;
              val += (r.invoiceTotal ?? 0);
              bal += (r.balance ?? 0);
              if (r.profit != null) {
                sumProf += r.profit!;
                hasProf = true;
              }
              if (r.status == 2) paid++;
              if (r.status == 1) partial++;
              if (r.status == 0) unpaid++;
            }
          }

          for (final rec in periodReceipts) {
            final t = rec.createdAt.toLocal();
            if ((t.isAfter(bStart) ||
                    t.isAtSameMomentAs(bStart)) &&
                t.isBefore(bEnd)) {
              col +=
                  (rec.bank +
                      rec.cashAlt +
                      (rec.customerAccount ?? 0));
            }
          }

          if (hasProf) prof = sumProf;

          points.add(
            InvoiceTrendPoint(
              date: day,
              label: label,
              invoiceValue: val,
              amountCollected: col,
              outstandingBalance: bal,
              profit: prof,
              invoicesCreated: created,
              fullyPaidCount: paid,
              partiallyPaidCount: partial,
              unpaidCount: unpaid,
            ),
          );
        }
      } else {
        // Group by Month when spanning multiple months
        final Map<String, InvoiceTrendPoint> monthBuckets =
            {};

        for (final r in qualifyingRows) {
          final t = r.createdAt.toLocal();
          final key =
              '${t.year}-${t.month.toString().padLeft(2, '0')}';
          final existing = monthBuckets[key];

          final val = (r.invoiceTotal ?? 0);
          final bal = (r.balance ?? 0);
          final prof = r.profit ?? 0;

          if (existing == null) {
            monthBuckets[key] = InvoiceTrendPoint(
              date: DateTime(t.year, t.month, 1),
              label:
                  '${_monthName(t.month)} ${t.year % 100}',
              invoiceValue: val,
              amountCollected: 0,
              outstandingBalance: bal,
              profit: r.profit != null ? prof : null,
              invoicesCreated: 1,
              fullyPaidCount: r.status == 2 ? 1 : 0,
              partiallyPaidCount: r.status == 1 ? 1 : 0,
              unpaidCount: r.status == 0 ? 1 : 0,
            );
          } else {
            monthBuckets[key] = InvoiceTrendPoint(
              date: existing.date,
              label: existing.label,
              invoiceValue: existing.invoiceValue + val,
              amountCollected: existing.amountCollected,
              outstandingBalance:
                  existing.outstandingBalance + bal,
              profit:
                  (existing.profit ?? 0) +
                  (r.profit != null ? prof : 0),
              invoicesCreated: existing.invoicesCreated + 1,
              fullyPaidCount:
                  existing.fullyPaidCount +
                  (r.status == 2 ? 1 : 0),
              partiallyPaidCount:
                  existing.partiallyPaidCount +
                  (r.status == 1 ? 1 : 0),
              unpaidCount:
                  existing.unpaidCount +
                  (r.status == 0 ? 1 : 0),
            );
          }
        }

        for (final rec in periodReceipts) {
          final t = rec.createdAt.toLocal();
          final key =
              '${t.year}-${t.month.toString().padLeft(2, '0')}';
          final col =
              (rec.bank +
                  rec.cashAlt +
                  (rec.customerAccount ?? 0));
          final existing = monthBuckets[key];
          if (existing != null) {
            monthBuckets[key] = InvoiceTrendPoint(
              date: existing.date,
              label: existing.label,
              invoiceValue: existing.invoiceValue,
              amountCollected:
                  existing.amountCollected + col,
              outstandingBalance:
                  existing.outstandingBalance,
              profit: existing.profit,
              invoicesCreated: existing.invoicesCreated,
              fullyPaidCount: existing.fullyPaidCount,
              partiallyPaidCount:
                  existing.partiallyPaidCount,
              unpaidCount: existing.unpaidCount,
            );
          }
        }

        points.addAll(monthBuckets.values.toList());
        points.sort((a, b) => a.date.compareTo(b.date));
      }
    }

    return points;
  }

  static String _monthName(int m) {
    const names = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    if (m >= 1 && m <= 12) return names[m - 1];
    return '';
  }
}
