// Pieces shared by the stock table views: the column type, the table
// frame (sticky header, rows, totals row, both scrollbars), text cells,
// the notes line, the app bar with Refresh, and the search box with the
// mobile "View" toggle. Same look as the Production Records table.

import 'package:flutter/material.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/pages/report/general_report/class/general_report_export_spec.dart'
    show generalReportChangeText;
import 'package:stockall/pages/report/production_report/stock_shared/class/stock_analysis_logic.dart';
import 'package:stockall/providers/theme_provider.dart';

/// "****" for quantities the user can't see.
const String productionMasked = '****';

/// One table column. [sortKey] is any value the view compares with its
/// current sort; null makes the column not sortable.
class StockCol<R, T> {
  final String label;
  final double width;
  final Object? sortKey;
  final TextAlign align;
  final Widget Function(R row) cell;
  final Widget Function(T totals)? total;

  const StockCol({
    required this.label,
    required this.width,
    required this.cell,
    this.sortKey,
    this.align = TextAlign.center,
    this.total,
  });
}

TextStyle stockCellStyle(ThemeProvider theme, {bool bold = false, Color? color}) =>
    TextStyle(
      fontSize: theme.mobileTexts.b3.fontSize,
      fontWeight: bold ? FontWeight.bold : FontWeight.w500,
      color: color ?? Colors.black87,
    );

Widget stockTxt(
  ThemeProvider theme,
  String text, {
  bool bold = false,
  Color? color,
  TextAlign? align,
  String? tooltip,
  int maxLines = 2,
}) {
  final t = Text(
    text,
    maxLines: maxLines,
    overflow: TextOverflow.ellipsis,
    textAlign: align,
    style: stockCellStyle(theme, bold: bold, color: color),
  );
  return tooltip == null ? t : Tooltip(message: tooltip, child: t);
}

Widget stockDash(ThemeProvider theme) => stockTxt(theme, '—', color: Colors.grey);

Alignment _alignment(TextAlign a) =>
    a == TextAlign.start
        ? Alignment.centerLeft
        : (a == TextAlign.end ? Alignment.centerRight : Alignment.center);

/// The table: header with sortable labels, a scrolling list of rows and
/// the totals row. Wider than the screen, it scrolls sideways.
class StockTableFrame<R, T> extends StatefulWidget {
  final ThemeProvider theme;
  final List<StockCol<R, T>> cols;
  final List<R> rows;
  final T? totals;
  final Object? sortKey;
  final bool ascending;
  final void Function(Object sortKey) onSort;
  final void Function(R row)? onTap;
  final Key Function(R row)? rowKey;

  const StockTableFrame({
    super.key,
    required this.theme,
    required this.cols,
    required this.rows,
    required this.totals,
    required this.sortKey,
    required this.ascending,
    required this.onSort,
    this.onTap,
    this.rowKey,
  });

  @override
  State<StockTableFrame<R, T>> createState() => _StockTableFrameState<R, T>();
}

class _StockTableFrameState<R, T> extends State<StockTableFrame<R, T>> {
  final _h = ScrollController();
  final _v = ScrollController();

  @override
  void dispose() {
    _h.dispose();
    _v.dispose();
    super.dispose();
  }

  Widget _cells(Widget Function(StockCol<R, T> c) cell) {
    return Row(
      children: [
        for (final c in widget.cols)
          SizedBox(
            width: c.width,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Align(alignment: _alignment(c.align), child: cell(c)),
            ),
          ),
      ],
    );
  }

  Widget _header(StockCol<R, T> c) {
    final theme = widget.theme;
    final accent = theme.lightModeColor.prColor300;
    final sortable = c.sortKey != null;
    final sorted = sortable && c.sortKey == widget.sortKey;
    final content = Row(
      mainAxisAlignment:
          c.align == TextAlign.start
              ? MainAxisAlignment.start
              : MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      spacing: 3,
      children: [
        Flexible(
          child: Text(
            c.label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: c.align,
            style: TextStyle(
              fontSize: theme.mobileTexts.b3.fontSize,
              fontWeight: FontWeight.bold,
              color: sorted ? accent : Colors.black87,
            ),
          ),
        ),
        if (sortable)
          Icon(
            sorted
                ? (widget.ascending
                    ? Icons.arrow_upward_rounded
                    : Icons.arrow_downward_rounded)
                : Icons.unfold_more_rounded,
            size: 14,
            color: sorted ? accent : Colors.grey,
          ),
      ],
    );
    final padded = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Align(alignment: _alignment(c.align), child: content),
    );
    return SizedBox(
      width: c.width,
      child:
          !sortable
              ? padded
              : InkWell(
                mouseCursor: SystemMouseCursors.click,
                onTap: () => widget.onSort(c.sortKey!),
                child: padded,
              ),
    );
  }

  Widget _row(R r, int i) {
    final theme = widget.theme;
    final body = Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: _cells((c) => c.cell(r)),
    );
    final tap = widget.onTap;
    return Material(
      key: widget.rowKey?.call(r),
      color: i.isEven ? Colors.white : Colors.grey.shade50,
      child:
          tap == null
              ? body
              : InkWell(
                mouseCursor: SystemMouseCursors.click,
                hoverColor: theme.lightModeColor.prColor300.withAlpha(20),
                onTap: () => tap(r),
                child: body,
              ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final totalWidth = widget.cols.fold<double>(0, (s, c) => s + c.width);
    final totals = widget.totals;
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 12)],
        ),
        clipBehavior: Clip.antiAlias,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w =
                totalWidth > constraints.maxWidth ? totalWidth : constraints.maxWidth;
            return Scrollbar(
              controller: _v,
              thumbVisibility: true,
              notificationPredicate: (n) => n.metrics.axis == Axis.vertical,
              child: Scrollbar(
                controller: _h,
                thumbVisibility: true,
                notificationPredicate: (n) => n.metrics.axis == Axis.horizontal,
                child: SingleChildScrollView(
                  controller: _h,
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: w,
                    height: constraints.maxHeight,
                    child: Column(
                      children: [
                        Container(
                          height: 48,
                          color: theme.lightModeColor.prColor300.withAlpha(22),
                          child: Row(children: [for (final c in widget.cols) _header(c)]),
                        ),
                        const Divider(height: 1),
                        Expanded(
                          child: ScrollConfiguration(
                            behavior: ScrollConfiguration.of(
                              context,
                            ).copyWith(scrollbars: false),
                            child: ListView.builder(
                              controller: _v,
                              itemCount: widget.rows.length,
                              itemExtent: 52,
                              itemBuilder: (context, i) => _row(widget.rows[i], i),
                            ),
                          ),
                        ),
                        if (totals != null) ...[
                          const Divider(height: 1, thickness: 1),
                          Container(
                            height: 46,
                            color: theme.lightModeColor.prColor300.withAlpha(25),
                            child: _cells(
                              (c) => c.total?.call(totals) ?? const SizedBox.shrink(),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// The notes line under the toolbar.
Widget stockNotes(List<String> notes) {
  if (notes.isEmpty) return const SizedBox.shrink();
  return Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          Icon(Icons.info_outline_rounded, size: 13, color: Colors.grey.shade600),
          Flexible(
            child: Text(
              notes.join('\n'),
              style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
            ),
          ),
        ],
      ),
    ),
  );
}

/// The app bar with the Refresh button of the report pages.
PreferredSizeWidget stockAppBar(
  BuildContext context,
  ThemeProvider theme, {
  required String title,
  required bool loading,
  required VoidCallback onRefresh,
}) {
  return appBar(
    context: context,
    title: title,
    widget: Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          mouseCursor: SystemMouseCursors.click,
          borderRadius: BorderRadius.circular(10),
          onTap: loading ? null : onRefresh,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 5,
              children: [
                Text(
                  'Refresh',
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b3.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Icon(Icons.refresh_rounded, size: 18),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

/// "The report could not be generated." with Try again.
Widget stockErrorView(ThemeProvider theme, VoidCallback onRetry) {
  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 10,
      children: [
        Icon(
          Icons.error_outline_rounded,
          size: 40,
          color: theme.lightModeColor.errorColor200,
        ),
        Text(
          'The report could not be generated.',
          style: TextStyle(
            fontSize: theme.mobileTexts.b2.fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        OutlinedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Try again'),
        ),
      ],
    ),
  );
}

/// The empty table, with "Clear all filters" when filters are on.
Widget stockEmptyView(
  ThemeProvider theme, {
  required bool hasFilters,
  required String filteredText,
  required String emptyText,
  required VoidCallback onReset,
}) {
  return Padding(
    padding: const EdgeInsets.only(top: 60),
    child: EmptyWidgetDisplayOnly(
      title: hasFilters ? 'No Matching Records' : 'Empty List',
      subText: hasFilters ? filteredText : emptyText,
      theme: theme,
      height: 35,
      icon: Icons.clear,
      altAction: hasFilters ? onReset : null,
      altActionText: hasFilters ? 'Clear all filters' : null,
      altIcon: hasFilters ? Icons.filter_alt_off : null,
    ),
  );
}

/// The search box; below [mobileScreen] it carries the View / Hide
/// toggle of the rest of the toolbar.
Widget stockSearchBox(
  BuildContext context,
  ThemeProvider theme, {
  required bool isDesktop,
  required TextEditingController controller,
  required String hint,
  required ValueChanged<String> onChanged,
  required bool toolbarOpen,
  required VoidCallback onToggleToolbar,
}) {
  return Padding(
    padding: const EdgeInsets.only(right: 6.0),
    child: SizedBox(
      width: isDesktop ? 320 : double.infinity,
      height: 38,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(fontSize: theme.mobileTexts.b3.fontSize),
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon:
                    controller.text.isEmpty
                        ? null
                        : IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () {
                            controller.clear();
                            onChanged('');
                          },
                        ),
                contentPadding: EdgeInsets.zero,
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          if (screenWidth(context) < mobileScreen) ...[
            const SizedBox(width: 5),
            InkWell(
              onTap: onToggleToolbar,
              mouseCursor: SystemMouseCursors.click,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10.0, 6, 6, 6),
                child: Row(
                  spacing: 1,
                  children: [
                    Text(
                      style: TextStyle(fontSize: theme.mobileTexts.b4.fontSize),
                      toolbarOpen ? 'Hide' : 'View',
                    ),
                    Icon(
                      toolbarOpen
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

/// Whether the rest of the toolbar shows: always above [mobileScreen].
bool stockToolbarVisible(BuildContext context, bool open) =>
    open || screenWidth(context) > mobileScreen;

/// A grey removable chip, as on the other report tables.
Widget stockChip(
  ThemeProvider theme,
  String text,
  VoidCallback onDeleted,
) {
  return InputChip(
    label: Text(text, style: const TextStyle(fontSize: 10)),
    onDeleted: onDeleted,
    deleteIcon: const Icon(Icons.close, size: 12),
    visualDensity: VisualDensity.compact,
    backgroundColor: theme.lightModeColor.prColor300.withAlpha(25),
    side: BorderSide.none,
  );
}

/// Chips for (label, value, clear) entries.
Widget stockChips(
  ThemeProvider theme,
  List<(String, String, VoidCallback)> entries,
  void Function(VoidCallback change) onApply,
) {
  if (entries.isEmpty) return const SizedBox.shrink();
  return Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        children: [
          for (final (label, value, clear) in entries)
            stockChip(theme, '$label: $value', () => onApply(clear)),
        ],
      ),
    ),
  );
}

/// The headline cards of the analysis and the history summary: four a
/// row on desktop, two on mobile. [onTap] opens what a card counts.
class StockKpiGrid extends StatelessWidget {
  final ThemeProvider theme;
  final bool isDesktop;
  final List<ProductionStockCard> cards;
  final String Function(num) money;
  final String Function(num) number;
  final String keyPrefix;
  final void Function(ProductionStockCard card)? onTap;

  const StockKpiGrid({
    super.key,
    required this.theme,
    required this.isDesktop,
    required this.cards,
    required this.money,
    required this.number,
    required this.keyPrefix,
    this.onTap,
  });

  Widget _card(BuildContext context, ProductionStockCard c) {
    final change = c.masked ? null : c.change;
    final changeText =
        change == null
            ? null
            : generalReportChangeText(
              change,
              c.kind == ProductionStockCardKind.money ? money : number,
            );
    final color =
        change == null
            ? Colors.grey.shade600
            : change.isUp
            ? Colors.green.shade700
            : change.isDown
            ? Colors.orange.shade800
            : Colors.grey.shade600;
    final body = Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            c.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: theme.mobileTexts.b4.fontSize,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              c.valueText(money, number),
              style: TextStyle(
                fontSize: theme.mobileTexts.b1.fontSize,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Text(
            changeText ?? c.subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: theme.mobileTexts.b4.fontSize,
              color: changeText == null ? Colors.grey.shade500 : color,
              fontWeight: changeText == null ? null : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
    final tap = onTap;
    return InkWell(
      key: ValueKey('$keyPrefix-kpi-${c.id}'),
      onTap: tap == null ? null : () => tap(c),
      borderRadius: BorderRadius.circular(8),
      child: body,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 10.0;
        final perRow = isDesktop ? 4 : 2;
        final width = (constraints.maxWidth - spacing * (perRow - 1)) / perRow;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final c in cards) SizedBox(width: width, child: _card(context, c)),
          ],
        );
      },
    );
  }
}
