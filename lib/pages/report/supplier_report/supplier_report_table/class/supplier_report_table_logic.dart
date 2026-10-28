import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_suppliers/suppliers_class.dart';
import 'package:stockall/pages/report/components/report_pager.dart';
import 'package:stockall/pages/report/purchase_report/purchase_report_table/class/purchase_report_table_logic.dart';
import 'package:stockall/pages/report/purchase_report/purchase_summary/class/purchase_summary_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

// Supplier Report: one row per supplier, built on the Purchase
// Report rows so every amount (total, paid, clamped balance) is
// the purchase report's own.

/// Page size, same as the Purchase Report table.
const int supplierReportPageSize = 100;

const String supplierDeletedLabel = 'Deleted supplier';

/// The period the supplier pages open on. A supplier list is a
/// lifetime view, so all time; today without the View Date
/// permission, since the period button is then locked to today.
/// [initial] (e.g. the table's period, passed to the analysis)
/// wins when the user may pick dates.
ReceiptsReportPeriod supplierReportInitialPeriod({
  required bool canPickDate,
  ReceiptsReportPeriod? initial,
  DateTime? now,
  TimeOfDay? closingTime,
}) {
  if (!canPickDate) {
    return ReceiptsReportPeriod.today(
      now: now,
      closingTime: closingTime,
    );
  }
  return initial ?? const ReceiptsReportPeriod.allTime();
}

/// Suppliers the current user may see. Same rule as
/// `SuppliersProvider.suppliersMain()`: with departments on, a
/// supplier without a department is shared by all of them;
/// otherwise it must be the current department's. Users who view
/// all departments see every supplier until they pick one.
class SupplierReportAccess {
  static List<SuppliersClass> scope({
    required List<SuppliersClass> suppliers,
    required bool departmentsEnabled,
    required bool canViewAllDepartments,
    required String? currentDepartmentUuid,
  }) {
    final restrict =
        departmentsEnabled &&
        (!canViewAllDepartments ||
            currentDepartmentUuid != null);
    if (!restrict) return List.of(suppliers);
    return suppliers
        .where(
          (s) =>
              s.departmentId == null ||
              s.departmentId == currentDepartmentUuid,
        )
        .toList();
  }
}

/// One table row: a supplier and the totals of its purchases in
/// the period. `null` means not set (shown as "—").
class SupplierReportRow {
  /// The supplier's uuid, as [PurchaseReportRow.supplierKey], so
  /// the purchase table can be opened on its purchases.
  final String key;

  /// The current supplier record. Null when it was deleted: only
  /// its purchases remain.
  final SuppliersClass? supplier;

  /// In the user's supplier scope. False for a supplier only
  /// reached through visible purchases (another department's, or
  /// deleted).
  final bool inScope;

  /// Current name, else the newest name saved on its purchases.
  final String? name;
  final String? phone;
  final String? email;
  final String? address;
  final String? city;
  final String? state;
  final String? country;

  final int purchaseCount;
  final double spend;
  final double paid;

  /// Still owed: the sum of the purchases' clamped balances, as
  /// the purchase table's Balance total.
  final double balance;
  final DateTime? firstPurchase;
  final DateTime? lastPurchase;

  const SupplierReportRow({
    required this.key,
    required this.supplier,
    required this.inScope,
    required this.name,
    this.phone,
    this.email,
    this.address,
    this.city,
    this.state,
    this.country,
    this.purchaseCount = 0,
    this.spend = 0,
    this.paid = 0,
    this.balance = 0,
    this.firstPurchase,
    this.lastPurchase,
  });

  bool get isDeleted => supplier == null;

  String get label => name ?? 'Not Set';

  /// Spend per purchase; 0 without purchases.
  double get average =>
      purchaseCount == 0 ? 0 : spend / purchaseCount;

  bool get hasBalance => balance > purchaseAmountTolerance;

  /// Street and city, as one line. Null when neither is set.
  String? get addressLine {
    final parts = [address, city].whereType<String>().toList();
    return parts.isEmpty ? null : parts.join(', ');
  }

  /// Street, city, state and country, blanks skipped. Null when
  /// none is set.
  String? get fullAddress {
    final parts =
        [address, city, state, country].whereType<String>().toList();
    return parts.isEmpty ? null : parts.join(', ');
  }

  String? get countryKey => locationKey(country);
  String? get stateKey => locationKey(state);

  /// Filter key of a country or state: case and spaces ignored.
  static String? locationKey(String? value) =>
      clean(value)?.toLowerCase();

  /// Trimmed, null when blank. Edited suppliers store '' for
  /// fields left empty.
  static String? clean(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

/// Builds [SupplierReportRow]s. Nothing is modified.
class SupplierReportRowBuilder {
  /// One row per supplier in [suppliers] (the user's scope), with
  /// or without purchases, plus one per other supplier that has
  /// purchases in [purchaseRows]: details from [allSuppliers]
  /// when it still exists there, else a deleted row. Purchases
  /// without a supplier are left out.
  ///
  /// [purchaseRows] are the visible purchases
  /// (`PurchaseReportAccess.scope` applied); only those in
  /// [period] are counted.
  static List<SupplierReportRow> build({
    required List<SuppliersClass> suppliers,
    List<SuppliersClass> allSuppliers = const [],
    required List<PurchaseReportRow> purchaseRows,
    required ReceiptsReportPeriod period,
    required bool departmentsEnabled,
    TimeOfDay? closingTime,
  }) {
    final inPeriod = purchasesInPeriod(
      purchaseRows: purchaseRows,
      period: period,
      departmentsEnabled: departmentsEnabled,
      closingTime: closingTime,
    );
    final groups = {
      for (final g in PurchaseSummaryBuilder.suppliers(inPeriod))
        if (!g.isNone) g.key: g,
    };
    final firstDates = _firstDates(inPeriod);

    final known = <String, SuppliersClass>{};
    for (final s in allSuppliers) {
      final id = PurchaseReportRow.keyOf(s.uuid);
      if (id != null) known.putIfAbsent(id, () => s);
    }

    final rows = <SupplierReportRow>[];
    final seen = <String>{};
    for (final s in suppliers) {
      final id = PurchaseReportRow.keyOf(s.uuid);
      if (id == null || !seen.add(id)) continue;
      rows.add(
        _row(
          key: id,
          supplier: s,
          inScope: true,
          group: groups[id],
          firstPurchase: firstDates[id],
        ),
      );
    }
    for (final g in groups.values) {
      if (!seen.add(g.key)) continue;
      rows.add(
        _row(
          key: g.key,
          supplier: known[g.key],
          inScope: false,
          group: g,
          firstPurchase: firstDates[g.key],
        ),
      );
    }
    return rows;
  }

  /// Rows in [period], newest first, as the purchase table
  /// without filters lists them.
  static List<PurchaseReportRow> purchasesInPeriod({
    required List<PurchaseReportRow> purchaseRows,
    required ReceiptsReportPeriod period,
    required bool departmentsEnabled,
    PurchaseReportFilters? filters,
    TimeOfDay? closingTime,
  }) {
    return PurchaseReportQuery.filterAndSort(
      rows: purchaseRows,
      period: period,
      filters: filters ?? PurchaseReportFilters(),
      sortField: PurchasesSortField.createdAt,
      ascending: false,
      departmentsEnabled: departmentsEnabled,
      closingTime: closingTime,
    );
  }

  /// The row of supplier [key] from its purchases in
  /// [supplierRows] (already in the period). Used by the supplier
  /// analysis, so its KPIs are the table row's.
  static SupplierReportRow single({
    required String key,
    required SuppliersClass? supplier,
    required bool inScope,
    required List<PurchaseReportRow> supplierRows,
  }) {
    final groups = PurchaseSummaryBuilder.suppliers(
      supplierRows.where((r) => r.supplierKey == key).toList(),
    );
    return _row(
      key: key,
      supplier: supplier,
      inScope: inScope,
      group: groups.isEmpty ? null : groups.first,
      firstPurchase: _firstDates(supplierRows)[key],
    );
  }

  static Map<String, DateTime> _firstDates(
    List<PurchaseReportRow> rows,
  ) {
    final first = <String, DateTime>{};
    for (final r in rows) {
      final k = r.supplierKey;
      if (k == null) continue;
      final d = first[k];
      if (d == null || r.createdAt.isBefore(d)) {
        first[k] = r.createdAt;
      }
    }
    return first;
  }

  static SupplierReportRow _row({
    required String key,
    required SuppliersClass? supplier,
    required bool inScope,
    required PurchaseSummaryGroup? group,
    required DateTime? firstPurchase,
  }) {
    final clean = SupplierReportRow.clean;
    // The group label is the newest saved name, or "Not Set".
    final purchaseName =
        group == null || group.label == 'Not Set'
            ? null
            : group.label;
    return SupplierReportRow(
      key: key,
      supplier: supplier,
      inScope: inScope,
      name: clean(supplier?.name) ?? purchaseName,
      phone: clean(supplier?.phone),
      email: clean(supplier?.email),
      address: clean(supplier?.address),
      city: clean(supplier?.city),
      state: clean(supplier?.state),
      country: clean(supplier?.country),
      purchaseCount: group?.purchaseCount ?? 0,
      spend: group?.spend ?? 0,
      paid: group?.paid ?? 0,
      balance: group?.balance ?? 0,
      firstPurchase: firstPurchase,
      lastPurchase: group?.lastDate,
    );
  }
}

/// User-selectable filters, combined with AND. Country and state
/// are [SupplierReportRow.locationKey]s, or
/// [purchaseReportNoneKey] for suppliers without one.
class SupplierReportFilters {
  String search;
  String? countryKey;
  String? stateKey;

  /// Only suppliers still owed money.
  bool hasBalance;

  SupplierReportFilters({
    this.search = '',
    this.countryKey,
    this.stateKey,
    this.hasBalance = false,
  });

  SupplierReportFilters copy() => SupplierReportFilters(
    search: search,
    countryKey: countryKey,
    stateKey: stateKey,
    hasBalance: hasBalance,
  );

  int get activeCount =>
      (countryKey != null ? 1 : 0) +
      (stateKey != null ? 1 : 0) +
      (hasBalance ? 1 : 0);

  bool get hasAnything =>
      activeCount > 0 || search.trim().isNotEmpty;

  void clearAll() {
    search = '';
    clearFiltersOnly();
  }

  void clearFiltersOnly() {
    countryKey = null;
    stateKey = null;
    hasBalance = false;
  }

  /// Sets the country, and clears a state that is not one of
  /// that country's any more.
  void setCountry(
    String? key,
    List<SupplierReportRow> rows,
  ) {
    countryKey = key;
    if (stateKey == null) return;
    final states = SupplierReportOptions.states(
      rows,
      countryKey: key,
    );
    if (!states.any((o) => o.key == stateKey)) {
      stateKey = null;
    }
  }

  bool matchesSearch(SupplierReportRow r) {
    final q = search.trim().toLowerCase();
    if (q.isEmpty) return true;
    bool has(String? s) =>
        s != null && s.toLowerCase().contains(q);
    return has(r.name) ||
        has(r.phone) ||
        has(r.email) ||
        has(r.address) ||
        has(r.city) ||
        has(r.state) ||
        has(r.country);
  }

  bool matches(SupplierReportRow r) {
    if (!matchesSearch(r)) return false;
    if (!PurchaseReportFilters.keyMatches(
      countryKey,
      r.countryKey,
    )) {
      return false;
    }
    if (!PurchaseReportFilters.keyMatches(
      stateKey,
      r.stateKey,
    )) {
      return false;
    }
    if (hasBalance && !r.hasBalance) return false;
    return true;
  }
}

/// Country and state choices, taken from the rows. Each key shows
/// the first spelling found, A-Z, with "Not set" last when some
/// supplier has none.
class SupplierReportOptions {
  static const String notSetLabel = 'Not set';

  static List<PurchaseFilterOption> _build(
    Iterable<SupplierReportRow> rows,
    String? Function(SupplierReportRow) value,
  ) {
    final labels = <String, String>{};
    var hasNone = false;
    for (final r in rows) {
      final v = value(r);
      final k = SupplierReportRow.locationKey(v);
      if (k == null) {
        hasNone = true;
        continue;
      }
      labels.putIfAbsent(k, () => v!.trim());
    }
    final options =
        labels.entries
            .map((e) => PurchaseFilterOption(e.key, e.value))
            .toList()
          ..sort((a, b) {
            final c = a.label.toLowerCase().compareTo(
              b.label.toLowerCase(),
            );
            return c != 0 ? c : a.key.compareTo(b.key);
          });
    if (hasNone) {
      options.add(
        const PurchaseFilterOption(
          purchaseReportNoneKey,
          notSetLabel,
        ),
      );
    }
    return options;
  }

  static List<PurchaseFilterOption> countries(
    List<SupplierReportRow> rows,
  ) => _build(rows, (r) => r.country);

  /// States of the suppliers in [countryKey] (all when null).
  static List<PurchaseFilterOption> states(
    List<SupplierReportRow> rows, {
    String? countryKey,
  }) => _build(
    rows.where(
      (r) => PurchaseReportFilters.keyMatches(
        countryKey,
        r.countryKey,
      ),
    ),
    (r) => r.state,
  );
}

enum SupplierSortField {
  name,
  phone,
  email,
  /// Location: country, then state, then street and city.
  address,
  purchases,
  spend,
  paid,
  balance,
  lastPurchase,
}

/// Result of [SupplierReportQuery.paginate].
class SupplierReportPage {
  final List<SupplierReportRow> rows;
  final int totalCount;
  final int page; // 1-based, already clamped
  final int totalPages;

  /// Totals of every filtered row (not just this page).
  final int totalPurchases;
  final double totalSpend;
  final double totalPaid;
  final double totalBalance;

  const SupplierReportPage({
    required this.rows,
    required this.totalCount,
    required this.page,
    required this.totalPages,
    this.totalPurchases = 0,
    this.totalSpend = 0,
    this.totalPaid = 0,
    this.totalBalance = 0,
  });

  int get firstIndex =>
      totalCount == 0
          ? 0
          : (page - 1) * supplierReportPageSize + 1;
  int get lastIndex =>
      firstIndex == 0 ? 0 : firstIndex + rows.length - 1;
}

class SupplierReportQuery {
  /// First direction of a newly picked column: names A-Z, counts,
  /// amounts and dates largest first (so the biggest supplier is
  /// one tap away).
  static bool defaultAscending(SupplierSortField f) {
    switch (f) {
      case SupplierSortField.name:
      case SupplierSortField.phone:
      case SupplierSortField.email:
      case SupplierSortField.address:
        return true;
      case SupplierSortField.purchases:
      case SupplierSortField.spend:
      case SupplierSortField.paid:
      case SupplierSortField.balance:
      case SupplierSortField.lastPurchase:
        return false;
    }
  }

  /// Filtered, then sorted. Nulls sink in both directions; ties:
  /// name, then key, so pages are stable.
  static List<SupplierReportRow> filterAndSort({
    required List<SupplierReportRow> rows,
    required SupplierReportFilters filters,
    required SupplierSortField sortField,
    required bool ascending,
  }) {
    final out = rows.where(filters.matches).toList();
    final cmp = PurchaseReportQuery.cmp;
    String? lower(String? s) => s?.toLowerCase();

    int compare(SupplierReportRow a, SupplierReportRow b) {
      int c;
      switch (sortField) {
        case SupplierSortField.name:
          c = cmp(lower(a.name), lower(b.name), ascending);
          break;
        case SupplierSortField.phone:
          c = cmp(a.phone, b.phone, ascending);
          break;
        case SupplierSortField.email:
          c = cmp(lower(a.email), lower(b.email), ascending);
          break;
        case SupplierSortField.address:
          c = cmp(a.countryKey, b.countryKey, ascending);
          if (c == 0) c = cmp(a.stateKey, b.stateKey, ascending);
          if (c == 0) {
            c = cmp(
              lower(a.addressLine),
              lower(b.addressLine),
              ascending,
            );
          }
          break;
        case SupplierSortField.purchases:
          c = cmp(a.purchaseCount, b.purchaseCount, ascending);
          break;
        case SupplierSortField.spend:
          c = cmp(a.spend, b.spend, ascending);
          break;
        case SupplierSortField.paid:
          c = cmp(a.paid, b.paid, ascending);
          break;
        case SupplierSortField.balance:
          c = cmp(a.balance, b.balance, ascending);
          break;
        case SupplierSortField.lastPurchase:
          c = cmp(a.lastPurchase, b.lastPurchase, ascending);
          break;
      }
      if (c != 0) return c;
      final n = cmp(lower(a.name), lower(b.name), true);
      return n != 0 ? n : a.key.compareTo(b.key);
    }

    out.sort(compare);
    return out;
  }

  static SupplierReportPage paginate(
    List<SupplierReportRow> sorted,
    int requestedPage,
  ) {
    final b = reportPageBounds(
      sorted.length,
      requestedPage,
      pageSize: supplierReportPageSize,
    );

    int purchases = 0;
    double spend = 0;
    double paid = 0;
    double balance = 0;
    for (final r in sorted) {
      purchases += r.purchaseCount;
      spend += r.spend;
      paid += r.paid;
      balance += r.balance;
    }

    return SupplierReportPage(
      rows:
          sorted.isEmpty
              ? const []
              : sorted.sublist(b.start, b.end),
      totalCount: sorted.length,
      page: b.page,
      totalPages: b.pages,
      totalPurchases: purchases,
      totalSpend: spend,
      totalPaid: paid,
      totalBalance: balance,
    );
  }
}

/// Filters, sort and page of the Supplier Report table.
class SupplierReportTableState {
  final SupplierReportFilters filters;
  SupplierSortField sortField;
  bool ascending;
  int page;

  SupplierReportTableState({
    SupplierReportFilters? filters,
    this.sortField = SupplierSortField.name,
    this.ascending = true,
    this.page = 1,
  }) : filters = filters ?? SupplierReportFilters();

  /// Same column: flips the direction. New column: its default
  /// direction. Back to page 1 either way.
  void setSort(SupplierSortField f) {
    if (sortField == f) {
      ascending = !ascending;
    } else {
      sortField = f;
      ascending = SupplierReportQuery.defaultAscending(f);
    }
    page = 1;
  }

  /// Reset All: clears the search and every filter. The sort is a
  /// view option and stays.
  void resetAll() {
    filters.clearAll();
    page = 1;
  }
}
