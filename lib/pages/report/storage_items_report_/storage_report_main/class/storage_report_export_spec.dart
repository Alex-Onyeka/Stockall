// Export spec of the Storage Report table: every filtered, sorted
// storage item (not just the page), with the screen's column conditions
// (cost, quantity access, item-history tracking). The screen has no
// totals row, so the totals are export-only: the item count and, with
// cost access, the total cost value. Quantities are in each item's own
// unit and aren't added up. No splits: the screen has no Department
// filter and storage items have no category.

import 'package:flutter/material.dart' show DateTimeRange;
import 'package:stockall/classes/temp_storage_product/temp_storage_products.dart';
import 'package:stockall/pages/report/components/export/report_export_format.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/invoice_report/invoice_report_table/class/invoice_report_export_spec.dart'
    show invoicePeriodLabel;
import 'package:stockall/pages/report/items_report_/items_report_main/class/items_report_export_spec.dart'
    show exportSheetSizeLabel;
import 'package:stockall/pages/report/storage_items_report_/storage_report_main/class/storage_report_main_logic.dart';

const String _dash = '—';
const String _masked = '****';

/// " (4 x 2)" for a 2D sheet storage item with a size, else null.
String? storageSizeLabel(TempStorageProducts s) => exportSheetSizeLabel(
  quantityType: s.quantityType,
  primaryUnit: s.getPrimaryUnit,
  width: s.widthDimension,
  height: s.heightDimension,
  dimensionUnit: s.dimensionUnit,
);

/// The primary unit, with the sheet size for 2D sheet items:
/// "Sheets (4 x 2)".
String storageUnitLabel(StorageReportRow r) {
  final size = storageSizeLabel(r.storageProduct);
  return size == null || size.isEmpty ? r.primaryUnit : '${r.primaryUnit}$size';
}

const Map<StorageSortField, String> storageSortLabels = {
  StorageSortField.name: 'Item Name',
  StorageSortField.quantity: 'Quantity',
  StorageSortField.primaryUnit: 'Primary Unit',
  StorageSortField.openingStock: 'Opening Stock',
  StorageSortField.closingStock: 'Closing Stock',
  StorageSortField.stockChange: 'Stock Change',
  StorageSortField.costPrice: 'Cost Price',
  StorageSortField.totalCostValue: 'Total Cost Value',
  StorageSortField.quantityType: 'Quantity Type',
  StorageSortField.createdAt: 'Created Date',
  StorageSortField.itemsInSalesCount: 'Item In Sales',
  StorageSortField.quantityInSales: 'Quantity In Sales',
  StorageSortField.totalQuantity: 'Total Quantity',
};

/// The table's filters with their values, worded like its chips.
List<ExportFilter> storageExportFilters({
  required StorageReportFilters filters,
  required bool canSeeCost,
  required ExportFormatter f,
}) {
  String any(num? v, String Function(num) fmt) => v == null ? 'Any' : fmt(v);
  final out = <ExportFilter>[];
  final search = filters.search.trim();
  if (search.isNotEmpty) out.add(ExportFilter('Search', search));
  if (canSeeCost && (filters.costMin != null || filters.costMax != null)) {
    out.add(ExportFilter(
      'Cost',
      '${any(filters.costMin, f.money)} - ${any(filters.costMax, f.money)}',
    ));
  }
  if (filters.quantityMin != null || filters.quantityMax != null) {
    out.add(ExportFilter(
      'Qty',
      '${any(filters.quantityMin, f.quantity)} - ${any(filters.quantityMax, f.quantity)}',
    ));
  }
  if (filters.salesItemsCountMin != null || filters.salesItemsCountMax != null) {
    out.add(ExportFilter(
      'Sales items',
      '${filters.salesItemsCountMin ?? 'Any'} - ${filters.salesItemsCountMax ?? 'Any'}',
    ));
  }
  return out;
}

double? _sum(List<StorageReportRow> rows, double? Function(StorageReportRow) v) {
  double? total;
  for (final r in rows) {
    final x = v(r);
    if (x != null) total = (total ?? 0) + x;
  }
  return total;
}

ExportTableSection<StorageReportRow> storageTableSection({
  required List<StorageReportRow> rows,
  required Map<String, StorageStockMovement> movements,
  required bool canSeeCost,
  required bool canSeeQuantity,
  required bool historyTracked,
  required ExportFormatter f,
}) {
  final number = Map<StorageReportRow, int>.identity();
  for (var i = 0; i < rows.length; i++) {
    number[rows[i]] = i + 1;
  }
  String unitText(StorageReportRow r, double v, [String sign = '']) =>
      '$sign${f.quantity(v)} ${storageUnitLabel(r)}';

  // Quantity access hides every quantity; without history tracking
  // the movements are "N/A".
  ExportColumn<StorageReportRow> movement(
    String id,
    String label,
    double? Function(StorageStockMovement m) pick, {
    bool signed = false,
  }) {
    double? value(StorageReportRow r) {
      final m = movements[r.uuid];
      return m == null ? null : pick(m);
    }

    return ExportColumn<StorageReportRow>(
      id: id,
      label: label,
      format: ExportFormat.quantity,
      value: (r) => canSeeQuantity && historyTracked ? value(r) : null,
      display: (r) {
        if (!canSeeQuantity) return _masked;
        if (!historyTracked) return 'N/A';
        final v = value(r);
        if (v == null) return _dash;
        return signed && v > 0 ? '+${f.quantity(v)}' : f.quantity(v);
      },
      width: 1.1,
    );
  }

  ExportColumn<StorageReportRow> qty(
    String id,
    String label,
    double? Function(StorageReportRow) v,
  ) => ExportColumn<StorageReportRow>(
    id: id,
    label: label,
    format: ExportFormat.quantity,
    value: (r) => canSeeQuantity ? v(r) : null,
    display: (r) {
      if (!canSeeQuantity) return _masked;
      final x = v(r);
      return x == null ? _dash : unitText(r, x);
    },
    width: 1.3,
  );

  return ExportTableSection<StorageReportRow>(
    title: 'Storage Items',
    rows: rows,
    columns: [
      ExportColumn(
        id: 'no',
        label: 'No.',
        format: ExportFormat.integer,
        value: (r) => number[r],
        width: 0.5,
      ),
      ExportColumn(id: 'name', label: 'Item Name', value: (r) => r.name, width: 1.8),
      qty('quantity', 'Quantity', (r) => r.quantity),
      ExportColumn(id: 'unit', label: 'Primary Unit', value: storageUnitLabel, width: 1.2),
      movement('opening', 'Opening Stock', (m) => m.opening),
      movement('closing', 'Closing Stock', (m) => m.closing),
      movement('change', 'Stock Change', (m) => m.change, signed: true),
      if (canSeeCost) ...[
        ExportColumn(
          id: 'costPrice',
          label: 'Cost Price',
          format: ExportFormat.money,
          value: (r) => r.costPrice,
          display: (r) => r.costPrice == null ? _dash : f.money(r.costPrice!),
          width: 1.1,
        ),
        ExportColumn(
          id: 'costTotal',
          label: 'Total Cost Value',
          format: ExportFormat.money,
          value: (r) => r.totalCostValue,
          display: (r) => r.totalCostValue == null ? _dash : f.money(r.totalCostValue!),
          width: 1.3,
        ),
      ],
      ExportColumn(id: 'type', label: 'Quantity Type', value: (r) => r.quantityTypeLabel),
      ExportColumn(
        id: 'createdDate',
        label: 'Created Date',
        format: ExportFormat.date,
        value: (r) => r.createdAt,
        display: (r) => r.createdAt == null ? _dash : f.date(r.createdAt!),
      ),
      ExportColumn(
        id: 'createdTime',
        label: 'Created Time',
        format: ExportFormat.time,
        value: (r) => r.createdAt,
        display: (r) => r.createdAt == null ? _dash : f.time(r.createdAt!),
        width: 0.8,
      ),
      ExportColumn(
        id: 'inSales',
        label: 'Item In Sales',
        value: (r) => r.itemsInSalesLabel,
        width: 1.6,
      ),
      qty('quantityInSales', 'Quantity In Sales', (r) => r.quantityInSales),
      qty('totalQuantity', 'Total Quantity', (r) => r.totalQuantity),
    ],
    // Export-only totals (the screen has no totals row).
    totalsFor: (rs) => {
      'name': '${f.integer(rs.length)} ${rs.length == 1 ? 'item' : 'items'}',
      if (canSeeCost) 'costTotal': _sum(rs, (r) => r.totalCostValue),
    },
    // 58mm: 15 / 16 characters, 80mm: 15 / 17 / 14, so
    // "3 Sheets (4 x 2)" and "₦1,250,000.00" stay on one line.
    roll: RollLayout(
      cols58: const ['name', 'quantity'],
      cols80: ['name', 'quantity', canSeeCost ? 'costTotal' : 'totalQuantity'],
      flex58: const [1, 1],
      flex80: const [16, 18, 14],
    ),
    emptyMessage: 'No storage item matches your search and filters.',
  );
}

/// [rows] is the full filtered and sorted list; [movements] has every
/// row's opening / closing stock for [range].
ReportExportSpec storageReportExportSpec({
  required List<StorageReportRow> rows,
  required Map<String, StorageStockMovement> movements,
  required StorageReportFilters filters,
  required StorageSortField sortField,
  required bool ascending,
  required DateTimeRange range,
  required bool canSeeCost,
  required bool canSeeQuantity,
  required bool historyTracked,
  required String currency,
}) {
  final f = ExportFormatter(currency: currency);
  return ReportExportSpec(
    reportName: 'Storage Report',
    fileSlug: 'storage_report',
    period: ExportPeriod(
      label: invoicePeriodLabel(range),
      start: range.start,
      end: range.end,
    ),
    filters: storageExportFilters(filters: filters, canSeeCost: canSeeCost, f: f),
    sortedBy: '${storageSortLabels[sortField] ?? sortField.name} '
        '(${ascending ? 'ascending' : 'descending'})',
    sections: [
      storageTableSection(
        rows: rows,
        movements: movements,
        canSeeCost: canSeeCost,
        canSeeQuantity: canSeeQuantity,
        historyTracked: historyTracked,
        f: f,
      ),
    ],
  );
}
