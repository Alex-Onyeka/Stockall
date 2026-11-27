import 'package:flutter/material.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/report/components/export/report_export_button.dart';
import 'package:stockall/pages/report/components/export/report_export_format.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/report_trend_chart.dart';
import 'package:stockall/pages/report/general_report/class/general_report_export_spec.dart'
    show generalReportChangeText;
import 'package:stockall/pages/report/production_report/production_records_table/class/production_records_table_logic.dart';
import 'package:stockall/pages/report/production_report/production_records_table/components/production_records_table_view.dart';
import 'package:stockall/pages/report/production_report/production_records_table/production_records_table_page.dart';
import 'package:stockall/pages/report/production_report/production_summary/class/production_summary_export_spec.dart';
import 'package:stockall/pages/report/production_report/production_summary/class/production_summary_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/components/receipts_report_filter_widgets.dart';
import 'package:stockall/providers/theme_provider.dart';

/// Shared body of the Production Summary page (desktop + mobile).
class ProductionSummaryView extends StatefulWidget {
  final bool isDesktop;
  final ReceiptsReportPeriod? initialPeriod;

  /// Null in the app: [ProductionRecordsEnv.live] is used.
  final ProductionRecordsEnv? env;

  const ProductionSummaryView({
    super.key,
    required this.isDesktop,
    this.initialPeriod,
    this.env,
  });

  @override
  State<ProductionSummaryView> createState() =>
      _ProductionSummaryViewState();
}

class _ProductionSummaryViewState
    extends State<ProductionSummaryView> {
  late final ProductionRecordsEnv _env;
  late ReceiptsReportPeriod _period;
  ProductionBreakdownTab _tab =
      ProductionBreakdownTab.outputItems;

  /// Null: the built order.
  ProductionBreakdownField? _sortField;
  bool _ascending = false;

  bool _loading = true;
  String? _error;
  ProductionSummaryResult? _result;
  String _signature = '';

  /// The summary has no filters of its own.
  final ProductionRecordsFilters _base =
      ProductionRecordsFilters();

  static const Color _recordedColor = Color(0xFF2563EB);
  static const Color _materialColor = Color(0xFF059669);

  @override
  void initState() {
    super.initState();
    _env = widget.env ?? ProductionRecordsEnv.live();
    _period =
        widget.initialPeriod ??
        ReceiptsReportPeriod.today();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load(refreshFromStore: true);
    });
  }

  // ---------------------------------------------------------------
  // data
  // ---------------------------------------------------------------

  bool get _departmentsEnabled => _env.departmentsEnabled();
  bool get _canSeeCost => _env.canSeeCost();
  bool get _canSeeQuantity => _env.canSeeQuantity();

  Future<void> _load({
    required bool refreshFromStore,
  }) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _env.loadWithPeriod(
        context,
        refreshFromStore: refreshFromStore,
        period: _period,
      );
      _rebuild();
      if (mounted) setState(() => _loading = false);
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString();
        });
      }
    }
  }

  void _rebuild() {
    final rows = ProductionRecordRowBuilder.buildAll(
      records: _env.records(),
      manageProductionItems: _env.manageProductionItems(),
      pendingDeletedUuids: _env.pendingDeletedUuids(),
    );
    _result = ProductionSummaryBuilder.build(
      rows: rows,
      period: _period,
      departmentsEnabled: _departmentsEnabled,
      canSeeCost: _canSeeCost,
      canSeeQuantity: _canSeeQuantity,
    );
    _signature = _env.signature();
  }

  void _setPeriod(ReceiptsReportPeriod p) {
    setState(() {
      _period = p;
      try {
        _rebuild();
        _error = null;
      } catch (e) {
        _error = e.toString();
      }
    });
    if (!p.isAllTime) {
      _load(refreshFromStore: false);
    }
  }

  Future<void> _pushTable(
    BuildContext context,
    ProductionRecordsFilters filters,
    ReceiptsReportPeriod period,
  ) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ProductionRecordsTablePage(
              initialFilters: filters,
              initialPeriod: period,
            ),
      ),
    );
  }

  /// One-way: the table opens on the row's records and period.
  Future<void> _openTable(
    ProductionRecordsFilters filters,
  ) async {
    final open = _env.openTable ?? _pushTable;
    await open(context, filters, _period);
    // Picks up edits or deletes made from the table.
    if (mounted) {
      setState(() {
        try {
          _rebuild();
          _error = null;
        } catch (e) {
          _error = e.toString();
        }
      });
    }
  }

  void _openAll() => _openTable(_base.copy());

  // ---------------------------------------------------------------
  // formatting
  // ---------------------------------------------------------------

  String _money(num v) => _env.money(context, v);
  String _number(num v) =>
      formatLargeNumberDouble(v.toDouble());

  List<ProductionBreakdownTab> get _tabs =>
      productionBreakdownTabs(
        departmentsEnabled: _departmentsEnabled,
        canSeeQuantity: _canSeeQuantity,
      );

  ReportExportSpec _exportSpec() {
    final tabs = _tabs;
    return productionSummaryExportSpec(
      result: _result!,
      period: _period,
      tabs: tabs,
      activeTab: tabs.contains(_tab) ? _tab : tabs.first,
      sortField: _sortField,
      ascending: _ascending,
      currency: currencySymbol(context: context),
      canSeeCost: _canSeeCost,
      canSeeQuantity: _canSeeQuantity,
    );
  }

  /// The screen's cell text: the export's, with the screen's money and
  /// number formats.
  String _cellText(
    ProductionBreakdownRow r,
    ProductionBreakdownColumn c,
  ) {
    final v = r.valueOf(c.field);
    if (v == null) return '—';
    final unit = r.unitOf(c.field);
    String withUnit(String s) =>
        unit == null ? s : '$s $unit';
    switch (c.kind) {
      case ProductionBreakdownKind.text:
        return v as String;
      case ProductionBreakdownKind.count:
        return '$v';
      case ProductionBreakdownKind.quantity:
        return withUnit(_number(v as num));
      case ProductionBreakdownKind.ratio:
        return withUnit(
          productionRatioText(
            (v as num).toDouble(),
            _number,
          ),
        );
      case ProductionBreakdownKind.money:
        return _money(v as num);
      case ProductionBreakdownKind.date:
        return formatDateTime(v as DateTime);
      case ProductionBreakdownKind.percent:
        return ExportFormatter(
          currency: '',
        ).percent(v as num);
    }
  }

  BoxDecoration get _card => BoxDecoration(
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
  );

  Widget _title(
    ThemeProvider theme,
    String text,
    String sub,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: theme.mobileTexts.b1.fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          sub,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: theme.mobileTexts.b4.fontSize,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  Widget _emptyText(ThemeProvider theme, String text) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: theme.mobileTexts.b3.fontSize,
            color: Colors.grey.shade500,
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------
  // build
  // ---------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = returnTheme(context);
    // Listen, so new, edited and synced records update the summary.
    _env.listen(context);

    if (!_loading && _error == null) {
      final sig = _env.signature();
      if (sig != _signature) {
        try {
          _rebuild();
        } catch (e) {
          _error = e.toString();
        }
      }
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(
        255,
        252,
        253,
        255,
      ),
      appBar: appBar(
        context: context,
        title: 'Production Summary',
        widget: Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              mouseCursor: SystemMouseCursors.click,
              borderRadius: BorderRadius.circular(10),
              onTap:
                  _loading
                      ? null
                      : () => _load(refreshFromStore: true),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 5,
                  children: [
                    Text(
                      'Refresh',
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b3.fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Icon(
                      Icons.refresh_rounded,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: _body(theme),
    );
  }

  Widget _body(ThemeProvider theme) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    final result = _result;
    if (_error != null || result == null) {
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
              'The summary could not be generated.',
              style: TextStyle(
                fontSize: theme.mobileTexts.b2.fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            OutlinedButton.icon(
              onPressed:
                  () => _load(refreshFromStore: false),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
            ),
          ],
        ),
      );
    }
    final notes = productionRecordsNotes(
      period: _period,
      rows: result.rows,
      canSeeCost: _canSeeCost,
    );
    final gap = SizedBox(
      height: widget.isDesktop ? 16 : 12,
    );
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: widget.isDesktop ? 20 : 12,
        vertical: 10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ReceiptsReportPeriodButton(
                  theme: theme,
                  period: _period,
                  enabled: _env.canPickDate(),
                  onChanged: _setPeriod,
                ),
                ReportExportButton(
                  showRollWidthEntries: false,
                  buildSpec: _exportSpec,
                ),
              ],
            ),
          ),
          if (notes.isNotEmpty) _note(notes),
          gap,
          _kpis(theme, result),
          gap,
          _trendCard(theme, result),
          gap,
          _breakdown(theme, result),
          gap,
        ],
      ),
    );
  }

  Widget _note(List<String> notes) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 13,
            color: Colors.grey.shade600,
          ),
          Flexible(
            child: Text(
              notes.join('\n'),
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------
  // KPIs
  // ---------------------------------------------------------------

  static const Map<String, (IconData, Color)> _cardStyle = {
    'runs': (
      Icons.precision_manufacturing_outlined,
      Color(0xFF7E22CE),
    ),
    'recordedCost': (
      Icons.receipt_long_rounded,
      _recordedColor,
    ),
    'materialCost': (
      Icons.inventory_2_outlined,
      _materialColor,
    ),
    'averageCost': (
      Icons.functions_rounded,
      Color(0xFF0891B2),
    ),
    'variance': (
      Icons.compare_arrows_rounded,
      Color(0xFFD97706),
    ),
    'outputs': (
      Icons.bakery_dining_outlined,
      Color(0xFFDB2777),
    ),
    'materials': (Icons.grain_rounded, Color(0xFF65A30D)),
    'staff': (
      Icons.people_outline_rounded,
      Color(0xFF64748B),
    ),
  };

  Widget _kpis(
    ThemeProvider theme,
    ProductionSummaryResult r,
  ) {
    final cards = [
      for (final c in productionSummaryCards(
        r,
        canSeeCost: _canSeeCost,
      ))
        _kpi(theme, c),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 10.0;
        final perRow = widget.isDesktop ? 4 : 2;
        final width =
            (constraints.maxWidth -
                spacing * (perRow - 1)) /
            perRow;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final c in cards)
              SizedBox(width: width, child: c),
          ],
        );
      },
    );
  }

  Widget _kpi(
    ThemeProvider theme,
    ProductionSummaryCard c,
  ) {
    final (icon, color) =
        _cardStyle[c.id] ??
        (Icons.info_outline, Colors.grey);
    final change = c.change;
    final changeText =
        change == null
            ? null
            : generalReportChangeText(
              change,
              c.isMoney ? _money : (v) => _number(v),
            );
    // Costs going up is not good news; runs and items going up is.
    final up = change?.isUp == true;
    final down = change?.isDown == true;
    final costCard = c.isMoney;
    final changeColor =
        (up && !costCard) || (down && costCard)
            ? Colors.green.shade700
            : (up || down)
            ? Colors.orange.shade800
            : Colors.grey.shade600;
    return InkWell(
      key: ValueKey('production-kpi-${c.id}'),
      onTap: _openAll,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: _card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              spacing: 8,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: color.withAlpha(25),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(icon, size: 16, color: color),
                ),
                Expanded(
                  child: Text(
                    c.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.b4.fontSize,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                c.isMoney
                    ? _money(c.value)
                    : _number(c.value),
                style: TextStyle(
                  fontSize: theme.mobileTexts.b1.fontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            if (changeText != null)
              Text(
                changeText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: theme.mobileTexts.b4.fontSize,
                  color: changeColor,
                  fontWeight: FontWeight.w600,
                ),
              )
            else if (screenWidth(context) > mobileScreen)
              Text(
                c.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: theme.mobileTexts.b4.fontSize,
                  color: Colors.grey.shade500,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------
  // trend
  // ---------------------------------------------------------------

  Widget _trendCard(
    ThemeProvider theme,
    ProductionSummaryResult r,
  ) {
    final trend = r.trend;
    final subtitle =
        '${reportTrendIntervalLabel(r.interval)}, by business day';
    final title =
        _canSeeCost
            ? 'Production Cost Trend'
            : 'Production Runs Trend';
    final Widget child;
    if (trend.isEmpty) {
      child = _emptyText(
        theme,
        'No production in this period.',
      );
    } else if (_canSeeCost) {
      child = ReportTrendChart(
        starts: [for (final p in trend) p.start],
        interval: r.interval,
        money: _money,
        series: [
          ReportTrendSeries(
            label: 'Recorded Cost',
            color: _recordedColor,
            values: [for (final p in trend) p.recordedCost],
          ),
          ReportTrendSeries(
            label: 'Material Cost',
            color: _materialColor,
            values: [for (final p in trend) p.materialCost],
          ),
        ],
      );
    } else {
      // Without the cost permission: runs, with a count formatter.
      child = ReportTrendChart(
        starts: [for (final p in trend) p.start],
        interval: r.interval,
        money: _number,
        series: [
          ReportTrendSeries(
            label: 'Production Runs',
            color: theme.lightModeColor.prColor300,
            values: [
              for (final p in trend) p.runs.toDouble(),
            ],
          ),
        ],
      );
    }
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [_title(theme, title, subtitle), child],
      ),
    );
  }

  // ---------------------------------------------------------------
  // breakdown tables
  // ---------------------------------------------------------------

  void _setTab(ProductionBreakdownTab t) {
    setState(() {
      _tab = t;
      // Each tab starts in its built order.
      _sortField = null;
      _ascending = false;
    });
  }

  void _setSort(ProductionBreakdownField f) {
    setState(() {
      if (_sortField == f) {
        _ascending = !_ascending;
      } else {
        _sortField = f;
        // Names A-Z first; counts, amounts and dates largest first.
        _ascending =
            f == ProductionBreakdownField.name ||
            f == ProductionBreakdownField.sublabel;
      }
    });
  }

  Widget _breakdown(
    ThemeProvider theme,
    ProductionSummaryResult result,
  ) {
    final tabs = _tabs;
    final tab = tabs.contains(_tab) ? _tab : tabs.first;
    final rows = ProductionSummaryBuilder.sortBreakdown(
      ProductionSummaryBuilder.breakdown(result, tab),
      field: _sortField,
      ascending: _ascending,
    );
    final cols = productionBreakdownColumns(
      tab,
      canSeeCost: _canSeeCost,
      canSeeQuantity: _canSeeQuantity,
    );

    Widget cell(
      double width,
      Widget child, {
      bool start = false,
    }) {
      return SizedBox(
        width: width,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
          ),
          child: Align(
            alignment:
                start
                    ? Alignment.centerLeft
                    : Alignment.center,
            child: child,
          ),
        ),
      );
    }

    Widget txt(
      String s, {
      bool bold = false,
      Color? color,
    }) => Text(
      s,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: theme.mobileTexts.b3.fontSize,
        fontWeight:
            bold ? FontWeight.bold : FontWeight.w500,
        color: color ?? Colors.black87,
      ),
    );

    bool isStart(ProductionBreakdownColumn c) =>
        c.kind == ProductionBreakdownKind.text;

    Widget header(ProductionBreakdownColumn c) {
      final accent = theme.lightModeColor.prColor300;
      final sorted = _sortField == c.field;
      return InkWell(
        key: ValueKey('production-sort-${c.field.name}'),
        mouseCursor: SystemMouseCursors.click,
        onTap: () => _setSort(c.field),
        child: cell(
          c.width,
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 3,
            children: [
              Flexible(
                child: txt(
                  c.label,
                  bold: true,
                  color: sorted ? accent : null,
                ),
              ),
              Icon(
                sorted
                    ? (_ascending
                        ? Icons.arrow_upward_rounded
                        : Icons.arrow_downward_rounded)
                    : Icons.unfold_more_rounded,
                size: 14,
                color: sorted ? accent : Colors.grey,
              ),
            ],
          ),
          start: isStart(c),
        ),
      );
    }

    Widget rowWidget(ProductionBreakdownRow r, int i) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          key: ValueKey('production-row-${r.id}'),
          mouseCursor: SystemMouseCursors.click,
          onTap: () => _openTable(r.filters),
          child: Container(
            height: 46,
            decoration: BoxDecoration(
              color:
                  i.isEven
                      ? Colors.white
                      : Colors.grey.shade50,
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.shade100,
                ),
              ),
            ),
            child: Row(
              children: [
                for (final c in cols)
                  cell(
                    c.width,
                    txt(
                      _cellText(r, c),
                      bold:
                          c.field ==
                          ProductionBreakdownField.name,
                      color:
                          c.field ==
                                      ProductionBreakdownField
                                          .name &&
                                  r.isNone
                              ? Colors.grey
                              : null,
                    ),
                    start: isStart(c),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: _card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                _title(
                  theme,
                  'Production Breakdown',
                  'Tap a row to open its records in the table',
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    spacing: 6,
                    children: [
                      for (final t in tabs)
                        ChoiceChip(
                          key: ValueKey(
                            'production-tab-${t.name}',
                          ),
                          label: Text(t.label),
                          selected: t == tab,
                          onSelected: (_) => _setTab(t),
                          selectedColor:
                              theme
                                  .lightModeColor
                                  .prColor50,
                          backgroundColor:
                              Colors.grey.shade100,
                          labelStyle: TextStyle(
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b4
                                    .fontSize,
                            fontWeight:
                                t == tab
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                            color:
                                t == tab
                                    ? theme
                                        .lightModeColor
                                        .prColor300
                                    : Colors.grey.shade700,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (rows.isEmpty)
            _emptyText(
              theme,
              'No production in this period.',
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 44,
                    color: theme.lightModeColor.prColor300
                        .withAlpha(22),
                    child: Row(
                      children: [
                        for (final c in cols) header(c),
                      ],
                    ),
                  ),
                  for (var i = 0; i < rows.length; i++)
                    rowWidget(rows[i], i),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
