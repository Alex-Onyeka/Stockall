import 'package:flutter/material.dart';
import 'package:stockall/pages/report/components/report_pill.dart';
import 'package:stockall/pages/report/components/report_range_fields.dart';
import 'package:stockall/pages/report/components/report_searchable_dropdown.dart';
import 'package:stockall/pages/report/production_report/production_records_table/class/production_records_table_logic.dart';
import 'package:stockall/pages/report/production_report/shared/class/production_report_access.dart';
import 'package:stockall/providers/theme_provider.dart';

// Filter fields, filter chips and the Group by button of the
// Production Records table, kept apart so the export words the
// filters the same way.

/// Output item / material / staff / department choices, taken from
/// the loaded records.
class ProductionRecordsFilterChoices {
  final List<ProductionFilterOption> outputs;
  final List<ProductionFilterOption> materials;
  final List<ProductionFilterOption> staff;
  final List<ProductionFilterOption> departments;

  const ProductionRecordsFilterChoices({
    required this.outputs,
    required this.materials,
    required this.staff,
    required this.departments,
  });

  static const empty = ProductionRecordsFilterChoices(
    outputs: [],
    materials: [],
    staff: [],
    departments: [],
  );

  factory ProductionRecordsFilterChoices.fromRows(
    List<ProductionRecordRow> rows,
  ) {
    return ProductionRecordsFilterChoices(
      outputs: ProductionRecordsOptions.outputs(rows),
      materials: ProductionRecordsOptions.materials(rows),
      staff: ProductionRecordsOptions.staff(rows),
      departments: ProductionRecordsOptions.departments(rows),
    );
  }

  static String labelFor(
    List<ProductionFilterOption> options,
    String key,
    String fallback,
  ) {
    for (final o in options) {
      if (o.key == key) return o.label;
    }
    return fallback;
  }
}

/// Output item, Output type, Material, Staff, Department and Cost
/// source dropdowns, for a filter panel's Wrap. Each change goes
/// through [onApply].
List<Widget> productionKeyFilterFields({
  required ThemeProvider theme,
  required ProductionRecordsFilters filters,
  required ProductionRecordsFilterChoices choices,
  required bool departmentsEnabled,
  required bool canSeeCost,
  required void Function(VoidCallback change) onApply,
}) {
  Widget keyDropdown({
    required String title,
    required String allLabel,
    required String? value,
    required List<ProductionFilterOption> options,
    required ValueChanged<String?> onChanged,
  }) {
    return ReportLabeledField(
      label: title,
      width: 220,
      child: ReportSearchableDropdown<String?>(
        title: title,
        value: value,
        options: [
          ReportSearchableOption(value: null, label: allLabel),
          ...options.map(
            (o) => ReportSearchableOption<String?>(value: o.key, label: o.label),
          ),
        ],
        onChanged: (v) => onApply(() => onChanged(v)),
        theme: theme,
        searchHint: 'Search ${title.toLowerCase()}...',
      ),
    );
  }

  return [
    keyDropdown(
      title: 'Output Item',
      allLabel: 'All items',
      value: filters.outputKey,
      options: choices.outputs,
      onChanged: (v) => filters.outputKey = v,
    ),
    ReportLabeledField(
      label: 'Output Type',
      width: 180,
      child: ReportSearchableDropdown<ProductionOutputType?>(
        title: 'Output Type',
        value: filters.outputType,
        showSearch: false,
        options: [
          const ReportSearchableOption(value: null, label: 'All types'),
          ...ProductionOutputType.values.map(
            (t) => ReportSearchableOption<ProductionOutputType?>(
              value: t,
              label: t.label,
            ),
          ),
        ],
        onChanged: (v) => onApply(() => filters.outputType = v),
        theme: theme,
      ),
    ),
    keyDropdown(
      title: 'Material',
      allLabel: 'All materials',
      value: filters.materialKey,
      options: choices.materials,
      onChanged: (v) => filters.materialKey = v,
    ),
    keyDropdown(
      title: 'Staff',
      allLabel: 'All staff',
      value: filters.staffKey,
      options: choices.staff,
      onChanged: (v) => filters.staffKey = v,
    ),
    if (departmentsEnabled)
      keyDropdown(
        title: 'Department',
        allLabel: 'All departments',
        value: filters.departmentKey,
        options: choices.departments,
        onChanged: (v) => filters.departmentKey = v,
      ),
    if (canSeeCost)
      ReportLabeledField(
        label: 'Cost Source',
        width: 180,
        child: ReportSearchableDropdown<ProductionCostSource?>(
          title: 'Cost Source',
          value: filters.costSource,
          showSearch: false,
          options: [
            const ReportSearchableOption(value: null, label: 'All sources'),
            ...ProductionCostSource.values.map(
              (s) => ReportSearchableOption<ProductionCostSource?>(
                value: s,
                label: s.label,
              ),
            ),
          ],
          onChanged: (v) => onApply(() => filters.costSource = v),
          theme: theme,
        ),
      ),
  ];
}

/// Removable chips for every active filter, worded like the export's
/// filter list.
class ProductionRecordsFilterChips extends StatelessWidget {
  final ThemeProvider theme;
  final ProductionRecordsFilters filters;
  final ProductionRecordsFilterChoices choices;
  final bool departmentsEnabled;
  final bool canSeeCost;
  final bool canSeeQuantity;
  final String Function(num value) money;
  final String Function(num value) number;
  final void Function(VoidCallback change) onApply;

  const ProductionRecordsFilterChips({
    super.key,
    required this.theme,
    required this.filters,
    required this.choices,
    required this.departmentsEnabled,
    required this.canSeeCost,
    required this.canSeeQuantity,
    required this.money,
    required this.number,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[];
    for (final (label, value, clear) in productionFilterEntries(
      filters: filters,
      choices: choices,
      departmentsEnabled: departmentsEnabled,
      canSeeCost: canSeeCost,
      canSeeQuantity: canSeeQuantity,
      money: money,
      number: number,
      includeSearch: false,
    )) {
      chips.add(
        InputChip(
          label: Text('$label: $value', style: const TextStyle(fontSize: 10)),
          onDeleted: () => onApply(clear),
          deleteIcon: const Icon(Icons.close, size: 12),
          visualDensity: VisualDensity.compact,
          backgroundColor: theme.lightModeColor.prColor300.withAlpha(25),
          side: BorderSide.none,
        ),
      );
    }
    if (chips.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Wrap(spacing: 6, runSpacing: 4, children: chips),
      ),
    );
  }
}

/// Every active filter as (label, value, clear), in chip order. The
/// chips and the export's filter list both use this.
List<(String, String, VoidCallback)> productionFilterEntries({
  required ProductionRecordsFilters filters,
  required ProductionRecordsFilterChoices choices,
  required bool departmentsEnabled,
  required bool canSeeCost,
  required bool canSeeQuantity,
  required String Function(num value) money,
  required String Function(num value) number,
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
    out.add((
      title,
      ProductionRecordsFilterChoices.labelFor(options, k, title),
      clear,
    ));
  }

  String range(double? min, double? max, String Function(num) f) =>
      '${min != null ? f(min) : 'Any'} - ${max != null ? f(max) : 'Any'}';

  final search = filters.search.trim();
  if (includeSearch && search.isNotEmpty) {
    out.add(('Search', search, () => filters.search = ''));
  }
  key(
    'Output Item',
    filters.outputKey,
    choices.outputs,
    () => filters.outputKey = null,
  );
  if (filters.outputType != null) {
    out.add((
      'Output Type',
      filters.outputType!.label,
      () => filters.outputType = null,
    ));
  }
  key(
    'Material',
    filters.materialKey,
    choices.materials,
    () => filters.materialKey = null,
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
  if (canSeeCost && filters.costSource != null) {
    out.add((
      'Cost Source',
      filters.costSource!.label,
      () => filters.costSource = null,
    ));
  }
  if (canSeeQuantity &&
      (filters.quantityMin != null || filters.quantityMax != null)) {
    out.add((
      'Quantity',
      range(filters.quantityMin, filters.quantityMax, number),
      () {
        filters.quantityMin = null;
        filters.quantityMax = null;
      },
    ));
  }
  if (canSeeCost && (filters.costMin != null || filters.costMax != null)) {
    out.add((
      'Recorded Cost',
      range(filters.costMin, filters.costMax, money),
      () {
        filters.costMin = null;
        filters.costMax = null;
      },
    ));
  }
  return out;
}

/// Toolbar pill that opens the Group by choices, like
/// `PurchaseGroupByButton`.
class ProductionGroupByButton extends StatelessWidget {
  final ThemeProvider theme;
  final ProductionGroupBy value;
  final bool departmentsEnabled;
  final ValueChanged<ProductionGroupBy> onChanged;

  const ProductionGroupByButton({
    super.key,
    required this.theme,
    required this.value,
    required this.departmentsEnabled,
    required this.onChanged,
  });

  PopupMenuItem<ProductionGroupBy> _item(ProductionGroupBy g) {
    final selected = g == value;
    return PopupMenuItem<ProductionGroupBy>(
      value: g,
      height: 38,
      child: Row(
        spacing: 8,
        children: [
          Icon(
            selected ? Icons.check_rounded : null,
            size: 16,
            color: theme.lightModeColor.prColor300,
          ),
          Text(
            g.label,
            style: TextStyle(
              fontSize: theme.mobileTexts.b3.fontSize,
              fontWeight: selected ? FontWeight.bold : null,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final on = value != ProductionGroupBy.off;
    return Padding(
      padding: const EdgeInsets.only(right: 5.0),
      child: PopupMenuButton<ProductionGroupBy>(
        tooltip: 'Group rows',
        offset: const Offset(0, 42),
        color: Colors.white,
        onSelected: (g) {
          if (g != value) onChanged(g);
        },
        itemBuilder:
            (context) => [
              for (final g in ProductionGroupBy.values)
                if (g != ProductionGroupBy.department || departmentsEnabled)
                  _item(g),
            ],
        child: ReportPill(
          theme: theme,
          icon: Icons.workspaces_outline,
          label: on ? 'Group by: ${value.label}' : 'Group by',
          highlighted: on,
        ),
      ),
    );
  }
}
