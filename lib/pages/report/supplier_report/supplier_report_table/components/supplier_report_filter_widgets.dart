import 'package:flutter/material.dart';
import 'package:stockall/pages/report/components/report_pill.dart';
import 'package:stockall/pages/report/components/report_range_fields.dart';
import 'package:stockall/pages/report/components/report_searchable_dropdown.dart';
import 'package:stockall/pages/report/purchase_report/purchase_report_table/class/purchase_report_table_logic.dart';
import 'package:stockall/pages/report/purchase_report/purchase_report_table/components/purchase_report_filter_widgets.dart';
import 'package:stockall/pages/report/supplier_report/supplier_report_table/class/supplier_report_table_logic.dart';
import 'package:stockall/providers/theme_provider.dart';

const String supplierHasBalanceLabel = 'Has balance owed';

/// Country, State (narrowed to the chosen country) and "Has
/// balance owed", for a filter panel's Wrap. Each change goes
/// through [onApply].
List<Widget> supplierFilterFields({
  required ThemeProvider theme,
  required SupplierReportFilters filters,
  required List<SupplierReportRow> rows,
  required void Function(VoidCallback change) onApply,
}) {
  Widget dropdown({
    required String title,
    required String allLabel,
    required String? value,
    required List<PurchaseFilterOption> options,
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
    dropdown(
      title: 'Country',
      allLabel: 'All countries',
      value: filters.countryKey,
      options: SupplierReportOptions.countries(rows),
      onChanged: (v) => filters.setCountry(v, rows),
    ),
    dropdown(
      title: 'State',
      allLabel: 'All states',
      value: filters.stateKey,
      options: SupplierReportOptions.states(
        rows,
        countryKey: filters.countryKey,
      ),
      onChanged: (v) => filters.stateKey = v,
    ),
    ReportLabeledField(
      label: 'Balance',
      width: 260,
      child: Align(
        alignment: Alignment.centerLeft,
        child: ReportPill(
          key: const ValueKey('supplier-has-balance'),
          theme: theme,
          icon:
              filters.hasBalance
                  ? Icons.check_box_rounded
                  : Icons.check_box_outline_blank_rounded,
          label: supplierHasBalanceLabel,
          highlighted: filters.hasBalance,
          onTap:
              () => onApply(
                () => filters.hasBalance = !filters.hasBalance,
              ),
        ),
      ),
    ),
  ];
}

/// Removable chips for the active filters.
class SupplierReportFilterChips extends StatelessWidget {
  final ThemeProvider theme;
  final SupplierReportFilters filters;
  final List<SupplierReportRow> rows;
  final void Function(VoidCallback change) onApply;

  const SupplierReportFilterChips({
    super.key,
    required this.theme,
    required this.filters,
    required this.rows,
    required this.onApply,
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

    if (filters.countryKey != null) {
      final label = PurchaseFilterChoices.labelFor(
        SupplierReportOptions.countries(rows),
        filters.countryKey!,
        'Country',
      );
      chip('Country: $label', () => filters.countryKey = null);
    }
    if (filters.stateKey != null) {
      final label = PurchaseFilterChoices.labelFor(
        SupplierReportOptions.states(rows),
        filters.stateKey!,
        'State',
      );
      chip('State: $label', () => filters.stateKey = null);
    }
    if (filters.hasBalance) {
      chip(
        supplierHasBalanceLabel,
        () => filters.hasBalance = false,
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
