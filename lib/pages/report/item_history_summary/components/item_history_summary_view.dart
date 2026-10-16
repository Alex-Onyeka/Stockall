import 'package:fl_chart/fl_chart.dart';
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
import 'package:stockall/pages/report/item_history_report/item_history_report_page.dart';
import 'package:stockall/pages/report/item_history_summary/class/item_history_summary_logic.dart';
import 'package:stockall/providers/theme_provider.dart';

class ItemHistorySummaryView extends StatefulWidget {
  final bool isDesktop;

  const ItemHistorySummaryView({
    super.key,
    required this.isDesktop,
  });

  @override
  State<ItemHistorySummaryView> createState() =>
      _ItemHistorySummaryViewState();
}

class _ItemHistorySummaryViewState
    extends State<ItemHistorySummaryView> {
  bool _loading = true;
  String? _error;

  List<TempProductClass> _products = [];
  List<ItemHistory> _histories = [];
  List<CategoryClass> _categories = [];
  List<DepartmentClass> _departments = [];

  ItemHistoryPeriod _period = ItemHistoryPeriod.today;
  DateTimeRange? _customRange;

  final ItemHistorySummaryFilters _filters =
      ItemHistorySummaryFilters();
  final TextEditingController _searchCtrl =
      TextEditingController();
  final ScrollController _hScroll = ScrollController();

  ItemHistorySummarySortField _sortField =
      ItemHistorySummarySortField.rowIndex;
  bool _ascending = true;
  int _page = 1;

  ItemHistorySummaryStats _stats =
      ItemHistorySummaryStats.empty;
  List<ItemHistorySummaryRow> _allRows = [];
  List<ItemHistorySummaryRow> _filteredSortedRows = [];
  ItemHistorySummaryPageResult? _pageResult;

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
    super.dispose();
  }

  bool get _departmentsEnabled =>
      shopSingle()?.manageDepartments == true;

  bool get _canViewAllDepartments => authorization(
    authorized: Authorizations().viewAllDepartments,
  );

  bool get _manageProductions =>
      shopSingle()?.manageProductions == true;

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
      if (refreshFromStore && mounted) {
        final refresh = RefreshFunctions(context);
        await refresh.refreshProducts(context);
        if (!mounted) return;
        await returnItemHistoryProvider()
            .getItemHistories();
      } else {
        await returnItemHistoryProvider()
            .getItemHistoriesOffline();
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
                      h.departmentUuid ==
                      _currentDepartmentUuid,
                )
                .toList();
      } else {
        _histories = shopHistories;
      }

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

    _stats = res.stats;
    _allRows = res.rows;
    _applyFilterAndSort();
  }

  void _applyFilterAndSort() {
    _filteredSortedRows =
        ItemHistorySummaryBuilder.filterAndSortRows(
          rows: _allRows,
          filters: _filters,
          sortField: _sortField,
          ascending: _ascending,
          departmentsEnabled: _departmentsEnabled,
        );

    // Re-index displayed rows
    for (int i = 0; i < _filteredSortedRows.length; i++) {
      _filteredSortedRows[i].index = i + 1;
    }

    _pageResult = ItemHistorySummaryBuilder.paginate(
      _filteredSortedRows,
      _page,
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
          _recompute();
        });
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
          _recompute();
        });
      },
    );
  }

  String _formatQty(double v) => formatLargeNumberDouble(v);

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

    return Scaffold(
      backgroundColor: const Color.fromARGB(
        255,
        252,
        253,
        255,
      ),
      appBar: appBar(
        context: context,
        title: 'Item History Summary and Analysis',
        widget: Padding(
          padding: const EdgeInsets.only(right: 10.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton.icon(
                style: TextButton.styleFrom(
                  backgroundColor: theme
                      .lightModeColor
                      .prColor300
                      .withAlpha(20),
                  foregroundColor:
                      theme.lightModeColor.prColor300,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              const ItemHistoryReportPage(),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.history_rounded,
                  size: 15,
                ),
                label: Text(
                  'View History',
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b3.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              IconButton(
                tooltip: 'Refresh Data',
                icon: const Icon(
                  Icons.refresh_rounded,
                  size: 18,
                ),
                mouseCursor: SystemMouseCursors.click,
                onPressed:
                    _loading
                        ? null
                        : () =>
                            _load(refreshFromStore: true),
              ),
            ],
          ),
        ),
      ),
      body:
          _loading
              ? const Center(
                child: CircularProgressIndicator(),
              )
              : _error != null
              ? _buildErrorView(theme)
              : _buildContent(theme),
    );
  }

  Widget _buildErrorView(ThemeProvider theme) {
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
            'Unable to generate item history summary',
            style: TextStyle(
              fontSize: theme.mobileTexts.b1.fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            _error ?? 'An unexpected error occurred',
            style: TextStyle(
              fontSize: theme.mobileTexts.b3.fontSize,
              color: Colors.grey.shade600,
            ),
          ),
          OutlinedButton.icon(
            onPressed: () => _load(refreshFromStore: false),
            icon: const Icon(Icons.refresh_rounded),
            label: Text(
              'Try Again',
              style: TextStyle(
                fontSize: theme.mobileTexts.b3.fontSize,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ThemeProvider theme) {
    final topInflow =
        ItemHistorySummaryBuilder.getTopInflowItems(
          _allRows,
        );
    final topOutflow =
        ItemHistorySummaryBuilder.getTopOutflowItems(
          _allRows,
        );

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: widget.isDesktop ? 16 : 10,
        vertical: 10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          _buildHeaderBar(theme),
          _buildHeadlineKpis(theme),
          _buildCategoryKpiCards(theme),
          // _buildStockBreakdownBar(theme),
          _buildMiddleSection(
            theme: theme,
            topInflow: topInflow,
            topOutflow: topOutflow,
          ),
          _buildItemSummaryTableCard(theme),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Top Header Bar: Title & Date Period Selector
  // ---------------------------------------------------------------------------
  Widget _buildHeaderBar(ThemeProvider theme) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 6,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Stock Movements & Analysis',
              style: TextStyle(
                fontSize: theme.mobileTexts.b1.fontSize,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            // Text(
            //   'Aggregated analysis of inventory changes over the selected period',
            //   style: TextStyle(
            //     fontSize: theme.mobileTexts.b4.fontSize,
            //     color: Colors.grey.shade600,
            //   ),
            // ),
          ],
        ),
        _buildPeriodSelector(theme),
      ],
    );
  }

  Widget _buildPeriodSelector(ThemeProvider theme) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 0,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.calendar_today_rounded,
            size: 14,
            color: theme.lightModeColor.prColor300,
          ),
          const SizedBox(width: 6),
          DropdownButtonHideUnderline(
            child: DropdownButton<ItemHistoryPeriod>(
              value: _period,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 16,
              ),
              style: TextStyle(
                fontSize: theme.mobileTexts.b3.fontSize,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              items:
                  ItemHistoryPeriod.values.map((p) {
                    return DropdownMenuItem(
                      value: p,
                      child: Text(
                        p.label,
                        style: TextStyle(
                          fontSize:
                              theme.mobileTexts.b3.fontSize,
                        ),
                      ),
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
                    _recompute();
                  });
                }
              },
            ),
          ),
          if (_period == ItemHistoryPeriod.custom &&
              _customRange != null) ...[
            const SizedBox(width: 6),
            InkWell(
              onTap: _pickCustomRange,
              mouseCursor: SystemMouseCursors.click,
              borderRadius: BorderRadius.circular(4),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: theme.lightModeColor.prColor50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${formatDateTime(_customRange!.start)} - ${formatDateTime(_customRange!.end)}',
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b4.fontSize,
                        fontWeight: FontWeight.bold,
                        color:
                            theme.lightModeColor.prColor300,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.edit, size: 11),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Top 4 Headline KPI Cards
  // ---------------------------------------------------------------------------
  Widget _buildHeadlineKpis(ThemeProvider theme) {
    final isDesktop = widget.isDesktop;
    final netPositive = _stats.netQuantityChange >= 0;

    final cards = [
      _buildKpiCard(
        theme: theme,
        title: 'Net Change',
        value:
            '${netPositive ? "+" : ""}${_formatQty(_stats.netQuantityChange)}',
        subtitle: 'Additions minus Reductions',
        badgeText:
            netPositive ? '↗ Qtty Change' : '↘ Qtty Change',
        badgeColor:
            netPositive
                ? const Color(0xFF059669)
                : const Color(0xFFDC2626),
        icon:
            netPositive
                ? Icons.trending_up_rounded
                : Icons.trending_down_rounded,
        iconBg:
            netPositive
                ? const Color(0xFFECFDF5)
                : const Color(0xFFFEF2F2),
        iconColor:
            netPositive
                ? const Color(0xFF059669)
                : const Color(0xFFDC2626),
      ),
      _buildKpiCard(
        theme: theme,
        title: 'Total Stock Additions',
        value: '+${_formatQty(_stats.totalStockAdditions)}',
        subtitle: 'Transfers, Purchases, Created, Produced',
        badgeText: 'Total In',
        badgeColor: const Color(0xFF2563EB),
        icon: Icons.add_circle_outline_rounded,
        iconBg: const Color(0xFFEFF6FF),
        iconColor: const Color(0xFF2563EB),
      ),
      _buildKpiCard(
        theme: theme,
        title: 'Total Stock Reductions',
        value:
            '-${_formatQty(_stats.totalStockReductions)}',
        subtitle:
            'Sales, Deliveries, Transferred Out, Deleted',
        badgeText: 'Total Out',
        badgeColor: const Color(0xFFD97706),
        icon: Icons.remove_circle_outline_rounded,
        iconBg: const Color(0xFFFFFBEB),
        iconColor: const Color(0xFFD97706),
      ),
      if (screenWidth(context) > mobileScreen) ...[
        _buildKpiCard(
          theme: theme,
          title: 'Items With Movement',
          value:
              '${_stats.itemsWithMovementCount} of ${_stats.totalDistinctItems}',
          subtitle:
              '${_stats.totalHistoryEvents} Recorded History Events',
          badgeText: 'Active Catalog',
          badgeColor: const Color(0xFF7E22CE),
          icon: Icons.inventory_2_rounded,
          iconBg: const Color(0xFFF3E8FF),
          iconColor: const Color(0xFF7E22CE),
        ),
      ],
    ];

    if (isDesktop) {
      return Row(
        spacing: 10,
        children:
            cards.map((c) => Expanded(child: c)).toList(),
      );
    } else {
      return GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.35,
        children: cards,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Section 6.3 Aggregated Movement Statistics Breakdown Cards
  // ---------------------------------------------------------------------------
  Widget _buildCategoryKpiCards(ThemeProvider theme) {
    final isDesktop = widget.isDesktop;

    final statWidgets = [
      _buildMiniStatPill(
        theme: theme,
        label: 'Transferred In',
        value: _formatQty(_stats.totalTransferredIn),
        icon: Icons.move_to_inbox_rounded,
        color: const Color(0xFF0284C7),
      ),
      _buildMiniStatPill(
        theme: theme,
        label: 'Transferred Out',
        value: _formatQty(_stats.totalTransferredOut),
        icon: Icons.outbox_rounded,
        color: const Color(0xFFE11D48),
      ),
      _buildMiniStatPill(
        theme: theme,
        label: 'Total In (Updated)',
        value: _formatQty(_stats.totalStockAdditions),
        icon: Icons.create_new_folder_rounded,
        color: const Color(0xFF10B981),
      ),
      // _buildMiniStatPill(
      //   theme: theme,
      //   label: 'Total Deleted',
      //   value: _formatQty(_stats.totalDeleted),
      //   icon: Icons.delete_outline_rounded,
      //   color: const Color(0xFF6B7280),
      // ),
      if (_manageProductions) ...[
        _buildMiniStatPill(
          theme: theme,
          label: 'Total Produced',
          value: _formatQty(_stats.totalProduced),
          icon: Icons.precision_manufacturing_rounded,
          color: const Color(0xFF8B5CF6),
        ),
        _buildMiniStatPill(
          theme: theme,
          label: 'Production Deleted',
          value: _formatQty(_stats.totalProductionDeleted),
          icon: Icons.remove_circle_outline_rounded,
          color: const Color(0xFFF43F5E),
        ),
      ],
      _buildMiniStatPill(
        theme: theme,
        label: 'Total Sold',
        value: _formatQty(_stats.totalSold),
        icon: Icons.point_of_sale_rounded,
        color: const Color(0xFFEA580C),
      ),
      _buildMiniStatPill(
        theme: theme,
        label: 'Total Returned',
        value: _formatQty(_stats.totalReturned),
        icon: Icons.assignment_return_rounded,
        color: const Color(0xFF16A34A),
      ),
      _buildMiniStatPill(
        theme: theme,
        label: 'Total Purchased',
        value: _formatQty(_stats.totalPurchased),
        icon: Icons.shopping_bag_rounded,
        color: const Color(0xFF3B82F6),
      ),
      _buildMiniStatPill(
        theme: theme,
        label: 'Delivered (Order)',
        value: _formatQty(_stats.totalDelivered),
        icon: Icons.local_shipping_rounded,
        color: const Color(0xFF9333EA),
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Movement Categories',
                style: TextStyle(
                  fontSize: theme.mobileTexts.b2.fontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              if (_manageProductions &&
                  screenWidth(context) > mobileScreen)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(
                      0xFF8B5CF6,
                    ).withAlpha(20),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Production Enabled',
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.b4.fontSize,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF8B5CF6),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          isDesktop
              ? Wrap(
                spacing: 10,
                runSpacing: 10,
                children:
                    statWidgets
                        .map(
                          (w) => SizedBox(
                            width: 175,
                            child: w,
                          ),
                        )
                        .toList(),
              )
              : GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics:
                    const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 2.2,
                children: statWidgets,
              ),
        ],
      ),
    );
  }

  Widget _buildMiniStatPill({
    required ThemeProvider theme,
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          if (screenWidth(context) > mobileScreen) ...[
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b5.fontSize,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b3.fontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard({
    required ThemeProvider theme,
    required String title,
    required String value,
    required String subtitle,
    required String badgeText,
    required Color badgeColor,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              if (screenWidth(context) > mobileScreen) ...[
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 17,
                  ),
                ),
              ],
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: badgeColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b4.fontSize,
                    fontWeight: FontWeight.bold,
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (screenWidth(context) > mobileScreen) ...[
                Text(
                  title,
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b4.fontSize,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
              ],
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b1.fontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              if (screenWidth(context) > mobileScreen) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b4.fontSize,
                    color: Colors.grey.shade500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Stock Availability Quick-Breakdown Pill Bar
  // ---------------------------------------------------------------------------
  // Widget _buildStockBreakdownBar(ThemeProvider theme) {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(
  //       horizontal: 12,
  //       vertical: 8,
  //     ),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(8),
  //       border: Border.all(color: Colors.grey.shade100),
  //     ),
  //     child: Wrap(
  //       spacing: 12,
  //       runSpacing: 6,
  //       crossAxisAlignment: WrapCrossAlignment.center,
  //       children: [
  //         Row(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             const Icon(
  //               Icons.swap_horiz_rounded,
  //               color: Color(0xFF0284C7),
  //               size: 15,
  //             ),
  //             const SizedBox(width: 4),
  //             Text(
  //               'Transfers: In +${_formatQty(_stats.totalTransferredIn)}  •  Out -${_formatQty(_stats.totalTransferredOut)}',
  //               style: TextStyle(
  //                 fontSize: theme.mobileTexts.b4.fontSize,
  //                 fontWeight: FontWeight.w600,
  //                 color: Colors.grey.shade700,
  //               ),
  //             ),
  //           ],
  //         ),
  //         Container(
  //           width: 1,
  //           height: 14,
  //           color: Colors.grey.shade300,
  //         ),
  //         Row(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             const Icon(
  //               Icons.shopping_cart_outlined,
  //               color: Color(0xFF16A34A),
  //               size: 15,
  //             ),
  //             const SizedBox(width: 4),
  //             Text(
  //               'Purchases +${_formatQty(_stats.totalPurchased)}  •  Sales -${_formatQty(_stats.totalSold)}  •  Returns +${_formatQty(_stats.totalReturned)}',
  //               style: TextStyle(
  //                 fontSize: theme.mobileTexts.b4.fontSize,
  //                 fontWeight: FontWeight.w600,
  //                 color: Colors.grey.shade700,
  //               ),
  //             ),
  //           ],
  //         ),
  //         Container(
  //           width: 1,
  //           height: 14,
  //           color: Colors.grey.shade300,
  //         ),
  //         Row(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             const Icon(
  //               Icons.layers_outlined,
  //               color: Colors.blueGrey,
  //               size: 15,
  //             ),
  //             const SizedBox(width: 4),
  //             Text(
  //               'Created +${_formatQty(_stats.totalCreated)}  •  Deleted -${_formatQty(_stats.totalDeleted)}',
  //               style: TextStyle(
  //                 fontSize: theme.mobileTexts.b4.fontSize,
  //                 fontWeight: FontWeight.w600,
  //                 color: Colors.blueGrey.shade700,
  //               ),
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // ---------------------------------------------------------------------------
  // Middle Section: Visual Donut Chart + Top Stock Movers Leaderboards
  // ---------------------------------------------------------------------------
  Widget _buildMiddleSection({
    required ThemeProvider theme,
    required List<ItemHistorySummaryRow> topInflow,
    required List<ItemHistorySummaryRow> topOutflow,
  }) {
    final isDesktop = widget.isDesktop;

    final donutCard = _buildMovementDonutCard(theme);
    final leadersCard = _buildTopMoversCard(
      theme: theme,
      topInflow: topInflow,
      topOutflow: topOutflow,
    );

    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          Expanded(flex: 40, child: donutCard),
          Expanded(flex: 60, child: leadersCard),
        ],
      );
    } else {
      return Column(
        spacing: 10,
        children: [donutCard, leadersCard],
      );
    }
  }

  Widget _buildMovementDonutCard(ThemeProvider theme) {
    final totalIn = _stats.totalStockAdditions;
    final totalOut = _stats.totalStockReductions;
    final totalMovement = totalIn + totalOut;

    final inPct =
        totalMovement > 0
            ? (totalIn / totalMovement) * 100
            : 0.0;
    final outPct =
        totalMovement > 0
            ? (totalOut / totalMovement) * 100
            : 0.0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Stock Movement Flow',
            style: TextStyle(
              fontSize: theme.mobileTexts.b1.fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            'Additions (Inflow) vs Reductions (Outflow)',
            style: TextStyle(
              fontSize: theme.mobileTexts.b4.fontSize,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 160,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 3,
                    centerSpaceRadius: 46,
                    startDegreeOffset: -90,
                    sections:
                        totalMovement == 0
                            ? [
                              PieChartSectionData(
                                color: Colors.grey.shade200,
                                value: 1,
                                radius: 18,
                                showTitle: false,
                              ),
                            ]
                            : [
                              if (totalIn > 0)
                                PieChartSectionData(
                                  color: const Color(
                                    0xFF059669,
                                  ),
                                  value: totalIn,
                                  radius: 20,
                                  showTitle: false,
                                ),
                              if (totalOut > 0)
                                PieChartSectionData(
                                  color: const Color(
                                    0xFFDC2626,
                                  ),
                                  value: totalOut,
                                  radius: 20,
                                  showTitle: false,
                                ),
                            ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatQty(
                        _stats.netQuantityChange.abs(),
                      ),
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b1.fontSize,
                        fontWeight: FontWeight.bold,
                        color:
                            _stats.netQuantityChange >= 0
                                ? const Color(0xFF059669)
                                : const Color(0xFFDC2626),
                      ),
                    ),
                    Text(
                      _stats.netQuantityChange >= 0
                          ? 'Net Inflow'
                          : 'Net Outflow',
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b4.fontSize,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Column(
            spacing: 6,
            children: [
              _buildLegendRow(
                theme: theme,
                color: const Color(0xFF059669),
                label: 'Stock Additions',
                percentage: inPct,
                value: '+${_formatQty(totalIn)}',
              ),
              _buildLegendRow(
                theme: theme,
                color: const Color(0xFFDC2626),
                label: 'Stock Reductions',
                percentage: outPct,
                value: '-${_formatQty(totalOut)}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendRow({
    required ThemeProvider theme,
    required Color color,
    required String label,
    required double percentage,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: theme.mobileTexts.b3.fontSize,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
        Text(
          '${percentage.toStringAsFixed(0)}%  •  $value',
          style: TextStyle(
            fontSize: theme.mobileTexts.b4.fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildTopMoversCard({
    required ThemeProvider theme,
    required List<ItemHistorySummaryRow> topInflow,
    required List<ItemHistorySummaryRow> topOutflow,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Movement Leaders',
            style: TextStyle(
              fontSize: theme.mobileTexts.b1.fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            'Highest stock additions and stock reductions in period',
            style: TextStyle(
              fontSize: theme.mobileTexts.b4.fontSize,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final stack = constraints.maxWidth < 550;
              final additionsBox = _buildMoversList(
                theme: theme,
                title: 'Top Inflow Items',
                badgeText: 'Highest Additions',
                badgeColor: const Color(0xFF16A34A),
                icon: Icons.trending_up_rounded,
                items: topInflow,
                isInflow: true,
              );
              final reductionsBox = _buildMoversList(
                theme: theme,
                title: 'Top Outflow Items',
                badgeText: 'Highest Reductions',
                badgeColor: const Color(0xFFD97706),
                icon: Icons.trending_down_rounded,
                items: topOutflow,
                isInflow: false,
              );

              if (stack) {
                return Column(
                  spacing: 10,
                  children: [additionsBox, reductionsBox],
                );
              } else {
                return Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  spacing: 10,
                  children: [
                    Expanded(child: additionsBox),
                    Expanded(child: reductionsBox),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMoversList({
    required ThemeProvider theme,
    required String title,
    required String badgeText,
    required Color badgeColor,
    required IconData icon,
    required List<ItemHistorySummaryRow> items,
    required bool isInflow,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: badgeColor, size: 16),
                  const SizedBox(width: 5),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.b3.fontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              if (screenWidth(context) > mobileScreen) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor.withAlpha(20),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.b4.fontSize,
                      fontWeight: FontWeight.bold,
                      color: badgeColor,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 12,
              ),
              child: Center(
                child: Text(
                  'No movement recorded',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: theme.mobileTexts.b4.fontSize,
                  ),
                ),
              ),
            )
          else
            Column(
              children: List.generate(items.length, (idx) {
                final it = items[idx];
                final rank = idx + 1;
                return Material(
                  color: Colors.transparent,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4.0,
                    ),
                    child: InkWell(
                      onTap:
                          () => _openItemDetails(it.uuid),
                      mouseCursor: SystemMouseCursors.click,
                      child: Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: badgeColor.withAlpha(
                                25,
                              ),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '$rank',
                              style: TextStyle(
                                fontSize:
                                    theme
                                        .mobileTexts
                                        .b4
                                        .fontSize,
                                fontWeight: FontWeight.bold,
                                color: badgeColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  it.name,
                                  style: TextStyle(
                                    fontSize:
                                        theme
                                            .mobileTexts
                                            .b4
                                            .fontSize,
                                    fontWeight:
                                        FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow:
                                      TextOverflow.ellipsis,
                                ),
                                Text(
                                  'Unit: ${it.primaryUnit}',
                                  style: TextStyle(
                                    fontSize:
                                        theme
                                            .mobileTexts
                                            .b5
                                            .fontSize,
                                    color:
                                        Colors
                                            .grey
                                            .shade500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isInflow
                                ? '+${_formatQty(it.totalAdditions)}'
                                : '-${_formatQty(it.totalReductions)}',
                            style: TextStyle(
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b4
                                      .fontSize,
                              fontWeight: FontWeight.bold,
                              color:
                                  isInflow
                                      ? const Color(
                                        0xFF16A34A,
                                      )
                                      : const Color(
                                        0xFFDC2626,
                                      ),
                            ),
                          ),
                          Icon(
                            size: 18,
                            color: Colors.grey.shade400,
                            Icons
                                .keyboard_arrow_right_outlined,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Section 6.4 Item-Level History Summary Table Card
  // ---------------------------------------------------------------------------
  Widget _buildItemSummaryTableCard(ThemeProvider theme) {
    final res = _pageResult;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Item-Level Stock Movements',
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b1.fontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Reconciliation: Closing Stock = Opening Stock + Net Quantity Change',
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b4.fontSize,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                _buildTableFilters(theme),
              ],
            ),
          ),
          const Divider(height: 1),
          if (res == null || res.rows.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 40,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.search_off_rounded,
                      size: 36,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No matching inventory items found',
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b3.fontSize,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            Scrollbar(
              controller: _hScroll,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _hScroll,
                scrollDirection: Axis.horizontal,
                child: _buildDataTable(theme, res.rows),
              ),
            ),
            const Divider(height: 1),
            _buildPaginationBar(theme, res),
          ],
        ],
      ),
    );
  }

  Widget _buildTableFilters(ThemeProvider theme) {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // Search
        SizedBox(
          width: 170,
          height: 32,
          child: TextField(
            controller: _searchCtrl,
            onChanged: (val) {
              setState(() {
                _filters.search = val;
                _page = 1;
                _applyFilterAndSort();
              });
            },
            style: TextStyle(
              fontSize: theme.mobileTexts.b4.fontSize,
            ),
            decoration: InputDecoration(
              hintText: 'Search items...',
              prefixIcon: const Icon(
                Icons.search,
                size: 14,
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 0,
                horizontal: 8,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(
                  color: Colors.grey.shade300,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(
                  color: Colors.grey.shade200,
                ),
              ),
            ),
          ),
        ),

        // Movement Filter
        Container(
          height: 32,
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
          ),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<
              ItemHistoryMovementFilter
            >(
              value: _filters.movementFilter,
              icon: const Icon(
                Icons.keyboard_arrow_down,
                size: 14,
              ),
              style: TextStyle(
                fontSize: theme.mobileTexts.b4.fontSize,
                color: Colors.black87,
              ),
              items:
                  ItemHistoryMovementFilter.values.map((f) {
                    return DropdownMenuItem(
                      value: f,
                      child: Text(
                        f.label,
                        style: TextStyle(
                          fontSize:
                              theme.mobileTexts.b4.fontSize,
                        ),
                      ),
                    );
                  }).toList(),
              onChanged: (val) {
                if (val == null) return;
                setState(() {
                  _filters.movementFilter = val;
                  _page = 1;
                  _applyFilterAndSort();
                });
              },
            ),
          ),
        ),

        // Category Filter
        Container(
          height: 32,
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
          ),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String?>(
              value: _filters.categoryKey,
              hint: Text(
                'Category',
                style: TextStyle(
                  fontSize: theme.mobileTexts.b4.fontSize,
                ),
              ),
              icon: const Icon(
                Icons.keyboard_arrow_down,
                size: 14,
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
                      fontSize:
                          theme.mobileTexts.b4.fontSize,
                    ),
                  ),
                ),
                ..._categories.map((c) {
                  return DropdownMenuItem<String?>(
                    value: c.uuid,
                    child: Text(
                      c.name,
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b4.fontSize,
                      ),
                    ),
                  );
                }),
                DropdownMenuItem<String?>(
                  value: itemHistorySummaryNoneKey,
                  child: Text(
                    'Unassigned',
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.b4.fontSize,
                    ),
                  ),
                ),
              ],
              onChanged: (val) {
                setState(() {
                  _filters.categoryKey = val;
                  _page = 1;
                  _applyFilterAndSort();
                });
              },
            ),
          ),
        ),

        // Department Filter
        if (_departmentsEnabled)
          Container(
            height: 32,
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
            ),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: Colors.grey.shade200,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String?>(
                value: _filters.departmentKey,
                hint: Text(
                  'Department',
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b4.fontSize,
                  ),
                ),
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  size: 14,
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
                        fontSize:
                            theme.mobileTexts.b4.fontSize,
                      ),
                    ),
                  ),
                  ..._departments.map((d) {
                    return DropdownMenuItem<String?>(
                      value: d.uuid,
                      child: Text(
                        d.name,
                        style: TextStyle(
                          fontSize:
                              theme.mobileTexts.b4.fontSize,
                        ),
                      ),
                    );
                  }),
                  DropdownMenuItem<String?>(
                    value: itemHistorySummaryNoneKey,
                    child: Text(
                      'Unassigned',
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b4.fontSize,
                      ),
                    ),
                  ),
                ],
                onChanged: (val) {
                  setState(() {
                    _filters.departmentKey = val;
                    _page = 1;
                    _applyFilterAndSort();
                  });
                },
              ),
            ),
          ),

        if (_filters.hasAnything)
          IconButton(
            tooltip: 'Clear Filters',
            mouseCursor: SystemMouseCursors.click,
            icon: const Icon(
              Icons.clear_all_rounded,
              size: 18,
            ),
            onPressed: () {
              setState(() {
                _searchCtrl.clear();
                _filters.clearAll();
                _page = 1;
                _applyFilterAndSort();
              });
            },
          ),
      ],
    );
  }

  Widget _buildDataTable(
    ThemeProvider theme,
    List<ItemHistorySummaryRow> rows,
  ) {
    final showProd = _manageProductions;

    return DataTable(
      headingRowHeight: 38,
      dataRowMinHeight: 36,
      dataRowMaxHeight: 44,
      horizontalMargin: 12,
      columnSpacing: 16,
      headingRowColor: WidgetStateProperty.all(
        Colors.grey.shade100,
      ),
      columns: [
        _dataCol(
          'No.',
          ItemHistorySummarySortField.rowIndex,
          theme,
          alignLeft: false,
        ),
        _dataCol(
          'Item Name',
          ItemHistorySummarySortField.itemName,
          theme,
          alignLeft: true,
        ),
        _dataCol(
          'Opening Stock',
          ItemHistorySummarySortField.openingStock,
          theme,
          tooltip:
              'Stock balance immediately before the period',
        ),
        _dataCol(
          'Closing Stock',
          ItemHistorySummarySortField.closingStock,
          theme,
          tooltip:
              'Stock balance immediately after the period',
        ),
        _dataCol(
          'Current Quantity',
          ItemHistorySummarySortField.currentQuantity,
          theme,
          tooltip: 'Live current inventory balance',
        ),
        _dataCol(
          'Transferred In',
          ItemHistorySummarySortField.transferredIn,
          theme,
        ),
        _dataCol(
          'Transferred Out',
          ItemHistorySummarySortField.transferredOut,
          theme,
        ),
        if (showProd) ...[
          _dataCol(
            'Produced',
            ItemHistorySummarySortField.produced,
            theme,
          ),
          _dataCol(
            'Production Del.',
            ItemHistorySummarySortField.productionDeleted,
            theme,
          ),
        ],
        _dataCol(
          'Sold',
          ItemHistorySummarySortField.sold,
          theme,
        ),
        _dataCol(
          'Returned',
          ItemHistorySummarySortField.returned,
          theme,
        ),
        _dataCol(
          'Purchased',
          ItemHistorySummarySortField.purchased,
          theme,
        ),
        _dataCol(
          'Delivered',
          ItemHistorySummarySortField.delivered,
          theme,
          tooltip: 'Delivered from Order',
        ),
        _dataCol(
          'Created',
          ItemHistorySummarySortField.created,
          theme,
        ),
        _dataCol(
          'Deleted',
          ItemHistorySummarySortField.deleted,
          theme,
        ),
        _dataCol(
          'Net Change',
          ItemHistorySummarySortField.netQuantityChange,
          theme,
          tooltip: 'Net Stock Additions - Reductions',
        ),
      ],
      rows:
          rows.map((r) {
            final netPositive = r.netQuantityChange > 0;
            final netNegative = r.netQuantityChange < 0;

            return DataRow(
              cells: [
                DataCell(
                  Center(
                    child: Text(
                      '${r.index}',
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b4.fontSize,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  InkWell(
                    onTap: () => _openItemDetails(r.uuid),
                    mouseCursor: SystemMouseCursors.click,
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Text(
                          r.name,
                          style: TextStyle(
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b3
                                    .fontSize,
                            fontWeight: FontWeight.bold,
                            color:
                                theme
                                    .lightModeColor
                                    .prColor300,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          r.primaryUnit,
                          style: TextStyle(
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b5
                                    .fontSize,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                DataCell(
                  Center(
                    child: Text(
                      r.openingStock != null
                          ? _formatQty(r.openingStock!)
                          : '—',
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b4.fontSize,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Center(
                    child: Text(
                      r.closingStock != null
                          ? _formatQty(r.closingStock!)
                          : '—',
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b4.fontSize,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2563EB),
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Center(
                    child: Text(
                      _formatQty(r.currentQuantity),
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b4.fontSize,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Center(
                    child: Text(
                      r.transferredIn > 0
                          ? '+${_formatQty(r.transferredIn)}'
                          : '—',
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b4.fontSize,
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
                ),
                DataCell(
                  Center(
                    child: Text(
                      r.transferredOut > 0
                          ? '-${_formatQty(r.transferredOut)}'
                          : '—',
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b4.fontSize,
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
                ),
                if (showProd) ...[
                  DataCell(
                    Center(
                      child: Text(
                        r.produced > 0
                            ? '+${_formatQty(r.produced)}'
                            : '—',
                        style: TextStyle(
                          fontSize:
                              theme.mobileTexts.b4.fontSize,
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
                  ),
                  DataCell(
                    Center(
                      child: Text(
                        r.productionDeleted > 0
                            ? '-${_formatQty(r.productionDeleted)}'
                            : '—',
                        style: TextStyle(
                          fontSize:
                              theme.mobileTexts.b4.fontSize,
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
                  ),
                ],
                DataCell(
                  Center(
                    child: Text(
                      r.sold > 0
                          ? '-${_formatQty(r.sold)}'
                          : '—',
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b4.fontSize,
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
                ),
                DataCell(
                  Center(
                    child: Text(
                      r.returned > 0
                          ? '+${_formatQty(r.returned)}'
                          : '—',
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b4.fontSize,
                        color:
                            r.returned > 0
                                ? const Color(0xFF16A34A)
                                : Colors.grey.shade400,
                        fontWeight:
                            r.returned > 0
                                ? FontWeight.bold
                                : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Center(
                    child: Text(
                      r.purchased > 0
                          ? '+${_formatQty(r.purchased)}'
                          : '—',
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b4.fontSize,
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
                ),
                DataCell(
                  Center(
                    child: Text(
                      r.delivered > 0
                          ? '-${_formatQty(r.delivered)}'
                          : '—',
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b4.fontSize,
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
                ),
                DataCell(
                  Center(
                    child: Text(
                      r.created > 0
                          ? '+${_formatQty(r.created)}'
                          : '—',
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b4.fontSize,
                        color:
                            r.created > 0
                                ? const Color(0xFF10B981)
                                : Colors.grey.shade400,
                        fontWeight:
                            r.created > 0
                                ? FontWeight.bold
                                : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Center(
                    child: Text(
                      r.deleted > 0
                          ? '-${_formatQty(r.deleted)}'
                          : '—',
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b4.fontSize,
                        color:
                            r.deleted > 0
                                ? const Color(0xFF6B7280)
                                : Colors.grey.shade400,
                        fontWeight:
                            r.deleted > 0
                                ? FontWeight.bold
                                : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color:
                            netPositive
                                ? const Color(
                                  0xFF16A34A,
                                ).withAlpha(18)
                                : netNegative
                                ? const Color(
                                  0xFFDC2626,
                                ).withAlpha(18)
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(
                          4,
                        ),
                      ),
                      child: Text(
                        r.netQuantityChange == 0
                            ? '0'
                            : '${netPositive ? "+" : ""}${_formatQty(r.netQuantityChange)}',
                        style: TextStyle(
                          fontSize:
                              theme.mobileTexts.b4.fontSize,
                          fontWeight: FontWeight.bold,
                          color:
                              netPositive
                                  ? const Color(0xFF16A34A)
                                  : netNegative
                                  ? const Color(0xFFDC2626)
                                  : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
    );
  }

  DataColumn _dataCol(
    String label,
    ItemHistorySummarySortField field,
    ThemeProvider theme, {
    bool alignLeft = false,
    String? tooltip,
  }) {
    final isSelected = _sortField == field;
    final arrow =
        isSelected ? (_ascending ? ' ↑' : ' ↓') : '';

    return DataColumn(
      tooltip: tooltip,
      label: InkWell(
        onTap: () => _onSort(field),
        mouseCursor: SystemMouseCursors.click,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment:
              alignLeft
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.center,
          children: [
            Text(
              label + arrow,
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaginationBar(
    ThemeProvider theme,
    ItemHistorySummaryPageResult res,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${res.firstIndex} to ${res.lastIndex} of ${res.totalCount} items',
            style: TextStyle(
              fontSize: theme.mobileTexts.b4.fontSize,
              color: Colors.grey.shade600,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.chevron_left_rounded,
                ),
                iconSize: 20,
                mouseCursor: SystemMouseCursors.click,
                onPressed:
                    res.page > 1
                        ? () => setState(() {
                          _page--;
                          _applyFilterAndSort();
                        })
                        : null,
              ),
              Text(
                'Page ${res.page} of ${res.totalPages}',
                style: TextStyle(
                  fontSize: theme.mobileTexts.b4.fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.chevron_right_rounded,
                ),
                iconSize: 20,
                mouseCursor: SystemMouseCursors.click,
                onPressed:
                    res.page < res.totalPages
                        ? () => setState(() {
                          _page++;
                          _applyFilterAndSort();
                        })
                        : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
