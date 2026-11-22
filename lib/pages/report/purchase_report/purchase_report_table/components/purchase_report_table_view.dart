import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_item_purchase_record/temp_item_purchase_record.dart';
import 'package:stockall/classes/temp_purchase/temp_purchase.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/local_database/purchases/unsync_funcs/deleted/deleted_purchases_func.dart';
import 'package:stockall/local_database/suppliers_func/suppliers_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/purchases/purchase_page/purchase_page.dart';
import 'package:stockall/pages/report/components/export/report_export_button.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/report_pager.dart';
import 'package:stockall/pages/report/components/report_pill.dart';
import 'package:stockall/pages/report/components/report_range_fields.dart';
import 'package:stockall/pages/report/purchase_report/purchase_report_table/class/purchase_report_export_spec.dart';
import 'package:stockall/pages/report/purchase_report/purchase_report_table/class/purchase_report_table_logic.dart';
import 'package:stockall/pages/report/purchase_report/purchase_report_table/components/purchase_report_filter_widgets.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/components/receipts_report_filter_widgets.dart';
import 'package:stockall/providers/theme_provider.dart';

/// Everything the view reads from the app. [PurchaseReportEnv.live]
/// uses the providers; tests pass their own, since the providers
/// need Supabase.
class PurchaseReportEnv {
  final bool Function() departmentsEnabled;
  final bool Function() canPickDate;

  /// Purchases the user may see (department and own-transactions
  /// scope applied).
  final List<TempPurchase> Function() purchases;

  /// item_purchase_records lines for purchases without `items`.
  final List<TempItemPurchaseRecord> Function() legacyLines;

  /// Current supplier names by uuid, for purchases saved without
  /// a name.
  final Map<String, String> Function() supplierNames;

  /// Purchases queued for deletion, left out of the report.
  final Set<String> Function() pendingDeletedUuids;

  final Future<void> Function(
    BuildContext context, {
    required bool refreshFromStore,
  })
  load;

  final Future<void> Function(
    BuildContext context, {
    required bool refreshFromStore,
    ReceiptsReportPeriod? period,
  })?
  loadForPeriod;

  Future<void> loadWithPeriod(
    BuildContext context, {
    required bool refreshFromStore,
    required ReceiptsReportPeriod period,
  }) =>
      loadForPeriod != null
          ? loadForPeriod!(
              context,
              refreshFromStore: refreshFromStore,
              period: period,
            )
          : load(context, refreshFromStore: refreshFromStore);

  /// Changes whenever the source data or the user's scope does.
  final String Function() signature;

  /// Subscribes the view to the providers it reads.
  final void Function(BuildContext context) listen;
  final String Function(BuildContext context, num amount) money;
  final Future<void> Function(
    BuildContext context,
    TempPurchase purchase,
  )
  openPurchase;

  /// Used by the purchase analysis to open the table. Null in the
  /// app: the analysis pushes `PurchaseReportTablePage`.
  final Future<void> Function(
    BuildContext context,
    PurchaseReportFilters filters,
    ReceiptsReportPeriod period,
  )?
  openTable;

  const PurchaseReportEnv({
    required this.departmentsEnabled,
    required this.canPickDate,
    required this.purchases,
    required this.legacyLines,
    required this.supplierNames,
    required this.pendingDeletedUuids,
    required this.load,
    this.loadForPeriod,
    required this.signature,
    required this.listen,
    required this.money,
    required this.openPurchase,
    this.openTable,
  });

  factory PurchaseReportEnv.live() {
    bool departmentsEnabled() =>
        shopSingle()?.manageDepartments == true;
    Set<String> pendingDeleted() {
      try {
        return DeletedPurchasesFunc()
            .getPurchaseIds()
            .map((d) => d.purchaseUuid)
            .toSet();
      } catch (_) {
        return const {};
      }
    }

    Future<void> loadPeriod(
      BuildContext context, {
      required bool refreshFromStore,
      ReceiptsReportPeriod? period,
    }) async {
      final sid = shopSingle()?.shopId;
      if (sid == null) return;
      final provider = returnPurchaseProvider();
      final fetchAll = period?.isAllTime ?? false;
      final startDate = period?.start;
      final endDate = period?.end ?? period?.start;
      if (refreshFromStore) {
        await provider.loadPurchases(
          sid,
          startDate: startDate,
          endDate: endDate,
          fetchAll: fetchAll,
          forceRefresh: true,
        );
        await returnSuppliersProvider().fetchSuppliers(sid);
        return;
      }
      // Local (offline) reads, only when nothing is loaded yet.
      if (provider.purchases.isEmpty) {
        await provider.loadPurchasesOffline();
      }
      if (period != null && !period.isAllTime) {
        await provider.loadPurchases(
          sid,
          startDate: startDate,
          endDate: endDate,
          forceRefresh: false,
        );
      }
    }

    return PurchaseReportEnv(
      departmentsEnabled: departmentsEnabled,
      canPickDate:
          () => authorization(
            authorized: Authorizations().viewDate,
          ),
      purchases:
          () => PurchaseReportAccess.scope(
            purchases: returnPurchaseProvider().purchases,
            departmentsEnabled: departmentsEnabled(),
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
          ),
      // Not loaded by the app any more; see the backfill script.
      legacyLines: () => const [],
      supplierNames: () {
        var suppliers = returnSuppliersProvider().suppliers;
        if (suppliers.isEmpty) {
          try {
            suppliers = SuppliersFunc().getSuppliers();
          } catch (_) {}
        }
        return {
          for (final s in suppliers)
            if (s.uuid != null) s.uuid!: s.name,
        };
      },
      pendingDeletedUuids: pendingDeleted,
      load: (context, {required refreshFromStore}) async {
        await loadPeriod(
          context,
          refreshFromStore: refreshFromStore,
        );
      },
      loadForPeriod: (
        context, {
        required refreshFromStore,
        period,
      }) async {
        await loadPeriod(
          context,
          refreshFromStore: refreshFromStore,
          period: period,
        );
      },
      signature: () {
        final purchases = returnPurchaseProvider().purchases;
        int latest = 0;
        double total = 0;
        double paid = 0;
        int withItems = 0;
        for (final p in purchases) {
          final t =
              (p.updatedAt ?? p.createdAt)
                  .millisecondsSinceEpoch;
          if (t > latest) latest = t;
          total += p.total ?? 0;
          paid += PurchaseReportClassifier.paidAmount(
            p.purchasePayments,
          );
          if (p.items?.isNotEmpty == true) withItems++;
        }
        return '${purchases.length}|$latest|$total|$paid|'
            '$withItems|'
            '${returnSuppliersProvider().suppliers.length}|'
            '${pendingDeleted().length}|'
            '${returnDepartmentProvider().currentDepartment()?.uuid}|'
            '${currentUser().userId}|${departmentsEnabled()}';
      },
      listen: (context) {
        returnPurchaseProvider(context: context);
        returnSuppliersProvider(context: context);
        shop(context);
      },
      money:
          (context, amount) =>
              formatMoneyBig(amount: amount, context: context),
      openPurchase: (context, purchase) {
        final uuid = purchase.uuid;
        if (uuid == null) return Future.value();
        return Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PurchasePage(purchaseUuid: uuid),
          ),
        );
      },
    );
  }
}

class _Col {
  final String label;
  final double width;
  final PurchasesSortField? sort;
  final TextAlign align;
  final Widget Function(PurchaseReportRow row) cell;

  /// Cell of the totals row; empty when null.
  final Widget Function(PurchaseReportPage res)? total;

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
  final PurchaseGroupSortField? sort;
  final TextAlign align;
  final Widget Function(PurchaseGroupRow row) cell;

  /// Cell of the totals row; empty when null.
  final Widget Function(PurchaseGroupPage res)? total;

  const _GCol({
    required this.label,
    required this.width,
    required this.cell,
    this.sort,
    this.align = TextAlign.center,
    this.total,
  });
}

/// Shared body of the Purchase Report table page (desktop +
/// mobile).
///
/// [initialFilters] and [initialPeriod] let another page (the
/// purchase analysis, a supplier) open the table on a given set.
class PurchaseReportTableView extends StatefulWidget {
  final bool isDesktop;
  final PurchaseReportFilters? initialFilters;
  final ReceiptsReportPeriod? initialPeriod;

  /// Null in the app: [PurchaseReportEnv.live] is used.
  final PurchaseReportEnv? env;

  const PurchaseReportTableView({
    super.key,
    required this.isDesktop,
    this.initialFilters,
    this.initialPeriod,
    this.env,
  });

  @override
  State<PurchaseReportTableView> createState() =>
      _PurchaseReportTableViewState();
}

class _PurchaseReportTableViewState
    extends State<PurchaseReportTableView> {
  late final PurchaseReportEnv _env;
  late final PurchaseReportTableState _state;
  final _searchCtrl = TextEditingController();
  final _totalMinCtrl = TextEditingController();
  final _totalMaxCtrl = TextEditingController();
  final _balanceMinCtrl = TextEditingController();
  final _balanceMaxCtrl = TextEditingController();
  final _hScroll = ScrollController();
  final _vScroll = ScrollController();

  bool _showFilters = false;
  bool _toolbarIsOpen = false;

  late ReceiptsReportPeriod _period;

  bool _loading = true;
  String? _error;

  List<PurchaseReportRow> _baseRows = [];
  PurchaseReportPage? _result;
  PurchaseGroupPage? _groupResult;
  String _signature = '';

  // Every filtered, sorted row and group, for the export.
  List<PurchaseReportRow> _sortedRows = [];
  List<PurchaseGroupRow> _sortedGroups = [];

  PurchaseFilterChoices _choices = PurchaseFilterChoices.empty;

  PurchaseReportFilters get _filters => _state.filters;
  bool get _grouped => _state.grouped;

  @override
  void initState() {
    super.initState();
    _env = widget.env ?? PurchaseReportEnv.live();
    _state = PurchaseReportTableState(
      filters: widget.initialFilters?.copy(),
    );
    _searchCtrl.text = _filters.search;
    _totalMinCtrl.text = _numText(_filters.totalMin);
    _totalMaxCtrl.text = _numText(_filters.totalMax);
    _balanceMinCtrl.text = _numText(_filters.balanceMin);
    _balanceMaxCtrl.text = _numText(_filters.balanceMax);
    _period =
        widget.initialPeriod ?? ReceiptsReportPeriod.today();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load(refreshFromStore: true);
    });
  }

  @override
  void dispose() {
    for (final c in [
      _searchCtrl,
      _totalMinCtrl,
      _totalMaxCtrl,
      _balanceMinCtrl,
      _balanceMaxCtrl,
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
    _baseRows = PurchaseReportRowBuilder.buildAll(
      purchases: _env.purchases(),
      legacyLines: _env.legacyLines(),
      supplierNames: _env.supplierNames(),
      pendingDeletedUuids: _env.pendingDeletedUuids(),
    );
    _choices = PurchaseFilterChoices.fromRows(_baseRows);
    _signature = _env.signature();
  }

  void _recompute() {
    final sorted = PurchaseReportQuery.filterAndSort(
      rows: _baseRows,
      period: _period,
      filters: _filters,
      sortField: _state.sortField,
      ascending: _state.ascending,
      departmentsEnabled: _departmentsEnabled,
    );
    _sortedRows = sorted;
    if (_grouped) {
      final groups = PurchaseGrouping.sort(
        PurchaseGrouping.build(sorted, _state.groupBy),
        field: _state.groupSortField,
        ascending: _state.groupAscending,
      );
      _sortedGroups = groups;
      final page = PurchaseGrouping.paginate(
        groups,
        _state.page,
      );
      _state.page = page.page;
      _groupResult = page;
    } else {
      final page = PurchaseReportQuery.paginate(
        sorted,
        _state.page,
      );
      _state.page = page.page;
      _result = page;
    }
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
    _apply(() => _state.page = p, resetPage: false);
    if (_vScroll.hasClients) {
      _vScroll.jumpTo(0);
    }
  }

  void _setSort(PurchasesSortField f) {
    _apply(() {
      if (_state.sortField == f) {
        _state.ascending = !_state.ascending;
      } else {
        _state.sortField = f;
        // Names A-Z first; dates and amounts largest first.
        _state.ascending =
            f == PurchasesSortField.supplier ||
            f == PurchasesSortField.staff;
      }
    });
  }

  void _setGroupSort(PurchaseGroupSortField f) {
    _apply(() {
      if (_state.groupSortField == f) {
        _state.groupAscending = !_state.groupAscending;
      } else {
        _state.groupSortField = f;
        // Names A-Z first; counts and amounts largest first.
        _state.groupAscending =
            f == PurchaseGroupSortField.name;
      }
    });
  }

  /// Clears the filters only: the period and Group by stay.
  void _resetAll() {
    for (final c in [
      _searchCtrl,
      _totalMinCtrl,
      _totalMaxCtrl,
      _balanceMinCtrl,
      _balanceMaxCtrl,
    ]) {
      c.clear();
    }
    _apply(_state.resetAll);
  }

  Future<void> _openPurchase(PurchaseReportRow row) async {
    await _env.openPurchase(context, row.purchase);
    // Picks up a payment, edit or delete made on the purchase page.
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

  void _setPeriod(ReceiptsReportPeriod p) {
    _apply(() => _period = p);
    if (!p.isAllTime) {
      _load(refreshFromStore: false);
    }
  }

  /// Clears a range's fields once its filter was removed (chip).
  void _applyAndSyncFields(VoidCallback change) {
    _apply(change);
    if (_filters.totalMin == null && _filters.totalMax == null) {
      _totalMinCtrl.clear();
      _totalMaxCtrl.clear();
    }
    if (_filters.balanceMin == null &&
        _filters.balanceMax == null) {
      _balanceMinCtrl.clear();
      _balanceMaxCtrl.clear();
    }
    if (_filters.search.isEmpty) _searchCtrl.clear();
  }

  // ---------------------------------------------------------------
  // formatting
  // ---------------------------------------------------------------

  String _money(num v) => _env.money(context, v);

  ReportExportSpec _exportSpec() {
    return purchaseReportExportSpec(
      rows: _sortedRows,
      groups: _sortedGroups,
      state: _state,
      choices: _choices,
      period: _period,
      currency: currencySymbol(context: context),
      departmentsEnabled: _departmentsEnabled,
    );
  }

  static String _numText(double? v) {
    if (v == null) return '';
    return v == v.roundToDouble()
        ? v.toStringAsFixed(0)
        : v.toString();
  }

  // ---------------------------------------------------------------
  // build
  // ---------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = returnTheme(context);
    // Listen, so purchases, payments and sync update the table.
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
        title: 'Purchase Report',
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
            PurchaseReportFilterChips(
              theme: theme,
              filters: _filters,
              choices: _choices,
              departmentsEnabled: _departmentsEnabled,
              money: _money,
              onApply: _applyAndSyncFields,
            ),
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
                itemLabel: _state.groupBy.pagerLabel,
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
                itemLabel: 'purchases',
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
              hasFilters
                  ? 'No Matching Purchases'
                  : 'Empty List',
          subText:
              hasFilters
                  ? 'No purchase matches your search and filters'
                  : 'No purchase was recorded in this period',
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
                              ? 'Search supplier, staff, department, tracking or ID'
                              : 'Search supplier, staff, tracking or ID',
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
          PurchaseGroupByButton(
            theme: theme,
            value: _state.groupBy,
            onChanged: (g) => _apply(() => _state.groupBy = g),
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
          ...purchaseKeyFilterFields(
            theme: theme,
            filters: _filters,
            choices: _choices,
            departmentsEnabled: _departmentsEnabled,
            onApply: _apply,
          ),
          ReportRangeFields(
            label: 'Total range',
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
        ],
      ),
    );
  }

  Widget _notes() {
    final notes = purchaseReportNotes(period: _period);
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

  static const String _noLinesTip =
      'No line data for this purchase';

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

  Color _statusColor(ThemeProvider theme, PurchaseStatus s) {
    switch (s) {
      case PurchaseStatus.paid:
        return Colors.green.shade700;
      case PurchaseStatus.partlyPaid:
        return Colors.orange.shade800;
      case PurchaseStatus.unpaid:
        return theme.lightModeColor.errorColor200;
    }
  }

  /// Text with an info icon and its tooltip after it.
  Widget _withIcon(
    Widget child, {
    required IconData icon,
    required Color color,
    required String tooltip,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        Flexible(child: child),
        Tooltip(
          message: tooltip,
          child: Icon(icon, size: 15, color: color),
        ),
      ],
    );
  }

  Widget _unknown(ThemeProvider theme) =>
      _txt(theme, '—', color: Colors.grey, tooltip: _noLinesTip);

  List<_Col> _columns(ThemeProvider theme) {
    Widget bold(String text) => _txt(theme, text, bold: true);

    return [
      _Col(
        label: 'ID',
        width: 170,
        align: TextAlign.start,
        cell:
            (r) => _txt(
              theme,
              r.displayId,
              bold: true,
              align: TextAlign.start,
            ),
        total:
            (_) => _txt(
              theme,
              'TOTAL',
              bold: true,
              align: TextAlign.start,
            ),
      ),
      _Col(
        label: 'Supplier',
        width: 180,
        sort: PurchasesSortField.supplier,
        align: TextAlign.start,
        cell:
            (r) => _txt(
              theme,
              r.supplierLabel,
              align: TextAlign.start,
              color: r.supplierName == null ? Colors.grey : null,
            ),
      ),
      _Col(
        label: 'Tracking No.',
        width: 150,
        align: TextAlign.start,
        cell:
            (r) => _txt(
              theme,
              r.trackingNumberLabel,
              align: TextAlign.start,
              color: r.trackingNumber == null ? Colors.grey : null,
            ),
      ),
      _Col(
        label: 'Staff',
        width: 160,
        sort: PurchasesSortField.staff,
        align: TextAlign.start,
        cell:
            (r) => _txt(
              theme,
              r.staffLabel,
              align: TextAlign.start,
              color: r.staffName == null ? Colors.grey : null,
            ),
      ),
      _Col(
        label: 'Date',
        width: 120,
        sort: PurchasesSortField.createdAt,
        cell: (r) => _txt(theme, formatDateTime(r.createdAt)),
      ),
      _Col(
        label: 'Time',
        width: 100,
        sort: PurchasesSortField.createdAt,
        cell: (r) => _txt(theme, formatTime(r.createdAt)),
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
                color: r.departmentKey == null ? Colors.grey : null,
              ),
        ),
      _Col(
        label: 'Status',
        width: 160,
        cell: (r) {
          final badge = _badge(
            r.status.label,
            _statusColor(theme, r.status),
          );
          if (!r.overpaid) return badge;
          return _withIcon(
            badge,
            icon: Icons.warning_amber_rounded,
            color: Colors.orange.shade800,
            tooltip: 'Overpaid by ${_money(r.overpaidBy)}',
          );
        },
      ),
      _Col(
        label: 'Channel',
        width: 120,
        cell:
            (r) => _txt(
              theme,
              r.channelLabel,
              color: r.channel == null ? Colors.grey : null,
            ),
      ),
      _Col(
        label: 'Lines',
        width: 80,
        cell:
            (r) =>
                r.lineCount == null
                    ? _unknown(theme)
                    : _txt(theme, '${r.lineCount}'),
      ),
      _Col(
        label: 'Items',
        width: 90,
        sort: PurchasesSortField.items,
        cell:
            (r) =>
                r.items == null
                    ? _unknown(theme)
                    : _txt(theme, formatLargeNumberDouble(r.items!)),
        total:
            (t) => bold(formatLargeNumberDouble(t.totalItems)),
      ),
      _Col(
        label: 'Total',
        width: 160,
        sort: PurchasesSortField.total,
        cell: (r) {
          final total = bold(_money(r.total));
          if (!r.hasAdjustment) return total;
          final sign = r.adjustment! > 0 ? '+' : '-';
          return _withIcon(
            total,
            icon: Icons.edit_note_rounded,
            color: Colors.blueGrey,
            tooltip:
                'Custom total. Lines: ${_money(r.lineTotal!)} '
                '($sign${_money(r.adjustment!.abs())})',
          );
        },
        total: (t) => bold(_money(t.total)),
      ),
      _Col(
        label: 'Paid',
        width: 140,
        sort: PurchasesSortField.paid,
        cell: (r) => _txt(theme, _money(r.paid)),
        total: (t) => bold(_money(t.totalPaid)),
      ),
      _Col(
        label: 'Balance',
        width: 140,
        sort: PurchasesSortField.balance,
        cell:
            (r) => _txt(
              theme,
              _money(r.balance),
              color:
                  r.balance > 0
                      ? theme.lightModeColor.errorColor200
                      : null,
            ),
        total: (t) => bold(_money(t.totalBalance)),
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
    PurchaseReportRow r,
    int i,
  ) {
    return Material(
      color: i.isEven ? Colors.white : Colors.grey.shade50,
      child: InkWell(
        mouseCursor: SystemMouseCursors.click,
        hoverColor: theme.lightModeColor.prColor300.withAlpha(20),
        onTap: () => _openPurchase(r),
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

  /// Totals of the whole filtered set, not just this page.
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

  Widget _table(ThemeProvider theme, PurchaseReportPage res) {
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
              isSorted:
                  c.sort != null && c.sort == _state.sortField,
              ascending: _state.ascending,
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
          (c) => c.total?.call(res) ?? const SizedBox.shrink(),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------
  // grouped by staff / supplier / channel
  // ---------------------------------------------------------------

  List<_GCol> _groupColumns(ThemeProvider theme) {
    Widget bold(String text) => _txt(theme, text, bold: true);

    return [
      _GCol(
        label: _state.groupBy.label,
        width: 220,
        sort: PurchaseGroupSortField.name,
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
        label: 'Purchases',
        width: 110,
        sort: PurchaseGroupSortField.count,
        cell: (g) => _txt(theme, '${g.count}'),
        total: (t) => bold('${t.totalPurchases}'),
      ),
      _GCol(
        label: 'Items',
        width: 100,
        sort: PurchaseGroupSortField.items,
        cell:
            (g) =>
                g.items == null
                    ? _unknown(theme)
                    : _txt(theme, formatLargeNumberDouble(g.items!)),
        total:
            (t) =>
                t.totalItems == null
                    ? _unknown(theme)
                    : bold(formatLargeNumberDouble(t.totalItems!)),
      ),
      _GCol(
        label: 'Total',
        width: 160,
        sort: PurchaseGroupSortField.total,
        cell: (g) => bold(_money(g.total)),
        total: (t) => bold(_money(t.total)),
      ),
      _GCol(
        label: 'Paid',
        width: 140,
        sort: PurchaseGroupSortField.paid,
        cell: (g) => _txt(theme, _money(g.paid)),
        total: (t) => bold(_money(t.totalPaid)),
      ),
      _GCol(
        label: 'Balance',
        width: 140,
        sort: PurchaseGroupSortField.balance,
        cell: (g) => _txt(theme, _money(g.balance)),
        total: (t) => bold(_money(t.totalBalance)),
      ),
    ];
  }

  /// No row tap: a group has no single purchase to open.
  Widget _groupRow(
    List<_GCol> cols,
    PurchaseGroupRow g,
    int i,
  ) {
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
    PurchaseGroupPage res,
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
                  c.sort != null && c.sort == _state.groupSortField,
              ascending: _state.groupAscending,
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
          (c) => c.total?.call(res) ?? const SizedBox.shrink(),
        ),
      ),
    );
  }
}
