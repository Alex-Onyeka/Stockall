import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_expenses/temp_expenses_class.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/report/components/export/report_export_button.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/report_trend_chart.dart';
import 'package:stockall/pages/report/expenses_report/expenses_report_table/class/expenses_report_table_logic.dart';
import 'package:stockall/pages/report/expenses_report/expenses_report_table/components/expenses_report_filter_widgets.dart';
import 'package:stockall/pages/report/expenses_report/expenses_report_table/components/expenses_report_table_view.dart';
import 'package:stockall/pages/report/expenses_report/expenses_report_table/expenses_report_table_page.dart';
import 'package:stockall/pages/report/expenses_report/expenses_summary/class/expenses_summary_export_spec.dart';
import 'package:stockall/pages/report/expenses_report/expenses_summary/class/expenses_summary_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/components/receipts_report_filter_widgets.dart';
import 'package:stockall/providers/theme_provider.dart';

/// Shared body of the Expenses Summary and Analysis page (desktop
/// and mobile). Navigation is one way: KPIs, top sub-expenses and
/// breakdown rows open the expenses table on exactly their expenses
/// and the current period; a top expense opens the expense itself.
class ExpensesSummaryView extends StatefulWidget {
  final bool isDesktop;
  final ReceiptsReportPeriod? initialPeriod;

  /// Null in the app: [ExpensesReportEnv.live] is used.
  final ExpensesReportEnv? env;

  const ExpensesSummaryView({
    super.key,
    required this.isDesktop,
    this.initialPeriod,
    this.env,
  });

  @override
  State<ExpensesSummaryView> createState() => _ExpensesSummaryViewState();
}

class _ExpensesSummaryViewState extends State<ExpensesSummaryView> {
  late final ExpensesReportEnv _env;
  late ExpensesReportAccess _access;
  late ReceiptsReportPeriod _period;
  ExpensesBreakdownTab _tab = ExpensesBreakdownTab.category;

  /// Null: the built order (amount, largest first).
  ExpensesBreakdownSortField? _sortField;
  bool _ascending = false;

  bool _loading = true;
  String? _error;
  ExpensesSummaryResult? _result;
  String _signature = '';

  static const Color _salaryColor = Colors.indigo;

  @override
  void initState() {
    super.initState();
    _env = widget.env ?? ExpensesReportEnv.live();
    _access = _env.access();
    _period = widget.initialPeriod ?? _access.initialPeriod();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load(refreshFromStore: false);
    });
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
      _rebuild();
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

  void _rebuild() {
    _access = _env.access();
    _result = ExpensesSummaryBuilder.build(
      rows: _env.rows(),
      period: _period,
      departmentsEnabled: _departmentsEnabled,
    );
    _signature = _env.signature();
  }

  void _rebuildInState() {
    setState(() {
      try {
        _rebuild();
        _error = null;
      } catch (e) {
        _error = e.toString();
      }
    });
  }

  void _setPeriod(ReceiptsReportPeriod p) {
    _period = p;
    _rebuildInState();
    if (!p.isAllTime) _load(refreshFromStore: false);
  }

  Future<void> _pushTable(
    BuildContext context,
    ExpensesTableHandoff handoff,
    ReceiptsReportPeriod period,
  ) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ExpensesReportTablePage(
              initialFilters: handoff.filters,
              initialPeriod: period,
              initialIncludeStockPurchases: handoff.includeStockPurchases,
            ),
      ),
    );
  }

  Future<void> _openTable(ExpensesTableHandoff handoff) async {
    final open = _env.openTable ?? _pushTable;
    await open(context, handoff, _period);
    // Picks up edits made from the table.
    if (mounted) _rebuildInState();
  }

  Future<void> _openExpense(ExpensesReportRow r) async {
    await _env.openExpense(context, r.expense);
    if (mounted) _rebuildInState();
  }

  /// Every expense counted in Total Expenses.
  void _openAll() => _openTable(ExpensesTableHandoff.of());

  // ---------------------------------------------------------------
  // formatting
  // ---------------------------------------------------------------

  String _money(num v) => _env.money(context, v);

  ReportExportSpec _exportSpec() {
    final tabs = _tabs;
    return expensesSummaryExportSpec(
      result: _result!,
      period: _period,
      tabs: tabs,
      activeTab: tabs.contains(_tab) ? _tab : tabs.first,
      sortField: _sortField,
      ascending: _ascending,
      currency: currencySymbol(context: context),
    );
  }

  String _percent(double v) =>
      '${formatLargeNumberDouble(double.parse(v.toStringAsFixed(2)))}%';

  BoxDecoration get _card => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: Colors.grey.shade100),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withAlpha(5),
        blurRadius: 6,
        offset: const Offset(0, 2),
      ),
    ],
  );

  Widget _title(ThemeProvider theme, String text, String sub) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: theme.mobileTexts.b1.fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          sub,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: theme.mobileTexts.b4.fontSize,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  Widget _emptyText(ThemeProvider theme, String text) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: theme.mobileTexts.b3.fontSize,
            color: Colors.grey.shade500,
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------
  // build
  // ---------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = returnTheme(context);
    // Listen, so adds, edits and sync update the analysis.
    _env.listen(context);

    if (!_loading && _error == null) {
      final sig = _env.signature();
      if (sig != _signature) {
        try {
          _rebuild();
        } catch (e) {
          _error = e.toString();
        }
      }
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 252, 253, 255),
      appBar: appBar(
        context: context,
        title: 'Expenses Summary and Analysis',
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
      body: _body(theme),
    );
  }

  Widget _body(ThemeProvider theme) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final result = _result;
    if (_error != null || result == null) {
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
              onPressed: () => _load(refreshFromStore: false),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
            ),
          ],
        ),
      );
    }
    final gap = SizedBox(height: widget.isDesktop ? 16 : 12);
    final notes = expensesReportNotes(
      period: _period,
      totals: ExpensesReportTotals.of(result.rows),
      money: _money,
    );
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: widget.isDesktop ? 20 : 12,
        vertical: 10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ReceiptsReportPeriodButton(
                  theme: theme,
                  period: _period,
                  enabled: _access.canPickDate,
                  onChanged: _setPeriod,
                ),
                ReportExportButton(buildSpec: _exportSpec),
              ],
            ),
          ),
          if (notes.isNotEmpty) _note(notes),
          gap,
          _kpis(theme, result.stats),
          gap,
          _trendCard(theme, result),
          gap,
          _pair(_topExpenses(theme, result), _topLines(theme, result)),
          gap,
          _breakdown(theme, result),
          gap,
        ],
      ),
    );
  }

  /// Side by side on desktop, stacked on mobile.
  Widget _pair(Widget a, Widget b) {
    if (widget.isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: a),
          const SizedBox(width: 12),
          Expanded(child: b),
        ],
      );
    }
    return Column(children: [a, const SizedBox(height: 12), b]);
  }

  Widget _note(List<String> notes) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
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
    );
  }

  // ---------------------------------------------------------------
  // KPIs
  // ---------------------------------------------------------------

  Widget _kpis(ThemeProvider theme, ExpensesSummaryStats s) {
    final largest = s.largest;
    final cards = <Widget>[
      _kpi(
        theme,
        id: 'total',
        title: 'Total Expenses',
        value: _money(s.totalExpenses),
        subtitle: 'Without stock purchases',
        icon: Icons.account_balance_wallet_outlined,
        color: theme.lightModeColor.prColor300,
        onTap: _openAll,
      ),
      _kpi(
        theme,
        id: 'count',
        title: 'Number of Expenses',
        value: '${s.expenseCount}',
        subtitle: 'Recorded in this period',
        icon: Icons.receipt_long_rounded,
        color: const Color(0xFF7E22CE),
        onTap: _openAll,
      ),
      _kpi(
        theme,
        id: 'average',
        title: 'Average per Expense',
        value: _money(s.average),
        subtitle: 'Total / number of expenses',
        icon: Icons.functions_rounded,
        color: const Color(0xFF0891B2),
        onTap: _openAll,
      ),
      _kpi(
        theme,
        id: 'largest',
        title: 'Largest Expense',
        value: largest == null ? '—' : _money(largest.amount),
        subtitle: largest?.name ?? 'No expense',
        icon: Icons.trending_up_rounded,
        color: const Color(0xFFDC2626),
        onTap: largest == null ? _openAll : () => _openExpense(largest),
      ),
      _kpi(
        theme,
        id: 'salary',
        title: 'Staff Salaries',
        value: _money(s.salaryTotal),
        subtitle:
            '${s.salaryCount} payment${s.salaryCount == 1 ? '' : 's'}'
            ' · ${s.staffPaidCount} staff',
        icon: Icons.badge_outlined,
        color: _salaryColor,
        onTap:
            () => _openTable(
              ExpensesTableHandoff.of(categoryKey: ExpenseType.staffSalary),
            ),
      ),
      _kpi(
        theme,
        id: 'lines',
        title: 'With Sub-expenses',
        value: '${s.withLinesCount}',
        subtitle: '${s.lineCount} line${s.lineCount == 1 ? '' : 's'}',
        icon: Icons.account_tree_outlined,
        color: const Color(0xFF2563EB),
        onTap: () => _openTable(_withLines()),
      ),
      _kpi(
        theme,
        id: 'categories',
        title: 'Categories Used',
        value: '${s.categoriesUsed}',
        subtitle: 'With an expense in this period',
        icon: Icons.category_outlined,
        color: const Color(0xFF059669),
        onTap: _openAll,
      ),
      _kpi(
        theme,
        id: 'stock',
        title: 'Stock Purchase Payments',
        value: _money(s.stockPurchaseTotal),
        subtitle: 'Not in Total Expenses',
        icon: Icons.inventory_2_outlined,
        color: expenseCategoryColor(ExpenseType.stockPurchase),
        onTap:
            () => _openTable(
              ExpensesTableHandoff.of(categoryKey: ExpenseType.stockPurchase),
            ),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 10.0;
        final perRow = widget.isDesktop ? 4 : 2;
        final width = (constraints.maxWidth - spacing * (perRow - 1)) / perRow;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [for (final c in cards) SizedBox(width: width, child: c)],
        );
      },
    );
  }

  ExpensesTableHandoff _withLines() {
    final h = ExpensesTableHandoff.of();
    h.filters.hasLines = true;
    return h;
  }

  Widget _kpi(
    ThemeProvider theme, {
    required String id,
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      key: ValueKey('expenses-kpi-$id'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: _card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              spacing: 8,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: color.withAlpha(25),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(icon, size: 16, color: color),
                ),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: theme.mobileTexts.b4.fontSize,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: theme.mobileTexts.b1.fontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            if (screenWidth(context) > mobileScreen)
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: theme.mobileTexts.b4.fontSize,
                  color: Colors.grey.shade500,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------
  // trend
  // ---------------------------------------------------------------

  Widget _trendCard(ThemeProvider theme, ExpensesSummaryResult r) {
    final trend = r.trend;
    final subtitle =
        '${reportTrendIntervalLabel(r.interval)}, by business day. '
        'Stock purchases left out';
    final hasData = trend.any((p) => p.count > 0);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          _title(theme, 'Expenses Trend', subtitle),
          if (!hasData)
            _emptyText(theme, 'No expenses in this period.')
          else
            ReportTrendChart(
              starts: [for (final p in trend) p.start],
              interval: r.interval,
              money: _money,
              series: [
                ReportTrendSeries(
                  label: 'Expenses',
                  color: theme.lightModeColor.prColor300,
                  values: [for (final p in trend) p.total],
                ),
                ReportTrendSeries(
                  label: 'Staff Salary',
                  color: _salaryColor,
                  values: [for (final p in trend) p.salary],
                ),
              ],
            ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------
  // top lists
  // ---------------------------------------------------------------

  Widget _listCard(
    ThemeProvider theme, {
    required String title,
    required String subtitle,
    required String empty,
    required List<Widget> rows,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title(theme, title, subtitle),
          const SizedBox(height: 8),
          if (rows.isEmpty) _emptyText(theme, empty),
          ...rows,
        ],
      ),
    );
  }

  Widget _rankRow(
    ThemeProvider theme, {
    required Key key,
    required int rank,
    required String label,
    required String detail,
    required String amount,
    required VoidCallback onTap,
  }) {
    return InkWell(
      key: key,
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          spacing: 10,
          children: [
            Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color:
                    rank == 1
                        ? const Color(0xFFFEF3C7)
                        : const Color(0xFFF3F4F6),
                shape: BoxShape.circle,
              ),
              child: Text(
                '$rank',
                style: TextStyle(
                  fontSize: theme.mobileTexts.b4.fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: theme.mobileTexts.b3.fontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    detail,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: theme.mobileTexts.b4.fontSize,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  amount,
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b3.fontSize,
                    fontWeight: FontWeight.bold,
                    color: theme.lightModeColor.prColor300,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _topExpenses(ThemeProvider theme, ExpensesSummaryResult r) {
    final top = r.topExpenses;
    return _listCard(
      theme,
      title: 'Top Expenses',
      subtitle: 'Largest in this period',
      empty: 'No expenses in this period.',
      rows: [
        for (var i = 0; i < top.length; i++)
          _rankRow(
            theme,
            key: ValueKey('expenses-top-${top[i].uuid}'),
            rank: i + 1,
            label: top[i].name,
            detail: [
              top[i].categoryLabel,
              if (top[i].createdAt != null) formatDateTime(top[i].createdAt!),
            ].join(' · '),
            amount: _money(top[i].amount),
            onTap: () => _openExpense(top[i]),
          ),
      ],
    );
  }

  Widget _topLines(ThemeProvider theme, ExpensesSummaryResult r) {
    final top = r.topLines;
    return _listCard(
      theme,
      title: 'Top Sub-expenses',
      subtitle: 'Sub-expense names across expenses',
      empty: 'No sub-expenses in this period.',
      rows: [
        for (var i = 0; i < top.length; i++)
          _rankRow(
            theme,
            key: ValueKey('expenses-line-${top[i].key}'),
            rank: i + 1,
            label: top[i].label,
            detail:
                '${top[i].lineCount} line${top[i].lineCount == 1 ? '' : 's'}'
                ' on ${top[i].expenseCount} expense'
                '${top[i].expenseCount == 1 ? '' : 's'}',
            amount: _money(top[i].amount),
            onTap: () => _openTable(top[i].handoff),
          ),
      ],
    );
  }

  // ---------------------------------------------------------------
  // breakdown tables
  // ---------------------------------------------------------------

  List<ExpensesBreakdownTab> get _tabs => [
    ExpensesBreakdownTab.category,
    ExpensesBreakdownTab.salary,
    ExpensesBreakdownTab.staff,
    ExpensesBreakdownTab.channel,
    if (_departmentsEnabled) ExpensesBreakdownTab.department,
  ];

  void _setTab(ExpensesBreakdownTab t) {
    setState(() {
      _tab = t;
      // Each tab starts in its built order.
      _sortField = null;
      _ascending = false;
    });
  }

  void _setSort(ExpensesBreakdownSortField f) {
    setState(() {
      if (_sortField == f) {
        _ascending = !_ascending;
      } else {
        _sortField = f;
        // Names A-Z first; counts, amounts and dates largest first.
        _ascending = f == ExpensesBreakdownSortField.name;
      }
    });
  }

  Widget _breakdown(ThemeProvider theme, ExpensesSummaryResult result) {
    final tabs = _tabs;
    final tab = tabs.contains(_tab) ? _tab : tabs.first;
    final rows = ExpensesSummaryBuilder.sortBreakdown(
      result.breakdown(tab),
      field: _sortField,
      ascending: _ascending,
    );

    final cols =
        <({String label, double width, ExpensesBreakdownSortField sort})>[
          (label: tab.label, width: 220, sort: ExpensesBreakdownSortField.name),
          (
            label: 'Expenses',
            width: 110,
            sort: ExpensesBreakdownSortField.count,
          ),
          (
            label: 'Amount',
            width: 150,
            sort: ExpensesBreakdownSortField.amount,
          ),
          (
            label: 'Average',
            width: 140,
            sort: ExpensesBreakdownSortField.average,
          ),
          (
            label: 'Last expense',
            width: 140,
            sort: ExpensesBreakdownSortField.lastDate,
          ),
          (label: 'Share', width: 100, sort: ExpensesBreakdownSortField.share),
        ];

    Widget cell(double width, Widget child, {bool start = false}) {
      return SizedBox(
        width: width,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Align(
            alignment: start ? Alignment.centerLeft : Alignment.center,
            child: child,
          ),
        ),
      );
    }

    Widget txt(String s, {bool bold = false, Color? color}) => Text(
      s,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: theme.mobileTexts.b3.fontSize,
        fontWeight: bold ? FontWeight.bold : FontWeight.w500,
        color: color ?? Colors.black87,
      ),
    );

    Widget header(
      ({String label, double width, ExpensesBreakdownSortField sort}) c,
      bool start,
    ) {
      final accent = theme.lightModeColor.prColor300;
      final sorted = _sortField == c.sort;
      return InkWell(
        key: ValueKey('expenses-sort-${c.sort.name}'),
        mouseCursor: SystemMouseCursors.click,
        onTap: () => _setSort(c.sort),
        child: cell(
          c.width,
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 3,
            children: [
              Flexible(
                child: txt(c.label, bold: true, color: sorted ? accent : null),
              ),
              Icon(
                sorted
                    ? (_ascending
                        ? Icons.arrow_upward_rounded
                        : Icons.arrow_downward_rounded)
                    : Icons.unfold_more_rounded,
                size: 14,
                color: sorted ? accent : Colors.grey,
              ),
            ],
          ),
          start: start,
        ),
      );
    }

    Widget label(ExpensesBreakdownRow r) {
      final name = txt(
        r.label,
        bold: true,
        color: r.isNone || r.excluded ? Colors.grey.shade600 : null,
      );
      if (!r.excluded) return name;
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          name,
          Text(
            'Not in Total Expenses',
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
          ),
        ],
      );
    }

    Widget rowWidget(ExpensesBreakdownRow r, int i) {
      final values = <Widget>[
        label(r),
        txt('${r.count}'),
        txt(
          _money(r.amount),
          bold: true,
          color: r.excluded ? Colors.grey.shade600 : null,
        ),
        txt(_money(r.average)),
        txt(r.lastDate == null ? '—' : formatDateTime(r.lastDate!)),
        txt(r.share == null ? '—' : _percent(r.share!)),
      ];
      return Material(
        color: Colors.transparent,
        child: InkWell(
          key: ValueKey('expenses-row-${r.id}'),
          mouseCursor: SystemMouseCursors.click,
          onTap: () => _openTable(r.handoff),
          child: Container(
            height: 46,
            decoration: BoxDecoration(
              color: i.isEven ? Colors.white : Colors.grey.shade50,
              border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
            ),
            child: Row(
              children: [
                for (var c = 0; c < cols.length; c++)
                  cell(cols[c].width, values[c], start: c == 0),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: _card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                _title(
                  theme,
                  'Expenses Breakdown',
                  'Tap a row to open its expenses in the table',
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    spacing: 6,
                    children: [
                      for (final t in tabs)
                        ChoiceChip(
                          key: ValueKey('expenses-tab-${t.name}'),
                          label: Text(t.label),
                          selected: t == tab,
                          onSelected: (_) => _setTab(t),
                          selectedColor: theme.lightModeColor.prColor50,
                          backgroundColor: Colors.grey.shade100,
                          labelStyle: TextStyle(
                            fontSize: theme.mobileTexts.b4.fontSize,
                            fontWeight:
                                t == tab ? FontWeight.bold : FontWeight.w500,
                            color:
                                t == tab
                                    ? theme.lightModeColor.prColor300
                                    : Colors.grey.shade700,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (rows.isEmpty)
            _emptyText(
              theme,
              tab == ExpensesBreakdownTab.salary
                  ? 'No staff salary in this period.'
                  : 'No expenses in this period.',
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 44,
                    color: theme.lightModeColor.prColor300.withAlpha(22),
                    child: Row(
                      children: [
                        for (var c = 0; c < cols.length; c++)
                          header(cols[c], c == 0),
                      ],
                    ),
                  ),
                  for (var i = 0; i < rows.length; i++) rowWidget(rows[i], i),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
