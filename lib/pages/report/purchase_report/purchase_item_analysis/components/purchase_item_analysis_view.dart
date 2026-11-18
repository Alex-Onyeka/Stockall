import 'package:flutter/material.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/report/components/export/report_export_button.dart';
import 'package:stockall/pages/report/components/export/report_export_format.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/report_pill.dart';
import 'package:stockall/pages/report/components/report_range_fields.dart';
import 'package:stockall/pages/report/components/report_searchable_dropdown.dart';
import 'package:stockall/pages/report/components/report_trend_chart.dart';
import 'package:stockall/pages/report/purchase_report/purchase_item_analysis/class/purchase_item_analysis_export_spec.dart';
import 'package:stockall/pages/report/purchase_report/purchase_item_analysis/class/purchase_item_analysis_logic.dart';
import 'package:stockall/pages/report/purchase_report/purchase_item_report/class/purchase_item_report_logic.dart';
import 'package:stockall/pages/report/purchase_report/purchase_item_report/purchase_item_report_page.dart';
import 'package:stockall/pages/report/purchase_report/purchase_report_table/class/purchase_report_table_logic.dart';
import 'package:stockall/pages/report/purchase_report/purchase_report_table/components/purchase_report_table_view.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/components/receipts_report_filter_widgets.dart';
import 'package:stockall/providers/theme_provider.dart';

class _SCol<T> {
  final String label;
  final double width;
  final bool alignStart;
  final Widget Function(T item, int index) cell;
  final PurchaseItemBreakdownSortField? sort;

  const _SCol({
    required this.label,
    required this.width,
    required this.cell,
    this.alignStart = false,
    this.sort,
  });
}

class PurchaseItemAnalysisView extends StatefulWidget {
  final bool isDesktop;
  final ReceiptsReportPeriod? initialPeriod;
  final PurchaseReportEnv? env;

  const PurchaseItemAnalysisView({
    super.key,
    required this.isDesktop,
    this.initialPeriod,
    this.env,
  });

  @override
  State<PurchaseItemAnalysisView> createState() =>
      _PurchaseItemAnalysisViewState();
}

class _PurchaseItemAnalysisViewState
    extends State<PurchaseItemAnalysisView> {
  static const int _preview = 10;

  late final PurchaseReportEnv _env;
  late ReceiptsReportPeriod _period;
  final PurchaseItemFilters _filters =
      PurchaseItemFilters();
  bool _showFilters = false;

  PurchaseItemBreakdownSortField _itemSort =
      PurchaseItemBreakdownSortField.spend;
  bool _itemAsc = false;
  bool _showAllItems = false;

  PurchaseItemBreakdownSortField _supplierSort =
      PurchaseItemBreakdownSortField.spend;
  bool _supplierAsc = false;
  bool _showAllSuppliers = false;

  PurchaseItemBreakdownSortField _deptSort =
      PurchaseItemBreakdownSortField.spend;
  bool _deptAsc = false;
  bool _showAllDepts = false;

  PurchaseItemBreakdownSortField _staffSort =
      PurchaseItemBreakdownSortField.spend;
  bool _staffAsc = false;
  bool _showAllStaff = false;

  bool _loading = true;
  String? _error;
  String _signature = '';
  List<PurchaseItemRow> _allRows = [];
  List<PurchaseItemRow> _periodRows = [];
  PurchaseItemAnalysisResult? _result;

  List<PurchaseFilterOption> _itemOpts = const [];
  List<PurchaseFilterOption> _supplierOpts = const [];
  List<PurchaseFilterOption> _staffOpts = const [];
  List<PurchaseFilterOption> _deptOpts = const [];

  @override
  void initState() {
    super.initState();
    _env = widget.env ?? PurchaseReportEnv.live();
    _period =
        widget.initialPeriod ??
        ReceiptsReportPeriod.today();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load(refreshFromStore: false);
    });
  }

  bool get _departmentsEnabled => _env.departmentsEnabled();
  bool get _hasFilters => _filters.activeFilterCount > 0;

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
    _signature = _env.signature();
    _allRows = PurchaseItemRowBuilder.buildAll(
      purchases: _env.purchases(),
      legacyLines: _env.legacyLines(),
      supplierNames: _env.supplierNames(),
      pendingDeletedUuids: _env.pendingDeletedUuids(),
    );
  }

  void _recompute() {
    _periodRows = PurchaseItemFilterBuilder.inPeriod(
      _allRows,
      _period,
    );
    _itemOpts = PurchaseItemFilterBuilder.items(
      _periodRows,
    );
    _supplierOpts = PurchaseItemFilterBuilder.suppliers(
      _periodRows,
    );
    _staffOpts = PurchaseItemFilterBuilder.staff(
      _periodRows,
    );
    _deptOpts = PurchaseItemFilterBuilder.departments(
      _periodRows,
    );

    _result = PurchaseItemAnalysisBuilder.build(
      allRows: _allRows,
      period: _period,
      departmentsEnabled: _departmentsEnabled,
      filters: _filters,
    );
  }

  void _apply(VoidCallback change) {
    setState(() {
      change();
      _recompute();
    });
  }

  void _resetAll() => _apply(_filters.clearAll);

  void _openTable(PurchaseItemFilters filters) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => PurchaseItemReportPage(
              initialFilters: filters,
              initialPeriod: _period,
              env: widget.env,
            ),
      ),
    );
  }

  String _money(num v) => _env.money(context, v);

  String _percent(double? v) =>
      v == null
          ? 'N/A'
          : '${formatLargeNumberDouble(double.parse(v.toStringAsFixed(1)))}%';

  ReportExportSpec _exportSpec() {
    final res = _result!;
    final items = PurchaseItemAnalysisBuilder.sortBreakdown(
      PurchaseItemAnalysisBuilder.breakdown(
        res,
        PurchaseItemAnalysisTab.items,
        base: _filters,
      ),
      _itemSort,
      _itemAsc,
    );
    return buildPurchaseItemAnalysisExportSpec(
      result: res,
      tab: PurchaseItemAnalysisTab.items,
      rows: items,
      period: _period,
      f: ExportFormatter(
        currency: currencySymbol(context: context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = returnTheme(context);
    _env.listen(context);

    if (!_loading && _error == null) {
      final sig = _env.signature();
      if (sig != _signature) {
        try {
          _rebuildBase();
          _recompute();
        } catch (e) {
          _error = e.toString();
        }
      }
    }

    return Scaffold(
      appBar: appBar(
        context: context,
        title: 'Purchase Item Analysis',
        widget:
            widget.isDesktop
                ? Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      mouseCursor: SystemMouseCursors.click,
                      borderRadius: BorderRadius.circular(
                        10,
                      ),
                      onTap:
                          _loading
                              ? null
                              : () => _load(
                                refreshFromStore: true,
                              ),
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
                                    theme
                                        .mobileTexts
                                        .b3
                                        .fontSize,
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
                )
                : IconButton(
                  tooltip: 'Refresh',
                  icon: const Icon(
                    Icons.refresh_rounded,
                    size: 20,
                  ),
                  onPressed:
                      _loading
                          ? null
                          : () =>
                              _load(refreshFromStore: true),
                ),
      ),
      body:
          _loading
              ? const Center(
                child: CircularProgressIndicator(),
              )
              : _error != null
              ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 10,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 40,
                      color:
                          theme
                              .lightModeColor
                              .errorColor200,
                    ),
                    Text(
                      'The analysis could not be generated.',
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b2.fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed:
                          () => _load(
                            refreshFromStore: false,
                          ),
                      icon: const Icon(
                        Icons.refresh_rounded,
                      ),
                      label: const Text('Try again'),
                    ),
                  ],
                ),
              )
              : _body(theme),
    );
  }

  Widget _body(ThemeProvider theme) {
    final res = _result!;
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: widget.isDesktop ? 20 : 12,
        vertical: 10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          _toolbar(theme),
          if (_showFilters) _filterPanel(theme),
          if (res.stats.lineCount == 0)
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: EmptyWidgetDisplayOnly(
                title:
                    _hasFilters
                        ? 'No Matching Item Records'
                        : 'Empty List',
                subText:
                    _hasFilters
                        ? 'No purchase item record matches your filters'
                        : 'No purchase item was recorded in this period',
                theme: theme,
                height: 35,
                icon: Icons.clear,
                altAction: _hasFilters ? _resetAll : null,
                altActionText:
                    _hasFilters
                        ? 'Clear all filters'
                        : null,
                altIcon:
                    _hasFilters
                        ? Icons.filter_alt_off
                        : null,
              ),
            )
          else ...[
            _statCards(theme, res.stats),
            _pair([
              _trendCard(theme, res),
              _activityCard(theme, res.stats),
            ]),
            _pair([
              _rankingCard(
                theme,
                title: 'Top 3 Items',
                groups: PurchaseItemAnalysisBuilder.top3(
                  res.items,
                ),
                nameLabel: 'Item',
                onTap:
                    (g) => _openTable(
                      _filters.copy()..itemKey = g.key,
                    ),
              ),
              _rankingCard(
                theme,
                title: 'Least 3 Items',
                groups: PurchaseItemAnalysisBuilder.least3(
                  res.items,
                ),
                nameLabel: 'Item',
                onTap:
                    (g) => _openTable(
                      _filters.copy()..itemKey = g.key,
                    ),
              ),
            ]),
            _pair([
              _rankingCard(
                theme,
                title: 'Top 3 Suppliers',
                groups: PurchaseItemAnalysisBuilder.top3(
                  res.suppliers,
                ),
                nameLabel: 'Supplier',
                onTap:
                    (g) => _openTable(
                      _filters.copy()..supplierKey = g.key,
                    ),
              ),
              _rankingCard(
                theme,
                title: 'Least 3 Suppliers',
                groups: PurchaseItemAnalysisBuilder.least3(
                  res.suppliers,
                ),
                nameLabel: 'Supplier',
                onTap:
                    (g) => _openTable(
                      _filters.copy()..supplierKey = g.key,
                    ),
              ),
            ]),
            _pair([
              _rankingCard(
                theme,
                title: 'Top 3 Staff',
                groups: PurchaseItemAnalysisBuilder.top3(
                  res.staff,
                ),
                nameLabel: 'Staff',
                onTap:
                    (g) => _openTable(
                      _filters.copy()..staffKey = g.key,
                    ),
              ),
              _rankingCard(
                theme,
                title: 'Least 3 Staff',
                groups: PurchaseItemAnalysisBuilder.least3(
                  res.staff,
                ),
                nameLabel: 'Staff',
                onTap:
                    (g) => _openTable(
                      _filters.copy()..staffKey = g.key,
                    ),
              ),
            ]),
            _pair([
              _channelCard(theme, res),
              _typeCard(theme, res),
            ]),
            _itemsCard(theme, res),
            _suppliersCard(theme, res),
            if (_departmentsEnabled)
              _departmentsCard(theme, res),
            _staffCard(theme, res),
          ],
        ],
      ),
    );
  }

  Widget _pair(List<Widget> children) {
    if (!widget.isDesktop) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: children,
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        for (final c in children) Expanded(child: c),
      ],
    );
  }

  Widget _toolbar(ThemeProvider theme) {
    final active = _filters.activeFilterCount;
    return Wrap(
      spacing: 6,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ReceiptsReportPeriodButton(
          theme: theme,
          period: _period,
          enabled: _env.canPickDate(),
          onChanged: (p) {
            _apply(() => _period = p);
            if (!p.isAllTime) {
              _load(refreshFromStore: false);
            }
          },
        ),
        ReportPill(
          theme: theme,
          icon: Icons.tune_rounded,
          label:
              active == 0 ? 'Filters' : 'Filters ($active)',
          highlighted: _showFilters || active > 0,
          onTap:
              () => setState(
                () => _showFilters = !_showFilters,
              ),
        ),
        if (_result != null)
          ReportExportButton(buildSpec: _exportSpec),
        if (_hasFilters)
          ReportPill(
            theme: theme,
            icon: Icons.filter_alt_off,
            label: 'Reset All Filters',
            onTap: _resetAll,
            color: theme.lightModeColor.prColor300,
          ),
      ],
    );
  }

  Widget _filterPanel(ThemeProvider theme) {
    Widget keyDropdown({
      required String title,
      required String allLabel,
      required String? value,
      required List<PurchaseFilterOption> options,
      required ValueChanged<String?> onChanged,
      bool showSearch = true,
    }) {
      return ReportLabeledField(
        label: title,
        width: 210,
        child: ReportSearchableDropdown<String?>(
          theme: theme,
          title: title,
          value: value,
          showSearch: showSearch,
          options: [
            ReportSearchableOption(
              value: null,
              label: allLabel,
            ),
            for (final o in options)
              ReportSearchableOption(
                value: o.key,
                label: o.label,
              ),
          ],
          onChanged: onChanged,
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 10,
        children: [
          keyDropdown(
            title: 'Item',
            allLabel: 'All Items',
            value: _filters.itemKey,
            options: _itemOpts,
            onChanged:
                (v) => _apply(() => _filters.itemKey = v),
          ),
          keyDropdown(
            title: 'Supplier',
            allLabel: 'All Suppliers',
            value: _filters.supplierKey,
            options: _supplierOpts,
            onChanged:
                (v) =>
                    _apply(() => _filters.supplierKey = v),
          ),
          keyDropdown(
            title: 'Staff',
            allLabel: 'All Staff',
            value: _filters.staffKey,
            options: _staffOpts,
            onChanged:
                (v) => _apply(() => _filters.staffKey = v),
          ),
          if (_departmentsEnabled)
            keyDropdown(
              title: 'Department',
              allLabel: 'All Departments',
              value: _filters.departmentKey,
              options: _deptOpts,
              onChanged:
                  (v) => _apply(
                    () => _filters.departmentKey = v,
                  ),
            ),
          keyDropdown(
            title: 'Channel',
            allLabel: 'All Channels',
            value: _filters.channelKey,
            options: PurchaseReportOptions.channels(),
            showSearch: false,
            onChanged:
                (v) =>
                    _apply(() => _filters.channelKey = v),
          ),
          ReportLabeledField(
            label: 'Status',
            width: 190,
            child:
                ReportSearchableDropdown<PurchaseStatus?>(
                  theme: theme,
                  title: 'Status',
                  value: _filters.status,
                  showSearch: false,
                  options: [
                    const ReportSearchableOption(
                      value: null,
                      label: 'All Statuses',
                    ),
                    for (final s in PurchaseStatus.values)
                      ReportSearchableOption(
                        value: s,
                        label: s.label,
                      ),
                  ],
                  onChanged:
                      (v) =>
                          _apply(() => _filters.status = v),
                ),
          ),
          ReportLabeledField(
            label: 'Item Type',
            width: 190,
            child: ReportSearchableDropdown<
              PurchaseItemTypeFilter
            >(
              theme: theme,
              title: 'Item Type',
              value: _filters.itemType,
              showSearch: false,
              options: [
                for (final t
                    in PurchaseItemTypeFilter.values)
                  ReportSearchableOption(
                    value: t,
                    label: t.label,
                  ),
              ],
              onChanged:
                  (v) =>
                      _apply(() => _filters.itemType = v),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(
    ThemeProvider theme, {
    required String title,
    String? subtitle,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 2,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: theme.mobileTexts.b2.fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
            ],
          ),
          child,
        ],
      ),
    );
  }

  Widget _statCards(
    ThemeProvider theme,
    PurchaseItemAnalysisStats s,
  ) {
    final width =
        widget.isDesktop
            ? 210.0
            : ((MediaQuery.of(context).size.width -
                        24 -
                        10) /
                    2)
                .clamp(130.0, 400.0);

    Widget stat(
      String label,
      String value, {
      String? sub,
      IconData icon = Icons.inventory_2_rounded,
      VoidCallback? onTap,
    }) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: width,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              Row(
                spacing: 6,
                children: [
                  Icon(
                    icon,
                    size: 15,
                    color: theme.lightModeColor.prColor300,
                  ),
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: theme.mobileTexts.h4.fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (sub != null)
                Text(
                  sub,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        stat(
          'Total Spend',
          _money(s.totalSpend),
          sub: 'Avg/line ${_money(s.averageLineValue)}',
          icon: Icons.payments_rounded,
          onTap: () => _openTable(_filters.copy()),
        ),
        stat(
          'Total Quantity',
          formatLargeNumberDouble(s.totalQuantity),
          sub: 'Avg cost ${_money(s.averageUnitCost)}',
          icon: Icons.inventory_2_rounded,
          onTap: () => _openTable(_filters.copy()),
        ),
        stat(
          'Item Lines',
          '${s.lineCount}',
          sub: '${s.distinctItems} distinct items',
          icon: Icons.list_alt_rounded,
          onTap: () => _openTable(_filters.copy()),
        ),
        stat(
          'Purchases',
          '${s.purchaseCount}',
          sub: '${s.distinctSuppliers} suppliers',
          icon: Icons.receipt_long_rounded,
          onTap: () => _openTable(_filters.copy()),
        ),
        stat(
          'Sales Items',
          _money(s.salesItemSpend),
          sub: '${s.salesItemLines} lines',
          icon: Icons.storefront_rounded,
          onTap:
              () => _openTable(
                _filters.copy()
                  ..itemType = PurchaseItemTypeFilter.sales,
              ),
        ),
        stat(
          'Storage Items',
          _money(s.storageItemSpend),
          sub: '${s.storageItemLines} lines',
          icon: Icons.warehouse_rounded,
          onTap:
              () => _openTable(
                _filters.copy()
                  ..itemType =
                      PurchaseItemTypeFilter.storage,
              ),
        ),
      ],
    );
  }

  Widget _trendCard(
    ThemeProvider theme,
    PurchaseItemAnalysisResult res,
  ) {
    return _card(
      theme,
      title: 'Purchase Spend Trend',
      subtitle: reportTrendIntervalLabel(res.interval),
      child:
          res.trend.isEmpty
              ? _emptyTableText(
                'No trend data in this period',
              )
              : ReportTrendChart(
                starts: [
                  for (final p in res.trend) p.start,
                ],
                interval: res.interval,
                series: [
                  ReportTrendSeries(
                    label: 'Spend',
                    color: theme.lightModeColor.prColor300,
                    values: [
                      for (final p in res.trend) p.spend,
                    ],
                  ),
                ],
                money: _money,
              ),
    );
  }

  Widget _activityCard(
    ThemeProvider theme,
    PurchaseItemAnalysisStats s,
  ) {
    Widget row(String label, String value) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: theme.mobileTexts.b3.fontSize,
                color: Colors.grey.shade700,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: theme.mobileTexts.b3.fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return _card(
      theme,
      title: 'Activity & Averages',
      subtitle: 'Line item purchase summary',
      child: Column(
        children: [
          row('Distinct Items', '${s.distinctItems}'),
          const Divider(height: 1),
          row(
            'Distinct Suppliers',
            '${s.distinctSuppliers}',
          ),
          const Divider(height: 1),
          row(
            'Custom Price Lines',
            '${s.customPriceLines} of ${s.lineCount}',
          ),
          const Divider(height: 1),
          row('Avg Line Spend', _money(s.averageLineValue)),
          const Divider(height: 1),
          row('Avg Unit Cost', _money(s.averageUnitCost)),
        ],
      ),
    );
  }

  Widget _emptyTableText([
    String text = 'No data in this period.',
  ]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _miniTable<T>(
    ThemeProvider theme, {
    required List<_SCol<T>> columns,
    required List<T> items,
    PurchaseItemBreakdownSortField? sortField,
    bool ascending = false,
    void Function(PurchaseItemBreakdownSortField f)? onSort,
    void Function(T item)? onTap,
  }) {
    final totalWidth = columns.fold<double>(
      0,
      (s, c) => s + c.width,
    );
    final accent = theme.lightModeColor.prColor300;
    return LayoutBuilder(
      builder: (context, constraints) {
        final w =
            totalWidth > constraints.maxWidth
                ? totalWidth
                : constraints.maxWidth;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: w,
            child: Column(
              children: [
                Container(
                  height: 38,
                  color: accent.withAlpha(20),
                  child: Row(
                    children: [
                      for (final c in columns)
                        SizedBox(
                          width: c.width,
                          child: InkWell(
                            onTap:
                                (c.sort != null &&
                                        onSort != null)
                                    ? () => onSort(c.sort!)
                                    : null,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                              child: Row(
                                mainAxisAlignment:
                                    c.alignStart
                                        ? MainAxisAlignment
                                            .start
                                        : MainAxisAlignment
                                            .end,
                                children: [
                                  Flexible(
                                    child: Text(
                                      c.label,
                                      maxLines: 1,
                                      overflow:
                                          TextOverflow
                                              .ellipsis,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight:
                                            FontWeight.bold,
                                        color:
                                            c.sort !=
                                                        null &&
                                                    c.sort ==
                                                        sortField
                                                ? accent
                                                : Colors
                                                    .black87,
                                      ),
                                    ),
                                  ),
                                  if (c.sort != null &&
                                      onSort != null) ...[
                                    const SizedBox(
                                      width: 2,
                                    ),
                                    Icon(
                                      c.sort == sortField
                                          ? (ascending
                                              ? Icons
                                                  .arrow_upward_rounded
                                              : Icons
                                                  .arrow_downward_rounded)
                                          : Icons
                                              .unfold_more_rounded,
                                      size: 13,
                                      color:
                                          c.sort ==
                                                  sortField
                                              ? accent
                                              : Colors.grey,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                for (var i = 0; i < items.length; i++)
                  Material(
                    color:
                        i.isEven
                            ? Colors.white
                            : Colors.grey.shade50,
                    child: InkWell(
                      onTap:
                          onTap == null
                              ? null
                              : () => onTap(items[i]),
                      hoverColor: accent.withAlpha(18),
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey.shade200,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            for (final c in columns)
                              SizedBox(
                                width: c.width,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                  child: Align(
                                    alignment:
                                        c.alignStart
                                            ? Alignment
                                                .centerLeft
                                            : Alignment
                                                .centerRight,
                                    child: c.cell(
                                      items[i],
                                      i,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<_SCol<PurchaseItemGroup>> _groupColumns(
    ThemeProvider theme, {
    required String nameLabel,
    bool sortable = false,
  }) {
    Text cellText(
      String t, {
      Color? color,
      FontWeight? weight,
    }) => Text(
      t,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 12,
        color: color,
        fontWeight: weight,
      ),
    );

    return [
      _SCol<PurchaseItemGroup>(
        label: nameLabel,
        width: 170,
        alignStart: true,
        sort:
            sortable
                ? PurchaseItemBreakdownSortField.name
                : null,
        cell:
            (g, _) => cellText(
              g.label,
              color:
                  g.isNone
                      ? Colors.grey
                      : theme.lightModeColor.prColor300,
              weight: FontWeight.w600,
            ),
      ),
      _SCol<PurchaseItemGroup>(
        label: 'Lines',
        width: 65,
        sort:
            sortable
                ? PurchaseItemBreakdownSortField.lines
                : null,
        cell: (g, _) => cellText('${g.lineCount}'),
      ),
      _SCol<PurchaseItemGroup>(
        label: 'Qty',
        width: 75,
        sort:
            sortable
                ? PurchaseItemBreakdownSortField.qty
                : null,
        cell:
            (g, _) => cellText(
              formatLargeNumberDouble(g.quantity),
            ),
      ),
      _SCol<PurchaseItemGroup>(
        label: 'Spend',
        width: 110,
        sort:
            sortable
                ? PurchaseItemBreakdownSortField.spend
                : null,
        cell:
            (g, _) => cellText(
              _money(g.spend),
              weight: FontWeight.w600,
            ),
      ),
      _SCol<PurchaseItemGroup>(
        label: 'Share',
        width: 70,
        sort:
            sortable
                ? PurchaseItemBreakdownSortField.share
                : null,
        cell: (g, _) => cellText(_percent(g.spendShare)),
      ),
    ];
  }

  Widget _rankingCard(
    ThemeProvider theme, {
    required String title,
    required List<PurchaseItemGroup> groups,
    required String nameLabel,
    required void Function(PurchaseItemGroup g) onTap,
  }) {
    return _card(
      theme,
      title: title,
      subtitle: 'By total spend',
      child:
          groups.isEmpty
              ? _emptyTableText()
              : _miniTable<PurchaseItemGroup>(
                theme,
                columns: _groupColumns(
                  theme,
                  nameLabel: nameLabel,
                ),
                items: groups,
                onTap: onTap,
              ),
    );
  }

  Widget _channelCard(
    ThemeProvider theme,
    PurchaseItemAnalysisResult res,
  ) {
    return _card(
      theme,
      title: 'Payment Channels',
      subtitle: 'Spend by payment channel',
      child:
          res.channels.isEmpty
              ? _emptyTableText()
              : _miniTable<PurchaseItemGroup>(
                theme,
                columns: _groupColumns(
                  theme,
                  nameLabel: 'Channel',
                ),
                items: res.channels,
                onTap:
                    (g) => _openTable(
                      _filters.copy()..channelKey = g.key,
                    ),
              ),
    );
  }

  Widget _typeCard(
    ThemeProvider theme,
    PurchaseItemAnalysisResult res,
  ) {
    return _card(
      theme,
      title: 'Item Types',
      subtitle: 'Sales vs Storage items',
      child:
          res.itemTypes.isEmpty
              ? _emptyTableText()
              : _miniTable<PurchaseItemGroup>(
                theme,
                columns: _groupColumns(
                  theme,
                  nameLabel: 'Type',
                ),
                items: res.itemTypes,
                onTap: (g) {
                  final f =
                      _filters.copy()
                        ..itemType =
                            g.key == 'storage'
                                ? PurchaseItemTypeFilter
                                    .storage
                                : PurchaseItemTypeFilter
                                    .sales;
                  _openTable(f);
                },
              ),
    );
  }

  Widget _sortableCard(
    ThemeProvider theme, {
    required String title,
    required String subtitle,
    required String nameLabel,
    required List<PurchaseItemGroup> groups,
    required PurchaseItemBreakdownSortField sortField,
    required bool ascending,
    required bool showAll,
    required void Function(PurchaseItemBreakdownSortField f)
    onSort,
    required VoidCallback onToggleAll,
    required void Function(PurchaseItemGroup g) onTap,
  }) {
    final sorted = List<PurchaseItemGroup>.from(groups)
      ..sort((a, b) {
        int cmp;
        switch (sortField) {
          case PurchaseItemBreakdownSortField.name:
            cmp = a.label.toLowerCase().compareTo(
              b.label.toLowerCase(),
            );
            break;
          case PurchaseItemBreakdownSortField.lines:
            cmp = a.lineCount.compareTo(b.lineCount);
            break;
          case PurchaseItemBreakdownSortField.qty:
            cmp = a.quantity.compareTo(b.quantity);
            break;
          case PurchaseItemBreakdownSortField.spend:
            cmp = a.spend.compareTo(b.spend);
            break;
          case PurchaseItemBreakdownSortField.share:
            cmp = (a.spendShare ?? 0).compareTo(
              b.spendShare ?? 0,
            );
            break;
        }
        if (cmp == 0) {
          cmp = a.label.toLowerCase().compareTo(
            b.label.toLowerCase(),
          );
        }
        return ascending ? cmp : -cmp;
      });
    final shown =
        showAll || sorted.length <= _preview
            ? sorted
            : sorted.take(_preview).toList();

    return _card(
      theme,
      title: title,
      subtitle: subtitle,
      child:
          sorted.isEmpty
              ? _emptyTableText()
              : Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch,
                children: [
                  _miniTable<PurchaseItemGroup>(
                    theme,
                    columns: _groupColumns(
                      theme,
                      nameLabel: nameLabel,
                      sortable: true,
                    ),
                    items: shown,
                    sortField: sortField,
                    ascending: ascending,
                    onSort: onSort,
                    onTap: onTap,
                  ),
                  if (sorted.length > _preview)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: onToggleAll,
                        child: Text(
                          showAll
                              ? 'Show fewer'
                              : 'Show all ${sorted.length}',
                        ),
                      ),
                    ),
                ],
              ),
    );
  }

  Widget _itemsCard(
    ThemeProvider theme,
    PurchaseItemAnalysisResult res,
  ) {
    return _sortableCard(
      theme,
      title: 'Items',
      subtitle:
          'Tap a row to open its purchase item records',
      nameLabel: 'Item',
      groups: res.items,
      sortField: _itemSort,
      ascending: _itemAsc,
      showAll: _showAllItems,
      onSort: (f) {
        setState(() {
          if (_itemSort == f) {
            _itemAsc = !_itemAsc;
          } else {
            _itemSort = f;
            _itemAsc =
                f == PurchaseItemBreakdownSortField.name;
          }
        });
      },
      onToggleAll:
          () => setState(
            () => _showAllItems = !_showAllItems,
          ),
      onTap:
          (g) =>
              _openTable(_filters.copy()..itemKey = g.key),
    );
  }

  Widget _suppliersCard(
    ThemeProvider theme,
    PurchaseItemAnalysisResult res,
  ) {
    return _sortableCard(
      theme,
      title: 'Suppliers',
      subtitle:
          'Tap a row to open purchases from that supplier',
      nameLabel: 'Supplier',
      groups: res.suppliers,
      sortField: _supplierSort,
      ascending: _supplierAsc,
      showAll: _showAllSuppliers,
      onSort: (f) {
        setState(() {
          if (_supplierSort == f) {
            _supplierAsc = !_supplierAsc;
          } else {
            _supplierSort = f;
            _supplierAsc =
                f == PurchaseItemBreakdownSortField.name;
          }
        });
      },
      onToggleAll:
          () => setState(
            () => _showAllSuppliers = !_showAllSuppliers,
          ),
      onTap:
          (g) => _openTable(
            _filters.copy()..supplierKey = g.key,
          ),
    );
  }

  Widget _departmentsCard(
    ThemeProvider theme,
    PurchaseItemAnalysisResult res,
  ) {
    return _sortableCard(
      theme,
      title: 'Departments',
      subtitle:
          'Tap a row to open purchases for that department',
      nameLabel: 'Department',
      groups: res.departments,
      sortField: _deptSort,
      ascending: _deptAsc,
      showAll: _showAllDepts,
      onSort: (f) {
        setState(() {
          if (_deptSort == f) {
            _deptAsc = !_deptAsc;
          } else {
            _deptSort = f;
            _deptAsc =
                f == PurchaseItemBreakdownSortField.name;
          }
        });
      },
      onToggleAll:
          () => setState(
            () => _showAllDepts = !_showAllDepts,
          ),
      onTap:
          (g) => _openTable(
            _filters.copy()..departmentKey = g.key,
          ),
    );
  }

  Widget _staffCard(
    ThemeProvider theme,
    PurchaseItemAnalysisResult res,
  ) {
    return _sortableCard(
      theme,
      title: 'Staff',
      subtitle:
          'Tap a row to open purchases recorded by that staff member',
      nameLabel: 'Staff',
      groups: res.staff,
      sortField: _staffSort,
      ascending: _staffAsc,
      showAll: _showAllStaff,
      onSort: (f) {
        setState(() {
          if (_staffSort == f) {
            _staffAsc = !_staffAsc;
          } else {
            _staffSort = f;
            _staffAsc =
                f == PurchaseItemBreakdownSortField.name;
          }
        });
      },
      onToggleAll:
          () => setState(
            () => _showAllStaff = !_showAllStaff,
          ),
      onTap:
          (g) =>
              _openTable(_filters.copy()..staffKey = g.key),
    );
  }
}
