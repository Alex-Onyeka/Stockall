import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_item_purchase_record/temp_item_purchase_record.dart';
import 'package:stockall/classes/temp_purchase/purchase_payments.dart';
import 'package:stockall/classes/temp_purchase/temp_purchase.dart';
import 'package:stockall/constants/generate_barcode.dart';
import 'package:stockall/pages/report/components/report_pager.dart';
import 'package:stockall/pages/report/purchase_report/purchase_report_table/class/purchase_lines.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

/// Page size, same as the Receipts Report table.
const int purchaseReportPageSize = 100;

/// Filter key for the "unassigned" bucket (no supplier, no staff,
/// no department, no payment).
const String purchaseReportNoneKey = '__none__';

/// Amounts closer than this are equal (float rounding).
const double purchaseAmountTolerance = 0.005;

const String purchasesNoStaffLabel = 'No staff';
const String purchasesNoSupplierLabel = 'No supplier';
const String purchasesUnpaidLabel = 'Unpaid';

/// Payment to the supplier, from the amounts paid.
enum PurchaseStatus { paid, partlyPaid, unpaid }

extension PurchaseStatusLabel on PurchaseStatus {
  String get label {
    switch (this) {
      case PurchaseStatus.paid:
        return 'Paid';
      case PurchaseStatus.partlyPaid:
        return 'Partly Paid';
      case PurchaseStatus.unpaid:
        return 'Unpaid';
    }
  }
}

/// How the supplier was paid. A purchase without payments has no
/// channel (the "Unpaid" bucket).
enum PurchaseChannel { cash, bank, split }

extension PurchaseChannelLabel on PurchaseChannel {
  String get label {
    switch (this) {
      case PurchaseChannel.cash:
        return 'Cash';
      case PurchaseChannel.bank:
        return 'Bank';
      case PurchaseChannel.split:
        return 'Split';
    }
  }
}

enum PurchasesSortField {
  createdAt,
  supplier,
  staff,
  items,
  total,
  paid,
  balance,
}

/// Status and channel rules, shared by the columns and the filters
/// so a purchase is never classified twice.
class PurchaseReportClassifier {
  static double paidAmount(List<PurchasePayments> payments) =>
      payments.fold<double>(0, (sum, p) => sum + p.amount);

  /// Paid when nothing is owed (a zero total and overpaid
  /// included), Partly Paid when something was paid.
  static PurchaseStatus status(double total, double paid) {
    final balance = total - paid;
    if (balance <= purchaseAmountTolerance) {
      return PurchaseStatus.paid;
    }
    if (paid > purchaseAmountTolerance) {
      return PurchaseStatus.partlyPaid;
    }
    return PurchaseStatus.unpaid;
  }

  static bool overpaid(double total, double paid) =>
      total - paid < -purchaseAmountTolerance;

  /// From the methods of the payments made. Unknown methods are
  /// Cash, as on receipts. Null without any payment.
  static PurchaseChannel? channel(
    List<PurchasePayments> payments,
  ) {
    final used = <PurchaseChannel>{};
    for (final p in payments) {
      if (p.amount <= purchaseAmountTolerance) continue;
      final method = p.paymentMethod.trim().toLowerCase();
      used.add(
        method == 'bank' || method == 'transfer'
            ? PurchaseChannel.bank
            : PurchaseChannel.cash,
      );
    }
    if (used.isEmpty) return null;
    if (used.length > 1) return PurchaseChannel.split;
    return used.first;
  }
}

/// One table row. Every value is calculated once, when the row is
/// built. `null` means unknown or not applicable (shown as "—").
class PurchaseReportRow {
  final TempPurchase purchase;
  final String displayId;

  /// `createdAt` in local time.
  final DateTime createdAt;
  final PurchaseLineSource lineSource;

  final int? lineCount;
  final double? items;

  /// Sum of the line totals.
  final double? lineTotal;

  /// Purchase total (a custom total when one was set).
  final double total;
  final double paid;

  /// Still owed: total - paid, never below 0. An overpaid
  /// purchase owes 0 and is flagged by [overpaid].
  final double balance;
  final PurchaseStatus status;
  final bool overpaid;

  /// paid - total when [overpaid], else 0.
  final double overpaidBy;
  final PurchaseChannel? channel;

  /// A custom total that differs from the line total.
  final bool hasAdjustment;

  /// total - lineTotal, when [hasAdjustment].
  final double? adjustment;

  /// Stored supplier name, else the current supplier list's.
  final String? _supplierName;

  PurchaseReportRow({
    required this.purchase,
    required this.displayId,
    required this.createdAt,
    required this.lineSource,
    required this.lineCount,
    required this.items,
    required this.lineTotal,
    required this.total,
    required this.paid,
    required this.balance,
    required this.status,
    required this.overpaid,
    required this.overpaidBy,
    required this.channel,
    required this.hasAdjustment,
    required this.adjustment,
    String? supplierName,
  }) : _supplierName = supplierName;

  String get uuid => purchase.uuid ?? '';

  String? get staffKey => _key(purchase.staffId);
  String? get supplierKey => _key(purchase.supplierId);
  String? get departmentKey =>
      _key(purchase.departmentUuid);
  String get channelKey =>
      channel?.name ?? purchaseReportNoneKey;

  String? get staffName => _name(purchase.staffName);
  String? get supplierName => _supplierName;
  String? get departmentName =>
      _name(purchase.departmentName);

  String get staffLabel => staffName ?? 'Not Set';
  String get supplierLabel =>
      supplierKey == null
          ? purchasesNoSupplierLabel
          : supplierName ?? 'Not Set';
  String get departmentLabel =>
      departmentKey == null
          ? 'No Department'
          : departmentName ?? 'No Department';
  String get channelLabel =>
      channel?.label ?? purchasesUnpaidLabel;

  /// The key rule of [supplierKey] etc., for matching other
  /// records (e.g. suppliers) to rows.
  static String? keyOf(String? value) => _key(value);

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

/// Builds [PurchaseReportRow]s. No purchase is modified.
class PurchaseReportRowBuilder {
  /// `#` and the digits of the uuid, as purchase history shows it.
  /// `returnOnlyDigits` throws for a uuid with under 12 digits;
  /// the uuid itself is shown then, so the row is never dropped.
  static String displayId(TempPurchase purchase) {
    final uuid = purchase.uuid ?? '';
    try {
      return '#${returnOnlyDigits(uuid)}';
    } on ArgumentError {
      return '#$uuid';
    }
  }

  /// Name saved on the purchase, else the current name of its
  /// supplier, else null.
  static String? supplierName(
    TempPurchase purchase,
    Map<String, String> supplierNames,
  ) {
    final stored = PurchaseReportRow._name(
      purchase.supplierName,
    );
    if (stored != null) return stored;
    final id = PurchaseReportRow._key(purchase.supplierId);
    if (id == null) return null;
    return PurchaseReportRow._name(supplierNames[id]);
  }

  static PurchaseReportRow build({
    required TempPurchase purchase,
    required Map<String, List<TempItemPurchaseRecord>>
    legacyLines,
    Map<String, String> supplierNames = const {},
  }) {
    final (:lines, :source) = PurchaseLines.linesFor(
      purchase,
      legacyLines,
    );

    double? items;
    double? lineTotal;
    if (lines != null) {
      items = lines.fold<double>(
        0,
        (sum, line) => sum + PurchaseLines.lineItemCount(line),
      );
      lineTotal = lines.fold<double>(
        0,
        (sum, line) => sum + PurchaseLines.lineTotal(line),
      );
    }

    final total = purchase.total ?? 0;
    final paid = PurchaseReportClassifier.paidAmount(
      purchase.purchasePayments,
    );
    final hasAdjustment =
        purchase.isCustomPriceSet &&
        lineTotal != null &&
        (total - lineTotal).abs() > purchaseAmountTolerance;
    final overpaid = PurchaseReportClassifier.overpaid(
      total,
      paid,
    );
    final owed = total - paid;

    return PurchaseReportRow(
      purchase: purchase,
      displayId: displayId(purchase),
      createdAt: purchase.createdAt.toLocal(),
      lineSource: source,
      lineCount: lines?.length,
      items: items,
      lineTotal: lineTotal,
      total: total,
      paid: paid,
      balance: owed > 0 ? owed : 0,
      status: PurchaseReportClassifier.status(total, paid),
      overpaid: overpaid,
      overpaidBy: overpaid ? -owed : 0,
      channel: PurchaseReportClassifier.channel(
        purchase.purchasePayments,
      ),
      hasAdjustment: hasAdjustment,
      adjustment: hasAdjustment ? total - lineTotal : null,
      supplierName: supplierName(purchase, supplierNames),
    );
  }

  /// [pendingDeletedUuids]: purchases queued for deletion, left
  /// out even if still loaded.
  static List<PurchaseReportRow> buildAll({
    required List<TempPurchase> purchases,
    List<TempItemPurchaseRecord> legacyLines = const [],
    Map<String, String> supplierNames = const {},
    Set<String> pendingDeletedUuids = const {},
  }) {
    final legacy = PurchaseLines.legacyLinesByPurchase(
      legacyLines,
    );
    final rows = <PurchaseReportRow>[];
    for (final purchase in purchases) {
      if (pendingDeletedUuids.contains(purchase.uuid)) {
        continue;
      }
      try {
        rows.add(
          build(
            purchase: purchase,
            legacyLines: legacy,
            supplierNames: supplierNames,
          ),
        );
      } catch (_) {
        // A single malformed purchase must never break the report.
      }
    }
    return rows;
  }
}

/// Purchases the current user may see. Same rule as
/// `ReceiptsReportAccess.scope`.
class PurchaseReportAccess {
  static List<TempPurchase> scope({
    required List<TempPurchase> purchases,
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
    return purchases.where((purchase) {
      if (restrictDepartment &&
          purchase.departmentUuid != currentDepartmentUuid) {
        return false;
      }
      if (!canViewAllTransactions &&
          purchase.staffId != currentUserId) {
        return false;
      }
      return true;
    }).toList();
  }
}

/// All user-selectable filters, combined with AND. Keys are the
/// row keys ([PurchaseReportRow.supplierKey] etc.) or
/// [purchaseReportNoneKey], so an analysis row can open the table
/// with the same set.
class PurchaseReportFilters {
  String search;
  String? staffKey;
  String? supplierKey;
  String? departmentKey;

  /// [PurchaseChannel.name], or [purchaseReportNoneKey] for
  /// purchases without payments.
  String? channelKey;
  PurchaseStatus? status;
  double? totalMin;
  double? totalMax;
  double? balanceMin;
  double? balanceMax;

  PurchaseReportFilters({
    this.search = '',
    this.staffKey,
    this.supplierKey,
    this.departmentKey,
    this.channelKey,
    this.status,
    this.totalMin,
    this.totalMax,
    this.balanceMin,
    this.balanceMax,
  });

  PurchaseReportFilters copy() => PurchaseReportFilters(
    search: search,
    staffKey: staffKey,
    supplierKey: supplierKey,
    departmentKey: departmentKey,
    channelKey: channelKey,
    status: status,
    totalMin: totalMin,
    totalMax: totalMax,
    balanceMin: balanceMin,
    balanceMax: balanceMax,
  );

  /// Message for a min above its max, otherwise null.
  static String? rangeError(double? min, double? max) =>
      ReceiptsReportFilters.rangeError(min, max);

  String? get totalRangeError =>
      rangeError(totalMin, totalMax);
  String? get balanceRangeError =>
      rangeError(balanceMin, balanceMax);

  /// Set and valid. An invalid range is not applied.
  bool get totalRangeActive =>
      (totalMin != null || totalMax != null) &&
      totalRangeError == null;
  bool get balanceRangeActive =>
      (balanceMin != null || balanceMax != null) &&
      balanceRangeError == null;

  int get activeCount =>
      (staffKey != null ? 1 : 0) +
      (supplierKey != null ? 1 : 0) +
      (departmentKey != null ? 1 : 0) +
      (channelKey != null ? 1 : 0) +
      (status != null ? 1 : 0) +
      (totalMin != null || totalMax != null ? 1 : 0) +
      (balanceMin != null || balanceMax != null ? 1 : 0);

  bool get hasAnything =>
      activeCount > 0 || search.trim().isNotEmpty;

  void clearAll() {
    search = '';
    clearFiltersOnly();
  }

  void clearFiltersOnly() {
    staffKey = null;
    supplierKey = null;
    departmentKey = null;
    channelKey = null;
    status = null;
    totalMin = null;
    totalMax = null;
    balanceMin = null;
    balanceMax = null;
  }

  /// Null [filterKey] matches all; [purchaseReportNoneKey]
  /// matches a null [rowKey].
  static bool keyMatches(
    String? filterKey,
    String? rowKey,
  ) {
    if (filterKey == null) return true;
    if (filterKey == purchaseReportNoneKey) {
      return rowKey == null;
    }
    return rowKey == filterKey;
  }

  static bool inRange(
    double value,
    double? min,
    double? max,
  ) => ReceiptsReportFilters.inRange(value, min, max);

  bool matchesSearch(
    PurchaseReportRow r, {
    required bool departmentsEnabled,
  }) {
    final q = search.trim().toLowerCase();
    if (q.isEmpty) return true;
    bool has(String? s) =>
        s != null && s.toLowerCase().contains(q);
    return has(r.supplierName) ||
        has(r.staffName) ||
        (departmentsEnabled && has(r.departmentName)) ||
        has(r.displayId);
  }

  /// [departmentsEnabled] switches off the department search and
  /// filter, hidden in the UI then.
  bool matches(
    PurchaseReportRow r, {
    required bool departmentsEnabled,
  }) {
    if (!matchesSearch(
      r,
      departmentsEnabled: departmentsEnabled,
    )) {
      return false;
    }
    if (!keyMatches(staffKey, r.staffKey)) return false;
    if (!keyMatches(supplierKey, r.supplierKey)) {
      return false;
    }
    if (departmentsEnabled &&
        !keyMatches(departmentKey, r.departmentKey)) {
      return false;
    }
    if (channelKey != null && r.channelKey != channelKey) {
      return false;
    }
    if (status != null && r.status != status) return false;
    if (totalRangeActive &&
        !inRange(r.total, totalMin, totalMax)) {
      return false;
    }
    if (balanceRangeActive &&
        !inRange(r.balance, balanceMin, balanceMax)) {
      return false;
    }
    return true;
  }
}

/// One choice in a staff / supplier / department / channel filter.
class PurchaseFilterOption {
  final String key;
  final String label;

  const PurchaseFilterOption(this.key, this.label);
}

/// Filter choices taken from the purchases themselves, so staff and
/// suppliers that were deleted since can still be selected. Each
/// key shows its most recent name.
class PurchaseReportOptions {
  static List<PurchaseFilterOption> _build(
    List<PurchaseReportRow> rows, {
    required String? Function(PurchaseReportRow) key,
    required String? Function(PurchaseReportRow) name,
    required String fallbackName,
    required String noneLabel,
  }) {
    final newestFirst = List<PurchaseReportRow>.from(rows)
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
              (e) => PurchaseFilterOption(e.key, e.value),
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
        PurchaseFilterOption(
          purchaseReportNoneKey,
          noneLabel,
        ),
      );
    }
    return options;
  }

  static List<PurchaseFilterOption> staff(
    List<PurchaseReportRow> rows,
  ) => _build(
    rows,
    key: (r) => r.staffKey,
    name: (r) => r.staffName,
    fallbackName: 'Not Set',
    noneLabel: purchasesNoStaffLabel,
  );

  static List<PurchaseFilterOption> suppliers(
    List<PurchaseReportRow> rows,
  ) => _build(
    rows,
    key: (r) => r.supplierKey,
    name: (r) => r.supplierName,
    fallbackName: 'Not Set',
    noneLabel: purchasesNoSupplierLabel,
  );

  static List<PurchaseFilterOption> departments(
    List<PurchaseReportRow> rows,
  ) => _build(
    rows,
    key: (r) => r.departmentKey,
    name: (r) => r.departmentName,
    fallbackName: 'No Department',
    noneLabel: 'No Department',
  );

  /// Cash, Bank, Split, then Unpaid, always all four.
  static List<PurchaseFilterOption> channels() => [
    for (final c in PurchaseChannel.values)
      PurchaseFilterOption(c.name, c.label),
    const PurchaseFilterOption(
      purchaseReportNoneKey,
      purchasesUnpaidLabel,
    ),
  ];
}

/// Result of [PurchaseReportQuery.paginate].
class PurchaseReportPage {
  final List<PurchaseReportRow> rows;
  final int totalCount;
  final int page; // 1-based, already clamped
  final int totalPages;

  /// Totals of every filtered row (not just this page). Unknown
  /// values ("—") are left out.
  final double totalItems;
  final double totalLineTotal;
  final double total;
  final double totalPaid;
  final double totalBalance;

  const PurchaseReportPage({
    required this.rows,
    required this.totalCount,
    required this.page,
    required this.totalPages,
    this.totalItems = 0,
    this.totalLineTotal = 0,
    this.total = 0,
    this.totalPaid = 0,
    this.totalBalance = 0,
  });

  int get firstIndex =>
      totalCount == 0
          ? 0
          : (page - 1) * purchaseReportPageSize + 1;
  int get lastIndex =>
      firstIndex == 0 ? 0 : firstIndex + rows.length - 1;
}

class PurchaseReportQuery {
  static int cmp<T extends Comparable>(
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
  static List<PurchaseReportRow> filterAndSort({
    required List<PurchaseReportRow> rows,
    required ReceiptsReportPeriod period,
    required PurchaseReportFilters filters,
    required PurchasesSortField sortField,
    required bool ascending,
    required bool departmentsEnabled,
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
                  ),
            )
            .toList();

    int compare(PurchaseReportRow a, PurchaseReportRow b) {
      int c;
      switch (sortField) {
        case PurchasesSortField.createdAt:
          c = cmp(a.createdAt, b.createdAt, ascending);
          break;
        case PurchasesSortField.supplier:
          c = cmp(
            a.supplierName?.toLowerCase(),
            b.supplierName?.toLowerCase(),
            ascending,
          );
          break;
        case PurchasesSortField.staff:
          c = cmp(
            a.staffName?.toLowerCase(),
            b.staffName?.toLowerCase(),
            ascending,
          );
          break;
        case PurchasesSortField.items:
          c = cmp(a.items, b.items, ascending);
          break;
        case PurchasesSortField.total:
          c = cmp(a.total, b.total, ascending);
          break;
        case PurchasesSortField.paid:
          c = cmp(a.paid, b.paid, ascending);
          break;
        case PurchasesSortField.balance:
          c = cmp(a.balance, b.balance, ascending);
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

  static PurchaseReportPage paginate(
    List<PurchaseReportRow> sorted,
    int requestedPage,
  ) {
    final b = reportPageBounds(
      sorted.length,
      requestedPage,
      pageSize: purchaseReportPageSize,
    );

    double items = 0;
    double lineTotal = 0;
    double total = 0;
    double paid = 0;
    double balance = 0;
    for (final r in sorted) {
      items += r.items ?? 0;
      lineTotal += r.lineTotal ?? 0;
      total += r.total;
      paid += r.paid;
      balance += r.balance;
    }

    return PurchaseReportPage(
      rows:
          sorted.isEmpty
              ? const []
              : sorted.sublist(b.start, b.end),
      totalCount: sorted.length,
      page: b.page,
      totalPages: b.pages,
      totalItems: items,
      totalLineTotal: lineTotal,
      total: total,
      totalPaid: paid,
      totalBalance: balance,
    );
  }
}

/// "Group by" of the Purchase Report table. A view option, not a
/// filter: Reset All keeps it.
enum PurchaseGroupBy { off, staff, supplier, channel }

extension PurchaseGroupByLabel on PurchaseGroupBy {
  String get label {
    switch (this) {
      case PurchaseGroupBy.off:
        return 'Off';
      case PurchaseGroupBy.staff:
        return 'Staff';
      case PurchaseGroupBy.supplier:
        return 'Supplier';
      case PurchaseGroupBy.channel:
        return 'Channel';
    }
  }

  /// Pager label for the grouped rows.
  String get pagerLabel {
    switch (this) {
      case PurchaseGroupBy.staff:
        return 'staff';
      case PurchaseGroupBy.supplier:
        return 'suppliers';
      case PurchaseGroupBy.channel:
        return 'channels';
      case PurchaseGroupBy.off:
        return 'rows';
    }
  }
}

enum PurchaseGroupSortField {
  name,
  count,
  items,
  total,
  paid,
  balance,
}

/// One table row when grouped: every purchase of one staff member,
/// supplier or channel. Values are raw, as on [PurchaseReportRow].
class PurchaseGroupRow {
  final String key;

  /// The "No staff" / "No supplier" / "Unpaid" row, always last.
  final bool isNone;
  final String _noneLabel;

  /// Most recent name in the group. Null when none was saved.
  String? name;

  int count = 0;

  /// Sum of the known item counts. Null when no purchase had one.
  double? items;
  double total = 0;
  double paid = 0;
  double balance = 0;

  PurchaseGroupRow({
    required this.key,
    required this.isNone,
    required this.name,
    String noneLabel = '',
  }) : _noneLabel = noneLabel;

  String get label =>
      isNone ? _noneLabel : (name ?? 'Not Set');

  void add(PurchaseReportRow r) {
    count++;
    if (r.items != null) items = (items ?? 0) + r.items!;
    total += r.total;
    paid += r.paid;
    balance += r.balance;
  }
}

/// Result of [PurchaseGrouping.paginate]. Totals cover every
/// group, not just this page.
class PurchaseGroupPage {
  final List<PurchaseGroupRow> rows;
  final int totalCount;
  final int page; // 1-based, already clamped
  final int totalPages;

  final int totalPurchases;
  final double? totalItems;
  final double total;
  final double totalPaid;
  final double totalBalance;

  const PurchaseGroupPage({
    required this.rows,
    required this.totalCount,
    required this.page,
    required this.totalPages,
    this.totalPurchases = 0,
    this.totalItems,
    this.total = 0,
    this.totalPaid = 0,
    this.totalBalance = 0,
  });

  int get firstIndex =>
      totalCount == 0
          ? 0
          : (page - 1) * purchaseReportPageSize + 1;
  int get lastIndex =>
      firstIndex == 0 ? 0 : firstIndex + rows.length - 1;
}

/// "Group by" Staff, Supplier or Channel.
class PurchaseGrouping {
  /// Groups [rows] that already passed the period and filters
  /// (`PurchaseReportQuery.filterAndSort`). Each group shows its
  /// most recent name.
  static List<PurchaseGroupRow> build(
    List<PurchaseReportRow> rows,
    PurchaseGroupBy by,
  ) {
    if (by == PurchaseGroupBy.off) return [];
    final newestFirst = List<PurchaseReportRow>.from(rows)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final groups = <String, PurchaseGroupRow>{};
    for (final r in newestFirst) {
      final String? key;
      final String? name;
      String noneLabel = '';
      switch (by) {
        case PurchaseGroupBy.staff:
          key = r.staffKey;
          name = r.staffName;
          noneLabel = purchasesNoStaffLabel;
          break;
        case PurchaseGroupBy.supplier:
          key = r.supplierKey;
          name = r.supplierName;
          noneLabel = purchasesNoSupplierLabel;
          break;
        case PurchaseGroupBy.channel:
          key = r.channel?.name;
          name = r.channel?.label;
          noneLabel = purchasesUnpaidLabel;
          break;
        case PurchaseGroupBy.off:
          key = null;
          name = null;
      }
      final g = groups.putIfAbsent(
        key ?? purchaseReportNoneKey,
        () => PurchaseGroupRow(
          key: key ?? purchaseReportNoneKey,
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

  /// Sorted copy. The none row is always last; nulls sink to the
  /// bottom; ties: label, then key.
  static List<PurchaseGroupRow> sort(
    List<PurchaseGroupRow> groups, {
    required PurchaseGroupSortField field,
    required bool ascending,
  }) {
    int compare(PurchaseGroupRow a, PurchaseGroupRow b) {
      if (a.isNone != b.isNone) return a.isNone ? 1 : -1;
      int c;
      switch (field) {
        case PurchaseGroupSortField.name:
          c = PurchaseReportQuery.cmp(
            a.label.toLowerCase(),
            b.label.toLowerCase(),
            ascending,
          );
          break;
        case PurchaseGroupSortField.count:
          c = PurchaseReportQuery.cmp(
            a.count,
            b.count,
            ascending,
          );
          break;
        case PurchaseGroupSortField.items:
          c = PurchaseReportQuery.cmp(
            a.items,
            b.items,
            ascending,
          );
          break;
        case PurchaseGroupSortField.total:
          c = PurchaseReportQuery.cmp(
            a.total,
            b.total,
            ascending,
          );
          break;
        case PurchaseGroupSortField.paid:
          c = PurchaseReportQuery.cmp(
            a.paid,
            b.paid,
            ascending,
          );
          break;
        case PurchaseGroupSortField.balance:
          c = PurchaseReportQuery.cmp(
            a.balance,
            b.balance,
            ascending,
          );
          break;
      }
      if (c != 0) return c;
      final n = a.label.toLowerCase().compareTo(
        b.label.toLowerCase(),
      );
      return n != 0 ? n : a.key.compareTo(b.key);
    }

    return List<PurchaseGroupRow>.from(groups)
      ..sort(compare);
  }

  static PurchaseGroupPage paginate(
    List<PurchaseGroupRow> sorted,
    int requestedPage,
  ) {
    final b = reportPageBounds(
      sorted.length,
      requestedPage,
      pageSize: purchaseReportPageSize,
    );

    int purchases = 0;
    double? items;
    double total = 0;
    double paid = 0;
    double balance = 0;
    for (final g in sorted) {
      purchases += g.count;
      if (g.items != null) items = (items ?? 0) + g.items!;
      total += g.total;
      paid += g.paid;
      balance += g.balance;
    }

    return PurchaseGroupPage(
      rows:
          sorted.isEmpty
              ? const []
              : sorted.sublist(b.start, b.end),
      totalCount: sorted.length,
      page: b.page,
      totalPages: b.pages,
      totalPurchases: purchases,
      totalItems: items,
      total: total,
      totalPaid: paid,
      totalBalance: balance,
    );
  }
}

/// Filters, grouping, sorts and page of the Purchase Report table.
class PurchaseReportTableState {
  final PurchaseReportFilters filters;
  PurchaseGroupBy groupBy;
  PurchasesSortField sortField;
  bool ascending;
  PurchaseGroupSortField groupSortField;
  bool groupAscending;
  int page;

  PurchaseReportTableState({
    PurchaseReportFilters? filters,
    this.groupBy = PurchaseGroupBy.off,
    this.sortField = PurchasesSortField.createdAt,
    this.ascending = false,
    this.groupSortField = PurchaseGroupSortField.total,
    this.groupAscending = false,
    this.page = 1,
  }) : filters = filters ?? PurchaseReportFilters();

  bool get grouped => groupBy != PurchaseGroupBy.off;

  /// Reset All: clears the search and every filter. Grouping and
  /// sorting are view options and stay.
  void resetAll() {
    filters.clearAll();
    page = 1;
  }
}
