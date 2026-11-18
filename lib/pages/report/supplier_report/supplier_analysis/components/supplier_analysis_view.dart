import 'package:flutter/material.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/report/components/export/report_export_button.dart';
import 'package:stockall/pages/report/components/report_trend_chart.dart';
import 'package:stockall/pages/report/purchase_report/purchase_report_table/class/purchase_report_export_spec.dart';
import 'package:stockall/pages/report/purchase_report/purchase_report_table/class/purchase_report_table_logic.dart';
import 'package:stockall/pages/report/purchase_report/purchase_report_table/components/purchase_report_table_view.dart';
import 'package:stockall/pages/report/purchase_report/purchase_report_table/purchase_report_table_page.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/components/receipts_report_filter_widgets.dart';
import 'package:stockall/pages/report/supplier_report/supplier_analysis/class/supplier_analysis_export_spec.dart';
import 'package:stockall/pages/report/supplier_report/supplier_analysis/class/supplier_analysis_logic.dart';
import 'package:stockall/pages/report/supplier_report/supplier_report_table/class/supplier_report_table_logic.dart';
import 'package:stockall/pages/report/supplier_report/supplier_report_table/components/supplier_report_table_view.dart';
import 'package:stockall/providers/theme_provider.dart';

/// Shared body of the Supplier Analysis page (desktop + mobile):
/// one supplier's KPIs, spend trend, top items and recent
/// purchases for a period. "See all" opens the purchase table on
/// the supplier and period; a recent purchase opens its page.
/// Coming back rebuilds.
class SupplierAnalysisView extends StatefulWidget {
  final bool isDesktop;

  /// The supplier's uuid ([SupplierReportRow.key]).
  final String supplierKey;
  final ReceiptsReportPeriod? initialPeriod;

  /// Null in the app: [SupplierReportEnv.live] is used.
  final SupplierReportEnv? env;

  const SupplierAnalysisView({
    super.key,
    required this.isDesktop,
    required this.supplierKey,
    this.initialPeriod,
    this.env,
  });

  @override
  State<SupplierAnalysisView> createState() =>
      _SupplierAnalysisViewState();
}

class _SupplierAnalysisViewState
    extends State<SupplierAnalysisView> {
  late final SupplierReportEnv _env;
  late ReceiptsReportPeriod _period;

  bool _loading = true;
  String? _error;
  SupplierAnalysisResult? _result;
  String _signature = '';

  static const Color _paidColor = Color(0xFF059669);
  static const Color _partlyColor = Color(0xFFD97706);
  static const Color _unpaidColor = Color(0xFFDC2626);

  PurchaseReportEnv get _purchaseEnv => _env.purchaseEnv;

  @override
  void initState() {
    super.initState();
    _env = widget.env ?? SupplierReportEnv.live();
    _period = supplierReportInitialPeriod(
      canPickDate: _purchaseEnv.canPickDate(),
      initial: widget.initialPeriod,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load(refreshFromStore: false);
    });
  }

  // ---------------------------------------------------------------
  // data
  // ---------------------------------------------------------------

  Future<void> _load({required bool refreshFromStore}) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _purchaseEnv.loadWithPeriod(
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
    _result = SupplierAnalysisBuilder.build(
      supplierKey: widget.supplierKey,
      purchaseRows: PurchaseReportRowBuilder.buildAll(
        purchases: _purchaseEnv.purchases(),
        legacyLines: _purchaseEnv.legacyLines(),
        supplierNames: _purchaseEnv.supplierNames(),
        pendingDeletedUuids: _purchaseEnv.pendingDeletedUuids(),
      ),
      suppliers: _env.scopedSuppliers(),
      allSuppliers: _env.suppliers(),
      legacyLines: _purchaseEnv.legacyLines(),
      period: _period,
      departmentsEnabled: _purchaseEnv.departmentsEnabled(),
    );
    _signature = _env.signature();
  }

  /// Rebuilds after a change, or after coming back from a page.
  void _refresh(VoidCallback change) {
    setState(() {
      change();
      try {
        _rebuild();
        _error = null;
      } catch (e) {
        _error = e.toString();
      }
    });
  }

  void _setPeriod(ReceiptsReportPeriod p) {
    _refresh(() => _period = p);
    if (!p.isAllTime) {
      _load(refreshFromStore: false);
    }
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

  Future<void> _openTable(SupplierAnalysisResult r) async {
    final open = _purchaseEnv.openTable ?? _pushTable;
    await open(context, r.tableFilters, _period);
    // Picks up payments or edits made from the table.
    if (mounted) _refresh(() {});
  }

  Future<void> _openPurchase(PurchaseReportRow row) async {
    await _purchaseEnv.openPurchase(context, row.purchase);
    // Picks up a payment, edit or delete made on the purchase.
    if (mounted) _refresh(() {});
  }

  String _money(num v) => _purchaseEnv.money(context, v);

  static String _date(DateTime? d) =>
      d == null ? '—' : formatDateTime(d);

  static String _count(int n, String noun) =>
      '$n ${n == 1 ? noun : '${noun}s'}';

  // ---------------------------------------------------------------
  // build
  // ---------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = returnTheme(context);
    // Listen, so purchases, payments, suppliers and sync update
    // the analysis.
    _purchaseEnv.listen(context);

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
        title: _result?.title ?? 'Supplier Analysis',
        titleWidget: _titleWidget(theme),
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

  Widget _titleWidget(ThemeProvider theme) {
    final r = _result;
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: [
        Flexible(
          child: Text(
            r?.title ?? 'Supplier Analysis',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: theme.mobileTexts.h4.fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (r != null && r.supplier.isDeleted)
          _badge(
            supplierDeletedLabel,
            theme.lightModeColor.errorColor200,
          ),
      ],
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
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ReceiptsReportPeriodButton(
                  theme: theme,
                  period: _period,
                  enabled: _purchaseEnv.canPickDate(),
                  onChanged: _setPeriod,
                ),
                ReportExportButton(
                  buildSpec:
                      () => supplierAnalysisExportSpec(
                        result: result,
                        period: _period,
                      ),
                ),
              ],
            ),
          ),
          if (purchaseReportNotes(period: _period).isNotEmpty) _note(),
          gap,
          _contact(theme, result.supplier),
          gap,
          _kpis(theme, result.supplier),
          gap,
          _pair(
            _trendCard(theme, result),
            _topItemsCard(theme, result),
          ),
          gap,
          _recentCard(theme, result),
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
              purchaseReportNotes(period: _period).join('\n'),
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
  // cards
  // ---------------------------------------------------------------

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

  Widget _section(
    ThemeProvider theme, {
    required String title,
    required String subtitle,
    required Widget child,
    Widget? action,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _title(theme, title, subtitle)),
              if (action != null) action,
            ],
          ),
          child,
        ],
      ),
    );
  }

  Widget _badge(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 8,
      vertical: 3,
    ),
    decoration: BoxDecoration(
      color: color.withAlpha(30),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        color: color,
      ),
    ),
  );

  Widget _footnote(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        Icon(
          Icons.info_outline_rounded,
          size: 13,
          color: Colors.grey.shade600,
        ),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _contact(ThemeProvider theme, SupplierReportRow s) {
    Widget field(String label, String? value, IconData icon) {
      return SizedBox(
        width: widget.isDesktop ? 320 : double.infinity,
        child: Row(
          spacing: 8,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 16, color: Colors.grey.shade600),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: theme.mobileTexts.b4.fontSize,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  Text(
                    value ?? '—',
                    style: TextStyle(
                      fontSize: theme.mobileTexts.b3.fontSize,
                      fontWeight: FontWeight.w600,
                      color:
                          value == null
                              ? Colors.grey
                              : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      key: const ValueKey('supplier-contact'),
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: _card,
      child: Wrap(
        spacing: 16,
        runSpacing: 12,
        children: [
          field('Phone', s.phone, Icons.phone_outlined),
          field('Email', s.email, Icons.mail_outline_rounded),
          field(
            'Address',
            s.fullAddress,
            Icons.location_on_outlined,
          ),
        ],
      ),
    );
  }

  Widget _kpis(ThemeProvider theme, SupplierReportRow s) {
    final cards = <Widget>[
      _kpi(
        theme,
        id: 'purchases',
        title: 'Purchases',
        value: '${s.purchaseCount}',
        subtitle: 'Purchases in this period',
        icon: Icons.shopping_bag_outlined,
        color: const Color(0xFF7E22CE),
      ),
      _kpi(
        theme,
        id: 'spend',
        title: 'Total Spend',
        value: _money(s.spend),
        subtitle: 'Total of the purchases',
        icon: Icons.receipt_long_rounded,
        color: const Color(0xFF2563EB),
      ),
      _kpi(
        theme,
        id: 'paid',
        title: 'Total Paid',
        value: _money(s.paid),
        subtitle: 'Paid to this supplier',
        icon: Icons.payments_outlined,
        color: const Color(0xFF0891B2),
      ),
      _kpi(
        theme,
        id: 'balance',
        title: 'Balance Owed',
        value: _money(s.balance),
        subtitle: 'Still owed to this supplier',
        icon: Icons.account_balance_wallet_outlined,
        color: _unpaidColor,
      ),
      _kpi(
        theme,
        id: 'average',
        title: 'Average Purchase',
        value: _money(s.average),
        subtitle: 'Spend per purchase',
        icon: Icons.analytics_outlined,
        color: const Color(0xFF4F46E5),
      ),
      _kpi(
        theme,
        id: 'first',
        title: 'First Purchase',
        value: _date(s.firstPurchase),
        subtitle: 'Earliest in this period',
        icon: Icons.first_page_rounded,
        color: const Color(0xFF0D9488),
      ),
      _kpi(
        theme,
        id: 'last',
        title: 'Last Purchase',
        value: _date(s.lastPurchase),
        subtitle: 'Latest in this period',
        icon: Icons.last_page_rounded,
        color: const Color(0xFFEA580C),
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

  Widget _kpi(
    ThemeProvider theme, {
    required String id,
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      key: ValueKey('supplier-kpi-$id'),
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
    );
  }

  Widget _trendCard(ThemeProvider theme, SupplierAnalysisResult r) {
    final subtitle =
        '${reportTrendIntervalLabel(r.interval)}, by business day';
    return _section(
      theme,
      title: 'Spend Trend',
      subtitle: subtitle,
      child:
          r.rows.isEmpty || r.trend.isEmpty
              ? _emptyText(theme, 'No purchases in this period.')
              : ReportTrendChart(
                starts: [for (final p in r.trend) p.start],
                interval: r.interval,
                money: _money,
                series: [
                  ReportTrendSeries(
                    label: 'Spend',
                    color: theme.lightModeColor.prColor300,
                    values: [for (final p in r.trend) p.spend],
                  ),
                  ReportTrendSeries(
                    label: 'Paid',
                    color: _paidColor,
                    values: [for (final p in r.trend) p.paid],
                  ),
                ],
              ),
    );
  }

  Widget _topItemsCard(
    ThemeProvider theme,
    SupplierAnalysisResult r,
  ) {
    return _section(
      theme,
      title: 'Top Items',
      subtitle: 'Largest line spend in this period',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 6,
        children: [
          if (r.topItems.isEmpty)
            _emptyText(theme, 'No items in this period.')
          else
            for (var i = 0; i < r.topItems.length; i++)
              _itemRow(theme, i + 1, r.topItems[i]),
          for (final note in supplierTopItemsFootnotes(r)) _footnote(note),
        ],
      ),
    );
  }

  Widget _itemRow(
    ThemeProvider theme,
    int rank,
    SupplierTopItem item,
  ) {
    return Container(
      key: ValueKey('supplier-top-item-${item.key}'),
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
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b3.fontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  // "3 items", not "3.0 items".
                  '${_count(item.purchaseCount, 'purchase')} · '
                  '${formatDimension(item.items)} items',
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
                _money(item.spend),
                style: TextStyle(
                  fontSize: theme.mobileTexts.b3.fontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _recentCard(
    ThemeProvider theme,
    SupplierAnalysisResult r,
  ) {
    final accent = theme.lightModeColor.prColor300;
    return _section(
      theme,
      title: 'Recent Purchases',
      subtitle:
          r.rows.isEmpty
              ? 'Newest first'
              : 'Newest first · ${_count(r.rows.length, 'purchase')} '
                  'in this period',
      action:
          r.rows.isEmpty
              ? null
              : TextButton.icon(
                key: const ValueKey('supplier-see-all'),
                onPressed: () => _openTable(r),
                icon: Icon(
                  Icons.open_in_new_rounded,
                  size: 16,
                  color: accent,
                ),
                label: Text(
                  'See all',
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b3.fontSize,
                    fontWeight: FontWeight.bold,
                    color: accent,
                  ),
                ),
              ),
      child:
          r.rows.isEmpty
              ? _emptyText(theme, 'No purchases in this period')
              : Column(
                spacing: 6,
                children: [
                  for (final p in r.recent) _recentRow(theme, p),
                ],
              ),
    );
  }

  Color _statusColor(PurchaseStatus s) {
    switch (s) {
      case PurchaseStatus.paid:
        return _paidColor;
      case PurchaseStatus.partlyPaid:
        return _partlyColor;
      case PurchaseStatus.unpaid:
        return _unpaidColor;
    }
  }

  Widget _recentRow(ThemeProvider theme, PurchaseReportRow p) {
    return InkWell(
      key: ValueKey('supplier-recent-${p.uuid}'),
      mouseCursor: SystemMouseCursors.click,
      borderRadius: BorderRadius.circular(6),
      onTap: () => _openPurchase(p),
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
          spacing: 10,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.displayId,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: theme.mobileTexts.b3.fontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    '${formatDateTime(p.createdAt)} · '
                    '${formatTime(p.createdAt)}',
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
            _badge(p.status.label, _statusColor(p.status)),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  _money(p.total),
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b3.fontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
