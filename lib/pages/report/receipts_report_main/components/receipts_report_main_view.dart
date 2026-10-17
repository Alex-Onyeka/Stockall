import 'package:flutter/material.dart';
import 'package:stockall/classes/checkout_response.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/date_picker_function.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/refresh_functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/report/components/report_pager.dart';
import 'package:stockall/pages/report/components/report_range_fields.dart';
import 'package:stockall/pages/report/components/report_searchable_dropdown.dart';
import 'package:stockall/pages/report/receipts_report_main/class/receipts_report_main_logic.dart';
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

  late ReceiptsReportPeriod _period;

  bool _loading = true;
  String? _error;

  List<ReceiptsReportRow> _baseRows = [];
  ReceiptsReportPage? _result;
  int _profitExcluded = 0;
  String _signature = '';

  List<ReceiptsFilterOption> _staffOptions = [];
  List<ReceiptsFilterOption> _customerOptions = [];
  List<ReceiptsFilterOption> _subStaffOptions = [];
  List<ReceiptsFilterOption> _departmentOptions = [];

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
    _staffOptions = ReceiptsReportOptions.staff(_baseRows);
    _customerOptions = ReceiptsReportOptions.customers(
      _baseRows,
    );
    _subStaffOptions = ReceiptsReportOptions.subStaff(
      _baseRows,
    );
    _departmentOptions = ReceiptsReportOptions.departments(
      _baseRows,
    );
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
    final page = ReceiptsReportQuery.paginate(
      sorted,
      _page,
    );
    _page = page.page;
    _result = page;
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

  // ---------------------------------------------------------------
  // period
  // ---------------------------------------------------------------

  bool get _isToday {
    final today = ReceiptsReportPeriod.today();
    return _period.isSingleDay &&
        _period.start == today.start;
  }

  void _pickDate() {
    final theme = returnTheme(context, listen: false);
    mainDatePicker(
      context: context,
      theme: theme,
      singleDate: (date) {
        if (date == null) return;
        _apply(
          () => _period = ReceiptsReportPeriod.day(date),
        );
      },
      rangeDate: (firstDate, lastDate) {
        if (firstDate == null) return;
        _apply(
          () =>
              _period = ReceiptsReportPeriod.range(
                firstDate,
                lastDate ?? firstDate,
              ),
        );
      },
    );
  }

  void _onPeriodMenu(int choice) {
    switch (choice) {
      case 0:
        _apply(
          () => _period = ReceiptsReportPeriod.today(),
        );
        break;
      case 1:
        _pickDate();
        break;
      case 2:
        _apply(
          () =>
              _period =
                  const ReceiptsReportPeriod.allTime(),
        );
        break;
    }
  }

  String get _periodLabel {
    if (_period.isAllTime) return 'All time (loaded data)';
    final s = _period.start!;
    final e = _period.end!;
    if (_period.isSingleDay) {
      return _isToday
          ? 'Today, ${formatDateTime(s)}'
          : formatDateTime(s);
    }
    return '${formatDateTime(s)} - ${formatDateTime(e)}';
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

  String _optionLabel(
    List<ReceiptsFilterOption> options,
    String key,
    String fallback,
  ) {
    for (final o in options) {
      if (o.key == key) return o.label;
    }
    return fallback;
  }

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
    if (res == null || res.totalCount == 0) {
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
        ),
        Padding(
          padding: const EdgeInsets.only(right: 5.0),
          child: PopupMenuButton<int>(
            enabled: _canPickDate,
            tooltip:
                _canPickDate
                    ? 'Change period'
                    : 'You can only view today',
            offset: const Offset(0, 42),
            color: Colors.white,
            onSelected: _onPeriodMenu,
            itemBuilder:
                (context) => [
                  _periodItem(theme, 0, 'Today', _isToday),
                  _periodItem(
                    theme,
                    1,
                    'Pick a date or range',
                    !_isToday && !_period.isAllTime,
                  ),
                  _periodItem(
                    theme,
                    2,
                    'All time (loaded data)',
                    _period.isAllTime,
                  ),
                ],
            child: _pill(
              theme: theme,
              icon: Icons.event_rounded,
              label: 'Date: $_periodLabel',
              highlighted: !_isToday,
            ),
          ),
        ),
        if (!_isToday && _canPickDate)
          Padding(
            padding: const EdgeInsets.only(right: 5.0),
            child: _pill(
              theme: theme,
              icon: Icons.close,
              label: 'Today',
              onTap: () => _onPeriodMenu(0),
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(
            left: 6.0,
            right: 5,
          ),
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
        if (_filters.hasAnything)
          _pill(
            theme: theme,
            icon: Icons.filter_alt_off,
            label: 'Reset All Filters',
            onTap: _resetAll,
            color: accent,
          ),
      ],
    );
  }

  PopupMenuItem<int> _periodItem(
    ThemeProvider theme,
    int value,
    String text,
    bool selected,
  ) {
    return PopupMenuItem<int>(
      value: value,
      child: Text(
        text,
        style: TextStyle(
          fontSize: theme.mobileTexts.b3.fontSize,
          fontWeight: selected ? FontWeight.bold : null,
        ),
      ),
    );
  }

  /// With a null [onTap] the pill only shows (a parent such as a
  /// PopupMenuButton handles the tap).
  Widget _pill({
    required ThemeProvider theme,
    required IconData icon,
    required String label,
    VoidCallback? onTap,
    bool highlighted = false,
    Color? color,
  }) {
    final accent = theme.lightModeColor.prColor300;
    final fg =
        color ?? (highlighted ? accent : Colors.black87);
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
              Icon(icon, size: 16, color: fg),
              Text(
                label,
                style: TextStyle(
                  fontSize: theme.mobileTexts.b3.fontSize,
                  fontWeight: FontWeight.bold,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _keyDropdown({
    required ThemeProvider theme,
    required String title,
    required String allLabel,
    required String? value,
    required List<ReceiptsFilterOption> options,
    required ValueChanged<String?> onChanged,
  }) {
    return ReportLabeledField(
      label: title,
      width: 220,
      child: ReportSearchableDropdown<String?>(
        title: title,
        value: value,
        options: [
          ReportSearchableOption(
            value: null,
            label: allLabel,
          ),
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
          _keyDropdown(
            theme: theme,
            title: 'Staff',
            allLabel: 'All staff',
            value: _filters.staffKey,
            options: _staffOptions,
            onChanged: (v) => _filters.staffKey = v,
          ),
          _keyDropdown(
            theme: theme,
            title: 'Customer',
            allLabel: 'All customers',
            value: _filters.customerKey,
            options: _customerOptions,
            onChanged: (v) => _filters.customerKey = v,
          ),
          if (_subStaffEnabled)
            _keyDropdown(
              theme: theme,
              title: 'Sub-Staff',
              allLabel: 'All sub-staff',
              value: _filters.subStaffKey,
              options: _subStaffOptions,
              onChanged: (v) => _filters.subStaffKey = v,
            ),
          if (_departmentsEnabled)
            _keyDropdown(
              theme: theme,
              title: 'Department',
              allLabel: 'All departments',
              value: _filters.departmentKey,
              options: _departmentOptions,
              onChanged: (v) => _filters.departmentKey = v,
            ),
          ReportLabeledField(
            label: 'Channel',
            width: 180,
            child: ReportSearchableDropdown<
              ReceiptChannel?
            >(
              title: 'Channel',
              value: _filters.channel,
              showSearch: false,
              options: [
                const ReportSearchableOption(
                  value: null,
                  label: 'All channels',
                ),
                ...ReceiptChannel.values.map(
                  (c) => ReportSearchableOption<
                    ReceiptChannel?
                  >(value: c, label: c.label),
                ),
              ],
              onChanged:
                  (v) => _apply(() => _filters.channel = v),
              theme: theme,
            ),
          ),
          ReportLabeledField(
            label: 'Type',
            width: 180,
            child: ReportSearchableDropdown<ReceiptType?>(
              title: 'Type',
              value: _filters.type,
              showSearch: false,
              options: [
                const ReportSearchableOption(
                  value: null,
                  label: 'All types',
                ),
                ...ReceiptType.values.map(
                  (t) =>
                      ReportSearchableOption<ReceiptType?>(
                        value: t,
                        label: t.label,
                      ),
                ),
              ],
              onChanged:
                  (v) => _apply(() => _filters.type = v),
              theme: theme,
            ),
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
    final chips = <Widget>[];
    Widget chip(String text, VoidCallback onRemove) =>
        InputChip(
          label: Text(
            text,
            style: const TextStyle(fontSize: 10),
          ),
          onDeleted: onRemove,
          deleteIcon: const Icon(Icons.close, size: 12),
          visualDensity: VisualDensity.compact,
          backgroundColor: theme.lightModeColor.prColor300
              .withAlpha(25),
          side: BorderSide.none,
        );

    void keyChip(
      String title,
      String? key,
      List<ReceiptsFilterOption> options,
      VoidCallback clear,
    ) {
      if (key == null) return;
      chips.add(
        chip(
          '$title: ${_optionLabel(options, key, title)}',
          () => _apply(clear),
        ),
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
    if (_filters.channel != null) {
      chips.add(
        chip(
          'Channel: ${_filters.channel!.label}',
          () => _apply(() => _filters.channel = null),
        ),
      );
    }
    if (_filters.type != null) {
      chips.add(
        chip(
          'Type: ${_filters.type!.label}',
          () => _apply(() => _filters.type = null),
        ),
      );
    }
    if (_filters.revenueMin != null ||
        _filters.revenueMax != null) {
      chips.add(
        chip(
          'Revenue: ${_filters.revenueMin != null ? _money(_filters.revenueMin!) : 'Any'}'
          ' - ${_filters.revenueMax != null ? _money(_filters.revenueMax!) : 'Any'}',
          () {
            _revMinCtrl.clear();
            _revMaxCtrl.clear();
            _apply(() {
              _filters.revenueMin = null;
              _filters.revenueMax = null;
            });
          },
        ),
      );
    }
    if (_canSeeCost &&
        (_filters.profitMin != null ||
            _filters.profitMax != null)) {
      chips.add(
        chip(
          'Profit/Loss: ${_filters.profitMin != null ? _money(_filters.profitMin!) : 'Any'}'
          ' - ${_filters.profitMax != null ? _money(_filters.profitMax!) : 'Any'}',
          () {
            _profitMinCtrl.clear();
            _profitMaxCtrl.clear();
            _apply(() {
              _filters.profitMin = null;
              _filters.profitMax = null;
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

  Widget _notes(ThemeProvider theme) {
    final notes = <String>[
      if (_period.isAllTime)
        'All time covers the receipts loaded on this device.',
      if (_profitExcluded > 0)
        '$_profitExcluded receipt${_profitExcluded == 1 ? ' is' : 's are'} '
            'left out of the profit range: no item data or a '
            'missing cost price.',
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
        cell: (r) => _txt(theme, r.channel.label),
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
