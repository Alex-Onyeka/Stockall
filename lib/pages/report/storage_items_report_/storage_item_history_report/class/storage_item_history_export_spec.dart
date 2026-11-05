// Export spec of the Storage Item History table: every filtered, sorted
// record (not just the page). Quantities are in each record's own unit,
// so the only total is the record count. Splits follow the screen's own
// filters: Department (the record's sales department) and Staff (the
// storekeeper).

import 'package:stockall/classes/temp_storage_item_history/storage_item_history.dart';
import 'package:stockall/constants/calculations.dart' show returnHistoryQuantity;
import 'package:stockall/pages/report/components/export/report_export_format.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/items_report_/item_history_report/class/item_history_report_logic.dart'
    show QuantityDirectionFilter;
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/components/receipts_report_filter_widgets.dart'
    show receiptsPeriodLabel;
import 'package:stockall/pages/report/storage_items_report_/storage_item_history_report/class/storage_item_history_report_logic.dart';

const String _dash = '—';

/// The note the storage history pages show for All time. The views draw
/// it and the exports carry it, so they always match.
List<String> storageHistoryNotes({required bool allTime}) => [
  if (allTime) 'All time covers the storage history loaded on this device.',
];

/// The names the screen's chips and cells look up, by key.
class StorageHistoryExportNames {
  final Map<String, String> storageItems;
  final Map<String, String> salesItems;
  final Map<String, String> departments;
  final Map<String, String> storekeepers;
  final Map<String, String> otherStaff;

  /// Current names by uuid, for "(now: X)" after a rename.
  final Map<String, String> currentStorageNames;
  final Map<String, String> currentSalesNames;

  const StorageHistoryExportNames({
    this.storageItems = const {},
    this.salesItems = const {},
    this.departments = const {},
    this.storekeepers = const {},
    this.otherStaff = const {},
    this.currentStorageNames = const {},
    this.currentSalesNames = const {},
  });
}

String? _clean(String? s) {
  final t = s?.trim();
  return t == null || t.isEmpty ? null : t;
}

/// The name cell: the snapshot name, "(now: X)" when the item has been
/// renamed since, as the screen's tooltip says.
String storageHistoryNameText(String? snapshot, String? current) {
  final now = currentNameIfDifferent(snapshotName: snapshot, currentName: current);
  final shown = _clean(snapshot) ?? now;
  if (shown == null) return _dash;
  if (now == null || _clean(snapshot) == null) return shown;
  return '$shown (now: $now)';
}

/// The Quantity Change cell, as the screen formats it.
String storageHistoryQuantityText(StorageItemHistory r) {
  if (r.quantityChange == null) return 'N/A';
  return returnHistoryQuantity(
    quantityChange: r.quantityChange,
    isIncreased: r.isIncreased,
    unit: r.storageUnit,
    primaryUnit: r.storagePrimaryUnit,
    oldValue: r.storageItemOldValue,
    newValue: r.storageItemNewValue,
  );
}

String _value(String? value, String? unit) {
  final v = _clean(value);
  if (v == null) return _dash;
  final u = _clean(unit);
  return u == null ? v : '$v $u';
}

const Map<StorageItemHistorySortField, String> storageHistorySortLabels = {
  StorageItemHistorySortField.storageItemName: 'Storage Item',
  StorageItemHistorySortField.salesItemName: 'Sales Item',
  StorageItemHistorySortField.departmentName: 'Department',
  StorageItemHistorySortField.title: 'History Title',
  StorageItemHistorySortField.event: 'Event',
  StorageItemHistorySortField.source: 'Source',
  StorageItemHistorySortField.destination: 'Destination',
  StorageItemHistorySortField.desc: 'Description',
  StorageItemHistorySortField.quantityChange: 'Quantity Change',
  StorageItemHistorySortField.unit: 'Unit',
  StorageItemHistorySortField.storageOldValue: 'Storage Old',
  StorageItemHistorySortField.storageNewValue: 'Storage New',
  StorageItemHistorySortField.storagePrimaryUnit: 'Primary Unit',
  StorageItemHistorySortField.salesOldValue: 'Sales Old',
  StorageItemHistorySortField.salesNewValue: 'Sales New',
  StorageItemHistorySortField.createdAt: 'Created Date',
  StorageItemHistorySortField.storekeeperName: 'Storekeeper',
  StorageItemHistorySortField.otherStaffName: 'Other Staff',
  StorageItemHistorySortField.supplier: 'Supplier',
  StorageItemHistorySortField.trackingNumber: 'Tracking Number',
};

/// The table's filters with their values, worded like its chips.
List<ExportFilter> storageHistoryExportFilters({
  required StorageItemHistoryReportFilters filters,
  required StorageHistoryExportNames names,
  required bool departmentsEnabled,
}) {
  String label(String key, Map<String, String> map, String fallback, {String? none}) =>
      key == storageItemHistoryReportNoneKey ? (none ?? fallback) : (map[key] ?? fallback);
  final out = <ExportFilter>[];
  final search = filters.search.trim();
  if (search.isNotEmpty) out.add(ExportFilter('Search', search));
  final storage = filters.storageItemUuid;
  if (storage != null) {
    out.add(ExportFilter('Storage Item', label(storage, names.storageItems, 'Item')));
  }
  final sales = filters.salesItemUuid;
  if (sales != null) {
    out.add(ExportFilter('Sales Item', label(sales, names.salesItems, 'Item', none: 'None')));
  }
  final dept = filters.departmentUuid;
  if (departmentsEnabled && dept != null) {
    out.add(ExportFilter(
      'Department',
      label(dept, names.departments, 'Department', none: 'No Department'),
    ));
  }
  final keeper = filters.storekeeperKey;
  if (keeper != null) {
    out.add(ExportFilter('Storekeeper', label(keeper, names.storekeepers, 'Staff')));
  }
  final other = filters.otherStaffKey;
  if (other != null) {
    out.add(ExportFilter('Other Staff', label(other, names.otherStaff, 'Staff', none: 'None')));
  }
  if (filters.event != null) {
    out.add(ExportFilter('Event', StorageItemHistoryReportQuery.formatEventName(filters.event!)));
  }
  if (filters.source != null) {
    out.add(ExportFilter(
      'Source',
      StorageItemHistoryReportQuery.formatSourceOrDestination(filters.source!),
    ));
  }
  if (filters.destination != null) {
    out.add(ExportFilter(
      'Destination',
      StorageItemHistoryReportQuery.formatSourceOrDestination(filters.destination!),
    ));
  }
  final direction = switch (filters.quantityDirection) {
    QuantityDirectionFilter.increase => 'Increase',
    QuantityDirectionFilter.decrease => 'Decrease',
    QuantityDirectionFilter.zeroChange => 'No Change',
    QuantityDirectionFilter.all => null,
  };
  if (direction != null) out.add(ExportFilter('Direction', direction));
  return out;
}

ExportTableSection<StorageItemHistory> storageHistorySection({
  required List<StorageItemHistory> rows,
  required StorageHistoryExportNames names,
  required bool departmentsEnabled,
  required ExportFormatter f,
}) {
  final number = Map<StorageItemHistory, int>.identity();
  for (var i = 0; i < rows.length; i++) {
    number[rows[i]] = i + 1;
  }
  String orDash(String? v) => _clean(v) ?? _dash;
  String place(String? v) => _clean(v) == null
      ? _dash
      : StorageItemHistoryReportQuery.formatSourceOrDestination(v!);

  return ExportTableSection<StorageItemHistory>(
    title: 'Storage Item History',
    rows: rows,
    columns: [
      ExportColumn(
        id: 'no',
        label: 'No.',
        format: ExportFormat.integer,
        value: (r) => number[r],
        width: 0.5,
      ),
      ExportColumn(
        id: 'item',
        label: 'Storage Item',
        value: (r) => storageHistoryNameText(
          r.storageItemName,
          names.currentStorageNames[r.storageItemUuid],
        ),
        width: 1.6,
      ),
      ExportColumn(
        id: 'created',
        label: 'Created Date',
        format: ExportFormat.dateTime,
        value: (r) => r.createdAt,
        display: (r) => r.createdAt == null ? _dash : f.dateTime(r.createdAt!),
        width: 1.5,
      ),
      ExportColumn(
        id: 'salesItem',
        label: 'Sales Item',
        value: (r) => storageHistoryNameText(
          r.salesItemName,
          names.currentSalesNames[r.salesItemUuid],
        ),
        width: 1.4,
      ),
      if (departmentsEnabled)
        ExportColumn(
          id: 'department',
          label: 'Department',
          value: (r) => orDash(r.salesDepartmentName),
          width: 1.2,
        ),
      ExportColumn(id: 'title', label: 'History Title', value: (r) => orDash(r.title), width: 1.4),
      ExportColumn(
        id: 'event',
        label: 'Event',
        value: (r) => _clean(r.event) == null
            ? _dash
            : StorageItemHistoryReportQuery.formatEventName(r.event!),
        width: 1.1,
      ),
      ExportColumn(id: 'source', label: 'Source', value: (r) => place(r.source)),
      ExportColumn(id: 'destination', label: 'Destination', value: (r) => place(r.destination)),
      ExportColumn(
        id: 'supplier',
        label: 'Supplier',
        value: (r) => orDash(r.supplier),
        inPdf: false,
      ),
      ExportColumn(
        id: 'tracking',
        label: 'Tracking Number',
        value: (r) => orDash(r.trackingNumber),
        inPdf: false,
      ),
      ExportColumn(
        id: 'desc',
        label: 'Description',
        value: (r) => orDash(r.desc),
        inPdf: false,
      ),
      ExportColumn(
        id: 'qty',
        label: 'Quantity Change',
        format: ExportFormat.quantity,
        value: (r) => r.quantityChange,
        display: storageHistoryQuantityText,
        width: 1.4,
      ),
      ExportColumn(
        id: 'unit',
        label: 'Unit',
        value: (r) => StorageItemHistoryReportQuery.quantityChangeUnit(r) ?? _dash,
        inPdf: false,
      ),
      ExportColumn(
        id: 'storageOld',
        label: 'Storage Old',
        value: (r) => _value(r.storageItemOldValue, r.storagePrimaryUnit),
      ),
      ExportColumn(
        id: 'storageNew',
        label: 'Storage New',
        value: (r) => _value(r.storageItemNewValue, r.storagePrimaryUnit),
      ),
      ExportColumn(
        id: 'primaryUnit',
        label: 'Primary Unit',
        value: (r) => orDash(r.storagePrimaryUnit),
        inPdf: false,
      ),
      // Sales values are stored in base units, so without a unit label,
      // as on screen.
      ExportColumn(
        id: 'salesOld',
        label: 'Sales Old',
        value: (r) => _value(r.salesItemOldValue, null),
        inPdf: false,
      ),
      ExportColumn(
        id: 'salesNew',
        label: 'Sales New',
        value: (r) => _value(r.salesItemNewValue, null),
        inPdf: false,
      ),
      ExportColumn(
        id: 'storekeeper',
        label: 'Storekeeper',
        value: (r) => orDash(r.storageStaffName),
        width: 1.1,
      ),
      ExportColumn(
        id: 'otherStaff',
        label: 'Other Staff',
        value: (r) => orDash(r.salesStaffName),
        width: 1.1,
      ),
    ],
    // Export-only total: the record count. Quantities are in each
    // record's own unit, so they aren't summed.
    totalsFor: (rs) => {
      'item': '${f.integer(rs.length)} ${rs.length == 1 ? 'record' : 'records'}',
    },
    splits: [
      if (departmentsEnabled)
        ExportSplit<StorageItemHistory>(
          id: 'department',
          label: 'Department',
          noneLabel: 'No Department',
          keys: (r) {
            final k = _clean(r.salesDepartmentUuid);
            return k == null ? const [] : [k];
          },
          name: (k) => names.departments[k] ?? k,
        ),
      ExportSplit<StorageItemHistory>(
        id: 'staff',
        label: 'Staff',
        noneLabel: 'No Staff',
        keys: (r) {
          final k = StorageHistoryStaff.storekeeperKey(r);
          return k == null ? const [] : [k];
        },
        name: (k) => names.storekeepers[k] ?? k,
      ),
    ],
    // As the Items history: 58mm 13 / 18 characters, 80mm 11 / 19 / 18,
    // so "+3 Sheets (4 x 2)" stays on one line.
    roll: const RollLayout(
      cols58: ['item', 'qty'],
      cols80: ['item', 'event', 'qty'],
      sub58: ['created'],
      sub80: ['created', 'storekeeper'],
      flex58: [7, 9],
      flex80: [4, 7, 6],
    ),
    emptyMessage: 'No storage history matches the selected period and filters.',
  );
}

/// [rows] is the full filtered and sorted list.
ReportExportSpec storageHistoryExportSpec({
  required List<StorageItemHistory> rows,
  required StorageItemHistoryReportFilters filters,
  required StorageHistoryExportNames names,
  required StorageItemHistorySortField sortField,
  required bool ascending,
  required ReceiptsReportPeriod period,
  required bool departmentsEnabled,
  required String currency,
}) {
  final f = ExportFormatter(currency: currency);
  return ReportExportSpec(
    reportName: 'Storage Item History',
    fileSlug: 'storage_item_history',
    period: ExportPeriod(
      label: receiptsPeriodLabel(period),
      start: period.start,
      end: period.end,
    ),
    filters: storageHistoryExportFilters(
      filters: filters,
      names: names,
      departmentsEnabled: departmentsEnabled,
    ),
    sortedBy: '${storageHistorySortLabels[sortField] ?? sortField.name} '
        '(${ascending ? 'ascending' : 'descending'})',
    notes: storageHistoryNotes(allTime: period.isAllTime),
    sections: [
      storageHistorySection(
        rows: rows,
        names: names,
        departmentsEnabled: departmentsEnabled,
        f: f,
      ),
    ],
  );
}
