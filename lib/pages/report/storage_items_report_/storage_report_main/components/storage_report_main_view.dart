import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_storage_item_history/storage_item_history.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/date_picker_function.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/refresh_functions.dart';
import 'package:stockall/constants/subscription/items_auth.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/products/storage_page/storage_details/storage_details_page.dart';
import 'package:stockall/pages/report/components/report_range_fields.dart';
import 'package:stockall/pages/report/storage_items_report_/storage_report_main/class/storage_report_main_logic.dart';
import 'package:stockall/providers/theme_provider.dart';

class _Col {
  final String label;
  final double width;
  final StorageSortField? sort;
  final TextAlign align;
  final Widget Function(StorageReportRow row, int index)
  cell;

  const _Col({
    required this.label,
    required this.width,
    required this.cell,
    this.sort,
    this.align = TextAlign.center,
  });
}

/// Shared body of the "Storage Report Main" table page (desktop + mobile).
class StorageReportMainView extends StatefulWidget {
  final bool isDesktop;
  final String? initialSearch;

  const StorageReportMainView({
    super.key,
    required this.isDesktop,
    this.initialSearch,
  });

  @override
  State<StorageReportMainView> createState() =>
      _StorageReportMainViewState();
}

class _StorageReportMainViewState
    extends State<StorageReportMainView> {
  final StorageReportFilters _filters =
      StorageReportFilters();
  final _searchCtrl = TextEditingController();
  final _costMinCtrl = TextEditingController();
  final _costMaxCtrl = TextEditingController();
  final _qtyMinCtrl = TextEditingController();
  final _qtyMaxCtrl = TextEditingController();
  final _salesCountMinCtrl = TextEditingController();
  final _salesCountMaxCtrl = TextEditingController();
  final _hScroll = ScrollController();
  final _vScroll = ScrollController();

  StorageSortField _sortField = StorageSortField.name;
  bool _ascending = true;
  int _page = 1;
  bool _showFilters = false;

  late DateTimeRange _range;

  bool _loading = true;
  String? _error;

  List<StorageReportRow> _baseRows = [];
  StorageReportPageResult? _result;
  String _signature = '';

  /// storage item uuid -> stock movement (opening, closing, change).
  final Map<String, StorageStockMovement> _movements = {};

  @override
  void initState() {
    super.initState();
    if (widget.initialSearch != null &&
        widget.initialSearch!.isNotEmpty) {
      _searchCtrl.text = widget.initialSearch!;
      _filters.search = widget.initialSearch!;
    }
    final today = resolveBusinessDate(DateTime.now());
    final day = DateTime(
      today.year,
      today.month,
      today.day,
    );
    _range = DateTimeRange(start: day, end: day);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load(refreshFromStore: false);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _costMinCtrl.dispose();
    _costMaxCtrl.dispose();
    _qtyMinCtrl.dispose();
    _qtyMaxCtrl.dispose();
    _salesCountMinCtrl.dispose();
    _salesCountMaxCtrl.dispose();
    _hScroll.dispose();
    _vScroll.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------
  // data
  // ---------------------------------------------------------------

  bool get _canSeeCost => authorization(
    authorized: Authorizations().manageCostPrice,
  );

  bool get _canSeeQuantity => authorization(
    authorized: Authorizations().viewItemQuantity,
  );

  bool get _historyTracked => ItemsAuthAction()
      .trackItemHistoryAction(context: null);

  Future<void> _load({
    required bool refreshFromStore,
  }) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final sId = shopId();
      if (refreshFromStore) {
        await RefreshFunctions(
          context,
        ).refreshProducts(context);
        await returnStorageProductProvider()
            .getStorageProducts(sId);
        await returnStorageItemHistoryProvider()
            .getItemHistories();
      } else {
        await returnStorageProductProvider()
            .getStorageProductsOffline(sId);
        await returnStorageItemHistoryProvider()
            .getItemHistoriesOffline();
      }

      _movements.clear();
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
        returnStorageProductProvider()
            .storageProductListMain;
    double qty = 0;
    int latest = 0;
    for (final p in list) {
      qty += p.quantity ?? 0;
      final t = p.updatedAt?.millisecondsSinceEpoch ?? 0;
      if (t > latest) latest = t;
    }
    final salesList = returnData().productListMain;
    return '${list.length}|$latest|$qty|${salesList.length}';
  }

  void _rebuildBase() {
    final storageProducts =
        returnStorageProductProvider()
            .storageProductListMain;
    final salesProducts = returnData().productListMain;
    _baseRows = StorageReportRowBuilder.buildAll(
      storageProducts: storageProducts,
      salesProducts: salesProducts,
    );
    _signature = _sourceSignature();
  }

  void _ensureStockMovements(
    Iterable<StorageReportRow> rows,
  ) {
    final needed = <String, StorageReportRow>{};
    for (final r in rows) {
      if (!_movements.containsKey(r.uuid)) {
        needed[r.uuid] = r;
      }
    }
    if (needed.isEmpty) return;

    if (!_historyTracked) {
      for (final id in needed.keys) {
        _movements[id] = const StorageStockMovement(
          opening: null,
          closing: null,
        );
      }
      return;
    }

    final sid = shopId();
    final byItem = <String, List<StorageItemHistory>>{};
    for (final h
        in returnStorageItemHistoryProvider()
            .storageItemHistories) {
      final id = h.storageItemUuid;
      if (id == null || h.shopId != sid) continue;
      if (!needed.containsKey(id)) continue;
      (byItem[id] ??= []).add(h);
    }

    final startCutoff = fourAm(_range.start);
    final endCutoff = fourAmNextDay(_range.end);
    for (final e in needed.entries) {
      _movements[e
          .key] = StorageStockMovementCalculator.calculate(
        row: e.value,
        histories: byItem[e.key] ?? const [],
        startCutoff: startCutoff,
        endCutoff: endCutoff,
      );
    }
  }

  void _recompute() {
    final sortByMovement =
        _sortField == StorageSortField.openingStock ||
        _sortField == StorageSortField.closingStock ||
        _sortField == StorageSortField.stockChange;
    if (sortByMovement) _ensureStockMovements(_baseRows);

    final sorted = StorageReportQuery.filterAndSort(
      rows: _baseRows,
      filters: _filters,
      sortField: _sortField,
      ascending: _ascending,
      costFilterAllowed: _canSeeCost,
      opening:
          sortByMovement
              ? (r) => _movements[r.uuid]?.opening
              : null,
      closing:
          sortByMovement
              ? (r) => _movements[r.uuid]?.closing
              : null,
      stockChange:
          sortByMovement
              ? (r) => _movements[r.uuid]?.change
              : null,
    );
    final page = StorageReportQuery.paginate(sorted, _page);
    _page = page.page;
    _ensureStockMovements(page.rows);
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

  void _setSort(StorageSortField f) {
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
    _costMinCtrl.clear();
    _costMaxCtrl.clear();
    _qtyMinCtrl.clear();
    _qtyMaxCtrl.clear();
    _salesCountMinCtrl.clear();
    _salesCountMaxCtrl.clear();
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
        _movements.clear();
        _apply(
          () =>
              _range = DateTimeRange(start: day, end: day),
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
        _movements.clear();
        _apply(
          () => _range = DateTimeRange(start: s, end: e),
        );
      },
    );
  }

  DateTime get _businessToday {
    final t = resolveBusinessDate(DateTime.now());
    return DateTime(t.year, t.month, t.day);
  }

  bool get _isDateToday {
    final t = _businessToday;
    return _range.start.year == t.year &&
        _range.start.month == t.month &&
        _range.start.day == t.day &&
        _range.end.year == t.year &&
        _range.end.month == t.month &&
        _range.end.day == t.day;
  }

  void _clearDate() {
    final today = _businessToday;
    _movements.clear();
    _apply(
      () =>
          _range = DateTimeRange(start: today, end: today),
    );
  }

  void _openStorageDetails(StorageReportRow row) {
    if (row.uuid.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                StorageDetailsPage(productUuid: row.uuid),
      ),
    ).then((_) {
      if (mounted) {
        setState(() {
          _rebuildBase();
          _movements.clear();
          try {
            _recompute();
          } catch (_) {}
        });
      }
    });
  }

  // ---------------------------------------------------------------
  // formatting
  // ---------------------------------------------------------------

  String _money(num v) =>
      formatMoneyBig(amount: v, context: context);

  String _qty(num v) => formatLargeNumberDouble(v);

  String get _rangeLabel {
    final s = _range.start;
    final e = _range.end;
    final same =
        s.year == e.year &&
        s.month == e.month &&
        s.day == e.day;
    return same
        ? formatDateTime(s)
        : '${formatDateTime(s)} - ${formatDateTime(e)}';
  }

  // ---------------------------------------------------------------
  // build
  // ---------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = returnTheme(context);

    if (!_loading && _error == null) {
      final sig = _sourceSignature();
      if (sig != _signature) {
        _rebuildBase();
        _movements.clear();
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
        title: 'Storage Report Main',
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
                  ? 'No Matching Storage Items'
                  : 'Empty List',
          subText:
              hasFilters
                  ? 'No storage item matches your search and filters'
                  : 'No Storage Item has been recorded yet',
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
                    'Search storage item or sales item',
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
          label: 'Date: $_rangeLabel',
          highlighted: !_isDateToday,
          onTap: _pickRange,
        ),
        if (!_isDateToday)
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

  Widget _filterPanel(ThemeProvider theme) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.start,
        children: [
          if (_canSeeCost)
            ReportRangeFields(
              label: 'Cost price range (per primary unit)',
              minController: _costMinCtrl,
              maxController: _costMaxCtrl,
              onChange:
                  (a, b) => _apply(() {
                    _filters.costMin = a;
                    _filters.costMax = b;
                  }),
            ),
          ReportRangeFields(
            label: 'Quantity range (primary unit)',
            minController: _qtyMinCtrl,
            maxController: _qtyMaxCtrl,
            onChange:
                (a, b) => _apply(() {
                  _filters.quantityMin = a;
                  _filters.quantityMax = b;
                }),
          ),
          ReportRangeFields(
            label: 'Number of sales items',
            minController: _salesCountMinCtrl,
            maxController: _salesCountMaxCtrl,
            onChange:
                (a, b) => _apply(() {
                  _filters.salesItemsCountMin = a?.toInt();
                  _filters.salesItemsCountMax = b?.toInt();
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

    if (_canSeeCost &&
        (_filters.costMin != null ||
            _filters.costMax != null)) {
      chips.add(
        chip(
          'Cost: ${_filters.costMin != null ? _money(_filters.costMin!) : 'Any'}'
          ' - ${_filters.costMax != null ? _money(_filters.costMax!) : 'Any'}',
          () {
            _costMinCtrl.clear();
            _costMaxCtrl.clear();
            _apply(() {
              _filters.costMin = null;
              _filters.costMax = null;
            });
          },
        ),
      );
    }
    if (_filters.quantityMin != null ||
        _filters.quantityMax != null) {
      chips.add(
        chip(
          'Qty: ${_filters.quantityMin != null ? formatLargeNumberDouble(_filters.quantityMin!) : 'Any'}'
          ' - ${_filters.quantityMax != null ? formatLargeNumberDouble(_filters.quantityMax!) : 'Any'}',
          () {
            _qtyMinCtrl.clear();
            _qtyMaxCtrl.clear();
            _apply(() {
              _filters.quantityMin = null;
              _filters.quantityMax = null;
            });
          },
        ),
      );
    }
    if (_filters.salesItemsCountMin != null ||
        _filters.salesItemsCountMax != null) {
      chips.add(
        chip(
          'Sales items: ${_filters.salesItemsCountMin ?? 'Any'}'
          ' - ${_filters.salesItemsCountMax ?? 'Any'}',
          () {
            _salesCountMinCtrl.clear();
            _salesCountMaxCtrl.clear();
            _apply(() {
              _filters.salesItemsCountMin = null;
              _filters.salesItemsCountMax = null;
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

  List<_Col> _columns(ThemeProvider theme, int pageStart) {
    const dash = '—';
    final red = theme.lightModeColor.errorColor200;
    final green = Colors.green.shade700;
    final cost = _canSeeCost;
    final seeQty = _canSeeQuantity;
    final trackHistory = _historyTracked;

    return [
      _Col(
        label: 'No.',
        width: 60,
        cell:
            (r, i) =>
                _txt(theme, '${pageStart + i}', bold: true),
      ),
      _Col(
        label: 'Item Name',
        width: 220,
        sort: StorageSortField.name,
        align: TextAlign.start,
        cell:
            (r, i) => _txt(
              theme,
              r.name,
              bold: true,
              align: TextAlign.start,
            ),
      ),
      _Col(
        label: 'Quantity',
        width: 120,
        sort: StorageSortField.quantity,
        cell:
            (r, i) => _txt(
              theme,
              !seeQty
                  ? '****'
                  : (r.quantity == null
                      ? dash
                      : _qty(r.quantity!)),
              bold: true,
              color:
                  (r.quantity != null && r.quantity! <= 0)
                      ? red
                      : null,
            ),
      ),
      _Col(
        label: 'Primary Unit',
        width: 110,
        sort: StorageSortField.primaryUnit,
        align: TextAlign.start,
        cell:
            (r, i) => _txt(
              theme,
              r.primaryUnit,
              align: TextAlign.start,
            ),
      ),
      _Col(
        label: 'Opening Stock',
        width: 130,
        sort: StorageSortField.openingStock,
        cell: (r, i) {
          if (!seeQty) return _txt(theme, '****');
          if (!trackHistory) return _txt(theme, 'N/A');
          final v = _movements[r.uuid]?.opening;
          return _txt(theme, v == null ? dash : _qty(v));
        },
      ),
      _Col(
        label: 'Closing Stock',
        width: 130,
        sort: StorageSortField.closingStock,
        cell: (r, i) {
          if (!seeQty) return _txt(theme, '****');
          if (!trackHistory) return _txt(theme, 'N/A');
          final v = _movements[r.uuid]?.closing;
          return _txt(theme, v == null ? dash : _qty(v));
        },
      ),
      _Col(
        label: 'Stock Change',
        width: 130,
        sort: StorageSortField.stockChange,
        cell: (r, i) {
          if (!seeQty) return _txt(theme, '****');
          if (!trackHistory) return _txt(theme, 'N/A');
          final diff = _movements[r.uuid]?.change;
          if (diff == null) return _txt(theme, dash);
          final text =
              diff > 0 ? '+${_qty(diff)}' : _qty(diff);
          final color =
              diff > 0 ? green : (diff < 0 ? red : null);
          return _txt(
            theme,
            text,
            color: color,
            bold: diff != 0,
          );
        },
      ),
      if (cost)
        _Col(
          label: 'Cost Price',
          width: 130,
          sort: StorageSortField.costPrice,
          cell:
              (r, i) => _txt(
                theme,
                r.costPrice == null
                    ? dash
                    : _money(r.costPrice!),
              ),
        ),
      if (cost)
        _Col(
          label: 'Total Cost Value',
          width: 160,
          sort: StorageSortField.totalCostValue,
          cell:
              (r, i) => _txt(
                theme,
                r.totalCostValue == null
                    ? dash
                    : _money(r.totalCostValue!),
                bold: true,
              ),
        ),
      _Col(
        label: 'Quantity Type',
        width: 140,
        sort: StorageSortField.quantityType,
        cell:
            (r, i) => _badge(
              r.quantityTypeLabel,
              r.isTwoDimensional
                  ? Colors.deepPurple
                  : Colors.blueGrey,
            ),
      ),
      _Col(
        label: 'Created Date',
        width: 130,
        sort: StorageSortField.createdAt,
        cell:
            (r, i) => _txt(
              theme,
              r.createdAt == null
                  ? dash
                  : formatDateTime(r.createdAt!),
            ),
      ),
      _Col(
        label: 'Created Time',
        width: 120,
        sort: StorageSortField.createdAt,
        cell:
            (r, i) => _txt(
              theme,
              r.createdAt == null
                  ? dash
                  : formatTime(r.createdAt!),
            ),
      ),
      _Col(
        label: 'Item In Sales',
        width: 230,
        sort: StorageSortField.itemsInSalesCount,
        align: TextAlign.start,
        cell: (r, i) {
          if (r.salesItemNames.isEmpty) {
            return _txt(
              theme,
              dash,
              align: TextAlign.start,
            );
          }
          final label = r.salesItemNames.join(', ');
          return Tooltip(
            message: label,
            child: _txt(
              theme,
              label,
              align: TextAlign.start,
            ),
          );
        },
      ),
      _Col(
        label: 'Quantity In Sales',
        width: 140,
        sort: StorageSortField.quantityInSales,
        cell:
            (r, i) => _txt(
              theme,
              !seeQty ? '****' : _qty(r.quantityInSales),
            ),
      ),
      _Col(
        label: 'Total Quantity',
        width: 130,
        sort: StorageSortField.totalQuantity,
        cell:
            (r, i) => _txt(
              theme,
              !seeQty ? '****' : _qty(r.totalQuantity),
              bold: true,
            ),
      ),
    ];
  }

  Widget _headerCell(ThemeProvider theme, _Col c) {
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
    StorageReportPageResult res,
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
                                                  _openStorageDetails(
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
                                                  cols
                                                      .map(
                                                        (
                                                          c,
                                                        ) => SizedBox(
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
                                                                r,
                                                                i,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                      .toList(),
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
                ? 'No storage items'
                : 'Showing ${res.firstIndex}-${res.lastIndex} of ${res.totalCount} storage items',
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
                    fontSize: theme.mobileTexts.b3.fontSize,
                    fontWeight: FontWeight.bold,
                    color: accent,
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
