// Export spec of the Supplier Report table: every filtered, sorted
// supplier (not just the page), with the screen's own totals
// (SupplierReportPage).

import 'package:stockall/pages/report/components/export/report_export_format.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/export/report_export_splits.dart';
import 'package:stockall/pages/report/purchase_report/purchase_report_table/class/purchase_report_export_spec.dart'
    show purchaseReportNotes;
import 'package:stockall/pages/report/purchase_report/purchase_report_table/components/purchase_report_filter_widgets.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/components/receipts_report_filter_widgets.dart'
    show receiptsPeriodLabel;
import 'package:stockall/pages/report/supplier_report/supplier_report_table/class/supplier_report_table_logic.dart';
import 'package:stockall/pages/report/supplier_report/supplier_report_table/components/supplier_report_filter_widgets.dart'
    show supplierHasBalanceLabel;

const String _dash = '—';

/// The Name cell: the deleted-supplier badge as text.
String supplierNameText(SupplierReportRow r) =>
    r.isDeleted ? '${r.label} ($supplierDeletedLabel)' : r.label;

const Map<SupplierSortField, String> supplierSortLabels = {
  SupplierSortField.name: 'Name',
  SupplierSortField.phone: 'Phone',
  SupplierSortField.email: 'Email',
  SupplierSortField.address: 'Address',
  SupplierSortField.purchases: 'Purchases',
  SupplierSortField.spend: 'Spend',
  SupplierSortField.paid: 'Paid',
  SupplierSortField.balance: 'Balance owed',
  SupplierSortField.lastPurchase: 'Last purchase',
};

String supplierSortLabel(SupplierSortField field, bool ascending) =>
    '${supplierSortLabels[field] ?? field.name} '
    '(${ascending ? 'ascending' : 'descending'})';

/// The table's filters with their values, worded like its chips.
/// [rows] are every supplier row of the period (the choices).
List<ExportFilter> supplierExportFilters({
  required SupplierReportFilters filters,
  required List<SupplierReportRow> rows,
}) {
  final out = <ExportFilter>[];
  final search = filters.search.trim();
  if (search.isNotEmpty) out.add(ExportFilter('Search', search));
  final country = filters.countryKey;
  if (country != null) {
    out.add(ExportFilter(
      'Country',
      PurchaseFilterChoices.labelFor(
        SupplierReportOptions.countries(rows),
        country,
        'Country',
      ),
    ));
  }
  final state = filters.stateKey;
  if (state != null) {
    out.add(ExportFilter(
      'State',
      PurchaseFilterChoices.labelFor(
        SupplierReportOptions.states(rows, countryKey: country),
        state,
        'State',
      ),
    ));
  }
  if (filters.hasBalance) {
    out.add(const ExportFilter('Balance', supplierHasBalanceLabel));
  }
  return out;
}

/// The screen's totals row (SupplierReportPage) by column id.
Map<String, Object?> supplierTotals(
  List<SupplierReportRow> rows, {
  required ExportFormatter f,
}) {
  final page = SupplierReportQuery.paginate(rows, 1);
  return {
    'name': '${f.integer(rows.length)} ${rows.length == 1 ? 'supplier' : 'suppliers'}',
    'purchases': page.totalPurchases,
    'spend': page.totalSpend,
    'paid': page.totalPaid,
    'balance': page.totalBalance,
  };
}

ExportTableSection<SupplierReportRow> supplierTableSection({
  required List<SupplierReportRow> rows,
  required ExportFormatter f,
}) {
  String orDash(String? v) => v ?? _dash;
  return ExportTableSection<SupplierReportRow>(
    title: 'Suppliers',
    rows: rows,
    columns: [
      ExportColumn(id: 'name', label: 'Name', value: supplierNameText, width: 1.8),
      ExportColumn(id: 'phone', label: 'Phone', value: (r) => orDash(r.phone), width: 1.2),
      ExportColumn(id: 'email', label: 'Email', value: (r) => orDash(r.email), width: 1.5),
      ExportColumn(
        id: 'address',
        label: 'Address',
        value: (r) => orDash(r.fullAddress),
        width: 2,
      ),
      ExportColumn(
        id: 'purchases',
        label: 'Purchases',
        format: ExportFormat.integer,
        value: (r) => r.purchaseCount,
        width: 0.8,
      ),
      ExportColumn(
        id: 'spend',
        label: 'Spend',
        format: ExportFormat.money,
        value: (r) => r.spend,
        width: 1.2,
      ),
      ExportColumn(
        id: 'paid',
        label: 'Paid',
        format: ExportFormat.money,
        value: (r) => r.paid,
        width: 1.2,
      ),
      ExportColumn(
        id: 'balance',
        label: 'Balance owed',
        format: ExportFormat.money,
        value: (r) => r.balance,
        width: 1.2,
      ),
      ExportColumn(
        id: 'lastPurchase',
        label: 'Last purchase',
        format: ExportFormat.date,
        value: (r) => r.lastPurchase,
        display: (r) => r.lastPurchase == null ? _dash : f.date(r.lastPurchase!),
      ),
    ],
    totalsFor: (rs) => supplierTotals(rs, f: f),
    // Country only: the screen filters by it (State depends on it).
    splits: [
      fieldSplit<SupplierReportRow>(
        id: 'country',
        label: 'Country',
        noneLabel: 'No Country',
        rows: rows,
        key: (r) => r.countryKey,
        name: (r) => r.country,
      ),
    ],
    // 58mm: 15 / 16 characters, 80mm: 25 / 7 / 14, so "₦1,250,000.00"
    // stays on one line.
    roll: const RollLayout(
      cols58: ['name', 'spend'],
      cols80: ['name', 'purchases', 'balance'],
      flex58: [1, 1],
      flex80: [26, 8, 14],
    ),
    emptyMessage: 'No supplier matches your search and filters.',
  );
}

/// [rows] is the full filtered and sorted list; [allRows] every
/// supplier row of the period (for the filter labels).
ReportExportSpec supplierReportExportSpec({
  required List<SupplierReportRow> rows,
  required List<SupplierReportRow> allRows,
  required SupplierReportTableState state,
  required ReceiptsReportPeriod period,
  required String currency,
}) {
  final f = ExportFormatter(currency: currency);
  return ReportExportSpec(
    reportName: 'Supplier Report',
    fileSlug: 'supplier_report',
    period: ExportPeriod(
      label: receiptsPeriodLabel(period),
      start: period.start,
      end: period.end,
    ),
    filters: supplierExportFilters(filters: state.filters, rows: allRows),
    sortedBy: supplierSortLabel(state.sortField, state.ascending),
    notes: purchaseReportNotes(period: period),
    sections: [supplierTableSection(rows: rows, f: f)],
  );
}
