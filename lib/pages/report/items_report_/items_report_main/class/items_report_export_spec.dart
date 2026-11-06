// Export spec of the Items Report main table: the same rows (the full
// filtered and sorted list, not the page), columns, period, filters and
// sort as the screen, for the shared Export button.

import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/classes/temp_product_class/units_class/product_units_class.dart';
import 'package:stockall/constants/calculations.dart'
    show formatDimensionsLabel, stripDimensionLabel;
import 'package:stockall/pages/report/components/export/report_export_format.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/export/report_export_splits.dart';
import 'package:stockall/pages/report/items_report_/items_report_main/class/items_report_main_logic.dart';

const String _dash = '—';
const String _masked = '****';

/// Column label of each sort field, as on the screen.
const Map<ItemsSortField, String> itemsSortLabels = {
  ItemsSortField.name: 'Item Name',
  ItemsSortField.createdAt: 'Created Date',
  ItemsSortField.quantity: 'Quantity',
  ItemsSortField.sellingPrice: 'Selling Price',
  ItemsSortField.costPrice: 'Cost Price',
  ItemsSortField.totalCostValue: 'Total Cost Value',
  ItemsSortField.profitPerUnit: 'Profit Per Unit',
  ItemsSortField.expiry: 'Expiry Date',
  ItemsSortField.totalSellingValue: 'Total Selling Value',
  ItemsSortField.profit: 'Total Profit',
  ItemsSortField.margin: 'Profit Margin',
  ItemsSortField.category: 'Category',
  ItemsSortField.department: 'Department',
  ItemsSortField.openingStock: 'Opening Stock',
  ItemsSortField.closingStock: 'Closing Stock',
  ItemsSortField.stockChange: 'Stock Change',
};

String itemsSortLabel(ItemsSortField field, bool ascending) =>
    '${itemsSortLabels[field] ?? field.name} '
    '(${ascending ? 'ascending' : 'descending'})';

/// The sheet size of a 2D item whose primary unit is a sheet unit,
/// " (4 x 2)" (the cart's rule, temp_cart_item.dart), or '' when its size
/// isn't set. Null when it isn't a 2D sheet item.
String? itemsExportSizeLabel(TempProductClass p) => exportSheetSizeLabel(
  quantityType: p.quantityType,
  primaryUnit: p.getPrimaryUnit,
  width: p.widthDimension,
  height: p.heightDimension,
  dimensionUnit: p.dimensionUnit,
);

/// [itemsExportSizeLabel]'s rule for any item with a primary unit and
/// a sheet size (sales items and storage items).
String? exportSheetSizeLabel({
  required int? quantityType,
  required ProductUnitsClass Function() primaryUnit,
  required double? width,
  required double? height,
  required String? dimensionUnit,
}) {
  if (quantityType != 2) return null;
  try {
    if (primaryUnit().dimensionType != ProductUnitsClass.sheetUnit) {
      return null;
    }
    return formatDimensionsLabel(width, height, unit: dimensionUnit);
  } catch (_) {
    return null;
  }
}

/// The primary unit, with the sheet size for 2D sheet items:
/// "Sheets (4 x 2)".
String itemsExportUnitLabel(ItemsReportRow r) {
  final unit = r.primaryUnit.trim();
  if (!r.isTwoDimensional) return unit;
  final size = itemsExportSizeLabel(r.product);
  if (size == null) return unit;
  return '${stripDimensionLabel(unit)}$size';
}

/// "12 Bottles", "3 Sheets (4 x 2)"; "—" when the item is not managed.
String itemsExportQuantityText(ItemsReportRow r, ExportFormatter f) {
  final q = r.quantity;
  if (q == null) return _dash;
  final unit = itemsExportUnitLabel(r);
  return unit.isEmpty ? f.quantity(q) : '${f.quantity(q)} $unit';
}

/// The active filters with their values, worded like the screen chips.
List<ExportFilter> itemsExportFilters({
  required ItemsReportFilters filters,
  required ExportFormatter f,
  required bool canSeeCost,
  required bool departmentsEnabled,
  required Map<String, String> categoryNames,
  required Map<String, String> departmentNames,
}) {
  String range(num? min, num? max, String Function(num) fmt) =>
      '${min != null ? fmt(min) : 'Any'} - ${max != null ? fmt(max) : 'Any'}';

  final out = <ExportFilter>[];
  final search = filters.search.trim();
  if (search.isNotEmpty) out.add(ExportFilter('Search', '"$search"'));

  if (filters.categoryKey != null) {
    out.add(ExportFilter(
      'Category',
      filters.categoryKey == itemsReportNoneKey
          ? 'No Category'
          : categoryNames[filters.categoryKey] ?? 'Category',
    ));
  }
  if (departmentsEnabled && filters.departmentKey != null) {
    out.add(ExportFilter(
      'Department',
      filters.departmentKey == itemsReportNoneKey
          ? 'No Department'
          : departmentNames[filters.departmentKey] ?? 'Department',
    ));
  }
  final level = switch (filters.stockLevel) {
    StockLevelFilter.inStock => 'In Stock',
    StockLevelFilter.lowStock => 'Low in Stock',
    StockLevelFilter.outOfStock => 'Out of Stock',
    StockLevelFilter.all => null,
  };
  if (level != null) out.add(ExportFilter('Quantity', level));
  if (filters.managed != null) {
    out.add(ExportFilter(
      'Is-Managed',
      filters.managed! ? 'Managed' : 'Un-Managed',
    ));
  }
  if (filters.sellingMin != null || filters.sellingMax != null) {
    out.add(ExportFilter(
      'Selling',
      range(filters.sellingMin, filters.sellingMax, f.money),
    ));
  }
  if (canSeeCost && (filters.costMin != null || filters.costMax != null)) {
    out.add(ExportFilter(
      'Cost',
      range(filters.costMin, filters.costMax, f.money),
    ));
  }
  if (filters.quantityMin != null || filters.quantityMax != null) {
    out.add(ExportFilter(
      'Qty',
      range(filters.quantityMin, filters.quantityMax, f.quantity),
    ));
  }
  final s = filters.expiryStart;
  final e = filters.expiryEnd;
  if (s != null || e != null) {
    String text;
    if (s != null && e != null) {
      final same = s.year == e.year && s.month == e.month && s.day == e.day;
      text = same ? f.date(s) : '${f.date(s)} - ${f.date(e)}';
    } else if (s != null) {
      text = 'From ${f.date(s)}';
    } else {
      text = 'Up to ${f.date(e!)}';
    }
    out.add(ExportFilter('Expiry', text));
  }
  return out;
}

double _sum(List<ItemsReportRow> rows, double? Function(ItemsReportRow) v) =>
    rows.fold<double>(0, (s, r) => s + (v(r) ?? 0));

ReportExportSpec itemsReportExportSpec({
  required List<ItemsReportRow> rows,
  required ItemsReportFilters filters,
  required ItemsSortField sortField,
  required bool ascending,
  required String rangeLabel,
  required String currency,
  required bool canSeeCost,
  required bool canSeeQuantity,
  required bool departmentsEnabled,
  required bool historyTracked,
  required ItemStockMovement? Function(String uuid) movement,
  required Map<String, String> categoryNames,
  required Map<String, String> departmentNames,
}) {
  final f = ExportFormatter(currency: currency);
  // "No." is the row's position in the export (1..N), by identity so two
  // rows can never share a number.
  final number = Map<ItemsReportRow, int>.identity();
  for (var i = 0; i < rows.length; i++) {
    number[rows[i]] = i + 1;
  }
  int? no(ItemsReportRow r) => number[r];

  // Opening/closing/change columns, as the screen shows them.
  ExportColumn<ItemsReportRow> movementColumn(
    String id,
    String label,
    double? Function(ItemStockMovement m) pick, {
    bool signed = false,
  }) {
    double? value(ItemsReportRow r) {
      if (!canSeeQuantity || !r.isManaged) return null;
      final m = movement(r.uuid);
      return m == null ? null : pick(m);
    }

    return ExportColumn<ItemsReportRow>(
      id: id,
      label: label,
      format: ExportFormat.quantity,
      value: value,
      display: (r) {
        if (!canSeeQuantity) return _masked;
        final v = value(r);
        if (v == null) return _dash;
        return signed && v > 0 ? '+${f.quantity(v)}' : f.quantity(v);
      },
    );
  }

  final section = ExportTableSection<ItemsReportRow>(
    title: 'Items',
    rows: rows,
    columns: [
      ExportColumn(
        id: 'no',
        label: 'No.',
        format: ExportFormat.integer,
        value: no,
        width: 0.5,
      ),
      ExportColumn(
        id: 'name',
        label: 'Item Name',
        value: (r) => r.name,
        width: 3,
      ),
      ExportColumn(
        id: 'qty',
        label: 'Quantity',
        format: ExportFormat.quantity,
        value: (r) => canSeeQuantity ? r.quantity : null,
        display: (r) =>
            canSeeQuantity ? itemsExportQuantityText(r, f) : _masked,
        width: 1.6,
      ),
      ExportColumn(
        id: 'unit',
        label: 'Primary Unit',
        value: (r) => r.primaryUnit,
      ),
      if (historyTracked) ...[
        movementColumn('opening', 'Opening Stock', (m) => m.opening),
        movementColumn('closing', 'Closing Stock', (m) => m.closing),
        movementColumn('change', 'Stock Change', (m) => m.change, signed: true),
      ],
      ExportColumn(
        id: 'sell',
        label: 'Selling Price',
        format: ExportFormat.money,
        value: (r) => r.sellingPrice,
      ),
      ExportColumn(
        id: 'sellTotal',
        label: 'Total Selling Value',
        format: ExportFormat.money,
        value: (r) => r.totalSellingValue,
        display: (r) => r.totalSellingValue == null
            ? _dash
            : f.money(r.totalSellingValue!),
        width: 1.3,
      ),
      if (canSeeCost) ...[
        ExportColumn(
          id: 'cost',
          label: 'Cost Price',
          format: ExportFormat.money,
          value: (r) => r.costPrice,
        ),
        ExportColumn(
          id: 'costTotal',
          label: 'Total Cost Value',
          format: ExportFormat.money,
          value: (r) => r.totalCostValue,
          display: (r) => r.totalCostValue == null
              ? _dash
              : f.money(r.totalCostValue!),
          width: 1.3,
        ),
        ExportColumn(
          id: 'profitUnit',
          label: 'Profit Per Unit',
          format: ExportFormat.money,
          value: (r) => r.profitPerUnit,
        ),
        ExportColumn(
          id: 'profit',
          label: 'Total Profit',
          format: ExportFormat.money,
          value: (r) => r.profit,
          display: (r) => r.profit == null ? _dash : f.money(r.profit!),
        ),
        ExportColumn(
          id: 'margin',
          label: 'Profit Margin',
          format: ExportFormat.percent,
          value: (r) => r.margin,
          display: (r) => r.margin == null ? 'N/A' : f.percent(r.margin!),
        ),
      ],
      ExportColumn(
        id: 'discount',
        label: 'Discount',
        format: ExportFormat.percent,
        value: (r) =>
            (r.discount == null || r.discount == 0) ? null : r.discount,
        display: (r) => (r.discount == null || r.discount == 0)
            ? _dash
            : f.percent(r.discount!),
        width: 0.8,
      ),
      ExportColumn(
        id: 'expiry',
        label: 'Expiry Date',
        format: ExportFormat.date,
        value: (r) => r.expiryDate,
        display: (r) {
          if (r.expiryDate == null) return 'Not Set';
          if (r.isExpired) return 'Expired';
          return f.date(r.expiryDate!);
        },
      ),
      if (departmentsEnabled)
        ExportColumn(
          id: 'department',
          label: 'Department',
          value: (r) => r.departmentLabel,
          width: 1.3,
        ),
      ExportColumn(
        id: 'qtyType',
        label: 'Quantity Type',
        value: (r) => r.quantityTypeLabel,
        inPdf: false,
      ),
      ExportColumn(
        id: 'managed',
        label: 'Is-Managed',
        value: (r) => r.isManaged ? 'Managed' : 'Un-Managed',
        inPdf: false,
      ),
      ExportColumn(
        id: 'created',
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
        inPdf: false,
      ),
      ExportColumn(
        id: 'category',
        label: 'Category',
        value: (r) => r.categoryLabel,
        width: 1.5,
      ),
    ],
    // Export-only totals (the screen has no totals row).
    totalsFor: (rs) => {
      'name': '${f.integer(rs.length)} ${rs.length == 1 ? 'item' : 'items'}',
      'sellTotal': _sum(rs, (r) => r.totalSellingValue),
      if (canSeeCost) ...{
        'costTotal': _sum(rs, (r) => r.totalCostValue),
        'profit': _sum(rs, (r) => r.profit),
      },
    },
    splits: [
      categorySplit<ItemsReportRow>(
        categoryIds: (r) => r.categoryUuids,
        names: categoryNames,
      ),
      if (departmentsEnabled)
        departmentSplit<ItemsReportRow>(
          departmentId: (r) => r.departmentUuid,
          names: departmentNames,
        ),
    ],
    // 80mm: a wider quantity column so "12 Bottles" stays on one line
    // (19 / 14 / 15 characters).
    roll: const RollLayout(
      cols58: ['name', 'qty'],
      cols80: ['name', 'qty', 'sellTotal'],
      flex80: [4, 3, 3],
    ),
    emptyMessage: 'No items match the selected filters.',
  );

  return ReportExportSpec(
    reportName: 'Items Report',
    fileSlug: 'items_report',
    period: ExportPeriod(label: rangeLabel),
    filters: itemsExportFilters(
      filters: filters,
      f: f,
      canSeeCost: canSeeCost,
      departmentsEnabled: departmentsEnabled,
      categoryNames: categoryNames,
      departmentNames: departmentNames,
    ),
    sortedBy: itemsSortLabel(sortField, ascending),
    sections: [section],
  );
}
