import 'package:flutter/material.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/report/components/export/report_export_button.dart';
import 'package:stockall/pages/report/components/export/report_export_format.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/production_report/production_summary/class/production_summary_logic.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/material_usage_logic.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/production_stock_model.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/stock_analysis_export_spec.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/stock_analysis_logic.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/stock_items_logic.dart';
import 'package:stockall/pages/report/production_report/stock_shared/components/production_stock_env.dart';
import 'package:stockall/pages/report/production_report/stock_shared/components/stock_view_kit.dart';
import 'package:stockall/pages/report/production_report/usage_records_table/class/usage_records_table_logic.dart';
import 'package:stockall/pages/report/general_report/class/general_report_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/components/receipts_report_filter_widgets.dart';
import 'package:stockall/providers/theme_provider.dart';

/// The stock analysis (I2 / M2), shared by desktop and mobile. Every
/// row and card opens the stock table on the same period.
class StockAnalysisView extends StatefulWidget {
  final bool isDesktop;
  final ProductionStockKind kind;
  final ReceiptsReportPeriod? initialPeriod;

  /// Null in the app: [ProductionStockEnv.live] is used.
  final ProductionStockEnv? env;

  const StockAnalysisView({
    super.key,
    required this.isDesktop,
    required this.kind,
    this.initialPeriod,
    this.env,
  });

  @override
  State<StockAnalysisView> createState() => _StockAnalysisViewState();
}

class _StockAnalysisViewState extends State<StockAnalysisView> {
  late final ProductionStockEnv _env;
  late ReceiptsReportPeriod _period;
  ProductionStockAnalysisTab? _tab;
  ProductionStockAnalysisField? _sortField;
  bool _ascending = false;

  bool _loading = true;
  String? _error;
  ProductionStockAnalysis? _result;
  String _signature = '';

  ProductionStockKind get _kind => widget.kind;

  @override
  void initState() {
    super.initState();
    _env = widget.env ?? ProductionStockEnv.live(widget.kind);
    _period = widget.initialPeriod ?? ReceiptsReportPeriod.today();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load(refreshFromStore: true);
    });
  }

  bool get _departmentsEnabled => _env.departmentsEnabled();
  bool get _canSeeCost => _env.canSeeCost();
  bool get _canSeeQuantity => _env.canSeeQuantity();
  bool get _historyAllowed => _env.historyAllowed();

  Future<void> _load({required bool refreshFromStore}) async {
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
    final items = _env.items();
    final entries = _env.entries();
    final names = _env.categoryNames();
    final now = resolveBusinessDate(DateTime.now());
    final material = _kind == ProductionStockKind.material;
    final records = _env.records();
    final usages = material ? _env.usages() : const <UsageRecordRow>[];
    final byUuid = {for (final i in items) i.uuid: i};
    Map<String, ProductionMaterialUsage>? usageFor(ReceiptsReportPeriod p) =>
        material
            ? ProductionMaterialUsageBuilder.build(
              records: records,
              usages: usages,
              period: p,
              items: byUuid,
            )
            : null;
    List<ProductionStockRow> rowsFor(ReceiptsReportPeriod p) =>
        ProductionStockRowBuilder.buildAll(
          items: items,
          entries: entries,
          categoryNames: names,
          period: p,
          businessNow: now,
          historyAllowed: _historyAllowed,
          usageByItem: usageFor(p),
        );
    final previous = GeneralReportPeriods.previous(_period);
    _result = ProductionStockAnalysisBuilder.build(
      kind: _kind,
      rows: rowsFor(_period),
      previousRows: previous == null ? null : rowsFor(previous),
      records: records,
      period: _period,
      businessNow: now,
      departmentsEnabled: _departmentsEnabled,
      canSeeCost: _canSeeCost,
      canSeeQuantity: _canSeeQuantity,
      historyAllowed: _historyAllowed,
      allTimeUsage:
          usageFor(const ReceiptsReportPeriod.allTime()) ?? const {},
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

  List<ProductionStockAnalysisTab> get _tabs => productionStockAnalysisTabs(
    kind: _kind,
    departmentsEnabled: _departmentsEnabled,
    canSeeCost: _canSeeCost,
    canSeeQuantity: _canSeeQuantity,
    historyAllowed: _historyAllowed,
  );

  ProductionStockAnalysisTab get _activeTab {
    final tabs = _tabs;
    final t = _tab;
    return t != null && tabs.contains(t) ? t : tabs.first;
  }

  /// One way: the table opens on the row's item, department or
  /// category, and the period.
  Future<void> _openTable(ProductionStockFilters filters) async {
    await _env.openTable(context, filters.copy(), _period);
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

  String _money(num v) => _env.money(context, v);
  String _number(num v) => formatLargeNumberDouble(v.toDouble());
  String _percent(num v) => ExportFormatter(currency: '').percent(v);

  ReportExportSpec _exportSpec() => productionStockAnalysisExportSpec(
    analysis: _result!,
    period: _period,
    tabs: _tabs,
    activeTab: _activeTab,
    sortField: _sortField,
    ascending: _ascending,
    currency: currencySymbol(context: context),
    canSeeCost: _canSeeCost,
    canSeeQuantity: _canSeeQuantity,
    historyAllowed: _historyAllowed,
  );

  @override
  Widget build(BuildContext context) {
    final theme = returnTheme(context);
    _env.listen(context);
    if (!_loading && _error == null && _env.signature() != _signature) {
      try {
        _rebuild();
      } catch (e) {
        _error = e.toString();
      }
    }
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 252, 253, 255),
      appBar: stockAppBar(
        context,
        theme,
        title: '${_kind.plural} Analysis',
        loading: _loading,
        onRefresh: () => _load(refreshFromStore: true),
      ),
      body: _body(theme),
    );
  }

  Widget _body(ThemeProvider theme) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final a = _result;
    if (_error != null || a == null) {
      return stockErrorView(theme, () => _load(refreshFromStore: false));
    }
    final gap = SizedBox(height: widget.isDesktop ? 16 : 12);
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: widget.isDesktop ? 20 : 12,
        vertical: 10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
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
          stockNotes(
            productionStockNotes(
              kind: _kind,
              page: ProductionStockReportPage.analysis,
              period: _period,
              historyAllowed: _historyAllowed,
              notNormalised: a.notNormalised,
            ),
          ),
          gap,
          StockKpiGrid(
            theme: theme,
            isDesktop: widget.isDesktop,
            cards: productionStockAnalysisCards(
              a,
              canSeeCost: _canSeeCost,
              canSeeQuantity: _canSeeQuantity,
              historyAllowed: _historyAllowed,
            ),
            money: _money,
            number: _number,
            keyPrefix: 'analysis',
            onTap: (_) => _openTable(ProductionStockFilters()),
          ),
          gap,
          _breakdown(theme, a),
          gap,
        ],
      ),
    );
  }

  void _setTab(ProductionStockAnalysisTab t) {
    setState(() {
      _tab = t;
      _sortField = null;
      _ascending = false;
    });
  }

  void _setSort(ProductionStockAnalysisField f) {
    setState(() {
      if (_sortField == f) {
        _ascending = !_ascending;
      } else {
        _sortField = f;
        _ascending = f == ProductionStockAnalysisField.name;
      }
    });
  }

  Widget _breakdown(ThemeProvider theme, ProductionStockAnalysis a) {
    final tabs = _tabs;
    final tab = _activeTab;
    final rows = ProductionStockAnalysisBuilder.sortTab(
      a.tabs[tab] ?? const [],
      field: _sortField,
      ascending: _ascending,
    );
    final cols = productionStockAnalysisColumns(
      tab,
      kind: _kind,
      canSeeCost: _canSeeCost,
      canSeeQuantity: _canSeeQuantity,
    );

    Widget cell(double width, Widget child, {bool start = false}) => SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Align(
          alignment: start ? Alignment.centerLeft : Alignment.center,
          child: child,
        ),
      ),
    );

    Widget header(ProductionStockAnalysisColumn c) {
      final accent = theme.lightModeColor.prColor300;
      final sorted = _sortField == c.field;
      return InkWell(
        key: ValueKey('analysis-sort-${c.field.name}'),
        mouseCursor: SystemMouseCursors.click,
        onTap: () => _setSort(c.field),
        child: cell(
          c.width,
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 3,
            children: [
              Flexible(
                child: stockTxt(
                  theme,
                  c.label,
                  bold: true,
                  color: sorted ? accent : null,
                  maxLines: 1,
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
          start: c.kind == ProductionBreakdownKind.text,
        ),
      );
    }

    Widget rowWidget(ProductionStockAnalysisRow r, int i) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          key: ValueKey('analysis-row-${r.id}'),
          mouseCursor: SystemMouseCursors.click,
          onTap: () => _openTable(r.filters),
          child: Container(
            height: 46,
            decoration: BoxDecoration(
              color: i.isEven ? Colors.white : Colors.grey.shade50,
              border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
            ),
            child: Row(
              children: [
                for (final c in cols)
                  cell(
                    c.width,
                    stockTxt(
                      theme,
                      productionStockAnalysisCellText(
                        r,
                        c,
                        _money,
                        _number,
                        _percent,
                        formatDateTime,
                      ),
                      bold: c.field == ProductionStockAnalysisField.name,
                      color:
                          c.field == ProductionStockAnalysisField.name && r.isNone
                              ? Colors.grey
                              : null,
                      maxLines: 1,
                    ),
                    start: c.kind == ProductionBreakdownKind.text,
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                Text(
                  '${_kind.plural} Breakdown',
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b1.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Tap a row to open it in the table',
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b4.fontSize,
                    color: Colors.grey.shade500,
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    spacing: 6,
                    children: [
                      for (final t in tabs)
                        ChoiceChip(
                          key: ValueKey('analysis-tab-${t.name}'),
                          label: Text(productionStockAnalysisTabLabel(t, _kind)),
                          selected: t == tab,
                          onSelected: (_) => _setTab(t),
                          selectedColor: theme.lightModeColor.prColor50,
                          backgroundColor: Colors.grey.shade100,
                          labelStyle: TextStyle(
                            fontSize: theme.mobileTexts.b4.fontSize,
                            fontWeight: t == tab ? FontWeight.bold : FontWeight.w500,
                            color:
                                t == tab
                                    ? theme.lightModeColor.prColor300
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
            Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'Nothing to show for this period.',
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b3.fontSize,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 44,
                    color: theme.lightModeColor.prColor300.withAlpha(22),
                    child: Row(children: [for (final c in cols) header(c)]),
                  ),
                  for (var i = 0; i < rows.length; i++) rowWidget(rows[i], i),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
