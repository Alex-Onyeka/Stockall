import 'package:flutter/material.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/report/components/export/report_export_button.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/report_pager.dart';
import 'package:stockall/pages/report/components/report_pill.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/production_stock_model.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/stock_history_logic.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/stock_history_summary_export_spec.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/stock_history_summary_logic.dart';
import 'package:stockall/pages/report/production_report/stock_shared/components/production_stock_env.dart';
import 'package:stockall/pages/report/production_report/stock_shared/components/stock_view_kit.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/components/receipts_report_filter_widgets.dart';
import 'package:stockall/providers/theme_provider.dart';

typedef _Col = StockCol<ProductionHistorySummaryRow, ProductionHistorySummaryPage>;

/// The stock history summary (I4 / M4), shared by desktop and mobile.
/// The cards cover every item of the period; the search and movement
/// filter only narrow the table.
class StockHistorySummaryView extends StatefulWidget {
  final bool isDesktop;
  final ProductionStockKind kind;
  final ReceiptsReportPeriod? initialPeriod;

  /// Null in the app: [ProductionStockEnv.live] is used.
  final ProductionStockEnv? env;

  const StockHistorySummaryView({
    super.key,
    required this.isDesktop,
    required this.kind,
    this.initialPeriod,
    this.env,
  });

  @override
  State<StockHistorySummaryView> createState() =>
      _StockHistorySummaryViewState();
}

class _StockHistorySummaryViewState extends State<StockHistorySummaryView> {
  late final ProductionStockEnv _env;
  final _state = ProductionHistorySummaryState();
  final _searchCtrl = TextEditingController();

  bool _toolbarOpen = false;
  late ReceiptsReportPeriod _period;
  bool _loading = true;
  String? _error;

  List<ProductionHistorySummaryRow> _allRows = [];
  List<ProductionHistorySummaryRow> _sorted = [];
  ProductionHistorySummaryStats? _stats;
  ProductionHistorySummaryPage? _result;
  Map<String, String> _categoryNames = const {};
  String _signature = '';

  ProductionHistorySummaryFilters get _filters => _state.filters;
  ProductionStockKind get _kind => widget.kind;

  @override
  void initState() {
    super.initState();
    _env = widget.env ?? ProductionStockEnv.live(widget.kind);
    _period = widget.initialPeriod ?? ReceiptsReportPeriod.today();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load(refreshFromStore: false);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  bool get _departmentsEnabled => _env.departmentsEnabled();
  bool get _canSeeQuantity => _env.canSeeQuantity();

  Future<void> _load({required bool refreshFromStore}) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _env.load(context, refreshFromStore: refreshFromStore);
      _rebuildBase();
      _recompute();
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

  void _rebuildBase() {
    _categoryNames = _env.categoryNames();
    _allRows = ProductionHistorySummaryBuilder.build(
      kind: _kind,
      items: _env.items(),
      entries: _env.entries(),
      categoryNames: _categoryNames,
      period: _period,
    );
    _stats = ProductionHistorySummaryStats.fromRows(_allRows);
    _signature = _env.signature();
  }

  void _recompute() {
    _sorted = ProductionHistorySummaryBuilder.filterAndSort(
      rows: _allRows,
      filters: _filters,
      sort: _state.sort,
      canSeeQuantity: _canSeeQuantity,
    );
    final page = ProductionHistorySummaryBuilder.paginate(_sorted, _state.page);
    _state.page = page.page;
    _result = page;
  }

  void _apply(VoidCallback change, {bool resetPage = true, bool rebuild = false}) {
    setState(() {
      change();
      if (resetPage) _state.page = 1;
      try {
        if (rebuild) _rebuildBase();
        _recompute();
        _error = null;
      } catch (e) {
        _error = e.toString();
      }
    });
  }

  void _resetAll() {
    _searchCtrl.clear();
    _apply(_state.resetAll);
  }

  void _goToPage(int p) {
    final r = _result;
    if (r == null || p < 1 || p > r.totalPages || p == r.page) return;
    _apply(() => _state.page = p, resetPage: false);
  }

  void _onSort(Object key) {
    final (field, movement) =
        key as (ProductionHistorySummarySortField, ProductionMovementKind?);
    _apply(() {
      final s = _state.sort;
      _state.sort = ProductionHistorySummarySort(
        field,
        movement: movement,
        ascending:
            s.sameColumn(field, movement)
                ? !s.ascending
                : field == ProductionHistorySummarySortField.name,
      );
    });
  }

  /// One way: the history table opens on the row's item and period.
  Future<void> _openHistory(ProductionHistorySummaryRow r) async {
    await _env.openHistory(
      context,
      ProductionHistoryFilters(itemKey: r.key),
      _period,
    );
    if (mounted) {
      setState(() {
        try {
          _rebuildBase();
          _recompute();
        } catch (e) {
          _error = e.toString();
        }
      });
    }
  }

  String _money(num v) => _env.money(context, v);
  String _number(num v) => formatLargeNumberDouble(v.toDouble());

  ReportExportSpec _exportSpec() => productionHistorySummaryExportSpec(
    kind: _kind,
    allRows: _allRows,
    rows: _sorted,
    state: _state,
    categoryNames: _categoryNames,
    period: _period,
    currency: currencySymbol(context: context),
    departmentsEnabled: _departmentsEnabled,
    canSeeQuantity: _canSeeQuantity,
  );

  @override
  Widget build(BuildContext context) {
    final theme = returnTheme(context);
    _env.listen(context);
    if (!_loading && _error == null && _env.signature() != _signature) {
      try {
        _rebuildBase();
        _recompute();
      } catch (e) {
        _error = e.toString();
      }
    }
    final r = _result;
    final stats = _stats;
    return Scaffold(
      appBar: stockAppBar(
        context,
        theme,
        title: '${_kind.singular} History Summary',
        loading: _loading,
        onRefresh: () => _load(refreshFromStore: true),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: widget.isDesktop ? 20 : 12),
        child: Column(
          children: [
            const SizedBox(height: 8),
            _toolbar(theme),
            stockNotes(
              productionStockNotes(
                kind: _kind,
                page: ProductionStockReportPage.historySummary,
                period: _period,
                historyAllowed: true,
                notNormalised: stats?.notNormalised ?? 0,
              ),
            ),
            if (!_loading && _error == null && stats != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: StockKpiGrid(
                  theme: theme,
                  isDesktop: widget.isDesktop,
                  cards: productionHistorySummaryCards(
                    stats,
                    kind: _kind,
                    canSeeQuantity: _canSeeQuantity,
                  ),
                  money: _money,
                  number: _number,
                  keyPrefix: 'summary',
                ),
              ),
            Expanded(child: _content(theme)),
            if (!_loading && _error == null && r != null)
              ReportPager(
                theme: theme,
                page: r.page,
                totalPages: r.totalPages,
                totalCount: r.totalCount,
                firstIndex: r.firstIndex,
                lastIndex: r.lastIndex,
                itemLabel: _kind.countNoun,
                onPage: _goToPage,
              ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }

  Widget _content(ThemeProvider theme) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return stockErrorView(theme, () => _load(refreshFromStore: false));
    }
    final res = _result;
    if (res == null || res.totalCount == 0) {
      return stockEmptyView(
        theme,
        hasFilters: _filters.hasAnything,
        filteredText:
            'No ${_kind.singular.toLowerCase()} matches your search and filter',
        emptyText: 'No ${_kind.plural.toLowerCase()} yet',
        onReset: _resetAll,
      );
    }
    final s = _state.sort;
    return StockTableFrame<ProductionHistorySummaryRow, ProductionHistorySummaryPage>(
      key: ValueKey('summary-page-${res.page}'),
      theme: theme,
      cols: _columns(theme),
      rows: res.rows,
      totals: res,
      sortKey: (s.field, s.movement),
      ascending: s.ascending,
      onSort: _onSort,
      onTap: _openHistory,
      rowKey: (r) => ValueKey('summary-row-${r.key}'),
    );
  }

  Widget _toolbar(ThemeProvider theme) {
    final movement = _filters.movement;
    final on = movement != ProductionHistoryMovementFilter.all;
    return Wrap(
      spacing: 2,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        stockSearchBox(
          context,
          theme,
          isDesktop: widget.isDesktop,
          controller: _searchCtrl,
          hint: 'Search name or unit',
          onChanged: (v) => _apply(() => _filters.search = v),
          toolbarOpen: _toolbarOpen,
          onToggleToolbar: () => setState(() => _toolbarOpen = !_toolbarOpen),
        ),
        if (stockToolbarVisible(context, _toolbarOpen)) ...[
          ReceiptsReportPeriodButton(
            theme: theme,
            period: _period,
            enabled: _env.canPickDate(),
            onChanged: (p) => _apply(() => _period = p, rebuild: true),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 6.0, right: 5),
            child: PopupMenuButton<ProductionHistoryMovementFilter>(
              key: const ValueKey('summary-movement'),
              tooltip: 'Movement',
              offset: const Offset(0, 42),
              color: Colors.white,
              onSelected: (m) => _apply(() => _filters.movement = m),
              itemBuilder:
                  (context) => [
                    for (final m in ProductionHistoryMovementFilter.values)
                      PopupMenuItem(value: m, height: 38, child: Text(m.label)),
                  ],
              child: ReportPill(
                theme: theme,
                icon: Icons.swap_vert_rounded,
                label: on ? 'Movement: ${movement.label}' : 'Movement',
                highlighted: on,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 5, right: 5),
            child: ReportExportButton(buildSpec: _exportSpec),
          ),
          if (_filters.hasAnything)
            ReportPill(
              theme: theme,
              icon: Icons.filter_alt_off,
              label: 'Reset All Filters',
              onTap: _resetAll,
              color: theme.lightModeColor.prColor300,
            ),
        ],
      ],
    );
  }

  List<_Col> _columns(ThemeProvider theme) {
    final seeQty = _canSeeQuantity;
    final produced = _kind == ProductionStockKind.producedItem;
    _Col qty(
      String label,
      ProductionHistorySummarySortField f,
      double? Function(ProductionHistorySummaryRow r) pick, {
      ProductionMovementKind? movement,
      bool signed = false,
      bool bold = false,
    }) => _Col(
      label: label,
      width: 130,
      sortKey: (f, movement),
      cell: (r) {
        if (!seeQty) return stockTxt(theme, productionMasked);
        final v = pick(r);
        if (v == null) return stockDash(theme);
        return stockTxt(
          theme,
          signed && v > 0 ? '+${_number(v)}' : _number(v),
          bold: bold,
        );
      },
    );
    _Col count(
      String label,
      ProductionHistorySummarySortField f,
      int Function(ProductionHistorySummaryRow r) pick,
    ) => _Col(
      label: label,
      width: 100,
      sortKey: (f, null),
      cell: (r) => stockTxt(theme, '${pick(r)}'),
    );

    return [
      _Col(
        label: _kind.singular,
        width: 200,
        sortKey: (ProductionHistorySummarySortField.name, null),
        align: TextAlign.start,
        cell:
            (r) => stockTxt(
              theme,
              r.exists ? r.name : '${r.name} (deleted)',
              bold: true,
              align: TextAlign.start,
              color: r.exists ? null : Colors.grey,
            ),
        total: (_) => stockTxt(theme, 'TOTAL', bold: true, align: TextAlign.start),
      ),
      _Col(
        label: 'Primary Unit',
        width: 120,
        cell: (r) => stockTxt(theme, r.primaryUnit),
        total: (t) => stockTxt(theme, '${t.totalCount} ${_kind.countNoun}', bold: true),
      ),
      qty('Opening', ProductionHistorySummarySortField.opening, (r) => r.balance.opening),
      for (final m in productionSummaryMovementColumns(_kind)) ...[
        qty(
          m.label,
          ProductionHistorySummarySortField.movement,
          (r) => r.of(m),
          movement: m,
        ),
        if (produced && m == ProductionMovementKind.productionDeleted)
          qty(
            'Net Produced',
            ProductionHistorySummarySortField.netProduced,
            (r) => r.netProduced,
          ),
      ],
      count('Created', ProductionHistorySummarySortField.created, (r) => r.created),
      count('Deleted', ProductionHistorySummarySortField.deleted, (r) => r.deleted),
      qty('Additions', ProductionHistorySummarySortField.additions, (r) => r.additions),
      qty('Reductions', ProductionHistorySummarySortField.reductions, (r) => r.reductions),
      qty('Net', ProductionHistorySummarySortField.net, (r) => r.net, signed: true, bold: true),
      qty('Closing', ProductionHistorySummarySortField.closing, (r) => r.balance.closing),
      _Col(
        label: 'Records',
        width: 100,
        sortKey: (ProductionHistorySummarySortField.events, null),
        cell: (r) => stockTxt(theme, '${r.events}'),
        total: (t) => stockTxt(theme, '${t.totalEvents}', bold: true),
      ),
    ];
  }
}
