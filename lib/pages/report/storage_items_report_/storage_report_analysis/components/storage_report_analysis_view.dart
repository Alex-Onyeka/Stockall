import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_departments_class/department_class.dart';
import 'package:stockall/classes/temp_storage_item_history/storage_item_history.dart';
import 'package:stockall/classes/temp_storage_product/temp_storage_products.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/date_picker_function.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/refresh_functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/products/storage_page/storage_details/storage_details_page.dart';
import 'package:stockall/pages/report/components/export/report_export_button.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/storage_items_report_/storage_item_history_report/class/storage_item_history_report_logic.dart';
import 'package:stockall/pages/report/storage_items_report_/storage_item_history_summary/class/storage_item_history_summary_logic.dart';
import 'package:stockall/pages/report/storage_items_report_/storage_report_analysis/class/storage_report_analysis_export_spec.dart';
import 'package:stockall/pages/report/storage_items_report_/storage_report_analysis/class/storage_report_analysis_logic.dart';
import 'package:stockall/pages/report/storage_items_report_/storage_report_main/class/storage_report_main_logic.dart';
import 'package:stockall/pages/report/storage_items_report_/storage_report_main/storage_report_main_page.dart';
import 'package:stockall/providers/theme_provider.dart';

/// Shared body of the "Storage Report Analysis" page (desktop + mobile).
class StorageReportAnalysisView extends StatefulWidget {
  final bool isDesktop;

  const StorageReportAnalysisView({
    super.key,
    required this.isDesktop,
  });

  @override
  State<StorageReportAnalysisView> createState() =>
      _StorageReportAnalysisViewState();
}

class _StorageReportAnalysisViewState
    extends State<StorageReportAnalysisView> {
  bool _loading = true;
  String? _error;

  List<StorageReportRow> _rows = [];
  List<TempStorageProducts> _storageProducts = [];
  List<StorageItemHistory> _histories = [];
  List<DepartmentClass> _departments = [];

  StoragePerformanceMetric _metric =
      StoragePerformanceMetric.transferredOut;
  StorageHistoryPeriod _period = StorageHistoryPeriod.today;
  DateTimeRange? _customRange;
  int _distribTabIndex = 0; // 0 = Department, 1 = Quantity Type

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load(refreshFromStore: false);
    });
  }

  bool get _departmentsEnabled =>
      shopSingle()?.manageDepartments == true;

  bool get _canViewAllDepartments => authorization(
    authorized: Authorizations().viewAllDepartments,
  );

  bool get _canSeeCost => authorization(
    authorized: Authorizations().manageCostPrice,
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
      if (refreshFromStore && mounted) {
        await RefreshFunctions(context).refreshProducts(context);
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

      _departments = returnDepartmentProvider().departments;
      _storageProducts =
          returnStorageProductProvider()
              .storageProductListMain;
      _rows = StorageReportRowBuilder.buildAll(
        storageProducts: _storageProducts,
        salesProducts: returnData().productListMain,
      );
      _histories = scopeStorageItemHistories(
        all:
            returnStorageItemHistoryProvider()
                .storageItemHistories,
        shopId: sId,
        departmentsEnabled: _departmentsEnabled,
        canViewAllDepartments: _canViewAllDepartments,
        currentDepartmentUuid: _currentDepartmentUuid,
      );

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

  void _pickCustomRange() {
    final theme = returnTheme(context, listen: false);
    mainDatePicker(
      context: context,
      theme: theme,
      singleDate: (date) {
        if (date == null) return;
        final d = DateTime(date.year, date.month, date.day);
        setState(() {
          _period = StorageHistoryPeriod.custom;
          _customRange = DateTimeRange(start: d, end: d);
        });
      },
      rangeDate: (start, end) {
        if (start == null) return;
        final s = DateTime(start.year, start.month, start.day);
        final e =
            end == null
                ? s
                : DateTime(end.year, end.month, end.day);
        setState(() {
          _period = StorageHistoryPeriod.custom;
          _customRange = DateTimeRange(start: s, end: e);
        });
      },
    );
  }

  String _money(num v) => formatMoneyBig(amount: v, context: context);

  /// One-way click-through to the main table, searched by name.
  void _openInMainTable(String name) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => StorageReportMainPage(initialSearch: name),
      ),
    ).then((_) {
      if (mounted) _load(refreshFromStore: false);
    });
  }

  void _openStorageItem(String uuid) {
    if (uuid.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => StorageDetailsPage(productUuid: uuid),
      ),
    ).then((_) {
      if (mounted) _load(refreshFromStore: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = returnTheme(context);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 252, 253, 255),
      appBar: appBar(
        context: context,
        title: 'Storage Report Analysis',
        widget: Padding(
          padding: const EdgeInsets.only(right: 10.0),
          child: IconButton(
            tooltip: 'Refresh Data',
            icon: const Icon(Icons.refresh_rounded, size: 18),
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
              ? const Center(child: CircularProgressIndicator())
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
            'Unable to generate storage analysis',
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

  /// The same figures [_buildContent] draws.
  ReportExportSpec _exportSpec() {
    final now = resolveBusinessDate(DateTime.now());
    final records = StorageReportAnalysisBuilder.computePerformance(
      rows: _rows,
      storageProducts: _storageProducts,
      histories: _histories,
      period: _period,
      businessNow: now,
      customRange: _customRange,
    );
    return storageAnalysisExportSpec(
      summary: StorageReportAnalysisBuilder.buildSummary(_rows),
      records: records,
      best3: StorageReportAnalysisBuilder.getBest3(
        records: records,
        metric: _metric,
      ),
      least3: StorageReportAnalysisBuilder.getLeast3(
        records: records,
        metric: _metric,
      ),
      idle: StorageReportAnalysisBuilder.getIdleItems(records),
      metric: _metric,
      departmentDist:
          StorageReportAnalysisBuilder.computeDepartmentDistribution(
            rows: _rows,
            departments: _departments,
          ),
      typeDist:
          StorageReportAnalysisBuilder.computeQuantityTypeDistribution(
            _rows,
          ),
      recentItems: StorageReportAnalysisBuilder.getNewlyCreatedItems(
        _rows,
        limit: 10,
      ),
      period: _period,
      customRange: _customRange,
      resolvedRange: StorageHistorySummaryBuilder.resolveDateRange(
        period: _period,
        businessNow: now,
        customRange: _customRange,
      ),
      canSeeCost: _canSeeCost,
      departmentsEnabled: _departmentsEnabled,
      currency: currencySymbol(context: context),
    );
  }

  Widget _buildContent(ThemeProvider theme) {
    final summary = StorageReportAnalysisBuilder.buildSummary(_rows);
    final now = resolveBusinessDate(DateTime.now());

    final records = StorageReportAnalysisBuilder.computePerformance(
      rows: _rows,
      storageProducts: _storageProducts,
      histories: _histories,
      period: _period,
      businessNow: now,
      customRange: _customRange,
    );
    final best3 = StorageReportAnalysisBuilder.getBest3(
      records: records,
      metric: _metric,
    );
    final least3 = StorageReportAnalysisBuilder.getLeast3(
      records: records,
      metric: _metric,
    );
    final idle = StorageReportAnalysisBuilder.getIdleItems(records);

    final departmentDist =
        StorageReportAnalysisBuilder.computeDepartmentDistribution(
          rows: _rows,
          departments: _departments,
        );
    final typeDist =
        StorageReportAnalysisBuilder.computeQuantityTypeDistribution(
          _rows,
        );
    final recentItems =
        StorageReportAnalysisBuilder.getNewlyCreatedItems(
          _rows,
          limit: 10,
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
          _buildSummaryCards(theme, summary),
          _buildStockBreakdownBar(theme, summary),
          _buildMiddleSection(
            theme: theme,
            summary: summary,
            records: records,
            best3: best3,
            least3: least3,
            idle: idle,
          ),
          _buildBottomSection(
            theme: theme,
            departmentDist: departmentDist,
            typeDist: typeDist,
            recentItems: recentItems,
          ),
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
          'Storage Analytics & Performance',
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
                          fontSize: theme.mobileTexts.b3.fontSize,
                        ),
                      ),
                    );
                  }).toList(),
              onChanged: (val) {
                if (val == null) return;
                if (val == StorageHistoryPeriod.custom) {
                  _pickCustomRange();
                } else {
                  setState(() {
                    _period = val;
                    _customRange = null;
                  });
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
                        fontSize: theme.mobileTexts.b4.fontSize,
                        fontWeight: FontWeight.bold,
                        color: theme.lightModeColor.prColor300,
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

  Widget _card({required Widget child}) {
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
      child: child,
    );
  }

  Widget _cardTitle(ThemeProvider theme, String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: theme.mobileTexts.b1.fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: theme.mobileTexts.b4.fontSize,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Summary Statistics KPI Cards
  // ---------------------------------------------------------------------------
  Widget _buildSummaryCards(
    ThemeProvider theme,
    StorageReportAnalysisSummary summary,
  ) {
    final stockText =
        summary.singleUnitFormattedQuantity ??
        '${summary.stockByPrimaryUnit.length} Units';

    final cards = [
      _buildKpiCard(
        theme: theme,
        title: 'Stock Cost Value',
        value:
            _canSeeCost
                ? _money(summary.totalStockCostValue)
                : 'Restricted',
        subtitle:
            _canSeeCost
                ? (summary.itemsWithoutCostCount > 0
                    ? '${summary.itemsWithoutCostCount} item${summary.itemsWithoutCostCount == 1 ? ' has' : 's have'} no cost price'
                    : 'Total Storage Cost')
                : 'Permission Required',
        badgeText: _canSeeCost ? 'Cost Basis' : 'Locked',
        badgeColor: Colors.grey.shade600,
        icon: Icons.account_balance_wallet_rounded,
        iconBg: const Color(0xFFF3E8FF),
        iconColor: const Color(0xFF7E22CE),
      ),
      _buildKpiCard(
        theme: theme,
        title: 'Storage Items',
        value:
            '${formatLargeNumberDouble(summary.totalDistinctItems.toDouble())} Items',
        subtitle:
            '${summary.oneDimensionalCount} Simple • ${summary.twoDimensionalCount} 2-Dimensional',
        badgeText: '${summary.totalDistinctItems} Total',
        badgeColor: const Color(0xFF2563EB),
        icon: Icons.inventory_2_rounded,
        iconBg: const Color(0xFFEFF6FF),
        iconColor: const Color(0xFF2563EB),
      ),
      _buildKpiCard(
        theme: theme,
        title: 'Linked To Sales Items',
        value: '${summary.linkedCount} of ${summary.totalDistinctItems}',
        subtitle:
            '${summary.linkedSalesItemsCount} Sales Item${summary.linkedSalesItemsCount == 1 ? '' : 's'} Supplied',
        badgeText: '${summary.unlinkedCount} Unlinked',
        badgeColor: const Color(0xFF059669),
        icon: Icons.link_rounded,
        iconBg: const Color(0xFFECFDF5),
        iconColor: const Color(0xFF059669),
      ),
      _buildKpiCard(
        theme: theme,
        title: 'Stock In Storage',
        value: stockText,
        tooltip: formatQuantitiesByUnit(summary.stockByPrimaryUnit),
        subtitle: 'In each item\'s primary unit',
        badgeText: '${summary.inStockCount} In Stock',
        badgeColor: const Color(0xFFD97706),
        icon: Icons.warehouse_rounded,
        iconBg: const Color(0xFFFFFBEB),
        iconColor: const Color(0xFFD97706),
      ),
    ];

    if (widget.isDesktop) {
      return Row(
        spacing: 10,
        children: cards.map((c) => Expanded(child: c)).toList(),
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
    String? tooltip,
  }) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (screenWidth(context) > mobileScreen)
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(icon, color: iconColor, size: 17),
                ),
              Flexible(
                child: Container(
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
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: theme.mobileTexts.b4.fontSize,
                      fontWeight: FontWeight.bold,
                      color: badgeColor,
                    ),
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
                message: tooltip ?? value,
                child: FittedBox(
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
  Widget _buildStockBreakdownBar(
    ThemeProvider theme,
    StorageReportAnalysisSummary summary,
  ) {
    Widget stat(IconData icon, Color color, String label, String value) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: theme.mobileTexts.b3.fontSize,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: theme.mobileTexts.b3.fontSize,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          stat(
            Icons.check_circle_outline,
            const Color(0xFF16A34A),
            'In Stock: ',
            '${summary.inStockCount}',
          ),
          stat(
            Icons.cancel_outlined,
            const Color(0xFFDC2626),
            'Out of Stock: ',
            '${summary.outOfStockCount}',
          ),
          Container(width: 1, height: 14, color: Colors.grey.shade300),
          stat(
            Icons.straighten_rounded,
            Colors.blueGrey,
            'Simple: ',
            '${summary.oneDimensionalCount}',
          ),
          stat(
            Icons.crop_square_rounded,
            Colors.blueGrey,
            '2-Dimensional: ',
            '${summary.twoDimensionalCount}',
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Middle Section: Storage Performance + Stock Donut Chart
  // ---------------------------------------------------------------------------
  Widget _buildMiddleSection({
    required ThemeProvider theme,
    required StorageReportAnalysisSummary summary,
    required List<StoragePerformanceRecord> records,
    required List<StoragePerformanceRecord> best3,
    required List<StoragePerformanceRecord> least3,
    required List<StoragePerformanceRecord> idle,
  }) {
    final performanceCard = _buildPerformanceCard(
      theme: theme,
      records: records,
      best3: best3,
      least3: least3,
      idle: idle,
    );
    final donutCard = _buildStockDonutCard(theme: theme, summary: summary);

    if (widget.isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          Expanded(flex: 65, child: performanceCard),
          Expanded(flex: 35, child: donutCard),
        ],
      );
    } else {
      return Column(
        spacing: 10,
        children: [performanceCard, donutCard],
      );
    }
  }

  Widget _buildPerformanceCard({
    required ThemeProvider theme,
    required List<StoragePerformanceRecord> records,
    required List<StoragePerformanceRecord> best3,
    required List<StoragePerformanceRecord> least3,
    required List<StoragePerformanceRecord> idle,
  }) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              _cardTitle(
                theme,
                'Storage Movement Performance',
                'Most & least active storage items for ${_period.label}',
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  border: Border.all(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<StoragePerformanceMetric>(
                    value: _metric,
                    icon: const Icon(Icons.arrow_drop_down, size: 16),
                    style: TextStyle(
                      fontSize: theme.mobileTexts.b3.fontSize,
                      fontWeight: FontWeight.w600,
                      color: theme.lightModeColor.prColor300,
                    ),
                    items:
                        StoragePerformanceMetric.values.map((m) {
                          return DropdownMenuItem(
                            value: m,
                            child: Text(
                              m.label,
                              style: TextStyle(
                                fontSize: theme.mobileTexts.b4.fontSize,
                              ),
                            ),
                          );
                        }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _metric = val);
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final stack = constraints.maxWidth < 550;
              final bestWidget = _buildRankingCard(
                theme: theme,
                title: 'Most Active 3',
                badgeText: 'Top Leaders',
                badgeColor: const Color(0xFF16A34A),
                icon: Icons.star_rounded,
                items: best3,
              );
              final leastWidget = _buildRankingCard(
                theme: theme,
                title: 'Least Active 3',
                badgeText: 'Needs Attention',
                badgeColor: const Color(0xFFD97706),
                icon: Icons.trending_down_rounded,
                items: least3,
              );
              if (stack) {
                return Column(
                  spacing: 10,
                  children: [bestWidget, leastWidget],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10,
                children: [
                  Expanded(child: bestWidget),
                  Expanded(child: leastWidget),
                ],
              );
            },
          ),
          const SizedBox(height: 10),
          Row(
            spacing: 4,
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 13,
                color: Colors.grey.shade600,
              ),
              Expanded(
                child: Text(
                  storageAnalysisIdleNote(records, idle),
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRankingCard({
    required ThemeProvider theme,
    required String title,
    required String badgeText,
    required Color badgeColor,
    required IconData icon,
    required List<StoragePerformanceRecord> items,
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: badgeColor, size: 16),
                  const SizedBox(width: 5),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: theme.mobileTexts.b3.fontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              if (screenWidth(context) > mobileScreen)
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
                      fontSize: theme.mobileTexts.b4.fontSize,
                      fontWeight: FontWeight.bold,
                      color: badgeColor,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text(
                  'No storage items',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: theme.mobileTexts.b4.fontSize,
                  ),
                ),
              ),
            )
          else
            for (var idx = 0; idx < items.length; idx++)
              Material(
                color: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: InkWell(
                    onTap: () => _openInMainTable(items[idx].name),
                    mouseCursor: SystemMouseCursors.click,
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: badgeColor.withAlpha(25),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${idx + 1}',
                            style: TextStyle(
                              fontSize: theme.mobileTexts.b4.fontSize,
                              fontWeight: FontWeight.bold,
                              color: badgeColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                items[idx].name,
                                style: TextStyle(
                                  fontSize: theme.mobileTexts.b4.fontSize,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                items[idx].currentQuantity == null
                                    ? 'In storage: —'
                                    : 'In storage: ${formatLargeNumberDouble(items[idx].currentQuantity!)} ${items[idx].primaryUnit}',
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
                        Text(
                          items[idx].formattedMetricValue(_metric),
                          style: TextStyle(
                            fontSize: theme.mobileTexts.b4.fontSize,
                            fontWeight: FontWeight.bold,
                            color: badgeColor,
                          ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_right_outlined,
                          size: 18,
                          color: Colors.grey.shade400,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildStockDonutCard({
    required ThemeProvider theme,
    required StorageReportAnalysisSummary summary,
  }) {
    final total = summary.totalDistinctItems;
    final inPct = total > 0 ? summary.inStockCount / total * 100 : 0.0;
    final outPct = total > 0 ? summary.outOfStockCount / total * 100 : 0.0;
    final units = <String>{
      ...summary.stockByPrimaryUnit.keys,
      ...summary.quantityInSalesByUnit.keys,
    }.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle(theme, 'Stock Status', 'Storage items in and out of stock'),
          const SizedBox(height: 12),
          SizedBox(
            height: 150,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 3,
                    centerSpaceRadius: 44,
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
                              if (summary.inStockCount > 0)
                                PieChartSectionData(
                                  color: const Color(0xFF16A34A),
                                  value: summary.inStockCount.toDouble(),
                                  radius: 20,
                                  showTitle: false,
                                ),
                              if (summary.outOfStockCount > 0)
                                PieChartSectionData(
                                  color: const Color(0xFFDC2626),
                                  value: summary.outOfStockCount.toDouble(),
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
                        fontSize: theme.mobileTexts.b1.fontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Items',
                      style: TextStyle(
                        fontSize: theme.mobileTexts.b4.fontSize,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _legendRow(
            theme,
            const Color(0xFF16A34A),
            'In Stock',
            '${inPct.toStringAsFixed(0)}%  •  ${summary.inStockCount}',
          ),
          const SizedBox(height: 6),
          _legendRow(
            theme,
            const Color(0xFFDC2626),
            'Out of Stock',
            '${outPct.toStringAsFixed(0)}%  •  ${summary.outOfStockCount}',
          ),
          if (units.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 8),
            Text(
              'Storage vs Sales Items, per unit',
              style: TextStyle(
                fontSize: theme.mobileTexts.b4.fontSize,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 6),
            for (final u in units)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        u,
                        style: TextStyle(
                          fontSize: theme.mobileTexts.b4.fontSize,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      'Storage ${formatLargeNumberDouble(summary.stockByPrimaryUnit[u] ?? 0)}'
                      '  •  Sales ${formatLargeNumberDouble(summary.quantityInSalesByUnit[u] ?? 0)}',
                      style: TextStyle(
                        fontSize: theme.mobileTexts.b4.fontSize,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _legendRow(
    ThemeProvider theme,
    Color color,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
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
          value,
          style: TextStyle(
            fontSize: theme.mobileTexts.b4.fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Bottom Section: Distribution & Newly Created Items
  // ---------------------------------------------------------------------------
  Widget _buildBottomSection({
    required ThemeProvider theme,
    required List<StorageDistributionItem> departmentDist,
    required List<StorageDistributionItem> typeDist,
    required List<StorageReportRow> recentItems,
  }) {
    final distribCard = _buildDistributionTableCard(
      theme: theme,
      departmentDist: departmentDist,
      typeDist: typeDist,
    );
    final recentCard = _buildNewlyCreatedItemsCard(
      theme: theme,
      recentItems: recentItems,
    );

    if (widget.isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          Expanded(flex: 55, child: distribCard),
          Expanded(flex: 45, child: recentCard),
        ],
      );
    } else {
      return Column(
        spacing: 10,
        children: [distribCard, recentCard],
      );
    }
  }

  Widget _tabButton({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    required ThemeProvider theme,
  }) {
    return InkWell(
      onTap: onTap,
      mouseCursor: SystemMouseCursors.click,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: Colors.black.withAlpha(8),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ]
                  : null,
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: theme.mobileTexts.b4.fontSize,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color:
                isSelected
                    ? theme.lightModeColor.prColor300
                    : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _buildDistributionTableCard({
    required ThemeProvider theme,
    required List<StorageDistributionItem> departmentDist,
    required List<StorageDistributionItem> typeDist,
  }) {
    final showDept = _departmentsEnabled;
    final tab = showDept ? _distribTabIndex : 1;
    final list = tab == 0 ? departmentDist : typeDist;

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              _cardTitle(
                theme,
                'Storage Distribution',
                tab == 0
                    ? 'Storage items per department they supply'
                    : 'Storage items per quantity type',
              ),
              if (showDept)
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _tabButton(
                        title: 'Departments',
                        isSelected: tab == 0,
                        onTap: () => setState(() => _distribTabIndex = 0),
                        theme: theme,
                      ),
                      _tabButton(
                        title: 'Quantity Type',
                        isSelected: tab == 1,
                        onTap: () => setState(() => _distribTabIndex = 1),
                        theme: theme,
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 30,
                  child: Text(
                    '#',
                    style: TextStyle(
                      fontSize: theme.mobileTexts.b4.fontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    tab == 0 ? 'Department' : 'Quantity Type',
                    style: TextStyle(
                      fontSize: theme.mobileTexts.b4.fontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                SizedBox(
                  width: 70,
                  child: Text(
                    'Items',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: theme.mobileTexts.b4.fontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                SizedBox(
                  width: 70,
                  child: Text(
                    'Share',
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontSize: theme.mobileTexts.b4.fontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          for (final item in list)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 30,
                    child: Text(
                      '${item.index}',
                      style: TextStyle(
                        fontSize: theme.mobileTexts.b4.fontSize,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: theme.mobileTexts.b3.fontSize,
                        fontWeight: FontWeight.w600,
                        color:
                            item.key == storageAnalysisUnlinkedKey ||
                                    item.key == storageAnalysisNoDepartmentKey
                                ? Colors.grey.shade600
                                : Colors.black87,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 70,
                    child: Text(
                      '${item.itemCount}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: theme.mobileTexts.b3.fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 70,
                    child: Text(
                      '${item.percentage.toStringAsFixed(1)}%',
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontSize: theme.mobileTexts.b4.fontSize,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (tab == 0) ...[
            const SizedBox(height: 4),
            Text(
              storageAnalysisDepartmentFootnote,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNewlyCreatedItemsCard({
    required ThemeProvider theme,
    required List<StorageReportRow> recentItems,
  }) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _cardTitle(
                theme,
                'Newly Created Items',
                'Latest additions to your storage',
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Top ${recentItems.length}',
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b4.fontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (recentItems.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'No storage items created yet',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: theme.mobileTexts.b3.fontSize,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentItems.length,
              separatorBuilder:
                  (_, __) => Divider(height: 1, color: Colors.grey.shade100),
              itemBuilder: (context, idx) {
                final item = recentItems[idx];
                final initial =
                    item.name.isNotEmpty ? item.name[0].toUpperCase() : 'S';
                final inStock = (item.quantity ?? 0) > 0;
                final stockColor =
                    inStock
                        ? const Color(0xFF16A34A)
                        : const Color(0xFFDC2626);
                final stockLabel =
                    inStock
                        ? '${formatLargeNumberDouble(item.quantity!)} ${item.primaryUnit}'
                        : 'Out of Stock';
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(6),
                    mouseCursor: SystemMouseCursors.click,
                    onTap: () => _openStorageItem(item.uuid),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 4,
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: theme.lightModeColor.prColor300
                                .withAlpha(25),
                            child: Text(
                              initial,
                              style: TextStyle(
                                fontSize: theme.mobileTexts.b4.fontSize,
                                fontWeight: FontWeight.bold,
                                color: theme.lightModeColor.prColor300,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: theme.mobileTexts.b3.fontSize,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '${item.createdAt != null ? formatDateTime(item.createdAt!) : 'Date not set'} • ${item.quantityTypeLabel}',
                                  style: TextStyle(
                                    fontSize: theme.mobileTexts.b5.fontSize,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: stockColor.withAlpha(20),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              stockLabel,
                              style: TextStyle(
                                fontSize: theme.mobileTexts.b4.fontSize,
                                fontWeight: FontWeight.bold,
                                color: stockColor,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.keyboard_arrow_right_outlined,
                            size: 18,
                            color: Colors.grey.shade400,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
