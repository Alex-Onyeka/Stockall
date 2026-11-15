import 'package:stockall/pages/report/components/export/report_export_format.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/purchase_report/purchase_item_report/class/purchase_item_report_logic.dart';
import 'package:stockall/pages/report/purchase_report/purchase_report_table/class/purchase_report_table_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/components/receipts_report_filter_widgets.dart'
    show receiptsPeriodLabel;

List<ExportFilter> _purchaseItemFiltersList(
  PurchaseItemFilters filters, {
  required List<PurchaseItemRow> inPeriod,
  required bool departmentsEnabled,
}) {
  final out = <ExportFilter>[];
  void key(
    String label,
    String? k,
    List<PurchaseFilterOption> opts,
  ) {
    if (k == null) return;
    final match = opts.where((o) => o.key == k).firstOrNull;
    out.add(ExportFilter(label, match?.label ?? k));
  }

  if (filters.search.trim().isNotEmpty) {
    out.add(ExportFilter('Search', filters.search.trim()));
  }
  key('Item', filters.itemKey, PurchaseItemFilterBuilder.items(inPeriod));
  key(
    'Supplier',
    filters.supplierKey,
    PurchaseItemFilterBuilder.suppliers(inPeriod),
  );
  key('Staff', filters.staffKey, PurchaseItemFilterBuilder.staff(inPeriod));
  if (departmentsEnabled) {
    key(
      'Department',
      filters.departmentKey,
      PurchaseItemFilterBuilder.departments(inPeriod),
    );
  }
  key('Channel', filters.channelKey, PurchaseReportOptions.channels());
  if (filters.status != null) {
    out.add(ExportFilter('Status', filters.status!.label));
  }
  if (filters.itemType != PurchaseItemTypeFilter.all) {
    out.add(ExportFilter('Item Type', filters.itemType.label));
  }
  return out;
}

ReportExportSpec buildPurchaseItemExportSpec({
  required List<PurchaseItemRow> rows,
  required List<PurchaseItemRow> inPeriod,
  required PurchaseItemFilters filters,
  required ReceiptsReportPeriod period,
  required bool departmentsEnabled,
  required bool showStorageColumn,
  required ExportFormatter f,
}) {
  return ReportExportSpec(
    reportName: 'Purchase Item Report',
    fileSlug: 'purchase_item_report',
    period: ExportPeriod(
      label: receiptsPeriodLabel(period),
      start: period.start,
      end: period.end,
    ),
    filters: _purchaseItemFiltersList(
      filters,
      inPeriod: inPeriod,
      departmentsEnabled: departmentsEnabled,
    ),
    sections: [
      ExportTableSection<PurchaseItemRow>(
        title: 'Purchase Items',
        rows: rows,
        columns: [
          ExportColumn(
            id: 'item',
            label: 'Item',
            value: (r) => r.itemName,
            width: 1.5,
          ),
          if (showStorageColumn)
            ExportColumn(
              id: 'itemType',
              label: 'Type',
              value: (r) => r.itemTypeLabel,
            ),
          ExportColumn(
            id: 'purchaseId',
            label: 'Purchase ID',
            value: (r) => r.purchaseDisplayId,
          ),
          ExportColumn(
            id: 'globalSupplier',
            label: 'Global Supplier',
            value: (r) => r.globalSupplierLabel,
            width: 1.3,
          ),
          ExportColumn(
            id: 'itemSupplier',
            label: 'Item Supplier',
            value: (r) => r.itemSupplierLabel,
            width: 1.3,
          ),
          ExportColumn(
            id: 'globalTracking',
            label: 'Global Tracking',
            value: (r) => r.globalTrackingLabel,
            width: 1.2,
          ),
          ExportColumn(
            id: 'itemTracking',
            label: 'Item Tracking',
            value: (r) => r.itemTrackingLabel,
            width: 1.2,
          ),
          ExportColumn(
            id: 'quantity',
            label: 'Qty',
            format: ExportFormat.quantity,
            value: (r) => r.quantity,
            display: (r) => '${f.quantity(r.quantity)} ${r.unit}',
          ),
          ExportColumn(
            id: 'unitCost',
            label: 'Unit Cost',
            format: ExportFormat.money,
            value: (r) => r.unitCost,
          ),
          ExportColumn(
            id: 'total',
            label: 'Total',
            format: ExportFormat.money,
            value: (r) => r.lineTotal,
          ),
          ExportColumn(
            id: 'customPrice',
            label: 'Custom Price',
            value: (r) => r.customPriceLabel,
          ),
          ExportColumn(
            id: 'channel',
            label: 'Channel',
            value: (r) => r.channelLabel,
          ),
          ExportColumn(
            id: 'status',
            label: 'Status',
            value: (r) => r.status.label,
          ),
          ExportColumn(
            id: 'staff',
            label: 'Staff',
            value: (r) => r.staffLabel,
            width: 1.2,
          ),
          if (departmentsEnabled)
            ExportColumn(
              id: 'department',
              label: 'Department',
              value: (r) => r.departmentLabel,
              width: 1.2,
            ),
          ExportColumn(
            id: 'date',
            label: 'Date',
            format: ExportFormat.date,
            value: (r) => r.createdAt,
          ),
          ExportColumn(
            id: 'time',
            label: 'Time',
            format: ExportFormat.time,
            value: (r) => r.createdAt,
          ),
        ],
        totalsFor: (rs) {
          double qty = 0;
          double total = 0;
          for (final r in rs) {
            qty += r.quantity;
            total += r.lineTotal;
          }
          return {
            'item': '${f.integer(rs.length)} lines',
            'quantity': qty,
            'total': total,
          };
        },
        roll: const RollLayout(
          cols58: ['item', 'total'],
          cols80: ['item', 'quantity', 'total'],
          flex58: [2, 1],
          flex80: [3, 1, 2],
        ),
        emptyMessage: 'No purchase item records match the current filters.',
      ),
    ],
  );
}
