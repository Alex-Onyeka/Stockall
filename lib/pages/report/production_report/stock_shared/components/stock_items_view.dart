import 'package:flutter/material.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/report/components/export/report_export_button.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/report_pager.dart';
import 'package:stockall/pages/report/components/report_pill.dart';
import 'package:stockall/pages/report/components/report_range_fields.dart';
import 'package:stockall/pages/report/production_report/shared/components/production_filter_panel_box.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/material_usage_logic.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/production_stock_model.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/stock_items_export_spec.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/stock_items_logic.dart';
import 'package:stockall/pages/report/production_report/stock_shared/components/production_stock_env.dart';
import 'package:stockall/pages/report/production_report/stock_shared/components/stock_filter_widgets.dart';
import 'package:stockall/pages/report/production_report/stock_shared/components/stock_view_kit.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/components/receipts_report_filter_widgets.dart';
import 'package:stockall/providers/theme_provider.dart';

typedef _Col =
    StockCol<ProductionStockRow, ProductionStockPage>;

/// The stock table (I1 / M1), shared by desktop and mobile.
///
/// [initialFilters] and [initialPeriod] let the analysis open the
/// table on one item, department or category.
class StockItemsView extends StatefulWidget {
  final bool isDesktop;
  final ProductionStockKind kind;
  final ProductionStockFilters? initialFilters;
  final ReceiptsReportPeriod? initialPeriod;

  /// Null in the app: [ProductionStockEnv.live] is used.
  final ProductionStockEnv? env;

  const StockItemsView({
    super.key,
    required this.isDesktop,
    required this.kind,
    this.initialFilters,
    this.initialPeriod,
    this.env,
  });

  @override
  State<StockItemsView> createState() =>
      _StockItemsViewState();
}

class _StockItemsViewState extends State<StockItemsView> {
  late final ProductionStockEnv _env;
  late final ProductionStockTableState _state;
  final _searchCtrl = TextEditingController();
  final _costMinCtrl = TextEditingController();
  final _costMaxCtrl = TextEditingController();
  final _qtyMinCtrl = TextEditingController();
  final _qtyMaxCtrl = TextEditingController();

  bool _showFilters = false;
  bool _toolbarOpen = false;
  late ReceiptsReportPeriod _period;
  bool _loading = true;
  String? _error;

  List<ProductionStockRow> _baseRows = [];
  List<ProductionStockRow> _sorted = [];
  ProductionStockPage? _result;
  ProductionStockFilterChoices _choices =
      ProductionStockFilterChoices.empty;
  Map<String, String> _categoryNames = const {};
  String _signature = '';

  ProductionStockFilters get _filters => _state.filters;
  ProductionStockKind get _kind => widget.kind;

  @override
  void initState() {
    super.initState();
    _env =
        widget.env ?? ProductionStockEnv.live(widget.kind);
    _state = ProductionStockTableState(
      filters: widget.initialFilters?.copy(),
    );
    _searchCtrl.text = _filters.search;
    _period =
        widget.initialPeriod ??
        ReceiptsReportPeriod.today();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load(refreshFromStore: false);
    });
  }

  @override
  void dispose() {
    for (final c in [
      _searchCtrl,
      _costMinCtrl,
      _costMaxCtrl,
      _qtyMinCtrl,
      _qtyMaxCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  // ---------------------------------------------------------------
  // data
  // ---------------------------------------------------------------

  bool get _departmentsEnabled => _env.departmentsEnabled();
  bool get _canSeeCost => _env.canSeeCost();
  bool get _canSeeQuantity => _env.canSeeQuantity();
  bool get _historyAllowed => _env.historyAllowed();

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
    final items = _env.items();
    _baseRows = ProductionStockRowBuilder.buildAll(
      items: items,
      entries: _env.entries(),
      categoryNames: _categoryNames,
      period: _period,
      businessNow: resolveBusinessDate(DateTime.now()),
      historyAllowed: _historyAllowed,
      usageByItem:
          _kind == ProductionStockKind.material
              ? ProductionMaterialUsageBuilder.build(
                records: _env.records(),
                usages: _env.usages(),
                period: _period,
                items: {for (final i in items) i.uuid: i},
              )
              : null,
    );
    _choices = ProductionStockFilterChoices.fromRows(
      _baseRows,
    );
    _signature = _env.signature();
  }

  void _recompute() {
    _sorted = ProductionStockQuery.filterAndSort(
      rows: _baseRows,
      filters: _filters,
      sort: _state.sort,
      departmentsEnabled: _departmentsEnabled,
      canSeeCost: _canSeeCost,
      canSeeQuantity: _canSeeQuantity,
    );
    final page = ProductionStockQuery.paginate(
      _sorted,
      _state.page,
    );
    _state.page = page.page;
    _result = page;
  }

  void _apply(
    VoidCallback change, {
    bool resetPage = true,
    bool rebuild = false,
  }) {
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

  void _applyAndSync(VoidCallback change) {
    _apply(change);
    if (_filters.costMin == null &&
        _filters.costMax == null) {
      _costMinCtrl.clear();
      _costMaxCtrl.clear();
    }
    if (_filters.quantityMin == null &&
        _filters.quantityMax == null) {
      _qtyMinCtrl.clear();
      _qtyMaxCtrl.clear();
    }
    if (_filters.search.isEmpty) _searchCtrl.clear();
  }

  void _setPeriod(ReceiptsReportPeriod p) {
    _apply(() => _period = p, rebuild: true);
    if (!p.isAllTime) {
      _load(refreshFromStore: false);
    }
  }

  void _resetAll() {
    for (final c in [
      _searchCtrl,
      _costMinCtrl,
      _costMaxCtrl,
      _qtyMinCtrl,
      _qtyMaxCtrl,
    ]) {
      c.clear();
    }
    _apply(_state.resetAll);
  }

  void _goToPage(int p) {
    final r = _result;
    if (r == null ||
        p < 1 ||
        p > r.totalPages ||
        p == r.page)
      return;
    _apply(() => _state.page = p, resetPage: false);
  }

  /// Names and labels A-Z first; numbers and dates largest first.
  void _onSort(Object key) {
    final (field, movement) =
        key
            as (
              ProductionStockSortField,
              ProductionMovementKind?,
            );
    _apply(() {
      final s = _state.sort;
      if (s.sameColumn(field, movement)) {
        _state.sort = ProductionStockSort(
          field,
          movement: movement,
          ascending: !s.ascending,
        );
      } else {
        const textual = {
          ProductionStockSortField.name,
          ProductionStockSortField.unit,
          ProductionStockSortField.department,
          ProductionStockSortField.category,
        };
        _state.sort = ProductionStockSort(
          field,
          movement: movement,
          ascending: textual.contains(field),
        );
      }
    });
  }

  Future<void> _openItem(ProductionStockRow r) async {
    await _env.openItem(context, r.uuid);
    // Picks up an edit or delete made on the item's page.
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
  String _number(num v) =>
      formatLargeNumberDouble(v.toDouble());

  ReportExportSpec _exportSpec() =>
      productionStockItemsExportSpec(
        kind: _kind,
        rows: _sorted,
        state: _state,
        choices: _choices,
        categoryNames: _categoryNames,
        period: _period,
        currency: currencySymbol(context: context),
        departmentsEnabled: _departmentsEnabled,
        canSeeCost: _canSeeCost,
        canSeeQuantity: _canSeeQuantity,
        historyAllowed: _historyAllowed,
      );

  // ---------------------------------------------------------------
  // build
  // ---------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = returnTheme(context);
    _env.listen(context);
    if (!_loading &&
        _error == null &&
        _env.signature() != _signature) {
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
        title: '${_kind.plural} Table',
        loading: _loading,
        onRefresh: () => _load(refreshFromStore: true),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: widget.isDesktop ? 20 : 12,
        ),
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
              productionStockFilterEntries(
                kind: _kind,
                filters: _filters,
                choices: _choices,
                departmentsEnabled: _departmentsEnabled,
                canSeeCost: _canSeeCost,
                canSeeQuantity: _canSeeQuantity,
                money: _money,
                number: _number,
                includeSearch: false,
              ),
              _applyAndSync,
            ),
            stockNotes(
              productionStockNotes(
                kind: _kind,
                page: ProductionStockReportPage.items,
                period: _period,
                historyAllowed: _historyAllowed,
                notNormalised: productionStockNotNormalised(
                  _sorted,
                ),
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
    if (_loading)
      return const Center(
        child: CircularProgressIndicator(),
      );
    if (_error != null) {
      return stockErrorView(
        theme,
        () => _load(refreshFromStore: false),
      );
    }
    final res = _result;
    if (res == null || res.totalCount == 0) {
      return stockEmptyView(
        theme,
        hasFilters: _filters.hasAnything,
        filteredText:
            'No ${_kind.singular.toLowerCase()} matches your search and filters',
        emptyText: 'No ${_kind.plural.toLowerCase()} yet',
        onReset: _resetAll,
      );
    }
    final s = _state.sort;
    return StockTableFrame<
      ProductionStockRow,
      ProductionStockPage
    >(
      key: ValueKey('stock-page-${res.page}'),
      theme: theme,
      cols: _columns(theme),
      rows: res.rows,
      totals: res,
      sortKey: (s.field, s.movement),
      ascending: s.ascending,
      onSort: _onSort,
      onTap: _openItem,
      rowKey: (r) => ValueKey('stock-row-${r.uuid}'),
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
          hint: 'Search name, category or department',
          onChanged:
              (v) => _apply(() => _filters.search = v),
          toolbarOpen: _toolbarOpen,
          onToggleToolbar:
              () => setState(
                () => _toolbarOpen = !_toolbarOpen,
              ),
        ),
        if (stockToolbarVisible(context, _toolbarOpen)) ...[
          ReceiptsReportPeriodButton(
            theme: theme,
            period: _period,
            enabled: _env.canPickDate(),
            onChanged: _setPeriod,
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 6.0,
              right: 5,
            ),
            child: ReportPill(
              theme: theme,
              icon: Icons.tune_rounded,
              label:
                  active == 0
                      ? 'Filters'
                      : 'Filters ($active)',
              highlighted: _showFilters || active > 0,
              onTap:
                  () => setState(
                    () => _showFilters = !_showFilters,
                  ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 5,
              right: 5,
            ),
            child: ReportExportButton(
              buildSpec: _exportSpec,
            ),
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
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 5,
          ),
        ],
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 12,
        children: [
          ...productionStockFilterFields(
            context,
            theme: theme,
            kind: _kind,
            filters: _filters,
            choices: _choices,
            departmentsEnabled: _departmentsEnabled,
            canSeeQuantity: _canSeeQuantity,
            onApply: _apply,
          ),
          if (_canSeeCost)
            ReportRangeFields(
              label: 'Cost price range (primary unit)',
              minController: _costMinCtrl,
              maxController: _costMaxCtrl,
              errorText: _filters.costRangeError,
              onChange:
                  (a, b) => _apply(() {
                    _filters.costMin = a;
                    _filters.costMax = b;
                  }),
            ),
          if (_canSeeQuantity)
            ReportRangeFields(
              label: 'Stock range (primary unit)',
              minController: _qtyMinCtrl,
              maxController: _qtyMaxCtrl,
              errorText: _filters.quantityRangeError,
              onChange:
                  (a, b) => _apply(() {
                    _filters.quantityMin = a;
                    _filters.quantityMax = b;
                  }),
            ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------
  // columns
  // ---------------------------------------------------------------

  List<_Col> _columns(ThemeProvider theme) {
    final seeQty = _canSeeQuantity;
    Widget bold(String t) => stockTxt(theme, t, bold: true);
    Widget qtyCell(
      ProductionStockRow r,
      double? v, {
      bool signed = false,
    }) {
      if (!seeQty) return stockTxt(theme, productionMasked);
      if (!r.isManaged || v == null)
        return stockDash(theme);
      return stockTxt(
        theme,
        signed && v > 0 ? '+${_number(v)}' : _number(v),
      );
    }

    _Col qtyCol(
      String label,
      ProductionStockSortField f,
      double? Function(ProductionStockRow r) pick, {
      ProductionMovementKind? movement,
      bool signed = false,
    }) => _Col(
      label: label,
      width: 130,
      sortKey: (f, movement),
      cell: (r) => qtyCell(r, pick(r), signed: signed),
    );

    return [
      _Col(
        label: _kind.singular,
        width: 210,
        sortKey: (ProductionStockSortField.name, null),
        align: TextAlign.start,
        cell:
            (r) => stockTxt(
              theme,
              r.name,
              bold: true,
              align: TextAlign.start,
            ),
        total:
            (_) => stockTxt(
              theme,
              'TOTAL',
              bold: true,
              align: TextAlign.start,
            ),
      ),
      _Col(
        label: 'Primary Unit',
        width: 120,
        sortKey: (ProductionStockSortField.unit, null),
        cell: (r) => stockTxt(theme, r.primaryUnit),
        total:
            (t) =>
                bold('${t.totalCount} ${_kind.countNoun}'),
      ),
      _Col(
        label: 'Stock',
        width: 140,
        sortKey: (ProductionStockSortField.quantity, null),
        cell:
            (r) => stockTxt(
              theme,
              productionStockQuantityText(
                r,
                _number,
                canSeeQuantity: seeQty,
              ),
              color:
                  r.stockLevel == ProductionStockLevel.out
                      ? Colors.red.shade700
                      : null,
            ),
      ),
      if (_kind == ProductionStockKind.material)
        _Col(
          label: 'Low Stock Qty',
          width: 130,
          sortKey: (
            ProductionStockSortField.lowQuantity,
            null,
          ),
          cell:
              (r) =>
                  !seeQty
                      ? stockTxt(theme, productionMasked)
                      : r.lowQuantity == null
                      ? stockDash(theme)
                      : stockTxt(
                        theme,
                        _number(r.lowQuantity!),
                      ),
        ),
      if (_canSeeCost) ...[
        _Col(
          label: 'Cost Price',
          width: 140,
          sortKey: (
            ProductionStockSortField.costPrice,
            null,
          ),
          cell:
              (r) => stockTxt(
                theme,
                _money(r.costPrice),
                tooltip: 'Per ${r.primaryUnit}',
              ),
        ),
        _Col(
          label: 'Stock Value',
          width: 160,
          sortKey: (
            ProductionStockSortField.stockValue,
            null,
          ),
          cell:
              (r) =>
                  !seeQty
                      ? stockTxt(theme, productionMasked)
                      : r.stockValue == null
                      ? stockDash(theme)
                      : bold(_money(r.stockValue!)),
          total:
              (t) =>
                  seeQty
                      ? bold(_money(t.totalStockValue))
                      : stockTxt(theme, productionMasked),
        ),
      ],
      if (_departmentsEnabled)
        _Col(
          label: 'Department',
          width: 160,
          sortKey: (
            ProductionStockSortField.department,
            null,
          ),
          align: TextAlign.start,
          cell:
              (r) => stockTxt(
                theme,
                r.departmentLabel,
                align: TextAlign.start,
                color:
                    r.departmentKey == null
                        ? Colors.grey
                        : null,
              ),
        ),
      _Col(
        label: 'Categories',
        width: 180,
        sortKey: (ProductionStockSortField.category, null),
        align: TextAlign.start,
        cell:
            (r) => stockTxt(
              theme,
              r.categoryLabel,
              align: TextAlign.start,
              color:
                  r.categoryKeys.isEmpty
                      ? Colors.grey
                      : null,
            ),
      ),
      _Col(
        label: 'Expiry',
        width: 160,
        sortKey: (ProductionStockSortField.expiry, null),
        cell:
            (r) =>
                r.expiryDate == null
                    ? stockDash(theme)
                    : stockTxt(
                      theme,
                      r.isExpired
                          ? '${formatDateTime(r.expiryDate!)} (Expired)'
                          : formatDateTime(r.expiryDate!),
                      color:
                          r.isExpired
                              ? Colors.red.shade700
                              : null,
                    ),
      ),
      _Col(
        label: 'Managed',
        width: 100,
        sortKey: (ProductionStockSortField.managed, null),
        cell:
            (r) => stockTxt(
              theme,
              r.isManaged ? 'Yes' : 'No',
              color: r.isManaged ? null : Colors.grey,
            ),
      ),
      _Col(
        label: 'Created',
        width: 130,
        sortKey: (ProductionStockSortField.createdAt, null),
        cell:
            (r) =>
                r.createdAt == null
                    ? stockDash(theme)
                    : stockTxt(
                      theme,
                      formatDateTime(r.createdAt!),
                    ),
      ),
      if (_historyAllowed) ...[
        qtyCol(
          'Opening',
          ProductionStockSortField.opening,
          (r) => r.balance.opening,
        ),
        for (final m in productionMovementColumns(_kind))
          qtyCol(
            m.label,
            ProductionStockSortField.movement,
            (r) => r.movement.of(m),
            movement: m,
          ),
        qtyCol(
          'Net',
          ProductionStockSortField.net,
          (r) => r.movement.net,
          signed: true,
        ),
        qtyCol(
          'Closing',
          ProductionStockSortField.closing,
          (r) => r.balance.closing,
        ),
      ],
      if (_kind == ProductionStockKind.material) ...[
        _usageCol(
          theme,
          'Used in Production',
          ProductionStockSortField.usedInProduction,
          (u) => u.productionQty,
        ),
        _usageCol(
          theme,
          'Used Manually',
          ProductionStockSortField.usedManually,
          (u) => u.manualQty,
        ),
        if (_canSeeCost)
          _Col(
            label: 'Usage Cost',
            width: 150,
            sortKey: (
              ProductionStockSortField.usageCost,
              null,
            ),
            cell:
                (r) => bold(
                  _money(r.materialUsage?.totalCost ?? 0),
                ),
            total: (t) => bold(_money(t.totalUsageCost)),
          ),
      ],
    ];
  }

  /// A material's use, shown for unmanaged materials too.
  _Col _usageCol(
    ThemeProvider theme,
    String label,
    ProductionStockSortField field,
    double Function(ProductionMaterialUsage u) pick,
  ) {
    return _Col(
      label: label,
      width: 150,
      sortKey: (field, null),
      cell: (r) {
        if (!_canSeeQuantity)
          return stockTxt(theme, productionMasked);
        final u = r.materialUsage;
        return u == null
            ? stockDash(theme)
            : stockTxt(theme, _number(pick(u)));
      },
    );
  }
}
