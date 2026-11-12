import 'package:flutter/material.dart';
import 'package:stockall/pages/report/components/report_pill.dart';
import 'package:stockall/pages/report/components/report_range_fields.dart';
import 'package:stockall/pages/report/components/report_searchable_dropdown.dart';
import 'package:stockall/pages/report/production_report/production_records_table/class/production_records_table_logic.dart';
import 'package:stockall/pages/report/production_report/production_records_table/components/production_records_filter_widgets.dart';
import 'package:stockall/pages/report/production_report/usage_records_table/class/usage_records_table_logic.dart';
import 'package:stockall/providers/theme_provider.dart';

// Filter fields, filter chips and the Group by button of the Usage
// Records table, kept apart so the export words the filters the same
// way.

/// Material / staff / department choices, taken from the loaded usage
/// records.
class UsageRecordsFilterChoices {
  final List<ProductionFilterOption> materials;
  final List<ProductionFilterOption> staff;
  final List<ProductionFilterOption> departments;

  const UsageRecordsFilterChoices({
    required this.materials,
    required this.staff,
    required this.departments,
  });

  static const empty = UsageRecordsFilterChoices(
    materials: [],
    staff: [],
    departments: [],
  );

  factory UsageRecordsFilterChoices.fromRows(List<UsageRecordRow> rows) {
    return UsageRecordsFilterChoices(
      materials: UsageRecordsOptions.materials(rows),
      staff: UsageRecordsOptions.staff(rows),
      departments: UsageRecordsOptions.departments(rows),
    );
  }
}

String usageManagedLabel(bool managed) =>
    managed ? 'Managed' : 'Not managed';

/// Material, Source, Staff, Department and Managed dropdowns, for a
/// filter panel's Wrap. Each change goes through [onApply].
List<Widget> usageKeyFilterFields({
  required ThemeProvider theme,
  required UsageRecordsFilters filters,
  required UsageRecordsFilterChoices choices,
  required bool departmentsEnabled,
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
      title: 'Material',
      allLabel: 'All materials',
      value: filters.materialKey,
      options: choices.materials,
      onChanged: (v) => filters.materialKey = v,
    ),
    ReportLabeledField(
      label: 'Source',
      width: 180,
      child: ReportSearchableDropdown<UsageSource?>(
        title: 'Source',
        value: filters.source,
        showSearch: false,
        options: [
          const ReportSearchableOption(value: null, label: 'All sources'),
          ...UsageSource.values.map(
            (s) => ReportSearchableOption<UsageSource?>(value: s, label: s.label),
          ),
        ],
        onChanged: (v) => onApply(() => filters.source = v),
        theme: theme,
      ),
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
    ReportLabeledField(
      label: 'Managed',
      width: 180,
      child: ReportSearchableDropdown<bool?>(
        title: 'Managed',
        value: filters.managed,
        showSearch: false,
        options: [
          const ReportSearchableOption(value: null, label: 'All'),
          for (final m in [true, false])
            ReportSearchableOption<bool?>(value: m, label: usageManagedLabel(m)),
        ],
        onChanged: (v) => onApply(() => filters.managed = v),
        theme: theme,
      ),
    ),
  ];
}

/// Removable chips for every active filter, worded like the export's
/// filter list.
class UsageRecordsFilterChips extends StatelessWidget {
  final ThemeProvider theme;
  final UsageRecordsFilters filters;
  final UsageRecordsFilterChoices choices;
  final bool departmentsEnabled;
  final bool canSeeCost;
  final bool canSeeQuantity;
  final String Function(num value) money;
  final String Function(num value) number;
  final void Function(VoidCallback change) onApply;

  const UsageRecordsFilterChips({
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
    for (final (label, value, clear) in usageFilterEntries(
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
List<(String, String, VoidCallback)> usageFilterEntries({
  required UsageRecordsFilters filters,
  required UsageRecordsFilterChoices choices,
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
    'Material',
    filters.materialKey,
    choices.materials,
    () => filters.materialKey = null,
  );
  if (filters.source != null) {
    out.add(('Source', filters.source!.label, () => filters.source = null));
  }
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
      usageManagedLabel(filters.managed!),
      () => filters.managed = null,
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
      'Cost',
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
/// `ProductionGroupByButton`.
class UsageGroupByButton extends StatelessWidget {
  final ThemeProvider theme;
  final UsageGroupBy value;
  final bool departmentsEnabled;
  final ValueChanged<UsageGroupBy> onChanged;

  const UsageGroupByButton({
    super.key,
    required this.theme,
    required this.value,
    required this.departmentsEnabled,
    required this.onChanged,
  });

  PopupMenuItem<UsageGroupBy> _item(UsageGroupBy g) {
    final selected = g == value;
    return PopupMenuItem<UsageGroupBy>(
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
    final on = value != UsageGroupBy.off;
    return Padding(
      padding: const EdgeInsets.only(right: 5.0),
      child: PopupMenuButton<UsageGroupBy>(
        tooltip: 'Group rows',
        offset: const Offset(0, 42),
        color: Colors.white,
        onSelected: (g) {
          if (g != value) onChanged(g);
        },
        itemBuilder:
            (context) => [
              for (final g in UsageGroupBy.values)
                if (g != UsageGroupBy.department || departmentsEnabled)
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
