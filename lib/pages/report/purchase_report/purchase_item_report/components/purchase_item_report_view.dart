import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_purchase/temp_purchase.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/report/components/export/report_export_button.dart';
import 'package:stockall/pages/report/components/export/report_export_format.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/report_pager.dart';
import 'package:stockall/pages/report/components/report_pill.dart';
import 'package:stockall/pages/report/components/report_range_fields.dart';
import 'package:stockall/pages/report/components/report_searchable_dropdown.dart';
import 'package:stockall/pages/report/purchase_report/purchase_item_report/class/purchase_item_export_spec.dart';
import 'package:stockall/pages/report/purchase_report/purchase_item_report/class/purchase_item_report_logic.dart';
import 'package:stockall/pages/report/purchase_report/purchase_report_table/class/purchase_report_table_logic.dart';
import 'package:stockall/pages/report/purchase_report/purchase_report_table/components/purchase_report_table_view.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/components/receipts_report_filter_widgets.dart';
import 'package:stockall/providers/theme_provider.dart';

class _Col {
  final String label;
  final double width;
  final PurchaseItemSortField? sort;
  final TextAlign align;
  final Widget Function(PurchaseItemRow row) cell;
  final Widget Function(PurchaseItemReportTotals totals)?
  total;

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
  final PurchaseItemSortField? sort;
  final TextAlign align;
  final Widget Function(PurchaseItemGroupRow row) cell;
  final Widget Function(PurchaseItemGroupPage page)? total;

  const _GCol({
    required this.label,
    required this.width,
    required this.cell,
    this.sort,
    this.align = TextAlign.center,
    this.total,
  });
}

class PurchaseItemReportView extends StatefulWidget {
  final bool isDesktop;
  final PurchaseItemFilters? initialFilters;
  final ReceiptsReportPeriod? initialPeriod;
  final PurchaseReportEnv? env;

  const PurchaseItemReportView({
    super.key,
    required this.isDesktop,
    this.initialFilters,
    this.initialPeriod,
    this.env,
  });

  @override
  State<PurchaseItemReportView> createState() =>
      _PurchaseItemReportViewState();
}

class _PurchaseItemReportViewState
    extends State<PurchaseItemReportView> {
  late final PurchaseReportEnv _env;
  late PurchaseItemFilters _filters;
  late ReceiptsReportPeriod _period;
  PurchaseItemSortField _sortField =
      PurchaseItemSortField.createdAt;
  bool _ascending = false;
  bool _groupByItem = false;
  PurchaseItemSortField _groupSortField =
      PurchaseItemSortField.total;
  bool _groupAscending = false;
  int _page = 1;

  final _searchCtrl = TextEditingController();
  final _totalMinCtrl = TextEditingController();
  final _totalMaxCtrl = TextEditingController();
  final _hScroll = ScrollController();
  final _vScroll = ScrollController();

  bool _showFilters = false;
  bool _toolbarIsOpen = false;
  bool _loading = true;
  String? _error;
  String _signature = '';

  List<PurchaseItemRow> _allRows = [];
  List<PurchaseItemRow> _inPeriod = [];
  List<PurchaseItemRow> _sortedRows = [];
  PurchaseItemPage? _pageResult;
  PurchaseItemGroupPage? _groupPageResult;
  PurchaseItemReportTotals _totals =
      const PurchaseItemReportTotals(
        lineCount: 0,
        distinctItems: 0,
        purchaseCount: 0,
        totalQuantity: 0,
        totalSpend: 0,
      );

  List<PurchaseFilterOption> _itemOpts = const [];
  List<PurchaseFilterOption> _supplierOpts = const [];
  List<PurchaseFilterOption> _staffOpts = const [];
  List<PurchaseFilterOption> _deptOpts = const [];

  @override
  void initState() {
    super.initState();
    _env = widget.env ?? PurchaseReportEnv.live();
    _filters =
        widget.initialFilters?.copy() ??
        PurchaseItemFilters();
    _period =
        widget.initialPeriod ??
        ReceiptsReportPeriod.today();
    _searchCtrl.text = _filters.search;
    if (_filters.totalMin != null) {
      _totalMinCtrl.text = _numText(_filters.totalMin);
    }
    if (_filters.totalMax != null) {
      _totalMaxCtrl.text = _numText(_filters.totalMax);
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
    _hScroll.dispose();
    _vScroll.dispose();
    super.dispose();
  }

  bool get _departmentsEnabled => _env.departmentsEnabled();

  bool get _hasAnyFilters =>
      _filters.search.trim().isNotEmpty ||
      _filters.activeFilterCount > 0;

  static String _numText(double? v) {
    if (v == null) return '';
    return v == v.roundToDouble()
        ? v.toStringAsFixed(0)
        : v.toString();
  }

  Future<void> _load({
    required bool refreshFromStore,
  }) async {
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
    _signature = _env.signature();
    _allRows = PurchaseItemRowBuilder.buildAll(
      purchases: _env.purchases(),
      legacyLines: _env.legacyLines(),
      supplierNames: _env.supplierNames(),
      pendingDeletedUuids: _env.pendingDeletedUuids(),
    );
  }

  void _recompute() {
    _inPeriod = PurchaseItemFilterBuilder.inPeriod(
      _allRows,
      _period,
    );
    _itemOpts = PurchaseItemFilterBuilder.items(_inPeriod);
    _supplierOpts = PurchaseItemFilterBuilder.suppliers(
      _inPeriod,
    );
    _staffOpts = PurchaseItemFilterBuilder.staff(_inPeriod);
    _deptOpts = PurchaseItemFilterBuilder.departments(
      _inPeriod,
    );

    final filtered = PurchaseItemFilterBuilder.filter(
      _inPeriod,
      _filters,
      departmentsEnabled: _departmentsEnabled,
    );
    _sortedRows = PurchaseItemFilterBuilder.sort(
      filtered,
      _sortField,
      _ascending,
    );
    _totals = PurchaseItemFilterBuilder.totals(_sortedRows);
    if (_groupByItem) {
      final groups = PurchaseItemGrouping.build(
        _sortedRows,
        sortField: _groupSortField,
        ascending: _groupAscending,
      );
      _groupPageResult = PurchaseItemGrouping.paginate(
        groups,
        _page,
      );
      _page = _groupPageResult!.page;
      _pageResult = null;
    } else {
      _pageResult = PurchaseItemFilterBuilder.paginate(
        _sortedRows,
        _page,
      );
      _page = _pageResult!.page;
      _groupPageResult = null;
    }
  }

  void _apply(
    VoidCallback change, {
    bool resetPage = true,
  }) {
    setState(() {
      change();
      if (resetPage) _page = 1;
      _recompute();
    });
  }

  void _resetAll() {
    _searchCtrl.clear();
    _totalMinCtrl.clear();
    _totalMaxCtrl.clear();
    _apply(_filters.clearAll);
  }

  void _setSort(PurchaseItemSortField field) {
    _apply(() {
      if (_groupByItem) {
        if (_groupSortField == field) {
          _groupAscending = !_groupAscending;
        } else {
          _groupSortField = field;
          _groupAscending =
              field == PurchaseItemSortField.item;
        }
      } else {
        if (_sortField == field) {
          _ascending = !_ascending;
        } else {
          _sortField = field;
          _ascending =
              field == PurchaseItemSortField.item ||
              field == PurchaseItemSortField.supplier ||
              field == PurchaseItemSortField.staff;
        }
      }
    });
  }

  void _goToPage(int p) {
    _apply(() => _page = p, resetPage: false);
    if (_vScroll.hasClients) _vScroll.jumpTo(0);
  }

  String _money(num v) => _env.money(context, v);

  ReportExportSpec _exportSpec() {
    final showStorage =
        (shopSingle()?.manageInventoryStorage == true) ||
        _sortedRows.any((r) => r.isStorageItem);
    return buildPurchaseItemExportSpec(
      rows: _sortedRows,
      inPeriod: _inPeriod,
      filters: _filters,
      period: _period,
      departmentsEnabled: _departmentsEnabled,
      showStorageColumn: showStorage,
      f: ExportFormatter(
        currency: currencySymbol(context: context),
      ),
    );
  }

  Future<void> _openPurchase(TempPurchase purchase) async {
    await _env.openPurchase(context, purchase);
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

  String _optionLabel(
    List<PurchaseFilterOption> opts,
    String key,
  ) {
    return opts
            .where((o) => o.key == key)
            .firstOrNull
            ?.label ??
        key;
  }

  static Alignment _alignment(TextAlign align) {
    switch (align) {
      case TextAlign.start:
      case TextAlign.left:
        return Alignment.centerLeft;
      case TextAlign.end:
      case TextAlign.right:
        return Alignment.centerRight;
      case TextAlign.center:
      case TextAlign.justify:
        return Alignment.center;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = returnTheme(context);
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
        title: 'Purchase Item Report',
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
                : IconButton(
                  tooltip: 'Refresh',
                  icon: const Icon(
                    Icons.refresh_rounded,
                    size: 20,
                  ),
                  onPressed:
                      _loading
                          ? null
                          : () =>
                              _load(refreshFromStore: true),
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
            Expanded(child: _content(theme)),
            if (!_loading &&
                _error == null &&
                _groupByItem &&
                _groupPageResult != null)
              ReportPager(
                theme: theme,
                page: _groupPageResult!.page,
                totalPages: _groupPageResult!.totalPages,
                totalCount: _groupPageResult!.totalCount,
                firstIndex: _groupPageResult!.firstIndex,
                lastIndex: _groupPageResult!.lastIndex,
                itemLabel: 'items',
                onPage: _goToPage,
              ),
            if (!_loading &&
                _error == null &&
                !_groupByItem &&
                _pageResult != null)
              ReportPager(
                theme: theme,
                page: _pageResult!.page,
                totalPages: _pageResult!.totalPages,
                totalCount: _pageResult!.totalCount,
                firstIndex: _pageResult!.firstIndex,
                lastIndex: _pageResult!.lastIndex,
                itemLabel: 'item records',
                onPage: _goToPage,
              ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }

  Widget _toolbar(ThemeProvider theme) {
    final active = _filters.activeFilterCount;
    final accent = theme.lightModeColor.prColor300;
    final showActions =
        _toolbarIsOpen ||
        screenWidth(context) >= mobileScreen;
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
                              ? 'Search item, purchase ID, supplier, tracking or department'
                              : 'Search item, purchase ID, supplier or tracking',
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
                            _toolbarIsOpen
                                ? 'Hide'
                                : 'View',
                            style: TextStyle(
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b4
                                      .fontSize,
                            ),
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
        if (showActions) ...[
          ReceiptsReportPeriodButton(
            theme: theme,
            period: _period,
            enabled: _env.canPickDate(),
            onChanged: (p) {
              _apply(() => _period = p);
              if (!p.isAllTime) {
                _load(refreshFromStore: false);
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 6,
              right: 4,
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
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: ReportPill(
              theme: theme,
              icon: Icons.layers_outlined,
              label: 'Group by item',
              highlighted: _groupByItem,
              onTap:
                  () => _apply(
                    () => _groupByItem = !_groupByItem,
                  ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: ReportExportButton(
              buildSpec: _exportSpec,
            ),
          ),
          if (_hasAnyFilters)
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

  Widget _activeChips(ThemeProvider theme) {
    final chips = <Widget>[];
    void addChip(String label, VoidCallback onClear) {
      chips.add(
        Chip(
          label: Text(
            label,
            style: TextStyle(
              fontSize: theme.mobileTexts.b4.fontSize,
            ),
          ),
          deleteIcon: const Icon(Icons.close, size: 15),
          onDeleted: onClear,
          visualDensity: VisualDensity.compact,
          backgroundColor: Colors.grey.shade100,
          side: BorderSide(color: Colors.grey.shade300),
        ),
      );
    }

    if (_filters.itemKey != null) {
      addChip(
        'Item: ${_optionLabel(_itemOpts, _filters.itemKey!)}',
        () => _apply(() => _filters.itemKey = null),
      );
    }
    if (_filters.supplierKey != null) {
      addChip(
        'Supplier: ${_optionLabel(_supplierOpts, _filters.supplierKey!)}',
        () => _apply(() => _filters.supplierKey = null),
      );
    }
    if (_filters.staffKey != null) {
      addChip(
        'Staff: ${_optionLabel(_staffOpts, _filters.staffKey!)}',
        () => _apply(() => _filters.staffKey = null),
      );
    }
    if (_departmentsEnabled &&
        _filters.departmentKey != null) {
      addChip(
        'Dept: ${_optionLabel(_deptOpts, _filters.departmentKey!)}',
        () => _apply(() => _filters.departmentKey = null),
      );
    }
    if (_filters.channelKey != null) {
      addChip(
        'Channel: ${_optionLabel(PurchaseReportOptions.channels(), _filters.channelKey!)}',
        () => _apply(() => _filters.channelKey = null),
      );
    }
    if (_filters.status != null) {
      addChip(
        'Status: ${_filters.status!.label}',
        () => _apply(() => _filters.status = null),
      );
    }
    if (_filters.itemType != PurchaseItemTypeFilter.all) {
      addChip(
        'Type: ${_filters.itemType.label}',
        () => _apply(
          () =>
              _filters.itemType =
                  PurchaseItemTypeFilter.all,
        ),
      );
    }
    if (_filters.totalRangeActive) {
      addChip(
        'Total: ${_filters.totalMin != null ? _money(_filters.totalMin!) : 'Any'} - ${_filters.totalMax != null ? _money(_filters.totalMax!) : 'Any'}',
        () {
          _totalMinCtrl.clear();
          _totalMaxCtrl.clear();
          _apply(() {
            _filters.totalMin = null;
            _filters.totalMax = null;
          });
        },
      );
    }
    if (chips.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Wrap(
          spacing: 6,
          runSpacing: 6,
          children: chips,
        ),
      ),
    );
  }

  Widget _filterPanel(ThemeProvider theme) {
    Widget keyDropdown({
      required String title,
      required String allLabel,
      required String? value,
      required List<PurchaseFilterOption> options,
      required ValueChanged<String?> onChanged,
      bool showSearch = true,
    }) {
      return ReportLabeledField(
        label: title,
        width: 210,
        child: ReportSearchableDropdown<String?>(
          theme: theme,
          title: title,
          value: value,
          showSearch: showSearch,
          options: [
            ReportSearchableOption(
              value: null,
              label: allLabel,
            ),
            for (final o in options)
              ReportSearchableOption(
                value: o.key,
                label: o.label,
              ),
          ],
          onChanged: onChanged,
        ),
      );
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 10,
        children: [
          keyDropdown(
            title: 'Item',
            allLabel: 'All Items',
            value: _filters.itemKey,
            options: _itemOpts,
            onChanged:
                (v) => _apply(() => _filters.itemKey = v),
          ),
          keyDropdown(
            title: 'Supplier',
            allLabel: 'All Suppliers',
            value: _filters.supplierKey,
            options: _supplierOpts,
            onChanged:
                (v) =>
                    _apply(() => _filters.supplierKey = v),
          ),
          keyDropdown(
            title: 'Staff',
            allLabel: 'All Staff',
            value: _filters.staffKey,
            options: _staffOpts,
            onChanged:
                (v) => _apply(() => _filters.staffKey = v),
          ),
          if (_departmentsEnabled)
            keyDropdown(
              title: 'Department',
              allLabel: 'All Departments',
              value: _filters.departmentKey,
              options: _deptOpts,
              onChanged:
                  (v) => _apply(
                    () => _filters.departmentKey = v,
                  ),
            ),
          keyDropdown(
            title: 'Channel',
            allLabel: 'All Channels',
            value: _filters.channelKey,
            options: PurchaseReportOptions.channels(),
            showSearch: false,
            onChanged:
                (v) =>
                    _apply(() => _filters.channelKey = v),
          ),
          ReportLabeledField(
            label: 'Status',
            width: 190,
            child:
                ReportSearchableDropdown<PurchaseStatus?>(
                  theme: theme,
                  title: 'Status',
                  value: _filters.status,
                  showSearch: false,
                  options: [
                    const ReportSearchableOption(
                      value: null,
                      label: 'All Statuses',
                    ),
                    for (final s in PurchaseStatus.values)
                      ReportSearchableOption(
                        value: s,
                        label: s.label,
                      ),
                  ],
                  onChanged:
                      (v) =>
                          _apply(() => _filters.status = v),
                ),
          ),
          ReportLabeledField(
            label: 'Item Type',
            width: 190,
            child: ReportSearchableDropdown<
              PurchaseItemTypeFilter
            >(
              theme: theme,
              title: 'Item Type',
              value: _filters.itemType,
              showSearch: false,
              options: [
                for (final t
                    in PurchaseItemTypeFilter.values)
                  ReportSearchableOption(
                    value: t,
                    label: t.label,
                  ),
              ],
              onChanged:
                  (v) =>
                      _apply(() => _filters.itemType = v),
            ),
          ),
          ReportRangeFields(
            label: 'Line Total',
            minController: _totalMinCtrl,
            maxController: _totalMaxCtrl,
            errorText: _filters.totalRangeError,
            onChange: (minV, maxV) {
              _apply(() {
                _filters.totalMin = minV;
                _filters.totalMax = maxV;
              });
            },
          ),
        ],
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

    final count =
        _groupByItem
            ? _groupPageResult?.totalCount
            : _pageResult?.totalCount;
    if (count == null || count == 0) {
      return Padding(
        padding: const EdgeInsets.only(top: 60),
        child: EmptyWidgetDisplayOnly(
          title:
              _hasAnyFilters
                  ? 'No Matching Purchase Items'
                  : 'Empty List',
          subText:
              _hasAnyFilters
                  ? 'No purchase item matches your search and filters'
                  : 'No purchase item was recorded in this period',
          theme: theme,
          height: 35,
          icon: Icons.clear,
          altAction: _hasAnyFilters ? _resetAll : null,
          altActionText:
              _hasAnyFilters ? 'Clear all filters' : null,
          altIcon:
              _hasAnyFilters ? Icons.filter_alt_off : null,
        ),
      );
    }

    return _groupByItem
        ? _groupTable(theme, _groupPageResult!)
        : _table(theme, _pageResult!.rows);
  }

  Widget _txt(
    ThemeProvider theme,
    String text, {
    TextAlign align = TextAlign.center,
    Color? color,
    FontWeight? weight,
  }) {
    return Text(
      text,
      textAlign: align,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: theme.mobileTexts.b3.fontSize,
        color: color,
        fontWeight: weight,
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(24),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _statusColor(
    ThemeProvider theme,
    PurchaseStatus s,
  ) {
    switch (s) {
      case PurchaseStatus.paid:
        return Colors.green.shade700;
      case PurchaseStatus.partlyPaid:
        return Colors.orange.shade800;
      case PurchaseStatus.unpaid:
        return theme.lightModeColor.errorColor200;
    }
  }

  Widget _headerCell(
    ThemeProvider theme, {
    required String label,
    required double width,
    required TextAlign align,
    required PurchaseItemSortField? sort,
    required PurchaseItemSortField activeField,
    required bool ascending,
  }) {
    final isSorted = sort != null && sort == activeField;
    final accent = theme.lightModeColor.prColor300;
    final content = Row(
      mainAxisAlignment:
          align == TextAlign.start
              ? MainAxisAlignment.start
              : (align == TextAlign.end
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.center),
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
        if (sort != null)
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
      child: Align(
        alignment: _alignment(align),
        child: content,
      ),
    );
    return SizedBox(
      width: width,
      child:
          sort == null
              ? padded
              : InkWell(
                mouseCursor: SystemMouseCursors.click,
                onTap: () => _setSort(sort),
                child: padded,
              ),
    );
  }

  Widget _tableShell(
    ThemeProvider theme, {
    required double totalWidth,
    required Widget header,
    required Widget body,
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
                  (n) => n.metrics.axis == Axis.vertical,
              child: Scrollbar(
                controller: _hScroll,
                thumbVisibility: true,
                notificationPredicate:
                    (n) =>
                        n.metrics.axis == Axis.horizontal,
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
                          child: header,
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
                            child: body,
                          ),
                        ),
                        const Divider(height: 1),
                        Container(
                          height: 48,
                          color: theme
                              .lightModeColor
                              .prColor300
                              .withAlpha(18),
                          child: totals,
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

  Widget _groupTable(
    ThemeProvider theme,
    PurchaseItemGroupPage page,
  ) {
    final showStorage =
        (shopSingle()?.manageInventoryStorage == true) ||
        _allRows.any((r) => r.isStorageItem);
    Widget bold(
      String text, {
      TextAlign align = TextAlign.center,
    }) => _txt(
      theme,
      text,
      align: align,
      weight: FontWeight.bold,
    );

    final cols = <_GCol>[
      _GCol(
        label: 'Item',
        width: 220,
        align: TextAlign.start,
        sort: PurchaseItemSortField.item,
        cell:
            (r) => _txt(
              theme,
              r.itemName,
              align: TextAlign.start,
              weight: FontWeight.w500,
            ),
        total:
            (p) => bold(
              'Totals (${p.totalCount})',
              align: TextAlign.start,
            ),
      ),
      if (showStorage)
        _GCol(
          label: 'Type',
          width: 120,
          cell: (r) => _txt(theme, r.itemTypeLabel),
        ),
      _GCol(
        label: 'Unit',
        width: 100,
        cell: (r) => _txt(theme, r.unit),
      ),
      _GCol(
        label: 'Lines',
        width: 90,
        cell: (r) => _txt(theme, '${r.lineCount}'),
        total: (p) => bold('${p.totalLines}'),
      ),
      _GCol(
        label: 'Purchases',
        width: 100,
        cell: (r) => _txt(theme, '${r.purchaseCount}'),
      ),
      _GCol(
        label: 'Total Qty',
        width: 120,
        sort: PurchaseItemSortField.quantity,
        cell:
            (r) => _txt(
              theme,
              formatLargeNumberDouble(r.quantity),
            ),
        total:
            (p) => bold(
              formatLargeNumberDouble(p.totalQuantity),
            ),
      ),
      _GCol(
        label: 'Avg Unit Cost',
        width: 130,
        sort: PurchaseItemSortField.unitCost,
        cell: (r) => _txt(theme, _money(r.averageUnitCost)),
      ),
      _GCol(
        label: 'Total Spend',
        width: 140,
        sort: PurchaseItemSortField.total,
        cell:
            (r) => _txt(
              theme,
              _money(r.totalSpend),
              weight: FontWeight.w600,
            ),
        total: (p) => bold(_money(p.totalSpend)),
      ),
    ];

    final totalWidth = cols.fold<double>(
      0,
      (s, c) => s + c.width,
    );

    return _tableShell(
      theme,
      totalWidth: totalWidth,
      header: Row(
        children: [
          for (final c in cols)
            _headerCell(
              theme,
              label: c.label,
              width: c.width,
              align: c.align,
              sort: c.sort,
              activeField: _groupSortField,
              ascending: _groupAscending,
            ),
        ],
      ),
      body: ListView.builder(
        controller: _vScroll,
        itemCount: page.rows.length,
        itemExtent: 52,
        itemBuilder: (context, i) {
          final r = page.rows[i];
          return Material(
            color:
                i.isEven
                    ? Colors.white
                    : Colors.grey.shade50,
            child: InkWell(
              mouseCursor: SystemMouseCursors.click,
              hoverColor: theme.lightModeColor.prColor300
                  .withAlpha(20),
              onTap: () {
                _apply(() {
                  _filters.itemKey = r.itemKey;
                  _groupByItem = false;
                });
              },
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
          );
        },
      ),
      totals: Row(
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
                      c.total?.call(page) ??
                      const SizedBox.shrink(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _table(
    ThemeProvider theme,
    List<PurchaseItemRow> rows,
  ) {
    final showStorage =
        (shopSingle()?.manageInventoryStorage == true) ||
        _allRows.any((r) => r.isStorageItem);

    Widget bold(
      String text, {
      TextAlign align = TextAlign.center,
    }) => _txt(
      theme,
      text,
      align: align,
      weight: FontWeight.bold,
    );

    final cols = <_Col>[
      _Col(
        label: 'Item',
        width: 190,
        align: TextAlign.start,
        sort: PurchaseItemSortField.item,
        cell:
            (r) => _txt(
              theme,
              r.itemName,
              align: TextAlign.start,
              weight: FontWeight.w500,
            ),
        total:
            (_) => bold(
              'Totals (${_totals.lineCount})',
              align: TextAlign.start,
            ),
      ),
      if (showStorage)
        _Col(
          label: 'Type',
          width: 115,
          cell: (r) => _txt(theme, r.itemTypeLabel),
        ),
      _Col(
        label: 'Quantity',
        width: 95,
        sort: PurchaseItemSortField.quantity,
        cell:
            (r) => _txt(
              theme,
              formatLargeNumberDouble(r.quantity),
            ),
        total:
            (t) => bold(
              formatLargeNumberDouble(t.totalQuantity),
            ),
      ),
      _Col(
        label: 'Unit',
        width: 90,
        cell: (r) => _txt(theme, r.unit),
      ),
      _Col(
        label: 'Unit Cost',
        width: 120,
        sort: PurchaseItemSortField.unitCost,
        cell: (r) => _txt(theme, _money(r.unitCost)),
      ),
      _Col(
        label: 'Total',
        width: 130,
        sort: PurchaseItemSortField.total,
        cell:
            (r) => _txt(
              theme,
              _money(r.lineTotal),
              weight: FontWeight.w600,
            ),
        total: (t) => bold(_money(t.totalSpend)),
      ),
      _Col(
        label: 'Purchase ID',
        width: 135,
        sort: PurchaseItemSortField.purchaseId,
        cell:
            (r) => _txt(
              theme,
              r.purchaseDisplayId,
              color: theme.lightModeColor.prColor300,
              weight: FontWeight.w600,
            ),
      ),
      _Col(
        label: 'Global Supplier',
        width: 165,
        align: TextAlign.start,
        sort: PurchaseItemSortField.supplier,
        cell:
            (r) => _txt(
              theme,
              r.globalSupplierLabel,
              align: TextAlign.start,
              color:
                  r.globalSupplierKey == null
                      ? Colors.grey
                      : null,
            ),
      ),
      _Col(
        label: 'Item Supplier',
        width: 165,
        align: TextAlign.start,
        cell:
            (r) => _txt(
              theme,
              r.itemSupplierLabel,
              align: TextAlign.start,
              color:
                  r.itemSupplierKey == null
                      ? Colors.grey
                      : null,
            ),
      ),
      _Col(
        label: 'Global Tracking',
        width: 145,
        cell:
            (r) => _txt(
              theme,
              r.globalTrackingLabel,
              color:
                  r.globalTrackingNumber == null
                      ? Colors.grey
                      : null,
            ),
      ),
      _Col(
        label: 'Item Tracking',
        width: 145,
        cell:
            (r) => _txt(
              theme,
              r.itemTrackingLabel,
              color:
                  r.itemTrackingNumber == null
                      ? Colors.grey
                      : null,
            ),
      ),
      _Col(
        label: 'Custom Price',
        width: 105,
        cell:
            (r) => _txt(
              theme,
              r.customPriceLabel,
              color:
                  r.customPrice == null
                      ? Colors.grey
                      : null,
            ),
      ),
      _Col(
        label: 'Channel',
        width: 120,
        cell: (r) => _txt(theme, r.channelLabel),
      ),
      _Col(
        label: 'Status',
        width: 120,
        cell:
            (r) => _badge(
              r.status.label,
              _statusColor(theme, r.status),
            ),
      ),
      _Col(
        label: 'Staff',
        width: 145,
        align: TextAlign.start,
        sort: PurchaseItemSortField.staff,
        cell:
            (r) => _txt(
              theme,
              r.staffLabel,
              align: TextAlign.start,
            ),
      ),
      if (_departmentsEnabled)
        _Col(
          label: 'Department',
          width: 145,
          align: TextAlign.start,
          cell:
              (r) => _txt(
                theme,
                r.departmentLabel,
                align: TextAlign.start,
              ),
        ),
      _Col(
        label: 'Date',
        width: 120,
        sort: PurchaseItemSortField.createdAt,
        cell:
            (r) => _txt(theme, formatDateTime(r.createdAt)),
      ),
      _Col(
        label: 'Time',
        width: 95,
        cell: (r) => _txt(theme, formatTime(r.createdAt)),
      ),
    ];

    final totalWidth = cols.fold<double>(
      0,
      (s, c) => s + c.width,
    );

    return _tableShell(
      theme,
      totalWidth: totalWidth,
      header: Row(
        children: [
          for (final c in cols)
            _headerCell(
              theme,
              label: c.label,
              width: c.width,
              align: c.align,
              sort: c.sort,
              activeField: _sortField,
              ascending: _ascending,
            ),
        ],
      ),
      body: ListView.builder(
        controller: _vScroll,
        itemCount: rows.length,
        itemExtent: 52,
        itemBuilder: (context, i) {
          final r = rows[i];
          return Material(
            color:
                i.isEven
                    ? Colors.white
                    : Colors.grey.shade50,
            child: InkWell(
              mouseCursor: SystemMouseCursors.click,
              hoverColor: theme.lightModeColor.prColor300
                  .withAlpha(20),
              onTap: () => _openPurchase(r.parent.purchase),
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
          );
        },
      ),
      totals: Row(
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
                      c.total?.call(_totals) ??
                      const SizedBox.shrink(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
