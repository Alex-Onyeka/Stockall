import 'package:flutter/material.dart';
import 'package:stockall/pages/report/components/report_pager.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/staff_report/staff_report_table/class/staff_report_table_logic.dart';

// One staff's expenses. Reached only from the staff, and only
// while expenses are shown (StaffReportAccess.showExpenses).

enum StaffExpensesSortField {
  createdAt,
  title,
  description,
  quantity,
  amount,
  department,
}

class StaffExpensesFilters {
  String search;

  /// On the amount.
  double? amountMin;
  double? amountMax;

  StaffExpensesFilters({this.search = '', this.amountMin, this.amountMax});

  StaffExpensesFilters copy() => StaffExpensesFilters(
    search: search,
    amountMin: amountMin,
    amountMax: amountMax,
  );

  /// Message for a min above its max, otherwise null.
  String? get amountRangeError =>
      (amountMin != null && amountMax != null && amountMin! > amountMax!)
          ? 'Minimum cannot be more than maximum'
          : null;

  int get activeCount => (amountMin != null || amountMax != null) ? 1 : 0;

  bool get hasAnything => activeCount > 0 || search.trim().isNotEmpty;

  void clearAll() {
    search = '';
    amountMin = null;
    amountMax = null;
  }

  /// [departmentsEnabled] switches off the department search.
  bool matches(StaffExpenseRow r, {required bool departmentsEnabled}) {
    // An invalid range is not applied.
    if (amountRangeError == null) {
      if (amountMin != null && r.amount < amountMin!) return false;
      if (amountMax != null && r.amount > amountMax!) return false;
    }
    final q = search.trim().toLowerCase();
    if (q.isEmpty) return true;
    bool has(String? s) => s != null && s.toLowerCase().contains(q);
    return has(r.title) ||
        has(r.description) ||
        has(r.unit) ||
        (departmentsEnabled && has(r.departmentName));
  }
}

class StaffExpensesTotals {
  final int count;
  final double amount;

  const StaffExpensesTotals({required this.count, required this.amount});

  factory StaffExpensesTotals.of(Iterable<StaffExpenseRow> rows) {
    int count = 0;
    double amount = 0;
    for (final r in rows) {
      count++;
      amount += r.amount;
    }
    return StaffExpensesTotals(count: count, amount: amount);
  }
}

class StaffExpensesPage {
  final List<StaffExpenseRow> rows;
  final int totalCount;
  final int page;
  final int pageSize;
  final int totalPages;

  /// Over the full filtered set, not just this page.
  final StaffExpensesTotals totals;

  const StaffExpensesPage({
    required this.rows,
    required this.totalCount,
    required this.page,
    required this.pageSize,
    required this.totalPages,
    required this.totals,
  });

  int get firstIndex => totalCount == 0 ? 0 : (page - 1) * pageSize + 1;
  int get lastIndex =>
      totalCount == 0 ? 0 : (page - 1) * pageSize + rows.length;
}

class StaffExpensesTable {
  /// First direction of a newly picked column: text A-Z; dates,
  /// quantities and amounts newest / largest first.
  static bool defaultAscending(StaffExpensesSortField f) {
    switch (f) {
      case StaffExpensesSortField.title:
      case StaffExpensesSortField.description:
      case StaffExpensesSortField.department:
        return true;
      case StaffExpensesSortField.createdAt:
      case StaffExpensesSortField.quantity:
      case StaffExpensesSortField.amount:
        return false;
    }
  }

  /// [staffKey]'s expenses in [period], then search and filters,
  /// then sorted. Without filters this is the staff report's
  /// expense group, so the totals match the staff's row.
  static List<StaffExpenseRow> filterAndSort({
    required StaffReportBase base,
    required String staffKey,
    required ReceiptsReportPeriod period,
    required StaffExpensesFilters filters,
    StaffExpensesSortField sortField = StaffExpensesSortField.createdAt,
    bool ascending = false,
    TimeOfDay? closingTime,
  }) {
    final departmentsEnabled = base.access.departmentsEnabled;
    final out =
        base.expenseRows
            .where(
              (r) =>
                  r.staffKey == staffKey &&
                  r.inPeriod(period, closingTime: closingTime) &&
                  filters.matches(r, departmentsEnabled: departmentsEnabled),
            )
            .toList();

    final cmp = StaffReportQuery.cmp;
    int compare(StaffExpenseRow a, StaffExpenseRow b) {
      final asc = ascending;
      int c;
      switch (sortField) {
        case StaffExpensesSortField.createdAt:
          c = cmp(a.createdAt, b.createdAt, asc);
          break;
        case StaffExpensesSortField.title:
          c = cmp(a.title.toLowerCase(), b.title.toLowerCase(), asc);
          break;
        case StaffExpensesSortField.description:
          c = cmp(
            a.description?.toLowerCase(),
            b.description?.toLowerCase(),
            asc,
          );
          break;
        case StaffExpensesSortField.quantity:
          c = cmp(a.quantity, b.quantity, asc);
          break;
        case StaffExpensesSortField.amount:
          c = cmp(a.amount, b.amount, asc);
          break;
        case StaffExpensesSortField.department:
          c = cmp(
            a.departmentName?.toLowerCase(),
            b.departmentName?.toLowerCase(),
            asc,
          );
          break;
      }
      return c != 0 ? c : StaffExpenseRow.newestFirst(a, b);
    }

    out.sort(compare);
    return out;
  }

  static StaffExpensesPage paginate(
    List<StaffExpenseRow> sorted,
    int requestedPage, {
    int pageSize = staffReportPageSize,
  }) {
    final b = reportPageBounds(
      sorted.length,
      requestedPage,
      pageSize: pageSize,
    );
    return StaffExpensesPage(
      rows:
          sorted.isEmpty ? <StaffExpenseRow>[] : sorted.sublist(b.start, b.end),
      totalCount: sorted.length,
      page: b.page,
      pageSize: pageSize,
      totalPages: b.pages,
      totals: StaffExpensesTotals.of(sorted),
    );
  }

  static StaffExpensesPage page({
    required StaffReportBase base,
    required String staffKey,
    required ReceiptsReportPeriod period,
    required StaffExpensesFilters filters,
    StaffExpensesSortField sortField = StaffExpensesSortField.createdAt,
    bool ascending = false,
    int page = 1,
    TimeOfDay? closingTime,
  }) {
    return paginate(
      filterAndSort(
        base: base,
        staffKey: staffKey,
        period: period,
        filters: filters,
        sortField: sortField,
        ascending: ascending,
        closingTime: closingTime,
      ),
      page,
    );
  }
}
