import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_production_folder/temp_productions/production_record.dart';
import 'package:stockall/classes/temp_production_folder/temp_productions/production_record_materials.dart';
import 'package:stockall/pages/report/components/report_pager.dart';
import 'package:stockall/pages/report/production_report/shared/class/production_report_access.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

/// Page size, same as the other report tables.
const int productionRecordsPageSize = 100;

/// Filter key for the "unassigned" bucket (no staff, no department,
/// no materials, no output item).
const String productionReportNoneKey = '__none__';

const String productionNoStaffLabel = 'No staff';
const String productionNoDepartmentLabel = 'No Department';
const String productionNoMaterialsLabel = 'No materials';
const String productionNoOutputLabel = 'No output item';

/// One material of a record, with its quantity in the material's
/// primary unit and its saved cost.
class ProductionRecordLine {
  final String? key;
  final String name;
  final double quantity;
  final String unit;
  final double cost;

  /// The quantity in the material's base units, as saved, for
  /// converting to the material's current unit.
  final double baseQuantity;

  const ProductionRecordLine({
    required this.key,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.cost,
    this.baseQuantity = 0,
  });
}

/// One table row: one production run. Every value is calculated once,
/// when the row is built. `null` means not applicable (shown as "—").
class ProductionRecordRow {
  final ProductionRecord record;
  final String displayId;

  /// `createdAt` in local time.
  final DateTime createdAt;

  final ProductionOutputType outputType;
  final String? outputKey;
  final String outputName;

  /// Quantity and unit as recorded ("3 Box").
  final double quantity;
  final String unitLabel;

  /// Quantity in the output's primary unit ("36 Pcs").
  final double primaryQty;
  final String primaryUnit;

  final List<ProductionRecordLine> lines;

  final double materialCost;
  final double recordedCost;
  final double variance;
  final ProductionCostSource costSource;

  /// Recorded cost of one primary unit; null when nothing was made.
  final double? costPerUnit;

  ProductionRecordRow({
    required this.record,
    required this.displayId,
    required this.createdAt,
    required this.outputType,
    required this.outputKey,
    required this.outputName,
    required this.quantity,
    required this.unitLabel,
    required this.primaryQty,
    required this.primaryUnit,
    required this.lines,
    required this.materialCost,
    required this.recordedCost,
    required this.variance,
    required this.costSource,
    required this.costPerUnit,
  });

  String get uuid => record.uuid ?? '';

  String? get staffKey => keyOf(record.staffId);
  String? get departmentKey => keyOf(record.departmentId);
  String? get staffName => nameOf(record.staffName);
  String? get departmentName => nameOf(record.departmentName);
  String? get comment => nameOf(record.comment);

  String get staffLabel => staffName ?? 'Not Set';
  String get departmentLabel =>
      departmentKey == null
          ? productionNoDepartmentLabel
          : departmentName ?? productionNoDepartmentLabel;

  /// Distinct material keys of the lines (null keys left out).
  Set<String> get materialKeys => {
    for (final l in lines)
      if (l.key != null) l.key!,
  };

  List<String> get materialNames => [
    for (final l in lines) l.name,
  ];

  /// "Flour, Sugar", or "No materials".
  String get materialsLabel =>
      lines.isEmpty
          ? productionNoMaterialsLabel
          : materialNames.toSet().join(', ');

  /// The key rule of [staffKey] etc.
  static String? keyOf(String? value) =>
      (value == null || value.trim().isEmpty) ? null : value;

  static String? nameOf(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

/// Builds [ProductionRecordRow]s. No record is modified.
class ProductionRecordRowBuilder {
  /// `#` and the first 12 digits of the uuid. A short uuid, or one
  /// with fewer digits, is shown as it is, so ids stay distinct.
  static String displayId(ProductionRecord record) {
    final uuid = record.uuid ?? '';
    final digits = uuid.replaceAll(RegExp(r'[^0-9]'), '');
    if (uuid.length < 13 || digits.length < 12) return '#$uuid';
    return '#${digits.substring(0, 12)}';
  }

  static ProductionRecordLine line(ProductionRecordMaterials m) {
    return ProductionRecordLine(
      key: ProductionRecordRow.keyOf(m.materialUuid),
      name: ProductionRecordRow.nameOf(m.materialName) ?? 'Not Set',
      quantity: ProductionReportUnits.materialLinePrimaryQty(m),
      unit: ProductionReportUnits.primaryUnitName(m.unitsList, unit: m.unit),
      cost: m.getTotalCost(),
      baseQuantity: m.getActualQuantity(),
    );
  }

  static ProductionRecordRow build({
    required ProductionRecord record,
    required bool manageProductionItems,
  }) {
    final type = ProductionReportCosts.outputType(
      record,
      manageProductionItems: manageProductionItems,
    );
    final outputKey = ProductionRecordRow.keyOf(
      type == ProductionOutputType.producedItem
          ? record.itemUuid
          : record.salesItemUuid,
    );
    return ProductionRecordRow(
      record: record,
      displayId: displayId(record),
      createdAt: (record.createdAt ?? DateTime(1970)).toLocal(),
      outputType: type,
      outputKey: outputKey,
      outputName:
          ProductionRecordRow.nameOf(record.itemName) ??
          (outputKey == null ? productionNoOutputLabel : 'Not Set'),
      quantity: record.quantity ?? 0,
      unitLabel: record.getUnit(),
      primaryQty: ProductionReportUnits.recordPrimaryQty(record),
      primaryUnit: ProductionReportUnits.primaryUnitName(
        record.unitsList,
        unit: record.unit,
      ),
      lines: [for (final m in record.materials) line(m)],
      materialCost: ProductionReportCosts.materialCost(record),
      recordedCost: ProductionReportCosts.recordedCost(record),
      variance: ProductionReportCosts.costVariance(record),
      costSource: ProductionReportCosts.costSource(record),
      costPerUnit: ProductionReportCosts.costPerUnitProduced(record),
    );
  }

  /// [pendingDeletedUuids]: records queued for deletion, left out
  /// even if still loaded.
  static List<ProductionRecordRow> buildAll({
    required List<ProductionRecord> records,
    required bool manageProductionItems,
    Set<String> pendingDeletedUuids = const {},
  }) {
    final rows = <ProductionRecordRow>[];
    for (final record in records) {
      if (pendingDeletedUuids.contains(record.uuid)) continue;
      if (record.createdAt == null) continue;
      try {
        rows.add(
          build(
            record: record,
            manageProductionItems: manageProductionItems,
          ),
        );
      } catch (_) {
        // A single malformed record must never break the report.
      }
    }
    return rows;
  }
}

/// All user-selectable filters, combined with AND. Keys are the row
/// keys or [productionReportNoneKey], so a summary row can open the
/// table with the same set.
class ProductionRecordsFilters {
  String search;
  String? outputKey;
  ProductionOutputType? outputType;
  String? materialKey;
  String? staffKey;
  String? departmentKey;
  ProductionCostSource? costSource;

  /// Quantity produced, in the output's primary unit.
  double? quantityMin;
  double? quantityMax;
  double? costMin;
  double? costMax;

  ProductionRecordsFilters({
    this.search = '',
    this.outputKey,
    this.outputType,
    this.materialKey,
    this.staffKey,
    this.departmentKey,
    this.costSource,
    this.quantityMin,
    this.quantityMax,
    this.costMin,
    this.costMax,
  });

  ProductionRecordsFilters copy() => ProductionRecordsFilters(
    search: search,
    outputKey: outputKey,
    outputType: outputType,
    materialKey: materialKey,
    staffKey: staffKey,
    departmentKey: departmentKey,
    costSource: costSource,
    quantityMin: quantityMin,
    quantityMax: quantityMax,
    costMin: costMin,
    costMax: costMax,
  );

  static String? rangeError(double? min, double? max) =>
      ReceiptsReportFilters.rangeError(min, max);

  String? get quantityRangeError => rangeError(quantityMin, quantityMax);
  String? get costRangeError => rangeError(costMin, costMax);

  bool get quantityRangeActive =>
      (quantityMin != null || quantityMax != null) &&
      quantityRangeError == null;
  bool get costRangeActive =>
      (costMin != null || costMax != null) && costRangeError == null;

  /// The one output item selected, or null (none or "No output").
  String? get singleOutputKey =>
      outputKey == null || outputKey == productionReportNoneKey
          ? null
          : outputKey;

  int get activeCount =>
      (outputKey != null ? 1 : 0) +
      (outputType != null ? 1 : 0) +
      (materialKey != null ? 1 : 0) +
      (staffKey != null ? 1 : 0) +
      (departmentKey != null ? 1 : 0) +
      (costSource != null ? 1 : 0) +
      (quantityMin != null || quantityMax != null ? 1 : 0) +
      (costMin != null || costMax != null ? 1 : 0);

  bool get hasAnything => activeCount > 0 || search.trim().isNotEmpty;

  void clearAll() {
    search = '';
    clearFiltersOnly();
  }

  void clearFiltersOnly() {
    outputKey = null;
    outputType = null;
    materialKey = null;
    staffKey = null;
    departmentKey = null;
    costSource = null;
    quantityMin = null;
    quantityMax = null;
    costMin = null;
    costMax = null;
  }

  /// Null [filterKey] matches all; [productionReportNoneKey] matches a
  /// null [rowKey].
  static bool keyMatches(String? filterKey, String? rowKey) {
    if (filterKey == null) return true;
    if (filterKey == productionReportNoneKey) return rowKey == null;
    return rowKey == filterKey;
  }

  bool matchesSearch(
    ProductionRecordRow r, {
    required bool departmentsEnabled,
  }) {
    final q = search.trim().toLowerCase();
    if (q.isEmpty) return true;
    bool has(String? s) => s != null && s.toLowerCase().contains(q);
    return has(r.outputName) ||
        has(r.staffName) ||
        (departmentsEnabled && has(r.departmentName)) ||
        has(r.displayId) ||
        r.materialNames.any(has) ||
        has(r.comment);
  }

  /// [departmentsEnabled] switches off the department search and
  /// filter. The cost filters need [canSeeCost] and the quantity range
  /// [canSeeQuantity]; they are hidden in the UI otherwise.
  bool matches(
    ProductionRecordRow r, {
    required bool departmentsEnabled,
    required bool canSeeCost,
    required bool canSeeQuantity,
  }) {
    if (!matchesSearch(r, departmentsEnabled: departmentsEnabled)) {
      return false;
    }
    if (!keyMatches(outputKey, r.outputKey)) return false;
    if (outputType != null && r.outputType != outputType) return false;
    if (materialKey != null) {
      if (materialKey == productionReportNoneKey) {
        if (r.lines.isNotEmpty) return false;
      } else if (!r.materialKeys.contains(materialKey)) {
        return false;
      }
    }
    if (!keyMatches(staffKey, r.staffKey)) return false;
    if (departmentsEnabled && !keyMatches(departmentKey, r.departmentKey)) {
      return false;
    }
    if (canSeeCost) {
      if (costSource != null && r.costSource != costSource) return false;
      if (costRangeActive &&
          !ReceiptsReportFilters.inRange(r.recordedCost, costMin, costMax)) {
        return false;
      }
    }
    if (canSeeQuantity &&
        quantityRangeActive &&
        !ReceiptsReportFilters.inRange(
          r.primaryQty,
          quantityMin,
          quantityMax,
        )) {
      return false;
    }
    return true;
  }
}

/// One choice in a key filter.
class ProductionFilterOption {
  final String key;
  final String label;

  const ProductionFilterOption(this.key, this.label);
}

/// Filter choices taken from the records themselves, so items and
/// staff deleted since can still be selected. Each key shows its most
/// recent name.
class ProductionRecordsOptions {
  static List<ProductionFilterOption> _build(
    List<ProductionRecordRow> rows, {
    required Iterable<(String?, String?)> Function(ProductionRecordRow)
    entries,
    required String fallbackName,
    required String noneLabel,
  }) {
    final newestFirst = List<ProductionRecordRow>.from(rows)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final labels = <String, String>{};
    var hasNone = false;
    for (final r in newestFirst) {
      final list = entries(r).toList();
      if (list.isEmpty) hasNone = true;
      for (final (k, name) in list) {
        if (k == null) {
          hasNone = true;
          continue;
        }
        labels.putIfAbsent(k, () => name ?? fallbackName);
      }
    }
    final options =
        labels.entries
            .map((e) => ProductionFilterOption(e.key, e.value))
            .toList()
          ..sort((a, b) {
            final c = a.label.toLowerCase().compareTo(b.label.toLowerCase());
            return c != 0 ? c : a.key.compareTo(b.key);
          });
    if (hasNone) {
      options.add(ProductionFilterOption(productionReportNoneKey, noneLabel));
    }
    return options;
  }

  static List<ProductionFilterOption> outputs(
    List<ProductionRecordRow> rows,
  ) => _build(
    rows,
    entries: (r) => [(r.outputKey, r.outputName)],
    fallbackName: 'Not Set',
    noneLabel: productionNoOutputLabel,
  );

  static List<ProductionFilterOption> materials(
    List<ProductionRecordRow> rows,
  ) => _build(
    rows,
    entries: (r) => [for (final l in r.lines) (l.key, l.name)],
    fallbackName: 'Not Set',
    noneLabel: productionNoMaterialsLabel,
  );

  static List<ProductionFilterOption> staff(
    List<ProductionRecordRow> rows,
  ) => _build(
    rows,
    entries: (r) => [(r.staffKey, r.staffName)],
    fallbackName: 'Not Set',
    noneLabel: productionNoStaffLabel,
  );

  static List<ProductionFilterOption> departments(
    List<ProductionRecordRow> rows,
  ) => _build(
    rows,
    entries: (r) => [(r.departmentKey, r.departmentName)],
    fallbackName: productionNoDepartmentLabel,
    noneLabel: productionNoDepartmentLabel,
  );
}

enum ProductionRecordsSortField {
  createdAt,
  output,
  staff,
  quantity,
  materialCost,
  recordedCost,
  variance,
  costPerUnit,
}

/// Result of [ProductionRecordsQuery.paginate].
class ProductionRecordsPage {
  final List<ProductionRecordRow> rows;
  final int totalCount;
  final int page; // 1-based, already clamped
  final int totalPages;

  /// Totals of every filtered row, not just this page.
  final double totalMaterialCost;
  final double totalRecordedCost;
  final double totalVariance;

  /// Only when one output item is selected: its quantity in its
  /// primary unit, and the recorded cost of one unit.
  final double? totalQuantity;
  final String? quantityUnit;
  final double? totalCostPerUnit;

  const ProductionRecordsPage({
    required this.rows,
    required this.totalCount,
    required this.page,
    required this.totalPages,
    this.totalMaterialCost = 0,
    this.totalRecordedCost = 0,
    this.totalVariance = 0,
    this.totalQuantity,
    this.quantityUnit,
    this.totalCostPerUnit,
  });

  int get firstIndex =>
      totalCount == 0 ? 0 : (page - 1) * productionRecordsPageSize + 1;
  int get lastIndex => firstIndex == 0 ? 0 : firstIndex + rows.length - 1;
}

class ProductionRecordsQuery {
  static int cmp<T extends Comparable>(T? a, T? b, bool asc) {
    // Null values always sink to the bottom, in both directions.
    if (a == null && b == null) return 0;
    if (a == null) return 1;
    if (b == null) return -1;
    final c = a.compareTo(b);
    return asc ? c : -c;
  }

  /// Rows in [period], then search and filters, then sorted. The whole
  /// set is sorted before pagination.
  static List<ProductionRecordRow> filterAndSort({
    required List<ProductionRecordRow> rows,
    required ReceiptsReportPeriod period,
    required ProductionRecordsFilters filters,
    required ProductionRecordsSortField sortField,
    required bool ascending,
    required bool departmentsEnabled,
    required bool canSeeCost,
    required bool canSeeQuantity,
    TimeOfDay? closingTime,
  }) {
    final out =
        rows
            .where(
              (r) =>
                  period.contains(r.createdAt, closingTime: closingTime) &&
                  filters.matches(
                    r,
                    departmentsEnabled: departmentsEnabled,
                    canSeeCost: canSeeCost,
                    canSeeQuantity: canSeeQuantity,
                  ),
            )
            .toList();

    int compare(ProductionRecordRow a, ProductionRecordRow b) {
      int c;
      switch (sortField) {
        case ProductionRecordsSortField.createdAt:
          c = cmp(a.createdAt, b.createdAt, ascending);
          break;
        case ProductionRecordsSortField.output:
          c = cmp(
            a.outputName.toLowerCase(),
            b.outputName.toLowerCase(),
            ascending,
          );
          break;
        case ProductionRecordsSortField.staff:
          c = cmp(
            a.staffName?.toLowerCase(),
            b.staffName?.toLowerCase(),
            ascending,
          );
          break;
        case ProductionRecordsSortField.quantity:
          c = cmp(a.primaryQty, b.primaryQty, ascending);
          break;
        case ProductionRecordsSortField.materialCost:
          c = cmp(a.materialCost, b.materialCost, ascending);
          break;
        case ProductionRecordsSortField.recordedCost:
          c = cmp(a.recordedCost, b.recordedCost, ascending);
          break;
        case ProductionRecordsSortField.variance:
          c = cmp(a.variance, b.variance, ascending);
          break;
        case ProductionRecordsSortField.costPerUnit:
          c = cmp(a.costPerUnit, b.costPerUnit, ascending);
          break;
      }
      if (c != 0) return c;
      // Deterministic tie-breakers keep pagination stable.
      final t = b.createdAt.compareTo(a.createdAt);
      return t != 0 ? t : a.uuid.compareTo(b.uuid);
    }

    out.sort(compare);
    return out;
  }

  /// [singleOutputKey]: the output item the filters select, if any;
  /// only then is the quantity totalled.
  static ProductionRecordsPage paginate(
    List<ProductionRecordRow> sorted,
    int requestedPage, {
    String? singleOutputKey,
  }) {
    final b = reportPageBounds(
      sorted.length,
      requestedPage,
      pageSize: productionRecordsPageSize,
    );

    double materialCost = 0;
    double recordedCost = 0;
    double variance = 0;
    double quantity = 0;
    for (final r in sorted) {
      materialCost += r.materialCost;
      recordedCost += r.recordedCost;
      variance += r.variance;
      quantity += r.primaryQty;
    }
    final single = singleOutputKey != null;

    return ProductionRecordsPage(
      rows: sorted.isEmpty ? const [] : sorted.sublist(b.start, b.end),
      totalCount: sorted.length,
      page: b.page,
      totalPages: b.pages,
      totalMaterialCost: materialCost,
      totalRecordedCost: recordedCost,
      totalVariance: variance,
      totalQuantity: single ? quantity : null,
      quantityUnit: single && sorted.isNotEmpty ? sorted.first.primaryUnit : null,
      totalCostPerUnit:
          single && quantity > 0 ? recordedCost / quantity : null,
    );
  }
}

/// "Group by" of the table. A view option, not a filter: Reset All
/// keeps it.
enum ProductionGroupBy { off, outputItem, staff, department, material }

extension ProductionGroupByLabel on ProductionGroupBy {
  String get label {
    switch (this) {
      case ProductionGroupBy.off:
        return 'Off';
      case ProductionGroupBy.outputItem:
        return 'Output Item';
      case ProductionGroupBy.staff:
        return 'Staff';
      case ProductionGroupBy.department:
        return 'Department';
      case ProductionGroupBy.material:
        return 'Material';
    }
  }

  /// Pager label for the grouped rows.
  String get pagerLabel {
    switch (this) {
      case ProductionGroupBy.outputItem:
        return 'items';
      case ProductionGroupBy.staff:
        return 'staff';
      case ProductionGroupBy.department:
        return 'departments';
      case ProductionGroupBy.material:
        return 'materials';
      case ProductionGroupBy.off:
        return 'records';
    }
  }

  String get noneLabel {
    switch (this) {
      case ProductionGroupBy.outputItem:
        return productionNoOutputLabel;
      case ProductionGroupBy.staff:
        return productionNoStaffLabel;
      case ProductionGroupBy.department:
        return productionNoDepartmentLabel;
      case ProductionGroupBy.material:
        return productionNoMaterialsLabel;
      case ProductionGroupBy.off:
        return '';
    }
  }
}

enum ProductionGroupSortField {
  name,
  count,
  quantity,
  materialCost,
  recordedCost,
  variance,
  costPerUnit,
}

/// One table row when grouped.
///
/// - Output item: its records, quantity (primary unit), costs and the
///   cost of one unit.
/// - Staff / Department: records and costs.
/// - Material: the records using it, the quantity used (its primary
///   unit) and that material's cost only. A record using two materials
///   counts in both groups.
class ProductionGroupRow {
  final ProductionGroupBy by;
  final String key;

  /// The none row, always last.
  final bool isNone;

  /// Most recent name in the group. Null when none was saved.
  String? name;

  int count = 0;

  /// Output item: quantity produced. Material: quantity used.
  double? quantity;
  String? unit;

  double materialCost = 0;

  /// Null for material groups: a record's cost isn't split by material.
  double? recordedCost;
  double? variance;

  ProductionGroupRow({
    required this.by,
    required this.key,
    required this.isNone,
    required this.name,
  }) {
    if (by != ProductionGroupBy.material) {
      recordedCost = 0;
      variance = 0;
    }
  }

  String get label => isNone ? by.noneLabel : (name ?? 'Not Set');

  /// Output item groups: recorded cost of one unit produced.
  double? get costPerUnit {
    if (by != ProductionGroupBy.outputItem || isNone) return null;
    final q = quantity;
    if (q == null || q <= 0 || recordedCost == null) return null;
    return recordedCost! / q;
  }
}

/// Result of [ProductionGrouping.paginate]. Totals cover every group,
/// not just this page.
class ProductionGroupPage {
  final List<ProductionGroupRow> rows;
  final int totalCount;
  final int page;
  final int totalPages;

  /// Distinct records (a record in two material groups counts once).
  final int totalRecords;
  final double totalMaterialCost;

  /// Null when grouped by material.
  final double? totalRecordedCost;
  final double? totalVariance;

  const ProductionGroupPage({
    required this.rows,
    required this.totalCount,
    required this.page,
    required this.totalPages,
    this.totalRecords = 0,
    this.totalMaterialCost = 0,
    this.totalRecordedCost,
    this.totalVariance,
  });

  int get firstIndex =>
      totalCount == 0 ? 0 : (page - 1) * productionRecordsPageSize + 1;
  int get lastIndex => firstIndex == 0 ? 0 : firstIndex + rows.length - 1;
}

class ProductionGrouping {
  /// Groups [rows] that already passed the period and filters. Each
  /// group shows its most recent name.
  static List<ProductionGroupRow> build(
    List<ProductionRecordRow> rows,
    ProductionGroupBy by,
  ) {
    if (by == ProductionGroupBy.off) return [];
    final newestFirst = List<ProductionRecordRow>.from(rows)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final groups = <String, ProductionGroupRow>{};

    ProductionGroupRow group(String? key, String? name) {
      final g = groups.putIfAbsent(
        key ?? productionReportNoneKey,
        () => ProductionGroupRow(
          by: by,
          key: key ?? productionReportNoneKey,
          isNone: key == null,
          name: name,
        ),
      );
      // Newest first, so only fill a name the newer ones lacked.
      g.name ??= name;
      return g;
    }

    for (final r in newestFirst) {
      switch (by) {
        case ProductionGroupBy.material:
          if (r.lines.isEmpty) {
            group(null, null).count++;
            continue;
          }
          final byKey = <String?, List<ProductionRecordLine>>{};
          for (final l in r.lines) {
            byKey.putIfAbsent(l.key, () => []).add(l);
          }
          for (final entry in byKey.entries) {
            final g = group(entry.key, entry.value.first.name);
            g.count++;
            g.unit ??= entry.value.first.unit;
            for (final l in entry.value) {
              g.quantity = (g.quantity ?? 0) + l.quantity;
              g.materialCost += l.cost;
            }
          }
          break;
        case ProductionGroupBy.outputItem:
        case ProductionGroupBy.staff:
        case ProductionGroupBy.department:
          final String? key;
          final String? name;
          if (by == ProductionGroupBy.outputItem) {
            key = r.outputKey;
            name = r.outputName;
          } else if (by == ProductionGroupBy.staff) {
            key = r.staffKey;
            name = r.staffName;
          } else {
            key = r.departmentKey;
            name = r.departmentName;
          }
          final g = group(key, name);
          g.count++;
          g.materialCost += r.materialCost;
          g.recordedCost = (g.recordedCost ?? 0) + r.recordedCost;
          g.variance = (g.variance ?? 0) + r.variance;
          if (by == ProductionGroupBy.outputItem) {
            g.quantity = (g.quantity ?? 0) + r.primaryQty;
            g.unit ??= r.primaryUnit;
          }
          break;
        case ProductionGroupBy.off:
          break;
      }
    }
    return groups.values.toList();
  }

  /// Sorted copy. The none row is always last; nulls sink to the
  /// bottom; ties: label, then key.
  static List<ProductionGroupRow> sort(
    List<ProductionGroupRow> groups, {
    required ProductionGroupSortField field,
    required bool ascending,
  }) {
    final cmp = ProductionRecordsQuery.cmp;
    int compare(ProductionGroupRow a, ProductionGroupRow b) {
      if (a.isNone != b.isNone) return a.isNone ? 1 : -1;
      int c;
      switch (field) {
        case ProductionGroupSortField.name:
          c = cmp(a.label.toLowerCase(), b.label.toLowerCase(), ascending);
          break;
        case ProductionGroupSortField.count:
          c = cmp(a.count, b.count, ascending);
          break;
        case ProductionGroupSortField.quantity:
          c = cmp(a.quantity, b.quantity, ascending);
          break;
        case ProductionGroupSortField.materialCost:
          c = cmp(a.materialCost, b.materialCost, ascending);
          break;
        case ProductionGroupSortField.recordedCost:
          c = cmp(a.recordedCost, b.recordedCost, ascending);
          break;
        case ProductionGroupSortField.variance:
          c = cmp(a.variance, b.variance, ascending);
          break;
        case ProductionGroupSortField.costPerUnit:
          c = cmp(a.costPerUnit, b.costPerUnit, ascending);
          break;
      }
      if (c != 0) return c;
      final n = a.label.toLowerCase().compareTo(b.label.toLowerCase());
      return n != 0 ? n : a.key.compareTo(b.key);
    }

    return List<ProductionGroupRow>.from(groups)..sort(compare);
  }

  /// [recordCount]: the filtered records the groups were built from.
  static ProductionGroupPage paginate(
    List<ProductionGroupRow> sorted,
    int requestedPage, {
    required int recordCount,
  }) {
    final b = reportPageBounds(
      sorted.length,
      requestedPage,
      pageSize: productionRecordsPageSize,
    );
    double materialCost = 0;
    double? recordedCost;
    double? variance;
    for (final g in sorted) {
      materialCost += g.materialCost;
      if (g.recordedCost != null) {
        recordedCost = (recordedCost ?? 0) + g.recordedCost!;
      }
      if (g.variance != null) variance = (variance ?? 0) + g.variance!;
    }
    return ProductionGroupPage(
      rows: sorted.isEmpty ? const [] : sorted.sublist(b.start, b.end),
      totalCount: sorted.length,
      page: b.page,
      totalPages: b.pages,
      totalRecords: recordCount,
      totalMaterialCost: materialCost,
      totalRecordedCost: recordedCost,
      totalVariance: variance,
    );
  }
}

/// Filters, grouping, sorts and page of the table.
class ProductionRecordsTableState {
  final ProductionRecordsFilters filters;
  ProductionGroupBy groupBy;
  ProductionRecordsSortField sortField;
  bool ascending;
  ProductionGroupSortField groupSortField;
  bool groupAscending;
  int page;

  ProductionRecordsTableState({
    ProductionRecordsFilters? filters,
    this.groupBy = ProductionGroupBy.off,
    this.sortField = ProductionRecordsSortField.createdAt,
    this.ascending = false,
    this.groupSortField = ProductionGroupSortField.count,
    this.groupAscending = false,
    this.page = 1,
  }) : filters = filters ?? ProductionRecordsFilters();

  bool get grouped => groupBy != ProductionGroupBy.off;

  /// Reset All: clears the search and every filter. Grouping and
  /// sorting are view options and stay.
  void resetAll() {
    filters.clearAll();
    page = 1;
  }
}

/// The notes the table and the summary show under their toolbar. The
/// views draw these and the export carries them, so they always match.
/// [rows] are the records in the period.
List<String> productionRecordsNotes({
  required ReceiptsReportPeriod period,
  required List<ProductionRecordRow> rows,
  required bool canSeeCost,
}) {
  final custom =
      rows.where((r) => r.costSource == ProductionCostSource.custom).length;
  return [
    if (period.isAllTime)
      'All time covers the production records loaded on this device.',
    if (canSeeCost && custom > 0)
      '$custom ${custom == 1 ? 'record uses' : 'records use'} a custom '
          'cost; Variance shows the difference from the materials.',
  ];
}
