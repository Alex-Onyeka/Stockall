// Export spec of the Item History table: the same rows (the full
// filtered and sorted list, not the page), columns, date range, filters
// and sort as the screen, for the shared Export button.

import 'package:stockall/classes/temp_item_history/item_history.dart';
import 'package:stockall/constants/calculations.dart'
    show returnHistoryQuantity, stripDimensionLabel;
import 'package:stockall/pages/report/components/export/report_export_format.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/export/report_export_splits.dart';
import 'package:stockall/pages/report/items_report_/item_history_report/class/item_history_report_logic.dart';

const String _dash = '—';

/// Column label of each sort field, as on the screen.
const Map<ItemHistorySortField, String> itemHistorySortLabels = {
  ItemHistorySortField.itemName: 'Item Name',
  ItemHistorySortField.title: 'History Title',
  ItemHistorySortField.event: 'Event',
  ItemHistorySortField.source: 'Source',
  ItemHistorySortField.destination: 'Destination',
  ItemHistorySortField.desc: 'Description',
  ItemHistorySortField.quantityChange: 'Quantity Change',
  ItemHistorySortField.oldValue: 'Old Value',
  ItemHistorySortField.newValue: 'New Value',
  ItemHistorySortField.createdAt: 'Created Date',
  ItemHistorySortField.staffName: 'Creator',
  ItemHistorySortField.departmentName: 'Department',
  ItemHistorySortField.unit: 'Unit',
  ItemHistorySortField.primaryUnit: 'Primary Unit',
  ItemHistorySortField.isManaged: 'Managed',
  ItemHistorySortField.supplier: 'Supplier',
  ItemHistorySortField.trackingNumber: 'Tracking Number',
};

String itemHistorySortLabel(ItemHistorySortField field, bool ascending) =>
    '${itemHistorySortLabels[field] ?? field.name} '
    '(${ascending ? 'ascending' : 'descending'})';

String? _clean(String? s) {
  final t = s?.trim();
  return (t == null || t.isEmpty) ? null : t;
}

/// The quantity change as a signed number: negative when the record is a
/// decrease, as the screen colours and signs it.
double? itemHistorySignedQuantity(ItemHistory h) {
  final q = h.quantityChange;
  if (q == null) return null;
  if (q == 0) return 0;
  if (h.isIncreased == false) return -q.abs();
  if (h.isIncreased == true) return q.abs();
  return q;
}

/// The screen's quantity text ("+12 Bottles", "-2 Bottles (0.2 Crates)").
/// A 2D sheet item counted in its primary unit also gets its size:
/// "+3 Sheets (4 x 2)". [sizeLabel] is the item's " (4 x 2)", or null.
String itemHistoryQuantityText(
  ItemHistory h,
  ExportFormatter f, {
  String? sizeLabel,
}) {
  if (h.quantityChange == null) return 'N/A';
  final screen = returnHistoryQuantity(
    quantityChange: h.quantityChange,
    isIncreased: h.isIncreased,
    unit: h.unit,
    primaryUnit: h.primaryUnit,
    oldValue: h.oldValue,
    newValue: h.newValue,
  );
  if (sizeLabel == null || sizeLabel.isEmpty) return screen;
  final unit = stripDimensionLabel(_clean(h.unit) ?? '');
  final primary = stripDimensionLabel(_clean(h.primaryUnit) ?? '');
  if (unit.isEmpty || unit.toLowerCase() != primary.toLowerCase()) {
    return screen;
  }
  final q = h.quantityChange!;
  final sign = q == 0 ? '' : (h.isIncreased == false ? '-' : '+');
  return '$sign${f.quantity(q.abs())} $unit$sizeLabel';
}

/// The unit of the quantity change, for the Excel-only Unit column.
String itemHistoryUnitText(ItemHistory h) =>
    ItemHistoryReportQuery.quantityChangeUnit(h) ?? '';

num? _number(String? v) {
  final t = _clean(v);
  if (t == null) return null;
  return num.tryParse(t.replaceAll(',', ''));
}

/// Old / New Value as the screen shows it: "90 Box", or "—".
String _valueText(String? v, String? primaryUnit) {
  final t = _clean(v);
  if (t == null) return _dash;
  final unit = _clean(primaryUnit);
  return unit == null ? t : '$t $unit';
}

/// The active filters with their values, worded like the screen chips.
List<ExportFilter> itemHistoryExportFilters({
  required ItemHistoryReportFilters filters,
  required bool departmentsEnabled,
  String? lockedItemName,
  Map<String, String> itemNames = const {},
  Map<String, String> staffNames = const {},
  Map<String, String> departmentNames = const {},
}) {
  final out = <ExportFilter>[];
  final search = filters.search.trim();
  if (search.isNotEmpty) out.add(ExportFilter('Search', '"$search"'));
  if (lockedItemName != null) {
    out.add(ExportFilter('Item', lockedItemName));
  } else if (filters.itemUuid != null) {
    out.add(ExportFilter('Item', itemNames[filters.itemUuid] ?? 'Item'));
  }
  if (filters.event != null) {
    out.add(ExportFilter(
      'Event',
      ItemHistoryReportQuery.formatEventName(filters.event!),
    ));
  }
  if (filters.staffId != null) {
    out.add(ExportFilter('Creator', staffNames[filters.staffId] ?? 'Creator'));
  }
  final direction = switch (filters.quantityDirection) {
    QuantityDirectionFilter.increase => 'Increase',
    QuantityDirectionFilter.decrease => 'Decrease',
    QuantityDirectionFilter.zeroChange => 'No Change',
    QuantityDirectionFilter.all => null,
  };
  if (direction != null) out.add(ExportFilter('Direction', direction));
  if (filters.source != null) {
    out.add(ExportFilter(
      'Source',
      ItemHistoryReportQuery.formatSourceOrDestination(filters.source!),
    ));
  }
  if (filters.supplier != null) {
    out.add(ExportFilter('Supplier', filters.supplier!));
  }
  final tracking = filters.trackingNumber?.trim();
  if (tracking != null && tracking.isNotEmpty) {
    out.add(ExportFilter('Tracking', tracking));
  }
  if (filters.destination != null) {
    out.add(ExportFilter(
      'Destination',
      ItemHistoryReportQuery.formatSourceOrDestination(filters.destination!),
    ));
  }
  if (departmentsEnabled && filters.departmentUuid != null) {
    out.add(ExportFilter(
      'Department',
      filters.departmentUuid == itemHistoryReportNoneKey
          ? 'No Department'
          : departmentNames[filters.departmentUuid] ?? 'Department',
    ));
  }
  if (filters.isManaged != null) {
    out.add(ExportFilter(
      'Managed',
      filters.isManaged! ? 'Managed' : 'Un-Managed',
    ));
  }
  return out;
}

/// [rows] is the full filtered and sorted list. [categoryIdsByItem] maps
/// an item uuid to its categories (history rows carry none); [sizeLabels]
/// maps a 2D sheet item's uuid to its " (4 x 2)".
ReportExportSpec itemHistoryExportSpec({
  required List<ItemHistory> rows,
  required ItemHistoryReportFilters filters,
  required ItemHistorySortField sortField,
  required bool ascending,
  required String dateLabel,
  required String currency,
  required bool departmentsEnabled,
  String? lockedItemName,
  Map<String, String> itemNames = const {},
  Map<String, String> staffNames = const {},
  Map<String, String> departmentNames = const {},
  Map<String, List<String>> categoryIdsByItem = const {},
  Map<String, String> categoryNames = const {},
  Map<String, String> sizeLabels = const {},
}) {
  final f = ExportFormatter(currency: currency);
  final number = Map<ItemHistory, int>.identity();
  for (var i = 0; i < rows.length; i++) {
    number[rows[i]] = i + 1;
  }
  String text(String? v) => _clean(v) ?? _dash;
  String? size(ItemHistory h) =>
      h.itemUuid == null ? null : sizeLabels[h.itemUuid];

  final section = ExportTableSection<ItemHistory>(
    title: 'Item History',
    rows: rows,
    columns: [
      ExportColumn(
        id: 'no',
        label: 'No.',
        format: ExportFormat.integer,
        value: (h) => number[h],
        width: 0.5,
      ),
      ExportColumn(
        id: 'item',
        label: 'Item Name',
        value: (h) => _clean(h.itemName),
        display: (h) => text(h.itemName),
        width: 2,
      ),
      ExportColumn(
        id: 'created',
        label: 'Created Date',
        format: ExportFormat.dateTime,
        value: (h) => h.createdAt,
        display: (h) => h.createdAt == null ? _dash : f.dateTime(h.createdAt!),
        width: 1.5,
      ),
      ExportColumn(
        id: 'title',
        label: 'History Title',
        value: (h) => _clean(h.title),
        display: (h) => text(h.title),
        width: 1.8,
      ),
      ExportColumn(
        id: 'event',
        label: 'Event',
        value: (h) => _clean(h.event) == null
            ? null
            : ItemHistoryReportQuery.formatEventName(h.event!),
        display: (h) => _clean(h.event) == null
            ? _dash
            : ItemHistoryReportQuery.formatEventName(h.event!),
        width: 1.2,
      ),
      ExportColumn(
        id: 'source',
        label: 'Source',
        value: (h) => _clean(h.source) == null
            ? null
            : ItemHistoryReportQuery.formatSourceOrDestination(h.source!),
        display: (h) => _clean(h.source) == null
            ? _dash
            : ItemHistoryReportQuery.formatSourceOrDestination(h.source!),
      ),
      ExportColumn(
        id: 'destination',
        label: 'Destination',
        value: (h) => _clean(h.destination) == null
            ? null
            : ItemHistoryReportQuery.formatSourceOrDestination(
                h.destination!,
              ),
        display: (h) => _clean(h.destination) == null
            ? _dash
            : ItemHistoryReportQuery.formatSourceOrDestination(
                h.destination!,
              ),
      ),
      ExportColumn(
        id: 'supplier',
        label: 'Supplier',
        value: (h) => _clean(h.supplier),
        display: (h) => text(h.supplier),
        inPdf: false,
      ),
      ExportColumn(
        id: 'tracking',
        label: 'Tracking Number',
        value: (h) => _clean(h.trackingNumber),
        display: (h) => text(h.trackingNumber),
        inPdf: false,
      ),
      ExportColumn(
        id: 'desc',
        label: 'Description',
        value: (h) => _clean(h.desc),
        display: (h) => text(h.desc),
        width: 2,
      ),
      ExportColumn(
        id: 'qty',
        label: 'Quantity Change',
        format: ExportFormat.quantity,
        value: itemHistorySignedQuantity,
        display: (h) => itemHistoryQuantityText(h, f, sizeLabel: size(h)),
        width: 1.5,
      ),
      ExportColumn(
        id: 'unit',
        label: 'Unit',
        value: (h) => _clean(itemHistoryUnitText(h)),
        display: (h) => text(itemHistoryUnitText(h)),
        inPdf: false,
      ),
      ExportColumn(
        id: 'old',
        label: 'Old Value',
        format: ExportFormat.quantity,
        value: (h) => _number(h.oldValue) ?? _clean(h.oldValue),
        display: (h) => _valueText(h.oldValue, h.primaryUnit),
      ),
      ExportColumn(
        id: 'new',
        label: 'New Value',
        format: ExportFormat.quantity,
        value: (h) => _number(h.newValue) ?? _clean(h.newValue),
        display: (h) => _valueText(h.newValue, h.primaryUnit),
      ),
      if (departmentsEnabled)
        ExportColumn(
          id: 'department',
          label: 'Department',
          value: (h) => _clean(h.departmentName),
          display: (h) => text(h.departmentName),
          width: 1.2,
        ),
      ExportColumn(
        id: 'managed',
        label: 'Managed',
        value: (h) => h.isManaged == null
            ? 'N/A'
            : (h.isManaged! ? 'Managed' : 'Un-Managed'),
        inPdf: false,
      ),
      ExportColumn(
        id: 'staff',
        label: 'Creator',
        value: (h) => _clean(h.staffName),
        display: (h) => text(h.staffName),
        width: 1.2,
      ),
    ],
    // Export-only total: the record count. Quantities are in mixed units,
    // so they aren't summed.
    totalsFor: (rs) => {
      'item': '${f.integer(rs.length)} ${rs.length == 1 ? 'record' : 'records'}',
    },
    splits: [
      categorySplit<ItemHistory>(
        categoryIds: (h) =>
            h.itemUuid == null ? const [] : categoryIdsByItem[h.itemUuid] ?? const [],
        names: categoryNames,
      ),
      if (departmentsEnabled)
        departmentSplit<ItemHistory>(
          departmentId: (h) => _clean(h.departmentUuid),
          names: departmentNames,
        ),
      staffSplit<ItemHistory>(
        rows: rows,
        staffId: (h) => h.staffId,
        staffName: (h) => h.staffName,
      ),
    ],
    // 58mm: 13 / 18 characters, 80mm: 10 / 18 / 18, so "+3 Sheets (4 x 2)"
    // and "Production Deleted" stay on one line.
    roll: const RollLayout(
      cols58: ['item', 'qty'],
      cols80: ['item', 'event', 'qty'],
      sub58: ['created'],
      sub80: ['created', 'staff'],
      flex58: [7, 9],
      flex80: [4, 7, 6],
    ),
    emptyMessage: 'No history record matches the selected filters.',
  );

  return ReportExportSpec(
    reportName: 'Item History',
    fileSlug: 'item_history',
    period: ExportPeriod(
      label: dateLabel,
      start: filters.dateRange?.start,
      end: filters.dateRange?.end,
    ),
    filters: itemHistoryExportFilters(
      filters: filters,
      departmentsEnabled: departmentsEnabled,
      lockedItemName: lockedItemName,
      itemNames: itemNames,
      staffNames: staffNames,
      departmentNames: departmentNames,
    ),
    sortedBy: itemHistorySortLabel(sortField, ascending),
    sections: [section],
  );
}
