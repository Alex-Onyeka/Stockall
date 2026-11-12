// Export spec of the stock table (I1 / M1): the full filtered and
// sorted rows, with the screen's columns, masking and totals. Splits:
// Category and Department.

import 'package:stockall/pages/report/components/export/report_export_format.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/export/report_export_splits.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/production_stock_model.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/stock_items_logic.dart';
import 'package:stockall/pages/report/production_report/stock_shared/components/stock_filter_widgets.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/components/receipts_report_filter_widgets.dart'
    show receiptsPeriodLabel;

const String _dash = '—';
const String _masked = '****';

/// The column label of a sort, for the info box.
String productionStockSortLabel(ProductionStockSort s, ProductionStockKind kind) {
  final label = switch (s.field) {
    ProductionStockSortField.name => kind.singular,
    ProductionStockSortField.unit => 'Primary Unit',
    ProductionStockSortField.quantity => 'Stock',
    ProductionStockSortField.costPrice => 'Cost Price',
    ProductionStockSortField.stockValue => 'Stock Value',
    ProductionStockSortField.department => 'Department',
    ProductionStockSortField.category => 'Category',
    ProductionStockSortField.expiry => 'Expiry',
    ProductionStockSortField.managed => 'Managed',
    ProductionStockSortField.createdAt => 'Created',
    ProductionStockSortField.opening => 'Opening',
    ProductionStockSortField.closing => 'Closing',
    ProductionStockSortField.movement => s.movement?.label ?? 'Movement',
    ProductionStockSortField.net => 'Net',
    ProductionStockSortField.lowQuantity => 'Low Stock Qty',
    ProductionStockSortField.usedInProduction => 'Used in Production',
    ProductionStockSortField.usedManually => 'Used Manually',
    ProductionStockSortField.usageCost => 'Usage Cost',
  };
  return '$label (${s.ascending ? 'ascending' : 'descending'})';
}

/// "15 Pcs"; "—" for an unmanaged item; "****" without the permission.
String productionStockQuantityText(
  ProductionStockRow r,
  String Function(num v) number, {
  required bool canSeeQuantity,
}) {
  if (!canSeeQuantity) return _masked;
  final q = r.quantity;
  return q == null ? _dash : '${number(q)} ${r.primaryUnit}';
}

/// "Oct 20, 2026", with "(Expired)" once it has passed.
String productionStockExpiryText(ProductionStockRow r, ExportFormatter f) {
  final e = r.expiryDate;
  if (e == null) return _dash;
  return r.isExpired ? '${f.date(e)} (Expired)' : f.date(e);
}

ExportTableSection<ProductionStockRow> productionStockItemsSection({
  required ProductionStockKind kind,
  required List<ProductionStockRow> rows,
  required Map<String, String> categoryNames,
  required ExportFormatter f,
  required bool departmentsEnabled,
  required bool canSeeCost,
  required bool canSeeQuantity,
  required bool historyAllowed,
}) {
  ExportColumn<ProductionStockRow> qty(
    String id,
    String label,
    double? Function(ProductionStockRow r) pick, {
    bool signed = false,
    bool managedOnly = true,
  }) {
    double? value(ProductionStockRow r) =>
        canSeeQuantity && (!managedOnly || r.isManaged) ? pick(r) : null;
    return ExportColumn<ProductionStockRow>(
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

  final departmentNames = <String, String>{
    for (final r in rows)
      if (r.departmentKey != null) r.departmentKey!: r.departmentLabel,
  };
  final value = rows.fold<double>(0, (s, r) => s + (r.stockValue ?? 0));
  final material = kind == ProductionStockKind.material;
  double usageCost(List<ProductionStockRow> rs) =>
      rs.fold(0, (s, r) => s + (r.materialUsage?.totalCost ?? 0));

  final RollLayout roll =
      canSeeCost
          ? const RollLayout(
            cols58: ['name', 'stockValue'],
            cols80: ['name', 'qtyRoll', 'stockValue'],
            flex58: [1, 1],
            flex80: [20, 14, 14],
          )
          : const RollLayout(
            cols58: ['name', 'qtyRoll'],
            cols80: ['name', 'qtyRoll'],
            flex58: [1, 1],
            flex80: [3, 2],
          );

  return ExportTableSection<ProductionStockRow>(
    title: kind.plural,
    rows: rows,
    columns: [
      ExportColumn(id: 'name', label: kind.singular, value: (r) => r.name, width: 2.2),
      ExportColumn(id: 'unit', label: 'Primary Unit', value: (r) => r.primaryUnit),
      ExportColumn<ProductionStockRow>(
        id: 'quantity',
        label: 'Stock',
        format: ExportFormat.quantity,
        value: (r) => canSeeQuantity ? r.quantity : null,
        display:
            (r) => productionStockQuantityText(
              r,
              f.quantity,
              canSeeQuantity: canSeeQuantity,
            ),
        width: 1.3,
      ),
      if (material)
        ExportColumn<ProductionStockRow>(
          id: 'lowQuantity',
          label: 'Low Stock Qty',
          format: ExportFormat.quantity,
          value: (r) => canSeeQuantity ? r.lowQuantity : null,
          display: (r) {
            if (!canSeeQuantity) return _masked;
            final v = r.lowQuantity;
            return v == null ? _dash : f.quantity(v);
          },
        ),
      // Roll only: the stock, short.
      ExportColumn<ProductionStockRow>(
        id: 'qtyRoll',
        label: 'Stock',
        value:
            (r) => productionStockQuantityText(
              r,
              f.quantity,
              canSeeQuantity: canSeeQuantity,
            ),
        inPdf: false,
        inExcel: false,
      ),
      if (canSeeCost) ...[
        ExportColumn(
          id: 'costPrice',
          label: 'Cost Price',
          format: ExportFormat.money,
          value: (r) => r.costPrice,
          width: 1.2,
        ),
        ExportColumn<ProductionStockRow>(
          id: 'stockValue',
          label: 'Stock Value',
          format: ExportFormat.money,
          value: (r) => canSeeQuantity ? r.stockValue : null,
          display: (r) {
            if (!canSeeQuantity) return _masked;
            final v = r.stockValue;
            return v == null ? _dash : f.money(v);
          },
          width: 1.3,
        ),
      ],
      if (departmentsEnabled)
        ExportColumn(
          id: 'department',
          label: 'Department',
          value: (r) => r.departmentLabel,
          width: 1.2,
        ),
      ExportColumn(
        id: 'category',
        label: 'Categories',
        value: (r) => r.categoryLabel,
        width: 1.4,
      ),
      ExportColumn<ProductionStockRow>(
        id: 'expiry',
        label: 'Expiry',
        format: ExportFormat.date,
        value: (r) => r.expiryDate,
        display: (r) => productionStockExpiryText(r, f),
        width: 1.3,
      ),
      ExportColumn(
        id: 'managed',
        label: 'Managed',
        value: (r) => r.isManaged ? 'Yes' : 'No',
        width: 0.8,
      ),
      ExportColumn<ProductionStockRow>(
        id: 'created',
        label: 'Created',
        format: ExportFormat.date,
        value: (r) => r.createdAt,
        display: (r) => r.createdAt == null ? _dash : f.date(r.createdAt!),
      ),
      if (historyAllowed) ...[
        qty('opening', 'Opening', (r) => r.balance.opening),
        for (final m in productionMovementColumns(kind))
          qty(m.name, m.label, (r) => r.movement.of(m)),
        qty('net', 'Net', (r) => r.movement.net, signed: true),
        qty('closing', 'Closing', (r) => r.balance.closing),
      ],
      if (material) ...[
        qty(
          'usedInProduction',
          'Used in Production',
          (r) => r.materialUsage?.productionQty,
          managedOnly: false,
        ),
        qty(
          'usedManually',
          'Used Manually',
          (r) => r.materialUsage?.manualQty,
          managedOnly: false,
        ),
        if (canSeeCost)
          ExportColumn<ProductionStockRow>(
            id: 'usageCost',
            label: 'Usage Cost',
            format: ExportFormat.money,
            value: (r) => r.materialUsage?.totalCost,
            width: 1.2,
          ),
      ],
    ],
    totals: {
      'name': '${f.integer(rows.length)} ${kind.countNoun}',
      if (canSeeCost) 'stockValue': canSeeQuantity ? value : _masked,
      if (material && canSeeCost) 'usageCost': usageCost(rows),
    },
    totalsFor:
        (rs) => {
          'name': '${f.integer(rs.length)} ${kind.countNoun}',
          if (canSeeCost)
            'stockValue':
                canSeeQuantity
                    ? rs.fold<double>(0, (s, r) => s + (r.stockValue ?? 0))
                    : _masked,
          if (material && canSeeCost) 'usageCost': usageCost(rs),
        },
    splits: [
      categorySplit<ProductionStockRow>(
        categoryIds: (r) => r.categoryKeys,
        names: categoryNames,
      ),
      if (departmentsEnabled)
        departmentSplit<ProductionStockRow>(
          departmentId: (r) => r.departmentKey,
          names: departmentNames,
        ),
    ],
    roll: roll,
    emptyMessage:
        'No ${kind.singular.toLowerCase()} matches the selected filters.',
  );
}

/// [rows] is the full filtered and sorted list.
ReportExportSpec productionStockItemsExportSpec({
  required ProductionStockKind kind,
  required List<ProductionStockRow> rows,
  required ProductionStockTableState state,
  required ProductionStockFilterChoices choices,
  required Map<String, String> categoryNames,
  required ReceiptsReportPeriod period,
  required String currency,
  required bool departmentsEnabled,
  required bool canSeeCost,
  required bool canSeeQuantity,
  required bool historyAllowed,
}) {
  final f = ExportFormatter(currency: currency);
  return ReportExportSpec(
    reportName: '${kind.plural} Table',
    fileSlug: '${kind.slug}_table',
    period: ExportPeriod(
      label: receiptsPeriodLabel(period),
      start: period.start,
      end: period.end,
    ),
    filters: [
      for (final (label, value, _) in productionStockFilterEntries(
        kind: kind,
        filters: state.filters,
        choices: choices,
        departmentsEnabled: departmentsEnabled,
        canSeeCost: canSeeCost,
        canSeeQuantity: canSeeQuantity,
        money: f.money,
        number: f.quantity,
      ))
        ExportFilter(label, value),
    ],
    sortedBy: productionStockSortLabel(
      ProductionStockQuery.effectiveSort(
        state.sort,
        canSeeCost: canSeeCost,
        canSeeQuantity: canSeeQuantity,
      ),
      kind,
    ),
    notes: productionStockNotes(
      kind: kind,
      page: ProductionStockReportPage.items,
      period: period,
      historyAllowed: historyAllowed,
      notNormalised: productionStockNotNormalised(rows),
    ),
    sections: [
      productionStockItemsSection(
        kind: kind,
        rows: rows,
        categoryNames: categoryNames,
        f: f,
        departmentsEnabled: departmentsEnabled,
        canSeeCost: canSeeCost,
        canSeeQuantity: canSeeQuantity,
        historyAllowed: historyAllowed,
      ),
    ],
  );
}
