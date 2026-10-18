import 'package:flutter/material.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/date_picker_function.dart';
import 'package:stockall/pages/report/components/report_pill.dart';
import 'package:stockall/pages/report/components/report_range_fields.dart';
import 'package:stockall/pages/report/components/report_searchable_dropdown.dart';
import 'package:stockall/pages/report/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/providers/theme_provider.dart';

// Period button, filter fields and filter chips shared by the
// receipts table and the receipt summary, so both offer the same
// choices on the same keys.

/// Staff / customer / sub-staff / department choices, taken from
/// the loaded receipts.
class ReceiptsFilterChoices {
  final List<ReceiptsFilterOption> staff;
  final List<ReceiptsFilterOption> customers;
  final List<ReceiptsFilterOption> subStaff;
  final List<ReceiptsFilterOption> departments;

  const ReceiptsFilterChoices({
    required this.staff,
    required this.customers,
    required this.subStaff,
    required this.departments,
  });

  static const empty = ReceiptsFilterChoices(
    staff: [],
    customers: [],
    subStaff: [],
    departments: [],
  );

  factory ReceiptsFilterChoices.fromRows(
    List<ReceiptsReportRow> rows,
  ) {
    return ReceiptsFilterChoices(
      staff: ReceiptsReportOptions.staff(rows),
      customers: ReceiptsReportOptions.customers(rows),
      subStaff: ReceiptsReportOptions.subStaff(rows),
      departments: ReceiptsReportOptions.departments(rows),
    );
  }

  static String labelFor(
    List<ReceiptsFilterOption> options,
    String key,
    String fallback,
  ) {
    for (final o in options) {
      if (o.key == key) return o.label;
    }
    return fallback;
  }
}

/// Today's business day.
bool receiptsPeriodIsToday(ReceiptsReportPeriod period) {
  return period.isSingleDay &&
      period.start == ReceiptsReportPeriod.today().start;
}

String receiptsPeriodLabel(ReceiptsReportPeriod period) {
  if (period.isAllTime) return 'All time';
  final s = period.start!;
  final e = period.end!;
  if (period.isSingleDay) {
    return receiptsPeriodIsToday(period)
        ? 'Today, ${formatDateTime(s)}'
        : formatDateTime(s);
  }
  return '${formatDateTime(s)} - ${formatDateTime(e)}';
}

/// "Date: ..." pill with Today / Pick a date or range / All time,
/// plus a "Today" shortcut when another period is set. Disabled
/// (today only) without the View Date permission.
class ReceiptsReportPeriodButton extends StatelessWidget {
  final ThemeProvider theme;
  final ReceiptsReportPeriod period;
  final bool enabled;
  final ValueChanged<ReceiptsReportPeriod> onChanged;

  const ReceiptsReportPeriodButton({
    super.key,
    required this.theme,
    required this.period,
    required this.enabled,
    required this.onChanged,
  });

  void _pickDate(BuildContext context) {
    mainDatePicker(
      context: context,
      theme: theme,
      singleDate: (date) {
        if (date == null) return;
        onChanged(ReceiptsReportPeriod.day(date));
      },
      rangeDate: (firstDate, lastDate) {
        if (firstDate == null) return;
        onChanged(
          ReceiptsReportPeriod.range(
            firstDate,
            lastDate ?? firstDate,
          ),
        );
      },
    );
  }

  PopupMenuItem<int> _item(
    int value,
    String text,
    bool selected,
  ) {
    return PopupMenuItem<int>(
      value: value,
      child: Text(
        text,
        style: TextStyle(
          fontSize: theme.mobileTexts.b3.fontSize,
          fontWeight: selected ? FontWeight.bold : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isToday = receiptsPeriodIsToday(period);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 5.0),
          child: PopupMenuButton<int>(
            enabled: enabled,
            tooltip:
                enabled
                    ? 'Change period'
                    : 'You can only view today',
            offset: const Offset(0, 42),
            color: Colors.white,
            onSelected: (choice) {
              switch (choice) {
                case 0:
                  onChanged(ReceiptsReportPeriod.today());
                  break;
                case 1:
                  _pickDate(context);
                  break;
                case 2:
                  onChanged(
                    const ReceiptsReportPeriod.allTime(),
                  );
                  break;
              }
            },
            itemBuilder:
                (context) => [
                  _item(0, 'Today', isToday),
                  _item(
                    1,
                    'Pick a date or range',
                    !isToday && !period.isAllTime,
                  ),
                  _item(2, 'All time', period.isAllTime),
                ],
            child: ReportPill(
              theme: theme,
              icon: Icons.event_rounded,
              label: 'Date: ${receiptsPeriodLabel(period)}',
              highlighted: !isToday,
            ),
          ),
        ),
        if (!isToday && enabled)
          Padding(
            padding: const EdgeInsets.only(right: 5.0),
            child: ReportPill(
              theme: theme,
              icon: Icons.close,
              label: 'Today',
              onTap:
                  () => onChanged(
                    ReceiptsReportPeriod.today(),
                  ),
            ),
          ),
      ],
    );
  }
}

/// Staff, Customer, Sub-Staff, Department, Channel and Type
/// dropdowns, for a filter panel's Wrap. Each change goes through
/// [onApply].
List<Widget> receiptsKeyFilterFields({
  required ThemeProvider theme,
  required ReceiptsReportFilters filters,
  required ReceiptsFilterChoices choices,
  required bool departmentsEnabled,
  required bool subStaffEnabled,
  required void Function(VoidCallback change) onApply,
}) {
  Widget keyDropdown({
    required String title,
    required String allLabel,
    required String? value,
    required List<ReceiptsFilterOption> options,
    required ValueChanged<String?> onChanged,
  }) {
    return ReportLabeledField(
      label: title,
      width: 220,
      child: ReportSearchableDropdown<String?>(
        title: title,
        value: value,
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
      title: 'Staff',
      allLabel: 'All staff',
      value: filters.staffKey,
      options: choices.staff,
      onChanged: (v) => filters.staffKey = v,
    ),
    keyDropdown(
      title: 'Customer',
      allLabel: 'All customers',
      value: filters.customerKey,
      options: choices.customers,
      onChanged: (v) => filters.customerKey = v,
    ),
    if (subStaffEnabled)
      keyDropdown(
        title: 'Sub-Staff',
        allLabel: 'All sub-staff',
        value: filters.subStaffKey,
        options: choices.subStaff,
        onChanged: (v) => filters.subStaffKey = v,
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
      label: 'Channel',
      width: 180,
      child: ReportSearchableDropdown<ReceiptChannel?>(
        title: 'Channel',
        value: filters.channel,
        showSearch: false,
        options: [
          const ReportSearchableOption(
            value: null,
            label: 'All channels',
          ),
          ...ReceiptChannel.values.map(
            (c) => ReportSearchableOption<ReceiptChannel?>(
              value: c,
              label: c.label,
            ),
          ),
        ],
        onChanged:
            (v) => onApply(() => filters.channel = v),
        theme: theme,
      ),
    ),
    ReportLabeledField(
      label: 'Type',
      width: 180,
      child: ReportSearchableDropdown<ReceiptType?>(
        title: 'Type',
        value: filters.type,
        showSearch: false,
        options: [
          const ReportSearchableOption(
            value: null,
            label: 'All types',
          ),
          ...ReceiptType.values.map(
            (t) => ReportSearchableOption<ReceiptType?>(
              value: t,
              label: t.label,
            ),
          ),
        ],
        onChanged: (v) => onApply(() => filters.type = v),
        theme: theme,
      ),
    ),
  ];
}

/// Removable chips for every active filter. With [showSearch] the
/// search text is a chip too (for pages without a search box).
class ReceiptsReportFilterChips extends StatelessWidget {
  final ThemeProvider theme;
  final ReceiptsReportFilters filters;
  final ReceiptsFilterChoices choices;
  final bool departmentsEnabled;
  final bool subStaffEnabled;
  final bool profitVisible;
  final bool showSearch;
  final String Function(num value) money;
  final void Function(VoidCallback change) onApply;

  const ReceiptsReportFilterChips({
    super.key,
    required this.theme,
    required this.filters,
    required this.choices,
    required this.departmentsEnabled,
    required this.subStaffEnabled,
    required this.profitVisible,
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
      List<ReceiptsFilterOption> options,
      VoidCallback clear,
    ) {
      if (key == null) return;
      chip(
        '$title: ${ReceiptsFilterChoices.labelFor(options, key, title)}',
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
      'Staff',
      filters.staffKey,
      choices.staff,
      () => filters.staffKey = null,
    );
    keyChip(
      'Customer',
      filters.customerKey,
      choices.customers,
      () => filters.customerKey = null,
    );
    if (subStaffEnabled) {
      keyChip(
        'Sub-Staff',
        filters.subStaffKey,
        choices.subStaff,
        () => filters.subStaffKey = null,
      );
    }
    if (departmentsEnabled) {
      keyChip(
        'Department',
        filters.departmentKey,
        choices.departments,
        () => filters.departmentKey = null,
      );
    }
    if (filters.channel != null) {
      chip(
        'Channel: ${filters.channel!.label}',
        () => filters.channel = null,
      );
    }
    if (filters.type != null) {
      chip(
        'Type: ${filters.type!.label}',
        () => filters.type = null,
      );
    }
    if (filters.revenueMin != null ||
        filters.revenueMax != null) {
      chip(
        'Revenue: ${range(filters.revenueMin, filters.revenueMax)}',
        () {
          filters.revenueMin = null;
          filters.revenueMax = null;
        },
      );
    }
    if (profitVisible &&
        (filters.profitMin != null ||
            filters.profitMax != null)) {
      chip(
        'Profit/Loss: ${range(filters.profitMin, filters.profitMax)}',
        () {
          filters.profitMin = null;
          filters.profitMax = null;
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
