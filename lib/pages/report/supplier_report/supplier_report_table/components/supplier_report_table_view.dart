import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_suppliers/suppliers_class.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/local_database/suppliers_func/suppliers_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/report/components/export/report_export_button.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/report_pager.dart';
import 'package:stockall/pages/report/components/report_pill.dart';
import 'package:stockall/pages/report/purchase_report/purchase_report_table/class/purchase_report_export_spec.dart';
import 'package:stockall/pages/report/purchase_report/purchase_report_table/class/purchase_report_table_logic.dart';
import 'package:stockall/pages/report/purchase_report/purchase_report_table/components/purchase_report_table_view.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/components/receipts_report_filter_widgets.dart';
import 'package:stockall/pages/report/supplier_report/supplier_analysis/supplier_analysis_page.dart';
import 'package:stockall/pages/report/supplier_report/supplier_report_table/class/supplier_report_export_spec.dart';
import 'package:stockall/pages/report/supplier_report/supplier_report_table/class/supplier_report_table_logic.dart';
import 'package:stockall/pages/report/supplier_report/supplier_report_table/components/supplier_report_filter_widgets.dart';
import 'package:stockall/providers/theme_provider.dart';

/// Everything the supplier pages read from the app, on top of the
/// Purchase Report's [purchaseEnv] (purchases, scope, loading,
/// money, permissions). [SupplierReportEnv.live] uses the
/// providers; tests pass their own.
class SupplierReportEnv {
  final PurchaseReportEnv purchaseEnv;

  /// Every loaded supplier, before the department scope.
  final List<SuppliersClass> Function() suppliers;
  final bool Function() canViewAllDepartments;
  final String? Function() currentDepartmentUuid;

  /// Changes whenever purchases, suppliers or the user's scope do.
  final String Function() signature;

  /// Opens the Supplier Analysis of [row] on [period]. Null in
  /// the app: the table pushes `SupplierAnalysisPage`.
  final Future<void> Function(
    BuildContext context,
    SupplierReportRow row,
    ReceiptsReportPeriod period,
  )?
  openAnalysis;

  const SupplierReportEnv({
    required this.purchaseEnv,
    required this.suppliers,
    required this.canViewAllDepartments,
    required this.currentDepartmentUuid,
    required this.signature,
    this.openAnalysis,
  });

  /// Suppliers the user may see (`suppliersMain()` rule).
  List<SuppliersClass> scopedSuppliers() =>
      SupplierReportAccess.scope(
        suppliers: suppliers(),
        departmentsEnabled: purchaseEnv.departmentsEnabled(),
        canViewAllDepartments: canViewAllDepartments(),
        currentDepartmentUuid: currentDepartmentUuid(),
      );

  factory SupplierReportEnv.live() {
    final purchaseEnv = PurchaseReportEnv.live();
    List<SuppliersClass> suppliers() {
      final loaded = returnSuppliersProvider().suppliers;
      if (loaded.isNotEmpty) return loaded;
      try {
        return SuppliersFunc().getSuppliers();
      } catch (_) {
        return const [];
      }
    }

    String? currentDepartmentUuid() =>
        returnDepartmentProvider().currentDepartment()?.uuid;

    return SupplierReportEnv(
      purchaseEnv: purchaseEnv,
      suppliers: suppliers,
      canViewAllDepartments:
          () => authorization(
            authorized: Authorizations().viewAllDepartments,
          ),
      currentDepartmentUuid: currentDepartmentUuid,
      signature: () {
        final all = suppliers();
        int latest = 0;
        for (final s in all) {
          final t =
              (s.updatedAt ?? s.createdAt).millisecondsSinceEpoch;
          if (t > latest) latest = t;
        }
        return '${purchaseEnv.signature()}|${all.length}|'
            '$latest|${currentDepartmentUuid()}';
      },
    );
  }
}

class _Col {
  final String label;
  final double width;
  final SupplierSortField? sort;
  final TextAlign align;
  final Widget Function(SupplierReportRow row) cell;

  /// Cell of the totals row; empty when null.
  final Widget Function(SupplierReportPage res)? total;

  const _Col({
    required this.label,
    required this.width,
    required this.cell,
    this.sort,
    this.align = TextAlign.center,
    this.total,
  });
}

/// Shared body of the Supplier Report table page (desktop +
/// mobile). Tapping a supplier opens its analysis with the
/// current period; coming back rebuilds.
class SupplierReportTableView extends StatefulWidget {
  final bool isDesktop;
  final SupplierReportFilters? initialFilters;
  final ReceiptsReportPeriod? initialPeriod;

  /// Null in the app: [SupplierReportEnv.live] is used.
  final SupplierReportEnv? env;

  const SupplierReportTableView({
    super.key,
    required this.isDesktop,
    this.initialFilters,
    this.initialPeriod,
    this.env,
  });

  @override
  State<SupplierReportTableView> createState() =>
      _SupplierReportTableViewState();
}

class _SupplierReportTableViewState
    extends State<SupplierReportTableView> {
  late final SupplierReportEnv _env;
  late final SupplierReportTableState _state;
  final _searchCtrl = TextEditingController();
  final _hScroll = ScrollController();
  final _vScroll = ScrollController();

  bool _showFilters = false;
  bool _toolbarIsOpen = false;

  late ReceiptsReportPeriod _period;

  bool _loading = true;
  String? _error;

  List<PurchaseReportRow> _purchaseRows = [];
  List<SuppliersClass> _allSuppliers = [];
  List<SuppliersClass> _scopedSuppliers = [];

  /// Every supplier row of the period, before filters (the
  /// country and state choices).
  List<SupplierReportRow> _rows = [];
  SupplierReportPage? _result;
  String _signature = '';

  // Every filtered, sorted row, for the export.
  List<SupplierReportRow> _sortedRows = [];

  PurchaseReportEnv get _purchaseEnv => _env.purchaseEnv;
  SupplierReportFilters get _filters => _state.filters;

  @override
  void initState() {
    super.initState();
    _env = widget.env ?? SupplierReportEnv.live();
    _state = SupplierReportTableState(
      filters: widget.initialFilters?.copy(),
    );
    _searchCtrl.text = _filters.search;
    _period = supplierReportInitialPeriod(
      canPickDate: _purchaseEnv.canPickDate(),
      initial: widget.initialPeriod,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load(refreshFromStore: false);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _hScroll.dispose();
    _vScroll.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------
  // data
  // ---------------------------------------------------------------

  bool get _departmentsEnabled => _purchaseEnv.departmentsEnabled();

  Future<void> _load({required bool refreshFromStore}) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _purchaseEnv.loadWithPeriod(
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
    _purchaseRows = PurchaseReportRowBuilder.buildAll(
      purchases: _purchaseEnv.purchases(),
      legacyLines: _purchaseEnv.legacyLines(),
      supplierNames: _purchaseEnv.supplierNames(),
      pendingDeletedUuids: _purchaseEnv.pendingDeletedUuids(),
    );
    _allSuppliers = _env.suppliers();
    _scopedSuppliers = _env.scopedSuppliers();
    _signature = _env.signature();
  }

  void _recompute() {
    _rows = SupplierReportRowBuilder.build(
      suppliers: _scopedSuppliers,
      allSuppliers: _allSuppliers,
      purchaseRows: _purchaseRows,
      period: _period,
      departmentsEnabled: _departmentsEnabled,
    );
    final sorted = SupplierReportQuery.filterAndSort(
      rows: _rows,
      filters: _filters,
      sortField: _state.sortField,
      ascending: _state.ascending,
    );
    _sortedRows = sorted;
    final page = SupplierReportQuery.paginate(sorted, _state.page);
    _state.page = page.page;
    _result = page;
  }

  ReportExportSpec _exportSpec() {
    return supplierReportExportSpec(
      rows: _sortedRows,
      allRows: _rows,
      state: _state,
      period: _period,
      currency: currencySymbol(context: context),
    );
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
    final res = _result;
    if (res == null ||
        p < 1 ||
        p > res.totalPages ||
        p == res.page) {
      return;
    }
    _apply(() => _state.page = p, resetPage: false);
    if (_vScroll.hasClients) {
      _vScroll.jumpTo(0);
    }
  }

  void _setSort(SupplierSortField f) =>
      _apply(() => _state.setSort(f), resetPage: false);

  /// Clears the search and filters only: the period and sort stay.
  void _resetAll() {
    _searchCtrl.clear();
    _apply(_state.resetAll);
  }

  void _setPeriod(ReceiptsReportPeriod p) {
    _apply(() => _period = p);
    if (!p.isAllTime) {
      _load(refreshFromStore: false);
    }
  }

  Future<void> _pushAnalysis(
    BuildContext context,
    SupplierReportRow row,
    ReceiptsReportPeriod period,
  ) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => SupplierAnalysisPage(
              supplierKey: row.key,
              initialPeriod: period,
              env: _env,
            ),
      ),
    );
  }

  Future<void> _openAnalysis(SupplierReportRow row) async {
    final open = _env.openAnalysis ?? _pushAnalysis;
    await open(context, row, _period);
    // Picks up payments or edits made from the analysis.
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

  String _money(num v) => _purchaseEnv.money(context, v);

  // ---------------------------------------------------------------
  // build
  // ---------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = returnTheme(context);
    // Listen, so purchases, payments, suppliers and sync update
    // the table.
    _purchaseEnv.listen(context);

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
        title: 'Supplier Report',
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
            SupplierReportFilterChips(
              theme: theme,
              filters: _filters,
              rows: _rows,
              onApply: _apply,
            ),
            _notes(),
            Expanded(child: _content(theme)),
            if (!_loading && _error == null && res != null)
              ReportPager(
                theme: theme,
                page: res.page,
                totalPages: res.totalPages,
                totalCount: res.totalCount,
                firstIndex: res.firstIndex,
                lastIndex: res.lastIndex,
                itemLabel: 'suppliers',
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
    if (res == null || res.totalCount == 0) {
      final hasFilters = _filters.hasAnything;
      return Padding(
        padding: const EdgeInsets.only(top: 60),
        child: EmptyWidgetDisplayOnly(
          title:
              hasFilters ? 'No Matching Suppliers' : 'Empty List',
          subText:
              hasFilters
                  ? 'No supplier matches your search and filters'
                  : 'You have not added any supplier yet',
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
                    onChanged:
                        (v) => _apply(() => _filters.search = v),
                    decoration: InputDecoration(
                      hintText:
                          'Search name, phone, email or address',
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
            enabled: _purchaseEnv.canPickDate(),
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
          Padding(
            padding: const EdgeInsets.only(right: 5),
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
        children: supplierFilterFields(
          theme: theme,
          filters: _filters,
          rows: _rows,
          onApply: _apply,
        ),
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
      style: TextStyle(
        fontSize: theme.mobileTexts.b3.fontSize,
        fontWeight: bold ? FontWeight.bold : FontWeight.w500,
        color: color ?? Colors.black87,
      ),
    );
    return tooltip == null
        ? t
        : Tooltip(message: tooltip, child: t);
  }

  /// [text], or a grey "—" when not set.
  Widget _orDash(
    ThemeProvider theme,
    String? text, {
    TextAlign align = TextAlign.start,
  }) =>
      text == null
          ? _txt(theme, '—', color: Colors.grey, align: align)
          : _txt(theme, text, align: align, tooltip: text);

  Widget _badge(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 8,
      vertical: 3,
    ),
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

  Widget _nameCell(ThemeProvider theme, SupplierReportRow r) {
    final name = _txt(
      theme,
      r.label,
      bold: true,
      align: TextAlign.start,
      color: r.name == null ? Colors.grey : null,
    );
    if (!r.isDeleted) return name;
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 6,
      children: [
        Flexible(child: name),
        _badge(
          supplierDeletedLabel,
          theme.lightModeColor.errorColor200,
        ),
      ],
    );
  }

  List<_Col> _columns(ThemeProvider theme) {
    Widget bold(String text) => _txt(theme, text, bold: true);

    return [
      _Col(
        label: 'Name',
        width: 260,
        sort: SupplierSortField.name,
        align: TextAlign.start,
        cell: (r) => _nameCell(theme, r),
        total:
            (_) => _txt(
              theme,
              'TOTAL',
              bold: true,
              align: TextAlign.start,
            ),
      ),
      _Col(
        label: 'Phone',
        width: 150,
        sort: SupplierSortField.phone,
        align: TextAlign.start,
        cell: (r) => _orDash(theme, r.phone),
      ),
      _Col(
        label: 'Email',
        width: 210,
        sort: SupplierSortField.email,
        align: TextAlign.start,
        cell: (r) => _orDash(theme, r.email),
      ),
      _Col(
        label: 'Address',
        width: 280,
        sort: SupplierSortField.address,
        align: TextAlign.start,
        cell: (r) => _orDash(theme, r.fullAddress),
      ),
      _Col(
        label: 'Purchases',
        width: 110,
        sort: SupplierSortField.purchases,
        cell: (r) => _txt(theme, '${r.purchaseCount}'),
        total: (t) => bold('${t.totalPurchases}'),
      ),
      _Col(
        label: 'Spend',
        width: 150,
        sort: SupplierSortField.spend,
        cell: (r) => bold(_money(r.spend)),
        total: (t) => bold(_money(t.totalSpend)),
      ),
      _Col(
        label: 'Paid',
        width: 140,
        sort: SupplierSortField.paid,
        cell: (r) => _txt(theme, _money(r.paid)),
        total: (t) => bold(_money(t.totalPaid)),
      ),
      _Col(
        label: 'Balance owed',
        width: 150,
        sort: SupplierSortField.balance,
        cell:
            (r) => _txt(
              theme,
              _money(r.balance),
              color:
                  r.hasBalance
                      ? theme.lightModeColor.errorColor200
                      : null,
            ),
        total: (t) => bold(_money(t.totalBalance)),
      ),
      _Col(
        label: 'Last purchase',
        width: 140,
        sort: SupplierSortField.lastPurchase,
        cell:
            (r) => _orDash(
              theme,
              r.lastPurchase == null
                  ? null
                  : formatDateTime(r.lastPurchase!),
              align: TextAlign.center,
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

  Widget _header(ThemeProvider theme, _Col c) {
    final accent = theme.lightModeColor.prColor300;
    final sortable = c.sort != null;
    final isSorted = sortable && c.sort == _state.sortField;
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
        if (sortable)
          Icon(
            isSorted
                ? (_state.ascending
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
      child: Align(alignment: _alignment(c.align), child: content),
    );
    return SizedBox(
      width: c.width,
      child:
          !sortable
              ? padded
              : InkWell(
                key: ValueKey('supplier-sort-${c.sort!.name}'),
                mouseCursor: SystemMouseCursors.click,
                onTap: () => _setSort(c.sort!),
                child: padded,
              ),
    );
  }

  Widget _cells(
    List<_Col> cols,
    Widget Function(_Col c) cell,
  ) {
    return Row(
      children: [
        for (final c in cols)
          SizedBox(
            width: c.width,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Align(
                alignment: _alignment(c.align),
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
    SupplierReportRow r,
    int i,
  ) {
    return Material(
      color: i.isEven ? Colors.white : Colors.grey.shade50,
      child: InkWell(
        key: ValueKey('supplier-row-${r.key}'),
        mouseCursor: SystemMouseCursors.click,
        hoverColor: theme.lightModeColor.prColor300.withAlpha(20),
        onTap: () => _openAnalysis(r),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade100),
            ),
          ),
          child: _cells(cols, (c) => c.cell(r)),
        ),
      ),
    );
  }

  Widget _table(ThemeProvider theme, SupplierReportPage res) {
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
                          child: Row(
                            children: [
                              for (final c in cols)
                                _header(theme, c),
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
                        // Totals of the whole filtered set, not
                        // just this page.
                        Container(
                          key: const ValueKey('supplier-totals'),
                          height: 46,
                          color: theme.lightModeColor.prColor300
                              .withAlpha(25),
                          child: _cells(
                            cols,
                            (c) =>
                                c.total?.call(res) ??
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
