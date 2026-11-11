import 'package:flutter/material.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/report/components/export/report_export_button.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/report_pager.dart';
import 'package:stockall/pages/report/components/report_pill.dart';
import 'package:stockall/pages/report/production_report/shared/components/production_filter_panel_box.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/production_stock_model.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/stock_history_export_spec.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/stock_history_logic.dart';
import 'package:stockall/pages/report/production_report/stock_shared/components/production_stock_env.dart';
import 'package:stockall/pages/report/production_report/stock_shared/components/stock_filter_widgets.dart';
import 'package:stockall/pages/report/production_report/stock_shared/components/stock_view_kit.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/components/receipts_report_filter_widgets.dart';
import 'package:stockall/providers/theme_provider.dart';

typedef _Col = StockCol<ProductionHistoryRow, ProductionHistoryPage>;

/// The stock history table (I3 / M3), shared by desktop and mobile.
/// [initialFilters] and [initialPeriod] let the history summary open
/// it on one item.
class StockHistoryView extends StatefulWidget {
  final bool isDesktop;
  final ProductionStockKind kind;
  final ProductionHistoryFilters? initialFilters;
  final ReceiptsReportPeriod? initialPeriod;

  /// Null in the app: [ProductionStockEnv.live] is used.
  final ProductionStockEnv? env;

  const StockHistoryView({
    super.key,
    required this.isDesktop,
    required this.kind,
    this.initialFilters,
    this.initialPeriod,
    this.env,
  });

  @override
  State<StockHistoryView> createState() => _StockHistoryViewState();
}

class _StockHistoryViewState extends State<StockHistoryView> {
  late final ProductionStockEnv _env;
  late final ProductionHistoryTableState _state;
  final _searchCtrl = TextEditingController();

  bool _showFilters = false;
  bool _toolbarOpen = false;
  late ReceiptsReportPeriod _period;
  bool _loading = true;
  String? _error;

  List<ProductionHistoryRow> _baseRows = [];
  List<ProductionHistoryRow> _sorted = [];
  ProductionHistoryPage? _result;
  ProductionHistoryFilterChoices _choices = ProductionHistoryFilterChoices.empty;
  Map<String, String> _categoryNames = const {};
  String _signature = '';

  ProductionHistoryFilters get _filters => _state.filters;
  ProductionStockKind get _kind => widget.kind;

  @override
  void initState() {
    super.initState();
    _env = widget.env ?? ProductionStockEnv.live(widget.kind);
    _state = ProductionHistoryTableState(filters: widget.initialFilters?.copy());
    _searchCtrl.text = _filters.search;
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
    _baseRows = ProductionHistoryRowBuilder.buildAll(
      entries: _env.entries(),
      items: _env.items(),
      categoryNames: _categoryNames,
    );
    _choices = ProductionHistoryFilterChoices.fromRows(_baseRows);
    _signature = _env.signature();
  }

  void _recompute() {
    _sorted = ProductionHistoryQuery.filterAndSort(
      rows: _baseRows,
      period: _period,
      filters: _filters,
      sortField: _state.sortField,
      ascending: _state.ascending,
      departmentsEnabled: _departmentsEnabled,
      canSeeQuantity: _canSeeQuantity,
    );
    final page = ProductionHistoryQuery.paginate(_sorted, _state.page);
    _state.page = page.page;
    _result = page;
  }

  void _apply(VoidCallback change, {bool resetPage = true}) {
    setState(() {
      change();
      if (resetPage) _state.page = 1;
      try {
        _recompute();
        _error = null;
      } catch (e) {
        _error = e.toString();
      }
    });
  }

  void _applyAndSync(VoidCallback change) {
    _apply(change);
    if (_filters.search.isEmpty) _searchCtrl.clear();
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
    final f = key as ProductionHistorySortField;
    _apply(() {
      if (_state.sortField == f) {
        _state.ascending = !_state.ascending;
      } else {
        _state.sortField = f;
        _state.ascending =
            f != ProductionHistorySortField.date &&
            f != ProductionHistorySortField.change;
      }
    });
  }

  Future<void> _openItem(ProductionHistoryRow r) async {
    final key = r.itemKey;
    if (r.item == null || key == null) return;
    await _env.openItem(context, key);
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

  String _number(num v) => formatLargeNumberDouble(v.toDouble());

  ReportExportSpec _exportSpec() => productionHistoryExportSpec(
    kind: _kind,
    rows: _sorted,
    state: _state,
    choices: _choices,
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
    return Scaffold(
      appBar: stockAppBar(
        context,
        theme,
        title: '${_kind.singular} History',
        loading: _loading,
        onRefresh: () => _load(refreshFromStore: true),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: widget.isDesktop ? 20 : 12),
        child: Column(
          children: [
            const SizedBox(height: 8),
            _toolbar(theme),
            if (_showFilters)
              productionFilterPanelBox(
                context,
                isDesktop: widget.isDesktop,
                child: _filterPanel(theme),
              ),
            stockChips(
              theme,
              productionHistoryFilterEntries(
                kind: _kind,
                filters: _filters,
                choices: _choices,
                departmentsEnabled: _departmentsEnabled,
                includeSearch: false,
              ),
              _applyAndSync,
            ),
            stockNotes(
              productionStockNotes(
                kind: _kind,
                page: ProductionStockReportPage.history,
                period: _period,
                historyAllowed: true,
                notNormalised: productionHistoryNotNormalised(_sorted),
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
                itemLabel: 'records',
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
        filteredText: 'No history record matches your search and filters',
        emptyText: 'No history was recorded in this period',
        onReset: _resetAll,
      );
    }
    return StockTableFrame<ProductionHistoryRow, ProductionHistoryPage>(
      key: ValueKey('history-page-${res.page}'),
      theme: theme,
      cols: _columns(theme),
      rows: res.rows,
      totals: res,
      sortKey: _state.sortField,
      ascending: _state.ascending,
      onSort: _onSort,
      onTap: _openItem,
      rowKey: (r) => ValueKey('history-row-${r.uuid}'),
    );
  }

  Widget _toolbar(ThemeProvider theme) {
    final active = _filters.activeCount;
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
          hint: 'Search item, event, staff or description',
          onChanged: (v) => _apply(() => _filters.search = v),
          toolbarOpen: _toolbarOpen,
          onToggleToolbar: () => setState(() => _toolbarOpen = !_toolbarOpen),
        ),
        if (stockToolbarVisible(context, _toolbarOpen)) ...[
          ReceiptsReportPeriodButton(
            theme: theme,
            period: _period,
            enabled: _env.canPickDate(),
            onChanged: (p) => _apply(() => _period = p),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 6.0, right: 5),
            child: ReportPill(
              theme: theme,
              icon: Icons.tune_rounded,
              label: active == 0 ? 'Filters' : 'Filters ($active)',
              highlighted: _showFilters || active > 0,
              onTap: () => setState(() => _showFilters = !_showFilters),
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

  Widget _filterPanel(ThemeProvider theme) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 5)],
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 12,
        children: productionHistoryFilterFields(
          theme: theme,
          kind: _kind,
          filters: _filters,
          choices: _choices,
          departmentsEnabled: _departmentsEnabled,
          onApply: _apply,
        ),
      ),
    );
  }

  List<_Col> _columns(ThemeProvider theme) {
    final seeQty = _canSeeQuantity;
    return [
      _Col(
        label: 'Date',
        width: 120,
        sortKey: ProductionHistorySortField.date,
        cell: (r) => stockTxt(theme, formatDateTime(r.createdAt)),
        total: (_) => stockTxt(theme, 'TOTAL', bold: true),
      ),
      _Col(
        label: 'Time',
        width: 100,
        cell: (r) => stockTxt(theme, formatTime(r.createdAt)),
        total: (t) => stockTxt(theme, '${t.totalCount} records', bold: true),
      ),
      _Col(
        label: _kind.singular,
        width: 190,
        sortKey: ProductionHistorySortField.item,
        align: TextAlign.start,
        cell:
            (r) => stockTxt(
              theme,
              r.itemName,
              bold: true,
              align: TextAlign.start,
              color: r.item == null ? Colors.grey : null,
            ),
      ),
      _Col(
        label: 'Event',
        width: 180,
        sortKey: ProductionHistorySortField.event,
        cell: (r) => stockTxt(theme, r.eventLabel),
      ),
      _Col(
        label: 'Title',
        width: 170,
        align: TextAlign.start,
        cell: (r) => stockTxt(theme, r.entry.title, align: TextAlign.start),
      ),
      _Col(
        label: 'Change',
        width: 200,
        sortKey: ProductionHistorySortField.change,
        cell:
            (r) => stockTxt(
              theme,
              seeQty ? productionHistoryChangeText(r, _number) : productionMasked,
              bold: true,
              color:
                  !seeQty
                      ? null
                      : r.direction == ProductionHistoryDirection.decrease
                      ? Colors.red.shade700
                      : r.direction == ProductionHistoryDirection.increase
                      ? Colors.green.shade700
                      : null,
            ),
      ),
      _Col(
        label: 'Old → New',
        width: 150,
        cell:
            (r) => stockTxt(
              theme,
              seeQty ? productionHistoryBalanceText(r, _number) : productionMasked,
            ),
      ),
      _Col(
        label: 'Source → Destination',
        width: 230,
        cell: (r) => stockTxt(theme, '${r.sourceLabel} → ${r.destinationLabel}'),
      ),
      _Col(
        label: 'Staff',
        width: 150,
        sortKey: ProductionHistorySortField.staff,
        align: TextAlign.start,
        cell:
            (r) => stockTxt(
              theme,
              r.staffLabel,
              align: TextAlign.start,
              color: r.staffName == null ? Colors.grey : null,
            ),
      ),
      if (_departmentsEnabled)
        _Col(
          label: 'Department',
          width: 150,
          sortKey: ProductionHistorySortField.department,
          align: TextAlign.start,
          cell:
              (r) => stockTxt(
                theme,
                r.departmentLabel,
                align: TextAlign.start,
                color: r.departmentKey == null ? Colors.grey : null,
              ),
        ),
      _Col(
        label: 'Description',
        width: 260,
        align: TextAlign.start,
        cell:
            (r) => stockTxt(
              theme,
              r.entry.desc ?? '—',
              align: TextAlign.start,
              tooltip: r.entry.desc,
              color: r.entry.desc == null ? Colors.grey : null,
            ),
      ),
    ];
  }
}
