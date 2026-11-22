import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/pages/report/components/report_period_loader.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/report/components/export/report_export_button.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/report_pill.dart';
import 'package:stockall/pages/report/sales_report_/item_sales_analysis/class/item_sales_analysis_export_spec.dart';
import 'package:stockall/pages/report/sales_report_/item_sales_analysis/class/item_sales_analysis_logic.dart';
import 'package:stockall/pages/report/sales_report_/item_sales_report_main/class/item_sales_report_logic.dart';
import 'package:stockall/pages/report/sales_report_/item_sales_report_main/components/item_sales_report_filter_widgets.dart';
import 'package:stockall/pages/report/sales_report_/item_sales_report_main/item_sales_report_main_page.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/components/receipts_report_filter_widgets.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_summary/class/receipts_report_summary_logic.dart';
import 'package:stockall/providers/theme_provider.dart';

/// One column of a summary table.
class _SCol<T> {
  final String label;
  final double width;
  final bool alignStart;
  final Widget Function(T item, int index) cell;
  final ItemSalesGroupSortField? sort;

  const _SCol({
    required this.label,
    required this.width,
    required this.cell,
    this.alignStart = false,
    this.sort,
  });
}

/// Shared body of the Item Sales Analysis page (desktop + mobile).
///
/// Opens on today's business day with no filters. It is reached
/// only from its Sales Reports tile; its rows open the Item Sales
/// Report filtered on them, never the other way round.
class ItemSalesAnalysisView extends StatefulWidget {
  final bool isDesktop;

  const ItemSalesAnalysisView({
    super.key,
    required this.isDesktop,
  });

  @override
  State<ItemSalesAnalysisView> createState() =>
      _ItemSalesAnalysisViewState();
}

class _ItemSalesAnalysisViewState
    extends State<ItemSalesAnalysisView> {
  final _filters = ItemSalesFilters();
  late ReceiptsReportPeriod _period;
  bool _showFilters = false;

  bool _loading = true;
  String? _error;
  String _signature = '';

  List<ItemSalesRow> _baseRows = [];
  ReceiptsFilterChoices _choices =
      ReceiptsFilterChoices.empty;
  List<ReceiptsFilterOption> _categoryOptions = [];
  List<ReceiptsFilterOption> _allItemOptions = [];
  List<ReceiptsFilterOption> _itemOptions = [];

  // Results for the current period and filters.
  List<ItemSalesRow> _rows = [];
  ItemSalesSummaryStats _stats =
      ItemSalesAnalysisBuilder.stats(const []);
  List<ItemSalesSummaryGroup> _items = [];
  List<ItemSalesSummaryGroup> _categories = [];
  List<ItemSalesSummaryGroup> _customers = [];
  List<ItemSalesSummaryGroup> _staff = [];
  List<ItemSalesSummaryGroup> _subStaff = [];
  List<ItemSalesSummaryGroup> _departments = [];
  List<ItemSalesChannelSummary> _channels = [];
  List<ItemSalesTypeSummary> _types = [];
  List<ItemSalesTrendPoint> _trend = [];
  ReceiptsTrendInterval _interval =
      ReceiptsTrendInterval.daily;
  bool _cartDiscountInView = false;

  ItemSalesGroupSortField _itemSort =
      ItemSalesGroupSortField.revenue;
  bool _itemAscending = false;
  bool _showAllItems = false;

  ItemSalesGroupSortField _customerSort =
      ItemSalesGroupSortField.revenue;
  bool _customerAscending = false;
  bool _showAllCustomers = false;

  static const int _preview = 20;

  @override
  void initState() {
    super.initState();
    _period = ReceiptsReportPeriod.today();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load(refreshFromStore: true);
    });
  }

  // ---------------------------------------------------------------
  // data
  // ---------------------------------------------------------------

  bool get _departmentsEnabled =>
      shopSingle()?.manageDepartments == true;

  bool get _subStaffEnabled =>
      shopSingle()?.bulkSale == true;

  bool get _canSeeCost => authorization(
    authorized: Authorizations().manageCostPrice,
  );

  bool get _canPickDate =>
      authorization(authorized: Authorizations().viewDate);

  Future<void> _load({
    required bool refreshFromStore,
  }) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await loadReceiptsForReportPeriod(
        context,
        period: _period,
        refreshFromStore: refreshFromStore,
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

  // Same signature as the Item Sales table, so both refresh on the
  // same changes.
  String _sourceSignature() {
    final provider = returnReceiptProviderSingle();
    int latest = 0;
    int withItems = 0;
    double total = 0;
    for (final r in provider.receipts) {
      final t = r.createdAt.millisecondsSinceEpoch;
      if (t > latest) latest = t;
      if (r.items?.isNotEmpty == true) withItems++;
      total += r.getTotalRevenue();
    }
    return '${provider.receipts.length}|$latest|$total|'
        '$withItems|${provider.mainSales.length}|'
        '${returnData().productListMain.length}|'
        '${returnCategoriesProvider().categoriesMain.length}|'
        '${returnDepartmentProvider().currentDepartment()?.uuid}|'
        '${currentUser().userId}|$_departmentsEnabled';
  }

  void _rebuildBase() {
    final provider = returnReceiptProviderSingle();
    final scoped = ReceiptsReportAccess.scope(
      receipts: provider.receipts,
      departmentsEnabled: _departmentsEnabled,
      canViewAllDepartments: authorization(
        authorized: Authorizations().viewAllDepartments,
      ),
      currentDepartmentUuid:
          returnDepartmentProvider()
              .currentDepartment()
              ?.uuid,
      canViewAllTransactions: authorization(
        authorized:
            Authorizations().viewAllTransactionRecords,
      ),
      currentUserId: currentUser().userId,
    );
    // All items, not the department view: a line keeps its
    // category even when its item belongs to another department.
    final products = <String, TempProductClass>{
      for (final p in returnData().productListMain)
        if (p.uuid != null) p.uuid!: p,
    };
    final categoryNames = {
      for (final c
          in returnCategoriesProvider().categoriesMain)
        c.uuid: c.name,
    };
    _baseRows = ItemSalesRowBuilder.buildAll(
      receipts: scoped,
      legacySales: provider.mainSales,
      productsByUuid: products,
      categoryNameByUuid: categoryNames,
    );
    _choices = ReceiptsFilterChoices.fromRows(
      {for (final r in _baseRows) r.parent}.toList(),
    );
    _categoryOptions = ItemSalesOptions.categories(
      categoryNames,
      _baseRows,
    );
    _allItemOptions = ItemSalesOptions.items(_baseRows);
    _signature = _sourceSignature();
  }

  void _recompute() {
    _rows = ItemSalesQuery.filterAndSort(
      rows: _baseRows,
      period: _period,
      filters: _filters,
      sortField: ItemSalesSortField.createdAt,
      ascending: false,
      departmentsEnabled: _departmentsEnabled,
      subStaffEnabled: _subStaffEnabled,
      profitVisible: _canSeeCost,
    );
    _stats = ItemSalesAnalysisBuilder.stats(_rows);
    _items = ItemSalesAnalysisBuilder.items(_rows);
    _categories = ItemSalesAnalysisBuilder.categories(_rows);
    _customers = ItemSalesAnalysisBuilder.customers(_rows);
    _staff = ItemSalesAnalysisBuilder.staff(_rows);
    _subStaff = ItemSalesAnalysisBuilder.subStaff(_rows);
    _departments = ItemSalesAnalysisBuilder.departments(
      _rows,
    );
    _channels = ItemSalesAnalysisBuilder.channels(_rows);
    _types = ItemSalesAnalysisBuilder.types(_rows);
    _trend = ItemSalesTrendBuilder.build(
      rows: _rows,
      period: _period,
    );
    final span = ItemSalesTrendBuilder.span(
      rows: _rows,
      period: _period,
      now: DateTime.now(),
    );
    _interval =
        span == null
            ? ReceiptsTrendInterval.daily
            : ReceiptsTrendBuilder.intervalFor(
              span.start,
              span.end,
            );
    _cartDiscountInView = _rows.any(
      (r) =>
          r.parent.receipt.generalDiscount != null ||
          r.parent.receipt.fixedDiscount != null,
    );
    _itemOptions =
        _filters.categoryKey == null
            ? _allItemOptions
            : ItemSalesOptions.items(
              _baseRows,
              categoryOf: _filters,
            );
  }

  void _apply(VoidCallback change) {
    setState(() {
      change();
      try {
        _recompute();
        _error = null;
      } catch (e) {
        _error = e.toString();
      }
    });
  }

  void _resetAll() => _apply(_filters.clearAll);

  /// Opens the table on the analysis's period and filters, plus
  /// the clicked row's key.
  void _openTable(ItemSalesFilters filters) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ItemSalesReportMainPage(
              initialFilters: filters,
              initialPeriod: _period,
            ),
      ),
    );
  }

  // ---------------------------------------------------------------
  // formatting
  // ---------------------------------------------------------------

  String _money(num v) =>
      formatMoneyBig(amount: v, context: context);

  String _percent(double? v) =>
      v == null
          ? 'N/A'
          : '${formatLargeNumberDouble(double.parse(v.toStringAsFixed(1)))}%';

  Color? _signColor(ThemeProvider theme, double v) =>
      v > 0
          ? Colors.green.shade700
          : (v < 0
              ? theme.lightModeColor.errorColor200
              : null);

  String _bucketLabel(DateTime d) {
    switch (_interval) {
      case ReceiptsTrendInterval.hourly:
        return DateFormat('ha').format(d);
      case ReceiptsTrendInterval.daily:
      case ReceiptsTrendInterval.weekly:
        return formatMonthAndDay(d);
      case ReceiptsTrendInterval.monthly:
        return DateFormat('MMM yy').format(d);
    }
  }

  String get _intervalLabel {
    switch (_interval) {
      case ReceiptsTrendInterval.hourly:
        return 'Hourly';
      case ReceiptsTrendInterval.daily:
        return 'Daily';
      case ReceiptsTrendInterval.weekly:
        return 'Weekly (from Monday)';
      case ReceiptsTrendInterval.monthly:
        return 'Monthly';
    }
  }

  static Color _typeColor(ReceiptType t) {
    switch (t) {
      case ReceiptType.sales:
        return Colors.blueGrey;
      case ReceiptType.invoicePayment:
        return Colors.deepPurple;
      case ReceiptType.orderDelivery:
        return Colors.teal;
      case ReceiptType.unknown:
        return Colors.orange.shade800;
    }
  }

  // ---------------------------------------------------------------
  // build
  // ---------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = returnTheme(context);
    // Listen, so sales, edits, sync, items and categories update
    // the analysis.
    returnReceiptProvider(context);
    returnData(context: context);
    returnCategoriesProvider(context: context);
    shop(context);

    if (!_loading && _error == null) {
      final sig = _sourceSignature();
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
        title: 'Item Sales Analysis',
        widget: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Refresh',
              icon: const Icon(
                Icons.refresh_rounded,
                size: 20,
              ),
              onPressed:
                  _loading
                      ? null
                      : () => _load(refreshFromStore: true),
            ),
            const SizedBox(width: 6),
          ],
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
    if (_error != null) {
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
              'The analysis could not be generated.',
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
          if (_showFilters) _filterPanel(),
          ItemSalesFilterChips(
            theme: theme,
            filters: _filters,
            categoryOptions: _categoryOptions,
            itemOptions: _allItemOptions,
            onApply: _apply,
          ),
          ReceiptsReportFilterChips(
            theme: theme,
            filters: _filters.receipt,
            choices: _choices,
            departmentsEnabled: _departmentsEnabled,
            subStaffEnabled: _subStaffEnabled,
            profitVisible: _canSeeCost,
            showSearch: true,
            money: _money,
            onApply: _apply,
          ),
          _notes(),
          if (_rows.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: EmptyWidgetDisplayOnly(
                title:
                    _filters.hasAnything
                        ? 'No Matching Item Records'
                        : 'Empty List',
                subText:
                    _filters.hasAnything
                        ? 'No item record matches your filters'
                        : 'No item was sold in this period',
                theme: theme,
                height: 35,
                icon: Icons.clear,
                altAction:
                    _filters.hasAnything ? _resetAll : null,
                altActionText:
                    _filters.hasAnything
                        ? 'Clear all filters'
                        : null,
                altIcon:
                    _filters.hasAnything
                        ? Icons.filter_alt_off
                        : null,
              ),
            )
          else ...[
            _statCards(theme),
            _pair([
              _trendCard(theme),
              _activityCard(theme),
            ]),
            _pair([
              _rankingCard(
                theme,
                title: 'Top 3 Items',
                groups: ItemSalesAnalysisBuilder.top3(_items),
                nameLabel: 'Item',
                onTap:
                    (g) => _openTable(
                      ItemSalesAnalysisBuilder.handoff(
                        _filters,
                        productKey: g.key,
                      ),
                    ),
              ),
              _rankingCard(
                theme,
                title: 'Least 3 Items',
                groups: ItemSalesAnalysisBuilder.least3(
                  _items,
                ),
                nameLabel: 'Item',
                onTap:
                    (g) => _openTable(
                      ItemSalesAnalysisBuilder.handoff(
                        _filters,
                        productKey: g.key,
                      ),
                    ),
              ),
            ]),
            _pair([
              _rankingCard(
                theme,
                title: 'Top 3 Staff',
                groups: ItemSalesAnalysisBuilder.top3(_staff),
                nameLabel: 'Staff',
                onTap:
                    (g) => _openTable(
                      ItemSalesAnalysisBuilder.handoff(
                        _filters,
                        staffKey: g.key,
                      ),
                    ),
              ),
              _rankingCard(
                theme,
                title: 'Least 3 Staff',
                groups: ItemSalesAnalysisBuilder.least3(
                  _staff,
                ),
                nameLabel: 'Staff',
                onTap:
                    (g) => _openTable(
                      ItemSalesAnalysisBuilder.handoff(
                        _filters,
                        staffKey: g.key,
                      ),
                    ),
              ),
            ]),
            _pair([_channelCard(theme), _typeCard(theme)]),
            _categoryCard(theme),
            _itemCard(theme),
            if (_departmentsEnabled) _departmentCard(theme),
            _customerCard(theme),
            _staffCard(theme),
            if (_subStaffEnabled) _subStaffCard(theme),
          ],
        ],
      ),
    );
  }

  /// Side by side on desktop, stacked on mobile.
  Widget _pair(List<Widget> children) {
    if (!widget.isDesktop) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: children,
      );
    }
    // Not IntrinsicHeight: the tables and charts use
    // LayoutBuilder, which cannot report intrinsic sizes.
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        for (final c in children) Expanded(child: c),
      ],
    );
  }

  // ---------------------------------------------------------------
  // toolbar / filters / notes
  // ---------------------------------------------------------------

  Widget _toolbar(ThemeProvider theme) {
    final active = _filters.activeCount;
    return Wrap(
      spacing: 2,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ReceiptsReportPeriodButton(
          theme: theme,
          period: _period,
          enabled: _canPickDate,
          onChanged: (p) {
            _apply(() => _period = p);
            if (!p.isAllTime) {
              _load(refreshFromStore: false);
            }
          },
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
        if (_filters.hasAnything)
          ReportPill(
            theme: theme,
            icon: Icons.filter_alt_off,
            label: 'Reset All Filters',
            onTap: _resetAll,
            color: theme.lightModeColor.prColor300,
          ),
        Padding(
          padding: const EdgeInsets.only(left: 5),
          child: ReportExportButton(buildSpec: _exportSpec),
        ),
      ],
    );
  }

  /// The notes under the toolbar, shared with the export.
  List<String> get _notesList => itemSalesAnalysisNotes(
    period: _period,
    stats: _stats,
    cartDiscountInView: _cartDiscountInView,
    voidFilter: _filters.voidFilter,
    canSeeCost: _canSeeCost,
  );

  /// What the Export button exports: the statistic cards and the
  /// tables, with the period, filters and notes on screen.
  ReportExportSpec _exportSpec() {
    return itemSalesAnalysisExportSpec(
      stats: _stats,
      items: ItemSalesAnalysisBuilder.sortGroups(
        _items,
        field: _itemSort,
        ascending: _itemAscending,
      ),
      categories: _categories,
      customers: ItemSalesAnalysisBuilder.sortGroups(
        _customers,
        field: _customerSort,
        ascending: _customerAscending,
      ),
      staff: _staff,
      subStaff: _subStaff,
      departments: _departments,
      channels: _channels,
      types: _types,
      filters: _filters,
      categoryOptions: _categoryOptions,
      itemOptions: _allItemOptions,
      choices: _choices,
      period: _period,
      notes: _notesList,
      currency: currencySymbol(context: context),
      canSeeCost: _canSeeCost,
      departmentsEnabled: _departmentsEnabled,
      subStaffEnabled: _subStaffEnabled,
    );
  }

  Widget _filterPanel() {
    final theme = returnTheme(context, listen: false);
    return Container(
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
          ...itemSalesFilterFields(
            theme: theme,
            filters: _filters,
            categoryOptions: _categoryOptions,
            itemOptions: _itemOptions,
            rows: _baseRows,
            onApply: _apply,
          ),
          ...receiptsKeyFilterFields(
            theme: theme,
            filters: _filters.receipt,
            choices: _choices,
            departmentsEnabled: _departmentsEnabled,
            subStaffEnabled: _subStaffEnabled,
            onApply: _apply,
          ),
        ],
      ),
    );
  }

  Widget _notes() {
    // Shared with the export, so both always match.
    final notes = _notesList;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 2,
      children: [
        for (final n in notes)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Icon(
                  Icons.info_outline_rounded,
                  size: 13,
                  color: Colors.grey.shade600,
                ),
              ),
              Expanded(
                child: Text(
                  n,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  // ---------------------------------------------------------------
  // cards
  // ---------------------------------------------------------------

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

  Widget _statCards(ThemeProvider theme) {
    final s = _stats;
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
      Color? color,
      IconData icon = Icons.inventory_2_rounded,
    }) {
      return Container(
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
                fontSize: theme.mobileTexts.b1.fontSize,
                fontWeight: FontWeight.bold,
                color: color ?? Colors.black87,
              ),
            ),
            if (sub != null)
              Text(
                sub,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade600,
                ),
              ),
          ],
        ),
      );
    }

    String n(num v) => formatLargeNumberDouble(v);

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        stat(
          'Item Records',
          n(s.totalLines),
          sub: s.voidLines > 0 ? '${s.voidLines} void' : null,
        ),
        stat(
          'Items Sold',
          n(s.distinctItems),
          sub:
              s.noItemIdLines > 0
                  ? '+ ${s.noItemIdLines} records without item ID'
                  : 'Distinct items',
        ),
        stat(
          'Receipts',
          n(s.receiptCount),
          icon: Icons.receipt_long_rounded,
        ),
        stat(
          'Categories Sold',
          n(s.distinctCategories),
          icon: Icons.category_rounded,
        ),
        stat(
          'Total Revenue',
          _money(s.totalRevenue),
          sub: 'All receipt types',
          icon: Icons.payments_rounded,
        ),
        if (_canSeeCost)
          stat(
            'Total Profit/Loss',
            _money(s.totalProfit),
            sub:
                s.costMissingCount > 0
                    ? '${s.costMissingCount} records with a missing cost'
                    : null,
            color: _signColor(theme, s.totalProfit),
            icon: Icons.trending_up_rounded,
          ),
        if (_canSeeCost)
          stat(
            'Profit Margin',
            _percent(s.margin),
            color:
                s.margin == null
                    ? null
                    : _signColor(theme, s.margin!),
            icon: Icons.percent_rounded,
          ),
        stat(
          'Average Item Revenue',
          _money(s.averageLineRevenue),
          sub: 'Per item record',
          icon: Icons.functions_rounded,
        ),
        stat(
          'Total Line Discounts',
          _money(s.totalDiscount),
          icon: Icons.discount_rounded,
        ),
        stat(
          'Custom Price Records',
          n(s.customPriceLines),
          icon: Icons.edit_note_rounded,
        ),
        stat(
          'Wholesale Records',
          n(s.wholesaleLines),
          icon: Icons.local_shipping_rounded,
        ),
        stat(
          'Invoice Payment Records',
          n(s.typeCount(ReceiptType.invoicePayment)),
          sub: 'Part payments of invoices',
          icon: Icons.request_quote_rounded,
        ),
        stat(
          'Total Customers',
          n(s.distinctCustomers),
          sub:
              s.walkInReceipts > 0
                  ? '+ ${s.walkInReceipts} walk-in receipts'
                  : null,
          icon: Icons.people_alt_rounded,
        ),
        stat(
          'Total Staff Involved',
          n(s.distinctStaff),
          sub:
              s.noStaffReceipts > 0
                  ? '+ ${s.noStaffReceipts} receipts without staff'
                  : null,
          icon: Icons.badge_rounded,
        ),
      ],
    );
  }

  // ---------------------------------------------------------------
  // charts
  // ---------------------------------------------------------------

  String _compact(double v) =>
      NumberFormat.compact().format(v);

  Widget _bottomTitle(double value, TitleMeta meta) {
    final i = value.round();
    if (i < 0 || i >= _trend.length || value != i) {
      return const SizedBox.shrink();
    }
    final step = math.max(1, (_trend.length / 6).ceil());
    if (i % step != 0) return const SizedBox.shrink();
    return SideTitleWidget(
      meta: meta,
      child: Text(
        _bucketLabel(_trend[i].start),
        style: const TextStyle(fontSize: 9),
      ),
    );
  }

  Widget _legend(List<(String, Color)> items) {
    return Wrap(
      spacing: 12,
      runSpacing: 4,
      children: [
        for (final (label, color) in items)
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 4,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                label,
                style: const TextStyle(fontSize: 10),
              ),
            ],
          ),
      ],
    );
  }

  Widget _trendCard(ThemeProvider theme) {
    final revenueColor = theme.lightModeColor.prColor300;
    final profitColor = Colors.green.shade600;
    final showProfit = _canSeeCost;
    double minY = 0;
    double maxY = 0;
    for (final p in _trend) {
      maxY = math.max(maxY, p.revenue);
      if (showProfit) {
        maxY = math.max(maxY, p.profit);
        minY = math.min(minY, p.profit);
      }
    }
    if (maxY == minY) maxY = minY + 1;

    LineChartBarData series(
      double Function(ItemSalesTrendPoint) value,
      Color color,
    ) {
      return LineChartBarData(
        spots: [
          for (var i = 0; i < _trend.length; i++)
            FlSpot(i.toDouble(), value(_trend[i])),
        ],
        color: color,
        barWidth: 2,
        isCurved: false,
        dotData: FlDotData(show: _trend.length <= 31),
      );
    }

    return _card(
      theme,
      title:
          showProfit
              ? 'Revenue and Profit Trend'
              : 'Revenue Trend',
      subtitle: '$_intervalLabel, by business day',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          _legend([
            ('Revenue', revenueColor),
            if (showProfit) ('Profit/Loss', profitColor),
          ]),
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                minY: minY,
                maxY: maxY * 1.1,
                gridData: const FlGridData(
                  drawVerticalLine: false,
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(),
                  rightTitles: const AxisTitles(),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 44,
                      getTitlesWidget:
                          (value, meta) => SideTitleWidget(
                            meta: meta,
                            child: Text(
                              _compact(value),
                              style: const TextStyle(
                                fontSize: 9,
                              ),
                            ),
                          ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      interval: 1,
                      getTitlesWidget: _bottomTitle,
                    ),
                  ),
                ),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => Colors.white,
                    getTooltipItems:
                        (spots) =>
                            spots.map((s) {
                              final label =
                                  s.barIndex == 0
                                      ? 'Revenue'
                                      : 'Profit/Loss';
                              final when = _bucketLabel(
                                _trend[s.x.round()].start,
                              );
                              return LineTooltipItem(
                                '$when\n$label: ${_money(s.y)}',
                                TextStyle(
                                  fontSize: 10,
                                  color: s.bar.color,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              );
                            }).toList(),
                  ),
                ),
                lineBarsData: [
                  series((p) => p.revenue, revenueColor),
                  if (showProfit)
                    series((p) => p.profit, profitColor),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _activityCard(ThemeProvider theme) {
    double maxY = 1;
    for (final p in _trend) {
      maxY = math.max(maxY, p.lineCount.toDouble());
    }
    final barWidth =
        _trend.length > 40
            ? 3.0
            : (_trend.length > 20 ? 6.0 : 10.0);

    BarChartGroupData group(int i) {
      final p = _trend[i];
      final parts = [
        (p.sales, _typeColor(ReceiptType.sales)),
        (
          p.invoicePayments,
          _typeColor(ReceiptType.invoicePayment),
        ),
        (
          p.orderDeliveries,
          _typeColor(ReceiptType.orderDelivery),
        ),
        (p.unknown, _typeColor(ReceiptType.unknown)),
      ];
      final stack = <BarChartRodStackItem>[];
      double from = 0;
      for (final (count, color) in parts) {
        if (count == 0) continue;
        stack.add(
          BarChartRodStackItem(from, from + count, color),
        );
        from += count;
      }
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: from,
            width: barWidth,
            color: Colors.transparent,
            rodStackItems: stack,
            borderRadius: BorderRadius.circular(2),
          ),
        ],
      );
    }

    return _card(
      theme,
      title: 'Item Sales Activity',
      subtitle:
          '$_intervalLabel item record counts by receipt type',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          _legend([
            for (final t in ReceiptType.values)
              if (t != ReceiptType.unknown ||
                  _stats.typeCount(t) > 0)
                (t.label, _typeColor(t)),
          ]),
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                maxY: maxY * 1.15,
                gridData: const FlGridData(
                  drawVerticalLine: false,
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(),
                  rightTitles: const AxisTitles(),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (value, meta) {
                        if (value !=
                            value.roundToDouble()) {
                          return const SizedBox.shrink();
                        }
                        return SideTitleWidget(
                          meta: meta,
                          child: Text(
                            value.toStringAsFixed(0),
                            style: const TextStyle(
                              fontSize: 9,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      getTitlesWidget: _bottomTitle,
                    ),
                  ),
                ),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => Colors.white,
                    getTooltipItem: (group, _, rod, _) {
                      final p = _trend[group.x];
                      return BarTooltipItem(
                        '${_bucketLabel(p.start)}\n'
                        'Sales: ${p.sales}\n'
                        'Invoice Payments: ${p.invoicePayments}\n'
                        'Order Deliveries: ${p.orderDeliveries}'
                        '${p.unknown > 0 ? '\nUnknown: ${p.unknown}' : ''}',
                        const TextStyle(
                          fontSize: 10,
                          color: Colors.black87,
                        ),
                      );
                    },
                  ),
                ),
                barGroups: [
                  for (var i = 0; i < _trend.length; i++)
                    group(i),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------
  // tables
  // ---------------------------------------------------------------

  Widget _cellText(
    String text, {
    bool bold = false,
    Color? color,
    bool alignStart = false,
  }) {
    return Text(
      text,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      textAlign:
          alignStart ? TextAlign.start : TextAlign.end,
      style: TextStyle(
        fontSize: 11,
        fontWeight:
            bold ? FontWeight.bold : FontWeight.w500,
        color: color ?? Colors.black87,
      ),
    );
  }

  /// Profit, coloured, with a note when some item records have a
  /// missing cost.
  Widget _profitCell(
    ThemeProvider theme,
    double profit,
    int costMissing,
    int lines,
  ) {
    final text = _cellText(
      _money(profit),
      bold: true,
      color: _signColor(theme, profit),
    );
    if (costMissing == 0) return text;
    return Tooltip(
      message:
          '$costMissing of $lines item records have a missing '
          'cost price (counted as 0)',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        spacing: 3,
        children: [
          Flexible(child: text),
          Icon(
            Icons.info_outline_rounded,
            size: 12,
            color: Colors.orange.shade800,
          ),
        ],
      ),
    );
  }

  Widget _table<T>(
    ThemeProvider theme, {
    required List<_SCol<T>> columns,
    required List<T> items,
    void Function(T item)? onTap,
    ItemSalesGroupSortField? sortField,
    bool ascending = false,
    void Function(ItemSalesGroupSortField field)? onSort,
  }) {
    final accent = theme.lightModeColor.prColor300;
    final total = columns.fold<double>(
      0,
      (s, c) => s + c.width,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale =
            total < constraints.maxWidth
                ? constraints.maxWidth / total
                : 1.0;
        Widget cellBox(_SCol<T> c, Widget child) =>
            SizedBox(
              width: c.width * scale,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                ),
                child: Align(
                  alignment:
                      c.alignStart
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                  child: child,
                ),
              ),
            );

        Widget header(_SCol<T> c) {
          final sorted =
              c.sort != null && c.sort == sortField;
          final label = Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 2,
            children: [
              Flexible(
                child: Text(
                  c.label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: sorted ? accent : Colors.black87,
                  ),
                ),
              ),
              if (c.sort != null && onSort != null)
                Icon(
                  sorted
                      ? (ascending
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded)
                      : Icons.unfold_more_rounded,
                  size: 12,
                  color: sorted ? accent : Colors.grey,
                ),
            ],
          );
          final box = cellBox(c, label);
          if (c.sort == null || onSort == null) return box;
          return InkWell(
            mouseCursor: SystemMouseCursors.click,
            onTap: () => onSort(c.sort!),
            child: box,
          );
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            children: [
              Container(
                height: 38,
                color: accent.withAlpha(22),
                child: Row(
                  children: [
                    for (final c in columns) header(c),
                  ],
                ),
              ),
              for (var i = 0; i < items.length; i++)
                Material(
                  color:
                      i.isEven
                          ? Colors.white
                          : Colors.grey.shade50,
                  child: InkWell(
                    mouseCursor:
                        onTap == null
                            ? MouseCursor.defer
                            : SystemMouseCursors.click,
                    hoverColor: accent.withAlpha(20),
                    onTap:
                        onTap == null
                            ? null
                            : () => onTap(items[i]),
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey.shade100,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          for (final c in columns)
                            cellBox(c, c.cell(items[i], i)),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _emptyTableText() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Text(
      'Nothing to show for this period.',
      style: TextStyle(
        fontSize: 11,
        color: Colors.grey.shade600,
      ),
    ),
  );

  List<_SCol<ItemSalesSummaryGroup>> _groupColumns(
    ThemeProvider theme, {
    required String nameLabel,
    bool receipts = true,
    bool margin = true,
    bool share = false,
    bool lastDate = false,
    bool sortable = false,
  }) {
    return [
      _SCol(
        label: 'No.',
        width: 44,
        alignStart: true,
        cell:
            (g, i) =>
                _cellText('${i + 1}', alignStart: true),
      ),
      _SCol(
        label: nameLabel,
        width: 180,
        alignStart: true,
        cell:
            (g, i) => _cellText(
              g.label,
              bold: true,
              alignStart: true,
              color: g.isNone ? Colors.grey.shade700 : null,
            ),
      ),
      _SCol(
        label: 'Item Records',
        width: 90,
        sort:
            sortable
                ? ItemSalesGroupSortField.lineCount
                : null,
        cell: (g, i) => _cellText('${g.lineCount}'),
      ),
      if (receipts)
        _SCol(
          label: 'Receipts',
          width: 80,
          cell: (g, i) => _cellText('${g.receiptCount}'),
        ),
      _SCol(
        label: 'Total Revenue',
        width: 130,
        sort:
            sortable
                ? ItemSalesGroupSortField.revenue
                : null,
        cell:
            (g, i) =>
                _cellText(_money(g.revenue), bold: true),
      ),
      if (_canSeeCost)
        _SCol(
          label: 'Profit/Loss',
          width: 130,
          sort:
              sortable
                  ? ItemSalesGroupSortField.profit
                  : null,
          cell:
              (g, i) => _profitCell(
                theme,
                g.profit,
                g.costMissingCount,
                g.lineCount,
              ),
        ),
      if (_canSeeCost && margin)
        _SCol(
          label: 'Margin',
          width: 90,
          sort:
              sortable
                  ? ItemSalesGroupSortField.margin
                  : null,
          cell: (g, i) {
            final m = g.margin;
            return _cellText(
              _percent(m),
              color:
                  m == null
                      ? Colors.grey
                      : _signColor(theme, m),
            );
          },
        ),
      if (share)
        _SCol(
          label: '% of Revenue',
          width: 100,
          cell:
              (g, i) => _cellText(_percent(g.revenueShare)),
        ),
      if (lastDate)
        _SCol(
          label: 'Last Sold',
          width: 120,
          sort:
              sortable
                  ? ItemSalesGroupSortField.lastDate
                  : null,
          cell:
              (g, i) => _cellText(
                g.lastDate == null
                    ? '—'
                    : formatDateTime(g.lastDate!),
              ),
        ),
    ];
  }

  Widget _rankingCard(
    ThemeProvider theme, {
    required String title,
    required List<ItemSalesSummaryGroup> groups,
    required String nameLabel,
    required void Function(ItemSalesSummaryGroup g) onTap,
  }) {
    return _card(
      theme,
      title: title,
      subtitle: 'By total revenue',
      child:
          groups.isEmpty
              ? _emptyTableText()
              : _table<ItemSalesSummaryGroup>(
                theme,
                columns: _groupColumns(
                  theme,
                  nameLabel: nameLabel,
                  receipts: false,
                ),
                items: groups,
                onTap: onTap,
              ),
    );
  }

  /// A sortable table that shows the first [_preview] rows until
  /// "Show all" is tapped.
  Widget _sortableCard(
    ThemeProvider theme, {
    required String title,
    required String subtitle,
    required String nameLabel,
    required List<ItemSalesSummaryGroup> groups,
    required ItemSalesGroupSortField sortField,
    required bool ascending,
    required bool showAll,
    required void Function(ItemSalesGroupSortField f) onSort,
    required VoidCallback onToggleAll,
    required void Function(ItemSalesSummaryGroup g) onTap,
  }) {
    final sorted = ItemSalesAnalysisBuilder.sortGroups(
      groups,
      field: sortField,
      ascending: ascending,
    );
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
                  _table<ItemSalesSummaryGroup>(
                    theme,
                    columns: _groupColumns(
                      theme,
                      nameLabel: nameLabel,
                      lastDate: true,
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

  Widget _categoryCard(ThemeProvider theme) {
    return _card(
      theme,
      title: 'Category Summary',
      subtitle:
          'Tap a category to see its item records. An item in '
          'several categories counts in each, so totals can add '
          'up to more than the overall total.',
      child:
          _categories.isEmpty
              ? _emptyTableText()
              : _table<ItemSalesSummaryGroup>(
                theme,
                columns: _groupColumns(
                  theme,
                  nameLabel: 'Category',
                  share: true,
                ),
                items: _categories,
                onTap:
                    (g) => _openTable(
                      ItemSalesAnalysisBuilder.handoff(
                        _filters,
                        categoryKey: g.key,
                      ),
                    ),
              ),
    );
  }

  Widget _itemCard(ThemeProvider theme) {
    return _sortableCard(
      theme,
      title: 'Item Summary',
      subtitle: 'Tap an item to see its item records',
      nameLabel: 'Item',
      groups: _items,
      sortField: _itemSort,
      ascending: _itemAscending,
      showAll: _showAllItems,
      onSort:
          (f) => setState(() {
            if (_itemSort == f) {
              _itemAscending = !_itemAscending;
            } else {
              _itemSort = f;
              _itemAscending = false;
            }
          }),
      onToggleAll:
          () => setState(() => _showAllItems = !_showAllItems),
      onTap:
          (g) => _openTable(
            ItemSalesAnalysisBuilder.handoff(
              _filters,
              productKey: g.key,
            ),
          ),
    );
  }

  Widget _departmentCard(ThemeProvider theme) {
    return _card(
      theme,
      title: 'Department Summary',
      subtitle: 'Tap a department to see its item records',
      child:
          _departments.isEmpty
              ? _emptyTableText()
              : _table<ItemSalesSummaryGroup>(
                theme,
                columns: _groupColumns(
                  theme,
                  nameLabel: 'Department',
                  share: true,
                ),
                items: _departments,
                onTap:
                    (g) => _openTable(
                      ItemSalesAnalysisBuilder.handoff(
                        _filters,
                        departmentKey: g.key,
                      ),
                    ),
              ),
    );
  }

  Widget _customerCard(ThemeProvider theme) {
    return _sortableCard(
      theme,
      title: 'Customer Summary',
      subtitle:
          'Tap a customer to see their item records. '
          'Walk-in sales are under No Customer.',
      nameLabel: 'Customer',
      groups: _customers,
      sortField: _customerSort,
      ascending: _customerAscending,
      showAll: _showAllCustomers,
      onSort:
          (f) => setState(() {
            if (_customerSort == f) {
              _customerAscending = !_customerAscending;
            } else {
              _customerSort = f;
              _customerAscending = false;
            }
          }),
      onToggleAll:
          () => setState(
            () => _showAllCustomers = !_showAllCustomers,
          ),
      onTap:
          (g) => _openTable(
            ItemSalesAnalysisBuilder.handoff(
              _filters,
              customerKey: g.key,
            ),
          ),
    );
  }

  Widget _staffCard(ThemeProvider theme) {
    return _card(
      theme,
      title: 'Staff Summary',
      subtitle: 'Tap a staff member to see their item records',
      child:
          _staff.isEmpty
              ? _emptyTableText()
              : _table<ItemSalesSummaryGroup>(
                theme,
                columns: _groupColumns(
                  theme,
                  nameLabel: 'Staff',
                  share: true,
                ),
                items: _staff,
                onTap:
                    (g) => _openTable(
                      ItemSalesAnalysisBuilder.handoff(
                        _filters,
                        staffKey: g.key,
                      ),
                    ),
              ),
    );
  }

  Widget _subStaffCard(ThemeProvider theme) {
    return _card(
      theme,
      title: 'Sub-Staff Summary',
      subtitle:
          'Tap a sub-staff member to see their item records',
      child:
          _subStaff.isEmpty
              ? _emptyTableText()
              : _table<ItemSalesSummaryGroup>(
                theme,
                columns: _groupColumns(
                  theme,
                  nameLabel: 'Sub-Staff',
                ),
                items: _subStaff,
                onTap:
                    (g) => _openTable(
                      ItemSalesAnalysisBuilder.handoff(
                        _filters,
                        subStaffKey: g.key,
                      ),
                    ),
              ),
    );
  }

  Widget _channelCard(ThemeProvider theme) {
    return _card(
      theme,
      title: 'Payment Channel Summary',
      subtitle:
          'By the receipt\'s channel; Split = paid with 2 or more '
          'methods',
      child: _table<ItemSalesChannelSummary>(
        theme,
        columns: [
          _SCol(
            label: 'No.',
            width: 44,
            alignStart: true,
            cell:
                (c, i) =>
                    _cellText('${i + 1}', alignStart: true),
          ),
          _SCol(
            label: 'Channel',
            width: 140,
            alignStart: true,
            cell:
                (c, i) => _cellText(
                  c.channel.label,
                  bold: true,
                  alignStart: true,
                ),
          ),
          _SCol(
            label: 'Item Records',
            width: 90,
            cell: (c, i) => _cellText('${c.lineCount}'),
          ),
          _SCol(
            label: 'Value',
            width: 130,
            cell:
                (c, i) =>
                    _cellText(_money(c.value), bold: true),
          ),
          _SCol(
            label: '% of Value',
            width: 100,
            cell:
                (c, i) => _cellText(_percent(c.valueShare)),
          ),
        ],
        items: _channels,
        onTap:
            (c) => _openTable(
              ItemSalesAnalysisBuilder.handoff(
                _filters,
                channel: c.channel,
              ),
            ),
      ),
    );
  }

  Widget _typeCard(ThemeProvider theme) {
    return _card(
      theme,
      title: 'Transaction Type Summary',
      subtitle:
          'Invoice payments are payments received, not new sales',
      child: _table<ItemSalesTypeSummary>(
        theme,
        columns: [
          _SCol(
            label: 'No.',
            width: 44,
            alignStart: true,
            cell:
                (t, i) =>
                    _cellText('${i + 1}', alignStart: true),
          ),
          _SCol(
            label: 'Type',
            width: 150,
            alignStart: true,
            cell:
                (t, i) => _cellText(
                  t.type.label,
                  bold: true,
                  alignStart: true,
                  color: _typeColor(t.type),
                ),
          ),
          _SCol(
            label: 'Item Records',
            width: 90,
            cell: (t, i) => _cellText('${t.lineCount}'),
          ),
          _SCol(
            label: 'Value',
            width: 130,
            cell:
                (t, i) =>
                    _cellText(_money(t.value), bold: true),
          ),
          if (_canSeeCost)
            _SCol(
              label: 'Profit/Loss',
              width: 130,
              cell:
                  (t, i) => _profitCell(
                    theme,
                    t.profit,
                    t.costMissingCount,
                    t.lineCount,
                  ),
            ),
        ],
        items: _types,
        onTap:
            (t) => _openTable(
              ItemSalesAnalysisBuilder.handoff(
                _filters,
                type: t.type,
              ),
            ),
      ),
    );
  }
}
