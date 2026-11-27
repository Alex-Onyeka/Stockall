import 'package:flutter/material.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/report/components/export/report_export_button.dart';
import 'package:stockall/pages/report/order_report/order_report_table/class/order_report_table_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/components/receipts_report_filter_widgets.dart';
import 'package:stockall/pages/report/staff_report/staff_analysis/class/staff_analysis_export_spec.dart';
import 'package:stockall/pages/report/staff_report/staff_analysis/class/staff_analysis_logic.dart';
import 'package:stockall/pages/report/staff_report/staff_report_table/class/staff_report_export_spec.dart';
import 'package:stockall/pages/report/staff_report/staff_report_table/class/staff_report_table_logic.dart';
import 'package:stockall/pages/report/staff_report/staff_report_table/components/staff_report_table_view.dart';
import 'package:stockall/providers/theme_provider.dart';

/// Shared body of the Staff Analysis page (desktop + mobile): the
/// staff's table-row numbers as KPIs, then the most recent
/// receipts, invoices, orders, purchases and expenses, each with
/// "See all". Without the View Date permission the period is today.
class StaffAnalysisView extends StatefulWidget {
  final bool isDesktop;

  /// `TempUserClass.userId`, the staff id every record carries.
  final String staffKey;
  final ReceiptsReportPeriod? initialPeriod;

  /// Null in the app: [StaffReportEnv.live] is used.
  final StaffReportEnv? env;

  const StaffAnalysisView({
    super.key,
    required this.isDesktop,
    required this.staffKey,
    this.initialPeriod,
    this.env,
  });

  @override
  State<StaffAnalysisView> createState() => _StaffAnalysisViewState();
}

class _StaffAnalysisViewState extends State<StaffAnalysisView> {
  late final StaffReportEnv _env;
  late StaffReportAccess _access;
  late ReceiptsReportPeriod _period;

  bool _loading = true;
  String? _error;

  StaffReportBase? _base;
  StaffAnalysis? _analysis;
  String _signature = '';

  @override
  void initState() {
    super.initState();
    _env = widget.env ?? StaffReportEnv.live();
    _access = _env.access(context);
    _period =
        _access.canPickDate
            ? (widget.initialPeriod ?? ReceiptsReportPeriod.today())
            : _access.initialPeriod();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load(refreshFromStore: true);
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
      await _env.loadWithPeriod(
        context,
        refreshFromStore: refreshFromStore,
        period: _period,
      );
      if (!mounted) return;
      _rebuild();
      setState(() => _loading = false);
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
    _access = _env.access(context);
    _base = StaffReportBase.build(source: _env.source(), access: _access);
    _signature = _env.signature(context);
    _rebuildAnalysis();
  }

  void _rebuildAnalysis() {
    final base = _base;
    if (base == null) return;
    _analysis = StaffAnalysis.build(
      staffKey: widget.staffKey,
      slice: StaffReportSlice.of(base, _period),
    );
  }

  void _setPeriod(ReceiptsReportPeriod p) {
    setState(() {
      _period = p;
      try {
        _rebuildAnalysis();
        _error = null;
      } catch (e) {
        _error = e.toString();
      }
    });
    if (!p.isAllTime) {
      _load(refreshFromStore: false);
    }
  }

  /// Runs a navigation hook, then rebuilds: whatever was changed
  /// on the page that was opened shows here.
  Future<void> _open(Future<void> Function() go) async {
    await go();
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

  String get _key => widget.staffKey;

  // ---------------------------------------------------------------
  // formatting
  // ---------------------------------------------------------------

  String _money(num v) => _env.money(context, v);

  String _date(DateTime? d) => d == null ? '—' : formatDateTime(d);

  String _dateTime(DateTime? d) => d == null ? '—' : formatDateWithTime(d);

  static String _count(int n, String noun) => '$n $noun${n == 1 ? '' : 's'}';

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

  Widget _formerBadge(ThemeProvider theme) {
    final color = theme.lightModeColor.errorColor200;
    return Container(
      key: const ValueKey('staff-former-badge'),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        staffReportFormerRoleLabel,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
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
    // Listen, so sales, purchases, expenses and sync update the
    // analysis.
    _env.listen(context);

    if (!_loading && _error == null) {
      final sig = _env.signature(context);
      if (sig != _signature) {
        try {
          _rebuild();
        } catch (e) {
          _error = e.toString();
        }
      }
    }

    final summary = _analysis?.summary;
    final name = summary?.name ?? 'Staff Analysis';
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 252, 253, 255),
      appBar: appBar(
        context: context,
        title: name,
        titleWidget:
            summary != null && summary.isFormer
                ? Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 8,
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: theme.mobileTexts.h4.fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _formerBadge(theme),
                  ],
                )
                : null,
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
      body: _body(theme),
    );
  }

  Widget _body(ThemeProvider theme) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    final analysis = _analysis;
    if (_error != null || analysis == null) {
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
          _header(theme, analysis.summary),
          gap,
          // Scrolls on narrow screens, where a range label is wider
          // than the page.
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              spacing: 6,
              children: [
                ReceiptsReportPeriodButton(
                  theme: theme,
                  period: _period,
                  enabled: _access.canPickDate,
                  onChanged: _setPeriod,
                ),
                ReportExportButton(
                  showRollWidthEntries: false,
                  buildSpec:
                      () => staffAnalysisExportSpec(
                        analysis: analysis,
                        period: _period,
                        currency: currencySymbol(context: context),
                      ),
                ),
              ],
            ),
          ),
          if (staffReportNotes(period: _period).isNotEmpty) _note(),
          gap,
          _kpis(theme, analysis),
          gap,
          _sections(theme, analysis),
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
              staffReportNotes(period: _period).join('\n'),
              style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------
  // header
  // ---------------------------------------------------------------

  Widget _header(ThemeProvider theme, StaffReportRow s) {
    Widget field(String id, String label, String? value) {
      return SizedBox(
        key: ValueKey('staff-header-$id'),
        width: widget.isDesktop ? 220 : 150,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 2,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              value ?? '—',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: theme.mobileTexts.b3.fontSize,
                fontWeight: FontWeight.w500,
                color: value == null ? Colors.grey : Colors.black87,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: _card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          Text(
            s.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: theme.mobileTexts.b1.fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              // Former staff have no role: the badge says it.
              field('role', 'Role', s.isFormer ? null : s.roleLabel),
              field('phone', 'Phone', s.phone),
              field('email', 'Email', s.email),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------
  // KPIs
  // ---------------------------------------------------------------

  Widget _kpis(ThemeProvider theme, StaffAnalysis a) {
    final s = a.summary;
    final cards = <Widget>[
      _kpi(
        theme,
        id: 'receipt-sales',
        title: 'Receipt Sales',
        value: _money(s.receiptSales),
        subtitle: _count(s.receiptCount, 'receipt'),
        icon: Icons.receipt_long_rounded,
        color: const Color(0xFF2563EB),
      ),
      _kpi(
        theme,
        id: 'invoice-sales',
        title: 'Invoice Sales',
        value: _money(s.invoiceSales),
        subtitle: _count(s.invoiceCount, 'invoice'),
        icon: Icons.description_outlined,
        color: const Color(0xFF7E22CE),
      ),
      if (a.showOrders)
        _kpi(
          theme,
          id: 'orders',
          title: 'Orders',
          value: _money(s.orderTotal),
          subtitle: _count(s.orderCount, 'order'),
          icon: Icons.inventory_2_outlined,
          color: const Color(0xFF9333EA),
        ),
      if (a.showPurchases)
        _kpi(
          theme,
          id: 'purchases',
          title: 'Purchases',
          value: _money(s.purchaseTotal),
          subtitle: _count(s.purchaseCount, 'purchase'),
          icon: Icons.shopping_cart_outlined,
          color: const Color(0xFF0891B2),
        ),
      if (a.showExpenses)
        _kpi(
          theme,
          id: 'expenses',
          title: 'Expenses',
          value: _money(s.expenseTotal),
          subtitle: _count(s.expenseCount, 'expense'),
          icon: Icons.money_off_rounded,
          color: theme.lightModeColor.errorColor200,
        ),
      _kpi(
        theme,
        id: 'first-activity',
        title: 'First Activity',
        value: _date(s.firstActivity),
        subtitle: 'Any record in this period',
        icon: Icons.event_outlined,
        color: Colors.blueGrey,
      ),
      _kpi(
        theme,
        id: 'last-activity',
        title: 'Last Activity',
        value: _date(s.lastActivity),
        subtitle: 'Any record in this period',
        icon: Icons.event_available_outlined,
        color: Colors.blueGrey,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 10.0;
        final perRow = widget.isDesktop ? 4 : 2;
        final width = (constraints.maxWidth - spacing * (perRow - 1)) / perRow;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [for (final c in cards) SizedBox(width: width, child: c)],
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
      key: ValueKey('staff-kpi-$id'),
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

  // ---------------------------------------------------------------
  // sections
  // ---------------------------------------------------------------

  Widget _sections(ThemeProvider theme, StaffAnalysis a) {
    final s = a.summary;

    final sections = <Widget>[
      _section(
        theme,
        id: 'receipts',
        title: 'Receipts',
        count: s.receiptCount,
        emptyText: 'No receipts in this period.',
        onSeeAll:
            () => _open(
              () => _env.openReceiptsTable(
                context,
                StaffSeeAll.receiptsFilters(_key),
                _period,
              ),
            ),
        rows: [
          for (final r in a.recentReceipts)
            _recordRow(
              theme,
              key: ValueKey('staff-receipt-${r.uuid}'),
              title: r.displayId,
              subtitle: '${_dateTime(r.createdAt)} · ${r.type.label}',
              amount: _money(r.revenue),
              onTap: () => _open(() => _env.openReceipt(context, r.receipt)),
            ),
        ],
      ),
      _section(
        theme,
        id: 'invoices',
        title: 'Invoices',
        count: s.invoiceCount,
        emptyText: 'No invoices in this period.',
        onSeeAll:
            () => _open(
              () => _env.openInvoiceTable(
                context,
                StaffSeeAll.invoiceFilters(_key, _period),
              ),
            ),
        rows: [
          for (final r in a.recentInvoices)
            _recordRow(
              theme,
              key: ValueKey('staff-invoice-${r.uuid}'),
              title: r.displayId,
              subtitle:
                  '${_dateTime(r.createdAt.toLocal())} · '
                  '${_invoiceStatus(r.status)}',
              amount: r.invoiceTotal == null ? '—' : _money(r.invoiceTotal!),
              detail:
                  r.balance == null ? null : 'Balance ${_money(r.balance!)}',
              onTap: () => _open(() => _env.openInvoice(context, r.invoice)),
            ),
        ],
      ),
      if (a.showOrders)
        _section(
          theme,
          id: 'orders',
          title: 'Orders',
          count: s.orderCount,
          emptyText: 'No orders in this period.',
          onSeeAll:
              () => _open(
                () => _env.openOrderTable(
                  context,
                  StaffSeeAll.orderFilters(_key),
                  _period,
                ),
              ),
          rows: [
            for (final r in a.recentOrders)
              _recordRow(
                theme,
                key: ValueKey('staff-order-${r.uuid}'),
                title: r.displayId,
                subtitle:
                    '${_dateTime(r.createdAt)} · '
                    '${r.status?.label ?? 'Unknown'}',
                amount: _money(r.total),
                detail: 'Balance ${_money(r.balance)}',
                onTap: () => _open(() => _env.openOrder(context, r.order)),
              ),
          ],
        ),
      if (a.showPurchases)
        _section(
          theme,
          id: 'purchases',
          title: 'Purchases',
          count: s.purchaseCount,
          emptyText: 'No purchases in this period.',
          onSeeAll:
              () => _open(
                () => _env.openPurchaseTable(
                  context,
                  StaffSeeAll.purchaseFilters(_key),
                  _period,
                ),
              ),
          rows: [
            for (final r in a.recentPurchases)
              _recordRow(
                theme,
                key: ValueKey('staff-purchase-${r.uuid}'),
                title: r.displayId,
                subtitle: '${_dateTime(r.createdAt)} · ${r.supplierLabel}',
                amount: _money(r.total),
                detail: 'Balance ${_money(r.balance)}',
                onTap:
                    () => _open(() => _env.openPurchase(context, r.purchase)),
              ),
          ],
        ),
      if (a.showExpenses)
        _section(
          theme,
          id: 'expenses',
          title: 'Expenses',
          count: s.expenseCount,
          emptyText: 'No expenses in this period.',
          onSeeAll:
              () => _open(
                () => _env.openExpensesTable(context, _key, _period),
              ),
          rows: [
            for (final r in a.recentExpenses)
              _recordRow(
                theme,
                key: ValueKey('staff-expense-${r.uuid}'),
                title: r.title,
                subtitle: [
                  _dateTime(r.createdAt),
                  if (r.description != null) r.description!,
                ].join(' · '),
                amount: _money(r.amount),
                onTap: () => _open(() => _env.openExpense(context, r.expense)),
              ),
          ],
        ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 12.0;
        final perRow = widget.isDesktop ? 2 : 1;
        final width = (constraints.maxWidth - spacing * (perRow - 1)) / perRow;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final s in sections) SizedBox(width: width, child: s),
          ],
        );
      },
    );
  }

  static String _invoiceStatus(int status) {
    switch (status) {
      case 0:
        return 'Unpaid';
      case 1:
        return 'Partial';
      case 2:
        return 'Paid';
      default:
        return 'N/A';
    }
  }

  Widget _section(
    ThemeProvider theme, {
    required String id,
    required String title,
    required int count,
    required String emptyText,
    required VoidCallback onSeeAll,
    required List<Widget> rows,
  }) {
    return Container(
      key: ValueKey('staff-section-$id'),
      padding: const EdgeInsets.all(12),
      decoration: _card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: theme.mobileTexts.b1.fontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      '$count in this period',
                      style: TextStyle(
                        fontSize: theme.mobileTexts.b4.fontSize,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              if (rows.isNotEmpty)
                TextButton(
                  key: ValueKey('staff-see-all-$id'),
                  onPressed: onSeeAll,
                  child: Text(
                    'See all',
                    style: TextStyle(
                      fontSize: theme.mobileTexts.b3.fontSize,
                      fontWeight: FontWeight.bold,
                      color: theme.lightModeColor.prColor300,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (rows.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  emptyText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b3.fontSize,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
            ),
          ...rows,
        ],
      ),
    );
  }

  Widget _recordRow(
    ThemeProvider theme, {
    required Key key,
    required String title,
    required String subtitle,
    required String amount,
    required VoidCallback onTap,
    String? detail,
  }) {
    return InkWell(
      key: key,
      onTap: onTap,
      mouseCursor: SystemMouseCursors.click,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: theme.mobileTexts.b3.fontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    subtitle,
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  amount,
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b3.fontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                if (detail != null)
                  Text(
                    detail,
                    style: TextStyle(
                      fontSize: theme.mobileTexts.b4.fontSize,
                      color: Colors.grey.shade600,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
