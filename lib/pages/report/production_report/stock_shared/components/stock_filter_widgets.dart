// Filter fields and chip / export wording of the stock table (I1 / M1)
// and the stock history table (I3 / M3). The chips and the exports
// word the filters through the same entries functions.

import 'package:flutter/material.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/date_picker_function.dart';
import 'package:stockall/pages/report/components/report_range_fields.dart';
import 'package:stockall/pages/report/components/report_searchable_dropdown.dart';
import 'package:stockall/pages/report/production_report/production_records_table/class/production_records_table_logic.dart';
import 'package:stockall/pages/report/production_report/production_records_table/components/production_records_filter_widgets.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/production_stock_model.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/stock_history_logic.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/stock_items_logic.dart';
import 'package:stockall/providers/theme_provider.dart';

Widget _keyDropdown({
  required ThemeProvider theme,
  required String title,
  required String allLabel,
  required String? value,
  required List<ProductionFilterOption> options,
  required ValueChanged<String?> onChanged,
  double width = 220,
}) {
  return ReportLabeledField(
    label: title,
    width: width,
    child: ReportSearchableDropdown<String?>(
      title: title,
      value: value,
      options: [
        ReportSearchableOption(value: null, label: allLabel),
        ...options.map(
          (o) => ReportSearchableOption<String?>(value: o.key, label: o.label),
        ),
      ],
      onChanged: onChanged,
      theme: theme,
      searchHint: 'Search ${title.toLowerCase()}...',
    ),
  );
}

Widget _choice<T>({
  required ThemeProvider theme,
  required String title,
  required String allLabel,
  required T? value,
  required List<(T, String)> options,
  required ValueChanged<T?> onChanged,
}) {
  return ReportLabeledField(
    label: title,
    width: 180,
    child: ReportSearchableDropdown<T?>(
      title: title,
      value: value,
      showSearch: false,
      options: [
        ReportSearchableOption<T?>(value: null, label: allLabel),
        for (final (v, label) in options)
          ReportSearchableOption<T?>(value: v, label: label),
      ],
      onChanged: onChanged,
      theme: theme,
    ),
  );
}

String productionManagedLabel(bool managed) => managed ? 'Managed' : 'Not managed';

String _expiryText(DateTime? s, DateTime? e) {
  if (s != null && e != null) {
    final same = s.year == e.year && s.month == e.month && s.day == e.day;
    return same ? formatDateTime(s) : '${formatDateTime(s)} - ${formatDateTime(e)}';
  }
  if (s != null) return 'From ${formatDateTime(s)}';
  if (e != null) return 'Up to ${formatDateTime(e)}';
  return 'All expiry dates';
}

/// Item, Category, Department, Stock Level, Managed and the expiry
/// range of the stock table. Each change goes through [onApply].
List<Widget> productionStockFilterFields(
  BuildContext context, {
  required ThemeProvider theme,
  required ProductionStockKind kind,
  required ProductionStockFilters filters,
  required ProductionStockFilterChoices choices,
  required bool departmentsEnabled,
  required bool canSeeQuantity,
  required void Function(VoidCallback change) onApply,
}) {
  return [
    _keyDropdown(
      theme: theme,
      title: kind.singular,
      allLabel: 'All ${kind.countNoun}',
      value: filters.itemKey,
      options: choices.items,
      onChanged: (v) => onApply(() => filters.itemKey = v),
    ),
    _keyDropdown(
      theme: theme,
      title: 'Category',
      allLabel: 'All categories',
      value: filters.categoryKey,
      options: choices.categories,
      onChanged: (v) => onApply(() => filters.categoryKey = v),
    ),
    if (departmentsEnabled)
      _keyDropdown(
        theme: theme,
        title: 'Department',
        allLabel: 'All departments',
        value: filters.departmentKey,
        options: choices.departments,
        onChanged: (v) => onApply(() => filters.departmentKey = v),
      ),
    if (canSeeQuantity)
      _choice<ProductionStockLevel>(
        theme: theme,
        title: 'Stock Level',
        allLabel: 'All levels',
        value: filters.stockLevel,
        options: [for (final l in productionStockLevels(kind)) (l, l.label)],
        onChanged: (v) => onApply(() => filters.stockLevel = v),
      ),
    _choice<bool>(
      theme: theme,
      title: 'Managed',
      allLabel: 'All',
      value: filters.managed,
      options: [
        for (final m in [true, false]) (m, productionManagedLabel(m)),
      ],
      onChanged: (v) => onApply(() => filters.managed = v),
    ),
    ReportLabeledField(
      label: 'Expiry Date',
      width: 240,
      child: OutlinedButton.icon(
        key: const ValueKey('stock-expiry-range'),
        onPressed:
            () => mainDatePicker(
              context: context,
              theme: theme,
              singleDate: (date) {
                if (date == null) return;
                final d = DateTime(date.year, date.month, date.day);
                onApply(() {
                  filters.expiryStart = d;
                  filters.expiryEnd = d;
                });
              },
              rangeDate: (first, last) {
                if (first == null) return;
                var s = DateTime(first.year, first.month, first.day);
                final end = last ?? first;
                var e = DateTime(end.year, end.month, end.day);
                if (e.isBefore(s)) (s, e) = (e, s);
                onApply(() {
                  filters.expiryStart = s;
                  filters.expiryEnd = e;
                });
              },
            ),
        icon: const Icon(Icons.event_outlined, size: 16),
        label: Text(
          _expiryText(filters.expiryStart, filters.expiryEnd),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ),
  ];
}

String _range(double? min, double? max, String Function(num) f) =>
    '${min != null ? f(min) : 'Any'} - ${max != null ? f(max) : 'Any'}';

/// Every active filter of the stock table as (label, value, clear), in
/// chip order. The chips and the export both use this.
List<(String, String, VoidCallback)> productionStockFilterEntries({
  required ProductionStockKind kind,
  required ProductionStockFilters filters,
  required ProductionStockFilterChoices choices,
  required bool departmentsEnabled,
  required bool canSeeCost,
  required bool canSeeQuantity,
  required String Function(num value) money,
  required String Function(num value) number,
  bool includeSearch = true,
}) {
  final out = <(String, String, VoidCallback)>[];
  String label(List<ProductionFilterOption> o, String k, String fallback) =>
      ProductionRecordsFilterChoices.labelFor(o, k, fallback);
  final search = filters.search.trim();
  if (includeSearch && search.isNotEmpty) {
    out.add(('Search', search, () => filters.search = ''));
  }
  if (filters.itemKey != null) {
    out.add((
      kind.singular,
      label(choices.items, filters.itemKey!, kind.singular),
      () => filters.itemKey = null,
    ));
  }
  if (filters.categoryKey != null) {
    out.add((
      'Category',
      filters.categoryKey == productionReportNoneKey
          ? productionNoCategoryLabel
          : label(choices.categories, filters.categoryKey!, 'Category'),
      () => filters.categoryKey = null,
    ));
  }
  if (departmentsEnabled && filters.departmentKey != null) {
    out.add((
      'Department',
      filters.departmentKey == productionReportNoneKey
          ? productionNoDepartmentLabel
          : label(choices.departments, filters.departmentKey!, 'Department'),
      () => filters.departmentKey = null,
    ));
  }
  if (canSeeQuantity && filters.stockLevel != null) {
    out.add((
      'Stock Level',
      filters.stockLevel!.label,
      () => filters.stockLevel = null,
    ));
  }
  if (filters.managed != null) {
    out.add((
      'Managed',
      productionManagedLabel(filters.managed!),
      () => filters.managed = null,
    ));
  }
  if (canSeeCost && (filters.costMin != null || filters.costMax != null)) {
    out.add((
      'Cost Price',
      _range(filters.costMin, filters.costMax, money),
      () {
        filters.costMin = null;
        filters.costMax = null;
      },
    ));
  }
  if (canSeeQuantity &&
      (filters.quantityMin != null || filters.quantityMax != null)) {
    out.add((
      'Stock',
      _range(filters.quantityMin, filters.quantityMax, number),
      () {
        filters.quantityMin = null;
        filters.quantityMax = null;
      },
    ));
  }
  if (filters.expiryStart != null || filters.expiryEnd != null) {
    out.add((
      'Expiry',
      _expiryText(filters.expiryStart, filters.expiryEnd),
      () {
        filters.expiryStart = null;
        filters.expiryEnd = null;
      },
    ));
  }
  return out;
}

/// Item, Event, Direction, Source, Destination, Staff, Department and
/// Managed of the history table.
List<Widget> productionHistoryFilterFields({
  required ThemeProvider theme,
  required ProductionStockKind kind,
  required ProductionHistoryFilters filters,
  required ProductionHistoryFilterChoices choices,
  required bool departmentsEnabled,
  required void Function(VoidCallback change) onApply,
}) {
  return [
    _keyDropdown(
      theme: theme,
      title: kind.singular,
      allLabel: 'All ${kind.countNoun}',
      value: filters.itemKey,
      options: choices.items,
      onChanged: (v) => onApply(() => filters.itemKey = v),
    ),
    _keyDropdown(
      theme: theme,
      title: 'Event',
      allLabel: 'All events',
      value: filters.eventKey,
      options: choices.events,
      onChanged: (v) => onApply(() => filters.eventKey = v),
      width: 200,
    ),
    _choice<ProductionHistoryDirection>(
      theme: theme,
      title: 'Direction',
      allLabel: 'All',
      value: filters.direction,
      options: [
        for (final d in ProductionHistoryDirection.values) (d, d.label),
      ],
      onChanged: (v) => onApply(() => filters.direction = v),
    ),
    _keyDropdown(
      theme: theme,
      title: 'Source',
      allLabel: 'All sources',
      value: filters.source,
      options: choices.sources,
      onChanged: (v) => onApply(() => filters.source = v),
      width: 180,
    ),
    _keyDropdown(
      theme: theme,
      title: 'Destination',
      allLabel: 'All destinations',
      value: filters.destination,
      options: choices.destinations,
      onChanged: (v) => onApply(() => filters.destination = v),
      width: 180,
    ),
    _keyDropdown(
      theme: theme,
      title: 'Staff',
      allLabel: 'All staff',
      value: filters.staffKey,
      options: choices.staff,
      onChanged: (v) => onApply(() => filters.staffKey = v),
    ),
    if (departmentsEnabled)
      _keyDropdown(
        theme: theme,
        title: 'Department',
        allLabel: 'All departments',
        value: filters.departmentKey,
        options: choices.departments,
        onChanged: (v) => onApply(() => filters.departmentKey = v),
      ),
    _choice<bool>(
      theme: theme,
      title: 'Managed',
      allLabel: 'All',
      value: filters.managed,
      options: [
        for (final m in [true, false]) (m, productionManagedLabel(m)),
      ],
      onChanged: (v) => onApply(() => filters.managed = v),
    ),
  ];
}

/// Every active filter of the history table as (label, value, clear).
List<(String, String, VoidCallback)> productionHistoryFilterEntries({
  required ProductionStockKind kind,
  required ProductionHistoryFilters filters,
  required ProductionHistoryFilterChoices choices,
  required bool departmentsEnabled,
  bool includeSearch = true,
}) {
  final out = <(String, String, VoidCallback)>[];
  void key(
    String title,
    String? k,
    List<ProductionFilterOption> options,
    VoidCallback clear,
  ) {
    if (k == null) return;
    out.add((title, ProductionRecordsFilterChoices.labelFor(options, k, k), clear));
  }

  final search = filters.search.trim();
  if (includeSearch && search.isNotEmpty) {
    out.add(('Search', search, () => filters.search = ''));
  }
  key(kind.singular, filters.itemKey, choices.items, () => filters.itemKey = null);
  key('Event', filters.eventKey, choices.events, () => filters.eventKey = null);
  if (filters.direction != null) {
    out.add(('Direction', filters.direction!.label, () => filters.direction = null));
  }
  key('Source', filters.source, choices.sources, () => filters.source = null);
  key(
    'Destination',
    filters.destination,
    choices.destinations,
    () => filters.destination = null,
  );
  key('Staff', filters.staffKey, choices.staff, () => filters.staffKey = null);
  if (departmentsEnabled) {
    key(
      'Department',
      filters.departmentKey,
      choices.departments,
      () => filters.departmentKey = null,
    );
  }
  if (filters.managed != null) {
    out.add((
      'Managed',
      productionManagedLabel(filters.managed!),
      () => filters.managed = null,
    ));
  }
  return out;
}
