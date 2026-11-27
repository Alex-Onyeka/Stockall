import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_customers/temp_customers_class.dart';
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
import 'package:stockall/pages/report/components/report_searchable_dropdown.dart';
import 'package:stockall/pages/report/customer_report/customer_account_transactions/class/customer_account_transactions_logic.dart';
import 'package:stockall/pages/report/customer_report/customer_report_table/class/customer_ledger_export_spec.dart';
import 'package:stockall/pages/report/customer_report/customer_report_table/class/customer_report_export_spec.dart';
import 'package:stockall/pages/report/customer_report/customer_report_table/class/customer_report_table_logic.dart';
import 'package:stockall/pages/report/customer_report/customer_report_table/components/customer_report_table_view.dart';
import 'package:stockall/pages/report/customer_report/customer_reward_earnings/class/customer_reward_earnings_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/components/receipts_report_filter_widgets.dart';
import 'package:stockall/providers/theme_provider.dart';

/// What the Reward Earnings and Account Transactions tables do
/// differently.
class _LedgerConfig {
  final String title;
  final String addedLabel;
  final String deductedLabel;
  final String addedTotalLabel;
  final String deductedTotalLabel;
  final bool showComment;
  final String emptyText;
  final String Function(CustomerLedgerRow row) directionLabel;

  const _LedgerConfig({
    required this.title,
    required this.addedLabel,
    required this.deductedLabel,
    required this.addedTotalLabel,
    required this.deductedTotalLabel,
    required this.showComment,
    required this.emptyText,
    required this.directionLabel,
  });

  static _LedgerConfig of(CustomerLedgerKind kind) {
    switch (kind) {
      case CustomerLedgerKind.reward:
        return const _LedgerConfig(
          title: 'Reward Earnings',
          addedLabel: 'Earned',
          deductedLabel: 'Redeemed',
          addedTotalLabel: 'Earned',
          deductedTotalLabel: 'Redeemed',
          showComment: false,
          emptyText: 'No reward earnings in this period',
          directionLabel: CustomerRewardEarningsTable.directionLabel,
        );
      case CustomerLedgerKind.account:
        return const _LedgerConfig(
          title: 'Account Transactions',
          addedLabel: 'Credit',
          deductedLabel: 'Debit',
          addedTotalLabel: 'Credits',
          deductedTotalLabel: 'Debits',
          showComment: true,
          emptyText: 'No account transactions in this period',
          directionLabel: CustomerAccountTransactionsTable.directionLabel,
        );
    }
  }
}

class _Col {
  final String label;
  final double width;
  final CustomerLedgerSortField sort;
  final TextAlign align;
  final Widget Function(CustomerLedgerRow row) cell;

  const _Col({
    required this.label,
    required this.width,
    required this.sort,
    required this.cell,
    this.align = TextAlign.center,
  });
}

/// Shared body of the Reward Earnings and Account Transactions
/// tables of one customer (desktop + mobile). Only reachable from
/// the Customer Analysis page. Without the View Date permission
/// the period is today.
class CustomerLedgerTableView extends StatefulWidget {
  final CustomerLedgerKind kind;
  final bool isDesktop;
  final TempCustomersClass customer;
  final ReceiptsReportPeriod? initialPeriod;

  /// Null in the app: [CustomerReportEnv.live] is used.
  final CustomerReportEnv? env;

  const CustomerLedgerTableView({
    super.key,
    required this.kind,
    required this.isDesktop,
    required this.customer,
    this.initialPeriod,
    this.env,
  });

  @override
  State<CustomerLedgerTableView> createState() =>
      _CustomerLedgerTableViewState();
}

class _CustomerLedgerTableViewState extends State<CustomerLedgerTableView> {
  late final CustomerReportEnv _env;
  late final _LedgerConfig _config;
  final _filters = CustomerLedgerFilters();
  final _searchCtrl = TextEditingController();
  final _amountMinCtrl = TextEditingController();
  final _amountMaxCtrl = TextEditingController();
  final _hScroll = ScrollController();
  final _vScroll = ScrollController();

  CustomerLedgerSortField _sortField = CustomerLedgerSortField.createdAt;
  bool _ascending = false;
  int _page = 1;
  bool _showFilters = false;
  bool _toolbarIsOpen = false;

  late ReceiptsReportPeriod _period;
  late CustomerReportAccess _access;
  late TempCustomersClass _customer;

  bool _loading = true;
  String? _error;

  CustomerReportBase? _base;
  CustomerLedgerPage? _result;
  List<CustomerReportFilterOption> _staffOptions = [];

  // Every filtered, sorted entry, for the export.
  List<CustomerLedgerRow> _sortedRows = [];
  String _signature = '';

  @override
  void initState() {
    super.initState();
    _env = widget.env ?? CustomerReportEnv.live();
    _config = _LedgerConfig.of(widget.kind);
    _access = _env.access();
    _customer = widget.customer;
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

  String get _uuid => widget.customer.uuid ?? '';

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
    _access = _env.access();
    final source = _env.source();
    final base = CustomerReportBase.build(source: source, access: _access);
    _base = base;
    // The stored customer, so a renamed customer shows.
    _customer = source.customers.firstWhere(
      (c) => _uuid.isNotEmpty && c.uuid == _uuid,
      orElse: () => widget.customer,
    );
    _staffOptions = CustomerLedgerOptions.staff(
      base.ledgerRows
          .where((r) => r.kind == widget.kind && r.customerKey == _uuid)
          .toList(),
    );
    _signature = _env.signature();
  }

  void _recompute() {
    final base = _base;
    if (base == null) return;
    final sorted = CustomerLedgerQuery.filterAndSort(
      base: base,
      customerUuid: _uuid,
      kind: widget.kind,
      period: _period,
      filters: _filters,
      sortField: _sortField,
      ascending: _ascending,
    );
    _sortedRows = sorted;
    final page = CustomerLedgerQuery.paginate(sorted, _page);
    _page = page.page;
    _result = page;
  }

  ReportExportSpec _exportSpec() {
    return customerLedgerExportSpec(
      kind: widget.kind,
      customerName: _customer.name,
      rows: _sortedRows,
      filters: _filters,
      staffOptions: _staffOptions,
      sortField: _sortField,
      ascending: _ascending,
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

  void _setSort(CustomerLedgerSortField f) {
    _apply(() {
      if (_sortField == f) {
        _ascending = !_ascending;
      } else {
        _sortField = f;
        // Text A-Z first; dates and amounts largest first.
        _ascending =
            f == CustomerLedgerSortField.title ||
            f == CustomerLedgerSortField.direction ||
            f == CustomerLedgerSortField.staff ||
            f == CustomerLedgerSortField.comment ||
            f == CustomerLedgerSortField.receipt;
      }
    });
  }

  /// Clears the search and filters only: the period stays.
  void _resetAll() {
    _searchCtrl.clear();
    _amountMinCtrl.clear();
    _amountMaxCtrl.clear();
    _apply(_filters.clearAll);
  }

  void _setPeriod(ReceiptsReportPeriod p) {
    _apply(() => _period = p);
    if (!p.isAllTime) {
      _load(refreshFromStore: false);
    }
  }

  /// Runs a navigation hook, then rebuilds: whatever was changed
  /// on the page that was opened shows here.
  Future<void> _open(Future<void> Function() go) async {
    await go();
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
  // formatting
  // ---------------------------------------------------------------

  String _money(num v) => _env.money(context, v);

  String _signed(double v) => v < 0 ? '-${_money(-v)}' : '+${_money(v)}';

  String _directionLabel(CustomerLedgerDirection d) =>
      d == CustomerLedgerDirection.added
          ? _config.addedLabel
          : _config.deductedLabel;

  // ---------------------------------------------------------------
  // build
  // ---------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = returnTheme(context);
    // Listen, so sales, payments and sync update the table.
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

    final res = _result;
    return Scaffold(
      appBar: appBar(
        context: context,
        title: '${_customer.name}: ${_config.title}',
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
            _activeChips(theme),
            _notes(),
            Expanded(child: _content(theme)),
            if (!_loading && _error == null && res != null) ...[
              _totals(theme, res.totals),
              ReportPager(
                theme: theme,
                page: res.page,
                totalPages: res.totalPages,
                totalCount: res.totalCount,
                firstIndex: res.firstIndex,
                lastIndex: res.lastIndex,
                itemLabel: 'entries',
                onPage: _goToPage,
              ),
            ],
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
    if (res == null || res.totalCount == 0) {
      final hasFilters = _filters.hasAnything;
      return Padding(
        padding: const EdgeInsets.only(top: 60),
        child: EmptyWidgetDisplayOnly(
          title: hasFilters ? 'No Matching Entries' : 'Empty List',
          subText:
              hasFilters
                  ? 'No entry matches your search and filters'
                  : _config.emptyText,
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
                      hintText: 'Search title, comment or staff',
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
          ReportLabeledField(
            label: 'Type',
            width: 200,
            child: ReportSearchableDropdown<CustomerLedgerDirection?>(
              title: 'Type',
              value: _filters.direction,
              showSearch: false,
              options: [
                const ReportSearchableOption(value: null, label: 'All types'),
                for (final d in CustomerLedgerDirection.values)
                  ReportSearchableOption<CustomerLedgerDirection?>(
                    value: d,
                    label: _directionLabel(d),
                  ),
              ],
              onChanged: (v) => _apply(() => _filters.direction = v),
              theme: theme,
            ),
          ),
          ReportLabeledField(
            label: 'Staff',
            width: 220,
            child: ReportSearchableDropdown<String?>(
              title: 'Staff',
              value: _filters.staffKey,
              options: [
                const ReportSearchableOption(value: null, label: 'All staff'),
                for (final o in _staffOptions)
                  ReportSearchableOption<String?>(value: o.key, label: o.label),
              ],
              onChanged: (v) => _apply(() => _filters.staffKey = v),
              theme: theme,
              searchHint: 'Search staff...',
            ),
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

  Widget _activeChips(ThemeProvider theme) {
    final chips = <Widget>[];
    void chip(String text, VoidCallback clear) {
      chips.add(
        InputChip(
          label: Text(text, style: const TextStyle(fontSize: 10)),
          onDeleted: () => _apply(clear),
          deleteIcon: const Icon(Icons.close, size: 12),
          visualDensity: VisualDensity.compact,
          backgroundColor: theme.lightModeColor.prColor300.withAlpha(25),
          side: BorderSide.none,
        ),
      );
    }

    final direction = _filters.direction;
    if (direction != null) {
      chip(
        'Type: ${_directionLabel(direction)}',
        () => _filters.direction = null,
      );
    }
    final staff = _filters.staffKey;
    if (staff != null) {
      var label = 'Not Set';
      for (final o in _staffOptions) {
        if (o.key == staff) label = o.label;
      }
      chip('Staff: $label', () => _filters.staffKey = null);
    }
    final min = _filters.amountMin;
    final max = _filters.amountMax;
    if (min != null || max != null) {
      chip('Amount: ${min != null ? _money(min) : 'Any'}'
          ' - ${max != null ? _money(max) : 'Any'}', () {
        _filters.amountMin = null;
        _filters.amountMax = null;
        _amountMinCtrl.clear();
        _amountMaxCtrl.clear();
      });
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
    final notes = customerReportNotes(period: _period);
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
    return tooltip == null ? t : Tooltip(message: tooltip, child: t);
  }

  Widget _badge(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: color.withAlpha(30),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      text,
      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
    ),
  );

  List<_Col> _columns(ThemeProvider theme) {
    const dash = '—';
    final green = Colors.green.shade700;
    final red = theme.lightModeColor.errorColor200;
    Widget balance(double? v) =>
        v == null
            ? _txt(theme, dash, color: Colors.grey)
            : _txt(theme, _money(v));

    return [
      _Col(
        label: 'Date',
        width: 130,
        sort: CustomerLedgerSortField.createdAt,
        align: TextAlign.start,
        cell:
            (r) => _txt(
              theme,
              r.createdAt == null ? dash : formatDateTime(r.createdAt!),
              bold: true,
              align: TextAlign.start,
            ),
      ),
      _Col(
        label: 'Time',
        width: 110,
        sort: CustomerLedgerSortField.createdAt,
        cell:
            (r) => _txt(
              theme,
              r.createdAt == null ? dash : formatTime(r.createdAt!),
            ),
      ),
      _Col(
        label: 'Title',
        width: 200,
        sort: CustomerLedgerSortField.title,
        align: TextAlign.start,
        cell: (r) => _txt(theme, r.title, align: TextAlign.start),
      ),
      _Col(
        label: 'Type',
        width: 130,
        sort: CustomerLedgerSortField.direction,
        cell: (r) => _badge(_config.directionLabel(r), r.isAdd ? green : red),
      ),
      _Col(
        label: 'Amount',
        width: 150,
        sort: CustomerLedgerSortField.amount,
        cell:
            (r) => _txt(
              theme,
              _signed(r.signedAmount),
              bold: true,
              color: r.isAdd ? green : red,
            ),
      ),
      _Col(
        label: 'Old Balance',
        width: 140,
        sort: CustomerLedgerSortField.oldBalance,
        cell: (r) => balance(r.oldBalance),
      ),
      _Col(
        label: 'New Balance',
        width: 140,
        sort: CustomerLedgerSortField.newBalance,
        cell: (r) => balance(r.newBalance),
      ),
      _Col(
        label: 'Staff',
        width: 160,
        sort: CustomerLedgerSortField.staff,
        align: TextAlign.start,
        cell:
            (r) => _txt(
              theme,
              r.staffName ?? 'Not Set',
              align: TextAlign.start,
              color: r.staffName == null ? Colors.grey : null,
            ),
      ),
      if (_config.showComment)
        _Col(
          label: 'Comment',
          width: 200,
          sort: CustomerLedgerSortField.comment,
          align: TextAlign.start,
          cell:
              (r) => _txt(
                theme,
                r.comment ?? dash,
                align: TextAlign.start,
                color: r.comment == null ? Colors.grey : null,
                tooltip: (r.comment?.length ?? 0) > 40 ? r.comment : null,
              ),
        ),
      _Col(
        label: 'Linked Receipt',
        width: 150,
        sort: CustomerLedgerSortField.receipt,
        cell: (r) {
          final receipt = r.receipt;
          if (receipt == null) {
            return _txt(theme, dash, color: Colors.grey);
          }
          return InkWell(
            key: ValueKey('ledger-receipt-${r.uuid}'),
            mouseCursor: SystemMouseCursors.click,
            onTap: () => _open(() => _env.openReceipt(context, receipt)),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(
                r.receiptDisplayId!,
                style: _cellStyle(
                  theme,
                  bold: true,
                  color: theme.lightModeColor.prColor300,
                ).copyWith(decoration: TextDecoration.underline),
              ),
            ),
          );
        },
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
    return SizedBox(
      width: width,
      child: InkWell(
        mouseCursor: SystemMouseCursors.click,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Align(alignment: _alignment(align), child: content),
        ),
      ),
    );
  }

  Widget _row(
    ThemeProvider theme,
    List<_Col> cols,
    CustomerLedgerRow r,
    int i,
  ) {
    return Material(
      key: ValueKey('ledger-row-${r.uuid}'),
      color: i.isEven ? Colors.white : Colors.grey.shade50,
      child: InkWell(
        mouseCursor: SystemMouseCursors.click,
        hoverColor: theme.lightModeColor.prColor300.withAlpha(20),
        onTap: () => _open(() => _env.openLedgerEntry(context, r.entry)),
        child: Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
          ),
          child: Row(
            children: [
              for (final c in cols)
                SizedBox(
                  width: c.width,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
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

  /// Totals of the whole filtered set.
  Widget _totals(ThemeProvider theme, CustomerLedgerTotals t) {
    final green = Colors.green.shade700;
    final red = theme.lightModeColor.errorColor200;
    Widget figure(String id, String label, String value, Color? color) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 6,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: theme.mobileTexts.b4.fontSize,
              color: Colors.grey.shade700,
            ),
          ),
          Text(
            value,
            key: ValueKey('ledger-total-$id'),
            style: _cellStyle(theme, bold: true, color: color),
          ),
        ],
      );
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: theme.lightModeColor.prColor300.withAlpha(25),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Wrap(
        spacing: 18,
        runSpacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text('TOTAL (${t.count})', style: _cellStyle(theme, bold: true)),
          figure('added', _config.addedTotalLabel, _money(t.added), green),
          figure(
            'deducted',
            _config.deductedTotalLabel,
            _money(t.deducted),
            red,
          ),
          figure(
            'net',
            'Net',
            _signed(t.net),
            t.net < 0 ? red : (t.net > 0 ? green : null),
          ),
        ],
      ),
    );
  }

  Widget _table(ThemeProvider theme, CustomerLedgerPage res) {
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
                            children: [
                              for (final c in cols)
                                _header(
                                  theme,
                                  label: c.label,
                                  width: c.width,
                                  align: c.align,
                                  isSorted: c.sort == _sortField,
                                  ascending: _ascending,
                                  onTap: () => _setSort(c.sort),
                                ),
                            ],
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
