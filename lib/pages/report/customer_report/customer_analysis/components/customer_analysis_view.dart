import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_customers/temp_customers_class.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/report/components/export/report_export_button.dart';
import 'package:stockall/pages/report/customer_report/customer_account_transactions/class/customer_account_transactions_logic.dart';
import 'package:stockall/pages/report/customer_report/customer_analysis/class/customer_analysis_export_spec.dart';
import 'package:stockall/pages/report/customer_report/customer_analysis/class/customer_analysis_logic.dart';
import 'package:stockall/pages/report/customer_report/customer_report_table/class/customer_report_export_spec.dart';
import 'package:stockall/pages/report/customer_report/customer_report_table/class/customer_report_table_logic.dart';
import 'package:stockall/pages/report/customer_report/customer_report_table/components/customer_report_table_view.dart';
import 'package:stockall/pages/report/customer_report/customer_reward_earnings/class/customer_reward_earnings_logic.dart';
import 'package:stockall/pages/report/order_report/order_report_table/class/order_report_table_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/components/receipts_report_filter_widgets.dart';
import 'package:stockall/providers/theme_provider.dart';

/// Shared body of the Customer Analysis page (desktop + mobile):
/// the customer's table-row numbers as KPIs, then the most recent
/// receipts, invoices, orders and ledger entries, each with "See
/// all". Without the View Date permission the period is today.
class CustomerAnalysisView extends StatefulWidget {
  final bool isDesktop;
  final TempCustomersClass customer;
  final ReceiptsReportPeriod? initialPeriod;

  /// Null in the app: [CustomerReportEnv.live] is used.
  final CustomerReportEnv? env;

  const CustomerAnalysisView({
    super.key,
    required this.isDesktop,
    required this.customer,
    this.initialPeriod,
    this.env,
  });

  @override
  State<CustomerAnalysisView> createState() => _CustomerAnalysisViewState();
}

class _CustomerAnalysisViewState extends State<CustomerAnalysisView> {
  late final CustomerReportEnv _env;
  late CustomerReportAccess _access;
  late ReceiptsReportPeriod _period;
  late TempCustomersClass _customer;

  bool _loading = true;
  String? _error;

  CustomerReportBase? _base;
  CustomerAnalysis? _analysis;
  String _signature = '';

  @override
  void initState() {
    super.initState();
    _env = widget.env ?? CustomerReportEnv.live();
    _access = _env.access();
    _customer = widget.customer;
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
    _access = _env.access();
    final source = _env.source();
    _base = CustomerReportBase.build(source: source, access: _access);
    // The stored customer, so balances changed elsewhere show.
    final uuid = widget.customer.uuid;
    _customer = source.customers.firstWhere(
      (c) => uuid != null && c.uuid == uuid,
      orElse: () => widget.customer,
    );
    _signature = _env.signature();
    _rebuildAnalysis();
  }

  void _rebuildAnalysis() {
    final base = _base;
    if (base == null) return;
    _analysis = CustomerAnalysis.build(
      customer: _customer,
      slice: CustomerReportSlice.of(base, _period),
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

  String get _uuid => _customer.uuid ?? '';

  // ---------------------------------------------------------------
  // formatting
  // ---------------------------------------------------------------

  String _money(num v) => _env.money(context, v);

  String _date(DateTime? d) => d == null ? '—' : formatDateTime(d);

  String _dateTime(DateTime? d) => d == null ? '—' : formatDateWithTime(d);

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

  // ---------------------------------------------------------------
  // build
  // ---------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = returnTheme(context);
    // Listen, so sales, payments and sync update the analysis.
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

    final name = _analysis?.summary.name ?? _customer.name;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 252, 253, 255),
      appBar: appBar(
        context: context,
        title: name,
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
                      () => customerAnalysisExportSpec(
                        analysis: analysis,
                        period: _period,
                        showTotalBalance: _access.showTotalBalance,
                        currency: currencySymbol(context: context),
                      ),
                ),
              ],
            ),
          ),
          if (customerReportNotes(period: _period).isNotEmpty) _note(),
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
              customerReportNotes(period: _period).join('\n'),
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

  Widget _header(ThemeProvider theme, CustomerReportRow s) {
    Widget field(String label, String? value) {
      return SizedBox(
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
              field('Phone', s.phone),
              field('Email', s.email),
              field('Address', s.address),
              field('City', s.city),
              field('State', s.state),
              field('Country', s.country),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------
  // KPIs
  // ---------------------------------------------------------------

  Widget _kpis(ThemeProvider theme, CustomerAnalysis a) {
    final s = a.summary;
    final red = theme.lightModeColor.errorColor200;
    final cards = <Widget>[
      _kpi(
        theme,
        id: 'receipt-purchases',
        title: 'Receipt Purchases',
        value: _money(s.receiptPurchases),
        subtitle: '${s.salesReceiptCount} sales receipts',
        icon: Icons.receipt_long_rounded,
        color: const Color(0xFF2563EB),
      ),
      _kpi(
        theme,
        id: 'invoice-purchases',
        title: 'Invoice Purchases',
        value: _money(s.invoicePurchases),
        subtitle: '${s.invoiceCount} invoices',
        icon: Icons.description_outlined,
        color: const Color(0xFF7E22CE),
      ),
      _kpi(
        theme,
        id: 'revenue',
        title: 'Revenue',
        value: _money(s.revenue),
        subtitle: 'Every receipt type, VAT included',
        icon: Icons.payments_outlined,
        color: Colors.green.shade700,
      ),
      _kpi(
        theme,
        id: 'credit',
        title: 'Credit',
        value: _money(s.credit),
        subtitle: 'Unpaid invoice balances',
        icon: Icons.account_balance_outlined,
        color: red,
        valueColor: s.credit > 0 ? red : null,
      ),
      if (a.showAccount)
        _kpi(
          theme,
          id: 'account-balance',
          title: 'Account Balance',
          value: _money(s.accountBalance),
          subtitle: 'Current balance',
          icon: Icons.account_balance_wallet_outlined,
          color: const Color(0xFF0891B2),
        ),
      if (a.showReward)
        _kpi(
          theme,
          id: 'reward-earnings',
          title: 'Reward Earnings',
          value: _money(s.rewardEarnings),
          subtitle: 'Current balance',
          icon: Icons.card_giftcard_rounded,
          color: Colors.orange.shade800,
        ),
      if (_access.showTotalBalance)
        _kpi(
          theme,
          id: 'total-balance',
          title: 'Total Balance',
          value: _money(s.totalBalance),
          subtitle:
              a.showAccount && a.showReward
                  ? 'Account + reward'
                  : (a.showAccount ? 'Account' : 'Reward'),
          icon: Icons.savings_outlined,
          color: const Color(0xFF0F766E),
        ),
      _kpi(
        theme,
        id: 'receipts',
        title: 'Receipts',
        value: '${s.receiptCount}',
        subtitle: 'Every receipt type',
        icon: Icons.receipt_rounded,
        color: const Color(0xFF2563EB),
      ),
      _kpi(
        theme,
        id: 'invoices',
        title: 'Invoices',
        value: '${s.invoiceCount}',
        subtitle: 'Created in this period',
        icon: Icons.description_rounded,
        color: const Color(0xFF7E22CE),
      ),
      _kpi(
        theme,
        id: 'orders',
        title: 'Orders',
        value: '${s.orderCount}',
        subtitle: 'Created in this period',
        icon: Icons.inventory_2_outlined,
        color: const Color(0xFF9333EA),
      ),
      _kpi(
        theme,
        id: 'order-total',
        title: 'Order Total',
        value: _money(s.orderTotal),
        subtitle: 'After discount, with VAT',
        icon: Icons.shopping_bag_outlined,
        color: const Color(0xFF9333EA),
      ),
      _kpi(
        theme,
        id: 'order-paid',
        title: 'Order Paid',
        value: _money(s.orderPaid),
        subtitle: 'Payments on the orders',
        icon: Icons.price_check_rounded,
        color: Colors.green.shade700,
      ),
      _kpi(
        theme,
        id: 'order-balance',
        title: 'Order Balance',
        value: _money(s.orderBalance),
        subtitle: 'Still to pay on the orders',
        icon: Icons.pending_actions_outlined,
        color: Colors.orange.shade800,
      ),
      _kpi(
        theme,
        id: 'first-purchase',
        title: 'First Purchase',
        value: _date(s.firstPurchase),
        subtitle: 'Sales receipt, invoice or order',
        icon: Icons.event_outlined,
        color: Colors.blueGrey,
      ),
      _kpi(
        theme,
        id: 'last-purchase',
        title: 'Last Purchase',
        value: _date(s.lastPurchase),
        subtitle: 'Sales receipt, invoice or order',
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
    Color? valueColor,
  }) {
    return Container(
      key: ValueKey('customer-kpi-$id'),
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
                color: valueColor ?? Colors.black87,
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

  Widget _sections(ThemeProvider theme, CustomerAnalysis a) {
    final s = a.summary;
    final green = Colors.green.shade700;
    final red = theme.lightModeColor.errorColor200;

    Widget ledgerRow(String kind, CustomerLedgerRow r, String direction) =>
        _recordRow(
          theme,
          key: ValueKey('customer-$kind-${r.uuid}'),
          title: r.title,
          subtitle: '${_dateTime(r.createdAt)} · $direction',
          amount: '${r.isAdd ? '+' : '-'}${_money(r.amount)}',
          amountColor: r.isAdd ? green : red,
          onTap: () => _open(() => _env.openLedgerEntry(context, r.entry)),
        );

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
                CustomerSeeAll.receiptsFilters(_uuid),
                _period,
              ),
            ),
        rows: [
          for (final r in a.recentReceipts)
            _recordRow(
              theme,
              key: ValueKey('customer-receipt-${r.uuid}'),
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
                CustomerSeeAll.invoiceFilters(_uuid, _period),
              ),
            ),
        rows: [
          for (final r in a.recentInvoices)
            _recordRow(
              theme,
              key: ValueKey('customer-invoice-${r.uuid}'),
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
                CustomerSeeAll.orderFilters(_uuid),
                _period,
              ),
            ),
        rows: [
          for (final r in a.recentOrders)
            _recordRow(
              theme,
              key: ValueKey('customer-order-${r.uuid}'),
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
      if (a.showReward)
        _section(
          theme,
          id: 'rewards',
          title: 'Reward Earnings',
          count: a.rewardTotals.count,
          emptyText: 'No reward earnings in this period.',
          onSeeAll:
              () => _open(
                () => _env.openLedgerTable(
                  context,
                  _customer,
                  CustomerLedgerKind.reward,
                  _period,
                ),
              ),
          rows: [
            for (final r in a.recentRewards)
              ledgerRow(
                'reward',
                r,
                CustomerRewardEarningsTable.directionLabel(r),
              ),
          ],
        ),
      if (a.showAccount)
        _section(
          theme,
          id: 'account',
          title: 'Account Transactions',
          count: a.accountTotals.count,
          emptyText: 'No account transactions in this period.',
          onSeeAll:
              () => _open(
                () => _env.openLedgerTable(
                  context,
                  _customer,
                  CustomerLedgerKind.account,
                  _period,
                ),
              ),
          rows: [
            for (final r in a.recentAccountTransactions)
              ledgerRow(
                'account',
                r,
                CustomerAccountTransactionsTable.directionLabel(r),
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
      key: ValueKey('customer-section-$id'),
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
                  key: ValueKey('customer-see-all-$id'),
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
    Color? amountColor,
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
                    color: amountColor ?? Colors.black87,
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
