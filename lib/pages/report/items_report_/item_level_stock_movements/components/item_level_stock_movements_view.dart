import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_categories/category_class.dart';
import 'package:stockall/classes/temp_departments_class/department_class.dart';
import 'package:stockall/classes/temp_item_history/item_history.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/date_picker_function.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/refresh_functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/products/product_details/product_details_page.dart';
import 'package:stockall/pages/report/components/export/report_export_button.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/items_report_/item_history_summary/class/item_history_summary_export_spec.dart'
    show stockMovementsSizeLabels;
import 'package:stockall/pages/report/items_report_/item_history_summary/class/item_history_summary_logic.dart';
import 'package:stockall/pages/report/items_report_/item_level_stock_movements/class/item_level_stock_movements_export_spec.dart';
import 'package:stockall/providers/theme_provider.dart';
import 'package:stockall/pages/report/components/report_department_scope.dart';

const int itemStockMovementsPageSize = 100;

class _MoveCol {
  final String label;
  final double width;
  final ItemHistorySummarySortField? sort;
  final TextAlign align;
  final String? tooltip;
  final Widget Function(
    ItemHistorySummaryRow row,
    int index,
  )
  cell;

  const _MoveCol({
    required this.label,
    required this.width,
    required this.cell,
    this.sort,
    this.align = TextAlign.center,
    this.tooltip,
  });
}

class ItemLevelStockMovementsView extends StatefulWidget {
  final bool isDesktop;
  final ItemHistoryPeriod? initialPeriod;
  final DateTimeRange? initialCustomRange;
  final String? initialCategoryKey;
  final String? initialDepartmentKey;
  final String? initialSearch;
  final ItemHistoryMovementFilter? initialMovementFilter;

  const ItemLevelStockMovementsView({
    super.key,
    required this.isDesktop,
    this.initialPeriod,
    this.initialCustomRange,
    this.initialCategoryKey,
    this.initialDepartmentKey,
    this.initialSearch,
    this.initialMovementFilter,
  });

  @override
  State<ItemLevelStockMovementsView> createState() =>
      _ItemLevelStockMovementsViewState();
}

class _ItemLevelStockMovementsViewState
    extends State<ItemLevelStockMovementsView> {
  final ItemHistorySummaryFilters _filters =
      ItemHistorySummaryFilters();
  final TextEditingController _searchCtrl =
      TextEditingController();
  final ScrollController _hScroll = ScrollController();
  final ScrollController _vScroll = ScrollController();

  ItemHistoryPeriod _period = ItemHistoryPeriod.thisMonth;
  DateTimeRange? _customRange;
  ItemHistorySummarySortField _sortField =
      ItemHistorySummarySortField.rowIndex;
  bool _ascending = true;
  int _page = 1;
  bool _showFilters = false;

  bool _loading = true;
  String? _error;

  List<TempProductClass> _products = [];
  List<ItemHistory> _histories = [];
  List<CategoryClass> _categories = [];
  List<DepartmentClass> _departments = [];

  bool get _departmentsEnabled =>
      shopSingle()?.manageDepartments == true;

  bool get _canViewAllDepartments => authorization(
    authorized: Authorizations().viewAllDepartments,
  );

  bool get _manageProductions =>
      shopSingle()?.manageProductions == true;

  String? get _currentDepartmentUuid =>
      returnDepartmentProvider().currentDepartment()?.uuid;

  List<ItemHistorySummaryRow> _allRows = [];
  List<ItemHistorySummaryRow> _filteredSortedRows = [];
  ItemHistorySummaryPageResult? _result;

  @override
  void initState() {
    super.initState();
    if (widget.initialPeriod != null) {
      _period = widget.initialPeriod!;
    }
    if (widget.initialCustomRange != null) {
      _customRange = widget.initialCustomRange;
    }
    if (widget.initialCategoryKey != null) {
      _filters.categoryKey = widget.initialCategoryKey;
    }
    if (widget.initialDepartmentKey != null) {
      _filters.departmentKey = widget.initialDepartmentKey;
    }
    if (widget.initialSearch != null &&
        widget.initialSearch!.isNotEmpty) {
      _searchCtrl.text = widget.initialSearch!;
      _filters.search = widget.initialSearch!;
    }
    if (widget.initialMovementFilter != null) {
      _filters.movementFilter =
          widget.initialMovementFilter!;
    }

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

  Future<void> _load({
    bool refreshFromStore = false,
  }) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final isAllTime =
          _period == ItemHistoryPeriod.allTime;
      final resolvedRange =
          isAllTime
              ? null
              : ItemHistorySummaryBuilder.resolveDateRange(
                period: _period,
                businessNow: resolveBusinessDate(
                  DateTime.now(),
                ),
                customRange: _customRange,
              );
      if (refreshFromStore && mounted) {
        final refresh = RefreshFunctions(context);
        await refresh.refreshProducts(context);
        if (!mounted) return;
        await returnItemHistoryProvider().getItemHistories(
          startDate: resolvedRange?.start,
          endDate: resolvedRange?.end,
          fetchAll: isAllTime,
          forceRefresh: true,
        );
      } else {
        await returnItemHistoryProvider()
            .getItemHistoriesOffline();
        if (!isAllTime && resolvedRange != null) {
          await returnItemHistoryProvider()
              .getItemHistories(
                startDate: resolvedRange.start,
                endDate: resolvedRange.end,
                forceRefresh: false,
              );
        }
      }

      _categories =
          returnCategoriesProvider().categoriesMain;
      _departments = returnDepartmentProvider().departments;
      _products = returnData().productList();

      // Scoped strictly to current shop
      final currentShopId = shopId();
      final allHistories =
          returnItemHistoryProvider().itemHistories;
      final shopHistories =
          allHistories
              .where((h) => h.shopId == currentShopId)
              .toList();

      // Department access rules
      if (_departmentsEnabled && !_canViewAllDepartments) {
        _histories =
            shopHistories
                .where(
                  (h) =>
                      reportDepartmentMatches(
                        h.departmentUuid,
                        _currentDepartmentUuid,
                      ),
                )
                .toList();
      } else {
        _histories = shopHistories;
      }

      _recompute();
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  void _recompute() {
    final now = resolveBusinessDate(DateTime.now());
    final res =
        ItemHistorySummaryBuilder.buildSummaryAndRows(
          products: _products,
          histories: _histories,
          period: _period,
          businessNow: now,
          manageProductions: _manageProductions,
          customRange: _customRange,
        );

    _allRows = res.rows;
    _applyFilterAndSort();
  }

  void _applyFilterAndSort({bool resetPage = false}) {
    if (resetPage) _page = 1;

    _filteredSortedRows =
        ItemHistorySummaryBuilder.filterAndSortRows(
          rows: _allRows,
          filters: _filters,
          sortField: _sortField,
          ascending: _ascending,
          departmentsEnabled: _departmentsEnabled,
        );

    for (int i = 0; i < _filteredSortedRows.length; i++) {
      _filteredSortedRows[i].index = i + 1;
    }

    _result = ItemHistorySummaryBuilder.paginate(
      _filteredSortedRows,
      _page,
      pageSize: itemStockMovementsPageSize,
    );
    _page = _result!.page;
  }

  /// What the Export button exports: the full filtered and sorted list
  /// (every page), with the period, filters and sort shown on screen.
  ReportExportSpec _exportSpec() {
    return itemStockMovementsExportSpec(
      rows: _filteredSortedRows,
      filters: _filters,
      sortField: _sortField,
      ascending: _ascending,
      period: _period,
      range: ItemHistorySummaryBuilder.resolveDateRange(
        period: _period,
        businessNow: resolveBusinessDate(DateTime.now()),
        customRange: _customRange,
      ),
      currency: currencySymbol(context: context),
      manageProductions: _manageProductions,
      departmentsEnabled: _departmentsEnabled,
      categoryNames: {
        for (final c in _categories) c.uuid: c.name,
      },
      departmentNames: {
        for (final d in _departments) d.uuid: d.name,
      },
      sizeLabels: stockMovementsSizeLabels(_products),
    );
  }

  void _onSort(ItemHistorySummarySortField field) {
    setState(() {
      if (_sortField == field) {
        _ascending = !_ascending;
      } else {
        _sortField = field;
        _ascending = true;
      }
      _applyFilterAndSort();
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
    setState(() {
      _page = p;
      _applyFilterAndSort();
    });
  }

  void _pickCustomRange() {
    final theme = returnTheme(context, listen: false);
    mainDatePicker(
      context: context,
      theme: theme,
      singleDate: (date) {
        if (date == null) return;
        final d = DateTime(date.year, date.month, date.day);
        setState(() {
          _period = ItemHistoryPeriod.custom;
          _customRange = DateTimeRange(start: d, end: d);
          _page = 1;
          _recompute();
        });
        _load(refreshFromStore: false);
      },
      rangeDate: (start, end) {
        if (start == null) return;
        final s = DateTime(
          start.year,
          start.month,
          start.day,
        );
        final e =
            end == null
                ? s
                : DateTime(end.year, end.month, end.day);
        setState(() {
          _period = ItemHistoryPeriod.custom;
          _customRange = DateTimeRange(start: s, end: e);
          _page = 1;
          _recompute();
        });
        _load(refreshFromStore: false);
      },
    );
  }

  // String _formatQty(double v) => formatLargeNumberDouble(v);

  void _openItemDetails(String uuid) {
    if (uuid.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                ProductDetailsPage(productUuid: uuid),
      ),
    ).then((_) {
      if (mounted) _load(refreshFromStore: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = returnTheme(context);
    returnShopProvider(context: context);

    return Scaffold(
      backgroundColor: const Color.fromARGB(
        255,
        252,
        253,
        255,
      ),
      appBar: appBar(
        context: context,
        title: 'Item-Level Stock Movements',
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
          horizontal:
              screenWidth(context) > mobileScreen ? 20 : 10,
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
                _result != null)
              _pager(theme),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Toolbar and Filters
  // ---------------------------------------------------------------------------
  Widget _toolbar(ThemeProvider theme) {
    bool isOpen = false;
    return StatefulBuilder(
      builder:
          (context, setState) => Container(
            width:
                screenWidth(context) < mobileScreen
                    ? double.infinity
                    : null,
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey.shade200,
              ),
            ),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    right:
                        screenWidth(context) < mobileScreen
                            ? 0
                            : 5.0,
                  ),
                  child: SizedBox(
                    width:
                        screenWidth(context) < mobileScreen
                            ? double.infinity
                            : 220,
                    height: 36,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchCtrl,
                            onChanged: (val) {
                              setState(() {
                                _filters.search = val;
                                _applyFilterAndSort(
                                  resetPage: true,
                                );
                              });
                            },
                            style: TextStyle(
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b4
                                      .fontSize,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Search items...',
                              prefixIcon: const Icon(
                                Icons.search,
                                size: 16,
                              ),
                              suffixIcon:
                                  _searchCtrl
                                          .text
                                          .isNotEmpty
                                      ? IconButton(
                                        icon: const Icon(
                                          Icons.clear,
                                          size: 14,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _searchCtrl
                                                .clear();
                                            _filters.search =
                                                '';
                                            _applyFilterAndSort(
                                              resetPage:
                                                  true,
                                            );
                                          });
                                        },
                                      )
                                      : null,
                              contentPadding:
                                  const EdgeInsets.symmetric(
                                    vertical: 0,
                                    horizontal: 8,
                                  ),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                      6,
                                    ),
                                borderSide: BorderSide(
                                  color:
                                      Colors.grey.shade300,
                                ),
                              ),
                              enabledBorder:
                                  OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(
                                          6,
                                        ),
                                    borderSide: BorderSide(
                                      color:
                                          Colors
                                              .grey
                                              .shade200,
                                    ),
                                  ),
                            ),
                          ),
                        ),
                        if (screenWidth(context) <
                            mobileScreen)
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 10.0,
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius:
                                    BorderRadius.circular(
                                      5,
                                    ),
                                onTap: () {
                                  setState(() {
                                    isOpen = !isOpen;
                                  });
                                },
                                mouseCursor:
                                    SystemMouseCursors
                                        .click,
                                child: Padding(
                                  padding: EdgeInsets.all(
                                    5,
                                  ),
                                  child: Row(
                                    mainAxisSize:
                                        MainAxisSize.min,
                                    spacing: 3,
                                    children: [
                                      Text(
                                        style: TextStyle(
                                          fontSize:
                                              theme
                                                  .mobileTexts
                                                  .b4
                                                  .fontSize,
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                        ),
                                        'Filter',
                                      ),
                                      Icon(
                                        isOpen
                                            ? Icons
                                                .keyboard_arrow_up
                                            : Icons
                                                .keyboard_arrow_down,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment:
                      WrapCrossAlignment.center,
                  children: [
                    if (isOpen ||
                        screenWidth(context) >
                            mobileScreen) ...[
                      _periodSelector(theme),
                      _movementFilterDropdown(theme),
                      _categoryDropdown(theme),
                      if (_departmentsEnabled)
                        _departmentDropdown(theme),
                      ReportExportButton(
                        buildSpec: _exportSpec,
                      ),
                      if (!widget.isDesktop)
                        IconButton(
                          tooltip:
                              _showFilters
                                  ? 'Hide Filters'
                                  : 'More Filters',
                          icon: Icon(
                            _showFilters
                                ? Icons.filter_list_off
                                : Icons.filter_list,
                            size: 20,
                          ),
                          onPressed:
                              () => setState(
                                () =>
                                    _showFilters =
                                        !_showFilters,
                              ),
                        ),
                    ],

                    if (_filters.hasAnything)
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _searchCtrl.clear();
                            _filters.clearAll();
                            _applyFilterAndSort(
                              resetPage: true,
                            );
                          });
                        },
                        icon: const Icon(
                          Icons.clear_all_rounded,
                          size: 16,
                        ),
                        label: const Text('Clear'),
                        style: TextButton.styleFrom(
                          foregroundColor:
                              theme
                                  .lightModeColor
                                  .errorColor200,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
    );
  }

  Widget _periodSelector(ThemeProvider theme) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ItemHistoryPeriod>(
          value: _period,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            size: 16,
          ),
          style: TextStyle(
            fontSize: theme.mobileTexts.b4.fontSize,
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
          items:
              ItemHistoryPeriod.values.map((p) {
                return DropdownMenuItem<ItemHistoryPeriod>(
                  value: p,
                  child: Text(p.label),
                );
              }).toList(),
          onChanged: (val) {
            if (val == null) return;
            if (val == ItemHistoryPeriod.custom) {
              _pickCustomRange();
            } else {
              setState(() {
                _period = val;
                _customRange = null;
                _page = 1;
                _recompute();
              });
              if (val != ItemHistoryPeriod.allTime) {
                _load(refreshFromStore: false);
              }
            }
          },
        ),
      ),
    );
  }

  Widget _movementFilterDropdown(ThemeProvider theme) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ItemHistoryMovementFilter>(
          value: _filters.movementFilter,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            size: 16,
          ),
          style: TextStyle(
            fontSize: theme.mobileTexts.b4.fontSize,
            color: Colors.black87,
          ),
          items:
              ItemHistoryMovementFilter.values.map((m) {
                return DropdownMenuItem<
                  ItemHistoryMovementFilter
                >(value: m, child: Text(m.label));
              }).toList(),
          onChanged: (val) {
            if (val == null) return;
            setState(() {
              _filters.movementFilter = val;
              _applyFilterAndSort(resetPage: true);
            });
          },
        ),
      ),
    );
  }

  Widget _categoryDropdown(ThemeProvider theme) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: _filters.categoryKey,
          hint: Text(
            'All Categories',
            style: TextStyle(
              fontSize: theme.mobileTexts.b4.fontSize,
            ),
          ),
          icon: const Icon(
            Icons.keyboard_arrow_down,
            size: 16,
          ),
          style: TextStyle(
            fontSize: theme.mobileTexts.b4.fontSize,
            color: Colors.black87,
          ),
          items: [
            DropdownMenuItem<String?>(
              value: null,
              child: Text(
                'All Categories',
                style: TextStyle(
                  fontSize: theme.mobileTexts.b4.fontSize,
                ),
              ),
            ),
            ..._categories.map((c) {
              return DropdownMenuItem<String?>(
                value: c.uuid,
                child: Text(
                  c.name,
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b4.fontSize,
                  ),
                ),
              );
            }),
            DropdownMenuItem<String?>(
              value: itemHistorySummaryNoneKey,
              child: Text(
                'Uncategorized',
                style: TextStyle(
                  fontSize: theme.mobileTexts.b4.fontSize,
                ),
              ),
            ),
          ],
          onChanged: (val) {
            setState(() {
              _filters.categoryKey = val;
              _applyFilterAndSort(resetPage: true);
            });
          },
        ),
      ),
    );
  }

  Widget _departmentDropdown(ThemeProvider theme) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: _filters.departmentKey,
          hint: Text(
            'All Departments',
            style: TextStyle(
              fontSize: theme.mobileTexts.b4.fontSize,
            ),
          ),
          icon: const Icon(
            Icons.keyboard_arrow_down,
            size: 16,
          ),
          style: TextStyle(
            fontSize: theme.mobileTexts.b4.fontSize,
            color: Colors.black87,
          ),
          items: [
            DropdownMenuItem<String?>(
              value: null,
              child: Text(
                'All Departments',
                style: TextStyle(
                  fontSize: theme.mobileTexts.b4.fontSize,
                ),
              ),
            ),
            ..._departments.map((d) {
              return DropdownMenuItem<String?>(
                value: d.uuid,
                child: Text(
                  d.name,
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b4.fontSize,
                  ),
                ),
              );
            }),
            DropdownMenuItem<String?>(
              value: itemHistorySummaryNoneKey,
              child: Text(
                'Unassigned',
                style: TextStyle(
                  fontSize: theme.mobileTexts.b4.fontSize,
                ),
              ),
            ),
          ],
          onChanged: (val) {
            setState(() {
              _filters.departmentKey = val;
              _applyFilterAndSort(resetPage: true);
            });
          },
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
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _categoryDropdown(theme),
          if (_departmentsEnabled)
            _departmentDropdown(theme),
          _movementFilterDropdown(theme),
        ],
      ),
    );
  }

  Widget _activeChips(ThemeProvider theme) {
    final chips = <Widget>[];

    if (_period == ItemHistoryPeriod.custom &&
        _customRange != null) {
      chips.add(
        _chip(
          theme,
          'Period: ${formatDateTime(_customRange!.start)} - ${formatDateTime(_customRange!.end)}',
          onDelete: () {
            setState(() {
              _period = ItemHistoryPeriod.thisMonth;
              _customRange = null;
              _recompute();
            });
          },
        ),
      );
    }

    if (_filters.search.trim().isNotEmpty) {
      chips.add(
        _chip(
          theme,
          'Search: "${_filters.search.trim()}"',
          onDelete: () {
            setState(() {
              _searchCtrl.clear();
              _filters.search = '';
              _applyFilterAndSort(resetPage: true);
            });
          },
        ),
      );
    }

    if (_filters.movementFilter !=
        ItemHistoryMovementFilter.all) {
      chips.add(
        _chip(
          theme,
          'Movement: ${_filters.movementFilter.label}',
          onDelete: () {
            setState(() {
              _filters.movementFilter =
                  ItemHistoryMovementFilter.all;
              _applyFilterAndSort(resetPage: true);
            });
          },
        ),
      );
    }

    if (_filters.categoryKey != null) {
      String label = 'Category: Uncategorized';
      if (_filters.categoryKey !=
          itemHistorySummaryNoneKey) {
        CategoryClass? cat;
        for (final c in _categories) {
          if (c.uuid == _filters.categoryKey) {
            cat = c;
            break;
          }
        }
        label = 'Category: ${cat?.name ?? 'Category'}';
      }
      chips.add(
        _chip(
          theme,
          label,
          onDelete: () {
            setState(() {
              _filters.categoryKey = null;
              _applyFilterAndSort(resetPage: true);
            });
          },
        ),
      );
    }

    if (_filters.departmentKey != null &&
        _departmentsEnabled) {
      String label = 'Department: Unassigned';
      if (_filters.departmentKey !=
          itemHistorySummaryNoneKey) {
        DepartmentClass? dept;
        for (final d in _departments) {
          if (d.uuid == _filters.departmentKey) {
            dept = d;
            break;
          }
        }
        label = 'Department: ${dept?.name ?? 'Department'}';
      }
      chips.add(
        _chip(
          theme,
          label,
          onDelete: () {
            setState(() {
              _filters.departmentKey = null;
              _applyFilterAndSort(resetPage: true);
            });
          },
        ),
      );
    }

    if (chips.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Row(
        children: [
          Expanded(
            child: Wrap(
              spacing: 6,
              runSpacing: 4,
              children: chips,
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(
    ThemeProvider theme,
    String text, {
    required VoidCallback onDelete,
  }) {
    return Chip(
      label: Text(
        text,
        style: TextStyle(
          fontSize: theme.mobileTexts.b5.fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
      deleteIcon: const Icon(Icons.close_rounded, size: 14),
      onDeleted: onDelete,
      materialTapTargetSize:
          MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(
        horizontal: 4,
        vertical: 0,
      ),
      backgroundColor: theme.lightModeColor.prColor300
          .withAlpha(20),
      side: BorderSide(
        color: theme.lightModeColor.prColor300.withAlpha(
          50,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Main Content & Table
  // ---------------------------------------------------------------------------
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
            Text(
              _error!,
              style: TextStyle(
                fontSize: theme.mobileTexts.b4.fontSize,
                color: Colors.grey.shade600,
              ),
            ),
            ElevatedButton(
              onPressed:
                  () => _load(refreshFromStore: true),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final res = _result;
    if (res == null || res.rows.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 40,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 8),
            Text(
              'No matching inventory items found',
              style: TextStyle(
                fontSize: theme.mobileTexts.b2.fontSize,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    final cols = _buildColumns(theme);
    final totalWidth = cols.fold<double>(
      0.0,
      (w, c) => w + c.width,
    );

    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Scrollbar(
          controller: _hScroll,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: _hScroll,
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: math.max(
                totalWidth,
                MediaQuery.of(context).size.width,
              ),
              child: Column(
                children: [
                  _headerRow(theme, cols),
                  const Divider(height: 1, thickness: 1),
                  Expanded(
                    child: Scrollbar(
                      controller: _vScroll,
                      thumbVisibility: true,
                      child: ListView.builder(
                        controller: _vScroll,
                        itemCount: res.rows.length,
                        itemBuilder: (context, i) {
                          final r = res.rows[i];
                          return Material(
                            color:
                                i.isEven
                                    ? Colors.white
                                    : Colors.grey.shade50,
                            child: InkWell(
                              mouseCursor:
                                  SystemMouseCursors.click,
                              hoverColor: theme
                                  .lightModeColor
                                  .prColor300
                                  .withAlpha(20),
                              onTap:
                                  () => _openItemDetails(
                                    r.uuid,
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
                                        return SizedBox(
                                          width: c.width,
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.symmetric(
                                                  horizontal:
                                                      10,
                                                  vertical:
                                                      6,
                                                ),
                                            child: Align(
                                              alignment:
                                                  c.align ==
                                                          TextAlign.start
                                                      ? Alignment
                                                          .centerLeft
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
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Columns Definition
  // ---------------------------------------------------------------------------
  List<_MoveCol> _buildColumns(ThemeProvider theme) {
    final showProd = _manageProductions;

    return [
      // 1. No.
      _MoveCol(
        label: 'No.',
        width: 60,
        sort: ItemHistorySummarySortField.rowIndex,
        cell:
            (r, i) => Text(
              '${r.index}',
              style: TextStyle(
                fontSize: theme.mobileTexts.b4.fontSize,
                color: Colors.grey.shade600,
              ),
            ),
      ),
      // 2. Item Name
      _MoveCol(
        label: 'Item Name',
        width: 230,
        align: TextAlign.start,
        sort: ItemHistorySummarySortField.itemName,
        cell:
            (r, i) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  r.name,
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b3.fontSize,
                    fontWeight: FontWeight.bold,
                    color: theme.lightModeColor.prColor300,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  r.primaryUnit,
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b5.fontSize,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
      ),
      // 3. Opening Stock
      _MoveCol(
        label: 'Opening Stock',
        width: 135,
        sort: ItemHistorySummarySortField.openingStock,
        tooltip:
            'Stock balance immediately before the period (Primary Unit)',
        cell:
            (r, i) => Text(
              r.openingStockText,
              style: TextStyle(
                fontSize: theme.mobileTexts.b4.fontSize,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
      ),
      // 4. Closing Stock
      _MoveCol(
        label: 'Closing Stock',
        width: 135,
        sort: ItemHistorySummarySortField.closingStock,
        tooltip:
            'Stock balance immediately after the period (Primary Unit)',
        cell:
            (r, i) => Text(
              r.closingStockText,
              style: TextStyle(
                fontSize: theme.mobileTexts.b4.fontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2563EB),
              ),
            ),
      ),
      // 5. Current Quantity
      _MoveCol(
        label: 'Current Quantity',
        width: 140,
        sort: ItemHistorySummarySortField.currentQuantity,
        tooltip:
            'Live current inventory balance (Primary Unit)',
        cell:
            (r, i) => Text(
              r.currentQuantityText,
              style: TextStyle(
                fontSize: theme.mobileTexts.b4.fontSize,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
      ),
      // 6. Net Change
      _MoveCol(
        label: 'Net Change',
        width: 135,
        sort: ItemHistorySummarySortField.netQuantityChange,
        tooltip: 'Net Stock Additions - Reductions',
        cell: (r, i) {
          final pos = r.netQuantityChange > 0;
          final neg = r.netQuantityChange < 0;
          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color:
                  pos
                      ? const Color(
                        0xFF16A34A,
                      ).withAlpha(18)
                      : neg
                      ? const Color(
                        0xFFDC2626,
                      ).withAlpha(18)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              r.netQuantityChangeText,
              style: TextStyle(
                fontSize: theme.mobileTexts.b4.fontSize,
                fontWeight: FontWeight.bold,
                color:
                    pos
                        ? const Color(0xFF16A34A)
                        : neg
                        ? const Color(0xFFDC2626)
                        : Colors.grey.shade600,
              ),
            ),
          );
        },
      ),
      // 7. Sold
      _MoveCol(
        label: 'Sold',
        width: 125,
        sort: ItemHistorySummarySortField.sold,
        cell:
            (r, i) => Text(
              r.soldText,
              style: TextStyle(
                fontSize: theme.mobileTexts.b4.fontSize,
                color:
                    r.sold > 0
                        ? const Color(0xFFEA580C)
                        : Colors.grey.shade400,
                fontWeight:
                    r.sold > 0
                        ? FontWeight.bold
                        : FontWeight.normal,
              ),
            ),
      ),
      // 8. Returned (Sales)
      _MoveCol(
        label: 'Returned (Sales)',
        width: 140,
        sort: ItemHistorySummarySortField.returnedReceipt,
        tooltip:
            'Customer returns from sales receipts and invoices',
        cell:
            (r, i) => Text(
              r.returnedReceiptText,
              style: TextStyle(
                fontSize: theme.mobileTexts.b4.fontSize,
                color:
                    r.returnedReceipt > 0
                        ? const Color(0xFF16A34A)
                        : Colors.grey.shade400,
                fontWeight:
                    r.returnedReceipt > 0
                        ? FontWeight.bold
                        : FontWeight.normal,
              ),
            ),
      ),
      // 9. Purchased
      _MoveCol(
        label: 'Purchased',
        width: 130,
        sort: ItemHistorySummarySortField.purchased,
        cell:
            (r, i) => Text(
              r.purchasedText,
              style: TextStyle(
                fontSize: theme.mobileTexts.b4.fontSize,
                color:
                    r.purchased > 0
                        ? const Color(0xFF3B82F6)
                        : Colors.grey.shade400,
                fontWeight:
                    r.purchased > 0
                        ? FontWeight.bold
                        : FontWeight.normal,
              ),
            ),
      ),
      // 10. Returned (Purchase)
      _MoveCol(
        label: 'Returned (Purchase)',
        width: 155,
        sort: ItemHistorySummarySortField.returnedPurchase,
        tooltip:
            'Stock returned to suppliers from purchase',
        cell:
            (r, i) => Text(
              r.returnedPurchaseText,
              style: TextStyle(
                fontSize: theme.mobileTexts.b4.fontSize,
                color:
                    r.returnedPurchase > 0
                        ? const Color(0xFFDC2626)
                        : Colors.grey.shade400,
                fontWeight:
                    r.returnedPurchase > 0
                        ? FontWeight.bold
                        : FontWeight.normal,
              ),
            ),
      ),
      // 11. Transfered In
      _MoveCol(
        label: 'Transfered In',
        width: 130,
        sort: ItemHistorySummarySortField.transferredIn,
        cell:
            (r, i) => Text(
              r.transferredInText,
              style: TextStyle(
                fontSize: theme.mobileTexts.b4.fontSize,
                color:
                    r.transferredIn > 0
                        ? const Color(0xFF0284C7)
                        : Colors.grey.shade400,
                fontWeight:
                    r.transferredIn > 0
                        ? FontWeight.bold
                        : FontWeight.normal,
              ),
            ),
      ),
      // 12. Transfered Out
      _MoveCol(
        label: 'Transfered Out',
        width: 130,
        sort: ItemHistorySummarySortField.transferredOut,
        cell:
            (r, i) => Text(
              r.transferredOutText,
              style: TextStyle(
                fontSize: theme.mobileTexts.b4.fontSize,
                color:
                    r.transferredOut > 0
                        ? const Color(0xFFE11D48)
                        : Colors.grey.shade400,
                fontWeight:
                    r.transferredOut > 0
                        ? FontWeight.bold
                        : FontWeight.normal,
              ),
            ),
      ),
      // 13. Stock In (Updated)
      _MoveCol(
        label: 'Stock In (Updated)',
        width: 145,
        sort: ItemHistorySummarySortField.stockInUpdated,
        tooltip: 'Stock increased by manual updates',
        cell:
            (r, i) => Text(
              r.stockInUpdatedText,
              style: TextStyle(
                fontSize: theme.mobileTexts.b4.fontSize,
                color:
                    r.stockInUpdated > 0
                        ? const Color(0xFF10B981)
                        : Colors.grey.shade400,
                fontWeight:
                    r.stockInUpdated > 0
                        ? FontWeight.bold
                        : FontWeight.normal,
              ),
            ),
      ),
      // 14. Stock Out (Updated)
      _MoveCol(
        label: 'Stock Out (Updated)',
        width: 150,
        sort: ItemHistorySummarySortField.stockOutUpdated,
        tooltip: 'Stock decreased by manual updates',
        cell:
            (r, i) => Text(
              r.stockOutUpdatedText,
              style: TextStyle(
                fontSize: theme.mobileTexts.b4.fontSize,
                color:
                    r.stockOutUpdated > 0
                        ? const Color(0xFF64748B)
                        : Colors.grey.shade400,
                fontWeight:
                    r.stockOutUpdated > 0
                        ? FontWeight.bold
                        : FontWeight.normal,
              ),
            ),
      ),
      // 15 & 16. Production & Production Deleted (conditional)
      if (showProd) ...[
        _MoveCol(
          label: 'Production',
          width: 130,
          sort: ItemHistorySummarySortField.produced,
          cell:
              (r, i) => Text(
                r.producedText,
                style: TextStyle(
                  fontSize: theme.mobileTexts.b4.fontSize,
                  color:
                      r.produced > 0
                          ? const Color(0xFF8B5CF6)
                          : Colors.grey.shade400,
                  fontWeight:
                      r.produced > 0
                          ? FontWeight.bold
                          : FontWeight.normal,
                ),
              ),
        ),
        _MoveCol(
          label: 'Production Deleted',
          width: 145,
          sort:
              ItemHistorySummarySortField.productionDeleted,
          cell:
              (r, i) => Text(
                r.productionDeletedText,
                style: TextStyle(
                  fontSize: theme.mobileTexts.b4.fontSize,
                  color:
                      r.productionDeleted > 0
                          ? const Color(0xFFF43F5E)
                          : Colors.grey.shade400,
                  fontWeight:
                      r.productionDeleted > 0
                          ? FontWeight.bold
                          : FontWeight.normal,
                ),
              ),
        ),
      ],
      // 15. Delivered
      _MoveCol(
        label: 'Delivered',
        width: 130,
        sort: ItemHistorySummarySortField.delivered,
        tooltip: 'Delivered from Order',
        cell:
            (r, i) => Text(
              r.deliveredText,
              style: TextStyle(
                fontSize: theme.mobileTexts.b4.fontSize,
                color:
                    r.delivered > 0
                        ? const Color(0xFF9333EA)
                        : Colors.grey.shade400,
                fontWeight:
                    r.delivered > 0
                        ? FontWeight.bold
                        : FontWeight.normal,
              ),
            ),
      ),
    ];
  }

  Widget _headerRow(
    ThemeProvider theme,
    List<_MoveCol> cols,
  ) {
    return Container(
      color: Colors.grey.shade100,
      height: 40,
      child: Row(
        children:
            cols.map((c) {
              final isSelected =
                  c.sort != null && _sortField == c.sort;
              final arrow =
                  isSelected
                      ? (_ascending ? ' ↑' : ' ↓')
                      : '';

              Widget labelWidget = Text(
                c.label + arrow,
                style: TextStyle(
                  fontSize: theme.mobileTexts.b4.fontSize,
                  fontWeight:
                      isSelected
                          ? FontWeight.bold
                          : FontWeight.w600,
                  color:
                      isSelected
                          ? theme.lightModeColor.prColor300
                          : Colors.black87,
                ),
              );

              if (c.tooltip != null) {
                labelWidget = Tooltip(
                  message: c.tooltip!,
                  child: labelWidget,
                );
              }

              if (c.sort != null) {
                labelWidget = InkWell(
                  onTap: () => _onSort(c.sort!),
                  mouseCursor: SystemMouseCursors.click,
                  child: labelWidget,
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
                    child: labelWidget,
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Bottom Pager
  // ---------------------------------------------------------------------------
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
                fontSize: theme.mobileTexts.b3.fontSize,
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
                ? 'No items'
                : 'Showing ${res.firstIndex}-${res.lastIndex} of ${res.totalCount}',
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
