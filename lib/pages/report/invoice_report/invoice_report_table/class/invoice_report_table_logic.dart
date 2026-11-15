import 'package:flutter/material.dart';
import 'package:stockall/classes/payment_entry/payment_entry.dart';
import 'package:stockall/classes/temp_customers/temp_customers_class.dart';
import 'package:stockall/classes/temp_invoices/temp_invoices.dart';
import 'package:stockall/classes/temp_main_receipt/temp_main_receipt.dart';
import 'package:stockall/classes/temp_product_slaes_record/temp_product_sale_record.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/pages/report/components/report_group_by.dart';

/// Page size required by report table specification.
const int invoiceReportPageSize = 100;

/// Identifier used for unassigned department filter bucket.
const String invoiceReportNoDepartmentKey =
    '__no_department__';

enum InvoiceSortField {
  id,
  staff,
  subStaff,
  customer,
  createdAt,
  discount,
  vat,
  items,
  department,
  channel,
  total,
  amountPaid,
  balance,
  cost,
  profit,
  margin,
  status,
}

enum InvoicePaymentStatusFilter {
  all,
  unpaid,
  partial,
  paid,
}

enum InvoicePaymentChannelFilter {
  all,
  cash,
  bank,
  split,
  unpaid,
}

/// One displayed line in the Invoice Report Table.
class InvoiceReportRow {
  final TempInvoice invoice;

  /// PERSISTED ID or appropriate fallback identifier (#id, #barcode, #uuid).
  final String displayId;

  /// Staff name.
  final String staffName;

  /// Sub-staff name (for bulk sale).
  final String subStaffName;

  /// Customer display name.
  final String customerName;

  /// Creation timestamp.
  final DateTime createdAt;

  /// Calculated monetary discount amount.
  final double discountAmount;

  /// Display text for discount (e.g. 10%, ₦500, or —).
  final String discountDisplay;

  /// Calculated VAT amount.
  final double vatAmount;

  /// Display text for VAT (e.g. [7.5%] ₦750, or —).
  final String vatDisplay;

  /// Total individual units across sold lines. Null when items are unavailable.
  final double? totalItems;

  /// Department name or 'No Department'.
  final String departmentName;

  /// Department uuid (new or legacy) for filtering.
  final String? departmentKey;

  /// Comment text or —.
  final String comment;

  /// Classified payment channel: 'Cash', 'Bank', 'Split', 'Unpaid'.
  final String paymentChannel;

  /// Total invoice value payable. Null if historical calculation is unavailable.
  final double? invoiceTotal;

  /// Authoritative cumulative amount paid toward invoice.
  final double amountPaid;

  /// Outstanding balance. Null if invoice total is unavailable.
  final double? balance;

  /// Total cost of goods sold. Null if items are unavailable.
  final double? cost;

  /// Net profit or loss. Null if cost or total is unavailable.
  final double? profit;

  /// Profit margin percentage: (profit / netRevenue) * 100.
  final double? margin;

  /// Invoice status index: 0 = Unpaid, 1 = Partial, 2 = Paid, -1 = Unavailable.
  final int status;

  InvoiceReportRow({
    required this.invoice,
    required this.displayId,
    required this.staffName,
    required this.subStaffName,
    required this.customerName,
    required this.createdAt,
    required this.discountAmount,
    required this.discountDisplay,
    required this.vatAmount,
    required this.vatDisplay,
    required this.totalItems,
    required this.departmentName,
    required this.departmentKey,
    required this.comment,
    required this.paymentChannel,
    required this.invoiceTotal,
    required this.amountPaid,
    required this.balance,
    required this.cost,
    required this.profit,
    required this.margin,
    required this.status,
  });

  String get uuid => invoice.uuid ?? '';
  String? get barcode => invoice.barcode;
}

/// Helper to aggregate invoice payments and build [InvoiceReportRow]s safely.
class InvoiceReportRowBuilder {
  /// Builds all rows for given invoices, payment receipts, and customer lookup.
  static List<InvoiceReportRow> buildAll({
    required List<TempInvoice> invoices,
    required List<TempMainReceipt> allReceipts,
    required List<TempProductSaleRecord> allProductSales,
    required Map<String, TempCustomersClass> customerMap,
    BuildContext? context,
  }) {
    // Index payment receipts by invoiceUuid for fast O(1) grouping.
    final Map<String, List<TempMainReceipt>>
    receiptsByInvoiceUuid = {};
    for (final rec in allReceipts) {
      final invUuid = rec.invoiceUuid;
      if (invUuid != null && invUuid.isNotEmpty) {
        (receiptsByInvoiceUuid[invUuid] ??= []).add(rec);
      }
    }

    // Index standalone product sales by invoiceUuid for fallback when items is null/empty.
    final Map<String, List<TempProductSaleRecord>>
    salesByInvoiceUuid = {};
    for (final sale in allProductSales) {
      final invUuid = sale.invoiceUuid;
      if (invUuid != null && invUuid.isNotEmpty) {
        (salesByInvoiceUuid[invUuid] ??= []).add(sale);
      }
    }

    final List<InvoiceReportRow> rows = [];
    for (final invoice in invoices) {
      final invUuid = invoice.uuid ?? '';
      final relatedReceipts =
          receiptsByInvoiceUuid[invUuid] ?? const [];
      final fallbackSales =
          salesByInvoiceUuid[invUuid] ?? const [];

      rows.add(
        buildSingle(
          invoice: invoice,
          relatedReceipts: relatedReceipts,
          fallbackSales: fallbackSales,
          customerMap: customerMap,
          context: context,
        ),
      );
    }
    return rows;
  }

  static InvoiceReportRow buildSingle({
    required TempInvoice invoice,
    required List<TempMainReceipt> relatedReceipts,
    required List<TempProductSaleRecord> fallbackSales,
    required Map<String, TempCustomersClass> customerMap,
    BuildContext? context,
  }) {
    // 1. Persisted ID or Fallback
    final String displayId;
    if (invoice.id != null) {
      displayId = '#${invoice.id}';
    } else if (invoice.barcode != null &&
        invoice.barcode!.trim().isNotEmpty) {
      displayId = '#${invoice.barcode!.trim()}';
    } else if (invoice.uuid != null &&
        invoice.uuid!.trim().isNotEmpty) {
      final digits = invoice.uuid!.replaceAll(
        RegExp(r'\D'),
        '',
      );
      displayId =
          '#${digits.isNotEmpty ? digits : (invoice.uuid!.length > 8 ? invoice.uuid!.substring(0, 8) : invoice.uuid!)}';
    } else {
      displayId = '—';
    }

    // 2. Staff Name
    final String staffName =
        invoice.staffName.trim().isNotEmpty
            ? invoice.staffName.trim()
            : '—';

    // 3. Sub-Staff Name
    final String subStaffName =
        (invoice.subStaffName != null &&
                invoice.subStaffName!.trim().isNotEmpty)
            ? invoice.subStaffName!.trim()
            : '—';

    // 4. Customer Name
    String customerName = 'Walk-in Customer';
    if (invoice.customerName != null &&
        invoice.customerName!.trim().isNotEmpty) {
      customerName = invoice.customerName!.trim();
    } else if (invoice.customerUuid != null &&
        invoice.customerUuid!.isNotEmpty) {
      final cust = customerMap[invoice.customerUuid!];
      if (cust != null && cust.name.trim().isNotEmpty) {
        customerName = cust.name.trim();
      }
    }

    // 5. Date & 6. Time (from createdAt)
    final DateTime createdAt = invoice.createdAt;

    // Helper for formatting monetary amounts safely even without BuildContext
    String formatAmount(double amt) {
      if (context != null) {
        return formatMoneyBig(
          amount: amt,
          context: context,
        );
      }
      return formatLargeNumberDouble(amt);
    }

    // 7. Discount
    final double discountAmount =
        invoice.getDiscountAmountForInvoice();
    final String discountDisplay;
    if (invoice.fixedDiscount != null &&
        invoice.fixedDiscount! > 0) {
      discountDisplay = formatAmount(
        invoice.fixedDiscount!,
      );
    } else if (invoice.generalDiscount != null &&
        invoice.generalDiscount! > 0) {
      discountDisplay =
          '${formatLargeNumberDouble(invoice.generalDiscount!)}% (${formatAmount(discountAmount)})';
    } else {
      discountDisplay = '—';
    }

    // 8. VAT
    final double vatAmount =
        (invoice.vat != null && invoice.vat! > 0)
            ? ((invoice.originalCost ?? 0) *
                (invoice.vat! / 100))
            : 0;
    final String vatDisplay =
        (invoice.vat != null && invoice.vat! > 0)
            ? '[${formatLargeNumberDouble(invoice.vat!)}%] ${formatAmount(vatAmount)}'
            : '—';

    // Items list (from invoice.items or fallback sales)
    List<TempProductSaleRecord> lines = const [];
    if (invoice.items != null &&
        invoice.items!.isNotEmpty) {
      lines = invoice.items!;
    } else if (fallbackSales.isNotEmpty) {
      lines = fallbackSales;
    }

    // 9. Total Items Count
    double? totalItems;
    if (lines.isNotEmpty) {
      double count = 0;
      for (final line in lines) {
        if (line.isVoid == true) continue;
        try {
          if (line.unitsList != null &&
              line.unitsList!.isNotEmpty) {
            count += line.getActualQuantity();
          } else if (line.quantityType == 2 &&
              line.hasCustomDimensions) {
            count += line.quantity * line.dimensionArea();
          } else {
            count += line.quantity;
          }
        } catch (_) {
          if (line.quantityType == 2 &&
              line.hasCustomDimensions) {
            count += line.quantity * line.dimensionArea();
          } else {
            count += line.quantity;
          }
        }
      }
      totalItems = count;
    }

    // 10. Department
    final bool hasDept =
        invoice.departmentName != null &&
        invoice.departmentName!.trim().isNotEmpty;
    final String departmentName =
        hasDept
            ? invoice.departmentName!.trim()
            : 'No Department';
    final String? departmentKey =
        invoice.departmentUuidNew ??
        (invoice.departmentUuid != null
            ? '${invoice.departmentUuid}'
            : null);

    // 11. Comment
    final String comment =
        (invoice.comment != null &&
                invoice.comment!.trim().isNotEmpty)
            ? invoice.comment!.trim()
            : '—';

    // 14. Amount Paid (aggregated from valid related receipts)
    double amountPaid = 0;
    double cashPaid = 0;
    double bankPaid = 0;
    double accountPaid = 0;
    for (final rec in relatedReceipts) {
      amountPaid +=
          (rec.bank +
              rec.cashAlt +
              (rec.customerAccount ?? 0));
      cashPaid += rec.cashAlt;
      bankPaid += rec.bank;
      accountPaid += (rec.customerAccount ?? 0);
    }

    // 13. Invoice Total
    double? invoiceTotal;
    final double storedTotal =
        invoice
            .getTotalMainRevenueInvoice(); // bank + cashAlt
    if (storedTotal > 0) {
      invoiceTotal = storedTotal;
    } else if (lines.isNotEmpty) {
      // Reconstruct total from lines if storedTotal is 0
      final double grossItems = lines.fold<double>(
        0,
        (sum, item) =>
            sum + (item.originalCost ?? item.revenue),
      );
      invoiceTotal =
          (grossItems - discountAmount) + vatAmount;
    } else if ((invoice.originalCost ?? 0) > 0) {
      invoiceTotal =
          ((invoice.originalCost ?? 0) - discountAmount) +
          vatAmount;
    } else {
      invoiceTotal = null; // truly unavailable
    }

    // 15. Outstanding Balance
    final double? balance;
    if (invoiceTotal != null) {
      balance = invoiceTotal - amountPaid;
    } else {
      balance = null;
    }

    // 16. Cost
    double? cost;
    if (lines.isNotEmpty) {
      double sumCost = 0;
      bool hasAnyCost = false;
      for (final line in lines) {
        if (line.isVoid == true) continue;
        if (line.costPrice != null) {
          sumCost += line.costPrice!;
          hasAnyCost = true;
        }
      }
      if (hasAnyCost) {
        cost = sumCost;
      }
    }

    // 17. Profit/Loss & 18. Profit Margin
    double? profit;
    double? margin;
    if (cost != null && invoiceTotal != null) {
      // Net revenue excludes VAT (tax liability collected on behalf of government)
      final double netRevenue = invoiceTotal - vatAmount;
      profit = netRevenue - cost;
      if (netRevenue > 0) {
        final calculatedMargin =
            (profit / netRevenue) * 100;
        if (calculatedMargin.isFinite) {
          margin = calculatedMargin;
        }
      }
    }

    // 19. Status
    final int status;
    if (invoiceTotal == null) {
      status = -1; // Unavailable
    } else if (amountPaid <= 0) {
      status = 0; // Unpaid
    } else if (amountPaid < invoiceTotal &&
        (balance ?? 0) > 0) {
      status = 1; // Partial
    } else {
      status = 2; // Paid
    }

    // 12. Payment Channel Classification
    final String paymentChannel;
    if (amountPaid <= 0) {
      paymentChannel = 'Unpaid';
    } else {
      int methodsUsed = 0;
      if (cashPaid > 0) methodsUsed++;
      if (bankPaid > 0) methodsUsed++;
      if (accountPaid > 0) methodsUsed++;

      if (methodsUsed > 1) {
        paymentChannel = 'Split';
      } else if (bankPaid > 0) {
        final bankLabels = <String>{};
        for (final rec in relatedReceipts) {
          if (rec.bank <= 0) continue;
          final bLabel = rec.paymentBreakdown().label.trim();
          if (bLabel.isNotEmpty &&
              PaymentMethods.isBankMethod(bLabel) &&
              bLabel.toLowerCase() != 'bank') {
            bankLabels.add(bLabel);
          } else if (rec.selectedBank != null &&
              rec.selectedBank!.displayName.trim().isNotEmpty) {
            bankLabels.add(rec.selectedBank!.displayName.trim());
          } else if (PaymentMethods.isBankMethod(rec.paymentMethod) &&
              rec.paymentMethod.trim().isNotEmpty &&
              rec.paymentMethod.trim().toLowerCase() != 'bank') {
            bankLabels.add(rec.paymentMethod.trim());
          }
        }
        if (bankLabels.length == 1) {
          paymentChannel = bankLabels.first;
        } else if (invoice.selectedBank != null &&
            invoice.selectedBank!.displayName.trim().isNotEmpty) {
          paymentChannel = invoice.selectedBank!.displayName.trim();
        } else if (PaymentMethods.isBankMethod(invoice.paymentMethod) &&
            invoice.paymentMethod.trim().isNotEmpty &&
            invoice.paymentMethod.trim().toLowerCase() != 'bank') {
          paymentChannel = invoice.paymentMethod.trim();
        } else {
          paymentChannel = 'Bank';
        }
      } else if (cashPaid > 0) {
        paymentChannel = 'Cash';
      } else if (accountPaid > 0) {
        paymentChannel = 'Account';
      } else {
        paymentChannel =
            invoice.paymentMethod.isNotEmpty
                ? invoice.paymentMethod
                : 'Cash';
      }
    }

    return InvoiceReportRow(
      invoice: invoice,
      displayId: displayId,
      staffName: staffName,
      subStaffName: subStaffName,
      customerName: customerName,
      createdAt: createdAt,
      discountAmount: discountAmount,
      discountDisplay: discountDisplay,
      vatAmount: vatAmount,
      vatDisplay: vatDisplay,
      totalItems: totalItems,
      departmentName: departmentName,
      departmentKey: departmentKey,
      comment: comment,
      paymentChannel: paymentChannel,
      invoiceTotal: invoiceTotal,
      amountPaid: amountPaid,
      balance: balance,
      cost: cost,
      profit: profit,
      margin: margin,
      status: status,
    );
  }
}

/// Filter criteria container for Invoice Report Table.
class InvoiceReportFilters {
  String search = '';
  DateTimeRange? dateRange;
  String? staffId;
  String? customerUuid;
  InvoicePaymentChannelFilter paymentChannel =
      InvoicePaymentChannelFilter.all;
  InvoicePaymentStatusFilter paymentStatus =
      InvoicePaymentStatusFilter.all;
  String? subStaffUuid;
  String? departmentKey;
  double? totalMin;
  double? totalMax;
  double? paidMin;
  double? paidMax;
  double? balanceMin;
  double? balanceMax;
  double? profitMin;
  double? profitMax;

  InvoiceReportFilters({
    this.search = '',
    this.dateRange,
    this.staffId,
    this.customerUuid,
    this.paymentChannel = InvoicePaymentChannelFilter.all,
    this.paymentStatus = InvoicePaymentStatusFilter.all,
    this.subStaffUuid,
    this.departmentKey,
    this.totalMin,
    this.totalMax,
    this.paidMin,
    this.paidMax,
    this.balanceMin,
    this.balanceMax,
    this.profitMin,
    this.profitMax,
  });

  void copyFrom(InvoiceReportFilters other) {
    search = other.search;
    dateRange = other.dateRange;
    staffId = other.staffId;
    customerUuid = other.customerUuid;
    paymentChannel = other.paymentChannel;
    paymentStatus = other.paymentStatus;
    subStaffUuid = other.subStaffUuid;
    departmentKey = other.departmentKey;
    totalMin = other.totalMin;
    totalMax = other.totalMax;
    paidMin = other.paidMin;
    paidMax = other.paidMax;
    balanceMin = other.balanceMin;
    balanceMax = other.balanceMax;
    profitMin = other.profitMin;
    profitMax = other.profitMax;
  }

  bool get hasAnything =>
      search.trim().isNotEmpty ||
      dateRange != null ||
      staffId != null ||
      customerUuid != null ||
      paymentChannel != InvoicePaymentChannelFilter.all ||
      paymentStatus != InvoicePaymentStatusFilter.all ||
      subStaffUuid != null ||
      departmentKey != null ||
      totalMin != null ||
      totalMax != null ||
      paidMin != null ||
      paidMax != null ||
      balanceMin != null ||
      balanceMax != null ||
      profitMin != null ||
      profitMax != null;

  int get activeCount {
    int c = 0;
    if (search.trim().isNotEmpty) c++;
    if (dateRange != null) c++;
    if (staffId != null) c++;
    if (customerUuid != null) c++;
    if (paymentChannel != InvoicePaymentChannelFilter.all)
      c++;
    if (paymentStatus != InvoicePaymentStatusFilter.all)
      c++;
    if (subStaffUuid != null) c++;
    if (departmentKey != null) c++;
    if (totalMin != null || totalMax != null) c++;
    if (paidMin != null || paidMax != null) c++;
    if (balanceMin != null || balanceMax != null) c++;
    if (profitMin != null || profitMax != null) c++;
    return c;
  }

  void clearAll() {
    search = '';
    dateRange = null;
    staffId = null;
    customerUuid = null;
    paymentChannel = InvoicePaymentChannelFilter.all;
    paymentStatus = InvoicePaymentStatusFilter.all;
    subStaffUuid = null;
    departmentKey = null;
    totalMin = null;
    totalMax = null;
    paidMin = null;
    paidMax = null;
    balanceMin = null;
    balanceMax = null;
    profitMin = null;
    profitMax = null;
  }
}

/// Result of paginating [InvoiceReportRow]s.
class InvoiceReportPageResult {
  final List<InvoiceReportRow> rows;
  final int totalCount;
  final int page;
  final int pageSize;
  final int totalPages;
  final double totalRevenue;
  final double totalAmountPaid;
  final double totalBalance;

  const InvoiceReportPageResult({
    required this.rows,
    required this.totalCount,
    required this.page,
    required this.pageSize,
    required this.totalPages,
    this.totalRevenue = 0,
    this.totalAmountPaid = 0,
    this.totalBalance = 0,
  });

  int get firstIndex =>
      totalCount == 0 ? 0 : (page - 1) * pageSize + 1;
  int get lastIndex =>
      totalCount == 0
          ? 0
          : ((page - 1) * pageSize + rows.length);
}

/// Query engine for searching, filtering, sorting, and paginating invoices.
class InvoiceReportQuery {
  static List<InvoiceReportRow> filterAndSort({
    required List<InvoiceReportRow> rows,
    required InvoiceReportFilters filters,
    required InvoiceSortField sortField,
    required bool ascending,
    required bool departmentsEnabled,
    required bool bulkSaleEnabled,
    required bool costFilterAllowed,
  }) {
    final query = filters.search.trim().toLowerCase();

    final filtered =
        rows.where((row) {
          // 1. Search Query
          if (query.isNotEmpty) {
            final matchesCustomer = row.customerName
                .toLowerCase()
                .contains(query);
            final matchesStaff = row.staffName
                .toLowerCase()
                .contains(query);
            final matchesId = row.displayId
                .toLowerCase()
                .contains(query);
            final matchesBarcode =
                row.barcode != null &&
                row.barcode!.toLowerCase().contains(query);
            final matchesDept =
                departmentsEnabled &&
                row.departmentName.toLowerCase().contains(
                  query,
                );

            if (!matchesCustomer &&
                !matchesStaff &&
                !matchesId &&
                !matchesBarcode &&
                !matchesDept) {
              return false;
            }
          }

          // 2. Date Range (using business-day conventions)
          if (filters.dateRange != null) {
            final created = row.createdAt.toLocal();
            final startCutoff = fourAm(
              filters.dateRange!.start,
            );
            final endCutoff = fourAmNextDay(
              filters.dateRange!.end,
            );
            if (created.isBefore(startCutoff) ||
                created.isAfter(endCutoff)) {
              return false;
            }
          }

          // 3. Staff Filter
          if (filters.staffId != null) {
            if (row.invoice.staffId != filters.staffId) {
              return false;
            }
          }

          // 4. Customer Filter
          if (filters.customerUuid != null) {
            if (row.invoice.customerUuid !=
                filters.customerUuid) {
              return false;
            }
          }

          // 5. Payment Channel Filter
          if (filters.paymentChannel !=
              InvoicePaymentChannelFilter.all) {
            switch (filters.paymentChannel) {
              case InvoicePaymentChannelFilter.cash:
                if (row.paymentChannel != 'Cash')
                  return false;
                break;
              case InvoicePaymentChannelFilter.bank:
                if (!PaymentMethods.isBankMethod(row.paymentChannel))
                  return false;
                break;
              case InvoicePaymentChannelFilter.split:
                if (row.paymentChannel != 'Split')
                  return false;
                break;
              case InvoicePaymentChannelFilter.unpaid:
                if (row.paymentChannel != 'Unpaid')
                  return false;
                break;
              case InvoicePaymentChannelFilter.all:
                break;
            }
          }

          // 6. Payment Status Filter
          if (filters.paymentStatus !=
              InvoicePaymentStatusFilter.all) {
            switch (filters.paymentStatus) {
              case InvoicePaymentStatusFilter.unpaid:
                if (row.status != 0) return false;
                break;
              case InvoicePaymentStatusFilter.partial:
                if (row.status != 1) return false;
                break;
              case InvoicePaymentStatusFilter.paid:
                if (row.status != 2) return false;
                break;
              case InvoicePaymentStatusFilter.all:
                break;
            }
          }

          // 7. Sub-Staff Filter (bulk sale enabled)
          if (bulkSaleEnabled &&
              filters.subStaffUuid != null) {
            if (row.invoice.subStaffUuid !=
                filters.subStaffUuid) {
              return false;
            }
          }

          // 8. Department Filter (department management enabled)
          if (departmentsEnabled &&
              filters.departmentKey != null) {
            if (filters.departmentKey ==
                invoiceReportNoDepartmentKey) {
              if (row.departmentKey != null &&
                  row.departmentKey!.isNotEmpty) {
                return false;
              }
            } else {
              if (row.departmentKey !=
                  filters.departmentKey) {
                return false;
              }
            }
          }

          // 9. Invoice Total Range Filter
          if (filters.totalMin != null ||
              filters.totalMax != null) {
            if (row.invoiceTotal == null) return false;
            if (filters.totalMin != null &&
                row.invoiceTotal! < filters.totalMin!) {
              return false;
            }
            if (filters.totalMax != null &&
                row.invoiceTotal! > filters.totalMax!) {
              return false;
            }
          }

          // 10. Amount Paid Range Filter
          if (filters.paidMin != null &&
              row.amountPaid < filters.paidMin!) {
            return false;
          }
          if (filters.paidMax != null &&
              row.amountPaid > filters.paidMax!) {
            return false;
          }

          // 11. Outstanding Balance Range Filter
          if (filters.balanceMin != null ||
              filters.balanceMax != null) {
            if (row.balance == null) return false;
            if (filters.balanceMin != null &&
                row.balance! < filters.balanceMin!) {
              return false;
            }
            if (filters.balanceMax != null &&
                row.balance! > filters.balanceMax!) {
              return false;
            }
          }

          // 12. Profit Range Filter (allowed only when cost is visible)
          if (costFilterAllowed &&
              (filters.profitMin != null ||
                  filters.profitMax != null)) {
            if (row.profit == null) return false;
            if (filters.profitMin != null &&
                row.profit! < filters.profitMin!) {
              return false;
            }
            if (filters.profitMax != null &&
                row.profit! > filters.profitMax!) {
              return false;
            }
          }

          return true;
        }).toList();

    // Sort complete filtered dataset
    filtered.sort((a, b) {
      int cmp = 0;
      switch (sortField) {
        case InvoiceSortField.id:
          cmp = (a.invoice.id ?? 0).compareTo(
            b.invoice.id ?? 0,
          );
          if (cmp == 0) {
            cmp = a.displayId.compareTo(b.displayId);
          }
          break;
        case InvoiceSortField.staff:
          cmp = a.staffName.toLowerCase().compareTo(
            b.staffName.toLowerCase(),
          );
          break;
        case InvoiceSortField.subStaff:
          cmp = a.subStaffName.toLowerCase().compareTo(
            b.subStaffName.toLowerCase(),
          );
          break;
        case InvoiceSortField.customer:
          cmp = a.customerName.toLowerCase().compareTo(
            b.customerName.toLowerCase(),
          );
          break;
        case InvoiceSortField.createdAt:
          cmp = a.createdAt.compareTo(b.createdAt);
          break;
        case InvoiceSortField.discount:
          cmp = a.discountAmount.compareTo(
            b.discountAmount,
          );
          break;
        case InvoiceSortField.vat:
          cmp = a.vatAmount.compareTo(b.vatAmount);
          break;
        case InvoiceSortField.items:
          final aQty = a.totalItems;
          final bQty = b.totalItems;
          if (aQty == null && bQty == null)
            cmp = 0;
          else if (aQty == null)
            cmp = -1;
          else if (bQty == null)
            cmp = 1;
          else
            cmp = aQty.compareTo(bQty);
          break;
        case InvoiceSortField.department:
          cmp = a.departmentName.toLowerCase().compareTo(
            b.departmentName.toLowerCase(),
          );
          break;
        case InvoiceSortField.channel:
          cmp = a.paymentChannel.compareTo(
            b.paymentChannel,
          );
          break;
        case InvoiceSortField.total:
          final aTot = a.invoiceTotal;
          final bTot = b.invoiceTotal;
          if (aTot == null && bTot == null)
            cmp = 0;
          else if (aTot == null)
            cmp = -1;
          else if (bTot == null)
            cmp = 1;
          else
            cmp = aTot.compareTo(bTot);
          break;
        case InvoiceSortField.amountPaid:
          cmp = a.amountPaid.compareTo(b.amountPaid);
          break;
        case InvoiceSortField.balance:
          final aBal = a.balance;
          final bBal = b.balance;
          if (aBal == null && bBal == null)
            cmp = 0;
          else if (aBal == null)
            cmp = -1;
          else if (bBal == null)
            cmp = 1;
          else
            cmp = aBal.compareTo(bBal);
          break;
        case InvoiceSortField.cost:
          final aCost = a.cost;
          final bCost = b.cost;
          if (aCost == null && bCost == null)
            cmp = 0;
          else if (aCost == null)
            cmp = -1;
          else if (bCost == null)
            cmp = 1;
          else
            cmp = aCost.compareTo(bCost);
          break;
        case InvoiceSortField.profit:
          final aProf = a.profit;
          final bProf = b.profit;
          if (aProf == null && bProf == null)
            cmp = 0;
          else if (aProf == null)
            cmp = -1;
          else if (bProf == null)
            cmp = 1;
          else
            cmp = aProf.compareTo(bProf);
          break;
        case InvoiceSortField.margin:
          final aMar = a.margin;
          final bMar = b.margin;
          if (aMar == null && bMar == null)
            cmp = 0;
          else if (aMar == null)
            cmp = -1;
          else if (bMar == null)
            cmp = 1;
          else
            cmp = aMar.compareTo(bMar);
          break;
        case InvoiceSortField.status:
          cmp = a.status.compareTo(b.status);
          break;
      }
      return ascending ? cmp : -cmp;
    });

    return filtered;
  }

  static InvoiceReportPageResult paginate(
    List<InvoiceReportRow> allRows,
    int requestedPage, {
    int pageSize = invoiceReportPageSize,
  }) {
    final total = allRows.length;
    final totalPages =
        total == 0 ? 1 : ((total - 1) ~/ pageSize) + 1;
    final page =
        requestedPage < 1
            ? 1
            : (requestedPage > totalPages
                ? totalPages
                : requestedPage);

    final start = (page - 1) * pageSize;
    final end =
        (start + pageSize) > total
            ? total
            : (start + pageSize);
    final slice =
        total == 0
            ? <InvoiceReportRow>[]
            : allRows.sublist(start, end);

    double sumRevenue = 0;
    double sumPaid = 0;
    double sumBalance = 0;
    for (final r in allRows) {
      sumRevenue += (r.invoiceTotal ?? 0);
      sumPaid += r.amountPaid;
      sumBalance += (r.balance ?? 0);
    }

    return InvoiceReportPageResult(
      rows: slice,
      totalCount: total,
      page: page,
      pageSize: pageSize,
      totalPages: totalPages,
      totalRevenue: sumRevenue,
      totalAmountPaid: sumPaid,
      totalBalance: sumBalance,
    );
  }
}

const String invoiceNoStaffLabel = 'No staff';
const String invoiceNoCustomerLabel = 'No customer';
const String invoiceUnpaidChannel = 'Unpaid';

enum InvoiceGroupSortField {
  name,
  count,
  total,
  paid,
  balance,
}

/// One table row when grouped: every invoice of one staff member,
/// customer or payment channel.
class InvoiceReportGroupRow {
  final String key;

  /// "No staff", "No customer" or the Unpaid channel: always
  /// shown last.
  final bool isNone;
  final String _noneLabel;

  /// Most recent name in the group. Null when none was saved.
  String? name;

  int count = 0;

  /// Same null rules as [InvoiceReportQuery.paginate]: an unknown
  /// total or balance counts as 0.
  double total = 0;
  double paid = 0;
  double balance = 0;

  InvoiceReportGroupRow({
    required this.key,
    required this.isNone,
    required this.name,
    String noneLabel = '',
  }) : _noneLabel = noneLabel;

  String get label =>
      isNone ? _noneLabel : (name ?? 'Not Set');

  void add(InvoiceReportRow r) {
    count++;
    total += r.invoiceTotal ?? 0;
    paid += r.amountPaid;
    balance += r.balance ?? 0;
  }
}

/// Result of [InvoiceReportGrouping.paginate]. Totals cover every
/// group, not just this page.
class InvoiceReportGroupPage {
  final List<InvoiceReportGroupRow> rows;
  final int totalCount;
  final int page;
  final int pageSize;
  final int totalPages;
  final int totalInvoices;
  final double totalRevenue;
  final double totalAmountPaid;
  final double totalBalance;

  const InvoiceReportGroupPage({
    required this.rows,
    required this.totalCount,
    required this.page,
    required this.pageSize,
    required this.totalPages,
    this.totalInvoices = 0,
    this.totalRevenue = 0,
    this.totalAmountPaid = 0,
    this.totalBalance = 0,
  });

  int get firstIndex =>
      totalCount == 0 ? 0 : (page - 1) * pageSize + 1;
  int get lastIndex =>
      totalCount == 0
          ? 0
          : ((page - 1) * pageSize + rows.length);
}

/// "Group by" Staff, Customer or payment Channel. Channel is the
/// derived [InvoiceReportRow.paymentChannel] (from the payment
/// receipts), so each invoice is in exactly one group.
class InvoiceReportGrouping {
  static String? _text(String? value) {
    if (value == null) return null;
    final t = value.trim();
    return t.isEmpty ? null : t;
  }

  /// Groups [rows] that already passed the filters
  /// (`InvoiceReportQuery.filterAndSort`). Each group shows its
  /// most recent name.
  static List<InvoiceReportGroupRow> build(
    List<InvoiceReportRow> rows,
    ReportGroupBy by,
  ) {
    if (by == ReportGroupBy.off) return [];
    final newestFirst = List<InvoiceReportRow>.from(rows)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final groups = <String, InvoiceReportGroupRow>{};
    for (final r in newestFirst) {
      String? key;
      String? name;
      String noneLabel = '';
      switch (by) {
        case ReportGroupBy.staff:
          key = _text(r.invoice.staffId);
          name = _text(r.invoice.staffName);
          noneLabel = invoiceNoStaffLabel;
          break;
        case ReportGroupBy.customer:
          key = _text(r.invoice.customerUuid);
          name = r.customerName;
          noneLabel = invoiceNoCustomerLabel;
          break;
        case ReportGroupBy.channel:
          name = r.paymentChannel;
          key =
              r.paymentChannel == invoiceUnpaidChannel
                  ? null
                  : r.paymentChannel;
          noneLabel = invoiceUnpaidChannel;
          break;
        case ReportGroupBy.off:
          break;
      }
      final k = key ?? '__none__';
      final g = groups.putIfAbsent(
        k,
        () => InvoiceReportGroupRow(
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

  /// Sorted copy. The none row is always last; ties: label, then
  /// key.
  static List<InvoiceReportGroupRow> sort(
    List<InvoiceReportGroupRow> groups, {
    required InvoiceGroupSortField field,
    required bool ascending,
  }) {
    int compare(
      InvoiceReportGroupRow a,
      InvoiceReportGroupRow b,
    ) {
      if (a.isNone != b.isNone) return a.isNone ? 1 : -1;
      int c;
      switch (field) {
        case InvoiceGroupSortField.name:
          c = a.label.toLowerCase().compareTo(
            b.label.toLowerCase(),
          );
          break;
        case InvoiceGroupSortField.count:
          c = a.count.compareTo(b.count);
          break;
        case InvoiceGroupSortField.total:
          c = a.total.compareTo(b.total);
          break;
        case InvoiceGroupSortField.paid:
          c = a.paid.compareTo(b.paid);
          break;
        case InvoiceGroupSortField.balance:
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

    return List<InvoiceReportGroupRow>.from(groups)
      ..sort(compare);
  }

  static InvoiceReportGroupPage paginate(
    List<InvoiceReportGroupRow> sorted,
    int requestedPage, {
    int pageSize = invoiceReportPageSize,
  }) {
    final total = sorted.length;
    final totalPages =
        total == 0 ? 1 : ((total - 1) ~/ pageSize) + 1;
    final page =
        requestedPage < 1
            ? 1
            : (requestedPage > totalPages
                ? totalPages
                : requestedPage);
    final start = (page - 1) * pageSize;
    final end =
        (start + pageSize) > total
            ? total
            : (start + pageSize);

    int invoices = 0;
    double sumTotal = 0;
    double sumPaid = 0;
    double sumBalance = 0;
    for (final g in sorted) {
      invoices += g.count;
      sumTotal += g.total;
      sumPaid += g.paid;
      sumBalance += g.balance;
    }

    return InvoiceReportGroupPage(
      rows:
          total == 0
              ? <InvoiceReportGroupRow>[]
              : sorted.sublist(start, end),
      totalCount: total,
      page: page,
      pageSize: pageSize,
      totalPages: totalPages,
      totalInvoices: invoices,
      totalRevenue: sumTotal,
      totalAmountPaid: sumPaid,
      totalBalance: sumBalance,
    );
  }
}
