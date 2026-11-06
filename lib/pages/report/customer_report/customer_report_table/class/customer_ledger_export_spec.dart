// Export spec of one customer's Reward Earnings or Account Transactions
// table (one view serves both): every filtered, sorted entry, with the
// totals bar's figures (CustomerLedgerTotals).

import 'package:stockall/pages/report/components/export/report_export_format.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/export/report_export_splits.dart';
import 'package:stockall/pages/report/customer_report/customer_report_table/class/customer_report_export_spec.dart';
import 'package:stockall/pages/report/customer_report/customer_report_table/class/customer_report_table_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

const String _dash = '—';

/// The table's wording per kind, as the view's `_LedgerConfig`.
class CustomerLedgerWording {
  final String title;
  final String added;
  final String deducted;
  final String addedTotal;
  final String deductedTotal;
  final bool showComment;

  const CustomerLedgerWording._({
    required this.title,
    required this.added,
    required this.deducted,
    required this.addedTotal,
    required this.deductedTotal,
    required this.showComment,
  });

  static CustomerLedgerWording of(CustomerLedgerKind kind) => switch (kind) {
    CustomerLedgerKind.reward => const CustomerLedgerWording._(
      title: 'Reward Earnings',
      added: 'Earned',
      deducted: 'Redeemed',
      addedTotal: 'Earned',
      deductedTotal: 'Redeemed',
      showComment: false,
    ),
    CustomerLedgerKind.account => const CustomerLedgerWording._(
      title: 'Account Transactions',
      added: 'Credit',
      deducted: 'Debit',
      addedTotal: 'Credits',
      deductedTotal: 'Debits',
      showComment: true,
    ),
  };

  String typeOf(CustomerLedgerRow r) => r.isAdd ? added : deducted;

  String directionLabel(CustomerLedgerDirection d) =>
      d == CustomerLedgerDirection.added ? added : deducted;
}

/// "+₦500.00" / "-₦500.00", as the Amount cells and the Net total.
String customerLedgerSigned(double v, ExportFormatter f) =>
    v < 0 ? '-${f.money(-v)}' : '+${f.money(v)}';

const Map<CustomerLedgerSortField, String> customerLedgerSortLabels = {
  CustomerLedgerSortField.createdAt: 'Date',
  CustomerLedgerSortField.title: 'Title',
  CustomerLedgerSortField.direction: 'Type',
  CustomerLedgerSortField.amount: 'Amount',
  CustomerLedgerSortField.oldBalance: 'Old Balance',
  CustomerLedgerSortField.newBalance: 'New Balance',
  CustomerLedgerSortField.staff: 'Staff',
  CustomerLedgerSortField.comment: 'Comment',
  CustomerLedgerSortField.receipt: 'Linked Receipt',
};

/// The totals bar (CustomerLedgerTotals) by column id: the count, the
/// added / deducted pair and the signed net.
Map<String, Object?> customerLedgerTotals(
  List<CustomerLedgerRow> rows, {
  required CustomerLedgerWording wording,
  required ExportFormatter f,
}) {
  final t = CustomerLedgerQuery.paginate(rows, 1).totals;
  return {
    'date': '${f.integer(t.count)} ${t.count == 1 ? 'entry' : 'entries'}',
    'title': '${wording.addedTotal} ${f.money(t.added)} · '
        '${wording.deductedTotal} ${f.money(t.deducted)}',
    'amount': customerLedgerSigned(t.net, f),
  };
}

ExportTableSection<CustomerLedgerRow> customerLedgerSection({
  required List<CustomerLedgerRow> rows,
  required CustomerLedgerKind kind,
  required ExportFormatter f,
}) {
  final w = CustomerLedgerWording.of(kind);
  String balance(double? v) => v == null ? _dash : f.money(v);
  return ExportTableSection<CustomerLedgerRow>(
    title: w.title,
    rows: rows,
    columns: [
      ExportColumn(
        id: 'date',
        label: 'Date',
        format: ExportFormat.date,
        value: (r) => r.createdAt,
        display: (r) => r.createdAt == null ? _dash : f.date(r.createdAt!),
      ),
      ExportColumn(
        id: 'time',
        label: 'Time',
        format: ExportFormat.time,
        value: (r) => r.createdAt,
        display: (r) => r.createdAt == null ? _dash : f.time(r.createdAt!),
        width: 0.8,
      ),
      ExportColumn(id: 'title', label: 'Title', value: (r) => r.title, width: 1.6),
      ExportColumn(id: 'type', label: 'Type', value: w.typeOf, width: 0.8),
      ExportColumn(
        id: 'amount',
        label: 'Amount',
        format: ExportFormat.money,
        value: (r) => r.signedAmount,
        display: (r) => customerLedgerSigned(r.signedAmount, f),
        width: 1.2,
      ),
      ExportColumn(
        id: 'oldBalance',
        label: 'Old Balance',
        format: ExportFormat.money,
        value: (r) => r.oldBalance,
        display: (r) => balance(r.oldBalance),
        width: 1.2,
      ),
      ExportColumn(
        id: 'newBalance',
        label: 'New Balance',
        format: ExportFormat.money,
        value: (r) => r.newBalance,
        display: (r) => balance(r.newBalance),
        width: 1.2,
      ),
      ExportColumn(
        id: 'staff',
        label: 'Staff',
        value: (r) => r.staffName ?? 'Not Set',
        width: 1.2,
      ),
      if (w.showComment)
        ExportColumn(
          id: 'comment',
          label: 'Comment',
          value: (r) => r.comment ?? _dash,
          width: 1.5,
        ),
      ExportColumn(
        id: 'receipt',
        label: 'Linked Receipt',
        value: (r) => r.receiptDisplayId ?? _dash,
        width: 1.3,
      ),
    ],
    totalsFor: (rs) => customerLedgerTotals(rs, wording: w, f: f),
    splits: [
      labelSplit<CustomerLedgerRow>(
        id: 'type',
        label: 'Type',
        noneLabel: 'No Type',
        value: w.typeOf,
      ),
      staffSplit<CustomerLedgerRow>(
        rows: rows,
        staffId: (r) => r.staffKey,
        staffName: (r) => r.staffName,
      ),
    ],
    // 58mm: 15 / 16 characters, 80mm: 23 / 9 / 14, so
    // "+₦1,250,000.00" stays on one line; the date goes underneath.
    roll: const RollLayout(
      cols58: ['title', 'amount'],
      cols80: ['title', 'type', 'amount'],
      sub58: ['date'],
      sub80: ['date'],
      flex58: [1, 1],
      flex80: [24, 10, 14],
    ),
    emptyMessage: kind == CustomerLedgerKind.reward
        ? 'No reward earnings in this period.'
        : 'No account transactions in this period.',
  );
}

/// [rows] is the full filtered and sorted list of [customerName]'s
/// entries of [kind]; [staffOptions] the table's staff choices.
ReportExportSpec customerLedgerExportSpec({
  required CustomerLedgerKind kind,
  required String customerName,
  required List<CustomerLedgerRow> rows,
  required CustomerLedgerFilters filters,
  required List<CustomerReportFilterOption> staffOptions,
  required CustomerLedgerSortField sortField,
  required bool ascending,
  required ReceiptsReportPeriod period,
  required String currency,
}) {
  final f = ExportFormatter(currency: currency);
  final w = CustomerLedgerWording.of(kind);
  String range(double? min, double? max) =>
      '${min != null ? f.money(min) : 'Any'} - ${max != null ? f.money(max) : 'Any'}';
  final search = filters.search.trim();
  final staff = filters.staffKey;
  return ReportExportSpec(
    reportName: w.title,
    fileSlug: kind == CustomerLedgerKind.reward
        ? 'customer_reward_earnings'
        : 'customer_account_transactions',
    period: customerExportPeriod(period),
    filters: [
      ExportFilter('Customer', customerName),
      if (search.isNotEmpty) ExportFilter('Search', search),
      if (filters.direction != null)
        ExportFilter('Type', w.directionLabel(filters.direction!)),
      if (staff != null)
        ExportFilter('Staff', [
          for (final o in staffOptions)
            if (o.key == staff) o.label,
        ].firstOrNull ?? 'Not Set'),
      if (filters.amountMin != null || filters.amountMax != null)
        ExportFilter('Amount', range(filters.amountMin, filters.amountMax)),
    ],
    sortedBy: '${customerLedgerSortLabels[sortField] ?? sortField.name} '
        '(${ascending ? 'ascending' : 'descending'})',
    notes: customerReportNotes(period: period),
    sections: [customerLedgerSection(rows: rows, kind: kind, f: f)],
  );
}
