import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/report/components/report_trend_chart.dart';
import 'package:stockall/pages/report/purchase_report/purchase_report_table/class/purchase_report_table_logic.dart';
import 'package:stockall/pages/report/purchase_report/purchase_report_table/components/purchase_report_table_view.dart';
import 'package:stockall/pages/report/purchase_report/purchase_report_table/purchase_report_table_page.dart';
import 'package:stockall/pages/report/purchase_report/purchase_summary/class/purchase_summary_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/components/receipts_report_filter_widgets.dart';
import 'package:stockall/providers/theme_provider.dart';

/// Shared body of the Purchase Summary and Analysis page (desktop +
/// mobile). Navigation is one way: KPIs, ranking rows and
/// breakdown rows open the purchase table with matching filters
/// and the current period.
class PurchaseSummaryView extends StatefulWidget {
  final bool isDesktop;
  final ReceiptsReportPeriod? initialPeriod;

  /// Null in the app: [PurchaseReportEnv.live] is used.
  final PurchaseReportEnv? env;

  const PurchaseSummaryView({
    super.key,
    required this.isDesktop,
    this.initialPeriod,
    this.env,
  });

  @override
  State<PurchaseSummaryView> createState() =>
      _PurchaseSummaryViewState();
}

class _PurchaseSummaryViewState extends State<PurchaseSummaryView> {
  late final PurchaseReportEnv _env;
  late ReceiptsReportPeriod _period;
  PurchaseBreakdownTab _tab = PurchaseBreakdownTab.suppliers;

  /// Null: the built order (spend for groups, fixed otherwise).
  PurchaseBreakdownSortField? _sortField;
  bool _ascending = false;

  bool _loading = true;
  String? _error;
  PurchaseSummaryResult? _result;
  String _signature = '';

  /// The analysis has no filters of its own.
  final PurchaseReportFilters _base = PurchaseReportFilters();

  static const Color _paidColor = Color(0xFF059669);
  static const Color _partlyColor = Color(0xFFD97706);
  static const Color _unpaidColor = Color(0xFFDC2626);

  @override
  void initState() {
    super.initState();
    _env = widget.env ?? PurchaseReportEnv.live();
    _period =
        widget.initialPeriod ?? ReceiptsReportPeriod.today();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load(refreshFromStore: false);
    });
  }

  // ---------------------------------------------------------------
  // data
  // ---------------------------------------------------------------

  bool get _departmentsEnabled => _env.departmentsEnabled();

  Future<void> _load({required bool refreshFromStore}) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _env.load(
        context,
        refreshFromStore: refreshFromStore,
      );
      _rebuild();
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

  void _rebuild() {
    final rows = PurchaseReportRowBuilder.buildAll(
      purchases: _env.purchases(),
      legacyLines: _env.legacyLines(),
      supplierNames: _env.supplierNames(),
      pendingDeletedUuids: _env.pendingDeletedUuids(),
    );
    _result = PurchaseSummaryBuilder.build(
      rows: rows,
      period: _period,
      departmentsEnabled: _departmentsEnabled,
    );
    _signature = _env.signature();
  }

  void _setPeriod(ReceiptsReportPeriod p) {
    setState(() {
      _period = p;
      try {
        _rebuild();
        _error = null;
      } catch (e) {
        _error = e.toString();
      }
    });
  }

  Future<void> _pushTable(
    BuildContext context,
    PurchaseReportFilters filters,
    ReceiptsReportPeriod period,
  ) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => PurchaseReportTablePage(
              initialFilters: filters,
              initialPeriod: period,
            ),
      ),
    );
  }

  Future<void> _openTable(PurchaseReportFilters filters) async {
    final open = _env.openTable ?? _pushTable;
    await open(context, filters, _period);
    // Picks up payments or edits made from the table.
    if (mounted) {
      setState(() {
        try {
          _rebuild();
          _error = null;
        } catch (e) {
          _error = e.toString();
        }
      });
    }
  }

  void _openAll() => _openTable(_base.copy());

  void _openStatus(PurchaseStatus status) => _openTable(
    PurchaseSummaryBuilder.handoff(_base, status: status),
  );

  void _openSupplier(String key) => _openTable(
    PurchaseSummaryBuilder.handoff(_base, supplierKey: key),
  );

  // ---------------------------------------------------------------
  // formatting
  // ---------------------------------------------------------------

  String _money(num v) => _env.money(context, v);

  String _percent(double v) =>
      '${formatLargeNumberDouble(double.parse(v.toStringAsFixed(2)))}%';

  BoxDecoration get _card => BoxDecoration(
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
  );

  Widget _title(ThemeProvider theme, String text, String sub) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: theme.mobileTexts.b1.fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          sub,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: theme.mobileTexts.b4.fontSize,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  Widget _emptyText(ThemeProvider theme, String text) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: theme.mobileTexts.b3.fontSize,
            color: Colors.grey.shade500,
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------
  // build
  // ---------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = returnTheme(context);
    // Listen, so purchases, payments and sync update the analysis.
    _env.listen(context);

    if (!_loading && _error == null) {
      final sig = _env.signature();
      if (sig != _signature) {
        try {
          _rebuild();
        } catch (e) {
          _error = e.toString();
        }
      }
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 252, 253, 255),
      appBar: appBar(
        context: context,
        title: 'Purchase Summary and Analysis',
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
      body: _body(theme),
    );
  }

  Widget _body(ThemeProvider theme) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    final result = _result;
    if (_error != null || result == null) {
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
              'The analysis could not be generated.',
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
    final gap = SizedBox(height: widget.isDesktop ? 16 : 12);
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: widget.isDesktop ? 20 : 12,
        vertical: 10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: ReceiptsReportPeriodButton(
              theme: theme,
              period: _period,
              enabled: _env.canPickDate(),
              onChanged: _setPeriod,
            ),
          ),
          if (_period.isAllTime) _note(),
          gap,
          _kpis(theme, result.stats),
          gap,
          _pair(
            _trendCard(theme, result),
            _activityCard(theme, result),
          ),
          gap,
          _pair(
            _ranking(
              theme,
              title: 'Top 3 Suppliers',
              subtitle: 'Highest spend in this period',
              keyPrefix: 'purchase-top-supplier',
              groups: result.topSuppliers,
            ),
            _ranking(
              theme,
              title: 'Least 3 Suppliers',
              subtitle: 'Lowest spend in this period',
              keyPrefix: 'purchase-least-supplier',
              groups: result.leastSuppliers,
            ),
          ),
          gap,
          _breakdown(theme, result),
          gap,
        ],
      ),
    );
  }

  /// Side by side on desktop, stacked on mobile.
  Widget _pair(Widget a, Widget b) {
    if (widget.isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: a),
          const SizedBox(width: 12),
          Expanded(child: b),
        ],
      );
    }
    return Column(children: [a, const SizedBox(height: 12), b]);
  }

  Widget _note() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
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
              'All time covers the purchases loaded on this device.',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------
  // KPIs
  // ---------------------------------------------------------------

  Widget _kpis(ThemeProvider theme, PurchaseSummaryStats s) {
    final cards = <Widget>[
      _kpi(
        theme,
        id: 'purchases',
        title: 'Total Purchases',
        value: '${s.totalPurchases}',
        subtitle: 'Purchases in this period',
        icon: Icons.shopping_bag_outlined,
        color: const Color(0xFF7E22CE),
        onTap: _openAll,
      ),
      _kpi(
        theme,
        id: 'spend',
        title: 'Total Spend',
        value: _money(s.totalSpend),
        subtitle: 'Total of the purchases',
        icon: Icons.receipt_long_rounded,
        color: const Color(0xFF2563EB),
        onTap: _openAll,
      ),
      _kpi(
        theme,
        id: 'paid',
        title: 'Total Paid',
        value: _money(s.totalPaid),
        subtitle: 'Paid to suppliers',
        icon: Icons.payments_outlined,
        color: const Color(0xFF0891B2),
        onTap: _openAll,
      ),
      _kpi(
        theme,
        id: 'outstanding',
        title: 'Outstanding Balance',
        value: _money(s.totalOutstanding),
        subtitle: 'Still owed to suppliers',
        icon: Icons.account_balance_wallet_outlined,
        color: _unpaidColor,
        onTap: _openAll,
      ),
      _kpi(
        theme,
        id: 'average',
        title: 'Average Purchase Value',
        value: _money(s.averagePurchaseValue),
        subtitle: 'Spend per purchase',
        icon: Icons.analytics_outlined,
        color: const Color(0xFF4F46E5),
        onTap: _openAll,
      ),
      _kpi(
        theme,
        id: 'items',
        title: 'Items Purchased',
        value: formatLargeNumberDouble(s.totalItems),
        subtitle:
            s.itemsUnknownCount > 0
                ? '${s.itemsUnknownCount} without line data'
                : 'In the units bought',
        icon: Icons.inventory_2_outlined,
        color: const Color(0xFF0D9488),
        onTap: _openAll,
      ),
      _kpi(
        theme,
        id: 'suppliers',
        title: 'Suppliers Used',
        value: '${s.distinctSuppliers}',
        subtitle:
            s.noSupplierPurchases > 0
                ? '+${s.noSupplierPurchases} with no supplier'
                : 'Distinct suppliers',
        icon: Icons.local_shipping_outlined,
        color: const Color(0xFFEA580C),
        onTap: _openAll,
      ),
      _kpi(
        theme,
        id: 'staff',
        title: 'Staff Involved',
        value: '${s.distinctStaff}',
        subtitle:
            s.noStaffPurchases > 0
                ? '+${s.noStaffPurchases} with no staff'
                : 'Distinct staff',
        icon: Icons.people_outline_rounded,
        color: const Color(0xFF64748B),
        onTap: _openAll,
      ),
      for (final st in PurchaseStatus.values)
        _kpi(
          theme,
          id: 'status-${st.name}',
          title: st.label,
          value: '${s.statusCount(st)}',
          subtitle: 'Purchases ${st.label.toLowerCase()}',
          icon: _statusIcon(st),
          color: _statusColor(st),
          onTap: () => _openStatus(st),
        ),
      if (s.overpaidCount > 0)
        _kpi(
          theme,
          id: 'overpaid',
          title: 'Overpaid',
          value: '${s.overpaidCount}',
          subtitle: 'Paid more than the total',
          icon: Icons.warning_amber_rounded,
          color: Colors.orange.shade800,
          onTap: _openAll,
        ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 10.0;
        final perRow = widget.isDesktop ? 4 : 2;
        final width =
            (constraints.maxWidth - spacing * (perRow - 1)) /
            perRow;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final c in cards) SizedBox(width: width, child: c),
          ],
        );
      },
    );
  }

  static Color _statusColor(PurchaseStatus s) {
    switch (s) {
      case PurchaseStatus.paid:
        return _paidColor;
      case PurchaseStatus.partlyPaid:
        return _partlyColor;
      case PurchaseStatus.unpaid:
        return _unpaidColor;
    }
  }

  static IconData _statusIcon(PurchaseStatus s) {
    switch (s) {
      case PurchaseStatus.paid:
        return Icons.check_circle_outline_rounded;
      case PurchaseStatus.partlyPaid:
        return Icons.timelapse_rounded;
      case PurchaseStatus.unpaid:
        return Icons.highlight_off_rounded;
    }
  }

  Widget _kpi(
    ThemeProvider theme, {
    required String id,
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      key: ValueKey('purchase-kpi-$id'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: _card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              spacing: 8,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: color.withAlpha(25),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(icon, size: 16, color: color),
                ),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: theme.mobileTexts.b4.fontSize,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
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
            if (screenWidth(context) > mobileScreen)
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: theme.mobileTexts.b4.fontSize,
                  color: Colors.grey.shade500,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------
  // charts
  // ---------------------------------------------------------------

  Widget _chartCard(
    ThemeProvider theme, {
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [_title(theme, title, subtitle), child],
      ),
    );
  }

  Widget _trendCard(ThemeProvider theme, PurchaseSummaryResult r) {
    final spendColor = theme.lightModeColor.prColor300;
    const paidColor = _paidColor;
    final trend = r.trend;
    final subtitle =
        '${reportTrendIntervalLabel(r.interval)}, by business day';
    if (trend.isEmpty) {
      return _chartCard(
        theme,
        title: 'Spend Trend',
        subtitle: subtitle,
        child: _emptyText(theme, 'No purchases in this period.'),
      );
    }
    return _chartCard(
      theme,
      title: 'Spend Trend',
      subtitle: subtitle,
      child: ReportTrendChart(
        starts: [for (final p in trend) p.start],
        interval: r.interval,
        money: _money,
        series: [
          ReportTrendSeries(
            label: 'Spend',
            color: spendColor,
            values: [for (final p in trend) p.spend],
          ),
          ReportTrendSeries(
            label: 'Paid',
            color: paidColor,
            values: [for (final p in trend) p.paid],
          ),
        ],
      ),
    );
  }

  Widget _activityCard(
    ThemeProvider theme,
    PurchaseSummaryResult r,
  ) {
    final trend = r.trend;
    final subtitle =
        '${reportTrendIntervalLabel(r.interval)} '
        'purchase counts by status';
    if (trend.isEmpty) {
      return _chartCard(
        theme,
        title: 'Purchase Activity',
        subtitle: subtitle,
        child: _emptyText(theme, 'No purchases in this period.'),
      );
    }
    double maxY = 1;
    for (final p in trend) {
      maxY = math.max(maxY, p.purchaseCount.toDouble());
    }
    final barWidth =
        trend.length > 40 ? 3.0 : (trend.length > 20 ? 6.0 : 10.0);

    BarChartGroupData group(int i) {
      final p = trend[i];
      final parts = [
        (p.paidCount, _paidColor),
        (p.partlyPaidCount, _partlyColor),
        (p.unpaidCount, _unpaidColor),
      ];
      final stack = <BarChartRodStackItem>[];
      double from = 0;
      for (final (count, color) in parts) {
        if (count == 0) continue;
        stack.add(BarChartRodStackItem(from, from + count, color));
        from += count;
      }
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: from,
            width: barWidth,
            color: Colors.transparent,
            rodStackItems: stack,
            borderRadius: BorderRadius.circular(2),
          ),
        ],
      );
    }

    return _chartCard(
      theme,
      title: 'Purchase Activity',
      subtitle: subtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          ReportChartLegend(
            items: [
              for (final s in PurchaseStatus.values)
                (s.label, _statusColor(s)),
            ],
          ),
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                maxY: maxY * 1.15,
                gridData: const FlGridData(drawVerticalLine: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(),
                  rightTitles: const AxisTitles(),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (value, meta) {
                        if (value != value.roundToDouble()) {
                          return const SizedBox.shrink();
                        }
                        return SideTitleWidget(
                          meta: meta,
                          child: Text(
                            value.toStringAsFixed(0),
                            style: const TextStyle(fontSize: 9),
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      getTitlesWidget: reportTrendBottomTitle(
                        [for (final p in r.trend) p.start],
                        r.interval,
                      ),
                    ),
                  ),
                ),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => Colors.white,
                    getTooltipItem: (group, _, rod, _) {
                      final p = trend[group.x];
                      return BarTooltipItem(
                        '${reportTrendBucketLabel(r.interval, p.start)}\n'
                        'Paid: ${p.paidCount}\n'
                        'Partly Paid: ${p.partlyPaidCount}\n'
                        'Unpaid: ${p.unpaidCount}',
                        const TextStyle(
                          fontSize: 10,
                          color: Colors.black87,
                        ),
                      );
                    },
                  ),
                ),
                barGroups: [
                  for (var i = 0; i < trend.length; i++) group(i),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------
  // top / least suppliers
  // ---------------------------------------------------------------

  Widget _ranking(
    ThemeProvider theme, {
    required String title,
    required String subtitle,
    required String keyPrefix,
    required List<PurchaseSummaryGroup> groups,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title(theme, title, subtitle),
          const SizedBox(height: 8),
          if (groups.isEmpty)
            _emptyText(theme, 'No supplier in this period.'),
          for (var i = 0; i < groups.length; i++)
            _rankRow(theme, keyPrefix, i + 1, groups[i]),
        ],
      ),
    );
  }

  Widget _rankRow(
    ThemeProvider theme,
    String keyPrefix,
    int rank,
    PurchaseSummaryGroup g,
  ) {
    return InkWell(
      key: ValueKey('$keyPrefix-${g.key}'),
      onTap: () => _openSupplier(g.key),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
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
          spacing: 10,
          children: [
            Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color:
                    rank == 1
                        ? const Color(0xFFFEF3C7)
                        : const Color(0xFFF3F4F6),
                shape: BoxShape.circle,
              ),
              child: Text(
                '$rank',
                style: TextStyle(
                  fontSize: theme.mobileTexts.b4.fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    g.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: theme.mobileTexts.b3.fontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    '${g.purchaseCount} purchases · Paid ${_money(g.paid)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: theme.mobileTexts.b4.fontSize,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  _money(g.spend),
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b3.fontSize,
                    fontWeight: FontWeight.bold,
                    color: theme.lightModeColor.prColor300,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------
  // breakdown tables
  // ---------------------------------------------------------------

  List<PurchaseBreakdownTab> get _tabs => [
    PurchaseBreakdownTab.suppliers,
    PurchaseBreakdownTab.staff,
    if (_departmentsEnabled) PurchaseBreakdownTab.departments,
    PurchaseBreakdownTab.status,
    PurchaseBreakdownTab.channel,
  ];

  void _setTab(PurchaseBreakdownTab t) {
    setState(() {
      _tab = t;
      // Each tab starts in its built order.
      _sortField = null;
      _ascending = false;
    });
  }

  void _setSort(PurchaseBreakdownSortField f) {
    setState(() {
      if (_sortField == f) {
        _ascending = !_ascending;
      } else {
        _sortField = f;
        // Names A-Z first; counts, amounts and dates largest first.
        _ascending = f == PurchaseBreakdownSortField.name;
      }
    });
  }

  Widget _breakdown(
    ThemeProvider theme,
    PurchaseSummaryResult result,
  ) {
    final tabs = _tabs;
    final tab = tabs.contains(_tab) ? _tab : tabs.first;
    final rows = PurchaseSummaryBuilder.sortBreakdown(
      PurchaseSummaryBuilder.breakdown(result, tab, base: _base),
      field: _sortField,
      ascending: _ascending,
    );

    final cols =
        <({String label, double width, PurchaseBreakdownSortField sort})>[
          (
            label: tab.label,
            width: 200,
            sort: PurchaseBreakdownSortField.name,
          ),
          (
            label: 'Purchases',
            width: 110,
            sort: PurchaseBreakdownSortField.count,
          ),
          (
            label: 'Spend',
            width: 140,
            sort: PurchaseBreakdownSortField.spend,
          ),
          (
            label: 'Paid',
            width: 130,
            sort: PurchaseBreakdownSortField.paid,
          ),
          (
            label: 'Balance',
            width: 130,
            sort: PurchaseBreakdownSortField.balance,
          ),
          if (tab.isGroupTab)
            (
              label: 'Last purchase',
              width: 140,
              sort: PurchaseBreakdownSortField.lastDate,
            ),
          (
            label: 'Share',
            width: 100,
            sort: PurchaseBreakdownSortField.share,
          ),
        ];

    Widget cell(double width, Widget child, {bool start = false}) {
      return SizedBox(
        width: width,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Align(
            alignment: start ? Alignment.centerLeft : Alignment.center,
            child: child,
          ),
        ),
      );
    }

    Widget txt(String s, {bool bold = false, Color? color}) => Text(
      s,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: theme.mobileTexts.b3.fontSize,
        fontWeight: bold ? FontWeight.bold : FontWeight.w500,
        color: color ?? Colors.black87,
      ),
    );

    Widget header(
      ({String label, double width, PurchaseBreakdownSortField sort}) c,
      bool start,
    ) {
      final accent = theme.lightModeColor.prColor300;
      final sorted = _sortField == c.sort;
      return InkWell(
        key: ValueKey('purchase-sort-${c.sort.name}'),
        mouseCursor: SystemMouseCursors.click,
        onTap: () => _setSort(c.sort),
        child: cell(
          c.width,
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 3,
            children: [
              Flexible(
                child: txt(
                  c.label,
                  bold: true,
                  color: sorted ? accent : null,
                ),
              ),
              Icon(
                sorted
                    ? (_ascending
                        ? Icons.arrow_upward_rounded
                        : Icons.arrow_downward_rounded)
                    : Icons.unfold_more_rounded,
                size: 14,
                color: sorted ? accent : Colors.grey,
              ),
            ],
          ),
          start: start,
        ),
      );
    }

    Widget rowWidget(PurchaseBreakdownRow r, int i) {
      final values = <Widget>[
        txt(
          r.label,
          bold: true,
          color: r.isNone ? Colors.grey : null,
        ),
        txt('${r.count}'),
        txt(_money(r.spend), bold: true),
        txt(_money(r.paid)),
        txt(
          _money(r.balance),
          color: r.balance > 0 ? _unpaidColor : null,
        ),
        if (tab.isGroupTab)
          txt(
            r.lastDate == null ? '—' : formatDateTime(r.lastDate!),
          ),
        txt(r.share == null ? '—' : _percent(r.share!)),
      ];
      return Material(
        color: Colors.transparent,
        child: InkWell(
          key: ValueKey('purchase-row-${r.id}'),
          mouseCursor: SystemMouseCursors.click,
          onTap: () => _openTable(r.filters),
          child: Container(
            height: 46,
            decoration: BoxDecoration(
              color: i.isEven ? Colors.white : Colors.grey.shade50,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade100),
              ),
            ),
            child: Row(
              children: [
                for (var c = 0; c < cols.length; c++)
                  cell(cols[c].width, values[c], start: c == 0),
              ],
            ),
          ),
        ),
      );
    }

    final hasPurchases = rows.any((r) => r.count > 0);

    return Container(
      decoration: _card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                _title(
                  theme,
                  'Purchase Breakdown',
                  'Tap a row to open its purchases in the table',
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    spacing: 6,
                    children: [
                      for (final t in tabs)
                        ChoiceChip(
                          key: ValueKey('purchase-tab-${t.name}'),
                          label: Text(t.label),
                          selected: t == tab,
                          onSelected: (_) => _setTab(t),
                          selectedColor: theme.lightModeColor.prColor50,
                          backgroundColor: Colors.grey.shade100,
                          labelStyle: TextStyle(
                            fontSize: theme.mobileTexts.b4.fontSize,
                            fontWeight:
                                t == tab
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                            color:
                                t == tab
                                    ? theme.lightModeColor.prColor300
                                    : Colors.grey.shade700,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (!hasPurchases)
            _emptyText(theme, 'No purchases in this period.')
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 44,
                    color: theme.lightModeColor.prColor300.withAlpha(22),
                    child: Row(
                      children: [
                        for (var c = 0; c < cols.length; c++)
                          header(cols[c], c == 0),
                      ],
                    ),
                  ),
                  for (var i = 0; i < rows.length; i++)
                    rowWidget(rows[i], i),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
