import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_expenses/expense_category.dart';
import 'package:stockall/classes/temp_expenses/sub_expense.dart';
import 'package:stockall/classes/temp_expenses/temp_expenses_class.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/refresh_functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/expenses/single_expense/expense_details.dart';
import 'package:stockall/pages/report/components/export/report_export_button.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/report_pager.dart';
import 'package:stockall/pages/report/components/report_pill.dart';
import 'package:stockall/pages/report/components/report_range_fields.dart';
import 'package:stockall/pages/report/expenses_report/expenses_report_table/class/expenses_report_export_spec.dart';
import 'package:stockall/pages/report/expenses_report/expenses_report_table/class/expenses_report_table_logic.dart';
import 'package:stockall/pages/report/expenses_report/expenses_report_table/components/expenses_report_filter_widgets.dart';
import 'package:stockall/pages/report/expenses_report/expenses_summary/class/expenses_summary_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/components/receipts_report_filter_widgets.dart';
import 'package:stockall/pages/report/staff_report/staff_report_table/class/staff_report_table_logic.dart';
import 'package:stockall/providers/theme_provider.dart';

/// Everything the Expenses Report screens read from the app.
/// [ExpensesReportEnv.live] uses the providers; tests pass their
/// own, since the providers need Supabase.
class ExpensesReportEnv {
  /// Shop settings and the user's permissions.
  final ExpensesReportAccess Function() access;

  /// Loaded expenses, before the user's scope.
  final List<TempExpensesClass> Function() expenses;

  /// The shop's custom categories, for their current names.
  final List<ExpenseCategory> Function() categories;

  /// User id -> full name, for the staff paid by a salary.
  final Map<String, String> Function() staffNames;

  final Future<void> Function(
    BuildContext context, {
    required bool refreshFromStore,
    ReceiptsReportPeriod? period,
  })
  load;

  /// Changes whenever the source data or the user's scope does.
  final String Function() signature;

  /// Subscribes the view to the providers it reads.
  final void Function(BuildContext context) listen;
  final String Function(BuildContext context, num amount) money;

  /// Returns when the user comes back, so the caller can rebuild.
  final Future<void> Function(BuildContext context, TempExpensesClass e)
  openExpense;

  /// Used by the analysis to open the table. Null in the app: the
  /// analysis pushes `ExpensesReportTablePage`.
  final Future<void> Function(
    BuildContext context,
    ExpensesTableHandoff handoff,
    ReceiptsReportPeriod period,
  )?
  openTable;

  const ExpensesReportEnv({
    required this.access,
    required this.expenses,
    required this.categories,
    required this.staffNames,
    required this.load,
    required this.signature,
    required this.listen,
    required this.money,
    required this.openExpense,
    this.openTable,
  });

  /// Rows the user may see, built once per data change.
  List<ExpensesReportRow> rows() {
    return ExpensesReportRowBuilder.buildAll(
      expenses: access().scope(expenses()),
      categories: categories(),
      staffNames: staffNames(),
    );
  }

  factory ExpensesReportEnv.live() {
    ExpensesReportAccess access() {
      final s = shopSingle();
      return ExpensesReportAccess(
        departmentsEnabled: s?.manageDepartments == true,
        canViewAllDepartments: authorization(
          authorized: Authorizations().viewAllDepartments,
        ),
        currentDepartmentUuid:
            returnDepartmentProvider().currentDepartment()?.uuid,
        canViewAllTransactions: authorization(
          authorized: Authorizations().viewAllTransactionRecords,
        ),
        currentUserId: currentUser().userId,
        canPickDate: authorization(authorized: Authorizations().viewDate),
        shopId: s?.shopId,
      );
    }

    Map<String, String> staffNames() {
      final users = returnUserProviderSingle();
      return {
        for (final u in [...users.usersMain, users.currentUserMain])
          if (u?.userId != null && u!.userId!.trim().isNotEmpty)
            u.userId!: StaffReportRow.nameOf(u),
      };
    }

    Future<void> load(
      BuildContext context, {
      required bool refreshFromStore,
      ReceiptsReportPeriod? period,
    }) async {
      final sid = shopSingle()?.shopId;
      if (sid == null) return;
      final expenses = returnExpensesProviderSingle();
      final users = returnUserProviderSingle();
      final fetchAll = period?.isAllTime ?? false;
      final startDate = period?.start;
      final endDate = period?.end ?? period?.start;
      if (users.usersMain.isEmpty) {
        await users.fetchUsersByShopOffline();
      }
      if (refreshFromStore) {
        await expenses.getExpenseCategories(sid);
        if (!context.mounted) return;
        await RefreshFunctions(context).refreshExpenses(
          context,
          startDate: startDate,
          endDate: endDate,
          fetchAll: fetchAll,
          forceRefresh: true,
        );
        return;
      }
      // Local (offline) reads, only when nothing is loaded yet.
      if (expenses.expensesMain.isEmpty) {
        await expenses.getExpensesOffline(sid);
      }
      await expenses.getExpenseCategories(sid);
      if (period != null && !period.isAllTime) {
        await expenses.getExpenses(
          sid,
          startDate: startDate,
          endDate: endDate,
          forceRefresh: false,
        );
      }
    }

    return ExpensesReportEnv(
      access: access,
      expenses: () => returnExpensesProviderSingle().expensesMain,
      categories: () => returnExpensesProviderSingle().expenseCategories,
      staffNames: staffNames,
      load: load,
      signature: () {
        final expenses = returnExpensesProviderSingle();
        int latest = 0;
        double spent = 0;
        int lines = 0;
        for (final e in expenses.expensesMain) {
          final t = (e.updatedAt ?? e.createdDate)?.millisecondsSinceEpoch ?? 0;
          if (t > latest) latest = t;
          spent += e.amount;
          lines += e.subExpenses?.length ?? 0;
        }
        final a = access();
        return '${expenses.expensesMain.length}|$latest|$spent|$lines|'
            '${expenses.expenseCategories.map((c) => '${c.uuid}:${c.name}').join(',')}|'
            '${staffNames().length}|'
            '${a.currentDepartmentUuid}|${a.currentUserId}|'
            '${a.departmentsEnabled}|${a.canViewAllTransactions}|'
            '${a.canViewAllDepartments}|${a.shopId}';
      },
      listen: (context) {
        returnExpensesProvider(context);
        returnUserProvider(context);
        returnDepartmentProvider(context: context);
        shop(context);
      },
      money: (context, amount) => formatMoneyBig(amount: amount, context: context),
      openExpense: (context, e) {
        final uuid = e.uuid;
        if (uuid == null) return Future.value();
        return Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ExpenseDetails(expenseUuid: uuid),
          ),
        );
      },
    );
  }
}

class _Col {
  final String label;
  final double width;
  final ExpensesSortField? sort;
  final TextAlign align;
  final Widget Function(ExpensesReportRow row) cell;

  /// Cell of a sub-expense line under its expense; empty when null.
  final Widget Function(SubExpense line)? line;

  /// Cell of the totals row; empty when null.
  final Widget Function(ExpensesReportPage res)? total;

  const _Col({
    required this.label,
    required this.width,
    required this.cell,
    this.sort,
    this.align = TextAlign.center,
    this.line,
    this.total,
  });
}

class _GCol {
  final String label;
  final double width;
  final ExpensesGroupSortField? sort;
  final TextAlign align;
  final Widget Function(ExpensesGroupRow row) cell;
  final Widget Function(ExpensesGroupPage res)? total;

  const _GCol({
    required this.label,
    required this.width,
    required this.cell,
    this.sort,
    this.align = TextAlign.center,
    this.total,
  });
}

const double _rowHeight = 52;
const double _lineHeight = 40;

/// Shared body of the Expenses Report table page (desktop and
/// mobile).
///
/// [initialFilters], [initialPeriod] and [initialIncludeStockPurchases]
/// let the analysis open the table on exactly a row's expenses.
class ExpensesReportTableView extends StatefulWidget {
  final bool isDesktop;
  final ExpensesReportFilters? initialFilters;
  final ReceiptsReportPeriod? initialPeriod;

  /// "Include stock purchases" to start with. Null: on.
  final bool? initialIncludeStockPurchases;

  /// Null in the app: [ExpensesReportEnv.live] is used.
  final ExpensesReportEnv? env;

  const ExpensesReportTableView({
    super.key,
    required this.isDesktop,
    this.initialFilters,
    this.initialPeriod,
    this.initialIncludeStockPurchases,
    this.env,
  });

  @override
  State<ExpensesReportTableView> createState() =>
      _ExpensesReportTableViewState();
}

class _ExpensesReportTableViewState extends State<ExpensesReportTableView> {
  late final ExpensesReportEnv _env;
  late final ExpensesReportTableState _state;
  final _searchCtrl = TextEditingController();
  final _amountMinCtrl = TextEditingController();
  final _amountMaxCtrl = TextEditingController();
  final _hScroll = ScrollController();
  final _vScroll = ScrollController();

  bool _showFilters = false;
  bool _toolbarIsOpen = false;

  late ReceiptsReportPeriod _period;
  late ExpensesReportAccess _access;

  bool _loading = true;
  String? _error;

  List<ExpensesReportRow> _baseRows = [];
  ExpensesReportPage? _result;
  ExpensesGroupPage? _groupResult;
  String _signature = '';

  /// Every filtered, sorted row and group, for the export.
  List<ExpensesReportRow> _sortedRows = [];
  List<ExpensesGroupRow> _sortedGroups = [];

  ExpensesFilterChoices _choices = ExpensesFilterChoices.empty;

  /// Rows whose lines show: [_expandAll] flipped by [_toggled].
  bool _expandAll = false;
  final Set<String> _toggled = {};

  ExpensesReportFilters get _filters => _state.filters;
  bool get _grouped => _state.grouped;

  @override
  void initState() {
    super.initState();
    _env = widget.env ?? ExpensesReportEnv.live();
    _access = _env.access();
    _state = ExpensesReportTableState(
      filters: widget.initialFilters?.copy(),
      includeStockPurchases: widget.initialIncludeStockPurchases ?? true,
    );
    _searchCtrl.text = _filters.search;
    _amountMinCtrl.text = _numText(_filters.amountMin);
    _amountMaxCtrl.text = _numText(_filters.amountMax);
    _period = widget.initialPeriod ?? _access.initialPeriod();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load(refreshFromStore: true);
    });
  }

  @override
  void dispose() {
    for (final c in [_searchCtrl, _amountMinCtrl, _amountMaxCtrl]) {
      c.dispose();
    }
    _hScroll.dispose();
    _vScroll.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------
  // data
  // ---------------------------------------------------------------

  bool get _departmentsEnabled => _access.departmentsEnabled;

  Future<void> _load({required bool refreshFromStore}) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _env.load(
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
    _access = _env.access();
    _baseRows = _env.rows();
    _choices = ExpensesFilterChoices.fromRows(
      _baseRows,
      categories: _env.categories(),
    );
    _signature = _env.signature();
  }

  void _recompute() {
    final sorted = ExpensesReportQuery.filterAndSort(
      rows: _baseRows,
      period: _period,
      filters: _filters,
      sortField: _state.sortField,
      ascending: _state.ascending,
      departmentsEnabled: _departmentsEnabled,
      includeStockPurchases: _state.includeStockPurchases,
    );
    _sortedRows = sorted;
    if (_grouped) {
      final groups = ExpensesGrouping.sort(
        ExpensesGrouping.build(sorted, _state.groupBy),
        field: _state.groupSortField,
        ascending: _state.groupAscending,
      );
      _sortedGroups = groups;
      final page = ExpensesGrouping.paginate(groups, _state.page, rows: sorted);
      _state.page = page.page;
      _groupResult = page;
    } else {
      final page = ExpensesReportQuery.paginate(sorted, _state.page);
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
        _grouped ? _groupResult?.totalPages : _result?.totalPages;
    final current = _grouped ? _groupResult?.page : _result?.page;
    if (totalPages == null || p < 1 || p > totalPages || p == current) {
      return;
    }
    _apply(() => _state.page = p, resetPage: false);
    if (_vScroll.hasClients) _vScroll.jumpTo(0);
  }

  void _setSort(ExpensesSortField f) {
    _apply(() {
      if (_state.sortField == f) {
        _state.ascending = !_state.ascending;
      } else {
        _state.sortField = f;
        _state.ascending = ExpensesReportQuery.defaultAscending(f);
      }
    });
  }

  void _setGroupSort(ExpensesGroupSortField f) {
    _apply(() {
      if (_state.groupSortField == f) {
        _state.groupAscending = !_state.groupAscending;
      } else {
        _state.groupSortField = f;
        // Names A-Z first; counts, amounts and dates largest first.
        _state.groupAscending = f == ExpensesGroupSortField.name;
      }
    });
  }

  /// Clears the filters only: the period, Group by and the stock
  /// purchase option stay.
  void _resetAll() {
    for (final c in [_searchCtrl, _amountMinCtrl, _amountMaxCtrl]) {
      c.clear();
    }
    _apply(_state.resetAll);
  }

  Future<void> _openExpense(ExpensesReportRow row) async {
    await _env.openExpense(context, row.expense);
    // Picks up an edit or delete made on the expense page.
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
    if (!p.isAllTime) _load(refreshFromStore: false);
  }

  /// Clears the range fields once its filter was removed (chip).
  void _applyAndSyncFields(VoidCallback change) {
    _apply(change);
    if (_filters.amountMin == null && _filters.amountMax == null) {
      _amountMinCtrl.clear();
      _amountMaxCtrl.clear();
    }
    if (_filters.search.isEmpty) _searchCtrl.clear();
  }

  bool _isExpanded(ExpensesReportRow r) =>
      r.hasLines && (_expandAll != _toggled.contains(r.uuid));

  void _toggle(ExpensesReportRow r) {
    setState(() {
      if (!_toggled.remove(r.uuid)) _toggled.add(r.uuid);
    });
  }

  // ---------------------------------------------------------------
  // formatting
  // ---------------------------------------------------------------

  String _money(num v) => _env.money(context, v);

  ReportExportSpec _exportSpec() {
    return expensesReportExportSpec(
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
    return v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();
  }

  // ---------------------------------------------------------------
  // build
  // ---------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = returnTheme(context);
    // Listen, so adds, edits and sync update the table.
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
        title: 'Expenses Report',
        widget: Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              mouseCursor: SystemMouseCursors.click,
              borderRadius: BorderRadius.circular(10),
              onTap: _loading ? null : () => _load(refreshFromStore: true),
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
        padding: EdgeInsets.symmetric(horizontal: widget.isDesktop ? 20 : 12),
        child: Column(
          children: [
            const SizedBox(height: 8),
            _toolbar(theme),
            if (_showFilters) _filterPanel(theme),
            ExpensesReportFilterChips(
              theme: theme,
              filters: _filters,
              choices: _choices,
              departmentsEnabled: _departmentsEnabled,
              money: _money,
              onApply: _applyAndSyncFields,
            ),
            _notes(),
            Expanded(child: _content(theme)),
            if (!_loading && _error == null && _grouped && _groupResult != null)
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
            if (!_loading && _error == null && !_grouped && _result != null)
              ReportPager(
                theme: theme,
                page: _result!.page,
                totalPages: _result!.totalPages,
                totalCount: _result!.totalCount,
                firstIndex: _result!.firstIndex,
                lastIndex: _result!.lastIndex,
                itemLabel: 'expenses',
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
    final count = _grouped ? _groupResult?.totalCount : _result?.totalCount;
    if (count == null || count == 0) {
      final hasFilters = _filters.hasAnything;
      return Padding(
        padding: const EdgeInsets.only(top: 60),
        child: EmptyWidgetDisplayOnly(
          title: hasFilters ? 'No Matching Expenses' : 'Empty List',
          subText:
              hasFilters
                  ? 'No expense matches your search and filters'
                  : 'No expense was recorded in this period',
          theme: theme,
          height: 35,
          icon: Icons.clear,
          altAction: hasFilters ? _resetAll : null,
          altActionText: hasFilters ? 'Clear all filters' : null,
          altIcon: hasFilters ? Icons.filter_alt_off : null,
        ),
      );
    }
    if (_grouped) return _groupTable(theme, _groupResult!);
    return _table(theme, _result!);
  }

  // ---------------------------------------------------------------
  // toolbar / filters
  // ---------------------------------------------------------------

  Widget _toolbar(ThemeProvider theme) {
    final active = _filters.activeCount;
    final accent = theme.lightModeColor.prColor300;
    final anyLines = !_grouped && _sortedRows.any((r) => r.hasLines);
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
                    onChanged: (v) => _apply(() => _filters.search = v),
                    decoration: InputDecoration(
                      hintText: 'Search name, category, staff or sub-expense',
                      hintStyle: TextStyle(
                        fontSize: theme.mobileTexts.b3.fontSize,
                      ),
                      prefixIcon: const Icon(Icons.search, size: 20),
                      suffixIcon:
                          _searchCtrl.text.isEmpty
                              ? null
                              : IconButton(
                                icon: const Icon(Icons.close, size: 18),
                                onPressed: () {
                                  _searchCtrl.clear();
                                  _apply(() => _filters.search = '');
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
                        () => setState(() => _toolbarIsOpen = !_toolbarIsOpen),
                    mouseCursor: SystemMouseCursors.click,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10.0, 6, 6, 6),
                      child: Row(
                        spacing: 1,
                        children: [
                          Text(
                            style: TextStyle(
                              fontSize: theme.mobileTexts.b4.fontSize,
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
        if (_toolbarIsOpen || screenWidth(context) > mobileScreen) ...[
          ReceiptsReportPeriodButton(
            theme: theme,
            period: _period,
            enabled: _access.canPickDate,
            onChanged: _setPeriod,
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
          // View options, not filters: Reset All keeps them.
          ExpensesGroupByButton(
            theme: theme,
            value: _state.groupBy,
            onChanged: (g) => _apply(() => _state.groupBy = g),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 5),
            child: ReportPill(
              theme: theme,
              icon:
                  _state.includeStockPurchases
                      ? Icons.check_box_outlined
                      : Icons.check_box_outline_blank,
              label: 'Include stock purchases',
              highlighted: _state.includeStockPurchases,
              onTap:
                  () => _apply(
                    () =>
                        _state.includeStockPurchases =
                            !_state.includeStockPurchases,
                  ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 5),
            child: ReportExportButton(buildSpec: _exportSpec),
          ),
          if (anyLines)
            Padding(
              padding: const EdgeInsets.only(right: 5),
              child: ReportPill(
                theme: theme,
                icon:
                    _expandAll
                        ? Icons.unfold_less_rounded
                        : Icons.unfold_more_rounded,
                label: _expandAll ? 'Collapse all' : 'Expand all',
                onTap:
                    () => setState(() {
                      _expandAll = !_expandAll;
                      _toggled.clear();
                    }),
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
        boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 5)],
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 12,
        children: [
          ...expensesKeyFilterFields(
            theme: theme,
            filters: _filters,
            choices: _choices,
            departmentsEnabled: _departmentsEnabled,
            onApply: _apply,
          ),
          ReportRangeFields(
            label: 'Amount range',
            minController: _amountMinCtrl,
            maxController: _amountMaxCtrl,
            errorText: _filters.amountRangeError,
            onChange:
                (a, b) => _apply(() {
                  _filters.amountMin = a;
                  _filters.amountMax = b;
                }),
          ),
        ],
      ),
    );
  }

  Widget _notes() {
    final totals = _grouped ? _groupResult?.totals : _result?.totals;
    if (_loading || totals == null) return const SizedBox.shrink();
    final notes = expensesReportNotes(
      period: _period,
      totals: totals,
      money: _money,
    );
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
                style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
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

  TextStyle _cellStyle(ThemeProvider theme, {bool bold = false, Color? color}) =>
      TextStyle(
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
    int maxLines = 2,
  }) {
    final t = Text(
      text,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      textAlign: align,
      style: _cellStyle(theme, bold: bold, color: color),
    );
    return tooltip == null ? t : Tooltip(message: tooltip, child: t);
  }

  Widget _grey(ThemeProvider theme, String text, {TextAlign? align}) =>
      _txt(theme, text, color: Colors.grey.shade600, align: align, maxLines: 1);

  Widget _badge(String text, Color color, {String? tooltip}) {
    final b = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
    return tooltip == null ? b : Tooltip(message: tooltip, child: b);
  }

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
        Tooltip(message: tooltip, child: Icon(icon, size: 15, color: color)),
      ],
    );
  }

  static const String _stockTip =
      'Stock purchase payment: shown, not counted in Total Expenses';

  Widget _nameCell(ThemeProvider theme, ExpensesReportRow r) {
    Widget name = _txt(
      theme,
      r.name,
      bold: true,
      align: TextAlign.start,
      maxLines: r.hasLines ? 1 : 2,
    );
    if (r.linesMismatch) {
      name = _withIcon(
        name,
        icon: Icons.warning_amber_rounded,
        color: Colors.orange.shade800,
        tooltip:
            'Sub-expenses add up to ${_money(r.expense.subExpensesTotal)}, '
            'not ${_money(r.amount)}',
      );
    }
    if (!r.hasLines) return name;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        name,
        Text(
          '${r.lineCount} sub-expense${r.lineCount == 1 ? '' : 's'}',
          style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  List<_Col> _columns(ThemeProvider theme) {
    Widget bold(String text) => _txt(theme, text, bold: true);
    String dash(String? s) => s ?? '—';

    return [
      _Col(
        label: '',
        width: 44,
        cell:
            (r) =>
                !r.hasLines
                    ? const SizedBox.shrink()
                    : IconButton(
                      tooltip:
                          _isExpanded(r)
                              ? 'Hide sub-expenses'
                              : 'Show sub-expenses',
                      visualDensity: VisualDensity.compact,
                      iconSize: 20,
                      onPressed: () => _toggle(r),
                      icon: Icon(
                        _isExpanded(r)
                            ? Icons.keyboard_arrow_down_rounded
                            : Icons.keyboard_arrow_right_rounded,
                      ),
                    ),
      ),
      _Col(
        label: 'Name',
        width: 220,
        sort: ExpensesSortField.name,
        align: TextAlign.start,
        cell: (r) => _nameCell(theme, r),
        line:
            (l) => Padding(
              padding: const EdgeInsets.only(left: 14),
              child: _txt(
                theme,
                '↳ ${l.name.trim().isEmpty ? 'Not Set' : l.name.trim()}',
                color: Colors.grey.shade700,
                align: TextAlign.start,
                maxLines: 1,
              ),
            ),
        total:
            (_) => _txt(theme, 'TOTAL', bold: true, align: TextAlign.start),
      ),
      _Col(
        label: 'Category',
        width: 170,
        sort: ExpensesSortField.category,
        cell:
            (r) => _badge(
              r.categoryLabel,
              expenseCategoryColor(r.categoryKey),
              tooltip: r.isStockPurchase ? _stockTip : null,
            ),
      ),
      _Col(
        label: 'Description',
        width: 200,
        align: TextAlign.start,
        cell:
            (r) => _txt(
              theme,
              dash(r.description),
              align: TextAlign.start,
              color: r.description == null ? Colors.grey : null,
            ),
        line:
            (l) => _grey(
              theme,
              (l.description?.trim().isNotEmpty ?? false)
                  ? l.description!.trim()
                  : '—',
              align: TextAlign.start,
            ),
      ),
      _Col(
        label: 'Quantity',
        width: 110,
        cell:
            (r) => _txt(
              theme,
              dash(r.quantityLabel),
              color: r.quantityLabel == null ? Colors.grey : null,
            ),
        line:
            (l) => _grey(theme, dash(expenseQuantityLabel(l.quantity, l.unit))),
      ),
      _Col(
        label: 'Staff',
        width: 160,
        sort: ExpensesSortField.staff,
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
        label: 'Staff Paid',
        width: 160,
        sort: ExpensesSortField.paidStaff,
        align: TextAlign.start,
        cell:
            (r) => _txt(
              theme,
              r.paidStaffLabel,
              align: TextAlign.start,
              color: r.paidStaffName == null ? Colors.grey : null,
            ),
      ),
      _Col(
        label: 'Channel',
        width: 150,
        sort: ExpensesSortField.channel,
        cell: (r) => _txt(theme, r.channelLabel),
        line: (l) => _grey(theme, l.paymentChannel),
      ),
      if (_departmentsEnabled)
        _Col(
          label: 'Department',
          width: 160,
          sort: ExpensesSortField.department,
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
        label: 'Date',
        width: 120,
        sort: ExpensesSortField.createdAt,
        cell:
            (r) =>
                r.createdAt == null
                    ? _txt(theme, '—', color: Colors.grey)
                    : _txt(theme, formatDateTime(r.createdAt!)),
      ),
      _Col(
        label: 'Time',
        width: 100,
        sort: ExpensesSortField.createdAt,
        cell:
            (r) =>
                r.createdAt == null
                    ? _txt(theme, '—', color: Colors.grey)
                    : _txt(theme, formatTime(r.createdAt!)),
      ),
      _Col(
        label: 'Lines',
        width: 80,
        sort: ExpensesSortField.lines,
        cell:
            (r) =>
                r.hasLines
                    ? _txt(theme, '${r.lineCount}')
                    : _txt(theme, '—', color: Colors.grey),
        total: (t) => bold('${t.totals.lineCount}'),
      ),
      _Col(
        label: 'Amount',
        width: 160,
        sort: ExpensesSortField.amount,
        cell: (r) {
          final amount = _txt(
            theme,
            _money(r.amount),
            bold: true,
            color: r.isStockPurchase ? Colors.grey.shade600 : null,
          );
          if (!r.isStockPurchase) return amount;
          return _withIcon(
            amount,
            icon: Icons.info_outline_rounded,
            color: Colors.teal,
            tooltip: _stockTip,
          );
        },
        line: (l) => _grey(theme, _money(l.amount)),
        total: (t) => bold(_money(t.totals.total)),
      ),
    ];
  }

  Alignment _alignment(TextAlign a) =>
      a == TextAlign.start
          ? Alignment.centerLeft
          : (a == TextAlign.end ? Alignment.centerRight : Alignment.center);

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
    Widget Function(T c) cell, {
    double height = _rowHeight,
  }) {
    return SizedBox(
      height: height,
      child: Row(
        children: [
          for (final c in cols)
            SizedBox(
              width: width(c),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Align(alignment: _alignment(align(c)), child: cell(c)),
              ),
            ),
        ],
      ),
    );
  }

  /// The expense, then its sub-expense lines when expanded.
  Widget _row(
    ThemeProvider theme,
    List<_Col> cols,
    ExpensesReportRow r,
    int i,
  ) {
    final bg = i.isEven ? Colors.white : Colors.grey.shade50;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: bg,
          child: InkWell(
            mouseCursor: SystemMouseCursors.click,
            hoverColor: theme.lightModeColor.prColor300.withAlpha(20),
            onTap: () => _openExpense(r),
            child: Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
              ),
              child: _cells<_Col>(
                cols,
                (c) => c.width,
                (c) => c.align,
                (c) => c.cell(r),
              ),
            ),
          ),
        ),
        if (_isExpanded(r))
          for (final l in r.lines)
            Container(
              decoration: BoxDecoration(
                color: theme.lightModeColor.prColor300.withAlpha(8),
                border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
              ),
              child: _cells<_Col>(
                cols,
                (c) => c.width,
                (c) => c.align,
                (c) => c.line?.call(l) ?? const SizedBox.shrink(),
                height: _lineHeight,
              ),
            ),
      ],
    );
  }

  /// Totals of the whole filtered set, not just this page.
  Widget _totalsRow(ThemeProvider theme, Widget content) {
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
          boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 12)],
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
                    (notif) => notif.metrics.axis == Axis.horizontal,
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
                          color: theme.lightModeColor.prColor300.withAlpha(22),
                          child: header,
                        ),
                        const Divider(height: 1),
                        Expanded(
                          child: ScrollConfiguration(
                            behavior: ScrollConfiguration.of(
                              context,
                            ).copyWith(scrollbars: false),
                            // Rows grow when their lines are shown, so
                            // no fixed item extent.
                            child: ListView.builder(
                              controller: _vScroll,
                              itemCount: itemCount,
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

  Widget _table(ThemeProvider theme, ExpensesReportPage res) {
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
              isSorted: c.sort != null && c.sort == _state.sortField,
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
          height: 46,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------
  // grouped
  // ---------------------------------------------------------------

  List<_GCol> _groupColumns(ThemeProvider theme) {
    Widget bold(String text) => _txt(theme, text, bold: true);

    return [
      _GCol(
        label: _state.groupBy.label,
        width: 240,
        sort: ExpensesGroupSortField.name,
        align: TextAlign.start,
        cell:
            (g) => _txt(
              theme,
              g.label,
              bold: true,
              align: TextAlign.start,
              color: g.isNone || g.name == null ? Colors.grey : null,
            ),
        total: (_) => _txt(theme, 'TOTAL', bold: true, align: TextAlign.start),
      ),
      _GCol(
        label: 'Expenses',
        width: 110,
        sort: ExpensesGroupSortField.count,
        cell: (g) => _txt(theme, '${g.count}'),
        total: (t) => bold('${t.totals.count}'),
      ),
      _GCol(
        label: 'Lines',
        width: 90,
        cell: (g) => _txt(theme, '${g.lineCount}'),
        total: (t) => bold('${t.totals.lineCount}'),
      ),
      _GCol(
        label: 'Amount',
        width: 190,
        sort: ExpensesGroupSortField.amount,
        cell: (g) {
          final amount = bold(_money(g.amount));
          if (g.stockPurchaseAmount <= 0) return amount;
          return _withIcon(
            amount,
            icon: Icons.info_outline_rounded,
            color: Colors.teal,
            tooltip:
                'Includes ${_money(g.stockPurchaseAmount)} of stock '
                'purchases, not counted in Total Expenses',
          );
        },
        total: (t) => bold(_money(t.totals.total)),
      ),
      _GCol(
        label: 'Last Expense',
        width: 140,
        sort: ExpensesGroupSortField.lastDate,
        cell:
            (g) =>
                g.lastDate == null
                    ? _txt(theme, '—', color: Colors.grey)
                    : _txt(theme, formatDateTime(g.lastDate!)),
      ),
    ];
  }

  /// No row tap: a group has no single expense to open.
  Widget _groupRow(List<_GCol> cols, ExpensesGroupRow g, int i) {
    return Container(
      decoration: BoxDecoration(
        color: i.isEven ? Colors.white : Colors.grey.shade50,
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: _cells<_GCol>(
        cols,
        (c) => c.width,
        (c) => c.align,
        (c) => c.cell(g),
      ),
    );
  }

  Widget _groupTable(ThemeProvider theme, ExpensesGroupPage res) {
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
              isSorted: c.sort != null && c.sort == _state.groupSortField,
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
          height: 46,
        ),
      ),
    );
  }
}
