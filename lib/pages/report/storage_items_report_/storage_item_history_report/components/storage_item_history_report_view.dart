import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stockall/classes/temp_storage_item_history/storage_item_history.dart';
import 'package:stockall/classes/temp_storage_item_history/storage_item_history_event_class.dart';
import 'package:stockall/components/alert_dialogues/dialog_template.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/components/buttons/main_button_transparent.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/products/storage_page/storage_details/storage_details_page.dart';
import 'package:stockall/pages/report/components/export/report_export_button.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/report_pager.dart';
import 'package:stockall/pages/report/components/report_pill.dart';
import 'package:stockall/pages/report/components/report_range_fields.dart';
import 'package:stockall/pages/report/components/report_searchable_dropdown.dart';
import 'package:stockall/pages/report/items_report_/item_history_report/class/item_history_report_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/components/receipts_report_filter_widgets.dart';
import 'package:stockall/pages/report/storage_items_report_/storage_item_history_report/class/storage_item_history_export_spec.dart';
import 'package:stockall/pages/report/storage_items_report_/storage_item_history_report/class/storage_item_history_report_logic.dart';
import 'package:stockall/providers/theme_provider.dart';

class _Col {
  final String label;
  final double width;
  final StorageItemHistorySortField? sort;
  final TextAlign align;
  final Widget Function(StorageItemHistory row, int index)
  cell;

  const _Col({
    required this.label,
    required this.width,
    required this.cell,
    this.sort,
    this.align = TextAlign.center,
  });
}

/// Shared body of the "Storage Item History Table" page (desktop + mobile).
class StorageItemHistoryReportView extends StatefulWidget {
  final bool isDesktop;

  /// Opens the table filtered to one storage item.
  final String? initialStorageItemUuid;

  /// Defaults to today's business day.
  final ReceiptsReportPeriod? initialPeriod;

  const StorageItemHistoryReportView({
    super.key,
    required this.isDesktop,
    this.initialStorageItemUuid,
    this.initialPeriod,
  });

  @override
  State<StorageItemHistoryReportView> createState() =>
      _StorageItemHistoryReportViewState();
}

class _StorageItemHistoryReportViewState
    extends State<StorageItemHistoryReportView> {
  final StorageItemHistoryReportFilters _filters =
      StorageItemHistoryReportFilters();
  final _searchCtrl = TextEditingController();
  final _hScroll = ScrollController();
  final _vScroll = ScrollController();

  StorageItemHistorySortField _sortField =
      StorageItemHistorySortField.createdAt;
  bool _ascending = false; // Default newest first
  int _page = 1;
  bool _showFilters = false;
  bool _toolbarIsOpen = false;
  late ReceiptsReportPeriod _period;

  bool _loading = true;
  String? _error;

  List<StorageItemHistory> _baseRecords = [];
  StorageItemHistoryReportPageResult? _result;
  String _signature = '';

  // Current names, for the renamed-item tooltip and the details link.
  final Map<String, String> _currentStorageNames = {};
  final Map<String, String> _currentSalesNames = {};

  // Filter options extracted from shop data and history: key -> label.
  final Map<String, String> _storageItemsMap = {};
  final Map<String, String> _salesItemsMap = {};
  final Map<String, String> _departmentsMap = {};
  final Map<String, String> _storekeepersMap = {};
  final Map<String, String> _otherStaffMap = {};
  final List<String> _eventsList = [];
  final List<String> _sourcesList = [];
  final List<String> _destinationsList = [];

  @override
  void initState() {
    super.initState();
    _filters.storageItemUuid =
        widget.initialStorageItemUuid;
    _period =
        widget.initialPeriod ??
        ReceiptsReportPeriod.today();
    _syncDateRange();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load(refreshFromStore: true);
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

  bool get _departmentsEnabled =>
      shopSingle()?.manageDepartments == true;

  bool get _canViewAllDepartments => authorization(
    authorized: Authorizations().viewAllDepartments,
  );

  bool get _canPickDate =>
      authorization(authorized: Authorizations().viewDate);

  String? get _currentDepartmentUuid =>
      returnDepartmentProvider().currentDepartment()?.uuid;

  Future<void> _load({
    required bool refreshFromStore,
  }) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final sId = shopId();
      final fetchAll = _period.isAllTime;
      final startDate = _period.start;
      final endDate = _period.end ?? _period.start;
      if (refreshFromStore) {
        await returnStorageProductProvider()
            .getStorageProducts(sId);
        await returnStorageItemHistoryProvider()
            .getItemHistories(
              startDate: startDate,
              endDate: endDate,
              fetchAll: fetchAll,
              forceRefresh: true,
            );
      } else {
        await returnStorageProductProvider()
            .getStorageProductsOffline(sId);
        await returnStorageItemHistoryProvider()
            .getItemHistoriesOffline();
        if (!fetchAll) {
          await returnStorageItemHistoryProvider()
              .getItemHistories(
                startDate: startDate,
                endDate: endDate,
                forceRefresh: false,
              );
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
    final list =
        returnStorageItemHistoryProvider()
            .storageItemHistories;
    int latest = 0;
    for (final h in list) {
      final t = h.createdAt?.millisecondsSinceEpoch ?? 0;
      if (t > latest) latest = t;
    }
    final storage =
        returnStorageProductProvider()
            .storageProductListMain;
    int latestStorage = 0;
    for (final s in storage) {
      final t = s.updatedAt?.millisecondsSinceEpoch ?? 0;
      if (t > latestStorage) latestStorage = t;
    }
    return '${list.length}|$latest|${storage.length}|$latestStorage|${shopId()}';
  }

  void _rebuildBase() {
    _baseRecords = scopeStorageItemHistories(
      all:
          returnStorageItemHistoryProvider()
              .storageItemHistories,
      shopId: shopId(),
      departmentsEnabled: _departmentsEnabled,
      canViewAllDepartments: _canViewAllDepartments,
      currentDepartmentUuid: _currentDepartmentUuid,
    );
    _extractFilterOptions();
    _signature = _sourceSignature();
  }

  void _extractFilterOptions() {
    _currentStorageNames.clear();
    _currentSalesNames.clear();
    _storageItemsMap.clear();
    _salesItemsMap.clear();
    _departmentsMap.clear();
    _storekeepersMap.clear();
    _otherStaffMap.clear();
    _eventsList.clear();
    _sourcesList.clear();
    _destinationsList.clear();

    for (final s
        in returnStorageProductProvider()
            .storageProductListMain) {
      final id = s.uuid;
      if (id == null || id.isEmpty) continue;
      _currentStorageNames[id] = s.name;
      _storageItemsMap[id] = s.name;
    }
    for (final p in returnData().productListMain) {
      final id = p.uuid;
      if (id == null || id.isEmpty) continue;
      _currentSalesNames[id] = p.name;
    }

    String? clean(String? s) {
      final t = s?.trim();
      return (t == null || t.isEmpty) ? null : t;
    }

    final eventsSet = <String>{
      ...storageItemHistoryKnownEvents,
    };
    final sourcesSet = <String>{
      StorageItemHistoryEventClass.manualSource,
      StorageItemHistoryEventClass.productSource,
      StorageItemHistoryEventClass.storageSource,
      StorageItemHistoryEventClass.purchaseSource,
    };
    final destinationsSet = <String>{
      StorageItemHistoryEventClass.storageDestination,
      StorageItemHistoryEventClass.productDestination,
      StorageItemHistoryEventClass.adjustmentDestination,
      StorageItemHistoryEventClass.purchaseDestination,
      StorageItemHistoryEventClass.deletedDestination,
    };

    for (final h in _baseRecords) {
      final storageId = clean(h.storageItemUuid);
      if (storageId != null) {
        _storageItemsMap.putIfAbsent(
          storageId,
          () => clean(h.storageItemName) ?? storageId,
        );
      }

      final salesId = clean(h.salesItemUuid);
      if (salesId != null) {
        _salesItemsMap.putIfAbsent(
          salesId,
          () =>
              _currentSalesNames[salesId] ??
              clean(h.salesItemName) ??
              salesId,
        );
      }

      final deptId = clean(h.salesDepartmentUuid);
      if (deptId != null) {
        _departmentsMap.putIfAbsent(
          deptId,
          () =>
              clean(h.salesDepartmentName) ?? 'Department',
        );
      }

      final keeper = StorageHistoryStaff.storekeeperKey(h);
      if (keeper != null) {
        _storekeepersMap.putIfAbsent(
          keeper,
          () => clean(h.storageStaffName) ?? keeper,
        );
      }

      final other = StorageHistoryStaff.otherStaffKey(h);
      if (other != null) {
        _otherStaffMap.putIfAbsent(
          other,
          () => clean(h.salesStaffName) ?? other,
        );
      }

      final event = clean(h.event);
      if (event != null) eventsSet.add(event);
      final source = clean(h.source);
      if (source != null) sourcesSet.add(source);
      final destination = clean(h.destination);
      if (destination != null)
        destinationsSet.add(destination);
    }

    // Departments from department provider
    for (final d
        in returnDepartmentProvider().departments) {
      if (d.uuid.isNotEmpty) {
        _departmentsMap[d.uuid] = d.name;
      }
    }

    int byLabel(String a, String b) =>
        a.toLowerCase().compareTo(b.toLowerCase());

    _eventsList
      ..addAll(eventsSet)
      ..sort(
        (a, b) => byLabel(
          StorageItemHistoryReportQuery.formatEventName(a),
          StorageItemHistoryReportQuery.formatEventName(b),
        ),
      );
    _sourcesList
      ..addAll(sourcesSet)
      ..sort(
        (a, b) => byLabel(
          StorageItemHistoryReportQuery.formatSourceOrDestination(
            a,
          ),
          StorageItemHistoryReportQuery.formatSourceOrDestination(
            b,
          ),
        ),
      );
    _destinationsList
      ..addAll(destinationsSet)
      ..sort(
        (a, b) => byLabel(
          StorageItemHistoryReportQuery.formatSourceOrDestination(
            a,
          ),
          StorageItemHistoryReportQuery.formatSourceOrDestination(
            b,
          ),
        ),
      );
  }

  void _syncDateRange() {
    _filters.dateRange =
        _period.isAllTime
            ? null
            : DateTimeRange(
              start: _period.start!,
              end: _period.end!,
            );
  }

  void _recompute() {
    final sorted =
        StorageItemHistoryReportQuery.filterAndSort(
          rows: _baseRecords,
          filters: _filters,
          sortField: _sortField,
          ascending: _ascending,
          departmentsEnabled: _departmentsEnabled,
        );
    _sortedRows = sorted;
    final page = StorageItemHistoryReportQuery.paginate(
      sorted,
      _page,
    );
    _page = page.page;
    _result = page;
  }

  // Every filtered, sorted record, for the export.
  List<StorageItemHistory> _sortedRows = [];

  ReportExportSpec _exportSpec() {
    return storageHistoryExportSpec(
      rows: _sortedRows,
      filters: _filters,
      names: StorageHistoryExportNames(
        storageItems: _storageItemsMap,
        salesItems: _salesItemsMap,
        departments: _departmentsMap,
        storekeepers: _storekeepersMap,
        otherStaff: _otherStaffMap,
        currentStorageNames: _currentStorageNames,
        currentSalesNames: _currentSalesNames,
      ),
      sortField: _sortField,
      ascending: _ascending,
      period: _period,
      departmentsEnabled: _departmentsEnabled,
      currency: currencySymbol(context: context),
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

  void _setSort(StorageItemHistorySortField f) {
    _apply(() {
      if (_sortField == f) {
        _ascending = !_ascending;
      } else {
        _sortField = f;
        _ascending = true;
      }
    });
  }

  void _setPeriod(ReceiptsReportPeriod p) {
    _apply(() {
      _period = p;
      _syncDateRange();
    });
    if (!p.isAllTime) {
      _load(refreshFromStore: false);
    }
  }

  void _resetAll() {
    _searchCtrl.clear();
    _apply(_filters.clearAll);
  }

  void _openStorageItem(String uuid) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                StorageDetailsPage(productUuid: uuid),
      ),
    );
  }

  void _openRecordDetails(StorageItemHistory row) {
    final theme = returnTheme(context, listen: false);
    final storageId = row.storageItemUuid;
    final exists =
        storageId != null &&
        _currentStorageNames.containsKey(storageId);
    showDialog(
      context: context,
      builder: (dialogContext) {
        return DialogTemplate(
          theme: theme,
          message: 'View Storage Item History Details',
          title: 'History Details',
          action: () {},
          showBottomActionButtons: false,
          widget: SizedBox(
            height: screenHeight(context) - 180,
            child: _StorageItemHistoryRecordDetailsModal(
              history: row,
              theme: theme,
              currentStorageName: currentNameIfDifferent(
                snapshotName: row.storageItemName,
                currentName:
                    _currentStorageNames[storageId],
              ),
              currentSalesName: currentNameIfDifferent(
                snapshotName: row.salesItemName,
                currentName:
                    _currentSalesNames[row.salesItemUuid],
              ),
              onViewItem:
                  exists
                      ? () {
                        Navigator.of(dialogContext).pop();
                        _openStorageItem(storageId);
                      }
                      : null,
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------
  // build
  // ---------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = returnTheme(context);

    // Pick up changes made elsewhere (sync, new events).
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
        title: 'Storage Item History Table',
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
                itemLabel: 'records',
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
      final canWiden = !_period.isAllTime && _canPickDate;
      return Padding(
        padding: const EdgeInsets.only(top: 60),
        child: EmptyWidgetDisplayOnly(
          title:
              hasFilters
                  ? 'No Matching Records'
                  : 'Empty List',
          subText:
              hasFilters
                  ? 'No storage history record matches your search and filters'
                  : !_period.isAllTime
                  ? 'No storage history was recorded for ${receiptsPeriodLabel(_period)}'
                  : 'No storage item history has been recorded yet',
          theme: theme,
          height: 35,
          icon: Icons.clear,
          altAction:
              hasFilters
                  ? _resetAll
                  : canWiden
                  ? () => _setPeriod(
                    const ReceiptsReportPeriod.allTime(),
                  )
                  : () => _load(refreshFromStore: true),
          altActionText:
              hasFilters
                  ? 'Clear all filters'
                  : canWiden
                  ? 'View all time'
                  : 'Refresh',
          altIcon:
              hasFilters
                  ? Icons.filter_alt_off
                  : canWiden
                  ? Icons.event_rounded
                  : Icons.refresh,
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
            width: widget.isDesktop ? 340 : double.infinity,
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
                          'Search item, staff, department, event...',
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
          Padding(
            padding: const EdgeInsets.only(right: 5),
            child: ReportExportButton(buildSpec: _exportSpec),
          ),
          if (_filters.hasAnything)
            ReportPill(
              theme: theme,
              icon: Icons.filter_alt_off,
              label: 'Reset Filter',
              onTap: _resetAll,
              color: accent,
            ),
        ],
      ],
    );
  }

  List<MapEntry<String, String>> _sortedEntries(
    Map<String, String> map,
  ) =>
      map.entries.toList()..sort(
        (a, b) => a.value.toLowerCase().compareTo(
          b.value.toLowerCase(),
        ),
      );

  Widget _keyDropdown({
    required ThemeProvider theme,
    required String title,
    required String allLabel,
    required String? value,
    required Map<String, String> options,
    required ValueChanged<String?> onChanged,
    String? noneLabel,
    double width = 220,
  }) {
    return ReportLabeledField(
      label: title,
      width: width,
      child: ReportSearchableDropdown<String?>(
        title: title,
        value: value,
        options: [
          ReportSearchableOption<String?>(
            value: null,
            label: allLabel,
          ),
          if (noneLabel != null)
            ReportSearchableOption<String?>(
              value: storageItemHistoryReportNoneKey,
              label: noneLabel,
            ),
          ..._sortedEntries(options).map(
            (e) => ReportSearchableOption<String?>(
              value: e.key,
              label: e.value,
            ),
          ),
        ],
        onChanged: (v) => _apply(() => onChanged(v)),
        theme: theme,
        searchHint: 'Search ${title.toLowerCase()}...',
      ),
    );
  }

  Widget _listDropdown({
    required ThemeProvider theme,
    required String title,
    required String allLabel,
    required String? value,
    required List<String> options,
    required String Function(String) format,
    required ValueChanged<String?> onChanged,
  }) {
    return ReportLabeledField(
      label: title,
      width: 180,
      child: ReportSearchableDropdown<String?>(
        title: title,
        value: value,
        options: [
          ReportSearchableOption<String?>(
            value: null,
            label: allLabel,
          ),
          ...options.map(
            (e) => ReportSearchableOption<String?>(
              value: e,
              label: format(e),
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
            title: 'Storage Item',
            allLabel: 'All storage items',
            value: _filters.storageItemUuid,
            options: _storageItemsMap,
            onChanged: (v) => _filters.storageItemUuid = v,
          ),
          _keyDropdown(
            theme: theme,
            title: 'Sales Item',
            allLabel: 'All sales items',
            noneLabel: 'No Sales Item',
            value: _filters.salesItemUuid,
            options: _salesItemsMap,
            onChanged: (v) => _filters.salesItemUuid = v,
          ),
          if (_departmentsEnabled)
            _keyDropdown(
              theme: theme,
              title: 'Department',
              allLabel: 'All departments',
              noneLabel: 'No Department',
              value: _filters.departmentUuid,
              options: _departmentsMap,
              onChanged: (v) => _filters.departmentUuid = v,
              width: 180,
            ),
          _keyDropdown(
            theme: theme,
            title: 'Storekeeper',
            allLabel: 'All storekeepers',
            value: _filters.storekeeperKey,
            options: _storekeepersMap,
            onChanged: (v) => _filters.storekeeperKey = v,
            width: 180,
          ),
          _keyDropdown(
            theme: theme,
            title: 'Other Staff',
            allLabel: 'All staff',
            noneLabel: 'No Other Staff',
            value: _filters.otherStaffKey,
            options: _otherStaffMap,
            onChanged: (v) => _filters.otherStaffKey = v,
            width: 180,
          ),
          _listDropdown(
            theme: theme,
            title: 'Event',
            allLabel: 'All events',
            value: _filters.event,
            options: _eventsList,
            format:
                StorageItemHistoryReportQuery
                    .formatEventName,
            onChanged: (v) => _filters.event = v,
          ),
          _listDropdown(
            theme: theme,
            title: 'Source',
            allLabel: 'All sources',
            value: _filters.source,
            options: _sourcesList,
            format:
                StorageItemHistoryReportQuery
                    .formatSourceOrDestination,
            onChanged: (v) => _filters.source = v,
          ),
          _listDropdown(
            theme: theme,
            title: 'Destination',
            allLabel: 'All destinations',
            value: _filters.destination,
            options: _destinationsList,
            format:
                StorageItemHistoryReportQuery
                    .formatSourceOrDestination,
            onChanged: (v) => _filters.destination = v,
          ),
          ReportLabeledField(
            label: 'Quantity Change',
            width: 180,
            child: ReportSearchableDropdown<
              QuantityDirectionFilter
            >(
              title: 'Quantity Change',
              value: _filters.quantityDirection,
              showSearch: false,
              highlighted:
                  _filters.quantityDirection !=
                  QuantityDirectionFilter.all,
              options: const [
                ReportSearchableOption(
                  value: QuantityDirectionFilter.all,
                  label: 'All Changes',
                ),
                ReportSearchableOption(
                  value: QuantityDirectionFilter.increase,
                  label: 'Quantity Increase',
                ),
                ReportSearchableOption(
                  value: QuantityDirectionFilter.decrease,
                  label: 'Quantity Decrease',
                ),
                ReportSearchableOption(
                  value: QuantityDirectionFilter.zeroChange,
                  label: 'No Change (0)',
                ),
              ],
              onChanged:
                  (v) => _apply(
                    () => _filters.quantityDirection = v,
                  ),
              theme: theme,
            ),
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
          onDeleted: () => _apply(onRemove),
          deleteIcon: const Icon(Icons.close, size: 12),
          visualDensity: VisualDensity.compact,
          backgroundColor: theme.lightModeColor.prColor300
              .withAlpha(25),
          side: BorderSide.none,
        );

    String keyLabel(
      String key,
      Map<String, String> map,
      String fallback, {
      String? noneLabel,
    }) {
      if (key == storageItemHistoryReportNoneKey) {
        return noneLabel ?? fallback;
      }
      return map[key] ?? fallback;
    }

    if (_filters.storageItemUuid != null) {
      chips.add(
        chip(
          'Storage Item: ${keyLabel(_filters.storageItemUuid!, _storageItemsMap, 'Item')}',
          () => _filters.storageItemUuid = null,
        ),
      );
    }
    if (_filters.salesItemUuid != null) {
      chips.add(
        chip(
          'Sales Item: ${keyLabel(_filters.salesItemUuid!, _salesItemsMap, 'Item', noneLabel: 'None')}',
          () => _filters.salesItemUuid = null,
        ),
      );
    }
    if (_departmentsEnabled &&
        _filters.departmentUuid != null) {
      chips.add(
        chip(
          'Department: ${keyLabel(_filters.departmentUuid!, _departmentsMap, 'Department', noneLabel: 'No Department')}',
          () => _filters.departmentUuid = null,
        ),
      );
    }
    if (_filters.storekeeperKey != null) {
      chips.add(
        chip(
          'Storekeeper: ${keyLabel(_filters.storekeeperKey!, _storekeepersMap, 'Staff')}',
          () => _filters.storekeeperKey = null,
        ),
      );
    }
    if (_filters.otherStaffKey != null) {
      chips.add(
        chip(
          'Other Staff: ${keyLabel(_filters.otherStaffKey!, _otherStaffMap, 'Staff', noneLabel: 'None')}',
          () => _filters.otherStaffKey = null,
        ),
      );
    }
    if (_filters.event != null) {
      chips.add(
        chip(
          'Event: ${StorageItemHistoryReportQuery.formatEventName(_filters.event!)}',
          () => _filters.event = null,
        ),
      );
    }
    if (_filters.source != null) {
      chips.add(
        chip(
          'Source: ${StorageItemHistoryReportQuery.formatSourceOrDestination(_filters.source!)}',
          () => _filters.source = null,
        ),
      );
    }
    if (_filters.destination != null) {
      chips.add(
        chip(
          'Destination: ${StorageItemHistoryReportQuery.formatSourceOrDestination(_filters.destination!)}',
          () => _filters.destination = null,
        ),
      );
    }
    if (_filters.quantityDirection !=
        QuantityDirectionFilter.all) {
      final label = switch (_filters.quantityDirection) {
        QuantityDirectionFilter.increase =>
          'Direction: Increase',
        QuantityDirectionFilter.decrease =>
          'Direction: Decrease',
        QuantityDirectionFilter.zeroChange =>
          'Direction: No Change',
        _ => '',
      };
      chips.add(
        chip(
          label,
          () =>
              _filters.quantityDirection =
                  QuantityDirectionFilter.all,
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
    final notes = storageHistoryNotes(allTime: _period.isAllTime);
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
                  color: Colors.grey.shade600,
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
    TextAlign align = TextAlign.start,
  }) => Text(
    text,
    maxLines: 2,
    overflow: TextOverflow.ellipsis,
    textAlign: align,
    style: _cellStyle(theme, bold: bold, color: color),
  );

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

  String _orDash(String? s) {
    final t = s?.trim();
    return (t == null || t.isEmpty) ? '—' : t;
  }

  /// History snapshot name, with the current name in a tooltip when
  /// the item has been renamed since.
  Widget _nameCell(
    ThemeProvider theme,
    String? snapshot,
    String? current,
  ) {
    final now = currentNameIfDifferent(
      snapshotName: snapshot,
      currentName: current,
    );
    final text = _txt(
      theme,
      _orDash(snapshot ?? now),
      bold: true,
    );
    if (now == null || snapshot == null) return text;
    return Tooltip(
      message: 'Now named: $now',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          Flexible(child: text),
          Icon(
            Icons.info_outline_rounded,
            size: 13,
            color: Colors.grey.shade600,
          ),
        ],
      ),
    );
  }

  Widget _quantityChangeCell(
    ThemeProvider theme,
    StorageItemHistory r,
  ) {
    if (r.quantityChange == null) {
      return _txt(
        theme,
        'N/A',
        color: Colors.grey,
        align: TextAlign.center,
      );
    }

    final formatted = returnHistoryQuantity(
      quantityChange: r.quantityChange,
      isIncreased: r.isIncreased,
      unit: r.storageUnit,
      primaryUnit: r.storagePrimaryUnit,
      oldValue: r.storageItemOldValue,
      newValue: r.storageItemNewValue,
    );

    final up =
        r.isIncreased ?? ((r.quantityChange ?? 0) > 0);
    final isZero = (r.quantityChange ?? 0) == 0;
    return _txt(
      theme,
      formatted,
      bold: true,
      color:
          isZero
              ? Colors.grey.shade700
              : (up
                  ? Colors.green.shade700
                  : theme.lightModeColor.errorColor200),
      align: TextAlign.center,
    );
  }

  Widget _valueCell(
    ThemeProvider theme,
    String? value,
    String? unit,
  ) {
    if (value == null || value.trim().isEmpty) {
      return _txt(theme, '—', align: TextAlign.center);
    }
    final u = unit?.trim();
    return _txt(
      theme,
      (u == null || u.isEmpty) ? value : '$value $u',
      align: TextAlign.center,
    );
  }

  List<_Col> _columns(ThemeProvider theme, int pageStart) {
    const dash = '—';
    return [
      _Col(
        label: 'No.',
        width: 60,
        cell:
            (r, i) => _txt(
              theme,
              '${pageStart + i}',
              bold: true,
              align: TextAlign.center,
            ),
      ),
      _Col(
        label: 'Storage Item',
        width: 200,
        sort: StorageItemHistorySortField.storageItemName,
        align: TextAlign.start,
        cell:
            (r, i) => _nameCell(
              theme,
              r.storageItemName,
              _currentStorageNames[r.storageItemUuid],
            ),
      ),
      _Col(
        label: 'Created Date',
        width: 170,
        sort: StorageItemHistorySortField.createdAt,
        align: TextAlign.start,
        cell:
            (r, i) => _txt(
              theme,
              r.createdAt != null
                  ? formatDateWithTime(r.createdAt!)
                  : dash,
            ),
      ),
      _Col(
        label: 'Sales Item',
        width: 180,
        sort: StorageItemHistorySortField.salesItemName,
        align: TextAlign.start,
        cell:
            (r, i) => _nameCell(
              theme,
              r.salesItemName,
              _currentSalesNames[r.salesItemUuid],
            ),
      ),
      if (_departmentsEnabled)
        _Col(
          label: 'Department',
          width: 150,
          sort: StorageItemHistorySortField.departmentName,
          cell:
              (r, i) => _txt(
                theme,
                _orDash(r.salesDepartmentName),
                align: TextAlign.center,
              ),
        ),
      _Col(
        label: 'History Title',
        width: 170,
        sort: StorageItemHistorySortField.title,
        align: TextAlign.start,
        cell:
            (r, i) =>
                _txt(theme, _orDash(r.title), bold: true),
      ),
      _Col(
        label: 'Event',
        width: 150,
        sort: StorageItemHistorySortField.event,
        cell: (r, i) {
          if (r.event == null || r.event!.isEmpty) {
            return _txt(
              theme,
              dash,
              align: TextAlign.center,
            );
          }
          return Center(
            child: _badge(
              StorageItemHistoryReportQuery.formatEventName(
                r.event!,
              ),
              Colors.blueGrey,
            ),
          );
        },
      ),
      _Col(
        label: 'Source',
        width: 120,
        sort: StorageItemHistorySortField.source,
        cell:
            (r, i) => _txt(
              theme,
              (r.source != null && r.source!.isNotEmpty)
                  ? StorageItemHistoryReportQuery.formatSourceOrDestination(
                    r.source!,
                  )
                  : dash,
              align: TextAlign.center,
            ),
      ),
      _Col(
        label: 'Destination',
        width: 120,
        sort: StorageItemHistorySortField.destination,
        cell:
            (r, i) => _txt(
              theme,
              (r.destination != null &&
                      r.destination!.isNotEmpty)
                  ? StorageItemHistoryReportQuery.formatSourceOrDestination(
                    r.destination!,
                  )
                  : dash,
              align: TextAlign.center,
            ),
      ),
      _Col(
        label: 'Supplier',
        width: 170,
        sort: StorageItemHistorySortField.supplier,
        align: TextAlign.start,
        cell:
            (r, i) => _txt(
              theme,
              _orDash(r.supplier),
              align: TextAlign.start,
            ),
      ),
      _Col(
        label: 'Tracking Number',
        width: 160,
        sort: StorageItemHistorySortField.trackingNumber,
        align: TextAlign.center,
        cell:
            (r, i) => _txt(
              theme,
              _orDash(r.trackingNumber),
              align: TextAlign.center,
            ),
      ),
      _Col(
        label: 'Description',
        width: 220,
        sort: StorageItemHistorySortField.desc,
        align: TextAlign.start,
        cell: (r, i) => _txt(theme, _orDash(r.desc)),
      ),
      _Col(
        label: 'Quantity Change',
        width: 150,
        sort: StorageItemHistorySortField.quantityChange,
        cell: (r, i) => _quantityChangeCell(theme, r),
      ),
      _Col(
        label: 'Unit',
        width: 110,
        sort: StorageItemHistorySortField.unit,
        cell:
            (r, i) => _txt(
              theme,
              StorageItemHistoryReportQuery.quantityChangeUnit(
                    r,
                  ) ??
                  dash,
              align: TextAlign.center,
            ),
      ),
      _Col(
        label: 'Storage Old',
        width: 130,
        sort: StorageItemHistorySortField.storageOldValue,
        cell:
            (r, i) => _valueCell(
              theme,
              r.storageItemOldValue,
              r.storagePrimaryUnit,
            ),
      ),
      _Col(
        label: 'Storage New',
        width: 130,
        sort: StorageItemHistorySortField.storageNewValue,
        cell:
            (r, i) => _valueCell(
              theme,
              r.storageItemNewValue,
              r.storagePrimaryUnit,
            ),
      ),
      _Col(
        label: 'Primary Unit',
        width: 120,
        sort:
            StorageItemHistorySortField.storagePrimaryUnit,
        cell:
            (r, i) => _txt(
              theme,
              _orDash(r.storagePrimaryUnit),
              align: TextAlign.center,
            ),
      ),
      // Sales values are stored in base units (area for 2D items), so
      // they are shown without the primary unit label.
      _Col(
        label: 'Sales Old',
        width: 110,
        sort: StorageItemHistorySortField.salesOldValue,
        cell:
            (r, i) => _valueCell(
              theme,
              r.salesItemOldValue,
              null,
            ),
      ),
      _Col(
        label: 'Sales New',
        width: 110,
        sort: StorageItemHistorySortField.salesNewValue,
        cell:
            (r, i) => _valueCell(
              theme,
              r.salesItemNewValue,
              null,
            ),
      ),
      _Col(
        label: 'Storekeeper',
        width: 160,
        sort: StorageItemHistorySortField.storekeeperName,
        align: TextAlign.start,
        cell:
            (r, i) =>
                _txt(theme, _orDash(r.storageStaffName)),
      ),
      _Col(
        label: 'Other Staff',
        width: 160,
        sort: StorageItemHistorySortField.otherStaffName,
        align: TextAlign.start,
        cell:
            (r, i) =>
                _txt(theme, _orDash(r.salesStaffName)),
      ),
    ];
  }

  Widget _headerCell(ThemeProvider theme, _Col c) {
    final accent = theme.lightModeColor.prColor300;
    final isSorted = c.sort != null && c.sort == _sortField;
    final isCenter = c.align == TextAlign.center;
    final label = Flexible(
      child: Text(
        c.label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: theme.mobileTexts.b3.fontSize,
          fontWeight: FontWeight.bold,
          color: isSorted ? accent : Colors.black87,
        ),
      ),
    );
    final content = Row(
      mainAxisAlignment:
          isCenter
              ? MainAxisAlignment.center
              : MainAxisAlignment.start,
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
    final aligned = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Align(
        alignment:
            isCenter
                ? Alignment.center
                : Alignment.centerLeft,
        child: content,
      ),
    );
    return SizedBox(
      width: c.width,
      child:
          c.sort == null
              ? aligned
              : InkWell(
                mouseCursor: SystemMouseCursors.click,
                onTap: () => _setSort(c.sort!),
                child: aligned,
              ),
    );
  }

  Widget _table(
    ThemeProvider theme,
    StorageItemHistoryReportPageResult res,
  ) {
    final cols = _columns(theme, res.firstIndex);
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
                            children:
                                cols
                                    .map(
                                      (c) => _headerCell(
                                        theme,
                                        c,
                                      ),
                                    )
                                    .toList(),
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
                              itemBuilder: (context, i) {
                                final r = res.rows[i];
                                return Material(
                                  color:
                                      i.isEven
                                          ? Colors.white
                                          : Colors
                                              .grey
                                              .shade50,
                                  child: InkWell(
                                    mouseCursor:
                                        SystemMouseCursors
                                            .click,
                                    hoverColor: theme
                                        .lightModeColor
                                        .prColor300
                                        .withAlpha(20),
                                    onTap:
                                        () =>
                                            _openRecordDetails(
                                              r,
                                            ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color:
                                                Colors
                                                    .grey
                                                    .shade100,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        children:
                                            cols.map((c) {
                                              final isCenter =
                                                  c.align ==
                                                  TextAlign
                                                      .center;
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
                                                        isCenter
                                                            ? Alignment.center
                                                            : Alignment.centerLeft,
                                                    child: c
                                                        .cell(
                                                          r,
                                                          i,
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

/// Detailed modal presenting every field of a [StorageItemHistory] record.
class _StorageItemHistoryRecordDetailsModal
    extends StatelessWidget {
  final StorageItemHistory history;
  final ThemeProvider theme;
  final String? currentStorageName;
  final String? currentSalesName;
  final VoidCallback? onViewItem;

  const _StorageItemHistoryRecordDetailsModal({
    required this.history,
    required this.theme,
    this.currentStorageName,
    this.currentSalesName,
    this.onViewItem,
  });

  Widget _entry({
    required String title,
    required String value,
    bool isSelectable = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(
              10,
              7,
              10,
              5,
            ),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(5),
                topRight: Radius.circular(5),
              ),
              color: Colors.grey.shade200,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '$title:',
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.b4.fontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade900,
                    ),
                  ),
                ),
                if (isSelectable)
                  InkWell(
                    mouseCursor: SystemMouseCursors.click,
                    onTap: () {
                      Clipboard.setData(
                        ClipboardData(text: value),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4.0,
                      ),
                      child: Row(
                        spacing: 2,
                        children: [
                          Icon(
                            Icons.copy_rounded,
                            size: 12,
                            color: Colors.grey.shade700,
                          ),
                          Text(
                            'Copy',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(
              10,
              5,
              10,
              8,
            ),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(2),
                bottomRight: Radius.circular(2),
              ),
              color: Colors.grey.shade100,
            ),
            child:
                isSelectable
                    ? SelectableText(
                      value,
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b3.fontSize,
                        fontFamily: 'monospace',
                        color: Colors.grey.shade800,
                      ),
                    )
                    : Text(
                      value,
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b3.fontSize,
                        fontWeight: FontWeight.normal,
                        color: Colors.grey.shade800,
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  String _orDash(String? s) {
    final t = s?.trim();
    return (t == null || t.isEmpty) ? '—' : t;
  }

  String _withUnit(String? value, String? unit) {
    final v = value?.trim();
    if (v == null || v.isEmpty) return '—';
    final u = unit?.trim();
    return (u == null || u.isEmpty) ? v : '$v $u';
  }

  String _named(String? snapshot, String? current) {
    final name = _orDash(snapshot);
    return current == null ? name : '$name (now: $current)';
  }

  @override
  Widget build(BuildContext context) {
    const dash = '—';
    final unit =
        StorageItemHistoryReportQuery.quantityChangeUnit(
          history,
        );
    final qtyStr =
        history.quantityChange != null
            ? returnHistoryQuantity(
              quantityChange: history.quantityChange,
              isIncreased: history.isIncreased,
              unit: history.storageUnit,
              primaryUnit: history.storagePrimaryUnit,
              oldValue: history.storageItemOldValue,
              newValue: history.storageItemNewValue,
            )
            : 'N/A';
    final directionStr =
        history.isIncreased == true
            ? 'Increase (+)'
            : (history.isIncreased == false
                ? 'Decrease (-)'
                : 'N/A');

    return Scaffold(
      body: Column(
        children: [
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                vertical: 6,
              ),
              children: [
                _entry(
                  title: 'Storage Item',
                  value: _named(
                    history.storageItemName,
                    currentStorageName,
                  ),
                ),
                _entry(
                  title: 'Sales Item',
                  value: _named(
                    history.salesItemName,
                    currentSalesName,
                  ),
                ),
                _entry(
                  title: 'Department',
                  value: _orDash(
                    history.salesDepartmentName,
                  ),
                ),
                _entry(
                  title: 'History Title',
                  value: history.title,
                ),
                _entry(
                  title: 'Event Type',
                  value:
                      history.event != null
                          ? StorageItemHistoryReportQuery.formatEventName(
                            history.event!,
                          )
                          : dash,
                ),
                _entry(
                  title: 'Description',
                  value: _orDash(history.desc),
                ),
                _entry(
                  title: 'Source',
                  value:
                      (history.source != null &&
                              history.source!.isNotEmpty)
                          ? StorageItemHistoryReportQuery.formatSourceOrDestination(
                            history.source!,
                          )
                          : dash,
                ),
                _entry(
                  title: 'Destination',
                  value:
                      (history.destination != null &&
                              history
                                  .destination!
                                  .isNotEmpty)
                          ? StorageItemHistoryReportQuery.formatSourceOrDestination(
                            history.destination!,
                          )
                          : dash,
                ),
                _entry(
                  title: 'Supplier Name',
                  value: _orDash(history.supplierName ?? history.supplier),
                ),
                _entry(
                  title: 'Tracking Number',
                  value: _orDash(history.trackingNumber),
                  isSelectable: true,
                ),
                _entry(
                  title: 'Quantity Change',
                  value: qtyStr,
                ),
                _entry(
                  title: 'Direction',
                  value: directionStr,
                ),
                _entry(
                  title: 'Storage Old Value',
                  value: _withUnit(
                    history.storageItemOldValue,
                    history.storagePrimaryUnit,
                  ),
                ),
                _entry(
                  title: 'Storage New Value',
                  value: _withUnit(
                    history.storageItemNewValue,
                    history.storagePrimaryUnit,
                  ),
                ),
                _entry(
                  title: 'Storage Unit',
                  value: unit ?? dash,
                ),
                _entry(
                  title: 'Storage Primary Unit',
                  value: _orDash(
                    history.storagePrimaryUnit,
                  ),
                ),
                _entry(
                  title: 'Sales Old Value',
                  value: _orDash(history.salesItemOldValue),
                ),
                _entry(
                  title: 'Sales New Value',
                  value: _orDash(history.salesItemNewValue),
                ),
                _entry(
                  title: 'Sales Unit',
                  value: _orDash(history.salesUnit),
                ),
                _entry(
                  title: 'Sales Primary Unit',
                  value: _orDash(history.salesPrimaryUnit),
                ),
                _entry(
                  title: 'Storekeeper',
                  value: _orDash(history.storageStaffName),
                ),
                _entry(
                  title: 'Other Staff',
                  value: _orDash(history.salesStaffName),
                ),
                _entry(
                  title: 'Created Date & Time',
                  value:
                      history.createdAt != null
                          ? formatDateWithTime(
                            history.createdAt!,
                          )
                          : dash,
                ),
                const SizedBox(height: 10),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 4,
                  ),
                  child: Text(
                    'Technical Identifiers',
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.b4.fontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                _entry(
                  title: 'History UUID',
                  value: history.uuid ?? dash,
                  isSelectable: true,
                ),
                _entry(
                  title: 'Shop ID',
                  value: '${history.shopId}',
                  isSelectable: true,
                ),
                _entry(
                  title: 'Storage Item UUID',
                  value: history.storageItemUuid ?? dash,
                  isSelectable: true,
                ),
                _entry(
                  title: 'Sales Item UUID',
                  value: history.salesItemUuid ?? dash,
                  isSelectable: true,
                ),
                _entry(
                  title: 'Storekeeper ID',
                  value: history.storageStaffId ?? dash,
                  isSelectable: true,
                ),
                _entry(
                  title: 'Other Staff ID',
                  value: history.salesStaffUuid ?? dash,
                  isSelectable: true,
                ),
                _entry(
                  title: 'Sales Department UUID',
                  value:
                      history.salesDepartmentUuid ?? dash,
                  isSelectable: true,
                ),
                if (history.supplierUuid != null &&
                    history.supplierUuid!.isNotEmpty)
                  _entry(
                    title: 'Supplier UUID',
                    value: history.supplierUuid!,
                    isSelectable: true,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          if (onViewItem != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: MainButtonP(
                themeProvider: theme,
                action: onViewItem!,
                text: 'View Storage Item',
              ),
            ),
          MainButtonTransparent(
            themeProvider: theme,
            constraints: const BoxConstraints(),
            text: 'Close',
            action: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
