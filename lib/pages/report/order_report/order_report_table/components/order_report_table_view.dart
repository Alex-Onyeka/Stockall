import 'package:flutter/material.dart';
import 'package:stockall/classes/checkout_response.dart';
import 'package:stockall/classes/temp_main_receipt/temp_main_receipt.dart';
import 'package:stockall/classes/temp_orders/orders.dart';
import 'package:stockall/classes/temp_product_slaes_record/temp_product_sale_record.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/refresh_functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/report/components/export/report_export_button.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/report_group_by.dart';
import 'package:stockall/pages/report/components/report_pager.dart';
import 'package:stockall/pages/report/components/report_pill.dart';
import 'package:stockall/pages/report/components/report_range_fields.dart';
import 'package:stockall/pages/report/components/report_searchable_dropdown.dart';
import 'package:stockall/pages/report/order_report/order_report_table/class/order_report_export_spec.dart';
import 'package:stockall/pages/report/order_report/order_report_table/class/order_report_table_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/components/receipts_report_filter_widgets.dart';
import 'package:stockall/pages/sales/make_sales/receipt_page/receipt_page.dart';
import 'package:stockall/providers/theme_provider.dart';

/// Everything the view reads from the app. [OrderReportTableEnv.live]
/// uses the providers; tests pass their own, since the providers
/// need Supabase.
class OrderReportTableEnv {
  final bool Function() departmentsEnabled;
  final bool Function() subStaffEnabled;
  final bool Function() canSeeCost;
  final bool Function() canPickDate;

  /// Orders the user may see (shop and department scope applied).
  final List<Orders> Function() orders;
  final List<TempMainReceipt> Function() receipts;
  final List<TempProductSaleRecord> Function() productSales;

  final Future<void> Function(
    BuildContext context, {
    required bool refreshFromStore,
  })
  load;

  /// Changes whenever the source data or the user's scope does.
  final String Function() signature;

  /// Subscribes the view to the providers it reads.
  final void Function(BuildContext context) listen;
  final String Function(BuildContext context, num amount) money;
  final Future<void> Function(BuildContext context, Orders order)
  openOrder;

  /// Used by the order summary to open the table. Null in the
  /// app: the summary pushes `OrderReportTablePage`.
  final Future<void> Function(
    BuildContext context,
    OrderReportFilters filters,
    ReceiptsReportPeriod period,
  )?
  openTable;

  const OrderReportTableEnv({
    required this.departmentsEnabled,
    required this.subStaffEnabled,
    required this.canSeeCost,
    required this.canPickDate,
    required this.orders,
    required this.receipts,
    required this.productSales,
    required this.load,
    required this.signature,
    required this.listen,
    required this.money,
    required this.openOrder,
    this.openTable,
  });

  factory OrderReportTableEnv.live() {
    bool departmentsEnabled() =>
        shopSingle()?.manageDepartments == true;
    return OrderReportTableEnv(
      departmentsEnabled: departmentsEnabled,
      subStaffEnabled: () => shopSingle()?.bulkSale == true,
      canSeeCost:
          () => authorization(
            authorized: Authorizations().manageCostPrice,
          ),
      canPickDate:
          () => authorization(
            authorized: Authorizations().viewDate,
          ),
      orders:
          () => OrderReportScope.scope(
            orders: returnOrdersProvider().orders,
            shopId: shopSingle()?.shopId ?? 0,
            departmentsEnabled: departmentsEnabled(),
            canViewAllDepartments: authorization(
              authorized: Authorizations().viewAllDepartments,
            ),
            currentDepartmentUuid:
                returnDepartmentProvider()
                    .currentDepartment()
                    ?.uuid,
          ),
      receipts: () => returnReceiptProviderSingle().receipts,
      productSales:
          () => returnReceiptProviderSingle().mainSales,
      load: (context, {required refreshFromStore}) async {
        final sid = shopSingle()?.shopId;
        if (sid == null) return;
        final receipts = returnReceiptProviderSingle();
        if (refreshFromStore) {
          await returnOrdersProvider().loadOrders(sid);
          if (!context.mounted) return;
          await RefreshFunctions(
            context,
          ).refreshReceipts(context);
          return;
        }
        // Local (offline) reads, only when nothing is loaded yet.
        if (returnOrdersProvider().orders.isEmpty) {
          await returnOrdersProvider().loadOrdersOffline(sid);
        }
        if (receipts.receipts.isEmpty) {
          await receipts.loadReceiptsOffline(sid);
        }
        if (receipts.mainSales.isEmpty) {
          await receipts.loadProductSalesRecordOffline(sid);
        }
      },
      signature: () {
        int latestOrder = 0;
        final orders = returnOrdersProvider().orders;
        for (final o in orders) {
          final t =
              (o.updatedAt ?? o.createdAt)
                  .millisecondsSinceEpoch;
          if (t > latestOrder) latestOrder = t;
        }
        int latestReceipt = 0;
        final provider = returnReceiptProviderSingle();
        for (final r in provider.receipts) {
          final t = r.createdAt.millisecondsSinceEpoch;
          if (t > latestReceipt) latestReceipt = t;
        }
        return '${orders.length}|$latestOrder|'
            '${provider.receipts.length}|$latestReceipt|'
            '${provider.mainSales.length}|'
            '${returnDepartmentProvider().currentDepartment()?.uuid}|'
            '${currentUser().userId}|${departmentsEnabled()}';
      },
      listen: (context) {
        returnOrdersProvider(context: context);
        returnReceiptProvider(context);
        shop(context);
      },
      money:
          (context, amount) =>
              formatMoneyBig(amount: amount, context: context),
      openOrder: (context, order) {
        return Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => ReceiptPage(
                  response: CheckoutResponse(order: order),
                  isMain: false,
                ),
          ),
        );
      },
    );
  }
}

class _Col {
  final String label;
  final double width;
  final OrderSortField? sort;
  final TextAlign align;
  final Widget Function(OrderReportRow row) cell;

  /// Cell of the totals row; empty when null.
  final Widget Function(OrderReportTotals totals)? total;

  const _Col({
    required this.label,
    required this.width,
    required this.cell,
    this.sort,
    this.align = TextAlign.center,
    this.total,
  });
}

class _GCol {
  final String label;
  final double width;
  final OrderGroupSortField? sort;
  final TextAlign align;
  final Widget Function(OrderReportGroupRow row) cell;

  /// Cell of the totals row; empty when null.
  final Widget Function(OrderReportTotals totals)? total;

  const _GCol({
    required this.label,
    required this.width,
    required this.cell,
    this.sort,
    this.align = TextAlign.center,
    this.total,
  });
}

/// Shared body of the Order Report Table page (desktop + mobile).
///
/// [initialFilters] and [initialPeriod] let another page (the
/// order summary) open the table on a given set.
class OrderReportTableView extends StatefulWidget {
  final bool isDesktop;
  final OrderReportFilters? initialFilters;
  final ReceiptsReportPeriod? initialPeriod;

  /// Null in the app: [OrderReportTableEnv.live] is used.
  final OrderReportTableEnv? env;

  const OrderReportTableView({
    super.key,
    required this.isDesktop,
    this.initialFilters,
    this.initialPeriod,
    this.env,
  });

  @override
  State<OrderReportTableView> createState() =>
      _OrderReportTableViewState();
}

class _OrderReportTableViewState
    extends State<OrderReportTableView> {
  late final OrderReportTableEnv _env;
  late final OrderReportFilters _filters;
  final _searchCtrl = TextEditingController();
  final _totalMinCtrl = TextEditingController();
  final _totalMaxCtrl = TextEditingController();
  final _paidMinCtrl = TextEditingController();
  final _paidMaxCtrl = TextEditingController();
  final _balanceMinCtrl = TextEditingController();
  final _balanceMaxCtrl = TextEditingController();
  final _profitMinCtrl = TextEditingController();
  final _profitMaxCtrl = TextEditingController();
  final _hScroll = ScrollController();
  final _vScroll = ScrollController();

  OrderSortField _sortField = OrderSortField.createdAt;
  bool _ascending = false;
  int _page = 1;
  bool _showFilters = false;
  bool _toolbarIsOpen = false;

  late ReceiptsReportPeriod _period;

  // A view option, not a filter: Reset All keeps it. Grouping has
  // its own sort, so the order sort is kept.
  ReportGroupBy _groupBy = ReportGroupBy.off;
  OrderGroupSortField _groupSortField =
      OrderGroupSortField.total;
  bool _groupAscending = false;
  OrderReportGroupPage? _groupResult;

  bool get _grouped => _groupBy != ReportGroupBy.off;

  bool _loading = true;
  String? _error;

  List<OrderReportRow> _baseRows = [];
  OrderReportPage? _result;

  // Every filtered, sorted row and group, for the export.
  List<OrderReportRow> _sortedRows = [];
  List<OrderReportGroupRow> _sortedGroups = [];
  String _signature = '';

  List<OrderReportFilterOption> _staffOptions = [];
  List<OrderReportFilterOption> _customerOptions = [];
  List<OrderReportFilterOption> _subStaffOptions = [];
  List<OrderReportFilterOption> _departmentOptions = [];

  @override
  void initState() {
    super.initState();
    _env = widget.env ?? OrderReportTableEnv.live();
    _filters =
        widget.initialFilters?.copy() ?? OrderReportFilters();
    _searchCtrl.text = _filters.search;
    _totalMinCtrl.text = _numText(_filters.totalMin);
    _totalMaxCtrl.text = _numText(_filters.totalMax);
    _paidMinCtrl.text = _numText(_filters.paidMin);
    _paidMaxCtrl.text = _numText(_filters.paidMax);
    _balanceMinCtrl.text = _numText(_filters.balanceMin);
    _balanceMaxCtrl.text = _numText(_filters.balanceMax);
    _profitMinCtrl.text = _numText(_filters.profitMin);
    _profitMaxCtrl.text = _numText(_filters.profitMax);
    _period =
        widget.initialPeriod ?? ReceiptsReportPeriod.today();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load(refreshFromStore: false);
    });
  }

  @override
  void dispose() {
    for (final c in [
      _searchCtrl,
      _totalMinCtrl,
      _totalMaxCtrl,
      _paidMinCtrl,
      _paidMaxCtrl,
      _balanceMinCtrl,
      _balanceMaxCtrl,
      _profitMinCtrl,
      _profitMaxCtrl,
    ]) {
      c.dispose();
    }
    _hScroll.dispose();
    _vScroll.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------
  // data
  // ---------------------------------------------------------------

  bool get _departmentsEnabled => _env.departmentsEnabled();
  bool get _subStaffEnabled => _env.subStaffEnabled();
  bool get _canSeeCost => _env.canSeeCost();

  Future<void> _load({required bool refreshFromStore}) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _env.load(
        context,
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

  void _rebuildBase() {
    _baseRows = OrderReportRowBuilder.buildAll(
      orders: _env.orders(),
      allReceipts: _env.receipts(),
      allProductSales: _env.productSales(),
    );
    _staffOptions = OrderReportOptions.staff(_baseRows);
    _customerOptions = OrderReportOptions.customers(_baseRows);
    _subStaffOptions = OrderReportOptions.subStaff(_baseRows);
    _departmentOptions = OrderReportOptions.departments(
      _baseRows,
    );
    _signature = _env.signature();
  }

  void _recompute() {
    final profitVisible = _canSeeCost;
    if (!profitVisible &&
        (_sortField == OrderSortField.cost ||
            _sortField == OrderSortField.profit ||
            _sortField == OrderSortField.margin)) {
      _sortField = OrderSortField.createdAt;
      _ascending = false;
    }
    final sorted = OrderReportQuery.filterAndSort(
      rows: _baseRows,
      period: _period,
      filters: _filters,
      sortField: _sortField,
      ascending: _ascending,
      departmentsEnabled: _departmentsEnabled,
      subStaffEnabled: _subStaffEnabled,
      profitVisible: profitVisible,
    );
    _sortedRows = sorted;
    if (_grouped) {
      final groups = OrderReportGrouping.sort(
        OrderReportGrouping.build(sorted, _groupBy),
        field: _groupSortField,
        ascending: _groupAscending,
      );
      _sortedGroups = groups;
      final page = OrderReportGrouping.paginate(
        groups,
        sorted,
        _page,
      );
      _page = page.page;
      _groupResult = page;
    } else {
      final page = OrderReportQuery.paginate(sorted, _page);
      _page = page.page;
      _result = page;
    }
  }

  ReportExportSpec _exportSpec() {
    return orderReportExportSpec(
      rows: _sortedRows,
      groups: _sortedGroups,
      groupBy: _groupBy,
      filters: _filters,
      staffOptions: _staffOptions,
      customerOptions: _customerOptions,
      subStaffOptions: _subStaffOptions,
      departmentOptions: _departmentOptions,
      period: _period,
      sortField: _sortField,
      ascending: _ascending,
      groupSortField: _groupSortField,
      groupAscending: _groupAscending,
      currency: currencySymbol(context: context),
      canSeeCost: _canSeeCost,
      departmentsEnabled: _departmentsEnabled,
      subStaffEnabled: _subStaffEnabled,
    );
  }

  void _apply(VoidCallback change, {bool resetPage = true}) {
    setState(() {
      change();
      if (resetPage) _page = 1;
      try {
        _recompute();
        _error = null;
      } catch (e) {
        _error = e.toString();
      }
    });
  }

  void _goToPage(int p) {
    final totalPages =
        _grouped
            ? _groupResult?.totalPages
            : _result?.totalPages;
    final current =
        _grouped ? _groupResult?.page : _result?.page;
    if (totalPages == null ||
        p < 1 ||
        p > totalPages ||
        p == current) {
      return;
    }
    _apply(() => _page = p, resetPage: false);
    if (_vScroll.hasClients) {
      _vScroll.jumpTo(0);
    }
  }

  void _setSort(OrderSortField f) {
    _apply(() {
      if (_sortField == f) {
        _ascending = !_ascending;
      } else {
        _sortField = f;
        // Names A-Z first; dates and amounts largest first.
        _ascending =
            f == OrderSortField.staff ||
            f == OrderSortField.subStaff ||
            f == OrderSortField.customer ||
            f == OrderSortField.department ||
            f == OrderSortField.status ||
            f == OrderSortField.channel;
      }
    });
  }

  void _setGroupSort(OrderGroupSortField f) {
    _apply(() {
      if (_groupSortField == f) {
        _groupAscending = !_groupAscending;
      } else {
        _groupSortField = f;
        // Names A-Z first; counts and amounts largest first.
        _groupAscending = f == OrderGroupSortField.name;
      }
    });
  }

  /// Clears the filters only: the period and Group by stay.
  void _resetAll() {
    for (final c in [
      _searchCtrl,
      _totalMinCtrl,
      _totalMaxCtrl,
      _paidMinCtrl,
      _paidMaxCtrl,
      _balanceMinCtrl,
      _balanceMaxCtrl,
      _profitMinCtrl,
      _profitMaxCtrl,
    ]) {
      c.clear();
    }
    _apply(_filters.clearAll);
  }

  Future<void> _openOrder(OrderReportRow row) async {
    await _env.openOrder(context, row.order);
    // Picks up a delivery, edit or delete made on the order page.
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

  void _setPeriod(ReceiptsReportPeriod p) =>
      _apply(() => _period = p);

  /// Clears a range's fields once its filter was removed (chip).
  void _applyAndSyncFields(VoidCallback change) {
    _apply(change);
    void sync(
      double? min,
      double? max,
      TextEditingController a,
      TextEditingController b,
    ) {
      if (min == null && max == null) {
        a.clear();
        b.clear();
      }
    }

    sync(
      _filters.totalMin,
      _filters.totalMax,
      _totalMinCtrl,
      _totalMaxCtrl,
    );
    sync(
      _filters.paidMin,
      _filters.paidMax,
      _paidMinCtrl,
      _paidMaxCtrl,
    );
    sync(
      _filters.balanceMin,
      _filters.balanceMax,
      _balanceMinCtrl,
      _balanceMaxCtrl,
    );
    sync(
      _filters.profitMin,
      _filters.profitMax,
      _profitMinCtrl,
      _profitMaxCtrl,
    );
    if (_filters.search.isEmpty) _searchCtrl.clear();
  }

  // ---------------------------------------------------------------
  // formatting
  // ---------------------------------------------------------------

  String _money(num v) => _env.money(context, v);

  static String _numText(double? v) {
    if (v == null) return '';
    return v == v.roundToDouble()
        ? v.toStringAsFixed(0)
        : v.toString();
  }

  String _percent(double v) =>
      '${formatLargeNumberDouble(double.parse(v.toStringAsFixed(2)))}%';

  // ---------------------------------------------------------------
  // build
  // ---------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = returnTheme(context);
    // Listen, so deliveries, edits and sync update the table.
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
        title: 'Order Report Table',
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
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: widget.isDesktop ? 20 : 12,
        ),
        child: Column(
          children: [
            const SizedBox(height: 8),
            _toolbar(theme),
            if (_showFilters) _filterPanel(theme),
            _activeChips(theme),
            _notes(),
            Expanded(child: _content(theme)),
            if (!_loading &&
                _error == null &&
                _grouped &&
                _groupResult != null)
              ReportPager(
                theme: theme,
                page: _groupResult!.page,
                totalPages: _groupResult!.totalPages,
                totalCount: _groupResult!.totalCount,
                firstIndex: _groupResult!.firstIndex,
                lastIndex: _groupResult!.lastIndex,
                itemLabel: _groupBy.pagerLabel,
                onPage: _goToPage,
              ),
            if (!_loading &&
                _error == null &&
                !_grouped &&
                _result != null)
              ReportPager(
                theme: theme,
                page: _result!.page,
                totalPages: _result!.totalPages,
                totalCount: _result!.totalCount,
                firstIndex: _result!.firstIndex,
                lastIndex: _result!.lastIndex,
                itemLabel: 'orders',
                onPage: _goToPage,
              ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }

  Widget _content(ThemeProvider theme) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
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
              'The report could not be generated.',
              style: TextStyle(
                fontSize: theme.mobileTexts.b2.fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => _load(refreshFromStore: false),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
            ),
          ],
        ),
      );
    }
    final res = _result;
    final groups = _groupResult;
    final count =
        _grouped ? groups?.totalCount : res?.totalCount;
    if (count == null || count == 0) {
      final hasFilters = _filters.hasAnything;
      return Padding(
        padding: const EdgeInsets.only(top: 60),
        child: EmptyWidgetDisplayOnly(
          title:
              hasFilters ? 'No Matching Orders' : 'Empty List',
          subText:
              hasFilters
                  ? 'No order matches your search and filters'
                  : 'No order was recorded in this period',
          theme: theme,
          height: 35,
          icon: Icons.clear,
          altAction: hasFilters ? _resetAll : null,
          altActionText: hasFilters ? 'Clear all filters' : null,
          altIcon: hasFilters ? Icons.filter_alt_off : null,
        ),
      );
    }
    if (_grouped) return _groupTable(theme, groups!);
    return _table(theme, res!);
  }

  // ---------------------------------------------------------------
  // toolbar / filters
  // ---------------------------------------------------------------

  Widget _toolbar(ThemeProvider theme) {
    final active = _filters.activeCount;
    final accent = theme.lightModeColor.prColor300;
    return Wrap(
      spacing: 2,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 6.0),
          child: SizedBox(
            width: widget.isDesktop ? 320 : double.infinity,
            height: 38,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged:
                        (v) => _apply(() => _filters.search = v),
                    decoration: InputDecoration(
                      hintText:
                          _departmentsEnabled
                              ? 'Search customer, staff, department or ID'
                              : 'Search customer, staff or ID',
                      hintStyle: TextStyle(
                        fontSize: theme.mobileTexts.b3.fontSize,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        size: 20,
                      ),
                      suffixIcon:
                          _searchCtrl.text.isEmpty
                              ? null
                              : IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  size: 18,
                                ),
                                onPressed: () {
                                  _searchCtrl.clear();
                                  _apply(
                                    () => _filters.search = '',
                                  );
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
                    onTap:
                        () => setState(
                          () => _toolbarIsOpen = !_toolbarIsOpen,
                        ),
                    mouseCursor: SystemMouseCursors.click,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        10.0,
                        6,
                        6,
                        6,
                      ),
                      child: Row(
                        spacing: 1,
                        children: [
                          Text(
                            style: TextStyle(
                              fontSize:
                                  theme.mobileTexts.b4.fontSize,
                            ),
                            _toolbarIsOpen ? 'Hide' : 'View',
                          ),
                          Icon(
                            _toolbarIsOpen
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
        ),
        if (_toolbarIsOpen ||
            screenWidth(context) > mobileScreen) ...[
          ReceiptsReportPeriodButton(
            theme: theme,
            period: _period,
            enabled: _env.canPickDate(),
            onChanged: _setPeriod,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 6.0, right: 5),
            child: ReportPill(
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
          ),
          // A view option, not a filter: Reset All keeps it.
          ReportGroupByButton(
            theme: theme,
            value: _groupBy,
            onChanged: (g) => _apply(() => _groupBy = g),
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
              color: accent,
            ),
        ],
      ],
    );
  }

  Widget _keyDropdown(
    ThemeProvider theme, {
    required String title,
    required String allLabel,
    required String? value,
    required List<OrderReportFilterOption> options,
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
        onChanged: (v) => _apply(() => onChanged(v)),
        theme: theme,
        searchHint: 'Search ${title.toLowerCase()}...',
      ),
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
          BoxShadow(color: Color(0x14000000), blurRadius: 5),
        ],
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 12,
        children: [
          ReportLabeledField(
            label: 'Delivery status',
            width: 200,
            child: ReportSearchableDropdown<OrderDeliveryStatus?>(
              title: 'Delivery status',
              value: _filters.deliveryStatus,
              showSearch: false,
              options: [
                const ReportSearchableOption(
                  value: null,
                  label: 'All statuses',
                ),
                ...OrderDeliveryStatus.values.reversed.map(
                  (s) =>
                      ReportSearchableOption<OrderDeliveryStatus?>(
                        value: s,
                        label: s.label,
                      ),
                ),
              ],
              onChanged:
                  (v) => _apply(() => _filters.deliveryStatus = v),
              theme: theme,
            ),
          ),
          ReportLabeledField(
            label: 'Records',
            width: 190,
            child: Align(
              alignment: Alignment.centerLeft,
              child: FilterChip(
                label: Text(
                  'Records disagree only',
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b4.fontSize,
                  ),
                ),
                selected: _filters.recordsDisagree,
                onSelected:
                    (v) => _apply(
                      () => _filters.recordsDisagree = v,
                    ),
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
          ReportLabeledField(
            label: 'Channel',
            width: 180,
            child: ReportSearchableDropdown<OrderPaymentChannel?>(
              title: 'Channel',
              value: _filters.channel,
              showSearch: false,
              options: [
                const ReportSearchableOption(
                  value: null,
                  label: 'All channels',
                ),
                ...OrderPaymentChannel.values.map(
                  (c) =>
                      ReportSearchableOption<OrderPaymentChannel?>(
                        value: c,
                        label: c.label,
                      ),
                ),
              ],
              onChanged: (v) => _apply(() => _filters.channel = v),
              theme: theme,
            ),
          ),
          _keyDropdown(
            theme,
            title: 'Staff',
            allLabel: 'All staff',
            value: _filters.staffKey,
            options: _staffOptions,
            onChanged: (v) => _filters.staffKey = v,
          ),
          _keyDropdown(
            theme,
            title: 'Customer',
            allLabel: 'All customers',
            value: _filters.customerKey,
            options: _customerOptions,
            onChanged: (v) => _filters.customerKey = v,
          ),
          if (_subStaffEnabled)
            _keyDropdown(
              theme,
              title: 'Sub-Staff',
              allLabel: 'All sub-staff',
              value: _filters.subStaffKey,
              options: _subStaffOptions,
              onChanged: (v) => _filters.subStaffKey = v,
            ),
          if (_departmentsEnabled)
            _keyDropdown(
              theme,
              title: 'Department',
              allLabel: 'All departments',
              value: _filters.departmentKey,
              options: _departmentOptions,
              onChanged: (v) => _filters.departmentKey = v,
            ),
          ReportRangeFields(
            label: 'Order total range',
            minController: _totalMinCtrl,
            maxController: _totalMaxCtrl,
            errorText: _filters.totalRangeError,
            onChange:
                (a, b) => _apply(() {
                  _filters.totalMin = a;
                  _filters.totalMax = b;
                }),
          ),
          ReportRangeFields(
            label: 'Paid range',
            minController: _paidMinCtrl,
            maxController: _paidMaxCtrl,
            errorText: _filters.paidRangeError,
            onChange:
                (a, b) => _apply(() {
                  _filters.paidMin = a;
                  _filters.paidMax = b;
                }),
          ),
          ReportRangeFields(
            label: 'Balance range',
            minController: _balanceMinCtrl,
            maxController: _balanceMaxCtrl,
            errorText: _filters.balanceRangeError,
            onChange:
                (a, b) => _apply(() {
                  _filters.balanceMin = a;
                  _filters.balanceMax = b;
                }),
          ),
          if (_canSeeCost)
            ReportRangeFields(
              label: 'Profit/Loss range',
              minController: _profitMinCtrl,
              maxController: _profitMaxCtrl,
              allowNegative: true,
              errorText: _filters.profitRangeError,
              onChange:
                  (a, b) => _apply(() {
                    _filters.profitMin = a;
                    _filters.profitMax = b;
                  }),
            ),
        ],
      ),
    );
  }

  Widget _activeChips(ThemeProvider theme) {
    final chips = <Widget>[];
    void chip(String text, VoidCallback clear) {
      chips.add(
        InputChip(
          label: Text(text, style: const TextStyle(fontSize: 10)),
          onDeleted: () => _applyAndSyncFields(clear),
          deleteIcon: const Icon(Icons.close, size: 12),
          visualDensity: VisualDensity.compact,
          backgroundColor: theme.lightModeColor.prColor300
              .withAlpha(25),
          side: BorderSide.none,
        ),
      );
    }

    void keyChip(
      String title,
      String? key,
      List<OrderReportFilterOption> options,
      VoidCallback clear,
    ) {
      if (key == null) return;
      chip(
        '$title: ${OrderReportOptions.labelFor(options, key, title)}',
        clear,
      );
    }

    void rangeChip(
      String title,
      double? min,
      double? max,
      VoidCallback clear,
    ) {
      if (min == null && max == null) return;
      chip(
        '$title: ${min != null ? _money(min) : 'Any'}'
        ' - ${max != null ? _money(max) : 'Any'}',
        clear,
      );
    }

    if (_filters.deliveryStatus != null) {
      chip(
        'Status: ${_filters.deliveryStatus!.label}',
        () => _filters.deliveryStatus = null,
      );
    }
    if (_filters.recordsDisagree) {
      chip(
        'Records disagree',
        () => _filters.recordsDisagree = false,
      );
    }
    if (_filters.channel != null) {
      chip(
        'Channel: ${_filters.channel!.label}',
        () => _filters.channel = null,
      );
    }
    keyChip(
      'Staff',
      _filters.staffKey,
      _staffOptions,
      () => _filters.staffKey = null,
    );
    keyChip(
      'Customer',
      _filters.customerKey,
      _customerOptions,
      () => _filters.customerKey = null,
    );
    if (_subStaffEnabled) {
      keyChip(
        'Sub-Staff',
        _filters.subStaffKey,
        _subStaffOptions,
        () => _filters.subStaffKey = null,
      );
    }
    if (_departmentsEnabled) {
      keyChip(
        'Department',
        _filters.departmentKey,
        _departmentOptions,
        () => _filters.departmentKey = null,
      );
    }
    rangeChip('Total', _filters.totalMin, _filters.totalMax, () {
      _filters.totalMin = null;
      _filters.totalMax = null;
    });
    rangeChip('Paid', _filters.paidMin, _filters.paidMax, () {
      _filters.paidMin = null;
      _filters.paidMax = null;
    });
    rangeChip(
      'Balance',
      _filters.balanceMin,
      _filters.balanceMax,
      () {
        _filters.balanceMin = null;
        _filters.balanceMax = null;
      },
    );
    if (_canSeeCost) {
      rangeChip(
        'Profit/Loss',
        _filters.profitMin,
        _filters.profitMax,
        () {
          _filters.profitMin = null;
          _filters.profitMax = null;
        },
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

  Widget _notes() {
    final notes = orderReportNotes(period: _period);
    if (notes.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Align(
        alignment: Alignment.centerLeft,
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
      ),
    );
  }

  // ---------------------------------------------------------------
  // table
  // ---------------------------------------------------------------

  static const String _disagreeNote = 'Records disagree';
  static const String _disagreeTip =
      'The order\'s stored quantities and its delivery receipts '
      'disagree. The larger delivered quantity is used.';
  static const String _linesNote = 'Receipt lines unavailable';
  static const String _linesTip =
      'A delivery receipt has no item data, so only the order\'s '
      'stored quantities are used.';
  static const String _estimateTip =
      'Estimated until the order is Fully Delivered';

  TextStyle _cellStyle(
    ThemeProvider theme, {
    bool bold = false,
    Color? color,
  }) => TextStyle(
    fontSize: theme.mobileTexts.b3.fontSize,
    fontWeight: bold ? FontWeight.bold : FontWeight.w500,
    color: color ?? Colors.black87,
  );

  Widget _txt(
    ThemeProvider theme,
    String text, {
    bool bold = false,
    Color? color,
    TextAlign? align,
    String? tooltip,
  }) {
    final t = Text(
      text,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      textAlign: align,
      style: _cellStyle(theme, bold: bold, color: color),
    );
    return tooltip == null
        ? t
        : Tooltip(message: tooltip, child: t);
  }

  Widget _badge(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 10,
      vertical: 4,
    ),
    decoration: BoxDecoration(
      color: color.withAlpha(30),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: color,
      ),
    ),
  );

  Color? _signColor(ThemeProvider theme, double v) =>
      v > 0
          ? Colors.green.shade700
          : (v < 0 ? theme.lightModeColor.errorColor200 : null);

  Color _statusColor(OrderDeliveryStatus s) {
    switch (s) {
      case OrderDeliveryStatus.full:
        return Colors.green.shade700;
      case OrderDeliveryStatus.partial:
        return Colors.orange.shade800;
      case OrderDeliveryStatus.undelivered:
        return Colors.blueGrey;
    }
  }

  Widget _profitText(
    ThemeProvider theme,
    double? p, {
    required bool estimate,
    bool bold = true,
  }) {
    if (p == null) {
      return _txt(
        theme,
        'N/A',
        color: Colors.grey,
        tooltip: 'No cost price on this order\'s items',
      );
    }
    return _txt(
      theme,
      estimate ? 'Est. ${_money(p)}' : _money(p),
      bold: bold,
      color: _signColor(theme, p),
      tooltip: estimate ? _estimateTip : null,
    );
  }

  Widget _items(ThemeProvider theme, double? v) =>
      v == null
          ? _txt(
            theme,
            '—',
            color: Colors.grey,
            tooltip: 'A unit conversion failed',
          )
          : _txt(theme, formatLargeNumberDouble(v));

  Widget _value(ThemeProvider theme, double? v) =>
      v == null
          ? _txt(
            theme,
            '—',
            color: Colors.grey,
            tooltip: 'Delivery status could not be worked out',
          )
          : _txt(theme, _money(v));

  List<_Col> _columns(ThemeProvider theme) {
    const dash = '—';
    final cost = _canSeeCost;
    Widget bold(String text, {Color? color}) =>
        _txt(theme, text, bold: true, color: color);

    return [
      _Col(
        label: 'ID',
        width: 170,
        sort: OrderSortField.id,
        align: TextAlign.start,
        cell: (r) {
          final id = _txt(
            theme,
            r.displayId,
            bold: true,
            align: TextAlign.start,
          );
          final IconData? icon;
          final Color? color;
          final String? tip;
          if (r.recordsDisagree) {
            icon = Icons.warning_amber_rounded;
            color = Colors.orange.shade800;
            tip = _disagreeTip;
          } else if (r.delivery.receiptLinesUnavailable) {
            icon = Icons.info_outline_rounded;
            color = Colors.grey.shade600;
            tip = _linesTip;
          } else {
            icon = null;
            color = null;
            tip = null;
          }
          if (icon == null) return id;
          return Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 4,
            children: [
              Flexible(child: id),
              Tooltip(
                message: tip!,
                child: Icon(icon, size: 15, color: color),
              ),
            ],
          );
        },
        total:
            (_) => _txt(
              theme,
              'TOTAL',
              bold: true,
              align: TextAlign.start,
            ),
      ),
      _Col(
        label: 'Staff',
        width: 160,
        sort: OrderSortField.staff,
        align: TextAlign.start,
        cell:
            (r) => _txt(
              theme,
              r.staffLabel,
              align: TextAlign.start,
              color: r.staffName == null ? Colors.grey : null,
            ),
      ),
      if (_subStaffEnabled)
        _Col(
          label: 'Sub-Staff',
          width: 150,
          sort: OrderSortField.subStaff,
          align: TextAlign.start,
          cell:
              (r) => _txt(
                theme,
                r.subStaffLabel,
                align: TextAlign.start,
                color: r.subStaffName == null ? Colors.grey : null,
              ),
        ),
      _Col(
        label: 'Customer',
        width: 170,
        sort: OrderSortField.customer,
        align: TextAlign.start,
        cell:
            (r) => _txt(
              theme,
              r.customerLabel,
              align: TextAlign.start,
              color: r.customerName == null ? Colors.grey : null,
            ),
      ),
      _Col(
        label: 'Date',
        width: 120,
        sort: OrderSortField.createdAt,
        cell: (r) => _txt(theme, formatDateTime(r.createdAt)),
      ),
      _Col(
        label: 'Time',
        width: 100,
        sort: OrderSortField.createdAt,
        cell: (r) => _txt(theme, formatTime(r.createdAt)),
      ),
      if (_departmentsEnabled)
        _Col(
          label: 'Department',
          width: 160,
          sort: OrderSortField.department,
          align: TextAlign.start,
          cell:
              (r) => _txt(
                theme,
                r.departmentLabel,
                align: TextAlign.start,
                color: r.departmentKey == null ? Colors.grey : null,
              ),
        ),
      _Col(
        label: 'Status',
        width: 170,
        sort: OrderSortField.status,
        cell:
            (r) =>
                r.status == null
                    ? _txt(
                      theme,
                      dash,
                      color: Colors.grey,
                      tooltip:
                          'Delivery status could not be worked out',
                    )
                    : _badge(
                      r.status!.label,
                      _statusColor(r.status!),
                    ),
      ),
      _Col(
        label: 'Items',
        width: 90,
        sort: OrderSortField.items,
        cell: (r) => _items(theme, r.delivery.orderedItems),
      ),
      _Col(
        label: 'Delivered',
        width: 100,
        sort: OrderSortField.delivered,
        cell: (r) => _items(theme, r.delivery.deliveredItems),
      ),
      _Col(
        label: 'Channel',
        width: 120,
        sort: OrderSortField.channel,
        cell:
            (r) => _txt(
              theme,
              r.channel.label,
              color:
                  r.channel == OrderPaymentChannel.unpaid
                      ? Colors.grey
                      : null,
            ),
      ),
      _Col(
        label: 'Discount',
        width: 130,
        cell: (r) {
          if (r.discountAmount <= 0) {
            return _txt(theme, dash, color: Colors.grey);
          }
          final pct = r.order.generalDiscount;
          final showPct =
              (r.order.fixedDiscount ?? 0) <= 0 && pct != null;
          return _txt(
            theme,
            showPct
                ? '${_money(r.discountAmount)} (${_percent(pct)})'
                : _money(r.discountAmount),
          );
        },
      ),
      _Col(
        label: 'VAT',
        width: 120,
        cell: (r) {
          if (r.vatAmount <= 0) {
            return _txt(theme, dash, color: Colors.grey);
          }
          final rate = r.order.vat;
          return _txt(
            theme,
            _money(r.vatAmount),
            tooltip: rate == null ? null : '${_percent(rate)} VAT',
          );
        },
      ),
      _Col(
        label: 'Total',
        width: 140,
        sort: OrderSortField.total,
        cell: (r) => bold(_money(r.total)),
        total: (t) => bold(_money(t.total)),
      ),
      _Col(
        label: 'Delivered Value',
        width: 150,
        sort: OrderSortField.deliveredValue,
        cell: (r) => _value(theme, r.deliveredValue),
        total: (t) => bold(_money(t.deliveredValue)),
      ),
      _Col(
        label: 'Undelivered Value',
        width: 160,
        sort: OrderSortField.undeliveredValue,
        cell: (r) => _value(theme, r.undeliveredValue),
        total: (t) => bold(_money(t.undeliveredValue)),
      ),
      _Col(
        label: 'Paid',
        width: 130,
        sort: OrderSortField.paid,
        cell: (r) => _txt(theme, _money(r.paid)),
        total: (t) => bold(_money(t.paid)),
      ),
      _Col(
        label: 'Balance',
        width: 130,
        sort: OrderSortField.balance,
        cell: (r) => _txt(theme, _money(r.balance)),
        total: (t) => bold(_money(t.balance)),
      ),
      if (cost)
        _Col(
          label: 'Cost',
          width: 130,
          sort: OrderSortField.cost,
          cell:
              (r) =>
                  r.cost == null
                      ? _txt(theme, 'N/A', color: Colors.grey)
                      : _txt(theme, _money(r.cost!)),
          total:
              (t) =>
                  t.cost == null
                      ? _txt(theme, 'N/A', color: Colors.grey)
                      : bold(_money(t.cost!)),
        ),
      if (cost)
        _Col(
          label: 'Profit/Loss',
          width: 170,
          sort: OrderSortField.profit,
          cell:
              (r) => _profitText(
                theme,
                r.profit,
                estimate: r.profitIsEstimate,
              ),
          total:
              (t) => _profitText(
                theme,
                t.profit,
                estimate: t.profitIsEstimate,
              ),
        ),
      if (cost)
        _Col(
          label: 'Margin (%)',
          width: 120,
          sort: OrderSortField.margin,
          cell: (r) {
            final m = r.margin;
            if (m == null) {
              return _txt(theme, 'N/A', color: Colors.grey);
            }
            return _txt(
              theme,
              _percent(m),
              color: _signColor(theme, m),
              tooltip: r.profitIsEstimate ? _estimateTip : null,
            );
          },
        ),
      _Col(
        label: 'Notes',
        width: 190,
        align: TextAlign.start,
        cell: (r) {
          if (r.recordsDisagree) {
            return _txt(
              theme,
              _disagreeNote,
              align: TextAlign.start,
              color: Colors.orange.shade800,
              tooltip: _disagreeTip,
            );
          }
          if (r.delivery.receiptLinesUnavailable) {
            return _txt(
              theme,
              _linesNote,
              align: TextAlign.start,
              color: Colors.grey.shade700,
              tooltip: _linesTip,
            );
          }
          return _txt(
            theme,
            dash,
            align: TextAlign.start,
            color: Colors.grey,
          );
        },
      ),
      _Col(
        label: 'Comment',
        width: 200,
        align: TextAlign.start,
        cell:
            (r) => _txt(
              theme,
              r.comment ?? dash,
              align: TextAlign.start,
              color: r.comment == null ? Colors.grey : null,
              tooltip:
                  (r.comment?.length ?? 0) > 40 ? r.comment : null,
            ),
      ),
    ];
  }

  Alignment _alignment(TextAlign a) =>
      a == TextAlign.start
          ? Alignment.centerLeft
          : (a == TextAlign.end
              ? Alignment.centerRight
              : Alignment.center);

  Widget _header(
    ThemeProvider theme, {
    required String label,
    required double width,
    required TextAlign align,
    required bool sortable,
    required bool isSorted,
    required bool ascending,
    required VoidCallback onTap,
  }) {
    final accent = theme.lightModeColor.prColor300;
    final content = Row(
      mainAxisAlignment:
          align == TextAlign.start
              ? MainAxisAlignment.start
              : MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      spacing: 3,
      children: [
        Flexible(
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: align,
            style: TextStyle(
              fontSize: theme.mobileTexts.b3.fontSize,
              fontWeight: FontWeight.bold,
              color: isSorted ? accent : Colors.black87,
            ),
          ),
        ),
        if (sortable)
          Icon(
            isSorted
                ? (ascending
                    ? Icons.arrow_upward_rounded
                    : Icons.arrow_downward_rounded)
                : Icons.unfold_more_rounded,
            size: 14,
            color: isSorted ? accent : Colors.grey,
          ),
      ],
    );
    final padded = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Align(alignment: _alignment(align), child: content),
    );
    return SizedBox(
      width: width,
      child:
          !sortable
              ? padded
              : InkWell(
                mouseCursor: SystemMouseCursors.click,
                onTap: onTap,
                child: padded,
              ),
    );
  }

  Widget _cells<T>(
    List<T> cols,
    double Function(T c) width,
    TextAlign Function(T c) align,
    Widget Function(T c) cell,
  ) {
    return Row(
      children: [
        for (final c in cols)
          SizedBox(
            width: width(c),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Align(
                alignment: _alignment(align(c)),
                child: cell(c),
              ),
            ),
          ),
      ],
    );
  }

  Widget _row(
    ThemeProvider theme,
    List<_Col> cols,
    OrderReportRow r,
    int i,
  ) {
    return Material(
      color: i.isEven ? Colors.white : Colors.grey.shade50,
      child: InkWell(
        mouseCursor: SystemMouseCursors.click,
        hoverColor: theme.lightModeColor.prColor300.withAlpha(20),
        onTap: () => _openOrder(r),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade100),
            ),
          ),
          child: _cells<_Col>(
            cols,
            (c) => c.width,
            (c) => c.align,
            (c) => c.cell(r),
          ),
        ),
      ),
    );
  }

  /// Totals of the whole filtered set, as the Invoice Report.
  Widget _totalsRow(
    ThemeProvider theme,
    Widget content,
  ) {
    return Container(
      height: 46,
      color: theme.lightModeColor.prColor300.withAlpha(25),
      child: content,
    );
  }

  Widget _frame(
    ThemeProvider theme, {
    required double totalWidth,
    required Widget header,
    required int itemCount,
    required Widget Function(int i) item,
    required Widget totals,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: const [
            BoxShadow(color: Color(0x14000000), blurRadius: 12),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w =
                totalWidth > constraints.maxWidth
                    ? totalWidth
                    : constraints.maxWidth;
            return Scrollbar(
              controller: _vScroll,
              thumbVisibility: true,
              notificationPredicate:
                  (notif) => notif.metrics.axis == Axis.vertical,
              child: Scrollbar(
                controller: _hScroll,
                thumbVisibility: true,
                notificationPredicate:
                    (notif) =>
                        notif.metrics.axis == Axis.horizontal,
                child: SingleChildScrollView(
                  controller: _hScroll,
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: w,
                    height: constraints.maxHeight,
                    child: Column(
                      children: [
                        Container(
                          height: 48,
                          color: theme.lightModeColor.prColor300
                              .withAlpha(22),
                          child: header,
                        ),
                        const Divider(height: 1),
                        Expanded(
                          child: ScrollConfiguration(
                            behavior: ScrollConfiguration.of(
                              context,
                            ).copyWith(scrollbars: false),
                            child: ListView.builder(
                              controller: _vScroll,
                              itemCount: itemCount,
                              itemExtent: 52,
                              itemBuilder: (context, i) => item(i),
                            ),
                          ),
                        ),
                        const Divider(height: 1, thickness: 1),
                        totals,
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

  Widget _table(ThemeProvider theme, OrderReportPage res) {
    final cols = _columns(theme);
    return _frame(
      theme,
      totalWidth: cols.fold<double>(0, (s, c) => s + c.width),
      header: Row(
        children: [
          for (final c in cols)
            _header(
              theme,
              label: c.label,
              width: c.width,
              align: c.align,
              sortable: c.sort != null,
              isSorted: c.sort != null && c.sort == _sortField,
              ascending: _ascending,
              onTap: () => _setSort(c.sort!),
            ),
        ],
      ),
      itemCount: res.rows.length,
      item: (i) => _row(theme, cols, res.rows[i], i),
      totals: _totalsRow(
        theme,
        _cells<_Col>(
          cols,
          (c) => c.width,
          (c) => c.align,
          (c) =>
              c.total?.call(res.totals) ?? const SizedBox.shrink(),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------
  // grouped by staff / customer / channel
  // ---------------------------------------------------------------

  List<_GCol> _groupColumns(ThemeProvider theme) {
    Widget bold(String text, {Color? color}) =>
        _txt(theme, text, bold: true, color: color);

    return [
      _GCol(
        label: _groupBy.label,
        width: 220,
        sort: OrderGroupSortField.name,
        align: TextAlign.start,
        cell:
            (g) => _txt(
              theme,
              g.label,
              bold: true,
              align: TextAlign.start,
              color: g.isNone || g.name == null ? Colors.grey : null,
            ),
        total:
            (_) => _txt(
              theme,
              'TOTAL',
              bold: true,
              align: TextAlign.start,
            ),
      ),
      _GCol(
        label: 'Orders',
        width: 100,
        sort: OrderGroupSortField.count,
        cell: (g) => _txt(theme, '${g.count}'),
        total: (t) => bold('${t.count}'),
      ),
      _GCol(
        label: 'Total',
        width: 150,
        sort: OrderGroupSortField.total,
        cell: (g) => bold(_money(g.total)),
        total: (t) => bold(_money(t.total)),
      ),
      _GCol(
        label: 'Delivered Value',
        width: 150,
        sort: OrderGroupSortField.deliveredValue,
        cell: (g) => _txt(theme, _money(g.deliveredValue)),
        total: (t) => bold(_money(t.deliveredValue)),
      ),
      _GCol(
        label: 'Undelivered Value',
        width: 160,
        sort: OrderGroupSortField.undeliveredValue,
        cell: (g) => _txt(theme, _money(g.undeliveredValue)),
        total: (t) => bold(_money(t.undeliveredValue)),
      ),
      _GCol(
        label: 'Paid',
        width: 140,
        sort: OrderGroupSortField.paid,
        cell: (g) => _txt(theme, _money(g.paid)),
        total: (t) => bold(_money(t.paid)),
      ),
      _GCol(
        label: 'Balance',
        width: 140,
        sort: OrderGroupSortField.balance,
        cell: (g) => _txt(theme, _money(g.balance)),
        total: (t) => bold(_money(t.balance)),
      ),
      if (_canSeeCost)
        _GCol(
          label: 'Profit/Loss',
          width: 170,
          cell:
              (g) => _profitText(
                theme,
                g.profit,
                estimate: g.profitIsEstimate,
              ),
          total:
              (t) => _profitText(
                theme,
                t.profit,
                estimate: t.profitIsEstimate,
              ),
        ),
    ];
  }

  /// No row tap: a group has no single order to open.
  Widget _groupRow(List<_GCol> cols, OrderReportGroupRow g, int i) {
    return Container(
      decoration: BoxDecoration(
        color: i.isEven ? Colors.white : Colors.grey.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100),
        ),
      ),
      child: _cells<_GCol>(
        cols,
        (c) => c.width,
        (c) => c.align,
        (c) => c.cell(g),
      ),
    );
  }

  Widget _groupTable(
    ThemeProvider theme,
    OrderReportGroupPage res,
  ) {
    final cols = _groupColumns(theme);
    return _frame(
      theme,
      totalWidth: cols.fold<double>(0, (s, c) => s + c.width),
      header: Row(
        children: [
          for (final c in cols)
            _header(
              theme,
              label: c.label,
              width: c.width,
              align: c.align,
              sortable: c.sort != null,
              isSorted:
                  c.sort != null && c.sort == _groupSortField,
              ascending: _groupAscending,
              onTap: () => _setGroupSort(c.sort!),
            ),
        ],
      ),
      itemCount: res.rows.length,
      item: (i) => _groupRow(cols, res.rows[i], i),
      totals: _totalsRow(
        theme,
        _cells<_GCol>(
          cols,
          (c) => c.width,
          (c) => c.align,
          (c) =>
              c.total?.call(res.totals) ?? const SizedBox.shrink(),
        ),
      ),
    );
  }
}
