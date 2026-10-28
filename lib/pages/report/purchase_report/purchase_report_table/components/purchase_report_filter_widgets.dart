import 'package:flutter/material.dart';
import 'package:stockall/pages/report/components/report_pill.dart';
import 'package:stockall/pages/report/components/report_range_fields.dart';
import 'package:stockall/pages/report/components/report_searchable_dropdown.dart';
import 'package:stockall/pages/report/purchase_report/purchase_report_table/class/purchase_report_table_logic.dart';
import 'package:stockall/providers/theme_provider.dart';

// Filter fields, filter chips and the Group by button of the
// purchase table, kept apart so the purchase analysis can offer the
// same choices on the same keys.

/// Supplier / staff / department choices, taken from the loaded
/// purchases.
class PurchaseFilterChoices {
  final List<PurchaseFilterOption> suppliers;
  final List<PurchaseFilterOption> staff;
  final List<PurchaseFilterOption> departments;

  const PurchaseFilterChoices({
    required this.suppliers,
    required this.staff,
    required this.departments,
  });

  static const empty = PurchaseFilterChoices(
    suppliers: [],
    staff: [],
    departments: [],
  );

  factory PurchaseFilterChoices.fromRows(
    List<PurchaseReportRow> rows,
  ) {
    return PurchaseFilterChoices(
      suppliers: PurchaseReportOptions.suppliers(rows),
      staff: PurchaseReportOptions.staff(rows),
      departments: PurchaseReportOptions.departments(rows),
    );
  }

  static String labelFor(
    List<PurchaseFilterOption> options,
    String key,
    String fallback,
  ) {
    for (final o in options) {
      if (o.key == key) return o.label;
    }
    return fallback;
  }
}

/// Supplier, Staff, Department, Channel and Status dropdowns, for a
/// filter panel's Wrap. Each change goes through [onApply].
List<Widget> purchaseKeyFilterFields({
  required ThemeProvider theme,
  required PurchaseReportFilters filters,
  required PurchaseFilterChoices choices,
  required bool departmentsEnabled,
  required void Function(VoidCallback change) onApply,
}) {
  Widget keyDropdown({
    required String title,
    required String allLabel,
    required String? value,
    required List<PurchaseFilterOption> options,
    required ValueChanged<String?> onChanged,
    bool showSearch = true,
    double width = 220,
  }) {
    return ReportLabeledField(
      label: title,
      width: width,
      child: ReportSearchableDropdown<String?>(
        title: title,
        value: value,
        showSearch: showSearch,
        options: [
          ReportSearchableOption(
            value: null,
            label: allLabel,
          ),
          ...options.map(
            (o) => ReportSearchableOption<String?>(
              value: o.key,
              label: o.label,
            ),
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
      title: 'Supplier',
      allLabel: 'All suppliers',
      value: filters.supplierKey,
      options: choices.suppliers,
      onChanged: (v) => filters.supplierKey = v,
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
    keyDropdown(
      title: 'Channel',
      allLabel: 'All channels',
      value: filters.channelKey,
      options: PurchaseReportOptions.channels(),
      onChanged: (v) => filters.channelKey = v,
      showSearch: false,
      width: 180,
    ),
    ReportLabeledField(
      label: 'Status',
      width: 180,
      child: ReportSearchableDropdown<PurchaseStatus?>(
        title: 'Status',
        value: filters.status,
        showSearch: false,
        options: [
          const ReportSearchableOption(
            value: null,
            label: 'All statuses',
          ),
          ...PurchaseStatus.values.map(
            (s) => ReportSearchableOption<PurchaseStatus?>(
              value: s,
              label: s.label,
            ),
          ),
        ],
        onChanged: (v) => onApply(() => filters.status = v),
        theme: theme,
      ),
    ),
  ];
}

/// Removable chips for every active filter. With [showSearch] the
/// search text is a chip too (for pages without a search box).
class PurchaseReportFilterChips extends StatelessWidget {
  final ThemeProvider theme;
  final PurchaseReportFilters filters;
  final PurchaseFilterChoices choices;
  final bool departmentsEnabled;
  final bool showSearch;
  final String Function(num value) money;
  final void Function(VoidCallback change) onApply;

  const PurchaseReportFilterChips({
    super.key,
    required this.theme,
    required this.filters,
    required this.choices,
    required this.departmentsEnabled,
    required this.money,
    required this.onApply,
    this.showSearch = false,
  });

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[];
    void chip(String text, VoidCallback clear) {
      chips.add(
        InputChip(
          label: Text(
            text,
            style: const TextStyle(fontSize: 10),
          ),
          onDeleted: () => onApply(clear),
          deleteIcon: const Icon(Icons.close, size: 12),
          visualDensity: VisualDensity.compact,
          backgroundColor: theme.lightModeColor.prColor300
              .withAlpha(25),
          side: BorderSide.none,
        ),
      );
    }

    void keyChip(
      String title,
      String? key,
      List<PurchaseFilterOption> options,
      VoidCallback clear,
    ) {
      if (key == null) return;
      chip(
        '$title: ${PurchaseFilterChoices.labelFor(options, key, title)}',
        clear,
      );
    }

    String range(double? min, double? max) =>
        '${min != null ? money(min) : 'Any'}'
        ' - ${max != null ? money(max) : 'Any'}';

    if (showSearch && filters.search.trim().isNotEmpty) {
      chip(
        'Search: ${filters.search.trim()}',
        () => filters.search = '',
      );
    }
    keyChip(
      'Supplier',
      filters.supplierKey,
      choices.suppliers,
      () => filters.supplierKey = null,
    );
    keyChip(
      'Staff',
      filters.staffKey,
      choices.staff,
      () => filters.staffKey = null,
    );
    if (departmentsEnabled) {
      keyChip(
        'Department',
        filters.departmentKey,
        choices.departments,
        () => filters.departmentKey = null,
      );
    }
    keyChip(
      'Channel',
      filters.channelKey,
      PurchaseReportOptions.channels(),
      () => filters.channelKey = null,
    );
    if (filters.status != null) {
      chip(
        'Status: ${filters.status!.label}',
        () => filters.status = null,
      );
    }
    if (filters.totalMin != null || filters.totalMax != null) {
      chip(
        'Total: ${range(filters.totalMin, filters.totalMax)}',
        () {
          filters.totalMin = null;
          filters.totalMax = null;
        },
      );
    }
    if (filters.balanceMin != null ||
        filters.balanceMax != null) {
      chip(
        'Balance: ${range(filters.balanceMin, filters.balanceMax)}',
        () {
          filters.balanceMin = null;
          filters.balanceMax = null;
        },
      );
    }
    if (chips.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Wrap(
          spacing: 6,
          runSpacing: 4,
          children: chips,
        ),
      ),
    );
  }
}

/// Toolbar pill that opens the Group by choices. Looks like
/// `ReportGroupByButton`, which only offers the shared
/// `ReportGroupBy` values (no Supplier).
class PurchaseGroupByButton extends StatelessWidget {
  final ThemeProvider theme;
  final PurchaseGroupBy value;
  final ValueChanged<PurchaseGroupBy> onChanged;

  const PurchaseGroupByButton({
    super.key,
    required this.theme,
    required this.value,
    required this.onChanged,
  });

  PopupMenuItem<PurchaseGroupBy> _item(PurchaseGroupBy g) {
    final selected = g == value;
    return PopupMenuItem<PurchaseGroupBy>(
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
    final on = value != PurchaseGroupBy.off;
    return Padding(
      padding: const EdgeInsets.only(right: 5.0),
      child: PopupMenuButton<PurchaseGroupBy>(
        tooltip: 'Group rows',
        offset: const Offset(0, 42),
        color: Colors.white,
        onSelected: (g) {
          if (g != value) onChanged(g);
        },
        itemBuilder:
            (context) => [
              for (final g in PurchaseGroupBy.values) _item(g),
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
