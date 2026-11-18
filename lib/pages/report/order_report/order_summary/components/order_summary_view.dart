import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/report/components/export/report_export_button.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/order_report/order_report_table/class/order_report_export_spec.dart';
import 'package:stockall/pages/report/order_report/order_report_table/class/order_report_table_logic.dart';
import 'package:stockall/pages/report/order_report/order_report_table/components/order_report_table_view.dart';
import 'package:stockall/pages/report/order_report/order_report_table/order_report_table_page.dart';
import 'package:stockall/pages/report/order_report/order_summary/class/order_summary_export_spec.dart';
import 'package:stockall/pages/report/order_report/order_summary/class/order_summary_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/components/receipts_report_filter_widgets.dart';
import 'package:stockall/providers/theme_provider.dart';

/// One donut slice / legend row. A null [status] is the Unknown
/// slice ("—" orders), which has no table filter.
class _Slice {
  final OrderDeliveryStatus? status;
  final String label;
  final int count;
  final Color color;

  const _Slice(
    this.status,
    this.label,
    this.count,
    this.color,
  );
}

/// One breakdown table row, from a group or a status.
class _BRow {
  final String key;
  final String label;
  final bool muted;
  final int count;
  final double total;
  final double delivered;
  final double undelivered;
  final double paid;
  final double balance;
  final double? profit;
  final bool profitIsEstimate;
  final DateTime? lastOrderAt;

  /// Null: the row can't open the table.
  final OrderReportFilters? filters;
  final String? tooltip;

  const _BRow({
    required this.key,
    required this.label,
    required this.muted,
    required this.count,
    required this.total,
    required this.delivered,
    required this.undelivered,
    required this.paid,
    required this.balance,
    required this.profit,
    required this.profitIsEstimate,
    required this.lastOrderAt,
    required this.filters,
    this.tooltip,
  });
}

enum _Tab {
  customers,
  staff,
  departments,
  subStaff,
  status,
  channel,
}

extension on _Tab {
  String get label {
    switch (this) {
      case _Tab.customers:
        return 'Customers';
      case _Tab.staff:
        return 'Staff';
      case _Tab.departments:
        return 'Departments';
      case _Tab.subStaff:
        return 'Sub-Staff';
      case _Tab.status:
        return 'Status';
      case _Tab.channel:
        return 'Channel';
    }
  }
}

/// Shared body of the Order Summary and Analysis page (desktop +
/// mobile). Navigation is one way: KPIs, slices and rows open the
/// order table with matching filters and the current period.
class OrderSummaryView extends StatefulWidget {
  final bool isDesktop;
  final ReceiptsReportPeriod? initialPeriod;

  /// Null in the app: [OrderReportTableEnv.live] is used.
  final OrderReportTableEnv? env;

  const OrderSummaryView({
    super.key,
    required this.isDesktop,
    this.initialPeriod,
    this.env,
  });

  @override
  State<OrderSummaryView> createState() =>
      _OrderSummaryViewState();
}

class _OrderSummaryViewState
    extends State<OrderSummaryView> {
  late final OrderReportTableEnv _env;
  late ReceiptsReportPeriod _period;
  _Tab _tab = _Tab.customers;

  bool _loading = true;
  String? _error;
  OrderSummaryResult? _result;
  String _signature = '';

  /// The analysis has no filters of its own.
  final OrderReportFilters _base = OrderReportFilters();

  static const Color _fullColor = Color(0xFF059669);
  static const Color _partialColor = Color(0xFFD97706);
  static const Color _undeliveredColor = Color(0xFF64748B);
  static const Color _unknownColor = Color(0xFFB0B7C3);

  @override
  void initState() {
    super.initState();
    _env = widget.env ?? OrderReportTableEnv.live();
    _period =
        widget.initialPeriod ??
        ReceiptsReportPeriod.today();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load(refreshFromStore: false);
    });
  }

  // ---------------------------------------------------------------
  // data
  // ---------------------------------------------------------------

  bool get _departmentsEnabled => _env.departmentsEnabled();
  bool get _subStaffEnabled => _env.subStaffEnabled();
  bool get _canSeeCost => _env.canSeeCost();

  Future<void> _load({
    required bool refreshFromStore,
  }) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _env.loadWithPeriod(
        context,
        refreshFromStore: refreshFromStore,
        period: _period,
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
    final rows = OrderReportRowBuilder.buildAll(
      orders: _env.orders(),
      allReceipts: _env.receipts(),
      allProductSales: _env.productSales(),
    );
    _result = OrderSummaryBuilder.build(
      rows: rows,
      period: _period,
      departmentsEnabled: _departmentsEnabled,
      subStaffEnabled: _subStaffEnabled,
      profitVisible: _canSeeCost,
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
    if (!p.isAllTime) {
      _load(refreshFromStore: false);
    }
  }

  Future<void> _pushTable(
    BuildContext context,
    OrderReportFilters filters,
    ReceiptsReportPeriod period,
  ) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => OrderReportTablePage(
              initialFilters: filters,
              initialPeriod: period,
            ),
      ),
    );
  }

  Future<void> _openTable(
    OrderReportFilters filters,
  ) async {
    final open = _env.openTable ?? _pushTable;
    await open(context, filters, _period);
    // Picks up deliveries or edits made from the table.
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

  void _openStatus(OrderDeliveryStatus status) =>
      _openTable(
        OrderSummaryBuilder.filtersForStatus(
          base: _base,
          status: status,
        ),
      );

  // ---------------------------------------------------------------
  // formatting
  // ---------------------------------------------------------------

  String _money(num v) => _env.money(context, v);

  ReportExportSpec _exportSpec() {
    return orderSummaryExportSpec(
      result: _result!,
      period: _period,
      currency: currencySymbol(context: context),
      canSeeCost: _canSeeCost,
      departmentsEnabled: _departmentsEnabled,
      subStaffEnabled: _subStaffEnabled,
    );
  }

  String _percent(double v) =>
      '${formatLargeNumberDouble(double.parse(v.toStringAsFixed(2)))}%';

  Color? _signColor(ThemeProvider theme, double v) =>
      v > 0
          ? Colors.green.shade700
          : (v < 0
              ? theme.lightModeColor.errorColor200
              : null);

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

  Widget _title(
    ThemeProvider theme,
    String text,
    String sub,
  ) {
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

  // ---------------------------------------------------------------
  // build
  // ---------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = returnTheme(context);
    // Listen, so deliveries, edits and sync update the analysis.
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
      backgroundColor: const Color.fromARGB(
        255,
        252,
        253,
        255,
      ),
      appBar: appBar(
        context: context,
        title: 'Order Summary and Analysis',
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
      body: _body(theme),
    );
  }

  Widget _body(ThemeProvider theme) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
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
              onPressed:
                  () => _load(refreshFromStore: false),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
            ),
          ],
        ),
      );
    }
    final gap = SizedBox(
      height: widget.isDesktop ? 16 : 12,
    );
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
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ReceiptsReportPeriodButton(
                  theme: theme,
                  period: _period,
                  enabled: _env.canPickDate(),
                  onChanged: _setPeriod,
                ),
                ReportExportButton(buildSpec: _exportSpec),
              ],
            ),
          ),
          if (orderReportNotes(period: _period).isNotEmpty)
            _note(),
          gap,
          _kpis(theme, result.stats),
          gap,
          _middle(theme, result),
          gap,
          _breakdown(theme, result),
          gap,
        ],
      ),
    );
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
              orderReportNotes(period: _period).join('\n'),
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

  Widget _kpis(ThemeProvider theme, OrderSummaryStats s) {
    void all() => _openTable(_base.copy());
    final cards = <Widget>[
      _kpi(
        theme,
        id: 'orders',
        title: 'Orders',
        value: '${s.orderCount}',
        subtitle:
            '${s.fullyDelivered} full · ${s.partiallyDelivered} partial · '
            '${s.undelivered} undelivered',
        icon: Icons.inventory_2_outlined,
        color: const Color(0xFF7E22CE),
        onTap: all,
      ),
      _kpi(
        theme,
        id: 'value',
        title: 'Order Value',
        value: _money(s.totalValue),
        subtitle: 'Total of the orders',
        icon: Icons.receipt_long_rounded,
        color: const Color(0xFF2563EB),
        onTap: all,
      ),
      _kpi(
        theme,
        id: 'delivered',
        title: 'Delivered Value',
        value: _money(s.deliveredValue),
        subtitle: 'Share of order value delivered',
        icon: Icons.local_shipping_outlined,
        color: _fullColor,
        onTap: all,
      ),
      _kpi(
        theme,
        id: 'undelivered',
        title: 'Undelivered Value',
        value: _money(s.undeliveredValue),
        subtitle: 'Still to deliver',
        icon: Icons.pending_actions_outlined,
        color: _partialColor,
        onTap: all,
      ),
      _kpi(
        theme,
        id: 'paid',
        title: 'Paid',
        value: _money(s.paid),
        subtitle: 'Collected on the orders',
        icon: Icons.payments_outlined,
        color: const Color(0xFF0891B2),
        onTap: all,
      ),
      _kpi(
        theme,
        id: 'balance',
        title: 'Balance',
        value: _money(s.balance),
        subtitle: 'Still owed on the orders',
        icon: Icons.account_balance_wallet_outlined,
        color: const Color(0xFFDC2626),
        onTap: all,
      ),
      if (_canSeeCost)
        _kpi(
          theme,
          id: 'profit',
          title:
              s.profitIsEstimate ? 'Est. Profit' : 'Profit',
          value:
              s.profit == null ? 'N/A' : _money(s.profit!),
          subtitle:
              s.margin == null
                  ? 'No cost price on the items'
                  : 'Margin ${_percent(s.margin!)}',
          icon: Icons.trending_up_rounded,
          color: const Color(0xFF16A34A),
          valueColor:
              s.profit == null
                  ? null
                  : _signColor(theme, s.profit!),
          tooltip:
              s.profitIsEstimate
                  ? 'Estimated until every order is Fully Delivered'
                  : null,
          onTap: all,
        ),
      _kpi(
        theme,
        id: 'disagree',
        title: 'Records Disagree',
        value: '${s.recordsDisagree}',
        subtitle: 'Stored and receipt quantities differ',
        icon: Icons.warning_amber_rounded,
        color: Colors.orange.shade800,
        onTap:
            () => _openTable(
              OrderSummaryBuilder.filtersForRecordsDisagree(
                base: _base,
              ),
            ),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 10.0;
        final perRow = widget.isDesktop ? 4 : 2;
        final width =
            (constraints.maxWidth -
                spacing * (perRow - 1)) /
            perRow;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final c in cards)
              SizedBox(width: width, child: c),
          ],
        );
      },
    );
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
    Color? valueColor,
    String? tooltip,
  }) {
    final card = InkWell(
      key: ValueKey('order-kpi-$id'),
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
                      fontSize:
                          theme.mobileTexts.b4.fontSize,
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
                  color: valueColor ?? Colors.black87,
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
    return tooltip == null
        ? card
        : Tooltip(message: tooltip, child: card);
  }

  // ---------------------------------------------------------------
  // donut + top customers
  // ---------------------------------------------------------------

  Widget _middle(
    ThemeProvider theme,
    OrderSummaryResult result,
  ) {
    final donut = _donut(theme, result.stats);
    final top = _topCustomers(theme, result);
    if (widget.isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 38, child: donut),
          const SizedBox(width: 12),
          Expanded(flex: 62, child: top),
        ],
      );
    }
    return Column(
      children: [donut, const SizedBox(height: 12), top],
    );
  }

  Widget _donut(ThemeProvider theme, OrderSummaryStats s) {
    final all = <_Slice>[
      _Slice(
        OrderDeliveryStatus.full,
        OrderDeliveryStatus.full.label,
        s.fullyDelivered,
        _fullColor,
      ),
      _Slice(
        OrderDeliveryStatus.partial,
        OrderDeliveryStatus.partial.label,
        s.partiallyDelivered,
        _partialColor,
      ),
      _Slice(
        OrderDeliveryStatus.undelivered,
        OrderDeliveryStatus.undelivered.label,
        s.undelivered,
        _undeliveredColor,
      ),
      if (s.unavailable > 0)
        _Slice(
          null,
          'Unknown',
          s.unavailable,
          _unknownColor,
        ),
    ];
    final shown = all.where((e) => e.count > 0).toList();
    final total = s.orderCount;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title(
            theme,
            'Delivery Status',
            'How much of each order was delivered',
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
                    pieTouchData: PieTouchData(
                      touchCallback: (event, response) {
                        if (event is! FlTapUpEvent) return;
                        final i =
                            response
                                ?.touchedSection
                                ?.touchedSectionIndex ??
                            -1;
                        if (i < 0 || i >= shown.length)
                          return;
                        final status = shown[i].status;
                        if (status != null)
                          _openStatus(status);
                      },
                    ),
                    sections:
                        shown.isEmpty
                            ? [
                              PieChartSectionData(
                                color: Colors.grey.shade200,
                                value: 1,
                                radius: 18,
                                showTitle: false,
                              ),
                            ]
                            : [
                              for (final e in shown)
                                PieChartSectionData(
                                  color: e.color,
                                  value: e.count.toDouble(),
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
                      'Orders',
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b4.fontSize,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          for (final e in all) _legend(theme, e, total),
        ],
      ),
    );
  }

  Widget _legend(ThemeProvider theme, _Slice e, int total) {
    final pct = total > 0 ? e.count / total * 100 : 0.0;
    final row = InkWell(
      key: ValueKey(
        'order-status-legend-${e.status?.name ?? 'unknown'}',
      ),
      onTap:
          e.status == null
              ? null
              : () => _openStatus(e.status!),
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          spacing: 6,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: e.color,
                shape: BoxShape.circle,
              ),
            ),
            Expanded(
              child: Text(
                e.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: theme.mobileTexts.b3.fontSize,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            Text(
              '${_percent(pct)} (${e.count})',
              style: TextStyle(
                fontSize: theme.mobileTexts.b4.fontSize,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
    if (e.status != null) return row;
    return Tooltip(
      message:
          'Orders whose delivery status could not be worked out. '
          'They show under All statuses in the table.',
      child: row,
    );
  }

  Widget _topCustomers(
    ThemeProvider theme,
    OrderSummaryResult result,
  ) {
    final list = result.topUndeliveredCustomers;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title(
            theme,
            'Top Customers by Undelivered Value',
            'Customers still waiting on the most',
          ),
          const SizedBox(height: 8),
          if (list.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'No customer has undelivered orders.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b3.fontSize,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
            ),
          for (var i = 0; i < list.length; i++)
            _rankRow(theme, i + 1, list[i]),
        ],
      ),
    );
  }

  Widget _rankRow(
    ThemeProvider theme,
    int rank,
    OrderReportGroupRow g,
  ) {
    return InkWell(
      key: ValueKey('order-top-customer-${g.key}'),
      onTap:
          () => _openTable(
            OrderSummaryBuilder.filtersForGroup(
              base: _base,
              dimension: OrderSummaryDimension.customer,
              group: g,
            ),
          ),
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
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    g.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.b3.fontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    '${g.count} orders · Total ${_money(g.total)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.b4.fontSize,
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
                  _money(g.undeliveredValue),
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b3.fontSize,
                    fontWeight: FontWeight.bold,
                    color: _partialColor,
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

  List<_Tab> get _tabs => [
    _Tab.customers,
    _Tab.staff,
    if (_departmentsEnabled) _Tab.departments,
    if (_subStaffEnabled) _Tab.subStaff,
    _Tab.status,
    _Tab.channel,
  ];

  _BRow _groupRow(
    String prefix,
    OrderSummaryDimension dim,
    OrderReportGroupRow g,
  ) {
    return _BRow(
      key: 'order-row-$prefix-${g.key}',
      label: g.label,
      muted: g.isNone || g.name == null,
      count: g.count,
      total: g.total,
      delivered: g.deliveredValue,
      undelivered: g.undeliveredValue,
      paid: g.paid,
      balance: g.balance,
      profit: g.profit,
      profitIsEstimate: g.profitIsEstimate,
      lastOrderAt: g.lastOrderAt,
      filters: OrderSummaryBuilder.filtersForGroup(
        base: _base,
        dimension: dim,
        group: g,
      ),
    );
  }

  _BRow _statusRow(
    String id,
    String label,
    List<OrderReportRow> rows,
    OrderReportFilters? filters, {
    String? tooltip,
  }) {
    final t = OrderReportTotals.of(rows);
    return _BRow(
      key: 'order-row-status-$id',
      label: label,
      muted: filters == null,
      count: t.count,
      total: t.total,
      delivered: t.deliveredValue,
      undelivered: t.undeliveredValue,
      paid: t.paid,
      balance: t.balance,
      profit: t.profit,
      profitIsEstimate: t.profitIsEstimate,
      lastOrderAt: null,
      filters: filters,
      tooltip: tooltip,
    );
  }

  List<_BRow> _rowsFor(_Tab tab, OrderSummaryResult r) {
    switch (tab) {
      case _Tab.customers:
        return [
          for (final g in r.customers)
            _groupRow(
              'customer',
              OrderSummaryDimension.customer,
              g,
            ),
        ];
      case _Tab.staff:
        return [
          for (final g in r.staff)
            _groupRow(
              'staff',
              OrderSummaryDimension.staff,
              g,
            ),
        ];
      case _Tab.departments:
        return [
          for (final g in r.departments)
            _groupRow(
              'department',
              OrderSummaryDimension.department,
              g,
            ),
        ];
      case _Tab.subStaff:
        return [
          for (final g in r.subStaff)
            _groupRow(
              'substaff',
              OrderSummaryDimension.subStaff,
              g,
            ),
        ];
      case _Tab.channel:
        return [
          for (final g in r.channels)
            _groupRow(
              'channel',
              OrderSummaryDimension.channel,
              g,
            ),
        ];
      case _Tab.status:
        final unknown =
            r.rows
                .where((row) => row.status == null)
                .toList();
        return [
          for (final s
              in OrderDeliveryStatus.values.reversed)
            _statusRow(
              s.name,
              s.label,
              r.rows
                  .where((row) => row.status == s)
                  .toList(),
              OrderSummaryBuilder.filtersForStatus(
                base: _base,
                status: s,
              ),
            ),
          if (unknown.isNotEmpty)
            _statusRow(
              'unknown',
              'Unknown',
              unknown,
              null,
              tooltip:
                  'Delivery status could not be worked out. These '
                  'orders show under All statuses in the table.',
            ),
        ];
    }
  }

  Widget _breakdown(
    ThemeProvider theme,
    OrderSummaryResult result,
  ) {
    final tabs = _tabs;
    final tab = tabs.contains(_tab) ? _tab : tabs.first;
    final rows = _rowsFor(tab, result);
    final showLast =
        tab != _Tab.status && tab != _Tab.channel;

    final cols = <({String label, double width})>[
      (label: tab.label, width: 200),
      (label: 'Orders', width: 80),
      (label: 'Total', width: 130),
      (label: 'Delivered', width: 130),
      (label: 'Undelivered', width: 140),
      (label: 'Paid', width: 120),
      (label: 'Balance', width: 120),
      if (_canSeeCost) (label: 'Profit', width: 150),
      if (showLast) (label: 'Last order', width: 130),
    ];

    Widget cell(
      double width,
      Widget child, {
      bool start = false,
    }) {
      return SizedBox(
        width: width,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
          ),
          child: Align(
            alignment:
                start
                    ? Alignment.centerLeft
                    : Alignment.center,
            child: child,
          ),
        ),
      );
    }

    Widget txt(
      String s, {
      bool bold = false,
      Color? color,
    }) => Text(
      s,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: theme.mobileTexts.b3.fontSize,
        fontWeight:
            bold ? FontWeight.bold : FontWeight.w500,
        color: color ?? Colors.black87,
      ),
    );

    Widget rowWidget(_BRow r, int i) {
      final values = <Widget>[
        txt(
          r.label,
          bold: true,
          color: r.muted ? Colors.grey : null,
        ),
        txt('${r.count}'),
        txt(_money(r.total), bold: true),
        txt(_money(r.delivered)),
        txt(_money(r.undelivered)),
        txt(_money(r.paid)),
        txt(_money(r.balance)),
        if (_canSeeCost)
          r.profit == null
              ? txt('N/A', color: Colors.grey)
              : txt(
                r.profitIsEstimate
                    ? 'Est. ${_money(r.profit!)}'
                    : _money(r.profit!),
                bold: true,
                color: _signColor(theme, r.profit!),
              ),
        if (showLast)
          txt(
            r.lastOrderAt == null
                ? '—'
                : formatDateTime(r.lastOrderAt!),
          ),
      ];
      final content = Container(
        height: 46,
        decoration: BoxDecoration(
          color:
              i.isEven ? Colors.white : Colors.grey.shade50,
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
      );
      final tappable = Material(
        color: Colors.transparent,
        child: InkWell(
          key: ValueKey(r.key),
          mouseCursor:
              r.filters == null
                  ? SystemMouseCursors.basic
                  : SystemMouseCursors.click,
          onTap:
              r.filters == null
                  ? null
                  : () => _openTable(r.filters!),
          child: content,
        ),
      );
      return r.tooltip == null
          ? tappable
          : Tooltip(message: r.tooltip!, child: tappable);
    }

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
                  'Order Breakdown',
                  'Tap a row to open its orders in the table',
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    spacing: 6,
                    children: [
                      for (final t in tabs)
                        ChoiceChip(
                          key: ValueKey(
                            'order-tab-${t.name}',
                          ),
                          label: Text(t.label),
                          selected: t == tab,
                          onSelected:
                              (_) =>
                                  setState(() => _tab = t),
                          selectedColor:
                              theme
                                  .lightModeColor
                                  .prColor50,
                          backgroundColor:
                              Colors.grey.shade100,
                          labelStyle: TextStyle(
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b4
                                    .fontSize,
                            fontWeight:
                                t == tab
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                            color:
                                t == tab
                                    ? theme
                                        .lightModeColor
                                        .prColor300
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
          if (rows.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'No orders in this period.',
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b3.fontSize,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 44,
                    color: theme.lightModeColor.prColor300
                        .withAlpha(22),
                    child: Row(
                      children: [
                        for (
                          var c = 0;
                          c < cols.length;
                          c++
                        )
                          cell(
                            cols[c].width,
                            txt(cols[c].label, bold: true),
                            start: c == 0,
                          ),
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
