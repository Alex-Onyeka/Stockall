import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_expenses/expense_category.dart';
import 'package:stockall/classes/temp_expenses/temp_expenses_class.dart';
import 'package:stockall/pages/report/components/report_pill.dart';
import 'package:stockall/pages/report/components/report_range_fields.dart';
import 'package:stockall/pages/report/components/report_searchable_dropdown.dart';
import 'package:stockall/pages/report/expenses_report/expenses_report_table/class/expenses_report_table_logic.dart';
import 'package:stockall/providers/theme_provider.dart';

// Filter fields, filter chips, the Group by button and the category
// badge colours of the Expenses Report table.

/// Category badge colour, as on the Expenses page's tiles.
Color expenseCategoryColor(String categoryKey) {
  switch (categoryKey) {
    case ExpenseType.staffSalary:
      return Colors.indigo;
    case ExpenseType.stockPurchase:
      return Colors.teal;
    case ExpenseType.simpleExpense:
      return Colors.blueGrey;
    default:
      return Colors.deepPurple;
  }
}

/// Every filter's choices, taken from the loaded expenses (and the
/// shop's custom categories).
class ExpensesFilterChoices {
  final List<ExpensesFilterOption> categories;
  final List<ExpensesFilterOption> staff;
  final List<ExpensesFilterOption> paidStaff;
  final List<ExpensesFilterOption> channels;
  final List<ExpensesFilterOption> departments;

  const ExpensesFilterChoices({
    required this.categories,
    required this.staff,
    required this.paidStaff,
    required this.channels,
    required this.departments,
  });

  static const empty = ExpensesFilterChoices(
    categories: [],
    staff: [],
    paidStaff: [],
    channels: [],
    departments: [],
  );

  factory ExpensesFilterChoices.fromRows(
    List<ExpensesReportRow> rows, {
    List<ExpenseCategory> categories = const [],
  }) {
    return ExpensesFilterChoices(
      categories: ExpensesReportOptions.categories(
        rows,
        categories: categories,
      ),
      staff: ExpensesReportOptions.staff(rows),
      paidStaff: ExpensesReportOptions.paidStaff(rows),
      channels: ExpensesReportOptions.channels(rows),
      departments: ExpensesReportOptions.departments(rows),
    );
  }

  static String labelFor(
    List<ExpensesFilterOption> options,
    String key,
    String fallback,
  ) {
    for (final o in options) {
      if (o.key == key) return o.label;
    }
    return fallback;
  }
}

String _linesLabel(bool v) => v ? 'With sub-expenses' : 'Without sub-expenses';

/// Category, Staff, Staff Paid, Channel, Department and
/// Sub-expenses dropdowns, for a filter panel's Wrap. Each change
/// goes through [onApply].
List<Widget> expensesKeyFilterFields({
  required ThemeProvider theme,
  required ExpensesReportFilters filters,
  required ExpensesFilterChoices choices,
  required bool departmentsEnabled,
  required void Function(VoidCallback change) onApply,
}) {
  Widget keyDropdown({
    required String title,
    required String allLabel,
    required String? value,
    required List<ExpensesFilterOption> options,
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
      title: 'Category',
      allLabel: 'All categories',
      value: filters.categoryKey,
      options: choices.categories,
      onChanged: (v) => filters.categoryKey = v,
    ),
    keyDropdown(
      title: 'Staff',
      allLabel: 'All staff',
      value: filters.staffKey,
      options: choices.staff,
      onChanged: (v) => filters.staffKey = v,
    ),
    keyDropdown(
      title: 'Staff Paid',
      allLabel: 'All staff paid',
      value: filters.paidStaffKey,
      options: choices.paidStaff,
      onChanged: (v) => filters.paidStaffKey = v,
    ),
    keyDropdown(
      title: 'Channel',
      allLabel: 'All channels',
      value: filters.channelKey,
      options: choices.channels,
      onChanged: (v) => filters.channelKey = v,
      width: 200,
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
      label: 'Sub-expenses',
      width: 200,
      child: ReportSearchableDropdown<bool?>(
        title: 'Sub-expenses',
        value: filters.hasLines,
        showSearch: false,
        options: [
          const ReportSearchableOption(value: null, label: 'All expenses'),
          for (final v in [true, false])
            ReportSearchableOption<bool?>(value: v, label: _linesLabel(v)),
        ],
        onChanged: (v) => onApply(() => filters.hasLines = v),
        theme: theme,
      ),
    ),
  ];
}

/// Removable chips for every active filter. With [showSearch] the
/// search text is a chip too.
class ExpensesReportFilterChips extends StatelessWidget {
  final ThemeProvider theme;
  final ExpensesReportFilters filters;
  final ExpensesFilterChoices choices;
  final bool departmentsEnabled;
  final bool showSearch;
  final String Function(num value) money;
  final void Function(VoidCallback change) onApply;

  const ExpensesReportFilterChips({
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
          label: Text(text, style: const TextStyle(fontSize: 10)),
          onDeleted: () => onApply(clear),
          deleteIcon: const Icon(Icons.close, size: 12),
          visualDensity: VisualDensity.compact,
          backgroundColor: theme.lightModeColor.prColor300.withAlpha(25),
          side: BorderSide.none,
        ),
      );
    }

    void keyChip(
      String title,
      String? key,
      List<ExpensesFilterOption> options,
      VoidCallback clear,
    ) {
      if (key == null) return;
      chip(
        '$title: ${ExpensesFilterChoices.labelFor(options, key, title)}',
        clear,
      );
    }

    if (showSearch && filters.search.trim().isNotEmpty) {
      chip('Search: ${filters.search.trim()}', () => filters.search = '');
    }
    keyChip(
      'Category',
      filters.categoryKey,
      choices.categories,
      () => filters.categoryKey = null,
    );
    keyChip(
      'Staff',
      filters.staffKey,
      choices.staff,
      () => filters.staffKey = null,
    );
    keyChip(
      'Staff Paid',
      filters.paidStaffKey,
      choices.paidStaff,
      () => filters.paidStaffKey = null,
    );
    keyChip(
      'Channel',
      filters.channelKey,
      choices.channels,
      () => filters.channelKey = null,
    );
    if (departmentsEnabled) {
      keyChip(
        'Department',
        filters.departmentKey,
        choices.departments,
        () => filters.departmentKey = null,
      );
    }
    if (filters.hasLines != null) {
      chip(_linesLabel(filters.hasLines!), () => filters.hasLines = null);
    }
    if (filters.amountMin != null || filters.amountMax != null) {
      final min = filters.amountMin;
      final max = filters.amountMax;
      chip(
        'Amount: ${min != null ? money(min) : 'Any'}'
        ' - ${max != null ? money(max) : 'Any'}',
        () {
          filters.amountMin = null;
          filters.amountMax = null;
        },
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

/// Toolbar pill that opens the Group by choices, as the Purchase
/// Report's.
class ExpensesGroupByButton extends StatelessWidget {
  final ThemeProvider theme;
  final ExpensesGroupBy value;
  final ValueChanged<ExpensesGroupBy> onChanged;

  const ExpensesGroupByButton({
    super.key,
    required this.theme,
    required this.value,
    required this.onChanged,
  });

  PopupMenuItem<ExpensesGroupBy> _item(ExpensesGroupBy g) {
    final selected = g == value;
    return PopupMenuItem<ExpensesGroupBy>(
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
    final on = value != ExpensesGroupBy.off;
    return Padding(
      padding: const EdgeInsets.only(right: 5.0),
      child: PopupMenuButton<ExpensesGroupBy>(
        tooltip: 'Group rows',
        offset: const Offset(0, 42),
        color: Colors.white,
        onSelected: (g) {
          if (g != value) onChanged(g);
        },
        itemBuilder:
            (context) => [for (final g in ExpensesGroupBy.values) _item(g)],
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
