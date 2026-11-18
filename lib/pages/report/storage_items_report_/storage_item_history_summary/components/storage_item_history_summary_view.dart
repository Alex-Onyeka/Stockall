import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/classes/temp_storage_item_history/storage_item_history.dart';
import 'package:stockall/classes/temp_storage_product/temp_storage_products.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/date_picker_function.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/report/components/export/report_export_button.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/report_pager.dart';
import 'package:stockall/pages/report/components/report_searchable_dropdown.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/storage_items_report_/storage_item_history_report/class/storage_item_history_report_logic.dart';
import 'package:stockall/pages/report/storage_items_report_/storage_item_history_report/storage_item_history_report_page.dart';
import 'package:stockall/pages/report/storage_items_report_/storage_item_history_summary/class/storage_item_history_summary_export_spec.dart';
import 'package:stockall/pages/report/storage_items_report_/storage_item_history_summary/class/storage_item_history_summary_logic.dart';
import 'package:stockall/providers/theme_provider.dart';

/// Shared body of the "Storage Item History Summary" page (desktop + mobile).
class StorageItemHistorySummaryView extends StatefulWidget {
  final bool isDesktop;

  const StorageItemHistorySummaryView({
    super.key,
    required this.isDesktop,
  });

  @override
  State<StorageItemHistorySummaryView> createState() =>
      _StorageItemHistorySummaryViewState();
}

class _StorageItemHistorySummaryViewState
    extends State<StorageItemHistorySummaryView> {
  bool _loading = true;
  String? _error;

  List<TempStorageProducts> _storageProducts = [];
  List<TempProductClass> _salesProducts = [];
  List<StorageItemHistory> _histories = [];

  StorageHistoryPeriod _period = StorageHistoryPeriod.today;
  DateTimeRange? _customRange;

  final StorageHistorySummaryFilters _filters =
      StorageHistorySummaryFilters();
  final TextEditingController _searchCtrl =
      TextEditingController();
  final ScrollController _hScroll = ScrollController();

  StorageHistorySummarySortField _sortField =
      StorageHistorySummarySortField.rowIndex;
  bool _ascending = true;
  int _page = 1;

  StorageHistorySummaryStats _stats =
      StorageHistorySummaryStats.empty;
  StorageHistoryBreakdowns _breakdowns =
      StorageHistoryBreakdowns.empty;
  List<StorageHistorySummaryRow> _allRows = [];
  List<StorageHistorySummaryRow> _filteredSortedRows = [];
  StorageHistorySummaryPageResult? _pageResult;

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
      final tablePeriod = _tablePeriod();
      final fetchAll = tablePeriod.isAllTime;
      final startDate = tablePeriod.start;
      final endDate = tablePeriod.end ?? tablePeriod.start;
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

      _storageProducts =
          returnStorageProductProvider()
              .storageProductListMain;
      _salesProducts = returnData().productListMain;
      _histories = scopeStorageItemHistories(
        all:
            returnStorageItemHistoryProvider()
                .storageItemHistories,
        shopId: sId,
        departmentsEnabled: _departmentsEnabled,
        canViewAllDepartments: _canViewAllDepartments,
        currentDepartmentUuid: _currentDepartmentUuid,
      );

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
        StorageHistorySummaryBuilder.buildSummaryAndRows(
          storageProducts: _storageProducts,
          salesProducts: _salesProducts,
          histories: _histories,
          period: _period,
          businessNow: now,
          customRange: _customRange,
        );
    _stats = res.stats;
    _allRows = res.rows;
    _breakdowns =
        StorageHistorySummaryBuilder.buildBreakdowns(
          storageProducts: _storageProducts,
          histories: _histories,
          period: _period,
          businessNow: now,
          customRange: _customRange,
        );
    _page = 1;
    _applyFilterAndSort();
  }

  void _applyFilterAndSort() {
    _filteredSortedRows =
        StorageHistorySummaryBuilder.filterAndSortRows(
          rows: _allRows,
          filters: _filters,
          sortField: _sortField,
          ascending: _ascending,
        );
    _pageResult = StorageHistorySummaryBuilder.paginate(
      _filteredSortedRows,
      _page,
    );
    _page = _pageResult!.page;
  }

  ReportExportSpec _exportSpec() {
    return storageHistorySummaryExportSpec(
      stats: _stats,
      breakdowns: _breakdowns,
      allRows: _allRows,
      rows: _filteredSortedRows,
      filters: _filters,
      sortField: _sortField,
      ascending: _ascending,
      period: _period,
      customRange: _customRange,
      resolvedRange:
          StorageHistorySummaryBuilder.resolveDateRange(
            period: _period,
            businessNow: resolveBusinessDate(
              DateTime.now(),
            ),
            customRange: _customRange,
          ),
      departmentsEnabled: _departmentsEnabled,
      currency: currencySymbol(context: context),
      sizeLabels: storageSizeLabels(_storageProducts),
    );
  }

  void _onSort(StorageHistorySummarySortField field) {
    setState(() {
      if (_sortField == field) {
        _ascending = !_ascending;
      } else {
        _sortField = field;
        _ascending = true;
      }
      _page = 1;
      _applyFilterAndSort();
    });
  }

  void _setPeriod(
    StorageHistoryPeriod p, {
    DateTimeRange? range,
  }) {
    setState(() {
      _period = p;
      _customRange = range;
      _recompute();
    });
    if (p != StorageHistoryPeriod.allTime) {
      _load(refreshFromStore: false);
    }
  }

  void _pickCustomRange() {
    final theme = returnTheme(context, listen: false);
    mainDatePicker(
      context: context,
      theme: theme,
      singleDate: (date) {
        if (date == null) return;
        final d = DateTime(date.year, date.month, date.day);
        _setPeriod(
          StorageHistoryPeriod.custom,
          range: DateTimeRange(start: d, end: d),
        );
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
        _setPeriod(
          StorageHistoryPeriod.custom,
          range: DateTimeRange(start: s, end: e),
        );
      },
    );
  }

  /// The summary period as the history table's period.
  ReceiptsReportPeriod _tablePeriod() {
    if (_period == StorageHistoryPeriod.allTime) {
      return const ReceiptsReportPeriod.allTime();
    }
    final range =
        StorageHistorySummaryBuilder.resolveDateRange(
          period: _period,
          businessNow: resolveBusinessDate(DateTime.now()),
          customRange: _customRange,
        );
    return ReceiptsReportPeriod.range(
      range.start,
      range.end,
    );
  }

  /// One-way click-through: the history table for one storage item.
  void _openItemHistory(String uuid) {
    if (uuid.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => StorageItemHistoryReportPage(
              initialStorageItemUuid: uuid,
              initialPeriod: _tablePeriod(),
            ),
      ),
    ).then((_) {
      if (mounted) _load(refreshFromStore: false);
    });
  }

  String _byUnit(Map<String, double> m) =>
      formatQuantitiesByUnit(m);

  String _signedByUnit(Map<String, double> m) =>
      storageSignedQuantitiesByUnit(m);

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
        title: 'Storage Item History Summary',
        widget: Padding(
          padding: const EdgeInsets.only(right: 10.0),
          child: IconButton(
            tooltip: 'Refresh Data',
            icon: const Icon(
              Icons.refresh_rounded,
              size: 18,
            ),
            mouseCursor: SystemMouseCursors.click,
            onPressed:
                _loading
                    ? null
                    : () => _load(refreshFromStore: true),
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
            'Unable to generate storage history summary',
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
        StorageHistorySummaryBuilder.getTopInflowItems(
          _allRows,
        );
    final topOutflow =
        StorageHistorySummaryBuilder.getTopOutflowItems(
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
          _buildNotes(theme),
          _buildHeadlineKpis(theme),
          _buildCategoryKpiCards(theme),
          _buildMiddleSection(
            theme: theme,
            topInflow: topInflow,
            topOutflow: topOutflow,
          ),
          _buildBreakdownsSection(theme),
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
        Text(
          'Storage Movements & Analysis',
          style: TextStyle(
            fontSize: theme.mobileTexts.b1.fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _buildPeriodSelector(theme),
            ReportExportButton(buildSpec: _exportSpec),
          ],
        ),
      ],
    );
  }

  Widget _buildPeriodSelector(ThemeProvider theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
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
            child: DropdownButton<StorageHistoryPeriod>(
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
                  StorageHistoryPeriod.values.map((p) {
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
                if (val == StorageHistoryPeriod.custom) {
                  _pickCustomRange();
                } else {
                  _setPeriod(val);
                }
              },
            ),
          ),
          if (_period == StorageHistoryPeriod.custom &&
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

  Widget _buildNotes(ThemeProvider theme) {
    final notes = storageHistorySummaryNotes(
      period: _period,
      stats: _stats,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 2,
      children: [
        for (final n in notes)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Icon(
                  Icons.info_outline_rounded,
                  size: 13,
                  color: Colors.grey.shade600,
                ),
              ),
              Expanded(
                child: Text(
                  n,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Headline KPI Cards
  // ---------------------------------------------------------------------------
  Widget _buildHeadlineKpis(ThemeProvider theme) {
    final net = _stats.netChangeByUnit;
    final netNegative =
        net.isNotEmpty && net.values.every((v) => v < 0);

    final cards = [
      _buildKpiCard(
        theme: theme,
        title: 'Net Change',
        value: _signedByUnit(net),
        subtitle: 'Additions minus Reductions',
        badgeText:
            netNegative ? '↘ Qtty Change' : '↗ Qtty Change',
        badgeColor:
            netNegative
                ? const Color(0xFFDC2626)
                : const Color(0xFF059669),
        icon:
            netNegative
                ? Icons.trending_down_rounded
                : Icons.trending_up_rounded,
        iconBg:
            netNegative
                ? const Color(0xFFFEF2F2)
                : const Color(0xFFECFDF5),
        iconColor:
            netNegative
                ? const Color(0xFFDC2626)
                : const Color(0xFF059669),
      ),
      _buildKpiCard(
        theme: theme,
        title: 'Total Stock Additions',
        value: _byUnit(_stats.additionsByUnit),
        subtitle:
            'Returns, Stock In, Purchases, Adjusted Up',
        badgeText: 'Total In',
        badgeColor: const Color(0xFF2563EB),
        icon: Icons.add_circle_outline_rounded,
        iconBg: const Color(0xFFEFF6FF),
        iconColor: const Color(0xFF2563EB),
      ),
      _buildKpiCard(
        theme: theme,
        title: 'Total Stock Reductions',
        value: _byUnit(_stats.reductionsByUnit),
        subtitle:
            'Transfers Out, Purchases Deleted, Adjusted Down',
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
          badgeText: 'Storage Items',
          badgeColor: const Color(0xFF7E22CE),
          icon: Icons.inventory_2_rounded,
          iconBg: const Color(0xFFF3E8FF),
          iconColor: const Color(0xFF7E22CE),
        ),
      ],
    ];

    if (widget.isDesktop) {
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
  // Movement Category Cards
  // ---------------------------------------------------------------------------
  Widget _buildCategoryKpiCards(ThemeProvider theme) {
    String qty(StorageMovementKind k) =>
        _byUnit(_stats.quantityByUnit(k));

    final statWidgets = [
      _buildMiniStatPill(
        theme: theme,
        label: 'Transferred Out To Sales',
        value: qty(StorageMovementKind.transferredOut),
        icon: Icons.outbox_rounded,
        color: const Color(0xFFE11D48),
      ),
      _buildMiniStatPill(
        theme: theme,
        label: 'Returned From Sales',
        value: qty(StorageMovementKind.returned),
        icon: Icons.assignment_return_rounded,
        color: const Color(0xFF16A34A),
      ),
      _buildMiniStatPill(
        theme: theme,
        label: 'Stocked In',
        value: qty(StorageMovementKind.stockIn),
        icon: Icons.move_to_inbox_rounded,
        color: const Color(0xFF0284C7),
      ),
      _buildMiniStatPill(
        theme: theme,
        label: 'Purchased',
        value: qty(StorageMovementKind.purchase),
        icon: Icons.shopping_bag_rounded,
        color: const Color(0xFF3B82F6),
      ),
      _buildMiniStatPill(
        theme: theme,
        label: 'Purchase Deleted',
        value: qty(StorageMovementKind.purchaseDeleted),
        icon: Icons.remove_shopping_cart_rounded,
        color: const Color(0xFFF43F5E),
      ),
      _buildMiniStatPill(
        theme: theme,
        label: 'Restocked (Net)',
        value: _byUnit(_stats.restockedByUnit),
        icon: Icons.inventory_rounded,
        color: const Color(0xFF8B5CF6),
      ),
      _buildMiniStatPill(
        theme: theme,
        label: 'Adjusted Up',
        value: qty(StorageMovementKind.adjustedUp),
        icon: Icons.create_new_folder_rounded,
        color: const Color(0xFF10B981),
      ),
      _buildMiniStatPill(
        theme: theme,
        label: 'Adjusted Down',
        value: qty(StorageMovementKind.adjustedDown),
        icon: Icons.delete_outline_rounded,
        color: const Color(0xFF6B7280),
      ),
      _buildMiniStatPill(
        theme: theme,
        label: 'Items Created',
        value:
            '${_stats.countOf(StorageMovementKind.created)}',
        icon: Icons.add_box_outlined,
        color: const Color(0xFF9333EA),
      ),
      _buildMiniStatPill(
        theme: theme,
        label: 'Items Deleted',
        value:
            '${_stats.countOf(StorageMovementKind.deleted)}',
        icon: Icons.delete_forever_outlined,
        color: const Color(0xFFEA580C),
      ),
    ];

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Movement Categories',
            style: TextStyle(
              fontSize: theme.mobileTexts.b2.fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          widget.isDesktop
              ? Wrap(
                spacing: 10,
                runSpacing: 10,
                children:
                    statWidgets
                        .map(
                          (w) => SizedBox(
                            width: 200,
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

  Widget _card({
    required Widget child,
    EdgeInsets? padding,
  }) {
    return Container(
      padding: padding ?? const EdgeInsets.all(12),
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
      child: child,
    );
  }

  Widget _buildMiniStatPill({
    required ThemeProvider theme,
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Tooltip(
      message: value,
      child: Container(
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
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.b5.fontSize,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.b3.fontSize,
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
    return _card(
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
              Tooltip(
                message: value,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.b1.fontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
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
  // Middle Section: Movement Mix & Movement Leaders
  // ---------------------------------------------------------------------------
  Widget _buildMiddleSection({
    required ThemeProvider theme,
    required List<StorageHistorySummaryRow> topInflow,
    required List<StorageHistorySummaryRow> topOutflow,
  }) {
    final donutCard = _buildMovementDonutCard(theme);
    final leadersCard = _buildTopMoversCard(
      theme: theme,
      topInflow: topInflow,
      topOutflow: topOutflow,
    );

    if (widget.isDesktop) {
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

  /// Share of records per movement type. Records are counted, not
  /// quantities, because storage items use different units.
  Widget _buildMovementDonutCard(ThemeProvider theme) {
    const kinds = [
      (
        StorageMovementKind.transferredOut,
        Color(0xFFE11D48),
      ),
      (StorageMovementKind.returned, Color(0xFF16A34A)),
      (StorageMovementKind.stockIn, Color(0xFF0284C7)),
      (StorageMovementKind.purchase, Color(0xFF3B82F6)),
      (
        StorageMovementKind.purchaseDeleted,
        Color(0xFFF43F5E),
      ),
      (StorageMovementKind.adjustedUp, Color(0xFF10B981)),
      (StorageMovementKind.adjustedDown, Color(0xFF6B7280)),
    ];
    final total = _stats.movementCount;

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Movement Mix',
            style: TextStyle(
              fontSize: theme.mobileTexts.b1.fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            'Share of stock movement records by type',
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
                        total == 0
                            ? [
                              PieChartSectionData(
                                color: Colors.grey.shade200,
                                value: 1,
                                radius: 18,
                                showTitle: false,
                              ),
                            ]
                            : [
                              for (final k in kinds)
                                if (_stats.countOf(k.$1) >
                                    0)
                                  PieChartSectionData(
                                    color: k.$2,
                                    value:
                                        _stats
                                            .countOf(k.$1)
                                            .toDouble(),
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
                      '$total',
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b1.fontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      total == 1 ? 'Movement' : 'Movements',
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
              for (final k in kinds)
                if (_stats.countOf(k.$1) > 0)
                  _buildLegendRow(
                    theme: theme,
                    color: k.$2,
                    label: k.$1.label,
                    percentage:
                        total > 0
                            ? (_stats.countOf(k.$1) /
                                    total) *
                                100
                            : 0,
                    value: '${_stats.countOf(k.$1)}',
                  ),
              if (total == 0)
                Text(
                  'No movement recorded',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: theme.mobileTexts.b4.fontSize,
                  ),
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
    required List<StorageHistorySummaryRow> topInflow,
    required List<StorageHistorySummaryRow> topOutflow,
  }) {
    return _card(
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
            'Highest stock additions and reductions in period, each in its own unit',
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
              }
              return Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                spacing: 10,
                children: [
                  Expanded(child: additionsBox),
                  Expanded(child: reductionsBox),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _rankedRow({
    required ThemeProvider theme,
    required int rank,
    required Color color,
    required String title,
    required String subtitle,
    required String trailing,
    VoidCallback? onTap,
  }) {
    final row = Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color.withAlpha(25),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            '$rank',
            style: TextStyle(
              fontSize: theme.mobileTexts.b4.fontSize,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: theme.mobileTexts.b4.fontSize,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: theme.mobileTexts.b5.fontSize,
                  color: Colors.grey.shade500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            trailing,
            textAlign: TextAlign.end,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: theme.mobileTexts.b4.fontSize,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        if (onTap != null)
          Icon(
            Icons.keyboard_arrow_right_outlined,
            size: 18,
            color: Colors.grey.shade400,
          ),
      ],
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child:
          onTap == null
              ? row
              : Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap,
                  mouseCursor: SystemMouseCursors.click,
                  child: row,
                ),
              ),
    );
  }

  Widget _emptyList(ThemeProvider theme, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: theme.mobileTexts.b4.fontSize,
          ),
        ),
      ),
    );
  }

  Widget _listBox({
    required ThemeProvider theme,
    required String title,
    required IconData icon,
    required Color color,
    String? badgeText,
    required List<Widget> children,
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
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: color, size: 16),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        title,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize:
                              theme.mobileTexts.b3.fontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (badgeText != null &&
                  screenWidth(context) > mobileScreen)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: color.withAlpha(20),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.b4.fontSize,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          ...children,
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
    required List<StorageHistorySummaryRow> items,
    required bool isInflow,
  }) {
    return _listBox(
      theme: theme,
      title: title,
      icon: icon,
      color: badgeColor,
      badgeText: badgeText,
      children: [
        if (items.isEmpty)
          _emptyList(theme, 'No movement recorded')
        else
          for (var idx = 0; idx < items.length; idx++)
            _rankedRow(
              theme: theme,
              rank: idx + 1,
              color:
                  isInflow
                      ? const Color(0xFF16A34A)
                      : const Color(0xFFDC2626),
              title: items[idx].name,
              subtitle: 'Unit: ${items[idx].primaryUnit}',
              trailing:
                  '${isInflow ? '+' : '-'}${items[idx].quantityText(isInflow ? items[idx].totalAdditions : items[idx].totalReductions)}',
              onTap:
                  () => _openItemHistory(items[idx].uuid),
            ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Breakdowns: sales items, departments, staff
  // ---------------------------------------------------------------------------
  Widget _buildBreakdownsSection(ThemeProvider theme) {
    Widget box({
      required String title,
      required IconData icon,
      required Color color,
      required List<StorageHistoryBreakdownEntry> entries,
      bool showInflow = true,
      bool showOutflow = true,
    }) {
      final top = entries.take(5).toList();
      return _listBox(
        theme: theme,
        title: title,
        icon: icon,
        color: color,
        children: [
          if (top.isEmpty)
            _emptyList(theme, 'Nothing recorded')
          else
            for (var i = 0; i < top.length; i++)
              _rankedRow(
                theme: theme,
                rank: i + 1,
                color: color,
                title: top[i].label,
                subtitle:
                    '${top[i].count} record${top[i].count == 1 ? '' : 's'}',
                trailing: [
                  if (showInflow &&
                      top[i].inflow.isNotEmpty)
                    'In: ${_byUnit(top[i].inflow)}',
                  if (showOutflow &&
                      top[i].outflow.isNotEmpty)
                    'Out: ${_byUnit(top[i].outflow)}',
                ].join('\n'),
              ),
        ],
      );
    }

    final boxes = [
      box(
        title: 'Sales Items Supplied',
        icon: Icons.outbox_rounded,
        color: const Color(0xFFE11D48),
        entries: _breakdowns.salesItemsSupplied,
        showInflow: false,
      ),
      box(
        title: 'Sales Items Returning',
        icon: Icons.assignment_return_rounded,
        color: const Color(0xFF16A34A),
        entries: _breakdowns.salesItemsReturning,
        showOutflow: false,
      ),
      if (_departmentsEnabled)
        box(
          title: 'Departments',
          icon: Icons.apartment_rounded,
          color: const Color(0xFF0284C7),
          entries: _breakdowns.departments,
        ),
      box(
        title: 'Storekeepers',
        icon: Icons.badge_outlined,
        color: const Color(0xFF7E22CE),
        entries: _breakdowns.storekeepers,
      ),
      box(
        title: 'Other Staff',
        icon: Icons.people_outline_rounded,
        color: const Color(0xFFD97706),
        entries: _breakdowns.otherStaff,
      ),
    ];

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Movement Breakdown',
            style: TextStyle(
              fontSize: theme.mobileTexts.b1.fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            'Top 5 by number of records in period',
            style: TextStyle(
              fontSize: theme.mobileTexts.b4.fontSize,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              if (!widget.isDesktop ||
                  constraints.maxWidth < 700) {
                return Column(spacing: 10, children: boxes);
              }
              final w = (constraints.maxWidth - 20) / 3;
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children:
                    boxes
                        .map(
                          (b) =>
                              SizedBox(width: w, child: b),
                        )
                        .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Item-Level Summary Table
  // ---------------------------------------------------------------------------
  Widget _buildItemSummaryTableCard(ThemeProvider theme) {
    final res = _pageResult;
    return _card(
      padding: EdgeInsets.zero,
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
                      'Storage Item Movements',
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b1.fontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Closing Stock = Opening Stock + Net Change • Tap an item to see its history',
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
                      'No matching storage items found',
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
            Padding(
              padding: const EdgeInsets.fromLTRB(
                14,
                0,
                14,
                8,
              ),
              child: ReportPager(
                theme: theme,
                page: res.page,
                totalPages: res.totalPages,
                totalCount: res.totalCount,
                firstIndex: res.firstIndex,
                lastIndex: res.lastIndex,
                itemLabel: 'storage items',
                onPage:
                    (p) => setState(() {
                      _page = p;
                      _applyFilterAndSort();
                    }),
              ),
            ),
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
        SizedBox(
          width:
              screenWidth(context) < mobileScreen
                  ? double.infinity
                  : 260,
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
              hintText: 'Search storage items...',
              prefixIcon: const Icon(
                Icons.search,
                size: 14,
              ),
              contentPadding: const EdgeInsets.symmetric(
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
        SizedBox(
          width: 170,
          child: ReportSearchableDropdown<
            StorageHistoryMovementFilter
          >(
            title: 'Movement',
            value: _filters.movementFilter,
            showSearch: false,
            highlighted:
                _filters.movementFilter !=
                StorageHistoryMovementFilter.all,
            options:
                StorageHistoryMovementFilter.values
                    .map(
                      (f) => ReportSearchableOption(
                        value: f,
                        label: f.label,
                      ),
                    )
                    .toList(),
            onChanged:
                (v) => setState(() {
                  _filters.movementFilter = v;
                  _page = 1;
                  _applyFilterAndSort();
                }),
            theme: theme,
          ),
        ),
      ],
    );
  }

  DataColumn _dataCol(
    String label,
    StorageHistorySummarySortField field,
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

  DataCell _numCell(
    ThemeProvider theme,
    StorageHistorySummaryRow r,
    double? v, {
    Color? color,
    bool bold = false,
  }) {
    return DataCell(
      Center(
        child: Text(
          v == null || v == 0
              ? (v == null ? '—' : '0')
              : formatLargeNumberDouble(v),
          style: TextStyle(
            fontSize: theme.mobileTexts.b4.fontSize,
            fontWeight:
                bold ? FontWeight.bold : FontWeight.w600,
            color:
                (v ?? 0) == 0
                    ? Colors.grey.shade500
                    : (color ?? Colors.black87),
          ),
        ),
      ),
    );
  }

  Widget _buildDataTable(
    ThemeProvider theme,
    List<StorageHistorySummaryRow> rows,
  ) {
    const green = Color(0xFF16A34A);
    const red = Color(0xFFDC2626);
    return DataTable(
      headingRowHeight: 38,
      dataRowMinHeight: 36,
      dataRowMaxHeight: 44,
      horizontalMargin: 12,
      columnSpacing: 16,
      showCheckboxColumn: false,
      headingRowColor: WidgetStateProperty.all(
        Colors.grey.shade100,
      ),
      columns: [
        _dataCol(
          'No.',
          StorageHistorySummarySortField.rowIndex,
          theme,
        ),
        _dataCol(
          'Storage Item',
          StorageHistorySummarySortField.itemName,
          theme,
          alignLeft: true,
        ),
        _dataCol(
          'Opening Stock',
          StorageHistorySummarySortField.openingStock,
          theme,
          tooltip:
              'Storage balance before the period (Primary Unit)',
        ),
        _dataCol(
          'Closing Stock',
          StorageHistorySummarySortField.closingStock,
          theme,
          tooltip:
              'Storage balance at the end of the period (Primary Unit)',
        ),
        _dataCol(
          'Current Quantity',
          StorageHistorySummarySortField.currentQuantity,
          theme,
        ),
        _dataCol(
          'Net Change',
          StorageHistorySummarySortField.netQuantityChange,
          theme,
          tooltip: 'Additions minus Reductions',
        ),
        _dataCol(
          'Transferred Out',
          StorageHistorySummarySortField.transferredOut,
          theme,
          tooltip: 'Stock moved to sales items',
        ),
        _dataCol(
          'Returned',
          StorageHistorySummarySortField.returned,
          theme,
          tooltip: 'Stock returned from sales items',
        ),
        _dataCol(
          'Stocked In',
          StorageHistorySummarySortField.stockedIn,
          theme,
        ),
        _dataCol(
          'Purchased',
          StorageHistorySummarySortField.purchased,
          theme,
        ),
        _dataCol(
          'Purchase Deleted',
          StorageHistorySummarySortField.purchaseDeleted,
          theme,
        ),
        _dataCol(
          'Adjusted Up',
          StorageHistorySummarySortField.adjustedUp,
          theme,
        ),
        _dataCol(
          'Adjusted Down',
          StorageHistorySummarySortField.adjustedDown,
          theme,
        ),
        _dataCol(
          'Total In',
          StorageHistorySummarySortField.totalAdditions,
          theme,
        ),
        _dataCol(
          'Total Out',
          StorageHistorySummarySortField.totalReductions,
          theme,
        ),
        _dataCol(
          'Movements',
          StorageHistorySummarySortField.movementCount,
          theme,
          tooltip: 'Number of stock movement records',
        ),
      ],
      rows:
          rows.map((r) {
            final net = r.netQuantityChange;
            return DataRow(
              onSelectChanged:
                  (_) => _openItemHistory(r.uuid),
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
                  Tooltip(
                    message: [
                      if (r.currentName != null)
                        'Now named: ${r.currentName}',
                      if (!r.exists) 'Deleted storage item',
                      if (r.notNormalised > 0)
                        '${r.notNormalised} record${r.notNormalised == 1 ? '' : 's'} not converted',
                    ].join('\n'),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          spacing: 4,
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
                                    r.exists
                                        ? theme
                                            .lightModeColor
                                            .prColor300
                                        : Colors
                                            .grey
                                            .shade600,
                              ),
                              maxLines: 1,
                              overflow:
                                  TextOverflow.ellipsis,
                            ),
                            if (r.currentName != null ||
                                !r.exists ||
                                r.notNormalised > 0)
                              Icon(
                                Icons.info_outline_rounded,
                                size: 13,
                                color: Colors.grey.shade500,
                              ),
                          ],
                        ),
                        Text(
                          r.exists
                              ? r.primaryUnit
                              : '${r.primaryUnit} • Deleted',
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
                _numCell(theme, r, r.openingStock),
                _numCell(
                  theme,
                  r,
                  r.closingStock,
                  color: const Color(0xFF2563EB),
                  bold: true,
                ),
                _numCell(theme, r, r.currentQuantity),
                DataCell(
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color:
                            net > 0
                                ? green.withAlpha(20)
                                : net < 0
                                ? red.withAlpha(20)
                                : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(
                          4,
                        ),
                      ),
                      child: Text(
                        '${net > 0 ? '+' : ''}${formatLargeNumberDouble(net)}',
                        style: TextStyle(
                          fontSize:
                              theme.mobileTexts.b4.fontSize,
                          fontWeight: FontWeight.bold,
                          color:
                              net > 0
                                  ? green
                                  : net < 0
                                  ? red
                                  : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
                ),
                _numCell(
                  theme,
                  r,
                  r.transferredOut,
                  color: red,
                ),
                _numCell(
                  theme,
                  r,
                  r.returned,
                  color: green,
                ),
                _numCell(
                  theme,
                  r,
                  r.stockedIn,
                  color: green,
                ),
                _numCell(
                  theme,
                  r,
                  r.purchased,
                  color: green,
                ),
                _numCell(
                  theme,
                  r,
                  r.purchaseDeleted,
                  color: red,
                ),
                _numCell(
                  theme,
                  r,
                  r.adjustedUp,
                  color: green,
                ),
                _numCell(
                  theme,
                  r,
                  r.adjustedDown,
                  color: red,
                ),
                _numCell(
                  theme,
                  r,
                  r.totalAdditions,
                  color: green,
                  bold: true,
                ),
                _numCell(
                  theme,
                  r,
                  r.totalReductions,
                  color: red,
                  bold: true,
                ),
                DataCell(
                  Center(
                    child: Text(
                      '${r.movementCount}',
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b4.fontSize,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
    );
  }
}
