import 'package:flutter/material.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/pages/report/components/report_range_fields.dart';
import 'package:stockall/pages/report/components/report_searchable_dropdown.dart';
import 'package:stockall/pages/report/item_sales_report_main/class/item_sales_report_logic.dart';
import 'package:stockall/pages/report/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/receipts_report_main/components/receipts_report_filter_widgets.dart';
import 'package:stockall/providers/theme_provider.dart';

// Item-level filter fields and chips. The receipt-level ones
// (staff, customer, ...) are the Receipts Report's own widgets.

/// Category, Item, Void, Custom Price and Wholesale dropdowns, for
/// a filter panel's Wrap. Each change goes through [onApply].
List<Widget> itemSalesFilterFields({
  required ThemeProvider theme,
  required ItemSalesFilters filters,
  required List<ReceiptsFilterOption> categoryOptions,
  required List<ReceiptsFilterOption> itemOptions,
  required List<ItemSalesRow> rows,
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

  Widget yesNo({
    required String title,
    required bool? value,
    required ValueChanged<bool?> onChanged,
  }) {
    return ReportLabeledField(
      label: title,
      width: 150,
      child: ReportSearchableDropdown<bool?>(
        title: title,
        value: value,
        showSearch: false,
        options: const [
          ReportSearchableOption(value: null, label: 'Any'),
          ReportSearchableOption(value: true, label: 'Yes'),
          ReportSearchableOption(value: false, label: 'No'),
        ],
        onChanged: (v) => onApply(() => onChanged(v)),
        theme: theme,
      ),
    );
  }

  return [
    keyDropdown(
      title: 'Category',
      allLabel: 'All categories',
      value: filters.categoryKey,
      options: categoryOptions,
      onChanged: (v) => filters.setCategory(v, rows),
    ),
    keyDropdown(
      title: 'Item',
      allLabel:
          filters.categoryKey == null
              ? 'All items'
              : 'All items in category',
      value: filters.productKey,
      options: itemOptions,
      onChanged: (v) => filters.productKey = v,
    ),
    ReportLabeledField(
      label: 'Void',
      width: 150,
      child: ReportSearchableDropdown<ItemSalesVoidFilter>(
        title: 'Void',
        value: filters.voidFilter,
        showSearch: false,
        highlighted:
            filters.voidFilter != ItemSalesVoidFilter.notVoid,
        options: [
          for (final v in ItemSalesVoidFilter.values)
            ReportSearchableOption(value: v, label: v.label),
        ],
        onChanged:
            (v) => onApply(() => filters.voidFilter = v),
        theme: theme,
      ),
    ),
    yesNo(
      title: 'Custom Price',
      value: filters.customPrice,
      onChanged: (v) => filters.customPrice = v,
    ),
    yesNo(
      title: 'Wholesale Price',
      value: filters.wholesale,
      onChanged: (v) => filters.wholesale = v,
    ),
  ];
}

/// Removable chips for the item-level filters.
class ItemSalesFilterChips extends StatelessWidget {
  final ThemeProvider theme;
  final ItemSalesFilters filters;
  final List<ReceiptsFilterOption> categoryOptions;

  /// Every item, not only those of the selected category, so a
  /// chip always finds its label.
  final List<ReceiptsFilterOption> itemOptions;
  final void Function(VoidCallback change) onApply;

  const ItemSalesFilterChips({
    super.key,
    required this.theme,
    required this.filters,
    required this.categoryOptions,
    required this.itemOptions,
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

    String yesNo(bool v) => v ? 'Yes' : 'No';
    String number(double? v) =>
        v == null ? 'Any' : formatDimension(v);

    final category = filters.categoryKey;
    if (category != null) {
      chip(
        'Category: ${ReceiptsFilterChoices.labelFor(categoryOptions, category, 'Category')}',
        () => filters.categoryKey = null,
      );
    }
    final item = filters.productKey;
    if (item != null) {
      chip(
        'Item: ${ReceiptsFilterChoices.labelFor(itemOptions, item, 'Item')}',
        () => filters.productKey = null,
      );
    }
    if (filters.voidFilter != ItemSalesVoidFilter.notVoid) {
      chip(
        'Void: ${filters.voidFilter.label}',
        () => filters.voidFilter = ItemSalesVoidFilter.notVoid,
      );
    }
    if (filters.customPrice != null) {
      chip(
        'Custom Price: ${yesNo(filters.customPrice!)}',
        () => filters.customPrice = null,
      );
    }
    if (filters.wholesale != null) {
      chip(
        'Wholesale Price: ${yesNo(filters.wholesale!)}',
        () => filters.wholesale = null,
      );
    }
    if (filters.quantitySet) {
      chip(
        'Quantity: ${number(filters.quantityMin)} - ${number(filters.quantityMax)}',
        () {
          filters.quantityMin = null;
          filters.quantityMax = null;
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
