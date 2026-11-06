import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:stockall/classes/checkout_response.dart';
import 'package:stockall/classes/temp_customers/temp_customers_class.dart';
import 'package:stockall/classes/temp_departments_class/department_class.dart';
import 'package:stockall/classes/temp_invoices/temp_invoices.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/date_picker_function.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/refresh_functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/report/components/export/report_export_button.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/report_group_by.dart';
import 'package:stockall/pages/report/invoice_report/invoice_report_table/class/invoice_report_export_spec.dart';
import 'package:stockall/pages/report/invoice_report/invoice_report_table/class/invoice_report_table_logic.dart';
import 'package:stockall/pages/sales/make_sales/receipt_page/receipt_page.dart';
import 'package:stockall/providers/theme_provider.dart';

class _TableCol {
  final String label;
  final double width;
  final InvoiceSortField? sort;
  final TextAlign align;
  final Widget Function(InvoiceReportRow row, int index)
  cell;

  const _TableCol({
    required this.label,
    required this.width,
    required this.cell,
    this.sort,
    this.align = TextAlign.center,
  });
}

class _GroupCol {
  final String label;
  final double width;
  final InvoiceGroupSortField sort;
  final TextAlign align;
  final Widget Function(InvoiceReportGroupRow row) cell;
  final Widget Function(InvoiceReportGroupPage res) total;

  const _GroupCol({
    required this.label,
    required this.width,
    required this.sort,
    required this.cell,
    required this.total,
    this.align = TextAlign.center,
  });
}

class InvoiceReportTableView extends StatefulWidget {
  final bool isDesktop;
  final InvoiceReportFilters? initialFilters;

  const InvoiceReportTableView({
    super.key,
    required this.isDesktop,
    this.initialFilters,
  });

  @override
  State<InvoiceReportTableView> createState() =>
      _InvoiceReportTableViewState();
}

class _InvoiceReportTableViewState
    extends State<InvoiceReportTableView> {
  final InvoiceReportFilters _filters =
      InvoiceReportFilters();
  final TextEditingController _searchCtrl =
      TextEditingController();
  final TextEditingController _totalMinCtrl =
      TextEditingController();
  final TextEditingController _totalMaxCtrl =
      TextEditingController();
  final TextEditingController _paidMinCtrl =
      TextEditingController();
  final TextEditingController _paidMaxCtrl =
      TextEditingController();
  final TextEditingController _balanceMinCtrl =
      TextEditingController();
  final TextEditingController _balanceMaxCtrl =
      TextEditingController();
  final TextEditingController _profitMinCtrl =
      TextEditingController();
  final TextEditingController _profitMaxCtrl =
      TextEditingController();

  final ScrollController _hScroll = ScrollController();
  final ScrollController _vScroll = ScrollController();

  InvoiceSortField _sortField = InvoiceSortField.createdAt;
  bool _ascending = false;
  int _page = 1;
  bool _showFilters = false;
  bool _toolbarIsOpen = false;

  DateTimeRange? _range;

  // Grouping has its own sort, so the invoice sort is kept.
  ReportGroupBy _groupBy = ReportGroupBy.off;
  InvoiceGroupSortField _groupSortField =
      InvoiceGroupSortField.total;
  bool _groupAscending = false;
  InvoiceReportGroupPage? _groupResult;

  bool get _grouped => _groupBy != ReportGroupBy.off;

  bool _loading = true;
  String? _error;

  List<InvoiceReportRow> _baseRows = [];
  InvoiceReportPageResult? _result;

  // Every filtered, sorted row and group, for the export.
  List<InvoiceReportRow> _sortedRows = [];
  List<InvoiceReportGroupRow> _sortedGroups = [];
  String _signature = '';

  @override
  void initState() {
    super.initState();
    if (widget.initialFilters != null) {
      _filters.copyFrom(widget.initialFilters!);
      _range = _filters.dateRange;
      if (_filters.search.isNotEmpty) {
        _searchCtrl.text = _filters.search;
      }
      if (_filters.hasAnything) {
        _showFilters = true;
      }
    } else {
      _range = null;
      _filters.dateRange = null;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load(refreshFromStore: false);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _totalMinCtrl.dispose();
    _totalMaxCtrl.dispose();
    _paidMinCtrl.dispose();
    _paidMaxCtrl.dispose();
    _balanceMinCtrl.dispose();
    _balanceMaxCtrl.dispose();
    _profitMinCtrl.dispose();
    _profitMaxCtrl.dispose();
    _hScroll.dispose();
    _vScroll.dispose();
    super.dispose();
  }

  bool get _departmentsEnabled =>
      shopSingle()?.manageDepartments == true;
  bool get _bulkSaleEnabled =>
      shopSingle()?.bulkSale == true;
  bool get _canSeeCost => authorization(
    authorized: Authorizations().manageCostPrice,
  );

  Future<void> _load({
    required bool refreshFromStore,
  }) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final currentShop = shopSingle();
      final sid = currentShop?.shopId;

      if (refreshFromStore && sid != null) {
        await RefreshFunctions(
          context,
        ).refreshInvoices(context);
        await RefreshFunctions(
          context,
        ).refreshReceipts(context);
        await RefreshFunctions(
          context,
        ).refreshCustomers(context);
      } else if (sid != null) {
        await returnInvoicesProvider().loadInvoicesOffline(
          sid,
        );
        await returnReceiptProviderSingle()
            .loadReceiptsOffline(sid);
        await returnCustomersSingle()
            .fetchCustomersOffline();
      }

      _rebuildBase();
      _recompute();

      if (mounted) {
        setState(() => _loading = false);
      }
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
    final invs = returnInvoicesProvider().invoicesMain;
    final receipts = returnReceiptProviderSingle().receipts;
    return '${invs.length}|${receipts.length}';
  }

  void _rebuildBase() {
    final currentShop = shopSingle();
    final sid = currentShop?.shopId ?? 0;

    // Filter invoices by selected shop
    final shopInvoices =
        returnInvoicesProvider().invoicesMain
            .where((inv) => inv.shopId == sid)
            .toList();

    // Enforce department access-control rules if user is restricted to a department
    List<TempInvoice> scopedInvoices = shopInvoices;
    if (_departmentsEnabled &&
        !authorization(
          authorized: Authorizations().viewAllDepartments,
        )) {
      final currentDeptUuid =
          returnDepartmentProvider()
              .currentDepartment()
              ?.uuid;
      if (currentDeptUuid != null) {
        scopedInvoices =
            shopInvoices
                .where(
                  (inv) =>
                      inv.departmentUuidNew ==
                      currentDeptUuid,
                )
                .toList();
      }
    }

    final allReceipts =
        returnReceiptProviderSingle().receipts;
    final allProductSales =
        returnReceiptProviderSingle().mainSales;
    final customers = returnCustomersSingle().customers;
    final Map<String, TempCustomersClass> customerMap = {
      for (final c in customers)
        if (c.uuid != null && c.uuid!.isNotEmpty)
          c.uuid!: c,
    };

    _baseRows = InvoiceReportRowBuilder.buildAll(
      invoices: scopedInvoices,
      allReceipts: allReceipts,
      allProductSales: allProductSales,
      customerMap: customerMap,
      context: context,
    );
    _signature = _sourceSignature();
  }

  void _recompute() {
    final sorted = InvoiceReportQuery.filterAndSort(
      rows: _baseRows,
      filters: _filters,
      sortField: _sortField,
      ascending: _ascending,
      departmentsEnabled: _departmentsEnabled,
      bulkSaleEnabled: _bulkSaleEnabled,
      costFilterAllowed: _canSeeCost,
    );
    _sortedRows = sorted;

    if (_grouped) {
      final groups = InvoiceReportGrouping.sort(
        InvoiceReportGrouping.build(sorted, _groupBy),
        field: _groupSortField,
        ascending: _groupAscending,
      );
      _sortedGroups = groups;
      final page = InvoiceReportGrouping.paginate(
        groups,
        _page,
      );
      _page = page.page;
      _groupResult = page;
    } else {
      final page = InvoiceReportQuery.paginate(
        sorted,
        _page,
      );
      _page = page.page;
      _result = page;
    }
  }

  ReportExportSpec _exportSpec() {
    return invoiceReportExportSpec(
      rows: _sortedRows,
      groups: _sortedGroups,
      baseRows: _baseRows,
      groupBy: _groupBy,
      filters: _filters,
      departmentNames: {
        for (final d in returnDepartmentProvider().departments)
          d.uuid: d.name,
      },
      sortField: _sortField,
      ascending: _ascending,
      groupSortField: _groupSortField,
      groupAscending: _groupAscending,
      currency: currencySymbol(context: context),
      departmentsEnabled: _departmentsEnabled,
      bulkSaleEnabled: _bulkSaleEnabled,
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

  void _setSort(InvoiceSortField f) {
    _apply(() {
      if (_sortField == f) {
        _ascending = !_ascending;
      } else {
        _sortField = f;
        _ascending = true;
      }
    });
  }

  void _setGroupSort(InvoiceGroupSortField f) {
    _apply(() {
      if (_groupSortField == f) {
        _groupAscending = !_groupAscending;
      } else {
        _groupSortField = f;
        // Names A-Z first; counts and amounts largest first.
        _groupAscending = f == InvoiceGroupSortField.name;
      }
    });
  }

  void _resetAll() {
    _searchCtrl.clear();
    _totalMinCtrl.clear();
    _totalMaxCtrl.clear();
    _paidMinCtrl.clear();
    _paidMaxCtrl.clear();
    _balanceMinCtrl.clear();
    _balanceMaxCtrl.clear();
    _profitMinCtrl.clear();
    _profitMaxCtrl.clear();

    _apply(() {
      _filters.clearAll();
      _range = null;
      _filters.dateRange = null;
    });
  }

  double? _num(String v) =>
      double.tryParse(v.replaceAll(',', '').trim());

  void _pickRange() {
    final theme = returnTheme(context, listen: false);
    mainDatePicker(
      context: context,
      theme: theme,
      singleDate: (date) {
        if (date == null) return;
        final day = DateTime(
          date.year,
          date.month,
          date.day,
        );
        _apply(() {
          _range = DateTimeRange(start: day, end: day);
          _filters.dateRange = _range;
        });
      },
      rangeDate: (firstDate, lastDate) {
        if (firstDate == null) return;
        DateTime s = DateTime(
          firstDate.year,
          firstDate.month,
          firstDate.day,
        );
        final endBase = lastDate ?? firstDate;
        DateTime e = DateTime(
          endBase.year,
          endBase.month,
          endBase.day,
        );
        if (e.isBefore(s)) {
          final temp = s;
          s = e;
          e = temp;
        }
        _apply(() {
          _range = DateTimeRange(start: s, end: e);
          _filters.dateRange = _range;
        });
      },
    );
  }

  DateTime get _businessToday {
    final t = resolveBusinessDate(DateTime.now());
    return DateTime(t.year, t.month, t.day);
  }

  bool get _isDateToday {
    if (_filters.dateRange == null || _range == null)
      return false;
    final t = _businessToday;
    return _range!.start.year == t.year &&
        _range!.start.month == t.month &&
        _range!.start.day == t.day &&
        _range!.end.year == t.year &&
        _range!.end.month == t.month &&
        _range!.end.day == t.day;
  }

  void _clearDate() {
    _apply(() {
      _range = null;
      _filters.dateRange = null;
    });
  }

  String _money(num v) =>
      formatMoneyBig(amount: v, context: context);

  String get _rangeLabel {
    if (_filters.dateRange == null || _range == null)
      return 'All Time';
    final s = _range!.start;
    final e = _range!.end;
    final same =
        s.year == e.year &&
        s.month == e.month &&
        s.day == e.day;
    return same
        ? formatDateTime(s)
        : '${formatDateTime(s)} - ${formatDateTime(e)}';
  }

  void _openInvoiceDetails(InvoiceReportRow row) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ReceiptPage(
              response: CheckoutResponse(
                invoice: row.invoice,
              ),
              isMain: false,
            ),
      ),
    ).then((_) {
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

  @override
  Widget build(BuildContext context) {
    final theme = returnTheme(context);

    // Pick up updates made to local database
    if (!_loading && _error == null) {
      final sig = _sourceSignature();
      if (sig != _signature) {
        _rebuildBase();
        try {
          _recompute();
        } catch (e) {
          _error = e.toString();
        }
      }
    }

    return Scaffold(
      appBar: appBar(
        context: context,
        title: 'Invoice Report Table',
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
                        fontSize:
                            theme.mobileTexts.b3.fontSize,
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
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 8),
            _toolbar(theme),
            if (_showFilters) _filterPanel(theme),
            _activeChips(theme),
            Expanded(child: _content(theme)),
            if (!_loading &&
                _error == null &&
                (_grouped
                    ? _groupResult != null
                    : _result != null))
              _pager(theme),
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
              'The invoice report could not be generated.',
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
                  ? 'No Matching Invoices'
                  : 'No Invoices Found',
          subText:
              hasFilters
                  ? 'No invoice matches your search and filters'
                  : 'No invoice has been created for this shop yet',
          theme: theme,
          height: 35,
          icon: Icons.receipt_long_outlined,
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

  Widget _toolbar(ThemeProvider theme) {
    final active = _filters.activeCount;
    final accent = theme.lightModeColor.prColor300;
    return Wrap(
      spacing: 4,
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
                              ? 'Search customer, staff, ID, barcode or department'
                              : 'Search customer, staff, ID or barcode',
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
          _pill(
            theme: theme,
            icon: Icons.event_rounded,
            label: 'Date: $_rangeLabel',
            highlighted:
                _filters.dateRange != null && !_isDateToday,
            onTap: _pickRange,
          ),
          if (_filters.dateRange != null)
            Padding(
              padding: const EdgeInsets.only(right: 5.0),
              child: Material(
                color: Colors.transparent,
                child: Ink(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.grey.shade100,
                  ),
                  child: InkWell(
                    onTap: _clearDate,
                    mouseCursor: SystemMouseCursors.click,
                    borderRadius: BorderRadius.circular(5),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        10,
                        10,
                        10,
                        10,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.close,
                            size: 16,
                            color: accent,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'All Dates',
                            style: TextStyle(
                              color: accent,
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b3
                                      .fontSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(left: 6.0),
            child: _pill(
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
          // A view option, not a filter: Reset Filters keeps it.
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
            Material(
              color: Colors.transparent,
              child: Ink(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.grey.shade100,
                ),
                child: InkWell(
                  onTap: _resetAll,
                  mouseCursor: SystemMouseCursors.click,
                  borderRadius: BorderRadius.circular(5),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      10,
                      10,
                      10,
                      10,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.filter_alt_off,
                          size: 16,
                          color: accent,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Reset Filters',
                          style: TextStyle(
                            color: accent,
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b3
                                    .fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ],
    );
  }

  Widget _pill({
    required ThemeProvider theme,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool highlighted = false,
  }) {
    final accent = theme.lightModeColor.prColor300;
    return Material(
      color:
          highlighted
              ? accent.withAlpha(30)
              : Colors.grey.shade100,
      borderRadius: BorderRadius.circular(5),
      child: InkWell(
        mouseCursor: SystemMouseCursors.click,
        borderRadius: BorderRadius.circular(5),
        onTap: onTap,
        child: Container(
          height: 38,
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 6,
            children: [
              Icon(
                icon,
                size: 16,
                color:
                    highlighted ? accent : Colors.black87,
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: theme.mobileTexts.b3.fontSize,
                  fontWeight: FontWeight.bold,
                  color:
                      highlighted ? accent : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _labeled(
    String label,
    Widget child,
    double width,
  ) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          child,
        ],
      ),
    );
  }

  Widget _numField(
    TextEditingController c,
    String hint,
    ValueChanged<String> onChanged,
  ) {
    return SizedBox(
      height: 38,
      child: TextField(
        controller: c,
        onChanged: onChanged,
        keyboardType: const TextInputType.numberWithOptions(
          decimal: true,
          signed: true,
        ),
        style: const TextStyle(fontSize: 12),
        decoration: InputDecoration(
          hintText: hint,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
          ),
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _rangeFields({
    required String label,
    required TextEditingController minC,
    required TextEditingController maxC,
    required void Function(double? min, double? max)
    onChange,
  }) {
    void emit() =>
        onChange(_num(minC.text), _num(maxC.text));
    return _labeled(
      label,
      Row(
        spacing: 6,
        children: [
          Expanded(
            child: _numField(minC, 'Min', (_) => emit()),
          ),
          Expanded(
            child: _numField(maxC, 'Max', (_) => emit()),
          ),
        ],
      ),
      240,
    );
  }

  Widget _filterPanel(ThemeProvider theme) {
    // Unique staffs from invoices
    final staffEntries = <String, String>{};
    for (final r in _baseRows) {
      if (r.invoice.staffId.isNotEmpty &&
          r.staffName != '—') {
        staffEntries[r.invoice.staffId] = r.staffName;
      }
    }
    final sortedStaffs =
        staffEntries.entries.toList()..sort(
          (a, b) => a.value.toLowerCase().compareTo(
            b.value.toLowerCase(),
          ),
        );

    // Unique customers from invoices
    final customerEntries = <String, String>{};
    for (final r in _baseRows) {
      if (r.invoice.customerUuid != null &&
          r.invoice.customerUuid!.isNotEmpty) {
        customerEntries[r.invoice.customerUuid!] =
            r.customerName;
      }
    }
    final sortedCustomers =
        customerEntries.entries.toList()..sort(
          (a, b) => a.value.toLowerCase().compareTo(
            b.value.toLowerCase(),
          ),
        );

    // Sub-staffs (bulk sales)
    final subStaffEntries = <String, String>{};
    if (_bulkSaleEnabled) {
      for (final r in _baseRows) {
        if (r.invoice.subStaffUuid != null &&
            r.invoice.subStaffUuid!.isNotEmpty) {
          subStaffEntries[r.invoice.subStaffUuid!] =
              r.subStaffName;
        }
      }
    }

    // Departments
    final List<DepartmentClass> depts =
        _departmentsEnabled
            ? (returnDepartmentProvider(
                context: context,
              ).departments.toList()
              ..sort(
                (a, b) => a.name.toLowerCase().compareTo(
                  b.name.toLowerCase(),
                ),
              ))
            : const [];

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
          _labeled(
            'Staff',
            _SearchableDropdown<String?>(
              title: 'Staff Member',
              value: _filters.staffId,
              options: [
                const _SearchableOption(
                  value: null,
                  label: 'All Staff',
                ),
                ...sortedStaffs.map(
                  (s) => _SearchableOption(
                    value: s.key,
                    label: s.value,
                  ),
                ),
              ],
              onChanged:
                  (v) => _apply(() => _filters.staffId = v),
              theme: theme,
              searchHint: 'Search staff...',
            ),
            200,
          ),
          _labeled(
            'Customer',
            _SearchableDropdown<String?>(
              title: 'Customer',
              value: _filters.customerUuid,
              options: [
                const _SearchableOption(
                  value: null,
                  label: 'All Customers',
                ),
                ...sortedCustomers.map(
                  (c) => _SearchableOption(
                    value: c.key,
                    label: c.value,
                  ),
                ),
              ],
              onChanged:
                  (v) => _apply(
                    () => _filters.customerUuid = v,
                  ),
              theme: theme,
              searchHint: 'Search customer...',
            ),
            200,
          ),
          _labeled(
            'Payment Status',
            _SearchableDropdown<InvoicePaymentStatusFilter>(
              title: 'Payment Status',
              value: _filters.paymentStatus,
              options: const [
                _SearchableOption(
                  value: InvoicePaymentStatusFilter.all,
                  label: 'All Statuses',
                ),
                _SearchableOption(
                  value: InvoicePaymentStatusFilter.unpaid,
                  label: 'Unpaid',
                ),
                _SearchableOption(
                  value: InvoicePaymentStatusFilter.partial,
                  label: 'Partially Paid',
                ),
                _SearchableOption(
                  value: InvoicePaymentStatusFilter.paid,
                  label: 'Paid',
                ),
              ],
              onChanged:
                  (v) => _apply(
                    () =>
                        _filters.paymentStatus =
                            v ??
                            InvoicePaymentStatusFilter.all,
                  ),
              theme: theme,
              showSearch: false,
            ),
            180,
          ),
          if (_bulkSaleEnabled)
            _labeled(
              'Sub-Staff',
              _SearchableDropdown<String?>(
                title: 'Sub-Staff',
                value: _filters.subStaffUuid,
                options: [
                  const _SearchableOption(
                    value: null,
                    label: 'All Sub-Staff',
                  ),
                  ...subStaffEntries.entries.map(
                    (s) => _SearchableOption(
                      value: s.key,
                      label: s.value,
                    ),
                  ),
                ],
                onChanged:
                    (v) => _apply(
                      () => _filters.subStaffUuid = v,
                    ),
                theme: theme,
                searchHint: 'Search sub-staff...',
              ),
              180,
            ),
          if (_departmentsEnabled)
            _labeled(
              'Department',
              _SearchableDropdown<String?>(
                title: 'Department',
                value: _filters.departmentKey,
                options: [
                  const _SearchableOption(
                    value: null,
                    label: 'All Departments',
                  ),
                  const _SearchableOption(
                    value: invoiceReportNoDepartmentKey,
                    label: 'No Department',
                  ),
                  ...depts.map(
                    (d) => _SearchableOption(
                      value: d.uuid,
                      label: d.name,
                    ),
                  ),
                ],
                onChanged:
                    (v) => _apply(
                      () => _filters.departmentKey = v,
                    ),
                theme: theme,
                searchHint: 'Search departments...',
              ),
              200,
            ),
          _rangeFields(
            label: 'Invoice Total Range',
            minC: _totalMinCtrl,
            maxC: _totalMaxCtrl,
            onChange:
                (min, max) => _apply(() {
                  _filters.totalMin = min;
                  _filters.totalMax = max;
                }),
          ),
          _rangeFields(
            label: 'Amount Paid Range',
            minC: _paidMinCtrl,
            maxC: _paidMaxCtrl,
            onChange:
                (min, max) => _apply(() {
                  _filters.paidMin = min;
                  _filters.paidMax = max;
                }),
          ),
          _rangeFields(
            label: 'Outstanding Balance Range',
            minC: _balanceMinCtrl,
            maxC: _balanceMaxCtrl,
            onChange:
                (min, max) => _apply(() {
                  _filters.balanceMin = min;
                  _filters.balanceMax = max;
                }),
          ),
        ],
      ),
    );
  }

  Widget _activeChips(ThemeProvider theme) {
    final chips = <Widget>[];
    final accent = theme.lightModeColor.prColor300;

    Widget chip(String label, VoidCallback onRemove) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: accent.withAlpha(20),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accent.withAlpha(80)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: accent,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            InkWell(
              onTap: onRemove,
              borderRadius: BorderRadius.circular(10),
              child: Icon(
                Icons.close,
                size: 14,
                color: accent,
              ),
            ),
          ],
        ),
      );
    }

    if (_filters.search.isNotEmpty) {
      chips.add(
        chip('Search: "${_filters.search}"', () {
          _searchCtrl.clear();
          _apply(() => _filters.search = '');
        }),
      );
    }

    if (_filters.dateRange != null) {
      chips.add(
        chip('Date: $_rangeLabel', () {
          _clearDate();
        }),
      );
    }

    if (_filters.staffId != null) {
      final staffRow =
          _baseRows
              .where(
                (r) =>
                    r.invoice.staffId == _filters.staffId,
              )
              .firstOrNull;
      chips.add(
        chip(
          'Staff: ${staffRow?.staffName ?? _filters.staffId}',
          () {
            _apply(() => _filters.staffId = null);
          },
        ),
      );
    }

    if (_filters.customerUuid != null) {
      final custRow =
          _baseRows
              .where(
                (r) =>
                    r.invoice.customerUuid ==
                    _filters.customerUuid,
              )
              .firstOrNull;
      chips.add(
        chip(
          'Customer: ${custRow?.customerName ?? _filters.customerUuid}',
          () {
            _apply(() => _filters.customerUuid = null);
          },
        ),
      );
    }

    if (_filters.paymentStatus !=
        InvoicePaymentStatusFilter.all) {
      chips.add(
        chip(
          'Status: ${_filters.paymentStatus.name.toUpperCase()}',
          () {
            _apply(
              () =>
                  _filters.paymentStatus =
                      InvoicePaymentStatusFilter.all,
            );
          },
        ),
      );
    }

    if (_filters.subStaffUuid != null) {
      final subStaffRow =
          _baseRows
              .where(
                (r) =>
                    r.invoice.subStaffUuid ==
                    _filters.subStaffUuid,
              )
              .firstOrNull;
      chips.add(
        chip(
          'Sub-Staff: ${subStaffRow?.subStaffName ?? _filters.subStaffUuid}',
          () {
            _apply(() => _filters.subStaffUuid = null);
          },
        ),
      );
    }

    if (_filters.departmentKey != null) {
      final String label =
          _filters.departmentKey ==
                  invoiceReportNoDepartmentKey
              ? 'No Department'
              : (returnDepartmentProvider(context: context)
                      .departments
                      .where(
                        (d) =>
                            d.uuid ==
                            _filters.departmentKey,
                      )
                      .firstOrNull
                      ?.name ??
                  _filters.departmentKey!);
      chips.add(
        chip('Dept: $label', () {
          _apply(() => _filters.departmentKey = null);
        }),
      );
    }

    if (_filters.totalMin != null ||
        _filters.totalMax != null) {
      chips.add(
        chip(
          'Total: ${_filters.totalMin != null ? _money(_filters.totalMin!) : 'Any'} - '
          '${_filters.totalMax != null ? _money(_filters.totalMax!) : 'Any'}',
          () {
            _totalMinCtrl.clear();
            _totalMaxCtrl.clear();
            _apply(() {
              _filters.totalMin = null;
              _filters.totalMax = null;
            });
          },
        ),
      );
    }

    if (_filters.paidMin != null ||
        _filters.paidMax != null) {
      chips.add(
        chip(
          'Paid: ${_filters.paidMin != null ? _money(_filters.paidMin!) : 'Any'} - '
          '${_filters.paidMax != null ? _money(_filters.paidMax!) : 'Any'}',
          () {
            _paidMinCtrl.clear();
            _paidMaxCtrl.clear();
            _apply(() {
              _filters.paidMin = null;
              _filters.paidMax = null;
            });
          },
        ),
      );
    }

    if (_filters.balanceMin != null ||
        _filters.balanceMax != null) {
      chips.add(
        chip(
          'Balance: ${_filters.balanceMin != null ? _money(_filters.balanceMin!) : 'Any'} - '
          '${_filters.balanceMax != null ? _money(_filters.balanceMax!) : 'Any'}',
          () {
            _balanceMinCtrl.clear();
            _balanceMaxCtrl.clear();
            _apply(() {
              _filters.balanceMin = null;
              _filters.balanceMax = null;
            });
          },
        ),
      );
    }

    if (chips.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Wrap(
          spacing: 6,
          runSpacing: 4,
          children: chips,
        ),
      ),
    );
  }

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
  }) => Text(
    text,
    maxLines: 2,
    overflow: TextOverflow.ellipsis,
    textAlign: align,
    style: _cellStyle(theme, bold: bold, color: color),
  );

  Widget _badge(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 8,
      vertical: 3,
    ),
    decoration: BoxDecoration(
      color: color.withAlpha(25),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withAlpha(80)),
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

  List<_TableCol> _columns(ThemeProvider theme) {
    final red = theme.lightModeColor.errorColor200;
    final green = Colors.green.shade700;
    final amber = Colors.amber.shade800;

    return [
      // 1. ID
      _TableCol(
        label: 'ID',
        width: 100,
        sort: InvoiceSortField.id,
        align: TextAlign.start,
        cell:
            (r, i) => _txt(
              theme,
              r.displayId,
              bold: true,
              align: TextAlign.start,
            ),
      ),

      // 2. Staff
      _TableCol(
        label: 'Staff',
        width: 140,
        sort: InvoiceSortField.staff,
        align: TextAlign.start,
        cell:
            (r, i) => _txt(
              theme,
              r.staffName,
              align: TextAlign.start,
            ),
      ),

      // 3. Sub-Staff (Conditional: Manage Bulk Sale)
      if (_bulkSaleEnabled)
        _TableCol(
          label: 'Sub-Staff',
          width: 140,
          sort: InvoiceSortField.subStaff,
          align: TextAlign.start,
          cell:
              (r, i) => _txt(
                theme,
                r.subStaffName,
                align: TextAlign.start,
              ),
        ),

      // 4. Customer
      _TableCol(
        label: 'Customer',
        width: 170,
        sort: InvoiceSortField.customer,
        align: TextAlign.start,
        cell:
            (r, i) => _txt(
              theme,
              r.customerName,
              bold: true,
              align: TextAlign.start,
            ),
      ),

      // 5. Date
      _TableCol(
        label: 'Date',
        width: 120,
        sort: InvoiceSortField.createdAt,
        align: TextAlign.center,
        cell:
            (r, i) => _txt(
              theme,
              formatDateTime(r.createdAt),
              align: TextAlign.center,
            ),
      ),

      // 6. Time
      _TableCol(
        label: 'Time',
        width: 100,
        align: TextAlign.center,
        cell:
            (r, i) => _txt(
              theme,
              formatTime(r.createdAt),
              align: TextAlign.center,
            ),
      ),

      // 7. Discount
      _TableCol(
        label: 'Discount',
        width: 130,
        sort: InvoiceSortField.discount,
        align: TextAlign.center,
        cell:
            (r, i) => _txt(
              theme,
              r.discountDisplay,
              align: TextAlign.center,
            ),
      ),

      // 8. VAT
      _TableCol(
        label: 'VAT',
        width: 130,
        sort: InvoiceSortField.vat,
        align: TextAlign.center,
        cell:
            (r, i) => _txt(
              theme,
              r.vatDisplay,
              align: TextAlign.center,
            ),
      ),

      // 9. Items
      _TableCol(
        label: 'Items',
        width: 90,
        sort: InvoiceSortField.items,
        align: TextAlign.center,
        cell:
            (r, i) => _txt(
              theme,
              r.totalItems == null
                  ? 'N/A'
                  : formatLargeNumberDouble(r.totalItems!),
              bold: true,
              align: TextAlign.center,
            ),
      ),

      // 10. Department (Conditional: Department Management)
      if (_departmentsEnabled)
        _TableCol(
          label: 'Department',
          width: 140,
          sort: InvoiceSortField.department,
          align: TextAlign.start,
          cell:
              (r, i) => _txt(
                theme,
                r.departmentName,
                align: TextAlign.start,
                color:
                    r.departmentKey == null
                        ? Colors.grey
                        : null,
              ),
        ),

      // 11. Comment
      _TableCol(
        label: 'Comment',
        width: 140,
        align: TextAlign.start,
        cell:
            (r, i) => _txt(
              theme,
              r.comment,
              align: TextAlign.start,
            ),
      ),

      // 12. Invoice Total
      _TableCol(
        label: 'Invoice Total',
        width: 140,
        sort: InvoiceSortField.total,
        align: TextAlign.center,
        cell:
            (r, i) => _txt(
              theme,
              r.invoiceTotal == null
                  ? 'N/A'
                  : _money(r.invoiceTotal!),
              bold: true,
              align: TextAlign.center,
            ),
      ),

      // 13. Amount Paid
      _TableCol(
        label: 'Amount Paid',
        width: 130,
        sort: InvoiceSortField.amountPaid,
        align: TextAlign.center,
        cell:
            (r, i) => _txt(
              theme,
              _money(r.amountPaid),
              bold: true,
              color: r.amountPaid > 0 ? green : null,
              align: TextAlign.center,
            ),
      ),

      // 14. Outstanding Balance
      _TableCol(
        label: 'Balance',
        width: 140,
        sort: InvoiceSortField.balance,
        align: TextAlign.center,
        cell:
            (r, i) => _txt(
              theme,
              r.balance == null
                  ? 'N/A'
                  : _money(r.balance!),
              bold: true,
              color:
                  r.balance == null
                      ? null
                      : (r.balance! > 0 ? red : green),
              align: TextAlign.center,
            ),
      ),

      // 15. Status
      _TableCol(
        label: 'Status',
        width: 110,
        sort: InvoiceSortField.status,
        align: TextAlign.center,
        cell: (r, i) {
          if (r.status == 0) return _badge('Unpaid', red);
          if (r.status == 1)
            return _badge('Partial', amber);
          if (r.status == 2) return _badge('Paid', green);
          return _badge('N/A', Colors.grey);
        },
      ),
    ];
  }

  Widget _headerCell(ThemeProvider theme, _TableCol c) {
    final isSorted = c.sort != null && c.sort == _sortField;
    final accent = theme.lightModeColor.prColor300;
    final label = Flexible(
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
    );

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
        label,
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

    return SizedBox(
      width: c.width,
      child:
          c.sort == null
              ? Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                ),
                child: Align(
                  alignment:
                      c.align == TextAlign.start
                          ? Alignment.centerLeft
                          : (c.align == TextAlign.end
                              ? Alignment.centerRight
                              : Alignment.center),
                  child: content,
                ),
              )
              : InkWell(
                mouseCursor: SystemMouseCursors.click,
                onTap: () => _setSort(c.sort!),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                  ),
                  child: Align(
                    alignment:
                        c.align == TextAlign.start
                            ? Alignment.centerLeft
                            : (c.align == TextAlign.end
                                ? Alignment.centerRight
                                : Alignment.center),
                    child: content,
                  ),
                ),
              ),
    );
  }

  Widget _table(
    ThemeProvider theme,
    InvoiceReportPageResult res,
  ) {
    final cols = _columns(theme);
    final totalWidth = cols.fold<double>(
      0,
      (s, c) => s + c.width,
    );

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.shade200,
                ),
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
                            notif.metrics.axis ==
                            Axis.vertical,
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
                                  children:
                                      cols
                                          .map(
                                            (c) =>
                                                _headerCell(
                                                  theme,
                                                  c,
                                                ),
                                          )
                                          .toList(),
                                ),
                              ),
                              const Divider(
                                height: 1,
                                thickness: 1,
                              ),
                              Expanded(
                                child: ListView.separated(
                                  controller: _vScroll,
                                  itemCount:
                                      res.rows.length,
                                  separatorBuilder:
                                      (_, __) => Divider(
                                        height: 1,
                                        color:
                                            Colors
                                                .grey
                                                .shade100,
                                      ),
                                  itemBuilder: (
                                    context,
                                    index,
                                  ) {
                                    final row =
                                        res.rows[index];
                                    final isEven =
                                        index.isEven;
                                    return Material(
                                      color:
                                          isEven
                                              ? Colors.white
                                              : Colors
                                                  .grey
                                                  .shade50
                                                  .withAlpha(
                                                    120,
                                                  ),
                                      child: InkWell(
                                        mouseCursor:
                                            SystemMouseCursors
                                                .click,
                                        onTap:
                                            () =>
                                                _openInvoiceDetails(
                                                  row,
                                                ),
                                        hoverColor: theme
                                            .lightModeColor
                                            .prColor300
                                            .withAlpha(15),
                                        child: SizedBox(
                                          height: 44,
                                          child: Row(
                                            children:
                                                cols.map((
                                                  c,
                                                ) {
                                                  return SizedBox(
                                                    width:
                                                        c.width,
                                                    child: Padding(
                                                      padding: const EdgeInsets.symmetric(
                                                        horizontal:
                                                            10,
                                                      ),
                                                      child: Align(
                                                        alignment:
                                                            c.align ==
                                                                    TextAlign.start
                                                                ? Alignment.centerLeft
                                                                : (c.align ==
                                                                        TextAlign.end
                                                                    ? Alignment.centerRight
                                                                    : Alignment.center),
                                                        child: c.cell(
                                                          row,
                                                          index,
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
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
          ),
        ],
      ),
    );
  }

  Widget _totalsRow(
    ThemeProvider theme,
    List<_TableCol> cols,
    InvoiceReportPageResult res,
  ) {
    final green = Colors.green.shade700;
    final red = theme.lightModeColor.errorColor200;

    return Container(
      height: 46,
      color: theme.lightModeColor.prColor300.withAlpha(25),
      child: Row(
        children:
            cols.map((c) {
              Widget child = const SizedBox.shrink();

              if (c.label == 'Comment') {
                child = Text(
                  'Total:',
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b3.fontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                );
              } else if (c.label == 'ID') {
                child = Text(
                  'TOTAL',
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b3.fontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                );
              } else if (c.label == 'Invoice Total') {
                child = Text(
                  _money(res.totalRevenue),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b3.fontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                );
              } else if (c.label == 'Amount Paid') {
                child = Text(
                  _money(res.totalAmountPaid),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b3.fontSize,
                    fontWeight: FontWeight.bold,
                    color:
                        res.totalAmountPaid > 0
                            ? green
                            : Colors.black87,
                  ),
                );
              } else if (c.label == 'Balance') {
                child = Text(
                  _money(res.totalBalance),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b3.fontSize,
                    fontWeight: FontWeight.bold,
                    color:
                        res.totalBalance > 0 ? red : green,
                  ),
                );
              }

              return SizedBox(
                width: c.width,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                  ),
                  child: Align(
                    alignment:
                        c.align == TextAlign.start
                            ? Alignment.centerLeft
                            : (c.align == TextAlign.end
                                ? Alignment.centerRight
                                : Alignment.center),
                    child: child,
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  // ---------------------------------------------------------------
  // grouped by staff / customer / channel
  // ---------------------------------------------------------------

  Alignment _alignOf(TextAlign a) =>
      a == TextAlign.start
          ? Alignment.centerLeft
          : (a == TextAlign.end
              ? Alignment.centerRight
              : Alignment.center);

  List<_GroupCol> _groupColumns(ThemeProvider theme) {
    final green = Colors.green.shade700;
    final red = theme.lightModeColor.errorColor200;

    return [
      _GroupCol(
        label: _groupBy.label,
        width: 220,
        sort: InvoiceGroupSortField.name,
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
      _GroupCol(
        label: 'Invoices',
        width: 110,
        sort: InvoiceGroupSortField.count,
        cell: (g) => _txt(theme, '${g.count}'),
        total:
            (res) => _txt(
              theme,
              '${res.totalInvoices}',
              bold: true,
            ),
      ),
      _GroupCol(
        label: 'Invoice Total',
        width: 160,
        sort: InvoiceGroupSortField.total,
        cell:
            (g) => _txt(theme, _money(g.total), bold: true),
        total:
            (res) => _txt(
              theme,
              _money(res.totalRevenue),
              bold: true,
            ),
      ),
      _GroupCol(
        label: 'Amount Paid',
        width: 160,
        sort: InvoiceGroupSortField.paid,
        cell:
            (g) => _txt(
              theme,
              _money(g.paid),
              color: g.paid > 0 ? green : null,
            ),
        total:
            (res) => _txt(
              theme,
              _money(res.totalAmountPaid),
              bold: true,
              color: res.totalAmountPaid > 0 ? green : null,
            ),
      ),
      _GroupCol(
        label: 'Balance',
        width: 160,
        sort: InvoiceGroupSortField.balance,
        cell:
            (g) => _txt(
              theme,
              _money(g.balance),
              color: g.balance > 0 ? red : green,
            ),
        total:
            (res) => _txt(
              theme,
              _money(res.totalBalance),
              bold: true,
              color: res.totalBalance > 0 ? red : green,
            ),
      ),
    ];
  }

  Widget _groupHeaderCell(
    ThemeProvider theme,
    _GroupCol c,
  ) {
    final isSorted = c.sort == _groupSortField;
    final accent = theme.lightModeColor.prColor300;
    return SizedBox(
      width: c.width,
      child: InkWell(
        mouseCursor: SystemMouseCursors.click,
        onTap: () => _setGroupSort(c.sort),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
          ),
          child: Align(
            alignment: _alignOf(c.align),
            child: Row(
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
                      fontSize:
                          theme.mobileTexts.b3.fontSize,
                      fontWeight: FontWeight.bold,
                      color:
                          isSorted
                              ? accent
                              : Colors.black87,
                    ),
                  ),
                ),
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
            ),
          ),
        ),
      ),
    );
  }

  /// One cell per column, for a group row or the totals row.
  Widget _groupCells(
    List<_GroupCol> cols,
    Widget Function(_GroupCol c) cell,
  ) {
    return Row(
      children: [
        for (final c in cols)
          SizedBox(
            width: c.width,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
              ),
              child: Align(
                alignment: _alignOf(c.align),
                child: cell(c),
              ),
            ),
          ),
      ],
    );
  }

  Widget _groupTable(
    ThemeProvider theme,
    InvoiceReportGroupPage res,
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
                        const Divider(
                          height: 1,
                          thickness: 1,
                        ),
                        Expanded(
                          child: ListView.separated(
                            controller: _vScroll,
                            itemCount: res.rows.length,
                            separatorBuilder:
                                (_, __) => Divider(
                                  height: 1,
                                  color:
                                      Colors.grey.shade100,
                                ),
                            // No row tap: a group has no single
                            // invoice to open.
                            itemBuilder: (context, index) {
                              final g = res.rows[index];
                              return Container(
                                height: 44,
                                color:
                                    index.isEven
                                        ? Colors.white
                                        : Colors
                                            .grey
                                            .shade50
                                            .withAlpha(120),
                                child: _groupCells(
                                  cols,
                                  (c) => c.cell(g),
                                ),
                              );
                            },
                          ),
                        ),
                        const Divider(
                          height: 1,
                          thickness: 1,
                        ),
                        Container(
                          height: 46,
                          color: theme
                              .lightModeColor
                              .prColor300
                              .withAlpha(25),
                          child: _groupCells(
                            cols,
                            (c) => c.total(res),
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

  Widget _pager(ThemeProvider theme) {
    final r = _result;
    final g = _groupResult;
    if (_grouped ? g == null : r == null) {
      return const SizedBox.shrink();
    }

    final cur = _grouped ? g!.page : r!.page;
    final total = _grouped ? g!.totalPages : r!.totalPages;
    final firstIndex =
        _grouped ? g!.firstIndex : r!.firstIndex;
    final lastIndex =
        _grouped ? g!.lastIndex : r!.lastIndex;
    final totalCount =
        _grouped ? g!.totalCount : r!.totalCount;
    final accent = theme.lightModeColor.prColor300;

    Widget btn({
      required Widget child,
      required VoidCallback? onTap,
      bool active = false,
      double minWidth = 32,
    }) {
      return Material(
        color: active ? accent : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          mouseCursor:
              onTap == null
                  ? SystemMouseCursors.basic
                  : SystemMouseCursors.click,
          borderRadius: BorderRadius.circular(4),
          onTap: onTap,
          child: Container(
            constraints: BoxConstraints(minWidth: minWidth),
            height: 32,
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
            ),
            alignment: Alignment.center,
            child: child,
          ),
        ),
      );
    }

    // Window of at most 5 page numbers centered on `cur`
    final pages = <int>[];
    final start = math.max(1, cur - 2);
    final end = math.min(total, start + 4);
    final adjustedStart = math.max(1, end - 4);
    for (int i = adjustedStart; i <= end; i++) {
      pages.add(i);
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Showing $firstIndex - $lastIndex of $totalCount',
            style: TextStyle(
              fontSize: theme.mobileTexts.b4.fontSize,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          Row(
            spacing: 4,
            children: [
              btn(
                onTap: cur > 1 ? () => _goToPage(1) : null,
                child: Icon(
                  Icons.first_page_rounded,
                  size: 16,
                  color:
                      cur > 1
                          ? Colors.black87
                          : Colors.grey,
                ),
              ),
              btn(
                onTap:
                    cur > 1
                        ? () => _goToPage(cur - 1)
                        : null,
                child: Icon(
                  Icons.chevron_left_rounded,
                  size: 16,
                  color:
                      cur > 1
                          ? Colors.black87
                          : Colors.grey,
                ),
              ),
              ...pages.map((p) {
                final isCur = p == cur;
                return btn(
                  active: isCur,
                  onTap: isCur ? null : () => _goToPage(p),
                  child: Text(
                    '$p',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color:
                          isCur
                              ? Colors.white
                              : Colors.black87,
                    ),
                  ),
                );
              }),
              btn(
                onTap:
                    cur < total
                        ? () => _goToPage(cur + 1)
                        : null,
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: 16,
                  color:
                      cur < total
                          ? Colors.black87
                          : Colors.grey,
                ),
              ),
              btn(
                onTap:
                    cur < total
                        ? () => _goToPage(total)
                        : null,
                child: Icon(
                  Icons.last_page_rounded,
                  size: 16,
                  color:
                      cur < total
                          ? Colors.black87
                          : Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Searchable Dropdown Helper Components (Styled consistently with Items Report)
// ---------------------------------------------------------------------------

class _SearchableOption<T> {
  final T value;
  final String label;

  const _SearchableOption({
    required this.value,
    required this.label,
  });
}

class _SearchableDropdown<T> extends StatelessWidget {
  final String title;
  final T value;
  final List<_SearchableOption<T>> options;
  final ValueChanged<T?> onChanged;
  final ThemeProvider theme;
  final String? searchHint;
  final bool showSearch;

  const _SearchableDropdown({
    required this.title,
    required this.value,
    required this.options,
    required this.onChanged,
    required this.theme,
    this.searchHint,
    this.showSearch = true,
  });

  @override
  Widget build(BuildContext context) {
    final selectedOption =
        options
            .where((o) => o.value == value)
            .firstOrNull ??
        options.firstOrNull;
    final currentLabel = selectedOption?.label ?? '';

    return Material(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(5),
      child: InkWell(
        mouseCursor: SystemMouseCursors.click,
        borderRadius: BorderRadius.circular(5),
        onTap: () async {
          final RenderBox box =
              context.findRenderObject() as RenderBox;
          final Offset offset = box.localToGlobal(
            Offset.zero,
          );
          final Size size = box.size;

          final result = await showDialog<T>(
            context: context,
            barrierColor: Colors.black.withAlpha(25),
            builder:
                (ctx) => _SearchableDropdownPopup<T>(
                  triggerOffset: offset,
                  triggerSize: size,
                  title: title,
                  currentValue: value,
                  options: options,
                  searchHint: searchHint,
                  showSearch: showSearch,
                  theme: theme,
                ),
          );

          if (result != null) {
            onChanged(result);
          }
        },
        child: Container(
          height: 38,
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
          ),
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  currentLabel,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_drop_down,
                size: 20,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchableDropdownPopup<T> extends StatefulWidget {
  final Offset triggerOffset;
  final Size triggerSize;
  final String title;
  final T currentValue;
  final List<_SearchableOption<T>> options;
  final String? searchHint;
  final bool showSearch;
  final ThemeProvider theme;

  const _SearchableDropdownPopup({
    required this.triggerOffset,
    required this.triggerSize,
    required this.title,
    required this.currentValue,
    required this.options,
    this.searchHint,
    this.showSearch = true,
    required this.theme,
  });

  @override
  State<_SearchableDropdownPopup<T>> createState() =>
      _SearchableDropdownPopupState<T>();
}

class _SearchableDropdownPopupState<T>
    extends State<_SearchableDropdownPopup<T>> {
  late final TextEditingController _searchCtrl;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController();
    _searchCtrl.addListener(() {
      final text = _searchCtrl.text.trim().toLowerCase();
      if (_query != text) {
        setState(() => _query = text);
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.theme.lightModeColor.prColor300;
    final filtered =
        widget.options.where((o) {
          if (_query.isEmpty) return true;
          return o.label.toLowerCase().contains(_query);
        }).toList();

    const double popupWidth = 260;
    const double popupHeight = 320;
    final screenSize = MediaQuery.of(context).size;

    double left = widget.triggerOffset.dx;
    if (left + popupWidth > screenSize.width - 16) {
      left = screenSize.width - popupWidth - 16;
    }
    if (left < 16) left = 16;

    double top =
        widget.triggerOffset.dy +
        widget.triggerSize.height +
        4;
    if (top + popupHeight > screenSize.height - 16) {
      top = widget.triggerOffset.dy - popupHeight - 4;
    }
    if (top < 16) top = 16;

    return Stack(
      children: [
        Positioned(
          left: left,
          top: top,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
            child: Container(
              width: popupWidth,
              height: popupHeight,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.grey.shade200,
                ),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (widget.showSearch) ...[
                    SizedBox(
                      height: 36,
                      child: TextField(
                        controller: _searchCtrl,
                        style: const TextStyle(
                          fontSize: 12,
                        ),
                        decoration: InputDecoration(
                          hintText:
                              widget.searchHint ??
                              'Search...',
                          prefixIcon: const Icon(
                            Icons.search,
                            size: 16,
                          ),
                          contentPadding: EdgeInsets.zero,
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(4),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],
                  Expanded(
                    child:
                        filtered.isEmpty
                            ? const Center(
                              child: Text(
                                'No options found',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                            : ListView.builder(
                              itemCount: filtered.length,
                              itemBuilder: (ctx, i) {
                                final opt = filtered[i];
                                final isSelected =
                                    opt.value ==
                                    widget.currentValue;
                                return Material(
                                  color:
                                      isSelected
                                          ? accent
                                              .withAlpha(20)
                                          : Colors
                                              .transparent,
                                  borderRadius:
                                      BorderRadius.circular(
                                        4,
                                      ),
                                  child: InkWell(
                                    borderRadius:
                                        BorderRadius.circular(
                                          4,
                                        ),
                                    onTap:
                                        () => Navigator.pop(
                                          context,
                                          opt.value,
                                        ),
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 8,
                                          ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              opt.label,
                                              style: TextStyle(
                                                fontSize:
                                                    12,
                                                fontWeight:
                                                    isSelected
                                                        ? FontWeight.bold
                                                        : FontWeight.normal,
                                                color:
                                                    isSelected
                                                        ? accent
                                                        : Colors.black87,
                                              ),
                                            ),
                                          ),
                                          if (isSelected)
                                            Icon(
                                              Icons
                                                  .check_rounded,
                                              size: 16,
                                              color: accent,
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
