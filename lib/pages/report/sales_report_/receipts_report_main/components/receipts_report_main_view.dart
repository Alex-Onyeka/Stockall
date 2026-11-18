import 'package:flutter/material.dart';
import 'package:stockall/classes/checkout_response.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/pages/report/components/report_period_loader.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/report/components/report_group_by.dart';
import 'package:stockall/pages/report/components/report_pager.dart';
import 'package:stockall/pages/report/components/report_range_fields.dart';
import 'package:stockall/pages/report/components/report_pill.dart';
import 'package:stockall/pages/report/components/export/report_export_button.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_export_spec.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/components/receipts_report_filter_widgets.dart';
import 'package:stockall/pages/sales/make_sales/receipt_page/receipt_page.dart';
import 'package:stockall/providers/theme_provider.dart';

class _Col {
  final String label;
  final double width;
  final ReceiptsSortField? sort;
  final TextAlign align;
  final Widget Function(ReceiptsReportRow row) cell;

  const _Col({
    required this.label,
    required this.width,
    required this.cell,
    this.sort,
    this.align = TextAlign.center,
  });
}

class _GCol {
  final String label;
  final double width;
  final ReceiptsTableGroupSortField? sort;
  final TextAlign align;
  final Widget Function(ReceiptsGroupRow row) cell;

  /// Cell of the totals row; empty when null.
  final Widget Function(ReceiptsGroupPage res)? total;

  const _GCol({
    required this.label,
    required this.width,
    required this.cell,
    this.sort,
    this.align = TextAlign.center,
    this.total,
  });
}

/// Shared body of the Receipts Report page (desktop + mobile).
///
/// [initialFilters] and [initialPeriod] let another page (the
/// receipt summary) open the table on a given set.
class ReceiptsReportMainView extends StatefulWidget {
  final bool isDesktop;
  final ReceiptsReportFilters? initialFilters;
  final ReceiptsReportPeriod? initialPeriod;

  const ReceiptsReportMainView({
    super.key,
    required this.isDesktop,
    this.initialFilters,
    this.initialPeriod,
  });

  @override
  State<ReceiptsReportMainView> createState() =>
      _ReceiptsReportMainViewState();
}

class _ReceiptsReportMainViewState
    extends State<ReceiptsReportMainView> {
  late final ReceiptsReportFilters _filters;
  final _searchCtrl = TextEditingController();
  final _revMinCtrl = TextEditingController();
  final _revMaxCtrl = TextEditingController();
  final _profitMinCtrl = TextEditingController();
  final _profitMaxCtrl = TextEditingController();
  final _hScroll = ScrollController();
  final _vScroll = ScrollController();

  ReceiptsSortField _sortField =
      ReceiptsSortField.createdAt;
  bool _ascending = false;
  int _page = 1;
  bool _showFilters = false;
  bool _toolbarIsOpen = false;

  late ReceiptsReportPeriod _period;

  // Grouping has its own sort, so the receipt sort is kept.
  ReportGroupBy _groupBy = ReportGroupBy.off;
  ReceiptsTableGroupSortField _groupSortField =
      ReceiptsTableGroupSortField.revenue;
  bool _groupAscending = false;
  ReceiptsGroupPage? _groupResult;

  bool get _grouped => _groupBy != ReportGroupBy.off;

  bool _loading = true;
  String? _error;

  List<ReceiptsReportRow> _baseRows = [];
  ReceiptsReportPage? _result;

  /// Every filtered, sorted receipt and every sorted group (all
  /// pages), for the export.
  List<ReceiptsReportRow> _sortedRows = const [];
  List<ReceiptsGroupRow> _sortedGroups = const [];
  int _profitExcluded = 0;
  String _signature = '';

  ReceiptsFilterChoices _choices =
      ReceiptsFilterChoices.empty;

  @override
  void initState() {
    super.initState();
    _filters =
        widget.initialFilters?.copy() ??
        ReceiptsReportFilters();
    _searchCtrl.text = _filters.search;
    _revMinCtrl.text = _numText(_filters.revenueMin);
    _revMaxCtrl.text = _numText(_filters.revenueMax);
    _profitMinCtrl.text = _numText(_filters.profitMin);
    _profitMaxCtrl.text = _numText(_filters.profitMax);
    _period =
        widget.initialPeriod ??
        ReceiptsReportPeriod.today();
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
    _baseRows = ReceiptsReportRowBuilder.buildAll(
      receipts: scoped,
      legacySales: provider.mainSales,
    );
    _choices = ReceiptsFilterChoices.fromRows(_baseRows);
    _signature = _sourceSignature();
  }

  void _recompute() {
    final profitVisible = _canSeeCost;
    if (!profitVisible &&
        (_sortField == ReceiptsSortField.profit ||
            _sortField == ReceiptsSortField.margin)) {
      _sortField = ReceiptsSortField.createdAt;
      _ascending = false;
    }
    if (!profitVisible &&
        (_groupSortField ==
                ReceiptsTableGroupSortField.profit ||
            _groupSortField ==
                ReceiptsTableGroupSortField.margin)) {
      _groupSortField = ReceiptsTableGroupSortField.revenue;
      _groupAscending = false;
    }
    final sorted = ReceiptsReportQuery.filterAndSort(
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
      final groups = ReceiptsGrouping.sort(
        ReceiptsGrouping.build(sorted, _groupBy),
        field: _groupSortField,
        ascending: _groupAscending,
      );
      _sortedGroups = groups;
      final page = ReceiptsGrouping.paginate(groups, _page);
      _page = page.page;
      _groupResult = page;
    } else {
      final page = ReceiptsReportQuery.paginate(
        sorted,
        _page,
      );
      _page = page.page;
      _result = page;
    }
    _profitExcluded =
        ReceiptsReportQuery.profitExcludedCount(
          rows: _baseRows,
          period: _period,
          filters: _filters,
          departmentsEnabled: _departmentsEnabled,
          subStaffEnabled: _subStaffEnabled,
          profitVisible: profitVisible,
        );
  }

  /// What the Export button exports: the receipts (or the groups when
  /// grouped) with the period, filters, sort and notes on screen.
  ReportExportSpec _exportSpec() {
    return receiptsReportExportSpec(
      rows: _sortedRows,
      groups: _sortedGroups,
      groupBy: _groupBy,
      filters: _filters,
      choices: _choices,
      period: _period,
      sortField: _sortField,
      ascending: _ascending,
      groupSortField: _groupSortField,
      groupAscending: _groupAscending,
      profitExcluded: _profitExcluded,
      currency: currencySymbol(context: context),
      canSeeCost: _canSeeCost,
      departmentsEnabled: _departmentsEnabled,
      subStaffEnabled: _subStaffEnabled,
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

  void _setSort(ReceiptsSortField f) {
    _apply(() {
      if (_sortField == f) {
        _ascending = !_ascending;
      } else {
        _sortField = f;
        // Names A-Z first; dates and amounts largest first.
        _ascending =
            f == ReceiptsSortField.customer ||
            f == ReceiptsSortField.staff;
      }
    });
  }

  void _setGroupSort(ReceiptsTableGroupSortField f) {
    _apply(() {
      if (_groupSortField == f) {
        _groupAscending = !_groupAscending;
      } else {
        _groupSortField = f;
        // Names A-Z first; counts and amounts largest first.
        _groupAscending =
            f == ReceiptsTableGroupSortField.name;
      }
    });
  }

  void _resetAll() {
    _searchCtrl.clear();
    _revMinCtrl.clear();
    _revMaxCtrl.clear();
    _profitMinCtrl.clear();
    _profitMaxCtrl.clear();
    _apply(_filters.clearAll);
  }

  void _openReceipt(ReceiptsReportRow row) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ReceiptPage(
              response: CheckoutResponse(
                receipt: row.receipt,
              ),
              isMain: false,
            ),
      ),
    ).then((_) {
      // Picks up an edit or delete made on the receipt page.
      if (mounted) {
        setState(() {
          _rebuildBase();
          try {
            _recompute();
          } catch (_) {}
        });
      }
    });
  }

  void _setPeriod(ReceiptsReportPeriod p) {
    _apply(() => _period = p);
    if (!p.isAllTime) {
      _load(refreshFromStore: false);
    }
  }

  /// Clears a range's fields once its filter was removed (chip).
  void _applyAndSyncFields(VoidCallback change) {
    _apply(change);
    if (_filters.revenueMin == null &&
        _filters.revenueMax == null) {
      _revMinCtrl.clear();
      _revMaxCtrl.clear();
    }
    if (_filters.profitMin == null &&
        _filters.profitMax == null) {
      _profitMinCtrl.clear();
      _profitMaxCtrl.clear();
    }
    if (_filters.search.isEmpty) _searchCtrl.clear();
  }

  // ---------------------------------------------------------------
  // formatting
  // ---------------------------------------------------------------

  String _money(num v) =>
      formatMoneyBig(amount: v, context: context);

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
    // Listen, so sales, edits and sync update the table.
    returnReceiptProvider(context);
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
        title: 'Receipts Report',
        widget: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  mouseCursor: SystemMouseCursors.click,
                  borderRadius: BorderRadius.circular(10),
                  onTap:
                      _loading
                          ? null
                          : () =>
                              _load(refreshFromStore: true),
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
            ),
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
                itemLabel: 'receipts',
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
    final groups = _groupResult;
    final count =
        _grouped ? groups?.totalCount : res?.totalCount;
    if (count == null || count == 0) {
      final hasFilters = _filters.hasAnything;
      return Padding(
        padding: const EdgeInsets.only(top: 60),
        child: EmptyWidgetDisplayOnly(
          title:
              hasFilters
                  ? 'No Matching Receipts'
                  : 'Empty List',
          subText:
              hasFilters
                  ? 'No receipt matches your search and filters'
                  : 'No receipt was recorded in this period',
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
                        (v) => _apply(
                          () => _filters.search = v,
                        ),
                    decoration: InputDecoration(
                      hintText:
                          _departmentsEnabled
                              ? 'Search customer, staff, department or ID'
                              : 'Search customer, staff or ID',
                      hintStyle: TextStyle(
                        fontSize:
                            theme.mobileTexts.b3.fontSize,
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
                                    () =>
                                        _filters.search =
                                            '',
                                  );
                                },
                              ),
                      contentPadding: EdgeInsets.zero,
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          5,
                        ),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                if (screenWidth(context) <
                    mobileScreen) ...[
                  const SizedBox(width: 5),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _toolbarIsOpen = !_toolbarIsOpen;
                      });
                    },
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
                                  theme
                                      .mobileTexts
                                      .b4
                                      .fontSize,
                            ),
                            _toolbarIsOpen
                                ? 'Hide'
                                : 'View',
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
          // A view option, not a filter: Reset All keeps it.
          ReportGroupByButton(
            theme: theme,
            value: _groupBy,
            onChanged: (g) => _apply(() => _groupBy = g),
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
              color: accent,
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
          ...receiptsKeyFilterFields(
            theme: theme,
            filters: _filters,
            choices: _choices,
            departmentsEnabled: _departmentsEnabled,
            subStaffEnabled: _subStaffEnabled,
            onApply: _apply,
          ),
          ReportRangeFields(
            label: 'Total revenue range',
            minController: _revMinCtrl,
            maxController: _revMaxCtrl,
            errorText: _filters.revenueRangeError,
            onChange:
                (a, b) => _apply(() {
                  _filters.revenueMin = a;
                  _filters.revenueMax = b;
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
    return ReceiptsReportFilterChips(
      theme: theme,
      filters: _filters,
      choices: _choices,
      departmentsEnabled: _departmentsEnabled,
      subStaffEnabled: _subStaffEnabled,
      profitVisible: _canSeeCost,
      money: _money,
      onApply: _applyAndSyncFields,
    );
  }

  Widget _notes(ThemeProvider theme) {
    // Shared with the export, so both always match.
    final notes = receiptsReportNotes(
      period: _period,
      profitExcluded: _profitExcluded,
    );
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

  static String _documentTip(ReceiptsReportRow r) =>
      r.type == ReceiptType.invoicePayment
          ? 'Belongs to the whole invoice, not this payment'
          : 'Belongs to the whole order, not this delivery';

  static const String _noItemsTip =
      'No item data on this receipt';

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

  List<_Col> _columns(ThemeProvider theme) {
    const dash = '—';
    final cost = _canSeeCost;

    Widget documentValue(ReceiptsReportRow r, double? v) {
      if (v != null) return _txt(theme, _money(v));
      return _txt(
        theme,
        dash,
        color: Colors.grey,
        tooltip:
            r.hidesDocumentTotals ? _documentTip(r) : null,
      );
    }

    return [
      _Col(
        label: 'ID',
        width: 150,
        align: TextAlign.start,
        cell:
            (r) => _txt(
              theme,
              r.displayId,
              bold: true,
              align: TextAlign.start,
            ),
      ),
      _Col(
        label: 'Staff',
        width: 160,
        sort: ReceiptsSortField.staff,
        align: TextAlign.start,
        cell:
            (r) => _txt(
              theme,
              r.staffLabel,
              align: TextAlign.start,
              color:
                  r.staffName == null ? Colors.grey : null,
            ),
      ),
      if (_subStaffEnabled)
        _Col(
          label: 'Sub-Staff',
          width: 150,
          align: TextAlign.start,
          cell:
              (r) => _txt(
                theme,
                r.subStaffLabel,
                align: TextAlign.start,
                color:
                    r.subStaffName == null
                        ? Colors.grey
                        : null,
              ),
        ),
      _Col(
        label: 'Customer',
        width: 170,
        sort: ReceiptsSortField.customer,
        align: TextAlign.start,
        cell:
            (r) => _txt(
              theme,
              r.customerLabel,
              align: TextAlign.start,
              color:
                  r.customerName == null
                      ? Colors.grey
                      : null,
            ),
      ),
      _Col(
        label: 'Channel',
        width: 140,
        cell: (r) => _txt(theme, r.channelLabel),
      ),
      _Col(
        label: 'Date',
        width: 120,
        sort: ReceiptsSortField.createdAt,
        cell:
            (r) => _txt(theme, formatDateTime(r.createdAt)),
      ),
      _Col(
        label: 'Time',
        width: 100,
        sort: ReceiptsSortField.createdAt,
        cell: (r) => _txt(theme, formatTime(r.createdAt)),
      ),
      _Col(
        label: 'Discount',
        width: 130,
        cell: (r) {
          final v = r.discount;
          if (v == null) return documentValue(r, null);
          final pct = r.receipt.generalDiscount;
          final showPct =
              r.receipt.fixedDiscount == null &&
              pct != null;
          return _txt(
            theme,
            showPct
                ? '${_money(v)} (${_percent(pct)})'
                : _money(v),
          );
        },
      ),
      _Col(
        label: 'VAT',
        width: 120,
        cell: (r) {
          final v = r.vat;
          if (v == null) return documentValue(r, null);
          final rate = r.receipt.vat;
          return _txt(
            theme,
            _money(v),
            tooltip:
                rate == null
                    ? null
                    : '${_percent(rate)} VAT',
          );
        },
      ),
      _Col(
        label: 'Items',
        width: 90,
        sort: ReceiptsSortField.items,
        cell: (r) {
          final v = r.items;
          if (v != null) {
            return _txt(theme, formatLargeNumberDouble(v));
          }
          return _txt(
            theme,
            dash,
            color: Colors.grey,
            tooltip:
                r.type == ReceiptType.invoicePayment
                    ? 'Part payments repeat the invoice quantities'
                    : _noItemsTip,
          );
        },
      ),
      if (_departmentsEnabled)
        _Col(
          label: 'Department',
          width: 160,
          align: TextAlign.start,
          cell:
              (r) => _txt(
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
                  (r.comment?.length ?? 0) > 40
                      ? r.comment
                      : null,
            ),
      ),
      _Col(
        label: 'Type',
        width: 150,
        cell:
            (r) => _badge(r.type.label, _typeColor(r.type)),
      ),
      _Col(
        label: 'Balance',
        width: 130,
        sort: ReceiptsSortField.balance,
        cell:
            (r) =>
                r.balance == null
                    ? _txt(theme, dash, color: Colors.grey)
                    : _txt(theme, _money(r.balance!)),
      ),
      if (cost)
        _Col(
          label: 'Profit/Loss',
          width: 150,
          sort: ReceiptsSortField.profit,
          cell: (r) {
            final p = r.profit;
            if (p == null) {
              return _txt(
                theme,
                'N/A',
                color: Colors.grey,
                tooltip: _noItemsTip,
              );
            }
            final value = _txt(
              theme,
              _money(p),
              bold: true,
              color: _signColor(theme, p),
            );
            if (!r.costMissing) return value;
            return Tooltip(
              message:
                  'Cost missing: some items have no cost price, '
                  'so their cost is counted as 0',
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
        ),
      if (cost)
        _Col(
          label: 'Margin (%)',
          width: 120,
          sort: ReceiptsSortField.margin,
          cell: (r) {
            final m = r.margin;
            if (m == null) {
              return _txt(theme, 'N/A', color: Colors.grey);
            }
            return _txt(
              theme,
              _percent(m),
              color: _signColor(theme, m),
            );
          },
        ),
      _Col(
        label: 'Subtotal',
        width: 140,
        cell: (r) => documentValue(r, r.subtotal),
      ),
      _Col(
        label: 'Total Revenue',
        width: 150,
        sort: ReceiptsSortField.revenue,
        cell:
            (r) =>
                _txt(theme, _money(r.revenue), bold: true),
      ),
    ];
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
            c.label,
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
    final padded = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Align(
        alignment: _alignment(c.align),
        child: content,
      ),
    );
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
    ReceiptsReportRow r,
    int i,
  ) {
    return Material(
      color: i.isEven ? Colors.white : Colors.grey.shade50,
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
                      child: c.cell(r),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Totals of the whole filtered set, as the Invoice Report.
  Widget _totalsRow(
    ThemeProvider theme,
    List<_Col> cols,
    ReceiptsReportPage res,
  ) {
    Widget cell(_Col c) {
      switch (c.label) {
        case 'ID':
          return _txt(
            theme,
            'TOTAL',
            bold: true,
            align: TextAlign.start,
          );
        case 'Discount':
          return _txt(
            theme,
            _money(res.totalDiscount),
            bold: true,
          );
        case 'VAT':
          return _txt(
            theme,
            _money(res.totalVat),
            bold: true,
          );
        case 'Items':
          return _txt(
            theme,
            formatLargeNumberDouble(res.totalItems),
            bold: true,
          );
        case 'Balance':
          return _txt(
            theme,
            _money(res.totalBalance),
            bold: true,
          );
        case 'Profit/Loss':
          return _txt(
            theme,
            _money(res.totalProfit),
            bold: true,
            color: _signColor(theme, res.totalProfit),
          );
        case 'Margin (%)':
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
        case 'Subtotal':
          return _txt(
            theme,
            _money(res.totalSubtotal),
            bold: true,
          );
        case 'Total Revenue':
          return _txt(
            theme,
            _money(res.totalRevenue),
            bold: true,
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

  Widget _table(
    ThemeProvider theme,
    ReceiptsReportPage res,
  ) {
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
                        const Divider(
                          height: 1,
                          thickness: 1,
                        ),
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

  // ---------------------------------------------------------------
  // grouped by staff / customer / channel
  // ---------------------------------------------------------------

  List<_GCol> _groupColumns(ThemeProvider theme) {
    const dash = '—';
    final cost = _canSeeCost;

    Widget bold(String text, {Color? color}) =>
        _txt(theme, text, bold: true, color: color);

    Widget marginText(double? m, {bool isBold = false}) {
      if (m == null) {
        return _txt(theme, 'N/A', color: Colors.grey);
      }
      return _txt(
        theme,
        _percent(m),
        bold: isBold,
        color: _signColor(theme, m),
      );
    }

    return [
      _GCol(
        label: _groupBy.label,
        width: 220,
        sort: ReceiptsTableGroupSortField.name,
        align: TextAlign.start,
        cell:
            (g) => _txt(
              theme,
              g.label,
              bold: true,
              align: TextAlign.start,
              color:
                  g.isNone || g.name == null
                      ? Colors.grey
                      : null,
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
        label: 'Receipts',
        width: 110,
        sort: ReceiptsTableGroupSortField.count,
        cell: (g) => _txt(theme, '${g.count}'),
        total: (res) => bold('${res.totalReceipts}'),
      ),
      _GCol(
        label: 'Items',
        width: 110,
        sort: ReceiptsTableGroupSortField.items,
        cell:
            (g) =>
                g.items == null
                    ? _txt(
                      theme,
                      dash,
                      color: Colors.grey,
                      tooltip: _noItemsTip,
                    )
                    : _txt(
                      theme,
                      formatLargeNumberDouble(g.items!),
                    ),
        total:
            (res) =>
                res.totalItems == null
                    ? const SizedBox.shrink()
                    : bold(
                      formatLargeNumberDouble(
                        res.totalItems!,
                      ),
                    ),
      ),
      _GCol(
        label: 'Balance',
        width: 140,
        sort: ReceiptsTableGroupSortField.balance,
        cell: (g) => _txt(theme, _money(g.balance)),
        total: (res) => bold(_money(res.totalBalance)),
      ),
      _GCol(
        label: 'Total Revenue',
        width: 160,
        sort: ReceiptsTableGroupSortField.revenue,
        cell: (g) => bold(_money(g.revenue)),
        total: (res) => bold(_money(res.totalRevenue)),
      ),
      if (cost)
        _GCol(
          label: 'Profit/Loss',
          width: 160,
          sort: ReceiptsTableGroupSortField.profit,
          cell: (g) {
            if (g.profitUnknown) {
              return _txt(
                theme,
                'N/A',
                color: Colors.grey,
                tooltip: _noItemsTip,
              );
            }
            final value = bold(
              _money(g.profit),
              color: _signColor(theme, g.profit),
            );
            if (g.costMissingCount == 0) return value;
            return Tooltip(
              message:
                  '${g.costMissingCount} of ${g.count} receipts '
                  'have items with no cost price, so their cost '
                  'is counted as 0',
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
          total:
              (res) =>
                  res.totalProfitCount == 0
                      ? _txt(
                        theme,
                        'N/A',
                        color: Colors.grey,
                      )
                      : bold(
                        _money(res.totalProfit),
                        color: _signColor(
                          theme,
                          res.totalProfit,
                        ),
                      ),
        ),
      if (cost)
        _GCol(
          label: 'Margin (%)',
          width: 120,
          sort: ReceiptsTableGroupSortField.margin,
          cell: (g) => marginText(g.margin),
          total:
              (res) =>
                  marginText(res.totalMargin, isBold: true),
        ),
    ];
  }

  Widget _groupHeaderCell(ThemeProvider theme, _GCol c) {
    final isSorted =
        c.sort != null && c.sort == _groupSortField;
    final accent = theme.lightModeColor.prColor300;
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
              color: isSorted ? accent : Colors.black87,
            ),
          ),
        ),
        if (c.sort != null)
          Icon(
            isSorted
                ? (_groupAscending
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
      child: Align(
        alignment: _alignment(c.align),
        child: content,
      ),
    );
    return SizedBox(
      width: c.width,
      child:
          c.sort == null
              ? padded
              : InkWell(
                mouseCursor: SystemMouseCursors.click,
                onTap: () => _setGroupSort(c.sort!),
                child: padded,
              ),
    );
  }

  /// No row tap: a group has no single receipt to open.
  Widget _groupRow(
    List<_GCol> cols,
    ReceiptsGroupRow g,
    int i,
  ) {
    return Container(
      decoration: BoxDecoration(
        color:
            i.isEven ? Colors.white : Colors.grey.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100),
        ),
      ),
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
                  child: c.cell(g),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Totals of every group, as the receipt table's totals row.
  Widget _groupTotalsRow(
    ThemeProvider theme,
    List<_GCol> cols,
    ReceiptsGroupPage res,
  ) {
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
                  child:
                      c.total?.call(res) ??
                      const SizedBox.shrink(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _groupTable(
    ThemeProvider theme,
    ReceiptsGroupPage res,
  ) {
    final cols = _groupColumns(theme);
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
                                _groupHeaderCell(theme, c),
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
                                  (context, i) => _groupRow(
                                    cols,
                                    res.rows[i],
                                    i,
                                  ),
                            ),
                          ),
                        ),
                        const Divider(
                          height: 1,
                          thickness: 1,
                        ),
                        _groupTotalsRow(theme, cols, res),
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
