import 'package:flutter/material.dart';
import 'package:stockall/classes/checkout_response.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/refresh_functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/products/product_details/product_details_page.dart';
import 'package:stockall/pages/report/components/report_pager.dart';
import 'package:stockall/pages/report/components/report_pill.dart';
import 'package:stockall/pages/report/components/report_range_fields.dart';
import 'package:stockall/pages/report/sales_report_/item_sales_report_main/class/item_sales_report_logic.dart';
import 'package:stockall/pages/report/sales_report_/item_sales_report_main/components/item_sales_report_filter_widgets.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/components/receipts_report_filter_widgets.dart';
import 'package:stockall/pages/sales/make_sales/receipt_page/receipt_page.dart';
import 'package:stockall/providers/theme_provider.dart';

class _Col {
  final ItemSalesColumn column;
  final double width;
  final TextAlign align;
  final String? tooltip;
  final Widget Function(ItemSalesRow row) cell;

  const _Col({
    required this.column,
    required this.width,
    required this.cell,
    this.align = TextAlign.center,
    this.tooltip,
  });

  ItemSalesSortField? get sort => column.sort;
}

/// Shared body of the Item Sales Report page (desktop + mobile):
/// one row per sold line.
class ItemSalesReportMainView extends StatefulWidget {
  final bool isDesktop;

  const ItemSalesReportMainView({
    super.key,
    required this.isDesktop,
  });

  @override
  State<ItemSalesReportMainView> createState() =>
      _ItemSalesReportMainViewState();
}

class _ItemSalesReportMainViewState
    extends State<ItemSalesReportMainView> {
  final _filters = ItemSalesFilters();
  final _searchCtrl = TextEditingController();
  final _revMinCtrl = TextEditingController();
  final _revMaxCtrl = TextEditingController();
  final _profitMinCtrl = TextEditingController();
  final _profitMaxCtrl = TextEditingController();
  final _qtyMinCtrl = TextEditingController();
  final _qtyMaxCtrl = TextEditingController();
  final _hScroll = ScrollController();
  final _vScroll = ScrollController();

  ItemSalesSortField _sortField =
      ItemSalesSortField.createdAt;
  bool _ascending = false;
  int _page = 1;
  bool _showFilters = false;

  ReceiptsReportPeriod _period =
      ReceiptsReportPeriod.today();

  bool _loading = true;
  String? _error;

  List<ItemSalesRow> _baseRows = [];
  ItemSalesPage? _result;
  int _profitExcluded = 0;
  int _quantityExcluded = 0;
  bool _cartDiscountInView = false;
  String _signature = '';

  ReceiptsFilterChoices _choices =
      ReceiptsFilterChoices.empty;
  List<ReceiptsFilterOption> _categoryOptions = [];
  List<ReceiptsFilterOption> _allItemOptions = [];
  List<ReceiptsFilterOption> _itemOptions = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load(refreshFromStore: false);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _revMinCtrl.dispose();
    _revMaxCtrl.dispose();
    _profitMinCtrl.dispose();
    _profitMaxCtrl.dispose();
    _qtyMinCtrl.dispose();
    _qtyMaxCtrl.dispose();
    _hScroll.dispose();
    _vScroll.dispose();
    super.dispose();
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
      final provider = returnReceiptProviderSingle();
      if (refreshFromStore) {
        await RefreshFunctions(
          context,
        ).refreshReceipts(context);
      } else {
        // Local (offline) reads, only when nothing is loaded yet.
        final sid = shopSingle()?.shopId;
        if (sid != null) {
          if (provider.receipts.isEmpty) {
            await provider.loadReceiptsOffline(sid);
          }
          if (provider.mainSales.isEmpty) {
            await provider.loadProductSalesRecordOffline(
              sid,
            );
          }
        }
      }
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
    final profitVisible = _canSeeCost;
    if (!profitVisible &&
        (_sortField == ItemSalesSortField.cost ||
            _sortField == ItemSalesSortField.profit ||
            _sortField == ItemSalesSortField.margin)) {
      _sortField = ItemSalesSortField.createdAt;
      _ascending = false;
    }
    final sorted = ItemSalesQuery.filterAndSort(
      rows: _baseRows,
      period: _period,
      filters: _filters,
      sortField: _sortField,
      ascending: _ascending,
      departmentsEnabled: _departmentsEnabled,
      subStaffEnabled: _subStaffEnabled,
      profitVisible: profitVisible,
    );
    final page = ItemSalesQuery.paginate(sorted, _page);
    _page = page.page;
    _result = page;
    _profitExcluded = ItemSalesQuery.profitExcludedCount(
      rows: _baseRows,
      period: _period,
      filters: _filters,
      departmentsEnabled: _departmentsEnabled,
      subStaffEnabled: _subStaffEnabled,
      profitVisible: profitVisible,
    );
    _quantityExcluded =
        ItemSalesQuery.quantityExcludedCount(
          rows: _baseRows,
          period: _period,
          filters: _filters,
          departmentsEnabled: _departmentsEnabled,
          subStaffEnabled: _subStaffEnabled,
          profitVisible: profitVisible,
        );
    _cartDiscountInView = sorted.any(
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

  void _apply(
    VoidCallback change, {
    bool resetPage = true,
  }) {
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
    final r = _result;
    if (r == null ||
        p < 1 ||
        p > r.totalPages ||
        p == r.page) {
      return;
    }
    _apply(() => _page = p, resetPage: false);
    if (_vScroll.hasClients) {
      _vScroll.jumpTo(0);
    }
  }

  void _setSort(ItemSalesSortField f) {
    _apply(() {
      if (_sortField == f) {
        _ascending = !_ascending;
      } else {
        _sortField = f;
        // Names A-Z first; dates and amounts largest first.
        _ascending =
            f == ItemSalesSortField.item ||
            f == ItemSalesSortField.category ||
            f == ItemSalesSortField.receiptId ||
            f == ItemSalesSortField.staff ||
            f == ItemSalesSortField.customer;
      }
    });
  }

  void _resetAll() {
    _searchCtrl.clear();
    _revMinCtrl.clear();
    _revMaxCtrl.clear();
    _profitMinCtrl.clear();
    _profitMaxCtrl.clear();
    _qtyMinCtrl.clear();
    _qtyMaxCtrl.clear();
    _apply(_filters.clearAll);
  }

  void _afterReturn() {
    // Picks up an edit or delete made on the opened page.
    if (mounted) {
      setState(() {
        _rebuildBase();
        try {
          _recompute();
        } catch (_) {}
      });
    }
  }

  void _openReceipt(ItemSalesRow row) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ReceiptPage(
              response: CheckoutResponse(
                receipt: row.parent.receipt,
              ),
              isMain: false,
            ),
      ),
    ).then((_) => _afterReturn());
  }

  void _openItem(ItemSalesRow row) {
    final uuid = row.productKey;
    if (uuid == null || !row.productExists) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                ProductDetailsPage(productUuid: uuid),
      ),
    ).then((_) => _afterReturn());
  }

  void _setPeriod(ReceiptsReportPeriod p) =>
      _apply(() => _period = p);

  /// Clears a range's fields once its filter was removed (chip).
  void _applyAndSyncFields(VoidCallback change) {
    _apply(change);
    final r = _filters.receipt;
    if (r.revenueMin == null && r.revenueMax == null) {
      _revMinCtrl.clear();
      _revMaxCtrl.clear();
    }
    if (r.profitMin == null && r.profitMax == null) {
      _profitMinCtrl.clear();
      _profitMaxCtrl.clear();
    }
    if (!_filters.quantitySet) {
      _qtyMinCtrl.clear();
      _qtyMaxCtrl.clear();
    }
    if (_filters.search.isEmpty) _searchCtrl.clear();
  }

  // ---------------------------------------------------------------
  // formatting
  // ---------------------------------------------------------------

  String _money(num v) =>
      formatMoneyBig(amount: v, context: context);

  String _percent(double v) =>
      '${formatLargeNumberDouble(double.parse(v.toStringAsFixed(2)))}%';

  // ---------------------------------------------------------------
  // build
  // ---------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = returnTheme(context);
    // Listen, so sales, edits, sync, items and categories update
    // the table.
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
        title: 'Item Sales Report',
        // Icon only on the mobile layout, as on the receipt
        // summary, so the centred title is not crowded.
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
                : Row(
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
                              : () => _load(
                                refreshFromStore: true,
                              ),
                    ),
                    const SizedBox(width: 6),
                  ],
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
            _notes(theme),
            Expanded(child: _content(theme)),
            if (!_loading &&
                _error == null &&
                _result != null)
              ReportPager(
                theme: theme,
                page: _result!.page,
                totalPages: _result!.totalPages,
                totalCount: _result!.totalCount,
                firstIndex: _result!.firstIndex,
                lastIndex: _result!.lastIndex,
                itemLabel: 'item records',
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
              'The report could not be generated.',
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
    final res = _result;
    if (res == null || res.totalCount == 0) {
      final hasFilters = _filters.hasAnything;
      return Padding(
        padding: const EdgeInsets.only(top: 60),
        child: EmptyWidgetDisplayOnly(
          title:
              hasFilters
                  ? 'No Matching Item Records'
                  : 'Empty List',
          subText:
              hasFilters
                  ? 'No item record matches your search and filters'
                  : 'No item was sold in this period',
          theme: theme,
          height: 35,
          icon: Icons.clear,
          altAction: hasFilters ? _resetAll : null,
          altActionText:
              hasFilters ? 'Clear all filters' : null,
          altIcon: hasFilters ? Icons.filter_alt_off : null,
        ),
      );
    }
    return _table(theme, res);
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
            width: widget.isDesktop ? 360 : double.infinity,
            height: 38,
            child: TextField(
              controller: _searchCtrl,
              onChanged:
                  (v) => _apply(() => _filters.search = v),
              decoration: InputDecoration(
                hintText:
                    _departmentsEnabled
                        ? 'Search item, category, receipt, staff, customer or department'
                        : 'Search item, category, receipt, staff or customer',
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
        ),
        ReceiptsReportPeriodButton(
          theme: theme,
          period: _period,
          enabled: _canPickDate,
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
        if (_filters.hasAnything)
          ReportPill(
            theme: theme,
            icon: Icons.filter_alt_off,
            label: 'Reset All Filters',
            onTap: _resetAll,
            color: accent,
          ),
      ],
    );
  }

  Widget _filterPanel(ThemeProvider theme) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      constraints: BoxConstraints(
        maxHeight:
            MediaQuery.of(context).size.height *
            (widget.isDesktop ? 0.5 : 0.4),
      ),
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
      child: SingleChildScrollView(
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
            ReportRangeFields(
              label: 'Item revenue range',
              minController: _revMinCtrl,
              maxController: _revMaxCtrl,
              errorText: _filters.receipt.revenueRangeError,
              onChange:
                  (a, b) => _apply(() {
                    _filters.receipt.revenueMin = a;
                    _filters.receipt.revenueMax = b;
                  }),
            ),
            if (_canSeeCost)
              ReportRangeFields(
                label: 'Profit/Loss range',
                minController: _profitMinCtrl,
                maxController: _profitMaxCtrl,
                allowNegative: true,
                errorText:
                    _filters.receipt.profitRangeError,
                onChange:
                    (a, b) => _apply(() {
                      _filters.receipt.profitMin = a;
                      _filters.receipt.profitMax = b;
                    }),
              ),
            ReportRangeFields(
              label: 'Quantity range (base unit, one item)',
              minController: _qtyMinCtrl,
              maxController: _qtyMaxCtrl,
              errorText:
                  _filters.quantityRangeError ??
                  (_filters.quantityNeedsItem
                      ? 'Select an item to apply this range'
                      : null),
              onChange:
                  (a, b) => _apply(() {
                    _filters.quantityMin = a;
                    _filters.quantityMax = b;
                  }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _activeChips(ThemeProvider theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ItemSalesFilterChips(
          theme: theme,
          filters: _filters,
          categoryOptions: _categoryOptions,
          itemOptions: _allItemOptions,
          onApply: _applyAndSyncFields,
        ),
        ReceiptsReportFilterChips(
          theme: theme,
          filters: _filters.receipt,
          choices: _choices,
          departmentsEnabled: _departmentsEnabled,
          subStaffEnabled: _subStaffEnabled,
          profitVisible: _canSeeCost,
          money: _money,
          onApply: _applyAndSyncFields,
        ),
      ],
    );
  }

  Widget _notes(ThemeProvider theme) {
    final notes = <String>[
      if (_period.isAllTime)
        'All time covers the receipts loaded on this device.',
      if (_cartDiscountInView)
        'Cart discounts on a receipt are not included in its '
            'item revenue.',
      if (_profitExcluded > 0)
        '$_profitExcluded item record${_profitExcluded == 1 ? ' is' : 's are'} '
            'left out of the profit range: missing cost price.',
      if (_quantityExcluded > 0)
        '$_quantityExcluded item record${_quantityExcluded == 1 ? ' is' : 's are'} '
            'left out of the quantity range: invoice part '
            'payment or unknown unit.',
    ];
    if (notes.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 2,
          children: [
            for (final n in notes)
              Row(
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
        ),
      ),
    );
  }

  // ---------------------------------------------------------------
  // table
  // ---------------------------------------------------------------

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
          : (v < 0
              ? theme.lightModeColor.errorColor200
              : null);

  Color _typeColor(ReceiptType t) {
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

  static String _yesNo(bool? v) =>
      v == null ? '—' : (v ? 'Yes' : 'No');

  static const String _partPaymentTip =
      'Invoice part payment: amounts are this payment\'s share; '
      'quantities are the whole invoice\'s';

  List<_Col> _columns(ThemeProvider theme) {
    const dash = '—';
    final accent = theme.lightModeColor.prColor300;

    Widget greyDash({String? tooltip}) => _txt(
      theme,
      dash,
      color: Colors.grey,
      tooltip: tooltip,
    );

    Widget person(String label, String? name) => _txt(
      theme,
      label,
      align: TextAlign.start,
      color: name == null ? Colors.grey : null,
    );

    _Col build(ItemSalesColumn c) {
      switch (c) {
        case ItemSalesColumn.recordId:
          return _Col(
            column: c,
            width: 120,
            align: TextAlign.start,
            cell:
                (r) =>
                    r.recordLabel == null
                        ? greyDash()
                        : _txt(
                          theme,
                          r.recordLabel!,
                          align: TextAlign.start,
                          tooltip: r.recordId,
                        ),
          );
        case ItemSalesColumn.item:
          return _Col(
            column: c,
            width: 190,
            align: TextAlign.start,
            cell: (r) {
              final text = _txt(
                theme,
                r.itemLabel,
                bold: true,
                align: TextAlign.start,
                color:
                    r.itemName == null
                        ? Colors.grey
                        : (r.productExists ? accent : null),
                tooltip:
                    r.productExists
                        ? 'Open item details'
                        : 'Item no longer exists',
              );
              if (!r.productExists) return text;
              return InkWell(
                mouseCursor: SystemMouseCursors.click,
                onTap: () => _openItem(r),
                child: text,
              );
            },
          );
        case ItemSalesColumn.category:
          return _Col(
            column: c,
            width: 170,
            align: TextAlign.start,
            cell:
                (r) => _txt(
                  theme,
                  r.categoryLabel,
                  align: TextAlign.start,
                  color:
                      r.categoryNames.isEmpty
                          ? Colors.grey
                          : null,
                  tooltip:
                      r.categoryNames.length > 1
                          ? r.categoryLabel
                          : null,
                ),
          );
        case ItemSalesColumn.receiptId:
          return _Col(
            column: c,
            width: 150,
            align: TextAlign.start,
            cell:
                (r) => _txt(
                  theme,
                  r.receiptId,
                  bold: true,
                  align: TextAlign.start,
                  tooltip:
                      r.isPartPayment
                          ? 'Invoice payment receipt'
                          : null,
                ),
          );
        case ItemSalesColumn.staff:
          return _Col(
            column: c,
            width: 150,
            align: TextAlign.start,
            cell:
                (r) => person(
                  r.parent.staffLabel,
                  r.parent.staffName,
                ),
          );
        case ItemSalesColumn.subStaff:
          return _Col(
            column: c,
            width: 140,
            align: TextAlign.start,
            cell:
                (r) => person(
                  r.parent.subStaffLabel,
                  r.parent.subStaffName,
                ),
          );
        case ItemSalesColumn.customer:
          return _Col(
            column: c,
            width: 160,
            align: TextAlign.start,
            cell:
                (r) => person(
                  r.parent.customerLabel,
                  r.parent.customerName,
                ),
          );
        case ItemSalesColumn.date:
          return _Col(
            column: c,
            width: 120,
            cell:
                (r) => _txt(
                  theme,
                  formatDateTime(r.createdAt),
                ),
          );
        case ItemSalesColumn.time:
          return _Col(
            column: c,
            width: 100,
            cell:
                (r) => _txt(theme, formatTime(r.createdAt)),
          );
        case ItemSalesColumn.quantity:
          return _Col(
            column: c,
            width: 100,
            cell:
                (r) => _txt(
                  theme,
                  formatDimension(r.quantity),
                  color:
                      r.isPartPayment ? Colors.grey : null,
                  tooltip:
                      r.isPartPayment
                          ? _partPaymentTip
                          : null,
                ),
          );
        case ItemSalesColumn.unit:
          return _Col(
            column: c,
            width: 130,
            cell:
                (r) =>
                    r.unitName == null
                        ? greyDash()
                        : _txt(theme, r.unitName!),
          );
        case ItemSalesColumn.sellingPrice:
          return _Col(
            column: c,
            width: 140,
            tooltip: 'Per sale unit, before discount',
            cell:
                (r) =>
                    r.sellingPrice == null
                        ? greyDash(
                          tooltip:
                              r.isPartPayment
                                  ? _partPaymentTip
                                  : 'Not available for this line',
                        )
                        : _txt(
                          theme,
                          _money(r.sellingPrice!),
                        ),
          );
        case ItemSalesColumn.discount:
          return _Col(
            column: c,
            width: 140,
            cell: (r) {
              final v = r.discount;
              if (v == null) return greyDash();
              final pct = r.discountPercent;
              return _txt(
                theme,
                pct == null
                    ? _money(v)
                    : '${_money(v)} (${_percent(pct)})',
              );
            },
          );
        case ItemSalesColumn.grossValue:
          return _Col(
            column: c,
            width: 140,
            tooltip: 'Selling value before line discount',
            cell:
                (r) =>
                    r.grossValue == null
                        ? greyDash()
                        : _txt(
                          theme,
                          _money(r.grossValue!),
                        ),
          );
        case ItemSalesColumn.costPrice:
          return _Col(
            column: c,
            width: 140,
            tooltip: 'Line total cost',
            cell:
                (r) =>
                    r.cost == null
                        ? _txt(
                          theme,
                          'N/A',
                          color: Colors.grey,
                          tooltip: 'Cost missing',
                        )
                        : _txt(theme, _money(r.cost!)),
          );
        case ItemSalesColumn.department:
          return _Col(
            column: c,
            width: 150,
            align: TextAlign.start,
            cell:
                (r) => _txt(
                  theme,
                  r.parent.departmentLabel,
                  align: TextAlign.start,
                  color:
                      r.parent.departmentKey == null
                          ? Colors.grey
                          : null,
                ),
          );
        case ItemSalesColumn.customPrice:
          return _Col(
            column: c,
            width: 120,
            cell:
                (r) => _txt(
                  theme,
                  r.customTotal
                      ? 'Yes (total)'
                      : _yesNo(r.customPrice),
                ),
          );
        case ItemSalesColumn.wholesale:
          return _Col(
            column: c,
            width: 120,
            cell:
                (r) => _txt(
                  theme,
                  _yesNo(r.wholesale),
                  color:
                      r.wholesale == null
                          ? Colors.grey
                          : null,
                ),
          );
        case ItemSalesColumn.managed:
          return _Col(
            column: c,
            width: 110,
            cell:
                (r) => _txt(
                  theme,
                  _yesNo(r.managed),
                  color:
                      r.managed == null
                          ? Colors.grey
                          : null,
                ),
          );
        case ItemSalesColumn.type:
          return _Col(
            column: c,
            width: 150,
            cell:
                (r) => _badge(
                  r.type.label,
                  _typeColor(r.type),
                ),
          );
        case ItemSalesColumn.voidStatus:
          return _Col(
            column: c,
            width: 90,
            cell:
                (r) =>
                    r.isVoid
                        ? _badge(
                          'VOID',
                          theme
                              .lightModeColor
                              .errorColor200,
                        )
                        : _txt(theme, 'No'),
          );
        case ItemSalesColumn.wastage:
          return _Col(
            column: c,
            width: 140,
            cell: (r) {
              final w = r.wastage;
              if (w == null) {
                return greyDash(
                  tooltip:
                      'Wastage set (${r.wastageSetting}) but its '
                      'unit is no longer known',
                );
              }
              if (w <= 0) return greyDash();
              return _txt(
                theme,
                '${formatDimension(w)} ${r.unitName ?? ''}'
                    .trim(),
                tooltip:
                    r.wastageSetting == null
                        ? null
                        : 'Entered as ${r.wastageSetting}',
              );
            },
          );
        case ItemSalesColumn.revenue:
          return _Col(
            column: c,
            width: 150,
            cell:
                (r) => _txt(
                  theme,
                  _money(r.revenue),
                  bold: true,
                  tooltip:
                      r.isPartPayment
                          ? _partPaymentTip
                          : null,
                ),
          );
        case ItemSalesColumn.profit:
          return _Col(
            column: c,
            width: 150,
            cell: (r) {
              final value = _txt(
                theme,
                _money(r.profit),
                bold: true,
                color: _signColor(theme, r.profit),
              );
              if (!r.costMissing) return value;
              return Tooltip(
                message:
                    'Cost missing: this item has no cost price, '
                    'so its cost is counted as 0',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 4,
                  children: [
                    Flexible(child: value),
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 14,
                      color: Colors.orange.shade800,
                    ),
                  ],
                ),
              );
            },
          );
        case ItemSalesColumn.margin:
          return _Col(
            column: c,
            width: 120,
            cell: (r) {
              final m = r.margin;
              if (m == null) {
                return _txt(
                  theme,
                  'N/A',
                  color: Colors.grey,
                );
              }
              return _txt(
                theme,
                _percent(m),
                color: _signColor(theme, m),
              );
            },
          );
      }
    }

    return ItemSalesColumnInfo.visible(
      departmentsEnabled: _departmentsEnabled,
      subStaffEnabled: _subStaffEnabled,
      costVisible: _canSeeCost,
    ).map(build).toList();
  }

  Alignment _alignment(TextAlign a) =>
      a == TextAlign.start
          ? Alignment.centerLeft
          : (a == TextAlign.end
              ? Alignment.centerRight
              : Alignment.center);

  Widget _headerCell(ThemeProvider theme, _Col c) {
    final isSorted = c.sort != null && c.sort == _sortField;
    final accent = theme.lightModeColor.prColor300;
    final content = Row(
      mainAxisAlignment:
          c.align == TextAlign.start
              ? MainAxisAlignment.start
              : (c.align == TextAlign.end
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.center),
      mainAxisSize: MainAxisSize.min,
      spacing: 3,
      children: [
        Flexible(
          child: Text(
            c.column.label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: c.align,
            style: TextStyle(
              fontSize: theme.mobileTexts.b3.fontSize,
              fontWeight: FontWeight.bold,
              color: isSorted ? accent : Colors.black87,
            ),
          ),
        ),
        if (c.sort != null)
          Icon(
            isSorted
                ? (_ascending
                    ? Icons.arrow_upward_rounded
                    : Icons.arrow_downward_rounded)
                : Icons.unfold_more_rounded,
            size: 14,
            color: isSorted ? accent : Colors.grey,
          ),
      ],
    );
    Widget padded = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Align(
        alignment: _alignment(c.align),
        child: content,
      ),
    );
    if (c.tooltip != null) {
      padded = Tooltip(message: c.tooltip!, child: padded);
    }
    return SizedBox(
      width: c.width,
      child:
          c.sort == null
              ? padded
              : InkWell(
                mouseCursor: SystemMouseCursors.click,
                onTap: () => _setSort(c.sort!),
                child: padded,
              ),
    );
  }

  Widget _row(
    ThemeProvider theme,
    List<_Col> cols,
    ItemSalesRow r,
    int i,
  ) {
    final cells = Row(
      children: [
        for (final c in cols)
          SizedBox(
            width: c.width,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
              ),
              child: Align(
                alignment: _alignment(c.align),
                child: c.cell(r),
              ),
            ),
          ),
      ],
    );
    return Material(
      color:
          r.isVoid
              ? theme.lightModeColor.errorColor200
                  .withAlpha(12)
              : (i.isEven
                  ? Colors.white
                  : Colors.grey.shade50),
      child: InkWell(
        mouseCursor: SystemMouseCursors.click,
        hoverColor: theme.lightModeColor.prColor300
            .withAlpha(20),
        onTap: () => _openReceipt(r),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.shade100,
              ),
            ),
          ),
          // Void lines were removed from the cart, not sold.
          child:
              r.isVoid
                  ? Opacity(opacity: 0.55, child: cells)
                  : cells,
        ),
      ),
    );
  }

  /// Totals of the whole filtered set, as the Invoice Report.
  /// Void lines are left out.
  Widget _totalsRow(
    ThemeProvider theme,
    List<_Col> cols,
    ItemSalesPage res,
  ) {
    Widget cell(_Col c) {
      switch (c.column) {
        case ItemSalesColumn.item:
          return _txt(
            theme,
            'TOTAL',
            bold: true,
            align: TextAlign.start,
          );
        case ItemSalesColumn.quantity:
          final q = res.totalQuantity;
          if (q == null) return const SizedBox.shrink();
          return _txt(
            theme,
            '${formatDimension(q)} ${res.totalQuantityUnit ?? ''}'
                .trim(),
            bold: true,
          );
        case ItemSalesColumn.discount:
          return _txt(theme, _money(res.totalDiscount), bold: true);
        case ItemSalesColumn.grossValue:
          return _txt(
            theme,
            _money(res.totalGrossValue),
            bold: true,
          );
        case ItemSalesColumn.costPrice:
          return _txt(theme, _money(res.totalCost), bold: true);
        case ItemSalesColumn.revenue:
          return _txt(theme, _money(res.totalRevenue), bold: true);
        case ItemSalesColumn.profit:
          return _txt(
            theme,
            _money(res.totalProfit),
            bold: true,
            color: _signColor(theme, res.totalProfit),
          );
        case ItemSalesColumn.margin:
          final m = res.totalMargin;
          if (m == null) {
            return _txt(theme, 'N/A', color: Colors.grey);
          }
          return _txt(
            theme,
            _percent(m),
            bold: true,
            color: _signColor(theme, m),
          );
        default:
          return const SizedBox.shrink();
      }
    }

    return Container(
      height: 46,
      color: theme.lightModeColor.prColor300.withAlpha(25),
      child: Row(
        children: [
          for (final c in cols)
            SizedBox(
              width: c.width,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                ),
                child: Align(
                  alignment: _alignment(c.align),
                  child: cell(c),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _table(ThemeProvider theme, ItemSalesPage res) {
    final cols = _columns(theme);
    final totalWidth = cols.fold<double>(
      0,
      (s, c) => s + c.width,
    );

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 12,
            ),
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
                  (notif) =>
                      notif.metrics.axis == Axis.vertical,
              child: Scrollbar(
                controller: _hScroll,
                thumbVisibility: true,
                notificationPredicate:
                    (notif) =>
                        notif.metrics.axis ==
                        Axis.horizontal,
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
                          color: theme
                              .lightModeColor
                              .prColor300
                              .withAlpha(22),
                          child: Row(
                            children: [
                              for (final c in cols)
                                _headerCell(theme, c),
                            ],
                          ),
                        ),
                        const Divider(height: 1),
                        Expanded(
                          child: ScrollConfiguration(
                            behavior:
                                ScrollConfiguration.of(
                                  context,
                                ).copyWith(
                                  scrollbars: false,
                                ),
                            child: ListView.builder(
                              controller: _vScroll,
                              itemCount: res.rows.length,
                              itemExtent: 52,
                              itemBuilder:
                                  (context, i) => _row(
                                    theme,
                                    cols,
                                    res.rows[i],
                                    i,
                                  ),
                            ),
                          ),
                        ),
                        const Divider(height: 1, thickness: 1),
                        _totalsRow(theme, cols, res),
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
