import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_categories/category_class.dart';
import 'package:stockall/classes/temp_departments_class/department_class.dart';
import 'package:stockall/classes/temp_product_slaes_record/temp_product_sale_record.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/date_picker_function.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/refresh_functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/products/product_details/product_details_page.dart';
import 'package:stockall/pages/report/components/export/report_export_button.dart';
import 'package:stockall/pages/report/components/export/report_export_format.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/items_report_/items_report_analysis/class/items_report_analysis_export_spec.dart';
import 'package:stockall/pages/report/items_report_/items_report_analysis/class/items_report_analysis_logic.dart';
import 'package:stockall/pages/report/items_report_/items_report_main/class/items_report_main_logic.dart';
import 'package:stockall/pages/report/items_report_/items_report_main/items_report_main_page.dart';
import 'package:stockall/providers/theme_provider.dart';

class ItemsReportAnalysisView extends StatefulWidget {
  final bool isDesktop;

  const ItemsReportAnalysisView({
    super.key,
    required this.isDesktop,
  });

  @override
  State<ItemsReportAnalysisView> createState() =>
      _ItemsReportAnalysisViewState();
}

class _ItemsReportAnalysisViewState
    extends State<ItemsReportAnalysisView> {
  bool _loading = true;
  String? _error;

  List<ItemsReportRow> _rows = [];
  List<CategoryClass> _categories = [];
  List<DepartmentClass> _departments = [];
  List<TempProductSaleRecord> _salesRecords = [];

  // Filter & Metric States
  ItemPerformanceMetric _metric =
      ItemPerformanceMetric.salesRevenue;
  ItemAnalysisPeriod _period = ItemAnalysisPeriod.today;
  DateTimeRange? _customRange;
  int _distribTabIndex = 0; // 0 = Category, 1 = Department

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load(refreshFromStore: false);
    });
  }

  bool get _departmentsEnabled =>
      shopSingle()?.manageDepartments == true;

  bool get _canSeeCost => authorization(
    authorized: Authorizations().manageCostPrice,
  );

  Future<void> _load({
    required bool refreshFromStore,
  }) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final isAllTime =
          _period == ItemAnalysisPeriod.allTime;
      final resolvedRange =
          isAllTime
              ? null
              : ItemsReportAnalysisBuilder.resolveDateRange(
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
        await refresh.refreshReceipts(
          context,
          startDate: resolvedRange?.start,
          endDate: resolvedRange?.end,
          fetchAll: isAllTime,
          forceRefresh: true,
        );
      } else if (!isAllTime && resolvedRange != null) {
        final sid = shopSingle()?.shopId;
        if (sid != null) {
          await returnReceiptProviderSingle().loadReceipts(
            sid,
            startDate: resolvedRange.start,
            endDate: resolvedRange.end,
            forceRefresh: false,
          );
        }
      }

      _categories =
          returnCategoriesProvider().categoriesMain;
      _departments = returnDepartmentProvider().departments;
      _salesRecords =
          returnReceiptProviderSingle().salesReceipts();

      _rows = ItemsReportRowBuilder.buildAll(
        products: returnData().productList(),
        categories: _categories,
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
          _period = ItemAnalysisPeriod.custom;
          _customRange = DateTimeRange(start: d, end: d);
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
          _period = ItemAnalysisPeriod.custom;
          _customRange = DateTimeRange(start: s, end: e);
        });
        _load(refreshFromStore: false);
      },
    );
  }

  String _money(num v) =>
      formatMoneyBig(amount: v, context: context);

  /// What the Export button exports: the same figures and tables as
  /// [_buildContent], recomputed with the same calls (charts aren't
  /// exported).
  ReportExportSpec _exportSpec() {
    final now = resolveBusinessDate(DateTime.now());
    final performanceRecords =
        ItemsReportAnalysisBuilder.computePerformance(
          rows: _rows,
          salesRecords: _salesRecords,
          period: _period,
          businessNow: now,
          customRange: _customRange,
        );
    final currency = currencySymbol(context: context);
    return itemsAnalysisExportSpec(
      summary: ItemsReportAnalysisBuilder.buildSummary(
        _rows,
      ),
      best3: ItemsReportAnalysisBuilder.getBest3(
        records: performanceRecords,
        metric: _metric,
      ),
      least3: ItemsReportAnalysisBuilder.getLeast3(
        records: performanceRecords,
        metric: _metric,
      ),
      metric: _metric,
      categoryDist:
          ItemsReportAnalysisBuilder.computeCategoryDistribution(
            rows: _rows,
            categories: _categories,
          ),
      departmentDist:
          ItemsReportAnalysisBuilder.computeDepartmentDistribution(
            rows: _rows,
            departments: _departments,
          ),
      recentItems:
          ItemsReportAnalysisBuilder.getNewlyCreatedItems(
            _rows,
            limit: 10,
          ),
      periodLabel: itemsAnalysisPeriodLabel(
        _period,
        _customRange,
        ExportFormatter(currency: currency),
      ),
      range:
          _period == ItemAnalysisPeriod.allTime
              ? null
              : ItemsReportAnalysisBuilder.resolveDateRange(
                period: _period,
                businessNow: now,
                customRange: _customRange,
              ),
      currency: currency,
      canSeeCost: _canSeeCost,
      departmentsEnabled: _departmentsEnabled,
    );
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
        title: 'Items Report Analysis',
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
                              const ItemsReportMainPage(),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.table_chart_outlined,
                  size: 15,
                ),
                label: Text(
                  'View Table',
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
            'Unable to generate inventory analysis',
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
    final summary = ItemsReportAnalysisBuilder.buildSummary(
      _rows,
    );
    final now = resolveBusinessDate(DateTime.now());

    final performanceRecords =
        ItemsReportAnalysisBuilder.computePerformance(
          rows: _rows,
          salesRecords: _salesRecords,
          period: _period,
          businessNow: now,
          customRange: _customRange,
        );

    final best3 = ItemsReportAnalysisBuilder.getBest3(
      records: performanceRecords,
      metric: _metric,
    );
    final least3 = ItemsReportAnalysisBuilder.getLeast3(
      records: performanceRecords,
      metric: _metric,
    );

    final margins =
        ItemsReportAnalysisBuilder.computeProfitMargins(
          _rows,
        );
    final categoryDist =
        ItemsReportAnalysisBuilder.computeCategoryDistribution(
          rows: _rows,
          categories: _categories,
        );
    final departmentDist =
        ItemsReportAnalysisBuilder.computeDepartmentDistribution(
          rows: _rows,
          departments: _departments,
        );
    final recentItems =
        ItemsReportAnalysisBuilder.getNewlyCreatedItems(
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
        spacing: 10, // 10px spacing between cards/widgets
        children: [
          _buildHeaderBar(theme),
          _buildSummaryCards(theme, summary),
          _buildStockBreakdownBar(theme, summary),
          _buildMiddleSection(
            theme: theme,
            summary: summary,
            performanceRecords: performanceRecords,
            best3: best3,
            least3: least3,
            topMargin: margins.top3,
            leastMargin: margins.least3,
          ),
          _buildBottomSection(
            theme: theme,
            categoryDist: categoryDist,
            departmentDist: departmentDist,
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
          'Inventory Analytics & Performance',
          style: TextStyle(
            fontSize: theme.mobileTexts.b1.fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 6,
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
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 2,
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
            child: DropdownButton<ItemAnalysisPeriod>(
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
                  ItemAnalysisPeriod.values.map((p) {
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
                if (val == ItemAnalysisPeriod.custom) {
                  _pickCustomRange();
                } else {
                  setState(() {
                    _period = val;
                    _customRange = null;
                  });
                  if (val != ItemAnalysisPeriod.allTime) {
                    _load(refreshFromStore: false);
                  }
                }
              },
            ),
          ),
          if (_period == ItemAnalysisPeriod.custom &&
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
  // Section 4.2: Summary Statistics KPI Cards
  // ---------------------------------------------------------------------------
  Widget _buildSummaryCards(
    ThemeProvider theme,
    ItemsReportAnalysisSummary summary,
  ) {
    final isDesktop = widget.isDesktop;

    final cards = [
      _buildKpiCard(
        theme: theme,
        title: 'Stock Selling Value',
        value: _money(summary.totalStockSellingValue),
        subtitle: 'Total Catalog Worth',
        badgeText: 'Potential',
        badgeColor: theme.lightModeColor.prColor250,
        icon: Icons.storefront_rounded,
        iconBg: const Color(0xFFEEF2FF),
        iconColor: const Color(0xFF4338CA),
      ),
      _buildKpiCard(
        theme: theme,
        title: 'Stock Cost Value',
        value:
            _canSeeCost
                ? _money(summary.totalStockCostValue)
                : 'Restricted',
        subtitle:
            _canSeeCost
                ? 'Total Inventory Cost'
                : 'Permission Required',
        badgeText: _canSeeCost ? 'Cost Basis' : 'Locked',
        badgeColor: Colors.grey.shade600,
        icon: Icons.account_balance_wallet_rounded,
        iconBg: const Color(0xFFF3E8FF),
        iconColor: const Color(0xFF7E22CE),
      ),
      _buildKpiCard(
        theme: theme,
        title: 'Potential Profit',
        value:
            _canSeeCost
                ? _money(summary.totalPotentialProfit)
                : 'Restricted',
        subtitle:
            _canSeeCost
                ? 'Unrealized Gross Profit'
                : 'Permission Required',
        badgeText:
            _canSeeCost
                ? '↗ ${summary.overallMargin.toStringAsFixed(1)}%'
                : 'Restricted',
        badgeColor: const Color(0xFF059669),
        icon: Icons.trending_up_rounded,
        iconBg: const Color(0xFFECFDF5),
        iconColor: const Color(0xFF059669),
      ),
      _buildKpiCard(
        theme: theme,
        title: 'Available Stock Items',
        // Total Items: Both managed (available) and unmanaged items
        value:
            '${formatLargeNumberDouble(summary.totalDistinctItems.toDouble())} Items',
        subtitle:
            '${summary.managedCount} Managed • ${summary.unmanagedCount} Unmanaged',
        badgeText: '${summary.totalDistinctItems} Total',
        badgeColor: const Color(0xFF2563EB),
        icon: Icons.inventory_2_rounded,
        iconBg: const Color(0xFFEFF6FF),
        iconColor: const Color(0xFF2563EB),
      ),
    ];

    if (isDesktop) {
      return Row(
        spacing: 10, // 10px spacing between cards
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
              Text(
                title,
                style: TextStyle(
                  fontSize: theme.mobileTexts.b4.fontSize,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
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
  // Stock Availability Quick-Breakdown Pill Bar (Section 4.2.1 & 4.2.3)
  // ---------------------------------------------------------------------------
  Widget _buildStockBreakdownBar(
    ThemeProvider theme,
    ItemsReportAnalysisSummary summary,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
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
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: Color(0xFF16A34A),
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                'In Stock: ',
                style: TextStyle(
                  fontSize: theme.mobileTexts.b3.fontSize,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                '${summary.inStockCount}',
                style: TextStyle(
                  fontSize: theme.mobileTexts.b3.fontSize,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF16A34A),
                ),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFD97706),
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                'Low in Stock: ',
                style: TextStyle(
                  fontSize: theme.mobileTexts.b3.fontSize,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                '${summary.lowStockCount}',
                style: TextStyle(
                  fontSize: theme.mobileTexts.b3.fontSize,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFD97706),
                ),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cancel_outlined,
                color: Color(0xFFDC2626),
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                'Out of Stock: ',
                style: TextStyle(
                  fontSize: theme.mobileTexts.b3.fontSize,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                '${summary.outOfStockCount}',
                style: TextStyle(
                  fontSize: theme.mobileTexts.b3.fontSize,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFDC2626),
                ),
              ),
            ],
          ),
          Container(
            width: 1,
            height: 14,
            color: Colors.grey.shade300,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.tune_rounded,
                color: Colors.blueGrey,
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                'Managed: ${summary.managedCount}  •  Un-Managed: ${summary.unmanagedCount}',
                style: TextStyle(
                  fontSize: theme.mobileTexts.b3.fontSize,
                  color: Colors.blueGrey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Middle Section: Item Performance Analysis + Stock Donut Chart
  // ---------------------------------------------------------------------------
  Widget _buildMiddleSection({
    required ThemeProvider theme,
    required ItemsReportAnalysisSummary summary,
    required List<ItemPerformanceRecord> performanceRecords,
    required List<ItemPerformanceRecord> best3,
    required List<ItemPerformanceRecord> least3,
    required List<ItemProfitMarginRecord> topMargin,
    required List<ItemProfitMarginRecord> leastMargin,
  }) {
    final isDesktop = widget.isDesktop;

    final performanceCard = _buildPerformanceCard(
      theme: theme,
      performanceRecords: performanceRecords,
      best3: best3,
      least3: least3,
      topMargin: topMargin,
      leastMargin: leastMargin,
    );

    final donutCard = _buildStockDonutCard(
      theme: theme,
      summary: summary,
    );

    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10, // 10px spacing
        children: [
          Expanded(flex: 65, child: performanceCard),
          Expanded(flex: 35, child: donutCard),
        ],
      );
    } else {
      return Column(
        spacing: 10, // 10px spacing
        children: [performanceCard, donutCard],
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Performance & Profit Margin Card (Sections 4.3, 4.4, 4.5, 4.6)
  // ---------------------------------------------------------------------------
  Widget _buildPerformanceCard({
    required ThemeProvider theme,
    required List<ItemPerformanceRecord> performanceRecords,
    required List<ItemPerformanceRecord> best3,
    required List<ItemPerformanceRecord> least3,
    required List<ItemProfitMarginRecord> topMargin,
    required List<ItemProfitMarginRecord> leastMargin,
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
          // Header Row with Title, Metric Selector, and View Toggle
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'Item Performance & Margins',
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.b1.fontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    'Best & least performers for ${_period.label}',
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.b4.fontSize,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 0,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  border: Border.all(
                    color: Colors.grey.shade200,
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<
                    ItemPerformanceMetric
                  >(
                    value: _metric,
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      size: 16,
                    ),
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.b3.fontSize,
                      fontWeight: FontWeight.w600,
                      color:
                          theme.lightModeColor.prColor300,
                    ),
                    items:
                        ItemPerformanceMetric.values.map((
                          m,
                        ) {
                          return DropdownMenuItem(
                            value: m,
                            enabled:
                                m !=
                                    ItemPerformanceMetric
                                        .realizedProfit ||
                                _canSeeCost,
                            child: Text(
                              m.label +
                                  (m ==
                                              ItemPerformanceMetric
                                                  .realizedProfit &&
                                          !_canSeeCost
                                      ? ' (Locked)'
                                      : ''),
                              style: TextStyle(
                                fontSize:
                                    theme
                                        .mobileTexts
                                        .b4
                                        .fontSize,
                              ),
                            ),
                          );
                        }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _metric = val);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Visual Curve Chart
          _buildPerformersComparison(theme, best3, least3),
        ],
      ),
    );
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
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? Colors.white
                  : Colors.transparent,
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
            fontWeight:
                isSelected
                    ? FontWeight.bold
                    : FontWeight.w500,
            color:
                isSelected
                    ? theme.lightModeColor.prColor300
                    : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  // Best 3 and Least 3 Performers Row/Grid
  Widget _buildPerformersComparison(
    ThemeProvider theme,
    List<ItemPerformanceRecord> best3,
    List<ItemPerformanceRecord> least3,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stack = constraints.maxWidth < 550;
        final bestWidget = _buildRankingCard(
          theme: theme,
          title: 'Best 3 Performing Items',
          badgeText: 'Top Leaders',
          badgeColor: const Color(0xFF16A34A),
          icon: Icons.star_rounded,
          items: best3,
          isBest: true,
        );

        final leastWidget = _buildRankingCard(
          theme: theme,
          title: 'Least 3 Performing Items',
          badgeText: 'Needs Attention',
          badgeColor: const Color(0xFFD97706),
          icon: Icons.trending_down_rounded,
          items: least3,
          isBest: false,
        );

        if (stack) {
          return Column(
            spacing: 10, // 10px spacing
            children: [bestWidget, leastWidget],
          );
        } else {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10, // 10px spacing
            children: [
              Expanded(child: bestWidget),
              Expanded(child: leastWidget),
            ],
          );
        }
      },
    );
  }

  Widget _buildRankingCard({
    required ThemeProvider theme,
    required String title,
    required String badgeText,
    required Color badgeColor,
    required IconData icon,
    required List<ItemPerformanceRecord> items,
    required bool isBest,
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
                          theme.mobileTexts.b2.fontSize,
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
                  'No items available to rank',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: theme.mobileTexts.b3.fontSize,
                  ),
                ),
              ),
            )
          else
            Column(
              children: List.generate(items.length, (idx) {
                final it = items[idx];
                final rank = idx + 1;
                return _buildPerformerRow(
                  theme: theme,
                  rank: rank,
                  item: it,
                  isBest: isBest,
                );
              }),
            ),
        ],
      ),
    );
  }

  Widget _buildPerformerRow({
    required ThemeProvider theme,
    required int rank,
    required ItemPerformanceRecord item,
    required bool isBest,
  }) {
    final rankColor =
        isBest
            ? (rank == 1
                ? const Color(0xFFEAB308)
                : (rank == 2
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFFD97706)))
            : Colors.grey.shade500;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: rankColor.withAlpha(25),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$rank',
              style: TextStyle(
                fontSize: theme.mobileTexts.b4.fontSize,
                fontWeight: FontWeight.bold,
                color: rankColor,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b3.fontSize,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Unit: ${item.primaryUnit} • ${_money(item.sellingPrice)}',
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b5.fontSize,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item.formattedMetricValue(
                  metric: _metric,
                  formatMoney: _money,
                ),
                style: TextStyle(
                  fontSize: theme.mobileTexts.b4.fontSize,
                  fontWeight: FontWeight.bold,
                  color:
                      isBest
                          ? const Color(0xFF16A34A)
                          : Colors.black87,
                ),
              ),
              Text(
                '${formatLargeNumberDouble(item.unitsSold)} sold',
                style: TextStyle(
                  fontSize: theme.mobileTexts.b5.fontSize,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Donut Chart: Stock Level Distribution
  // ---------------------------------------------------------------------------
  Widget _buildStockDonutCard({
    required ThemeProvider theme,
    required ItemsReportAnalysisSummary summary,
  }) {
    final inStock = summary.inStockCount;
    final lowStock = summary.lowStockCount;
    final outOfStock = summary.outOfStockCount;
    final total = inStock + lowStock + outOfStock;

    final inStockPct =
        total > 0 ? (inStock / total) * 100 : 0.0;
    final lowStockPct =
        total > 0 ? (lowStock / total) * 100 : 0.0;
    final outStockPct =
        total > 0 ? (outOfStock / total) * 100 : 0.0;

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
            'Stock Classification',
            style: TextStyle(
              fontSize: theme.mobileTexts.b1.fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            'Inventory stock levels breakdown',
            style: TextStyle(
              fontSize: theme.mobileTexts.b4.fontSize,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 12),

          // Donut Chart with center label
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
                              if (inStock > 0)
                                PieChartSectionData(
                                  color: const Color(
                                    0xFF16A34A,
                                  ),
                                  value: inStock.toDouble(),
                                  radius: 20,
                                  showTitle: false,
                                ),
                              if (lowStock > 0)
                                PieChartSectionData(
                                  color: const Color(
                                    0xFFD97706,
                                  ),
                                  value:
                                      lowStock.toDouble(),
                                  radius: 20,
                                  showTitle: false,
                                ),
                              if (outOfStock > 0)
                                PieChartSectionData(
                                  color: const Color(
                                    0xFFDC2626,
                                  ),
                                  value:
                                      outOfStock.toDouble(),
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
                      '${summary.totalDistinctItems}',
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b1.fontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Total Items',
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

          // Legend below chart
          Column(
            spacing: 6,
            children: [
              _buildLegendRow(
                theme: theme,
                color: const Color(0xFF16A34A),
                label: 'In Stock',
                percentage: inStockPct,
                count: inStock,
              ),
              _buildLegendRow(
                theme: theme,
                color: const Color(0xFFD97706),
                label: 'Low in Stock',
                percentage: lowStockPct,
                count: lowStock,
              ),
              _buildLegendRow(
                theme: theme,
                color: const Color(0xFFDC2626),
                label: 'Out of Stock',
                percentage: outStockPct,
                count: outOfStock,
              ),
            ],
          ),
          const Divider(height: 18),
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text(
                    '${summary.managedCount}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize:
                          theme.mobileTexts.b2.fontSize,
                    ),
                  ),
                  Text(
                    'Managed Items',
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.b4.fontSize,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              Container(
                width: 1,
                height: 20,
                color: Colors.grey.shade200,
              ),
              Column(
                children: [
                  Text(
                    '${summary.unmanagedCount}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize:
                          theme.mobileTexts.b2.fontSize,
                    ),
                  ),
                  Text(
                    'Un-Managed',
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.b4.fontSize,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
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
    required int count,
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
          '${percentage.toStringAsFixed(0)}%  •  $count items',
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
  // Bottom Section: Category/Department Tables + Newly Created Items
  // ---------------------------------------------------------------------------
  Widget _buildBottomSection({
    required ThemeProvider theme,
    required List<CategoryDistributionItem> categoryDist,
    required List<DepartmentDistributionItem>
    departmentDist,
    required List<ItemsReportRow> recentItems,
  }) {
    final isDesktop = widget.isDesktop;

    final distribCard = _buildDistributionTableCard(
      theme: theme,
      categoryDist: categoryDist,
      departmentDist: departmentDist,
    );

    final recentCard = _buildNewlyCreatedItemsCard(
      theme: theme,
      recentItems: recentItems,
    );

    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10, // 10px spacing
        children: [
          Expanded(flex: 55, child: distribCard),
          Expanded(flex: 45, child: recentCard),
        ],
      );
    } else {
      return Column(
        spacing: 10, // 10px spacing
        children: [distribCard, recentCard],
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Distribution Mini Table Card (Sections 4.7 & 4.8)
  // Responsive selector: Tab buttons on desktop; PopupMenu / Dropdown on mobile!
  // ---------------------------------------------------------------------------
  Widget _buildDistributionTableCard({
    required ThemeProvider theme,
    required List<CategoryDistributionItem> categoryDist,
    required List<DepartmentDistributionItem>
    departmentDist,
  }) {
    final showDept = _departmentsEnabled;
    final isDesktop = widget.isDesktop;

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
          // Header with responsive switch: Button on desktop, PopupMenu on mobile
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Item Distribution',
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b1.fontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Click row to filter Main Table',
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b4.fontSize,
                        color: Colors.grey.shade500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (showDept) ...[
                if (isDesktop)
                  // Desktop tab button switch
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(
                        6,
                      ),
                    ),
                    padding: const EdgeInsets.all(2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _tabButton(
                          title: 'Category',
                          isSelected: _distribTabIndex == 0,
                          onTap:
                              () => setState(
                                () => _distribTabIndex = 0,
                              ),
                          theme: theme,
                        ),
                        _tabButton(
                          title: 'Department',
                          isSelected: _distribTabIndex == 1,
                          onTap:
                              () => setState(
                                () => _distribTabIndex = 1,
                              ),
                          theme: theme,
                        ),
                      ],
                    ),
                  )
                else
                  // Mobile: PopupMenuButton / Dropdown (prevents horizontal layout issues)
                  PopupMenuButton<int>(
                    offset: const Offset(0, 32),
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        8,
                      ),
                    ),
                    onSelected:
                        (val) => setState(
                          () => _distribTabIndex = val,
                        ),
                    itemBuilder:
                        (context) => [
                          PopupMenuItem(
                            value: 0,
                            child: Text(
                              'Category',
                              style: TextStyle(
                                fontSize:
                                    theme
                                        .mobileTexts
                                        .b3
                                        .fontSize,
                                fontWeight:
                                    _distribTabIndex == 0
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                color:
                                    _distribTabIndex == 0
                                        ? theme
                                            .lightModeColor
                                            .prColor300
                                        : Colors.black87,
                              ),
                            ),
                          ),
                          PopupMenuItem(
                            value: 1,
                            child: Text(
                              'Department',
                              style: TextStyle(
                                fontSize:
                                    theme
                                        .mobileTexts
                                        .b3
                                        .fontSize,
                                fontWeight:
                                    _distribTabIndex == 1
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                color:
                                    _distribTabIndex == 1
                                        ? theme
                                            .lightModeColor
                                            .prColor300
                                        : Colors.black87,
                              ),
                            ),
                          ),
                        ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(
                          6,
                        ),
                        border: Border.all(
                          color: Colors.grey.shade200,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _distribTabIndex == 0
                                ? 'Category'
                                : 'Department',
                            style: TextStyle(
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b4
                                      .fontSize,
                              fontWeight: FontWeight.bold,
                              color:
                                  theme
                                      .lightModeColor
                                      .prColor300,
                            ),
                          ),
                          const SizedBox(width: 3),
                          Icon(
                            Icons
                                .keyboard_arrow_down_rounded,
                            size: 15,
                            color:
                                theme
                                    .lightModeColor
                                    .prColor300,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ],
          ),
          const SizedBox(height: 10),

          // Table Content
          if (_distribTabIndex == 0 || !showDept)
            _buildCategoryTable(theme, categoryDist)
          else
            _buildDepartmentTable(theme, departmentDist),
        ],
      ),
    );
  }

  Widget _buildCategoryTable(
    ThemeProvider theme,
    List<CategoryDistributionItem> list,
  ) {
    if (list.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            'No categories available',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: theme.mobileTexts.b3.fontSize,
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        // Table Header
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 6,
            horizontal: 4,
          ),
          child: Row(
            children: [
              SizedBox(
                width: 24,
                child: Text(
                  '#',
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b4.fontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Text(
                  'Category',
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b4.fontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
              if (screenWidth(context) > mobileScreen) ...[
                Expanded(
                  flex: 3,
                  child: Text(
                    'Proportion',
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.b4.fontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ),
              ],
              Text(
                'Items',
                textAlign: TextAlign.end,
                style: TextStyle(
                  fontSize: theme.mobileTexts.b4.fontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(width: 18),
            ],
          ),
        ),
        const Divider(height: 1),
        // Rows
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: list.length,
          separatorBuilder:
              (_, __) => Divider(
                height: 1,
                color: Colors.grey.shade100,
              ),
          itemBuilder: (context, idx) {
            final item = list[idx];
            return Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(6),
                mouseCursor: SystemMouseCursors.click,
                onTap: () {
                  final catKey =
                      item.isOthers
                          ? itemsReportNoneKey
                          : item.categoryUuid;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => ItemsReportMainPage(
                            initialCategoryKey: catKey,
                          ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 4,
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 24,
                        child: Text(
                          '${item.index}',
                          style: TextStyle(
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b4
                                    .fontSize,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                item.categoryName,
                                style: TextStyle(
                                  fontSize:
                                      theme
                                          .mobileTexts
                                          .b3
                                          .fontSize,
                                  fontWeight:
                                      FontWeight.bold,
                                  color:
                                      item.isOthers
                                          ? Colors
                                              .grey
                                              .shade700
                                          : theme
                                              .lightModeColor
                                              .prColor300,
                                ),
                                maxLines: 1,
                                overflow:
                                    TextOverflow.ellipsis,
                              ),
                            ),
                            if (item.isOthers) ...[
                              const SizedBox(width: 4),
                              Icon(
                                Icons.help_outline,
                                size: 12,
                                color: Colors.grey.shade500,
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (screenWidth(context) >
                          mobileScreen) ...[
                        Expanded(
                          flex: 3,
                          child: Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(
                                        3,
                                      ),
                                  child: LinearProgressIndicator(
                                    value:
                                        (item.percentage /
                                                100)
                                            .clamp(
                                              0.0,
                                              1.0,
                                            ),
                                    minHeight: 5,
                                    backgroundColor:
                                        Colors
                                            .grey
                                            .shade100,
                                    valueColor:
                                        const AlwaysStoppedAnimation<
                                          Color
                                        >(
                                          Color(0xFF3B82F6),
                                        ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${item.percentage.toStringAsFixed(0)}%',
                                style: TextStyle(
                                  fontSize:
                                      theme
                                          .mobileTexts
                                          .b4
                                          .fontSize,
                                  color:
                                      Colors.grey.shade600,
                                  fontWeight:
                                      FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color:
                              theme
                                  .lightModeColor
                                  .prColor50,
                          borderRadius:
                              BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${item.itemCount}',
                          style: TextStyle(
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b4
                                    .fontSize,
                            fontWeight: FontWeight.bold,
                            color:
                                theme
                                    .lightModeColor
                                    .prColor300,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 10,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDepartmentTable(
    ThemeProvider theme,
    List<DepartmentDistributionItem> list,
  ) {
    if (list.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            'No departments available',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: theme.mobileTexts.b3.fontSize,
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        // Table Header
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 6,
            horizontal: 4,
          ),
          child: Row(
            children: [
              SizedBox(
                width: 24,
                child: Text(
                  '#',
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b4.fontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Text(
                  'Department',
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b4.fontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
              if (screenWidth(context) > mobileScreen) ...[
                Expanded(
                  flex: 3,
                  child: Text(
                    'Proportion',
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.b4.fontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ),
              ],
              Text(
                'Items',
                textAlign: TextAlign.end,
                style: TextStyle(
                  fontSize: theme.mobileTexts.b4.fontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(width: 18),
            ],
          ),
        ),
        const Divider(height: 1),
        // Rows
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: list.length,
          separatorBuilder:
              (_, __) => Divider(
                height: 1,
                color: Colors.grey.shade100,
              ),
          itemBuilder: (context, idx) {
            final item = list[idx];
            return Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(6),
                mouseCursor: SystemMouseCursors.click,
                onTap: () {
                  final deptKey =
                      item.isOthers
                          ? itemsReportNoneKey
                          : item.departmentUuid;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => ItemsReportMainPage(
                            initialDepartmentKey: deptKey,
                          ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 4,
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 24,
                        child: Text(
                          '${item.index}',
                          style: TextStyle(
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b4
                                    .fontSize,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                item.departmentName,
                                style: TextStyle(
                                  fontSize:
                                      theme
                                          .mobileTexts
                                          .b3
                                          .fontSize,
                                  fontWeight:
                                      FontWeight.bold,
                                  color:
                                      item.isOthers
                                          ? Colors
                                              .grey
                                              .shade700
                                          : theme
                                              .lightModeColor
                                              .prColor300,
                                ),
                                maxLines: 1,
                                overflow:
                                    TextOverflow.ellipsis,
                              ),
                            ),
                            if (item.isOthers) ...[
                              const SizedBox(width: 4),
                              Icon(
                                Icons.help_outline,
                                size: 12,
                                color: Colors.grey.shade500,
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (screenWidth(context) >
                          mobileScreen) ...[
                        Expanded(
                          flex: 3,
                          child: Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(
                                        3,
                                      ),
                                  child: LinearProgressIndicator(
                                    value:
                                        (item.percentage /
                                                100)
                                            .clamp(
                                              0.0,
                                              1.0,
                                            ),
                                    minHeight: 5,
                                    backgroundColor:
                                        Colors
                                            .grey
                                            .shade100,
                                    valueColor:
                                        const AlwaysStoppedAnimation<
                                          Color
                                        >(
                                          Color(0xFF6366F1),
                                        ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${item.percentage.toStringAsFixed(0)}%',
                                style: TextStyle(
                                  fontSize:
                                      theme
                                          .mobileTexts
                                          .b4
                                          .fontSize,
                                  color:
                                      Colors.grey.shade600,
                                  fontWeight:
                                      FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FF),
                          borderRadius:
                              BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${item.itemCount}',
                          style: TextStyle(
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b4
                                    .fontSize,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF4338CA),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 10,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Newly Created Items Card (Section 4.9)
  // ---------------------------------------------------------------------------
  Widget _buildNewlyCreatedItemsCard({
    required ThemeProvider theme,
    required List<ItemsReportRow> recentItems,
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
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'Newly Created Items',
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.b1.fontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    'Latest additions in the past 7 days',
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.b4.fontSize,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  recentItems.isEmpty
                      ? '0 items'
                      : 'Top ${recentItems.length}',
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
              padding: const EdgeInsets.symmetric(
                vertical: 16,
              ),
              child: Center(
                child: Text(
                  'No items created within the past week',
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
                  (_, __) => Divider(
                    height: 1,
                    color: Colors.grey.shade100,
                  ),
              itemBuilder: (context, idx) {
                final item = recentItems[idx];
                final initial =
                    item.name.isNotEmpty
                        ? item.name[0].toUpperCase()
                        : 'P';
                final dateStr =
                    item.createdAt != null
                        ? formatDateTime(item.createdAt!)
                        : 'Date not set';

                Color stockColor;
                String stockLabel;
                if (!item.isManaged) {
                  stockColor = Colors.blueGrey;
                  stockLabel = 'Unmanaged';
                } else if (item.stockLevel ==
                    StockLevelFilter.inStock) {
                  stockColor = const Color(0xFF16A34A);
                  stockLabel =
                      '${formatLargeNumberDouble(item.quantity ?? 0)} ${item.primaryUnit}';
                } else if (item.stockLevel ==
                    StockLevelFilter.lowStock) {
                  stockColor = const Color(0xFFD97706);
                  stockLabel =
                      '${formatLargeNumberDouble(item.quantity ?? 0)} ${item.primaryUnit}';
                } else {
                  stockColor = const Color(0xFFDC2626);
                  stockLabel = 'Out of Stock';
                }

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(6),
                    mouseCursor: SystemMouseCursors.click,
                    onTap: () {
                      if (item.uuid.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    ProductDetailsPage(
                                      productUuid:
                                          item.uuid,
                                    ),
                          ),
                        ).then((_) {
                          if (mounted) {
                            _load(refreshFromStore: false);
                          }
                        });
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 4,
                      ),
                      child: Row(
                        children: [
                          if (screenWidth(context) >
                              mobileScreen) ...[
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color:
                                    theme
                                        .lightModeColor
                                        .prColor50,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                initial,
                                style: TextStyle(
                                  fontSize:
                                      theme
                                          .mobileTexts
                                          .b2
                                          .fontSize,
                                  fontWeight:
                                      FontWeight.bold,
                                  color:
                                      theme
                                          .lightModeColor
                                          .prColor300,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: TextStyle(
                                    fontSize:
                                        theme
                                            .mobileTexts
                                            .b3
                                            .fontSize,
                                    fontWeight:
                                        FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow:
                                      TextOverflow.ellipsis,
                                ),
                                Text(
                                  '$dateStr  •  ${item.primaryUnit}  •  ${_money(item.sellingPrice)}',
                                  style: TextStyle(
                                    fontSize:
                                        theme
                                            .mobileTexts
                                            .b4
                                            .fontSize,
                                    color:
                                        Colors
                                            .grey
                                            .shade500,
                                  ),
                                  maxLines: 1,
                                  overflow:
                                      TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding:
                                const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                            decoration: BoxDecoration(
                              color: stockColor.withAlpha(
                                20,
                              ),
                              borderRadius:
                                  BorderRadius.circular(8),
                            ),
                            child: Text(
                              stockLabel,
                              style: TextStyle(
                                fontSize:
                                    theme
                                        .mobileTexts
                                        .b4
                                        .fontSize,
                                fontWeight: FontWeight.bold,
                                color: stockColor,
                              ),
                            ),
                          ),
                          if (screenWidth(context) >
                              mobileScreen) ...[
                            const SizedBox(width: 4),
                            IconButton(
                              icon: const Icon(
                                Icons.table_view_outlined,
                                size: 15,
                                color: Colors.grey,
                              ),
                              tooltip: 'Find in Main Table',
                              padding: EdgeInsets.zero,
                              constraints:
                                  const BoxConstraints(
                                    minWidth: 24,
                                    minHeight: 24,
                                  ),
                              mouseCursor:
                                  SystemMouseCursors.click,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            ItemsReportMainPage(
                                              initialSearch:
                                                  item.name,
                                            ),
                                  ),
                                );
                              },
                            ),
                          ],
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
