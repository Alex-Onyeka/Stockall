import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_item_history/item_history.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/date_picker_function.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/refresh_functions.dart';
import 'package:stockall/constants/subscription/items_auth.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/products/product_details/product_details_page.dart';
import 'package:stockall/pages/report/items_report_main/class/items_report_main_logic.dart';
import 'package:stockall/providers/theme_provider.dart';

class _Col {
  final String label;
  final double width;
  final ItemsSortField? sort;
  final bool alignEnd;
  final Widget Function(ItemsReportRow row, int index) cell;

  const _Col({
    required this.label,
    required this.width,
    required this.cell,
    this.sort,
    this.alignEnd = false,
  });
}

/// Shared body of the "Items Report Main" page (desktop + mobile).
class ItemsReportMainView extends StatefulWidget {
  final bool isDesktop;
  const ItemsReportMainView({super.key, required this.isDesktop});

  @override
  State<ItemsReportMainView> createState() => _ItemsReportMainViewState();
}

class _ItemsReportMainViewState extends State<ItemsReportMainView> {
  final ItemsReportFilters _filters = ItemsReportFilters();
  final _searchCtrl = TextEditingController();
  final _sellMinCtrl = TextEditingController();
  final _sellMaxCtrl = TextEditingController();
  final _costMinCtrl = TextEditingController();
  final _costMaxCtrl = TextEditingController();
  final _hScroll = ScrollController();
  final _vScroll = ScrollController();

  ItemsSortField _sortField = ItemsSortField.name;
  bool _ascending = true;
  int _page = 1;
  bool _showFilters = false;

  late DateTimeRange _range;

  bool _loading = true;
  String? _error;

  List<ItemsReportRow> _baseRows = [];
  ItemsReportPage? _result;
  String _signature = '';

  /// uuid -> stock movement (opening, closing, change).
  final Map<String, ItemStockMovement> _movements = {};

  @override
  void initState() {
    super.initState();
    final today = resolveBusinessDate(DateTime.now());
    final day = DateTime(today.year, today.month, today.day);
    _range = DateTimeRange(start: day, end: day);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load(refreshFromStore: false);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _sellMinCtrl.dispose();
    _sellMaxCtrl.dispose();
    _costMinCtrl.dispose();
    _costMaxCtrl.dispose();
    _hScroll.dispose();
    _vScroll.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------
  // data
  // ---------------------------------------------------------------

  bool get _departmentsEnabled => shopSingle()?.manageDepartments == true;

  bool get _canSeeCost =>
      authorization(authorized: Authorizations().manageCostPrice);

  bool get _canSeeQuantity =>
      authorization(authorized: Authorizations().viewItemQuantity);

  bool get _historyTracked =>
      ItemsAuthAction().trackItemHistoryAction(context: null);

  Future<void> _load({required bool refreshFromStore}) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      if (refreshFromStore) {
        await RefreshFunctions(context).refreshProducts(context);
      }
      // Local (offline) read; never writes.
      await returnItemHistoryProvider().getItemHistoriesOffline();
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
    final list = returnData().productList();
    double qty = 0;
    int latest = 0;
    for (final p in list) {
      qty += p.quantity ?? 0;
      final t = p.updatedAt?.millisecondsSinceEpoch ?? 0;
      if (t > latest) latest = t;
    }
    return '${list.length}|$latest|$qty|'
        '${returnCategoriesProvider().categoriesMain.length}';
  }

  void _rebuildBase() {
    _baseRows = ItemsReportRowBuilder.buildAll(
      products: returnData().productList(),
      categories: returnCategoriesProvider().categoriesMain,
    );
    _signature = _sourceSignature();
  }

  /// Opening and closing stock for the given rows, reading the history ONCE and
  /// only for items that are not cached yet.
  void _ensureStockMovements(Iterable<ItemsReportRow> rows) {
    final needed = <String, ItemsReportRow>{};
    for (final r in rows) {
      if (!_movements.containsKey(r.uuid)) needed[r.uuid] = r;
    }
    if (needed.isEmpty) return;

    if (!_historyTracked) {
      for (final id in needed.keys) {
        _movements[id] = const ItemStockMovement(opening: null, closing: null);
      }
      return;
    }

    final sid = shopId();
    final byItem = <String, List<ItemHistory>>{};
    for (final h in returnItemHistoryProvider().itemHistories) {
      final id = h.itemUuid;
      if (id == null || h.shopId != sid) continue;
      if (!needed.containsKey(id)) continue;
      (byItem[id] ??= []).add(h);
    }

    final startCutoff = fourAm(_range.start);
    final endCutoff = fourAmNextDay(_range.end);
    for (final e in needed.entries) {
      _movements[e.key] = StockMovementCalculator.calculate(
        row: e.value,
        histories: byItem[e.key] ?? const [],
        startCutoff: startCutoff,
        endCutoff: endCutoff,
      );
    }
  }

  void _recompute() {
    final sortByMovement =
        _sortField == ItemsSortField.openingStock ||
        _sortField == ItemsSortField.closingStock ||
        _sortField == ItemsSortField.stockChange;
    if (sortByMovement) _ensureStockMovements(_baseRows);

    final sorted = ItemsReportQuery.filterAndSort(
      rows: _baseRows,
      filters: _filters,
      sortField: _sortField,
      ascending: _ascending,
      departmentsEnabled: _departmentsEnabled,
      costFilterAllowed: _canSeeCost,
      opening: sortByMovement ? (r) => _movements[r.uuid]?.opening : null,
      closing: sortByMovement ? (r) => _movements[r.uuid]?.closing : null,
      stockChange: sortByMovement ? (r) => _movements[r.uuid]?.change : null,
    );
    final page = ItemsReportQuery.paginate(sorted, _page);
    _page = page.page;
    // Only the visible 100 rows need stock movements.
    _ensureStockMovements(page.rows);
    _result = page;
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
    final r = _result;
    if (r == null || p < 1 || p > r.totalPages || p == r.page) {
      return;
    }
    _apply(() => _page = p, resetPage: false);
    if (_vScroll.hasClients) {
      _vScroll.jumpTo(0);
    }
  }

  void _setSort(ItemsSortField f) {
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
    _sellMinCtrl.clear();
    _sellMaxCtrl.clear();
    _costMinCtrl.clear();
    _costMaxCtrl.clear();
    _apply(_filters.clearAll);
  }

  double? _num(String v) => double.tryParse(v.replaceAll(',', '').trim());

  void _pickRange() {
    final theme = returnTheme(context, listen: false);
    mainDatePicker(
      context: context,
      theme: theme,
      singleDate: (date) {
        if (date == null) return;
        final day = DateTime(date.year, date.month, date.day);
        _movements.clear();
        _apply(() => _range = DateTimeRange(start: day, end: day));
      },
      rangeDate: (firstDate, lastDate) {
        if (firstDate == null) return;
        DateTime s = DateTime(firstDate.year, firstDate.month, firstDate.day);
        final endBase = lastDate ?? firstDate;
        DateTime e = DateTime(endBase.year, endBase.month, endBase.day);
        if (e.isBefore(s)) {
          final temp = s;
          s = e;
          e = temp;
        }
        _movements.clear();
        _apply(() => _range = DateTimeRange(start: s, end: e));
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
    _apply(() => _range = DateTimeRange(start: today, end: today));
  }

  void _openItemDetails(ItemsReportRow row) {
    if (row.uuid.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailsPage(productUuid: row.uuid),
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

  String _money(num v) => formatMoneyBig(amount: v, context: context);

  String _qty(num v) => formatLargeNumberDouble(v);

  String get _rangeLabel {
    final s = _range.start;
    final e = _range.end;
    final same = s.year == e.year && s.month == e.month && s.day == e.day;
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

    // Pick up changes made elsewhere (sales, stock updates, sync).
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
        title: 'Items Report Main',
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
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 8),
            _toolbar(theme),
            if (_showFilters) _filterPanel(theme),
            _activeChips(theme),
            Expanded(child: _content(theme)),
            if (!_loading && _error == null && _result != null) _pager(theme),
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
          title: hasFilters ? 'No Matching Items' : 'Empty List',
          subText:
              hasFilters
                  ? 'No item matches your search and filters'
                  : 'No Item has been recorded yet',
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
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => _apply(() => _filters.search = v),
              decoration: InputDecoration(
                hintText:
                    _departmentsEnabled
                        ? 'Search name, category or department'
                        : 'Search name or category',
                hintStyle: TextStyle(fontSize: theme.mobileTexts.b3.fontSize),
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
                    padding: EdgeInsetsGeometry.fromLTRB(10, 12, 10, 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.close, size: 16, color: accent),
                        Text(
                          'Clear',
                          style: TextStyle(
                            color: accent,
                            fontSize: theme.mobileTexts.b3.fontSize,
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
            label: active == 0 ? 'Filters' : 'Filters ($active)',
            highlighted: _showFilters || active > 0,
            onTap: () => setState(() => _showFilters = !_showFilters),
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
                  padding: EdgeInsetsGeometry.fromLTRB(10, 12, 10, 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.filter_alt_off, size: 16, color: accent),
                      Text(
                        'Reset Filter',
                        style: TextStyle(
                          color: accent,
                          fontSize: theme.mobileTexts.b3.fontSize,
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
      color: highlighted ? accent.withAlpha(30) : Colors.grey.shade100,
      borderRadius: BorderRadius.circular(5),
      child: InkWell(
        mouseCursor: SystemMouseCursors.click,
        borderRadius: BorderRadius.circular(5),
        onTap: onTap,
        child: Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 6,
            children: [
              Icon(
                icon,
                size: 16,
                color: highlighted ? accent : Colors.black87,
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: theme.mobileTexts.b3.fontSize,
                  fontWeight: FontWeight.bold,
                  color: highlighted ? accent : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _labeled(String label, Widget child, double width) {
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

  Widget _dropdown<T>({
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          isExpanded: true,
          value: value,
          items: items,
          onChanged: onChanged,
          style: const TextStyle(fontSize: 12, color: Colors.black87),
        ),
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
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: const TextStyle(fontSize: 12),
        decoration: InputDecoration(
          hintText: hint,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
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
    required void Function(double? min, double? max) onChange,
  }) {
    void emit() => onChange(_num(minC.text), _num(maxC.text));
    return _labeled(
      label,
      Row(
        spacing: 6,
        children: [
          Expanded(child: _numField(minC, 'Min', (_) => emit())),
          Expanded(child: _numField(maxC, 'Max', (_) => emit())),
        ],
      ),
      240,
    );
  }

  Widget _filterPanel(ThemeProvider theme) {
    final cats =
        returnCategoriesProvider(context: context).categoriesMain.toList()
          ..sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
          );
    final depts =
        returnDepartmentProvider(context: context).departments.toList()..sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );

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
          _labeled(
            'Category',
            _dropdown<String?>(
              value: _filters.categoryKey,
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('All categories'),
                ),
                const DropdownMenuItem(
                  value: itemsReportNoneKey,
                  child: Text('No Category'),
                ),
                ...cats.map(
                  (c) => DropdownMenuItem(
                    value: c.uuid,
                    child: Text(c.name, overflow: TextOverflow.ellipsis),
                  ),
                ),
              ],
              onChanged: (v) => _apply(() => _filters.categoryKey = v),
            ),
            220,
          ),
          if (_departmentsEnabled)
            _labeled(
              'Department',
              _dropdown<String?>(
                value: _filters.departmentKey,
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('All departments'),
                  ),
                  const DropdownMenuItem(
                    value: itemsReportNoneKey,
                    child: Text('No Department'),
                  ),
                  ...depts.map(
                    (d) => DropdownMenuItem(
                      value: d.uuid,
                      child: Text(d.name, overflow: TextOverflow.ellipsis),
                    ),
                  ),
                ],
                onChanged: (v) => _apply(() => _filters.departmentKey = v),
              ),
              220,
            ),
          _labeled(
            'Quantity level',
            _dropdown<StockLevelFilter>(
              value: _filters.stockLevel,
              items: const [
                DropdownMenuItem(
                  value: StockLevelFilter.all,
                  child: Text('All levels'),
                ),
                DropdownMenuItem(
                  value: StockLevelFilter.inStock,
                  child: Text('In Stock'),
                ),
                DropdownMenuItem(
                  value: StockLevelFilter.lowStock,
                  child: Text('Low in Stock'),
                ),
                DropdownMenuItem(
                  value: StockLevelFilter.outOfStock,
                  child: Text('Out of Stock'),
                ),
              ],
              onChanged:
                  (v) => _apply(
                    () => _filters.stockLevel = v ?? StockLevelFilter.all,
                  ),
            ),
            180,
          ),
          _labeled(
            'Inventory management',
            _dropdown<int>(
              value: _filters.managed == null ? 0 : (_filters.managed! ? 1 : 2),
              items: const [
                DropdownMenuItem(value: 0, child: Text('All')),
                DropdownMenuItem(value: 1, child: Text('Managed')),
                DropdownMenuItem(value: 2, child: Text('Un-Managed')),
              ],
              onChanged:
                  (v) => _apply(
                    () =>
                        _filters.managed =
                            v == 1 ? true : (v == 2 ? false : null),
                  ),
            ),
            180,
          ),
          _rangeFields(
            label: 'Selling price range (per primary unit)',
            minC: _sellMinCtrl,
            maxC: _sellMaxCtrl,
            onChange:
                (a, b) => _apply(() {
                  _filters.sellingMin = a;
                  _filters.sellingMax = b;
                }),
          ),
          if (_canSeeCost)
            _rangeFields(
              label: 'Cost price range (per primary unit)',
              minC: _costMinCtrl,
              maxC: _costMaxCtrl,
              onChange:
                  (a, b) => _apply(() {
                    _filters.costMin = a;
                    _filters.costMax = b;
                  }),
            ),
        ],
      ),
    );
  }

  Widget _activeChips(ThemeProvider theme) {
    final chips = <Widget>[];
    Widget chip(String text, VoidCallback onRemove) => InputChip(
      label: Text(text, style: const TextStyle(fontSize: 10)),
      onDeleted: onRemove,
      deleteIcon: const Icon(Icons.close, size: 12),
      visualDensity: VisualDensity.compact,
      backgroundColor: theme.lightModeColor.prColor300.withAlpha(25),
      side: BorderSide.none,
    );

    if (_filters.categoryKey != null) {
      final name =
          _filters.categoryKey == itemsReportNoneKey
              ? 'No Category'
              : returnCategoriesProvider(context: context).categoriesMain
                      .where((c) => c.uuid == _filters.categoryKey)
                      .map((c) => c.name)
                      .firstOrNull ??
                  'Category';
      chips.add(
        chip(
          'Category: $name',
          () => _apply(() => _filters.categoryKey = null),
        ),
      );
    }
    if (_departmentsEnabled && _filters.departmentKey != null) {
      final name =
          _filters.departmentKey == itemsReportNoneKey
              ? 'No Department'
              : returnDepartmentProvider(context: context).departments
                      .where((d) => d.uuid == _filters.departmentKey)
                      .map((d) => d.name)
                      .firstOrNull ??
                  'Department';
      chips.add(
        chip(
          'Department: $name',
          () => _apply(() => _filters.departmentKey = null),
        ),
      );
    }
    if (_filters.stockLevel != StockLevelFilter.all) {
      final t = switch (_filters.stockLevel) {
        StockLevelFilter.inStock => 'In Stock',
        StockLevelFilter.lowStock => 'Low in Stock',
        StockLevelFilter.outOfStock => 'Out of Stock',
        _ => '',
      };
      chips.add(
        chip(
          'Quantity: $t',
          () => _apply(() => _filters.stockLevel = StockLevelFilter.all),
        ),
      );
    }
    if (_filters.managed != null) {
      chips.add(
        chip(
          _filters.managed! ? 'Managed' : 'Un-Managed',
          () => _apply(() => _filters.managed = null),
        ),
      );
    }
    if (_filters.sellingMin != null || _filters.sellingMax != null) {
      chips.add(
        chip(
          'Selling: ${_filters.sellingMin != null ? _money(_filters.sellingMin!) : 'Any'}'
          ' - ${_filters.sellingMax != null ? _money(_filters.sellingMax!) : 'Any'}',
          () {
            _sellMinCtrl.clear();
            _sellMaxCtrl.clear();
            _apply(() {
              _filters.sellingMin = null;
              _filters.sellingMax = null;
            });
          },
        ),
      );
    }
    if (_canSeeCost && (_filters.costMin != null || _filters.costMax != null)) {
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
    if (chips.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Wrap(spacing: 6, runSpacing: 4, children: chips),
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
  }) => Text(
    text,
    maxLines: 2,
    overflow: TextOverflow.ellipsis,
    style: _cellStyle(theme, bold: bold, color: color),
  );

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
        cell: (r, i) => _txt(theme, '${pageStart + i}', bold: true),
      ),
      _Col(
        label: 'Item Name',
        width: 230,
        sort: ItemsSortField.name,
        cell: (r, i) => _txt(theme, r.name, bold: true),
      ),
      _Col(
        label: 'Quantity',
        width: 120,
        sort: ItemsSortField.quantity,
        alignEnd: true,
        cell:
            (r, i) => _txt(
              theme,
              !seeQty
                  ? '****'
                  : (r.quantity == null ? dash : _qty(r.quantity!)),
              bold: true,
              color:
                  r.isManaged && r.stockLevel == StockLevelFilter.outOfStock
                      ? red
                      : null,
            ),
      ),
      _Col(
        label: 'Primary Unit',
        width: 110,
        cell: (r, i) => _txt(theme, r.primaryUnit),
      ),
      _Col(
        label: 'Opening Stock',
        width: 130,
        sort: ItemsSortField.openingStock,
        alignEnd: true,
        cell: (r, i) {
          if (!seeQty) return _txt(theme, '****');
          if (!r.isManaged) return _txt(theme, dash);
          if (!trackHistory) return _txt(theme, 'N/A');
          final v = _movements[r.uuid]?.opening;
          return _txt(theme, v == null ? dash : _qty(v));
        },
      ),
      _Col(
        label: 'Closing Stock',
        width: 130,
        sort: ItemsSortField.closingStock,
        alignEnd: true,
        cell: (r, i) {
          if (!seeQty) return _txt(theme, '****');
          if (!r.isManaged) return _txt(theme, dash);
          if (!trackHistory) return _txt(theme, 'N/A');
          final v = _movements[r.uuid]?.closing;
          return _txt(theme, v == null ? dash : _qty(v));
        },
      ),
      _Col(
        label: 'Stock Change',
        width: 130,
        sort: ItemsSortField.stockChange,
        alignEnd: true,
        cell: (r, i) {
          if (!seeQty) return _txt(theme, '****');
          if (!r.isManaged) return _txt(theme, dash);
          if (!trackHistory) return _txt(theme, 'N/A');
          final diff = _movements[r.uuid]?.change;
          if (diff == null) return _txt(theme, dash);
          final text = diff > 0 ? '+${_qty(diff)}' : _qty(diff);
          final color = diff > 0 ? green : (diff < 0 ? red : null);
          return _txt(theme, text, color: color, bold: diff != 0);
        },
      ),
      _Col(
        label: 'Selling Price',
        width: 130,
        sort: ItemsSortField.sellingPrice,
        alignEnd: true,
        cell: (r, i) => _txt(theme, _money(r.sellingPrice)),
      ),
      _Col(
        label: 'Total Selling Value',
        width: 160,
        sort: ItemsSortField.totalSellingValue,
        alignEnd: true,
        cell:
            (r, i) => _txt(
              theme,
              r.totalSellingValue == null ? dash : _money(r.totalSellingValue!),
              bold: true,
            ),
      ),
      if (cost)
        _Col(
          label: 'Cost Price',
          width: 130,
          sort: ItemsSortField.costPrice,
          alignEnd: true,
          cell: (r, i) => _txt(theme, _money(r.costPrice)),
        ),
      if (cost)
        _Col(
          label: 'Total Cost Value',
          width: 160,
          sort: ItemsSortField.totalCostValue,
          alignEnd: true,
          cell:
              (r, i) => _txt(
                theme,
                r.totalCostValue == null ? dash : _money(r.totalCostValue!),
                bold: true,
              ),
        ),
      if (cost)
        _Col(
          label: 'Profit Per Unit',
          width: 140,
          sort: ItemsSortField.profitPerUnit,
          alignEnd: true,
          cell:
              (r, i) => _txt(
                theme,
                _money(r.profitPerUnit),
                bold: true,
                color: r.profitPerUnit < 0 ? red : green,
              ),
        ),
      if (cost)
        _Col(
          label: 'Total Profit',
          width: 140,
          sort: ItemsSortField.profit,
          alignEnd: true,
          cell:
              (r, i) => _txt(
                theme,
                r.profit == null ? dash : _money(r.profit!),
                bold: true,
                color: r.profit == null ? null : (r.profit! < 0 ? red : green),
              ),
        ),
      if (cost)
        _Col(
          label: 'Profit Margin',
          width: 120,
          sort: ItemsSortField.margin,
          alignEnd: true,
          cell:
              (r, i) => _txt(
                theme,
                r.margin == null
                    ? 'N/A'
                    : '${formatLargeNumberDouble(double.parse(r.margin!.toStringAsFixed(2)))}%',
                color: r.margin == null ? null : (r.margin! < 0 ? red : green),
              ),
        ),
      _Col(
        label: 'Discount',
        width: 100,
        alignEnd: true,
        cell:
            (r, i) => _txt(
              theme,
              (r.discount == null || r.discount == 0)
                  ? dash
                  : '${formatLargeNumberDouble(r.discount!)}%',
            ),
      ),
      _Col(
        label: 'Expiry Date',
        width: 140,
        sort: ItemsSortField.expiry,
        cell: (r, i) {
          if (r.expiryDate == null) {
            return _txt(theme, 'Not Set', color: Colors.grey);
          }
          if (r.isExpired) {
            return _txt(theme, 'Expired', bold: true, color: red);
          }
          return _txt(theme, formatDateTime(r.expiryDate!));
        },
      ),
      if (_departmentsEnabled)
        _Col(
          label: 'Department',
          width: 160,
          sort: ItemsSortField.department,
          cell:
              (r, i) => _txt(
                theme,
                r.departmentLabel,
                color: r.departmentUuid == null ? Colors.grey : null,
              ),
        ),
      _Col(
        label: 'Quantity Type',
        width: 140,
        cell:
            (r, i) => Align(
              alignment: Alignment.centerLeft,
              child: _badge(
                r.quantityTypeLabel,
                r.isTwoDimensional ? Colors.deepPurple : Colors.blueGrey,
              ),
            ),
      ),
      _Col(
        label: 'Is-Managed',
        width: 130,
        cell:
            (r, i) => Align(
              alignment: Alignment.centerLeft,
              child: _badge(
                r.isManaged ? 'Managed' : 'Un-Managed',
                r.isManaged ? green : Colors.orange.shade800,
              ),
            ),
      ),
      _Col(
        label: 'Created Date',
        width: 140,
        sort: ItemsSortField.createdAt,
        cell:
            (r, i) => _txt(
              theme,
              r.createdAt == null ? dash : formatDateTime(r.createdAt!),
            ),
      ),
      _Col(
        label: 'Created Time',
        width: 120,
        sort: ItemsSortField.createdAt,
        cell:
            (r, i) => _txt(
              theme,
              r.createdAt == null ? dash : formatTime(r.createdAt!),
            ),
      ),
      _Col(
        label: 'Category',
        width: 180,
        sort: ItemsSortField.category,
        cell:
            (r, i) => _txt(
              theme,
              r.categoryLabel,
              color: r.categoryNames.isEmpty ? Colors.grey : null,
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
        textAlign: c.alignEnd ? TextAlign.end : TextAlign.start,
        style: TextStyle(
          fontSize: theme.mobileTexts.b3.fontSize,
          fontWeight: FontWeight.bold,
          color: isSorted ? accent : Colors.black87,
        ),
      ),
    );
    final content = Row(
      mainAxisAlignment:
          c.alignEnd ? MainAxisAlignment.end : MainAxisAlignment.start,
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
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: content,
              )
              : InkWell(
                mouseCursor: SystemMouseCursors.click,
                onTap: () => _setSort(c.sort!),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: content,
                ),
              ),
    );
  }

  Widget _table(ThemeProvider theme, ItemsReportPage res) {
    final cols = _columns(theme, res.firstIndex);
    final totalWidth = cols.fold<double>(0, (s, c) => s + c.width);

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        children: [
          Expanded(
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
                                color: theme.lightModeColor.prColor300
                                    .withAlpha(22),
                                child: Row(
                                  children:
                                      cols
                                          .map((c) => _headerCell(theme, c))
                                          .toList(),
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
                                    itemBuilder: (context, i) {
                                      final r = res.rows[i];
                                      return Material(
                                        color:
                                            i.isEven
                                                ? Colors.white
                                                : Colors.grey.shade50,
                                        child: InkWell(
                                          mouseCursor: SystemMouseCursors.click,
                                          hoverColor: theme
                                              .lightModeColor
                                              .prColor300
                                              .withAlpha(20),
                                          onTap: () => _openItemDetails(r),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              border: Border(
                                                bottom: BorderSide(
                                                  color: Colors.grey.shade100,
                                                ),
                                              ),
                                            ),
                                            child: Row(
                                              children:
                                                  cols
                                                      .map(
                                                        (c) => SizedBox(
                                                          width: c.width,
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets.symmetric(
                                                                  horizontal:
                                                                      10,
                                                                ),
                                                            child: Align(
                                                              alignment:
                                                                  c.alignEnd
                                                                      ? Alignment
                                                                          .centerRight
                                                                      : Alignment
                                                                          .centerLeft,
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
            if (!iconRight) Icon(icon, size: 16, color: color),
            Text(
              text,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
            if (iconRight) Icon(icon, size: 16, color: color),
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
                ? 'No items'
                : 'Showing ${res.firstIndex}-${res.lastIndex} of ${res.totalCount} items',
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
