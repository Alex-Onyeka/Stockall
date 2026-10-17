import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stockall/classes/temp_item_history/item_history.dart';
import 'package:stockall/classes/temp_item_history/item_history_event_class.dart';
import 'package:stockall/components/alert_dialogues/dialog_template.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/components/buttons/main_button_transparent.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/date_picker_function.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/products/product_details/product_details_page.dart';
import 'package:stockall/pages/report/item_history_report/class/item_history_report_logic.dart';
import 'package:stockall/providers/theme_provider.dart';

class _Col {
  final String label;
  final double width;
  final ItemHistorySortField? sort;
  final TextAlign align;
  final Widget Function(ItemHistory row, int index) cell;

  const _Col({
    required this.label,
    required this.width,
    required this.cell,
    this.sort,
    this.align = TextAlign.center,
  });
}

/// Shared body of the "Item History Table" page (desktop + mobile).
class ItemHistoryReportView extends StatefulWidget {
  final bool isDesktop;
  const ItemHistoryReportView({
    super.key,
    required this.isDesktop,
  });

  @override
  State<ItemHistoryReportView> createState() =>
      _ItemHistoryReportViewState();
}

class _ItemHistoryReportViewState
    extends State<ItemHistoryReportView> {
  final ItemHistoryReportFilters _filters =
      ItemHistoryReportFilters();
  final _searchCtrl = TextEditingController();
  final _hScroll = ScrollController();
  final _vScroll = ScrollController();

  ItemHistorySortField _sortField =
      ItemHistorySortField.createdAt;
  bool _ascending = false; // Default newest first
  int _page = 1;
  bool _showFilters = false;

  bool _loading = true;
  String? _error;

  List<ItemHistory> _baseRecords = [];
  ItemHistoryReportPageResult? _result;
  String _signature = '';

  // Cached filter option collections extracted from shop data and history
  final Map<String, String> _itemsMap =
      {}; // itemUuid -> itemName
  final List<String> _eventsList = [];
  final Map<String, String> _staffMap =
      {}; // staffId -> staffName
  final List<String> _sourcesList = [];
  final List<String> _destinationsList = [];
  final Map<String, String> _departmentsMap =
      {}; // deptUuid -> deptName

  @override
  void initState() {
    super.initState();
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

  bool get _departmentsEnabled =>
      shopSingle()?.manageDepartments == true;

  bool get _canViewAllDepartments => authorization(
    authorized: Authorizations().viewAllDepartments,
  );

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
      if (refreshFromStore) {
        await returnItemHistoryProvider()
            .getItemHistories();
      } else {
        await returnItemHistoryProvider()
            .getItemHistoriesOffline();
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
    final list = returnItemHistoryProvider().itemHistories;
    int latest = 0;
    for (final h in list) {
      final t = h.createdAt?.millisecondsSinceEpoch ?? 0;
      if (t > latest) latest = t;
    }
    return '${list.length}|$latest|${shopId()}';
  }

  void _rebuildBase() {
    final currentShopId = shopId();
    final all = returnItemHistoryProvider().itemHistories;

    // 1. Scoped strictly to the current shop using shopId
    final shopRecords =
        all
            .where((h) => h.shopId == currentShopId)
            .toList();

    // 2. Department access rules
    if (_departmentsEnabled && !_canViewAllDepartments) {
      _baseRecords =
          shopRecords
              .where(
                (h) =>
                    h.departmentUuid ==
                    _currentDepartmentUuid,
              )
              .toList();
    } else {
      _baseRecords = shopRecords;
    }

    _extractFilterOptions();
    _signature = _sourceSignature();
  }

  void _extractFilterOptions() {
    _itemsMap.clear();
    _eventsList.clear();
    _staffMap.clear();
    _sourcesList.clear();
    _destinationsList.clear();
    _departmentsMap.clear();

    // Items from current products
    for (final p in returnData().productList()) {
      if (p.uuid != null && p.uuid!.isNotEmpty) {
        _itemsMap[p.uuid!] = p.name;
      }
    }

    // Known events from ItemHistoryEventClass
    final knownEvents = <String>{
      ItemHistoryEventClass.returnEvent,
      ItemHistoryEventClass.sold,
      ItemHistoryEventClass.delivered,
      ItemHistoryEventClass.purchase,
      ItemHistoryEventClass.transferedIn,
      ItemHistoryEventClass.transferedOut,
      ItemHistoryEventClass.produced,
      ItemHistoryEventClass.productionDeleted,
      ItemHistoryEventClass.itemCreated,
      ItemHistoryEventClass.itemDeleted,
      ItemHistoryEventClass.itemDuplicated,
      ItemHistoryEventClass.quantityUpdatedIncrease,
      ItemHistoryEventClass.quantityUpdatedDecrease,
    };

    // Known sources & destinations
    final knownSources = <String>{
      ItemHistoryEventClass.receiptSource,
      ItemHistoryEventClass.invoiceSource,
      ItemHistoryEventClass.departmentSource,
      ItemHistoryEventClass.orderSource,
      ItemHistoryEventClass.purchaseSource,
      ItemHistoryEventClass.productionSource,
      ItemHistoryEventClass.storageSource,
      ItemHistoryEventClass.branchStoreSource,
      ItemHistoryEventClass.productSource,
      ItemHistoryEventClass.manualSource,
    };

    final knownDestinations = <String>{
      ItemHistoryEventClass.receiptDestination,
      ItemHistoryEventClass.invoiceDestination,
      ItemHistoryEventClass.productDestination,
      ItemHistoryEventClass.storageDestination,
      ItemHistoryEventClass.productionDestination,
      ItemHistoryEventClass.purchaseDestination,
      ItemHistoryEventClass.orderDestination,
      ItemHistoryEventClass.departmentDestination,
      ItemHistoryEventClass.branchStoreDestination,
      ItemHistoryEventClass.deletedDestination,
      ItemHistoryEventClass.manualDestination,
    };

    final eventsSet = <String>{...knownEvents};
    final sourcesSet = <String>{...knownSources};
    final destinationsSet = <String>{...knownDestinations};

    for (final h in _baseRecords) {
      if (h.itemUuid != null && h.itemUuid!.isNotEmpty) {
        if (!_itemsMap.containsKey(h.itemUuid)) {
          _itemsMap[h.itemUuid!] =
              (h.itemName != null && h.itemName!.isNotEmpty)
                  ? h.itemName!
                  : h.itemUuid!;
        }
      }

      if (h.event != null && h.event!.trim().isNotEmpty) {
        eventsSet.add(h.event!.trim());
      }

      if (h.staffId != null &&
          h.staffId!.trim().isNotEmpty) {
        _staffMap[h.staffId!.trim()] =
            (h.staffName != null &&
                    h.staffName!.trim().isNotEmpty)
                ? h.staffName!.trim()
                : h.staffId!.trim();
      }

      if (h.source != null && h.source!.trim().isNotEmpty) {
        sourcesSet.add(h.source!.trim());
      }

      if (h.destination != null &&
          h.destination!.trim().isNotEmpty) {
        destinationsSet.add(h.destination!.trim());
      }

      if (h.departmentUuid != null &&
          h.departmentUuid!.trim().isNotEmpty) {
        _departmentsMap[h.departmentUuid!.trim()] =
            (h.departmentName != null &&
                    h.departmentName!.trim().isNotEmpty)
                ? h.departmentName!.trim()
                : 'Department';
      }
    }

    // Departments from department provider
    for (final d
        in returnDepartmentProvider().departments) {
      if (d.uuid.isNotEmpty) {
        _departmentsMap[d.uuid] = d.name;
      }
    }

    _eventsList.addAll(eventsSet);
    _eventsList.sort(
      (a, b) => ItemHistoryReportQuery.formatEventName(
        a,
      ).toLowerCase().compareTo(
        ItemHistoryReportQuery.formatEventName(
          b,
        ).toLowerCase(),
      ),
    );

    _sourcesList.addAll(sourcesSet);
    _sourcesList.sort(
      (
        a,
        b,
      ) => ItemHistoryReportQuery.formatSourceOrDestination(
        a,
      ).toLowerCase().compareTo(
        ItemHistoryReportQuery.formatSourceOrDestination(
          b,
        ).toLowerCase(),
      ),
    );

    _destinationsList.addAll(destinationsSet);
    _destinationsList.sort(
      (
        a,
        b,
      ) => ItemHistoryReportQuery.formatSourceOrDestination(
        a,
      ).toLowerCase().compareTo(
        ItemHistoryReportQuery.formatSourceOrDestination(
          b,
        ).toLowerCase(),
      ),
    );
  }

  void _recompute() {
    final sorted = ItemHistoryReportQuery.filterAndSort(
      rows: _baseRecords,
      filters: _filters,
      sortField: _sortField,
      ascending: _ascending,
      departmentsEnabled: _departmentsEnabled,
    );
    final page = ItemHistoryReportQuery.paginate(
      sorted,
      _page,
    );
    _page = page.page;
    _result = page;
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

  void _setSort(ItemHistorySortField f) {
    _apply(() {
      if (_sortField == f) {
        _ascending = !_ascending;
      } else {
        _sortField = f;
        _ascending = true;
      }
    });
  }

  void _resetAll() {
    _searchCtrl.clear();
    _apply(_filters.clearAll);
  }

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
        _apply(
          () =>
              _filters.dateRange = DateTimeRange(
                start: day,
                end: day,
              ),
        );
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
        _apply(
          () =>
              _filters.dateRange = DateTimeRange(
                start: s,
                end: e,
              ),
        );
      },
    );
  }

  void _clearDate() {
    _apply(() => _filters.dateRange = null);
  }

  String get _dateLabel {
    final r = _filters.dateRange;
    if (r == null) return 'All Dates';
    final s = r.start;
    final e = r.end;
    final same =
        s.year == e.year &&
        s.month == e.month &&
        s.day == e.day;
    return same
        ? formatDateTime(s)
        : '${formatDateTime(s)} - ${formatDateTime(e)}';
  }

  void _openRecordDetails(ItemHistory row) {
    final theme = returnTheme(context, listen: false);
    showDialog(
      context: context,
      builder: (context) {
        return DialogTemplate(
          theme: theme,
          message: 'View Item History Details',
          title: 'History Details',
          action: () {},
          showBottomActionButtons: false,
          widget: SizedBox(
            height: screenHeight(context) - 180,
            child: _ItemHistoryRecordDetailsModal(
              history: row,
              theme: theme,
              onViewItem:
                  (row.itemUuid != null &&
                          row.itemUuid!.isNotEmpty)
                      ? () {
                        Navigator.of(context).pop();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    ProductDetailsPage(
                                      productUuid:
                                          row.itemUuid!,
                                    ),
                          ),
                        );
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
        title: 'Item History Table',
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
                _result != null)
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
                  ? 'No Matching Records'
                  : 'Empty List',
          subText:
              hasFilters
                  ? 'No history record matches your search and filters'
                  : 'No item history has been recorded yet',
          theme: theme,
          height: 35,
          icon: Icons.clear,
          altAction:
              hasFilters
                  ? _resetAll
                  : () => _load(refreshFromStore: true),
          altActionText:
              hasFilters ? 'Clear all filters' : 'Refresh',
          altIcon:
              hasFilters
                  ? Icons.filter_alt_off
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
            child: TextField(
              controller: _searchCtrl,
              onChanged:
                  (v) => _apply(() => _filters.search = v),
              decoration: InputDecoration(
                hintText:
                    'Search title, item, event, desc, creator...',
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
        _pill(
          theme: theme,
          icon: Icons.event_rounded,
          label: 'Date: $_dateLabel',
          highlighted: _filters.dateRange != null,
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
                      12,
                      10,
                      12,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.close,
                          size: 16,
                          color: accent,
                        ),
                        Text(
                          'Clear',
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
                    12,
                    10,
                    12,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.filter_alt_off,
                        size: 16,
                        color: accent,
                      ),
                      Text(
                        'Reset Filter',
                        style: TextStyle(
                          color: accent,
                          fontSize:
                              theme.mobileTexts.b3.fontSize,
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

  Widget _filterPanel(ThemeProvider theme) {
    // Sorted items list
    final itemsList =
        _itemsMap.entries.toList()..sort(
          (a, b) => a.value.toLowerCase().compareTo(
            b.value.toLowerCase(),
          ),
        );

    // Sorted staff list
    final staffList =
        _staffMap.entries.toList()..sort(
          (a, b) => a.value.toLowerCase().compareTo(
            b.value.toLowerCase(),
          ),
        );

    // Sorted departments list
    final deptList =
        _departmentsMap.entries.toList()..sort(
          (a, b) => a.value.toLowerCase().compareTo(
            b.value.toLowerCase(),
          ),
        );

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
            'Item',
            _SearchableDropdown<String?>(
              title: 'Item',
              value: _filters.itemUuid,
              options: [
                const _SearchableOption(
                  value: null,
                  label: 'All items',
                ),
                ...itemsList.map(
                  (e) => _SearchableOption(
                    value: e.key,
                    label: e.value,
                  ),
                ),
              ],
              onChanged: (v) => _apply(() => _filters.itemUuid = v),
              theme: theme,
              searchHint: 'Search items...',
            ),
            220,
          ),
          _labeled(
            'Event',
            _SearchableDropdown<String?>(
              title: 'Event',
              value: _filters.event,
              options: [
                const _SearchableOption(
                  value: null,
                  label: 'All events',
                ),
                ..._eventsList.map(
                  (e) => _SearchableOption(
                    value: e,
                    label: ItemHistoryReportQuery.formatEventName(e),
                  ),
                ),
              ],
              onChanged: (v) => _apply(() => _filters.event = v),
              theme: theme,
              searchHint: 'Search events...',
            ),
            180,
          ),
          _labeled(
            'Creator',
            _SearchableDropdown<String?>(
              title: 'Creator',
              value: _filters.staffId,
              options: [
                const _SearchableOption(
                  value: null,
                  label: 'All creators',
                ),
                ...staffList.map(
                  (e) => _SearchableOption(
                    value: e.key,
                    label: e.value,
                  ),
                ),
              ],
              onChanged: (v) => _apply(() => _filters.staffId = v),
              theme: theme,
              searchHint: 'Search creators...',
            ),
            180,
          ),
          _labeled(
            'Quantity Change',
            _SearchableDropdown<QuantityDirectionFilter>(
              title: 'Quantity Change',
              value: _filters.quantityDirection,
              options: const [
                _SearchableOption(
                  value: QuantityDirectionFilter.all,
                  label: 'All Changes',
                ),
                _SearchableOption(
                  value: QuantityDirectionFilter.increase,
                  label: 'Quantity Increase',
                ),
                _SearchableOption(
                  value: QuantityDirectionFilter.decrease,
                  label: 'Quantity Decrease',
                ),
                _SearchableOption(
                  value: QuantityDirectionFilter.zeroChange,
                  label: 'No Change (0)',
                ),
              ],
              onChanged:
                  (v) => _apply(
                    () => _filters.quantityDirection = v,
                  ),
              theme: theme,
              searchHint: 'Search changes...',
            ),
            170,
          ),
          _labeled(
            'Source',
            _SearchableDropdown<String?>(
              title: 'Source',
              value: _filters.source,
              options: [
                const _SearchableOption(
                  value: null,
                  label: 'All sources',
                ),
                ..._sourcesList.map(
                  (s) => _SearchableOption(
                    value: s,
                    label:
                        ItemHistoryReportQuery.formatSourceOrDestination(
                          s,
                        ),
                  ),
                ),
              ],
              onChanged: (v) => _apply(() => _filters.source = v),
              theme: theme,
              searchHint: 'Search sources...',
            ),
            170,
          ),
          _labeled(
            'Destination',
            _SearchableDropdown<String?>(
              title: 'Destination',
              value: _filters.destination,
              options: [
                const _SearchableOption(
                  value: null,
                  label: 'All destinations',
                ),
                ..._destinationsList.map(
                  (d) => _SearchableOption(
                    value: d,
                    label:
                        ItemHistoryReportQuery.formatSourceOrDestination(
                          d,
                        ),
                  ),
                ),
              ],
              onChanged:
                  (v) =>
                      _apply(() => _filters.destination = v),
              theme: theme,
              searchHint: 'Search destinations...',
            ),
            170,
          ),
          if (_departmentsEnabled)
            _labeled(
              'Department',
              _SearchableDropdown<String?>(
                title: 'Department',
                value: _filters.departmentUuid,
                options: [
                  const _SearchableOption(
                    value: null,
                    label: 'All departments',
                  ),
                  const _SearchableOption(
                    value: itemHistoryReportNoneKey,
                    label: 'No Department',
                  ),
                  ...deptList.map(
                    (d) => _SearchableOption(
                      value: d.key,
                      label: d.value,
                    ),
                  ),
                ],
                onChanged:
                    (v) => _apply(
                      () => _filters.departmentUuid = v,
                    ),
                theme: theme,
                searchHint: 'Search departments...',
              ),
              200,
            ),
          _labeled(
            'Managed status',
            _SearchableDropdown<int>(
              title: 'Managed status',
              value:
                  _filters.isManaged == null
                      ? 0
                      : (_filters.isManaged! ? 1 : 2),
              options: const [
                _SearchableOption(
                  value: 0,
                  label: 'All',
                ),
                _SearchableOption(
                  value: 1,
                  label: 'Managed',
                ),
                _SearchableOption(
                  value: 2,
                  label: 'Un-Managed',
                ),
              ],
              onChanged:
                  (v) => _apply(
                    () =>
                        _filters.isManaged =
                            v == 1
                                ? true
                                : (v == 2 ? false : null),
                  ),
              theme: theme,
              searchHint: 'Search status...',
            ),
            150,
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

    if (_filters.itemUuid != null) {
      final name = _itemsMap[_filters.itemUuid!] ?? 'Item';
      chips.add(
        chip(
          'Item: $name',
          () => _apply(() => _filters.itemUuid = null),
        ),
      );
    }
    if (_filters.event != null) {
      final name = ItemHistoryReportQuery.formatEventName(
        _filters.event!,
      );
      chips.add(
        chip(
          'Event: $name',
          () => _apply(() => _filters.event = null),
        ),
      );
    }
    if (_filters.staffId != null) {
      final name =
          _staffMap[_filters.staffId!] ?? 'Creator';
      chips.add(
        chip(
          'Creator: $name',
          () => _apply(() => _filters.staffId = null),
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
          () => _apply(
            () =>
                _filters.quantityDirection =
                    QuantityDirectionFilter.all,
          ),
        ),
      );
    }
    if (_filters.source != null) {
      final name =
          ItemHistoryReportQuery.formatSourceOrDestination(
            _filters.source!,
          );
      chips.add(
        chip(
          'Source: $name',
          () => _apply(() => _filters.source = null),
        ),
      );
    }
    if (_filters.destination != null) {
      final name =
          ItemHistoryReportQuery.formatSourceOrDestination(
            _filters.destination!,
          );
      chips.add(
        chip(
          'Destination: $name',
          () => _apply(() => _filters.destination = null),
        ),
      );
    }
    if (_departmentsEnabled &&
        _filters.departmentUuid != null) {
      final name =
          _filters.departmentUuid ==
                  itemHistoryReportNoneKey
              ? 'No Department'
              : (_departmentsMap[_filters
                      .departmentUuid!] ??
                  'Department');
      chips.add(
        chip(
          'Department: $name',
          () =>
              _apply(() => _filters.departmentUuid = null),
        ),
      );
    }
    if (_filters.isManaged != null) {
      chips.add(
        chip(
          _filters.isManaged! ? 'Managed' : 'Un-Managed',
          () => _apply(() => _filters.isManaged = null),
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

  Widget _quantityChangeCell(
    ThemeProvider theme,
    ItemHistory r,
  ) {
    if (r.quantityChange == null) {
      return _txt(
        theme,
        'N/A',
        color: Colors.grey,
        align: TextAlign.center,
      );
    }

    final qty = r.quantityChange!;
    final unitStr =
        (r.unit != null && r.unit!.trim().isNotEmpty)
            ? ' ${r.unit!.trim()}'
            : '';

    if (qty == 0) {
      return _txt(
        theme,
        '0$unitStr',
        bold: true,
        color: Colors.grey.shade700,
        align: TextAlign.center,
      );
    }

    if (r.isIncreased == true) {
      return _txt(
        theme,
        '+${formatLargeNumberDouble(qty.abs())}$unitStr',
        bold: true,
        color: Colors.green.shade700,
        align: TextAlign.center,
      );
    } else if (r.isIncreased == false) {
      return _txt(
        theme,
        '-${formatLargeNumberDouble(qty.abs())}$unitStr',
        bold: true,
        color: theme.lightModeColor.errorColor200,
        align: TextAlign.center,
      );
    } else {
      final sign = qty > 0 ? '+' : (qty < 0 ? '-' : '');
      final color =
          qty > 0
              ? Colors.green.shade700
              : (qty < 0
                  ? theme.lightModeColor.errorColor200
                  : Colors.grey.shade700);
      return _txt(
        theme,
        '$sign${formatLargeNumberDouble(qty.abs())}$unitStr',
        bold: true,
        color: color,
        align: TextAlign.center,
      );
    }
  }

  Widget _oldValueCell(ThemeProvider theme, ItemHistory r) {
    if (r.oldValue == null || r.oldValue!.isEmpty) {
      return _txt(theme, '—', align: TextAlign.center);
    }
    final pUnit =
        (r.primaryUnit != null &&
                r.primaryUnit!.trim().isNotEmpty)
            ? ' ${r.primaryUnit!.trim()}'
            : '';
    return _txt(
      theme,
      '${r.oldValue!}$pUnit',
      align: TextAlign.center,
    );
  }

  Widget _newValueCell(ThemeProvider theme, ItemHistory r) {
    if (r.newValue == null || r.newValue!.isEmpty) {
      return _txt(theme, '—', align: TextAlign.center);
    }
    final pUnit =
        (r.primaryUnit != null &&
                r.primaryUnit!.trim().isNotEmpty)
            ? ' ${r.primaryUnit!.trim()}'
            : '';
    return _txt(
      theme,
      '${r.newValue!}$pUnit',
      align: TextAlign.center,
    );
  }

  List<_Col> _columns(ThemeProvider theme, int pageStart) {
    const dash = '—';
    final green = Colors.green.shade700;

    return [
      // 1. Index Number (Center)
      _Col(
        label: 'No.',
        width: 60,
        align: TextAlign.center,
        cell:
            (r, i) => _txt(
              theme,
              '${pageStart + i}',
              bold: true,
              align: TextAlign.center,
            ),
      ),
      // 2. Item Name (Left)
      _Col(
        label: 'Item Name',
        width: 220,
        sort: ItemHistorySortField.itemName,
        align: TextAlign.start,
        cell:
            (r, i) => _txt(
              theme,
              (r.itemName != null && r.itemName!.isNotEmpty)
                  ? r.itemName!
                  : dash,
              bold: true,
              align: TextAlign.start,
            ),
      ),
      // 3. Created Date (Left) - Moved right after Item Name
      _Col(
        label: 'Created Date',
        width: 180,
        sort: ItemHistorySortField.createdAt,
        align: TextAlign.start,
        cell:
            (r, i) => _txt(
              theme,
              r.createdAt != null
                  ? formatDateWithTime(r.createdAt!)
                  : dash,
              align: TextAlign.start,
            ),
      ),
      // 4. History Title (Left)
      _Col(
        label: 'History Title',
        width: 200,
        sort: ItemHistorySortField.title,
        align: TextAlign.start,
        cell:
            (r, i) => _txt(
              theme,
              r.title.isNotEmpty ? r.title : dash,
              bold: true,
              align: TextAlign.start,
            ),
      ),
      // 5. Event (Center)
      _Col(
        label: 'Event',
        width: 150,
        sort: ItemHistorySortField.event,
        align: TextAlign.center,
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
              ItemHistoryReportQuery.formatEventName(
                r.event!,
              ),
              Colors.blueGrey,
            ),
          );
        },
      ),
      // 6. Source (Center)
      _Col(
        label: 'Source',
        width: 140,
        sort: ItemHistorySortField.source,
        align: TextAlign.center,
        cell:
            (r, i) => _txt(
              theme,
              (r.source != null && r.source!.isNotEmpty)
                  ? ItemHistoryReportQuery.formatSourceOrDestination(
                    r.source!,
                  )
                  : dash,
              align: TextAlign.center,
            ),
      ),
      // 7. Destination (Center)
      _Col(
        label: 'Destination',
        width: 140,
        sort: ItemHistorySortField.destination,
        align: TextAlign.center,
        cell:
            (r, i) => _txt(
              theme,
              (r.destination != null &&
                      r.destination!.isNotEmpty)
                  ? ItemHistoryReportQuery.formatSourceOrDestination(
                    r.destination!,
                  )
                  : dash,
              align: TextAlign.center,
            ),
      ),
      // 8. Description (Left)
      _Col(
        label: 'Description',
        width: 250,
        sort: ItemHistorySortField.desc,
        align: TextAlign.start,
        cell:
            (r, i) => _txt(
              theme,
              (r.desc != null && r.desc!.isNotEmpty)
                  ? r.desc!
                  : dash,
              align: TextAlign.start,
            ),
      ),
      // 9. Quantity Change with Unit + Direction coloring (Center)
      _Col(
        label: 'Quantity Change',
        width: 170,
        sort: ItemHistorySortField.quantityChange,
        align: TextAlign.center,
        cell: (r, i) => _quantityChangeCell(theme, r),
      ),
      // 10. Old Value with Primary Unit (Center)
      _Col(
        label: 'Old Value',
        width: 160,
        sort: ItemHistorySortField.oldValue,
        align: TextAlign.center,
        cell: (r, i) => _oldValueCell(theme, r),
      ),
      // 11. New Value with Primary Unit (Center)
      _Col(
        label: 'New Value',
        width: 160,
        sort: ItemHistorySortField.newValue,
        align: TextAlign.center,
        cell: (r, i) => _newValueCell(theme, r),
      ),
      // 12. Department (Center)
      if (_departmentsEnabled)
        _Col(
          label: 'Department',
          width: 160,
          sort: ItemHistorySortField.departmentName,
          align: TextAlign.center,
          cell:
              (r, i) => _txt(
                theme,
                (r.departmentName != null &&
                        r.departmentName!.isNotEmpty)
                    ? r.departmentName!
                    : dash,
                color:
                    r.departmentUuid == null
                        ? Colors.grey
                        : null,
                align: TextAlign.center,
              ),
        ),
      // 13. Managed (Center)
      _Col(
        label: 'Managed',
        width: 140,
        sort: ItemHistorySortField.isManaged,
        align: TextAlign.center,
        cell: (r, i) {
          if (r.isManaged == null) {
            return _txt(
              theme,
              'N/A',
              color: Colors.grey,
              align: TextAlign.center,
            );
          }
          return Center(
            child: _badge(
              r.isManaged! ? 'Managed' : 'Un-Managed',
              r.isManaged! ? green : Colors.orange.shade800,
            ),
          );
        },
      ),
      // 14. Creator (Left)
      _Col(
        label: 'Creator',
        width: 160,
        sort: ItemHistorySortField.staffName,
        align: TextAlign.start,
        cell:
            (r, i) => _txt(
              theme,
              (r.staffName != null &&
                      r.staffName!.isNotEmpty)
                  ? r.staffName!
                  : dash,
              align: TextAlign.start,
            ),
      ),
    ];
  }

  Widget _headerCell(ThemeProvider theme, _Col c) {
    final isSorted = c.sort != null && c.sort == _sortField;
    final accent = theme.lightModeColor.prColor300;
    final isCenter = c.align == TextAlign.center;
    final label = Flexible(
      child: Text(
        c.label,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign:
            isCenter ? TextAlign.center : TextAlign.start,
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
                      isCenter
                          ? Alignment.center
                          : Alignment.centerLeft,
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
                        isCenter
                            ? Alignment.center
                            : Alignment.centerLeft,
                    child: content,
                  ),
                ),
              ),
    );
  }

  Widget _table(
    ThemeProvider theme,
    ItemHistoryReportPageResult res,
  ) {
    final cols = _columns(theme, res.firstIndex);
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
                                    itemCount:
                                        res.rows.length,
                                    itemExtent: 52,
                                    itemBuilder: (
                                      context,
                                      i,
                                    ) {
                                      final r = res.rows[i];
                                      return Material(
                                        color:
                                            i.isEven
                                                ? Colors
                                                    .white
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
                                              .withAlpha(
                                                20,
                                              ),
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
                                                  cols.map((
                                                    c,
                                                  ) {
                                                    final isCenter =
                                                        c.align ==
                                                        TextAlign.center;
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
                                                          child: c.cell(
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
          ),
        ],
      ),
    );
  }

  Widget _pager(ThemeProvider theme) {
    final res = _result!;
    final accent = theme.lightModeColor.prColor300;
    Widget nav(
      String text,
      IconData icon,
      bool enabled,
      int to, {
      bool iconRight = false,
    }) {
      final color = enabled ? accent : Colors.grey;
      return TextButton(
        onPressed: enabled ? () => _goToPage(to) : null,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 4,
          children: [
            if (!iconRight)
              Icon(icon, size: 16, color: color),
            Text(
              text,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (iconRight)
              Icon(icon, size: 16, color: color),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        runSpacing: 4,
        children: [
          Text(
            res.totalCount == 0
                ? 'No records'
                : 'Showing ${res.firstIndex}-${res.lastIndex} of ${res.totalCount} records',
            style: TextStyle(
              fontSize: theme.mobileTexts.b3.fontSize,
              color: Colors.grey.shade700,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              nav(
                'Previous',
                Icons.chevron_left_rounded,
                res.page > 1,
                res.page - 1,
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: accent.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Page ${res.page} of ${res.totalPages}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: theme.mobileTexts.b3.fontSize,
                  ),
                ),
              ),
              nav(
                'Next',
                Icons.chevron_right_rounded,
                res.page < res.totalPages,
                res.page + 1,
                iconRight: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Detailed Modal Dialog presenting all 21 fields of an [ItemHistory] record.
class _ItemHistoryRecordDetailsModal
    extends StatelessWidget {
  final ItemHistory history;
  final ThemeProvider theme;
  final VoidCallback? onViewItem;

  const _ItemHistoryRecordDetailsModal({
    required this.history,
    required this.theme,
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

  @override
  Widget build(BuildContext context) {
    const dash = '—';
    final qtyStr =
        history.quantityChange != null
            ? '${formatLargeNumberDouble(history.quantityChange!.abs())} ${history.unit ?? ''}'
            : 'N/A';
    final directionStr =
        history.isIncreased == true
            ? 'Increase (+)'
            : (history.isIncreased == false
                ? 'Decrease (-)'
                : 'N/A');
    final managedStr =
        history.isManaged == null
            ? 'N/A'
            : (history.isManaged!
                ? 'Managed'
                : 'Un-Managed');

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
                  title: 'Item Name',
                  value:
                      (history.itemName != null &&
                              history.itemName!.isNotEmpty)
                          ? history.itemName!
                          : dash,
                ),
                _entry(
                  title: 'History Title',
                  value: history.title,
                ),
                _entry(
                  title: 'Event Type',
                  value:
                      history.event != null
                          ? ItemHistoryReportQuery.formatEventName(
                            history.event!,
                          )
                          : dash,
                ),
                _entry(
                  title: 'Description',
                  value:
                      (history.desc != null &&
                              history.desc!.isNotEmpty)
                          ? history.desc!
                          : dash,
                ),
                _entry(
                  title: 'Source',
                  value:
                      (history.source != null &&
                              history.source!.isNotEmpty)
                          ? ItemHistoryReportQuery.formatSourceOrDestination(
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
                          ? ItemHistoryReportQuery.formatSourceOrDestination(
                            history.destination!,
                          )
                          : dash,
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
                  title: 'Unit',
                  value:
                      (history.unit != null &&
                              history.unit!.isNotEmpty)
                          ? history.unit!
                          : dash,
                ),
                _entry(
                  title: 'Primary Unit',
                  value:
                      (history.primaryUnit != null &&
                              history
                                  .primaryUnit!
                                  .isNotEmpty)
                          ? history.primaryUnit!
                          : dash,
                ),
                _entry(
                  title: 'Old Value',
                  value:
                      (history.oldValue != null &&
                              history.oldValue!.isNotEmpty)
                          ? '${history.oldValue!} ${history.primaryUnit ?? ''}'
                              .trim()
                          : dash,
                ),
                _entry(
                  title: 'New Value',
                  value:
                      (history.newValue != null &&
                              history.newValue!.isNotEmpty)
                          ? '${history.newValue!} ${history.primaryUnit ?? ''}'
                              .trim()
                          : dash,
                ),
                _entry(
                  title: 'Managed Status',
                  value: managedStr,
                ),
                _entry(
                  title: 'Department Name',
                  value:
                      (history.departmentName != null &&
                              history
                                  .departmentName!
                                  .isNotEmpty)
                          ? history.departmentName!
                          : dash,
                ),
                _entry(
                  title: 'Creator (Staff Name)',
                  value:
                      (history.staffName != null &&
                              history.staffName!.isNotEmpty)
                          ? history.staffName!
                          : dash,
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
                  title: 'Item UUID',
                  value: history.itemUuid ?? dash,
                  isSelectable: true,
                ),
                _entry(
                  title: 'Staff ID',
                  value: history.staffId ?? dash,
                  isSelectable: true,
                ),
                _entry(
                  title: 'Department UUID',
                  value: history.departmentUuid ?? dash,
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
                text: 'View Item',
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

class _SearchableOption<T> {
  final T value;
  final String label;

  const _SearchableOption({
    required this.value,
    required this.label,
  });
}

class _DropdownSelectionResult<T> {
  final T value;
  const _DropdownSelectionResult(this.value);
}

class _SearchableDropdown<T> extends StatefulWidget {
  final String title;
  final T value;
  final List<_SearchableOption<T>> options;
  final ValueChanged<T> onChanged;
  final ThemeProvider theme;
  final String? searchHint;
  final bool showSearch;

  const _SearchableDropdown({
    super.key,
    required this.title,
    required this.value,
    required this.options,
    required this.onChanged,
    required this.theme,
    this.searchHint,
    this.showSearch = true,
  });

  @override
  State<_SearchableDropdown<T>> createState() => _SearchableDropdownState<T>();
}

class _SearchableDropdownState<T> extends State<_SearchableDropdown<T>> {
  Future<void> _openPicker() async {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.attached) return;
    final triggerOffset = renderBox.localToGlobal(Offset.zero);
    final triggerSize = renderBox.size;

    final result = await showDialog<_DropdownSelectionResult<T>>(
      context: context,
      barrierColor: Colors.black.withAlpha(25),
      barrierDismissible: true,
      builder: (ctx) {
        return _SearchableDropdownPopup<T>(
          triggerOffset: triggerOffset,
          triggerSize: triggerSize,
          title: widget.title,
          currentValue: widget.value,
          options: widget.options,
          searchHint: widget.searchHint,
          showSearch: widget.showSearch,
          theme: widget.theme,
        );
      },
    );

    if (result != null) {
      widget.onChanged(result.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final accent = theme.lightModeColor.prColor300;

    _SearchableOption<T>? selectedOption;
    for (final opt in widget.options) {
      if (opt.value == widget.value) {
        selectedOption = opt;
        break;
      }
    }
    selectedOption ??= widget.options.isNotEmpty
        ? widget.options.first
        : _SearchableOption(value: widget.value, label: '');

    final bool isHighlighted = widget.value != null &&
        (widget.value is! QuantityDirectionFilter ||
            widget.value != QuantityDirectionFilter.all) &&
        (widget.value is! int || widget.value != 0);

    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: isHighlighted ? accent.withAlpha(90) : Colors.transparent,
            width: 1,
          ),
        ),
        child: InkWell(
          mouseCursor: SystemMouseCursors.click,
          borderRadius: BorderRadius.circular(5),
          onTap: _openPicker,
          child: Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selectedOption.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isHighlighted ? FontWeight.w600 : FontWeight.normal,
                      color: isHighlighted ? accent : Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_drop_down_rounded,
                  size: 20,
                  color: isHighlighted ? accent : Colors.black54,
                ),
              ],
            ),
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
    super.key,
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
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollCtrl = ScrollController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController();
    _searchCtrl.addListener(() {
      final text = _searchCtrl.text.trim().toLowerCase();
      if (_query != text) {
        setState(() {
          _query = text;
        });
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.showSearch) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _focusNode.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  List<_SearchableOption<T>> _getFilteredOptions() {
    if (_query.isEmpty) {
      return widget.options;
    }
    return widget.options.where((opt) {
      return opt.label.toLowerCase().contains(_query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final screenSize = media.size;
    final viewInsets = media.viewInsets;
    final theme = widget.theme;
    final accent = theme.lightModeColor.prColor300;

    final filtered = _getFilteredOptions();

    final isMobile = screenSize.width < 520;

    final double popupWidth = isMobile
        ? (screenSize.width - 32.0).clamp(260.0, 420.0)
        : math
            .max(widget.triggerSize.width, 280.0)
            .clamp(240.0, screenSize.width - 32.0);

    final double left = isMobile
        ? (screenSize.width - popupWidth) / 2
        : widget.triggerOffset.dx
            .clamp(16.0, screenSize.width - popupWidth - 16.0);

    final double maxPossibleHeight = math.min(
      380.0,
      screenSize.height - viewInsets.bottom - 40.0,
    );

    final double spaceBelow = screenSize.height -
        viewInsets.bottom -
        (widget.triggerOffset.dy + widget.triggerSize.height) -
        16.0;
    final double spaceAbove = widget.triggerOffset.dy - 16.0;

    final bool placeBelow =
        isMobile ? false : (spaceBelow >= 240.0 || spaceBelow >= spaceAbove);

    final double? top = isMobile
        ? ((screenSize.height - viewInsets.bottom - maxPossibleHeight) / 2)
            .clamp(20.0, screenSize.height - maxPossibleHeight - 20.0)
        : (placeBelow
            ? widget.triggerOffset.dy + widget.triggerSize.height + 4.0
            : null);

    final double? bottom = (!isMobile && !placeBelow)
        ? (screenSize.height - widget.triggerOffset.dy + 4.0)
        : null;

    final double availableHeight = isMobile
        ? maxPossibleHeight
        : (placeBelow ? spaceBelow : spaceAbove).clamp(180.0, maxPossibleHeight);

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context).pop(),
              child: const SizedBox.expand(),
            ),
          ),
          Positioned(
            left: left,
            top: top,
            bottom: bottom,
            child: GestureDetector(
              onTap: () {},
              child: Container(
                width: popupWidth,
                constraints: BoxConstraints(
                  maxHeight: availableHeight,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(45),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 8, 6, 4),
                        child: Row(
                          children: [
                            Text(
                              widget.title,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.close_rounded, size: 16),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 26,
                                minHeight: 26,
                              ),
                              splashRadius: 14,
                              color: Colors.grey.shade600,
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                        ),
                      ),
                      if (widget.showSearch)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(10, 2, 10, 8),
                          child: SizedBox(
                            height: 34,
                            child: TextField(
                              controller: _searchCtrl,
                              focusNode: _focusNode,
                              style: const TextStyle(fontSize: 12),
                              textInputAction: TextInputAction.search,
                              onSubmitted: (_) {
                                if (filtered.isNotEmpty) {
                                  Navigator.of(context).pop(
                                    _DropdownSelectionResult<T>(
                                      filtered.first.value,
                                    ),
                                  );
                                }
                              },
                              decoration: InputDecoration(
                                hintText: widget.searchHint ??
                                    'Search ${widget.title.toLowerCase()}...',
                                hintStyle: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade500,
                                ),
                                prefixIcon: const Icon(
                                  Icons.search_rounded,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                suffixIcon: _searchCtrl.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(
                                          Icons.close_rounded,
                                          size: 14,
                                        ),
                                        padding: EdgeInsets.zero,
                                        splashRadius: 14,
                                        onPressed: () {
                                          _searchCtrl.clear();
                                        },
                                      )
                                    : null,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 0,
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: BorderSide(
                                    color: accent,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: Color(0xFFEEEEEE),
                      ),
                      Flexible(
                        child: filtered.isEmpty
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 24,
                                  horizontal: 16,
                                ),
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.search_off_rounded,
                                      size: 26,
                                      color: Colors.grey.shade400,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'No matches found',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Scrollbar(
                                controller: _scrollCtrl,
                                thumbVisibility: true,
                                child: ListView.builder(
                                  controller: _scrollCtrl,
                                  shrinkWrap: true,
                                  itemCount: filtered.length,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  itemBuilder: (ctx, index) {
                                    final opt = filtered[index];
                                    final isSelected =
                                        opt.value == widget.currentValue;

                                    return Material(
                                      color: isSelected
                                          ? accent.withAlpha(20)
                                          : Colors.transparent,
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.of(context).pop(
                                            _DropdownSelectionResult<T>(
                                              opt.value,
                                            ),
                                          );
                                        },
                                        hoverColor: accent.withAlpha(12),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                          child: Row(
                                            children: [
                                              SizedBox(
                                                width: 18,
                                                child: isSelected
                                                    ? Icon(
                                                        Icons.check_rounded,
                                                        size: 16,
                                                        color: accent,
                                                      )
                                                    : null,
                                              ),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                child: Text(
                                                  opt.label,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: isSelected
                                                        ? FontWeight.bold
                                                        : FontWeight.normal,
                                                    color: isSelected
                                                        ? accent
                                                        : Colors.black87,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                      ),
                      if (widget.options.length > 6)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            border: Border(
                              top: BorderSide(color: Colors.grey.shade200),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _query.isEmpty
                                    ? '${widget.options.length} ${widget.title.toLowerCase()}${widget.options.length == 1 ? '' : 's'}'
                                    : '${filtered.length} of ${widget.options.length}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (_query.isNotEmpty)
                                InkWell(
                                  onTap: () => _searchCtrl.clear(),
                                  child: Text(
                                    'Clear search',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: accent,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
