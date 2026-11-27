import 'package:flutter/material.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/report/components/export/report_export_button.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/report_pager.dart';
import 'package:stockall/pages/report/components/report_pill.dart';
import 'package:stockall/pages/report/components/report_range_fields.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/components/receipts_report_filter_widgets.dart';
import 'package:stockall/pages/report/staff_report/staff_expenses/class/staff_expenses_export_spec.dart';
import 'package:stockall/pages/report/staff_report/staff_expenses/class/staff_expenses_logic.dart';
import 'package:stockall/pages/report/staff_report/staff_report_table/class/staff_report_export_spec.dart';
import 'package:stockall/pages/report/staff_report/staff_report_table/class/staff_report_table_logic.dart';
import 'package:stockall/pages/report/staff_report/staff_report_table/components/staff_report_table_view.dart';
import 'package:stockall/providers/theme_provider.dart';

class _Col {
  final String label;
  final double width;

  /// Null: the column cannot be sorted.
  final StaffExpensesSortField? sort;
  final TextAlign align;
  final Widget Function(StaffExpenseRow row) cell;

  /// Cell of the totals row; empty when null.
  final Widget Function(StaffExpensesTotals totals)? total;

  const _Col({
    required this.label,
    required this.width,
    required this.cell,
    this.sort,
    this.align = TextAlign.center,
    this.total,
  });
}

/// Shared body of the Staff Expenses page (desktop + mobile): one
/// staff's expenses in a period. Reached only from the staff's
/// analysis. Without the View Date permission the period is today.
class StaffExpensesView extends StatefulWidget {
  final bool isDesktop;

  /// `TempUserClass.userId`, the staff id every record carries.
  final String staffKey;
  final ReceiptsReportPeriod? initialPeriod;

  /// Null in the app: [StaffReportEnv.live] is used.
  final StaffReportEnv? env;

  const StaffExpensesView({
    super.key,
    required this.isDesktop,
    required this.staffKey,
    this.initialPeriod,
    this.env,
  });

  @override
  State<StaffExpensesView> createState() => _StaffExpensesViewState();
}

class _StaffExpensesViewState extends State<StaffExpensesView> {
  late final StaffReportEnv _env;
  final _filters = StaffExpensesFilters();
  final _searchCtrl = TextEditingController();
  final _amountMinCtrl = TextEditingController();
  final _amountMaxCtrl = TextEditingController();
  final _hScroll = ScrollController();
  final _vScroll = ScrollController();

  StaffExpensesSortField _sortField = StaffExpensesSortField.createdAt;
  bool _ascending = false;
  int _page = 1;
  bool _showFilters = false;
  bool _toolbarIsOpen = false;

  late ReceiptsReportPeriod _period;
  late StaffReportAccess _access;

  bool _loading = true;
  String? _error;

  StaffReportBase? _base;
  StaffReportRow? _staff;
  StaffExpensesPage? _result;
  String _signature = '';

  // Every filtered, sorted expense, for the export.
  List<StaffExpenseRow> _sortedRows = [];

  @override
  void initState() {
    super.initState();
    _env = widget.env ?? StaffReportEnv.live();
    _access = _env.access(context);
    _period =
        _access.canPickDate
            ? (widget.initialPeriod ?? ReceiptsReportPeriod.today())
            : _access.initialPeriod();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load(refreshFromStore: true);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _amountMinCtrl.dispose();
    _amountMaxCtrl.dispose();
    _hScroll.dispose();
    _vScroll.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------
  // data
  // ---------------------------------------------------------------

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
      if (!mounted) return;
      _rebuildBase();
      _recompute();
      setState(() => _loading = false);
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
    _access = _env.access(context);
    _base = StaffReportBase.build(source: _env.source(), access: _access);
    _signature = _env.signature(context);
    _rebuildStaff();
  }

  /// The staff's row of the current period: name and Former flag.
  void _rebuildStaff() {
    final base = _base;
    if (base == null) return;
    _staff = StaffReportRowBuilder.single(
      staffKey: widget.staffKey,
      slice: StaffReportSlice.of(base, _period),
    );
  }

  void _recompute() {
    final base = _base;
    if (base == null) return;
    _sortedRows = StaffExpensesTable.filterAndSort(
      base: base,
      staffKey: widget.staffKey,
      period: _period,
      filters: _filters,
      sortField: _sortField,
      ascending: _ascending,
    );
    final page = StaffExpensesTable.paginate(_sortedRows, _page);
    _page = page.page;
    _result = page;
  }

  ReportExportSpec _exportSpec() {
    return staffExpensesExportSpec(
      staffName: _staff?.name ?? 'Not Set',
      rows: _sortedRows,
      filters: _filters,
      sortField: _sortField,
      ascending: _ascending,
      departmentsEnabled: _access.departmentsEnabled,
      period: _period,
      currency: currencySymbol(context: context),
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
    final res = _result;
    if (res == null || p < 1 || p > res.totalPages || p == res.page) {
      return;
    }
    _apply(() => _page = p, resetPage: false);
    if (_vScroll.hasClients) {
      _vScroll.jumpTo(0);
    }
  }

  void _setSort(StaffExpensesSortField f) {
    _apply(() {
      if (_sortField == f) {
        _ascending = !_ascending;
      } else {
        _sortField = f;
        _ascending = StaffExpensesTable.defaultAscending(f);
      }
    });
  }

  void _clearAmount() {
    _filters.amountMin = null;
    _filters.amountMax = null;
    _amountMinCtrl.clear();
    _amountMaxCtrl.clear();
  }

  /// Clears the search and filters only: the period and sort stay.
  void _resetAll() {
    _searchCtrl.clear();
    _apply(() {
      _filters.clearAll();
      _clearAmount();
    });
  }

  void _setPeriod(ReceiptsReportPeriod p) {
    _apply(() {
      _period = p;
      _rebuildStaff();
    });
    if (!p.isAllTime) {
      _load(refreshFromStore: false);
    }
  }

  Future<void> _openExpense(StaffExpenseRow row) async {
    await _env.openExpense(context, row.expense);
    // Picks up anything changed while the expense was open.
    if (mounted) {
      setState(() {
        try {
          _rebuildBase();
          _recompute();
          _error = null;
        } catch (e) {
          _error = e.toString();
        }
      });
    }
  }

  // ---------------------------------------------------------------
  // build
  // ---------------------------------------------------------------

  String _money(num v) => _env.money(context, v);

  @override
  Widget build(BuildContext context) {
    final theme = returnTheme(context);
    // Listen, so new, edited and synced expenses show.
    _env.listen(context);

    if (!_loading && _error == null) {
      final sig = _env.signature(context);
      if (sig != _signature) {
        try {
          _rebuildBase();
          _recompute();
        } catch (e) {
          _error = e.toString();
        }
      }
    }

    final staff = _staff;
    final title = staff == null ? 'Expenses' : '${staff.name}: Expenses';
    final res = _result;
    final showTable = _access.showExpenses;
    return Scaffold(
      appBar: appBar(
        context: context,
        title: title,
        titleWidget:
            staff != null && staff.isFormer
                ? Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 8,
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: theme.mobileTexts.h4.fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _badge(
                      staffReportFormerRoleLabel,
                      theme.lightModeColor.errorColor200,
                    ),
                  ],
                )
                : null,
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
            if (showTable) ...[
              _toolbar(theme),
              if (_showFilters) _filterPanel(theme),
              _activeChips(theme),
              _notes(),
            ],
            Expanded(child: _content(theme)),
            if (showTable && !_loading && _error == null && res != null)
              ReportPager(
                theme: theme,
                page: res.page,
                totalPages: res.totalPages,
                totalCount: res.totalCount,
                firstIndex: res.firstIndex,
                lastIndex: res.lastIndex,
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
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (!_access.showExpenses) {
      return Center(
        child: Text(
          'Expenses are not available.',
          style: TextStyle(
            fontSize: theme.mobileTexts.b2.fontSize,
            color: Colors.grey.shade600,
          ),
        ),
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
              onPressed: () => _load(refreshFromStore: false),
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
          title: hasFilters ? 'No Matching Expenses' : 'Empty List',
          subText:
              hasFilters
                  ? 'No expense matches your search and filters'
                  : 'No expenses in this period',
          theme: theme,
          height: 35,
          icon: Icons.clear,
          altAction: hasFilters ? _resetAll : null,
          altActionText: hasFilters ? 'Clear all filters' : null,
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
            width: widget.isDesktop ? 320 : double.infinity,
            height: 38,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => _apply(() => _filters.search = v),
                    decoration: InputDecoration(
                      hintText: 'Search name, description or unit',
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
          // Scrolls on narrow screens, where a range label is wider
          // than the page.
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ReceiptsReportPeriodButton(
              theme: theme,
              period: _period,
              enabled: _access.canPickDate,
              onChanged: _setPeriod,
            ),
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
            padding: const EdgeInsets.only(right: 5),
            child: ReportExportButton(
              showRollWidthEntries: false,
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
        boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 5)],
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 12,
        children: [
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

  Widget _activeChips(ThemeProvider theme) {
    final min = _filters.amountMin;
    final max = _filters.amountMax;
    if (min == null && max == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Wrap(
          spacing: 6,
          runSpacing: 4,
          children: [
            InputChip(
              label: Text(
                'Amount: ${min != null ? _money(min) : 'Any'}'
                ' - ${max != null ? _money(max) : 'Any'}',
                style: const TextStyle(fontSize: 10),
              ),
              onDeleted: () => _apply(_clearAmount),
              deleteIcon: const Icon(Icons.close, size: 12),
              visualDensity: VisualDensity.compact,
              backgroundColor: theme.lightModeColor.prColor300.withAlpha(25),
              side: BorderSide.none,
            ),
          ],
        ),
      ),
    );
  }

  Widget _notes() {
    final notes = staffReportNotes(period: _period);
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

  Widget _txt(
    ThemeProvider theme,
    String text, {
    bool bold = false,
    Color? color,
    TextAlign? align,
  }) {
    return Text(
      text,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      textAlign: align,
      style: TextStyle(
        fontSize: theme.mobileTexts.b3.fontSize,
        fontWeight: bold ? FontWeight.bold : FontWeight.w500,
        color: color ?? Colors.black87,
      ),
    );
  }

  Widget _badge(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: color.withAlpha(30),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        color: color,
      ),
    ),
  );

  /// "20 litres", the quantity alone, or null.
  static String? _quantityLabel(StaffExpenseRow r) =>
      staffExpenseQuantityLabel(r);

  List<_Col> _columns(ThemeProvider theme) {
    const dash = '—';
    Widget orDash(String? v, {TextAlign align = TextAlign.start}) => _txt(
      theme,
      v ?? dash,
      align: align,
      color: v == null ? Colors.grey : null,
    );

    return [
      _Col(
        label: 'Date',
        width: 140,
        sort: StaffExpensesSortField.createdAt,
        align: TextAlign.start,
        cell:
            (r) => orDash(
              r.createdAt == null ? null : formatDateTime(r.createdAt!),
            ),
        total: (_) => _txt(theme, 'TOTAL', bold: true, align: TextAlign.start),
      ),
      _Col(
        label: 'Time',
        width: 110,
        cell:
            (r) => orDash(
              r.createdAt == null ? null : formatTime(r.createdAt!),
              align: TextAlign.center,
            ),
      ),
      _Col(
        label: 'Name',
        width: 200,
        sort: StaffExpensesSortField.title,
        align: TextAlign.start,
        cell: (r) => _txt(theme, r.title, bold: true, align: TextAlign.start),
        total:
            (t) => _txt(
              theme,
              '${t.count} expense${t.count == 1 ? '' : 's'}',
              bold: true,
              align: TextAlign.start,
            ),
      ),
      _Col(
        label: 'Description',
        width: 260,
        sort: StaffExpensesSortField.description,
        align: TextAlign.start,
        cell: (r) => orDash(r.description),
      ),
      _Col(
        label: 'Quantity',
        width: 130,
        sort: StaffExpensesSortField.quantity,
        cell: (r) => orDash(_quantityLabel(r), align: TextAlign.center),
      ),
      _Col(
        label: 'Amount',
        width: 160,
        sort: StaffExpensesSortField.amount,
        cell: (r) => _txt(theme, _money(r.amount), bold: true),
        total: (t) => _txt(theme, _money(t.amount), bold: true),
      ),
      if (_access.departmentsEnabled)
        _Col(
          label: 'Department',
          width: 170,
          sort: StaffExpensesSortField.department,
          align: TextAlign.start,
          cell: (r) => orDash(r.departmentName),
        ),
    ];
  }

  Alignment _alignment(TextAlign a) =>
      a == TextAlign.start
          ? Alignment.centerLeft
          : (a == TextAlign.end ? Alignment.centerRight : Alignment.center);

  Widget _header(ThemeProvider theme, _Col c) {
    final accent = theme.lightModeColor.prColor300;
    final sort = c.sort;
    final isSorted = sort != null && sort == _sortField;
    final label = Text(
      c.label,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      textAlign: c.align,
      style: TextStyle(
        fontSize: theme.mobileTexts.b3.fontSize,
        fontWeight: FontWeight.bold,
        color: isSorted ? accent : Colors.black87,
      ),
    );
    final content =
        sort == null
            ? label
            : Row(
              mainAxisAlignment:
                  c.align == TextAlign.start
                      ? MainAxisAlignment.start
                      : MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              spacing: 3,
              children: [
                Flexible(child: label),
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
    return SizedBox(
      width: c.width,
      child: InkWell(
        mouseCursor: sort == null ? null : SystemMouseCursors.click,
        onTap: sort == null ? null : () => _setSort(sort),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Align(alignment: _alignment(c.align), child: content),
        ),
      ),
    );
  }

  Widget _cells(List<_Col> cols, Widget Function(_Col c) cell) {
    return Row(
      children: [
        for (final c in cols)
          SizedBox(
            width: c.width,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Align(alignment: _alignment(c.align), child: cell(c)),
            ),
          ),
      ],
    );
  }

  Widget _row(ThemeProvider theme, List<_Col> cols, StaffExpenseRow r, int i) {
    return Material(
      color: i.isEven ? Colors.white : Colors.grey.shade50,
      child: InkWell(
        mouseCursor: SystemMouseCursors.click,
        hoverColor: theme.lightModeColor.prColor300.withAlpha(20),
        onTap: () => _openExpense(r),
        child: Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
          ),
          child: _cells(cols, (c) => c.cell(r)),
        ),
      ),
    );
  }

  Widget _table(ThemeProvider theme, StaffExpensesPage res) {
    final cols = _columns(theme);
    final totalWidth = cols.fold<double>(0, (s, c) => s + c.width);
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
                          child: Row(
                            children: [for (final c in cols) _header(theme, c)],
                          ),
                        ),
                        const Divider(height: 1),
                        Expanded(
                          child: ScrollConfiguration(
                            behavior: ScrollConfiguration.of(
                              context,
                            ).copyWith(scrollbars: false),
                            child: ListView.builder(
                              controller: _vScroll,
                              itemCount: res.rows.length,
                              itemExtent: 52,
                              itemBuilder:
                                  (context, i) =>
                                      _row(theme, cols, res.rows[i], i),
                            ),
                          ),
                        ),
                        const Divider(height: 1, thickness: 1),
                        // Totals of the whole filtered set.
                        Container(
                          height: 46,
                          color: theme.lightModeColor.prColor300.withAlpha(25),
                          child: _cells(
                            cols,
                            (c) =>
                                c.total?.call(res.totals) ??
                                const SizedBox.shrink(),
                          ),
                        ),
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
