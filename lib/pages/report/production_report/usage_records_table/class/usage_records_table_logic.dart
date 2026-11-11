import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_materials_usage/production_materials_usage.dart';
import 'package:stockall/pages/report/components/report_pager.dart';
import 'package:stockall/pages/report/production_report/production_records_table/class/production_records_table_logic.dart';
import 'package:stockall/pages/report/production_report/shared/class/production_report_access.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

/// Page size, same as the other report tables.
const int usageRecordsPageSize = 100;

/// Where a usage record came from: a production run (it has a
/// `productionRecordUuid`) or a manual usage entry.
enum UsageSource { production, manual }

extension UsageSourceLabel on UsageSource {
  String get label =>
      this == UsageSource.production ? 'Production' : 'Manual';

  /// Key of the source split and the source group.
  String get key => name;
}

/// One table row: one usage record (one material). Every value is
/// calculated once, when the row is built. `null` means not applicable
/// (shown as "—").
class UsageRecordRow {
  final ProductionMaterialsUsage usage;
  final String displayId;

  /// `createdAt` in local time.
  final DateTime createdAt;

  final String materialKey;
  final String materialName;

  /// Quantity and unit as recorded ("1 Bag").
  final double quantity;
  final String unitLabel;

  /// Quantity in the material's primary unit.
  final double primaryQty;
  final String primaryUnit;

  /// `getTotalCost()`, as on the usage details.
  final double cost;

  /// Cost of one primary unit when the usage was saved. Null when no
  /// unit cost was saved.
  final double? unitCost;

  final UsageSource source;

  /// The production's display id and output, when the usage came from
  /// a production that is loaded. Null otherwise.
  final String? productionId;
  final String? productionOutputName;

  /// True when the usage reduced the material's stock. A usage saved
  /// without the flag counts as not managed, as the stock update does.
  final bool managed;

  UsageRecordRow({
    required this.usage,
    required this.displayId,
    required this.createdAt,
    required this.materialKey,
    required this.materialName,
    required this.quantity,
    required this.unitLabel,
    required this.primaryQty,
    required this.primaryUnit,
    required this.cost,
    required this.unitCost,
    required this.source,
    required this.productionId,
    required this.productionOutputName,
    required this.managed,
  });

  String get uuid => usage.uuid;

  String? get productionRecordUuid =>
      ProductionRecordRow.keyOf(usage.productionRecordUuid);

  String? get staffKey => ProductionRecordRow.keyOf(usage.staffUuid);
  String? get departmentKey => ProductionRecordRow.keyOf(usage.departmentUuid);
  String? get staffName => ProductionRecordRow.nameOf(usage.staffName);
  String? get departmentName =>
      ProductionRecordRow.nameOf(usage.departmentName);

  String get staffLabel => staffName ?? 'Not Set';
  String get departmentLabel =>
      departmentKey == null
          ? productionNoDepartmentLabel
          : departmentName ?? productionNoDepartmentLabel;

  String get managedLabel => managed ? 'Yes' : 'No';

  /// "Donut #123456789012", the output only, or "Not loaded" for a
  /// production usage whose record isn't on this device. Null for a
  /// manual usage.
  String? get productionLabel {
    if (source == UsageSource.manual) return null;
    if (productionOutputName == null) return 'Not loaded';
    return '$productionOutputName ${productionId ?? ''}'.trim();
  }
}

/// Builds [UsageRecordRow]s. No record is modified.
class UsageRecordRowBuilder {
  /// Same rule as the production records: `#` and the first 12 digits
  /// of the uuid, else `#uuid`.
  static String displayId(String uuid) {
    final digits = uuid.replaceAll(RegExp(r'[^0-9]'), '');
    if (uuid.length < 13 || digits.length < 12) return '#$uuid';
    return '#${digits.substring(0, 12)}';
  }

  static UsageRecordRow build({
    required ProductionMaterialsUsage usage,
    Map<String, ProductionRecordRow> recordsByUuid = const {},
  }) {
    final source =
        ProductionReportCosts.isProductionUsage(usage)
            ? UsageSource.production
            : UsageSource.manual;
    final record =
        source == UsageSource.production
            ? recordsByUuid[usage.productionRecordUuid!.trim()]
            : null;
    final unitCostBase = ProductionReportCosts.usageUnitCost(usage);
    return UsageRecordRow(
      usage: usage,
      displayId: displayId(usage.uuid),
      createdAt: (usage.createdAt ?? DateTime(1970)).toLocal(),
      materialKey: usage.materialUuid,
      materialName: ProductionRecordRow.nameOf(usage.materialName) ?? 'Not Set',
      quantity: usage.quantity,
      unitLabel: usage.getUnit(),
      primaryQty: ProductionReportUnits.usagePrimaryQty(usage),
      primaryUnit: ProductionReportUnits.primaryUnitName(
        usage.unitsList,
        unit: usage.unit,
      ),
      cost: ProductionReportCosts.usageCost(usage),
      unitCost:
          unitCostBase == null
              ? null
              : ProductionReportUnits.primaryCostPrice(
                unitCostBase,
                usage.unitsList,
              ),
      source: source,
      productionId: record?.displayId,
      productionOutputName: record?.outputName,
      managed: usage.isManaged == true,
    );
  }

  /// [recordRows]: the loaded production records, for the output name
  /// of production usages. [pendingDeletedUuids]: usages queued for
  /// deletion, left out even if still loaded.
  static List<UsageRecordRow> buildAll({
    required List<ProductionMaterialsUsage> usages,
    List<ProductionRecordRow> recordRows = const [],
    Set<String> pendingDeletedUuids = const {},
  }) {
    final byUuid = {for (final r in recordRows) r.uuid: r};
    final rows = <UsageRecordRow>[];
    for (final usage in usages) {
      if (pendingDeletedUuids.contains(usage.uuid)) continue;
      if (usage.createdAt == null) continue;
      try {
        rows.add(build(usage: usage, recordsByUuid: byUuid));
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
class UsageRecordsFilters {
  String search;

  /// A usage always has a material, so there is no none choice here.
  String? materialKey;
  UsageSource? source;
  String? staffKey;
  String? departmentKey;
  bool? managed;

  /// Quantity used, in the material's primary unit.
  double? quantityMin;
  double? quantityMax;
  double? costMin;
  double? costMax;

  UsageRecordsFilters({
    this.search = '',
    this.materialKey,
    this.source,
    this.staffKey,
    this.departmentKey,
    this.managed,
    this.quantityMin,
    this.quantityMax,
    this.costMin,
    this.costMax,
  });

  UsageRecordsFilters copy() => UsageRecordsFilters(
    search: search,
    materialKey: materialKey,
    source: source,
    staffKey: staffKey,
    departmentKey: departmentKey,
    managed: managed,
    quantityMin: quantityMin,
    quantityMax: quantityMax,
    costMin: costMin,
    costMax: costMax,
  );

  String? get quantityRangeError =>
      ReceiptsReportFilters.rangeError(quantityMin, quantityMax);
  String? get costRangeError =>
      ReceiptsReportFilters.rangeError(costMin, costMax);

  bool get quantityRangeActive =>
      (quantityMin != null || quantityMax != null) &&
      quantityRangeError == null;
  bool get costRangeActive =>
      (costMin != null || costMax != null) && costRangeError == null;

  /// The one material selected, or null.
  String? get singleMaterialKey => materialKey;

  int get activeCount =>
      (materialKey != null ? 1 : 0) +
      (source != null ? 1 : 0) +
      (staffKey != null ? 1 : 0) +
      (departmentKey != null ? 1 : 0) +
      (managed != null ? 1 : 0) +
      (quantityMin != null || quantityMax != null ? 1 : 0) +
      (costMin != null || costMax != null ? 1 : 0);

  bool get hasAnything => activeCount > 0 || search.trim().isNotEmpty;

  void clearAll() {
    search = '';
    clearFiltersOnly();
  }

  void clearFiltersOnly() {
    materialKey = null;
    source = null;
    staffKey = null;
    departmentKey = null;
    managed = null;
    quantityMin = null;
    quantityMax = null;
    costMin = null;
    costMax = null;
  }

  bool matchesSearch(UsageRecordRow r, {required bool departmentsEnabled}) {
    final q = search.trim().toLowerCase();
    if (q.isEmpty) return true;
    bool has(String? s) => s != null && s.toLowerCase().contains(q);
    return has(r.materialName) ||
        has(r.staffName) ||
        (departmentsEnabled && has(r.departmentName)) ||
        has(r.displayId) ||
        has(r.productionOutputName) ||
        has(r.productionId);
  }

  /// [departmentsEnabled] switches off the department search and
  /// filter. The cost range needs [canSeeCost] and the quantity range
  /// [canSeeQuantity]; they are hidden in the UI otherwise.
  bool matches(
    UsageRecordRow r, {
    required bool departmentsEnabled,
    required bool canSeeCost,
    required bool canSeeQuantity,
  }) {
    if (!matchesSearch(r, departmentsEnabled: departmentsEnabled)) {
      return false;
    }
    if (materialKey != null && r.materialKey != materialKey) return false;
    if (source != null && r.source != source) return false;
    if (!ProductionRecordsFilters.keyMatches(staffKey, r.staffKey)) {
      return false;
    }
    if (departmentsEnabled &&
        !ProductionRecordsFilters.keyMatches(departmentKey, r.departmentKey)) {
      return false;
    }
    if (managed != null && r.managed != managed) return false;
    if (canSeeCost &&
        costRangeActive &&
        !ReceiptsReportFilters.inRange(r.cost, costMin, costMax)) {
      return false;
    }
    if (canSeeQuantity &&
        quantityRangeActive &&
        !ReceiptsReportFilters.inRange(r.primaryQty, quantityMin, quantityMax)) {
      return false;
    }
    return true;
  }
}

/// Filter choices taken from the records themselves, so materials and
/// staff deleted since can still be selected. Each key shows its most
/// recent name.
class UsageRecordsOptions {
  static List<ProductionFilterOption> _build(
    List<UsageRecordRow> rows, {
    required (String?, String?) Function(UsageRecordRow) entry,
    required String fallbackName,
    required String noneLabel,
  }) {
    final newestFirst = List<UsageRecordRow>.from(rows)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final labels = <String, String>{};
    var hasNone = false;
    for (final r in newestFirst) {
      final (k, name) = entry(r);
      if (k == null) {
        hasNone = true;
        continue;
      }
      labels.putIfAbsent(k, () => name ?? fallbackName);
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

  static List<ProductionFilterOption> materials(List<UsageRecordRow> rows) =>
      _build(
        rows,
        entry: (r) => (r.materialKey, r.materialName),
        fallbackName: 'Not Set',
        noneLabel: '',
      );

  static List<ProductionFilterOption> staff(List<UsageRecordRow> rows) =>
      _build(
        rows,
        entry: (r) => (r.staffKey, r.staffName),
        fallbackName: 'Not Set',
        noneLabel: productionNoStaffLabel,
      );

  static List<ProductionFilterOption> departments(List<UsageRecordRow> rows) =>
      _build(
        rows,
        entry: (r) => (r.departmentKey, r.departmentName),
        fallbackName: productionNoDepartmentLabel,
        noneLabel: productionNoDepartmentLabel,
      );
}

enum UsageRecordsSortField {
  createdAt,
  material,
  quantity,
  unitCost,
  cost,
  source,
  staff,
}

/// Result of [UsageRecordsQuery.paginate].
class UsageRecordsPage {
  final List<UsageRecordRow> rows;
  final int totalCount;
  final int page; // 1-based, already clamped
  final int totalPages;

  /// Total of every filtered row, not just this page.
  final double totalCost;

  /// Only when one material is selected: its quantity in its primary
  /// unit, and the cost of one unit.
  final double? totalQuantity;
  final String? quantityUnit;
  final double? averageUnitCost;

  const UsageRecordsPage({
    required this.rows,
    required this.totalCount,
    required this.page,
    required this.totalPages,
    this.totalCost = 0,
    this.totalQuantity,
    this.quantityUnit,
    this.averageUnitCost,
  });

  int get firstIndex =>
      totalCount == 0 ? 0 : (page - 1) * usageRecordsPageSize + 1;
  int get lastIndex => firstIndex == 0 ? 0 : firstIndex + rows.length - 1;
}

class UsageRecordsQuery {
  /// Rows in [period], then search and filters, then sorted. The whole
  /// set is sorted before pagination.
  static List<UsageRecordRow> filterAndSort({
    required List<UsageRecordRow> rows,
    required ReceiptsReportPeriod period,
    required UsageRecordsFilters filters,
    required UsageRecordsSortField sortField,
    required bool ascending,
    required bool departmentsEnabled,
    required bool canSeeCost,
    required bool canSeeQuantity,
    TimeOfDay? closingTime,
  }) {
    final cmp = ProductionRecordsQuery.cmp;
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

    int compare(UsageRecordRow a, UsageRecordRow b) {
      int c;
      switch (sortField) {
        case UsageRecordsSortField.createdAt:
          c = cmp(a.createdAt, b.createdAt, ascending);
          break;
        case UsageRecordsSortField.material:
          c = cmp(
            a.materialName.toLowerCase(),
            b.materialName.toLowerCase(),
            ascending,
          );
          break;
        case UsageRecordsSortField.quantity:
          c = cmp(a.primaryQty, b.primaryQty, ascending);
          break;
        case UsageRecordsSortField.unitCost:
          c = cmp(a.unitCost, b.unitCost, ascending);
          break;
        case UsageRecordsSortField.cost:
          c = cmp(a.cost, b.cost, ascending);
          break;
        case UsageRecordsSortField.source:
          c = cmp(a.source.label, b.source.label, ascending);
          break;
        case UsageRecordsSortField.staff:
          c = cmp(
            a.staffName?.toLowerCase(),
            b.staffName?.toLowerCase(),
            ascending,
          );
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

  /// [singleMaterialKey]: the material the filters select, if any;
  /// only then is the quantity totalled.
  static UsageRecordsPage paginate(
    List<UsageRecordRow> sorted,
    int requestedPage, {
    String? singleMaterialKey,
  }) {
    final b = reportPageBounds(
      sorted.length,
      requestedPage,
      pageSize: usageRecordsPageSize,
    );
    double cost = 0;
    double quantity = 0;
    for (final r in sorted) {
      cost += r.cost;
      quantity += r.primaryQty;
    }
    final single = singleMaterialKey != null;
    return UsageRecordsPage(
      rows: sorted.isEmpty ? const [] : sorted.sublist(b.start, b.end),
      totalCount: sorted.length,
      page: b.page,
      totalPages: b.pages,
      totalCost: cost,
      totalQuantity: single ? quantity : null,
      quantityUnit: single && sorted.isNotEmpty ? sorted.first.primaryUnit : null,
      averageUnitCost: single && quantity > 0 ? cost / quantity : null,
    );
  }
}

/// "Group by" of the table. A view option, not a filter: Reset All
/// keeps it.
enum UsageGroupBy { off, material, source, staff, department }

extension UsageGroupByLabel on UsageGroupBy {
  String get label {
    switch (this) {
      case UsageGroupBy.off:
        return 'Off';
      case UsageGroupBy.material:
        return 'Material';
      case UsageGroupBy.source:
        return 'Source';
      case UsageGroupBy.staff:
        return 'Staff';
      case UsageGroupBy.department:
        return 'Department';
    }
  }

  /// Pager label for the grouped rows.
  String get pagerLabel {
    switch (this) {
      case UsageGroupBy.material:
        return 'materials';
      case UsageGroupBy.source:
        return 'sources';
      case UsageGroupBy.staff:
        return 'staff';
      case UsageGroupBy.department:
        return 'departments';
      case UsageGroupBy.off:
        return 'records';
    }
  }

  String get noneLabel {
    switch (this) {
      case UsageGroupBy.staff:
        return productionNoStaffLabel;
      case UsageGroupBy.department:
        return productionNoDepartmentLabel;
      case UsageGroupBy.material:
      case UsageGroupBy.source:
      case UsageGroupBy.off:
        return '';
    }
  }
}

enum UsageGroupSortField { name, count, quantity, cost, unitCost, lastDate }

/// One table row when grouped: its records, cost and last usage. A
/// material group also has the quantity (its primary unit) and the
/// average cost of one unit.
class UsageGroupRow {
  final UsageGroupBy by;
  final String key;

  /// The none row, always last.
  final bool isNone;

  /// Most recent name in the group. Null when none was saved.
  String? name;

  int count = 0;
  double cost = 0;
  DateTime? lastDate;

  /// Material groups only.
  double? quantity;
  String? unit;

  UsageGroupRow({
    required this.by,
    required this.key,
    required this.isNone,
    required this.name,
  });

  String get label => isNone ? by.noneLabel : (name ?? 'Not Set');

  /// Material groups: cost of one primary unit.
  double? get unitCost {
    final q = quantity;
    if (by != UsageGroupBy.material || q == null || q <= 0) return null;
    return cost / q;
  }
}

/// Result of [UsageGrouping.paginate]. Totals cover every group, not
/// just this page.
class UsageGroupPage {
  final List<UsageGroupRow> rows;
  final int totalCount;
  final int page;
  final int totalPages;
  final int totalRecords;
  final double totalCost;

  const UsageGroupPage({
    required this.rows,
    required this.totalCount,
    required this.page,
    required this.totalPages,
    this.totalRecords = 0,
    this.totalCost = 0,
  });

  int get firstIndex =>
      totalCount == 0 ? 0 : (page - 1) * usageRecordsPageSize + 1;
  int get lastIndex => firstIndex == 0 ? 0 : firstIndex + rows.length - 1;
}

class UsageGrouping {
  /// The key and name a row groups under.
  static (String?, String?) keyOf(UsageRecordRow r, UsageGroupBy by) {
    switch (by) {
      case UsageGroupBy.material:
        return (r.materialKey, r.materialName);
      case UsageGroupBy.source:
        return (r.source.key, r.source.label);
      case UsageGroupBy.staff:
        return (r.staffKey, r.staffName);
      case UsageGroupBy.department:
        return (r.departmentKey, r.departmentName);
      case UsageGroupBy.off:
        return (null, null);
    }
  }

  /// Groups [rows] that already passed the period and filters. Each
  /// group shows its most recent name.
  static List<UsageGroupRow> build(List<UsageRecordRow> rows, UsageGroupBy by) {
    if (by == UsageGroupBy.off) return [];
    final newestFirst = List<UsageRecordRow>.from(rows)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final groups = <String, UsageGroupRow>{};
    for (final r in newestFirst) {
      final (key, name) = keyOf(r, by);
      final g = groups.putIfAbsent(
        key ?? productionReportNoneKey,
        () => UsageGroupRow(
          by: by,
          key: key ?? productionReportNoneKey,
          isNone: key == null,
          name: name,
        ),
      );
      // Newest first, so only fill a name the newer ones lacked.
      g.name ??= name;
      g.count++;
      g.cost += r.cost;
      g.lastDate ??= r.createdAt;
      if (by == UsageGroupBy.material) {
        g.quantity = (g.quantity ?? 0) + r.primaryQty;
        g.unit ??= r.primaryUnit;
      }
    }
    return groups.values.toList();
  }

  /// Sorted copy. The none row is always last; nulls sink to the
  /// bottom; ties: label, then key.
  static List<UsageGroupRow> sort(
    List<UsageGroupRow> groups, {
    required UsageGroupSortField field,
    required bool ascending,
  }) {
    final cmp = ProductionRecordsQuery.cmp;
    int compare(UsageGroupRow a, UsageGroupRow b) {
      if (a.isNone != b.isNone) return a.isNone ? 1 : -1;
      int c;
      switch (field) {
        case UsageGroupSortField.name:
          c = cmp(a.label.toLowerCase(), b.label.toLowerCase(), ascending);
          break;
        case UsageGroupSortField.count:
          c = cmp(a.count, b.count, ascending);
          break;
        case UsageGroupSortField.quantity:
          c = cmp(a.quantity, b.quantity, ascending);
          break;
        case UsageGroupSortField.cost:
          c = cmp(a.cost, b.cost, ascending);
          break;
        case UsageGroupSortField.unitCost:
          c = cmp(a.unitCost, b.unitCost, ascending);
          break;
        case UsageGroupSortField.lastDate:
          c = cmp(a.lastDate, b.lastDate, ascending);
          break;
      }
      if (c != 0) return c;
      final n = a.label.toLowerCase().compareTo(b.label.toLowerCase());
      return n != 0 ? n : a.key.compareTo(b.key);
    }

    return List<UsageGroupRow>.from(groups)..sort(compare);
  }

  static UsageGroupPage paginate(List<UsageGroupRow> sorted, int requestedPage) {
    final b = reportPageBounds(
      sorted.length,
      requestedPage,
      pageSize: usageRecordsPageSize,
    );
    var records = 0;
    double cost = 0;
    for (final g in sorted) {
      records += g.count;
      cost += g.cost;
    }
    return UsageGroupPage(
      rows: sorted.isEmpty ? const [] : sorted.sublist(b.start, b.end),
      totalCount: sorted.length,
      page: b.page,
      totalPages: b.pages,
      totalRecords: records,
      totalCost: cost,
    );
  }
}

/// Filters, grouping, sorts and page of the table.
class UsageRecordsTableState {
  final UsageRecordsFilters filters;
  UsageGroupBy groupBy;
  UsageRecordsSortField sortField;
  bool ascending;
  UsageGroupSortField groupSortField;
  bool groupAscending;
  int page;

  UsageRecordsTableState({
    UsageRecordsFilters? filters,
    this.groupBy = UsageGroupBy.off,
    this.sortField = UsageRecordsSortField.createdAt,
    this.ascending = false,
    this.groupSortField = UsageGroupSortField.count,
    this.groupAscending = false,
    this.page = 1,
  }) : filters = filters ?? UsageRecordsFilters();

  bool get grouped => groupBy != UsageGroupBy.off;

  /// Reset All: clears the search and every filter. Grouping and
  /// sorting are view options and stay.
  void resetAll() {
    filters.clearAll();
    page = 1;
  }
}

/// Productions in [period] that used materials but have no usage
/// record linked to them in [usages]: they were saved before usage
/// records existed, so the usage report leaves them out. [recordRows]
/// are the scoped production rows, pending deletes already removed.
int legacyProductionsWithoutUsage({
  required ReceiptsReportPeriod period,
  required List<ProductionRecordRow> recordRows,
  required List<UsageRecordRow> usages,
  TimeOfDay? closingTime,
}) {
  final linked = {
    for (final u in usages)
      if (u.productionRecordUuid != null) u.productionRecordUuid!,
  };
  return recordRows
      .where(
        (r) =>
            r.lines.isNotEmpty &&
            !linked.contains(r.uuid) &&
            period.contains(r.createdAt, closingTime: closingTime),
      )
      .length;
}

/// The notes the usage table and the usage summary show under their
/// toolbar. The views draw these and the export carries them, so they
/// always match. [usages] are all the loaded usage rows (any period),
/// [recordRows] the loaded production rows.
List<String> usageRecordsNotes({
  required ReceiptsReportPeriod period,
  required List<UsageRecordRow> usages,
  required List<ProductionRecordRow> recordRows,
  TimeOfDay? closingTime,
}) {
  final legacy = legacyProductionsWithoutUsage(
    period: period,
    recordRows: recordRows,
    usages: usages,
    closingTime: closingTime,
  );
  return [
    if (period.isAllTime)
      'All time covers the usage records loaded on this device.',
    if (legacy > 0)
      '$legacy earlier ${legacy == 1 ? 'production has' : 'productions have'} '
          'no usage records and ${legacy == 1 ? "isn't" : "aren't"} included. '
          'Their materials appear in the Production Records report.',
  ];
}
