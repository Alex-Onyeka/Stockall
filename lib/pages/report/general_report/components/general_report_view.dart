import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_expenses/temp_expenses_class.dart';
import 'package:stockall/classes/temp_main_receipt/temp_main_receipt.dart';
import 'package:stockall/classes/temp_product_slaes_record/temp_product_sale_record.dart';
import 'package:stockall/classes/temp_purchase/temp_purchase.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/refresh_functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/report/components/export/report_export_button.dart';
import 'package:stockall/pages/report/components/report_trend_chart.dart';
import 'package:stockall/pages/report/general_report/class/general_report_export_spec.dart';
import 'package:stockall/pages/report/general_report/class/general_report_logic.dart';
import 'package:stockall/pages/report/purchase_report/purchase_report_table/class/purchase_report_table_logic.dart';
import 'package:stockall/pages/report/purchase_report/purchase_report_table/components/purchase_report_table_view.dart';
import 'package:stockall/pages/report/purchase_report/purchase_report_table/purchase_report_table_page.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/components/receipts_report_filter_widgets.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/receipts_report_main_page.dart';
import 'package:stockall/providers/theme_provider.dart';

/// Everything the view reads from the app. [GeneralReportEnv.live]
/// uses the providers; tests pass their own, since the providers
/// need Supabase.
class GeneralReportEnv {
  final bool Function() canPickDate;

  /// Manage Cost Price: gross and net profit.
  final bool Function() canSeeCost;

  /// View Receipt Sales Report: revenue / gross profit open it.
  final bool Function() canOpenReceipts;

  /// Manage Purchases: purchases open the Purchase Report table.
  final bool Function() canOpenPurchases;

  /// Receipts the user may see (department and own-transactions
  /// scope applied, as the Receipts Report).
  final List<TempMainReceipt> Function() receipts;

  /// product_sales lines for receipts without `items`.
  final List<TempProductSaleRecord> Function() legacySales;

  /// Purchases the user may see, as the Purchase Report.
  final List<TempPurchase> Function() purchases;

  /// Purchases queued for deletion, left out as the Purchase
  /// Report does.
  final Set<String> Function() pendingDeletedPurchaseUuids;

  /// Expenses the user may see ([GeneralReportExpenses.scope]).
  final List<TempExpensesClass> Function() expenses;

  final Future<void> Function(
    BuildContext context, {
    required bool refreshFromStore,
  })
  load;

  final Future<void> Function(
    BuildContext context, {
    required bool refreshFromStore,
    ReceiptsReportPeriod? period,
  })?
  loadForPeriod;

  Future<void> loadWithPeriod(
    BuildContext context, {
    required bool refreshFromStore,
    required ReceiptsReportPeriod period,
  }) =>
      loadForPeriod != null
          ? loadForPeriod!(
            context,
            refreshFromStore: refreshFromStore,
            period: period,
          )
          : load(
            context,
            refreshFromStore: refreshFromStore,
          );

  /// Changes whenever the source data or the user's scope does.
  final String Function() signature;

  /// Subscribes the view to the providers it reads.
  final void Function(BuildContext context) listen;
  final String Function(BuildContext context, num amount)
  money;

  final Future<void> Function(
    BuildContext context,
    ReceiptsReportPeriod period,
  )
  openReceipts;

  final Future<void> Function(
    BuildContext context,
    ReceiptsReportPeriod period,
  )
  openPurchases;

  const GeneralReportEnv({
    required this.canPickDate,
    required this.canSeeCost,
    required this.canOpenReceipts,
    required this.canOpenPurchases,
    required this.receipts,
    required this.legacySales,
    required this.purchases,
    required this.pendingDeletedPurchaseUuids,
    required this.expenses,
    required this.load,
    this.loadForPeriod,
    required this.signature,
    required this.listen,
    required this.money,
    required this.openReceipts,
    required this.openPurchases,
  });

  factory GeneralReportEnv.live() {
    final purchaseEnv = PurchaseReportEnv.live();
    bool departmentsEnabled() =>
        shopSingle()?.manageDepartments == true;
    bool canViewAllDepartments() => authorization(
      authorized: Authorizations().viewAllDepartments,
    );
    String? currentDepartmentUuid() =>
        returnDepartmentProvider()
            .currentDepartment()
            ?.uuid;
    bool canViewAllTransactions() => authorization(
      authorized:
          Authorizations().viewAllTransactionRecords,
    );

    return GeneralReportEnv(
      canPickDate:
          () => authorization(
            authorized: Authorizations().viewDate,
          ),
      canSeeCost:
          () => authorization(
            authorized: Authorizations().manageCostPrice,
          ),
      canOpenReceipts:
          () => authorization(
            authorized:
                Authorizations().viewReceiptSalesReport,
          ),
      canOpenPurchases:
          () => authorization(
            authorized: Authorizations().managePurchases,
          ),
      receipts:
          () => ReceiptsReportAccess.scope(
            receipts:
                returnReceiptProviderSingle().receipts,
            departmentsEnabled: departmentsEnabled(),
            canViewAllDepartments: canViewAllDepartments(),
            currentDepartmentUuid: currentDepartmentUuid(),
            canViewAllTransactions:
                canViewAllTransactions(),
            currentUserId: currentUser().userId,
          ),
      legacySales:
          () => returnReceiptProviderSingle().mainSales,
      purchases: purchaseEnv.purchases,
      pendingDeletedPurchaseUuids:
          purchaseEnv.pendingDeletedUuids,
      expenses:
          () => GeneralReportExpenses.scope(
            expenses:
                returnExpensesProviderSingle().expensesMain,
            departmentsEnabled: departmentsEnabled(),
            canViewAllDepartments: canViewAllDepartments(),
            currentDepartmentUuid: currentDepartmentUuid(),
            canViewAllTransactions:
                canViewAllTransactions(),
            currentUserId: currentUser().userId,
          ),
      load: (context, {required refreshFromStore}) async {
        final sid = shopSingle()?.shopId;
        if (sid == null) return;
        final receipts = returnReceiptProviderSingle();
        final expenses = returnExpensesProviderSingle();
        if (refreshFromStore) {
          // Only this one can ask about unsynced records; the
          // expenses below go online only when they are synced.
          await RefreshFunctions(
            context,
          ).refreshReceipts(context, forceRefresh: true);
          if (!context.mounted) return;
          await purchaseEnv.load(
            context,
            refreshFromStore: true,
          );
          await expenses.getExpenses(
            sid,
            forceRefresh: true,
          );
          return;
        }
        // Local (offline) reads, only when nothing is loaded yet.
        if (receipts.receipts.isEmpty) {
          await receipts.loadReceiptsOffline(sid);
        }
        if (receipts.mainSales.isEmpty) {
          await receipts.loadProductSalesRecordOffline(sid);
        }
        if (!context.mounted) return;
        await purchaseEnv.load(
          context,
          refreshFromStore: false,
        );
        if (expenses.expensesMain.isEmpty) {
          await expenses.getExpensesOffline(sid);
        }
      },
      loadForPeriod: (
        context, {
        required refreshFromStore,
        period,
      }) async {
        final sid = shopSingle()?.shopId;
        if (sid == null) return;
        final receipts = returnReceiptProviderSingle();
        final expenses = returnExpensesProviderSingle();
        final fetchAll = period?.isAllTime ?? false;
        final startDate = period?.start;
        final endDate = period?.end ?? period?.start;
        if (refreshFromStore) {
          await RefreshFunctions(context).refreshReceipts(
            context,
            startDate: startDate,
            endDate: endDate,
            fetchAll: fetchAll,
            forceRefresh: true,
          );
          if (!context.mounted) return;
          if (period != null) {
            await purchaseEnv.loadWithPeriod(
              context,
              refreshFromStore: true,
              period: period,
            );
          } else {
            await purchaseEnv.load(
              context,
              refreshFromStore: true,
            );
          }
          await expenses.getExpenses(
            sid,
            startDate: startDate,
            endDate: endDate,
            fetchAll: fetchAll,
            forceRefresh: true,
          );
          return;
        }
        // Local (offline) reads, only when nothing is loaded yet.
        if (receipts.receipts.isEmpty) {
          await receipts.loadReceiptsOffline(sid);
        }
        if (receipts.mainSales.isEmpty) {
          await receipts.loadProductSalesRecordOffline(sid);
        }
        if (!context.mounted) return;
        if (period != null) {
          await purchaseEnv.loadWithPeriod(
            context,
            refreshFromStore: false,
            period: period,
          );
        } else {
          await purchaseEnv.load(
            context,
            refreshFromStore: false,
          );
        }
        if (expenses.expensesMain.isEmpty) {
          await expenses.getExpensesOffline(sid);
        }
        if (period != null && !period.isAllTime) {
          await receipts.loadReceipts(
            sid,
            startDate: startDate,
            endDate: endDate,
            forceRefresh: false,
          );
          await expenses.getExpenses(
            sid,
            startDate: startDate,
            endDate: endDate,
            forceRefresh: false,
          );
        }
      },
      signature: () {
        final receipts = returnReceiptProviderSingle();
        int latest = 0;
        int withItems = 0;
        double revenue = 0;
        for (final r in receipts.receipts) {
          final t = r.createdAt.millisecondsSinceEpoch;
          if (t > latest) latest = t;
          if (r.items?.isNotEmpty == true) withItems++;
          revenue += r.getTotalRevenue();
        }
        final expenses =
            returnExpensesProviderSingle().expensesMain;
        int latestExpense = 0;
        double spent = 0;
        for (final e in expenses) {
          final t =
              (e.updatedAt ?? e.createdDate)
                  ?.millisecondsSinceEpoch ??
              0;
          if (t > latestExpense) latestExpense = t;
          spent += e.amount;
        }
        return '${receipts.receipts.length}|$latest|$revenue|'
            '$withItems|${receipts.mainSales.length}|'
            '${purchaseEnv.signature()}|'
            '${expenses.length}|$latestExpense|$spent|'
            '${currentDepartmentUuid()}|'
            '${currentUser().userId}|${departmentsEnabled()}';
      },
      listen: (context) {
        returnReceiptProvider(context);
        purchaseEnv.listen(context);
        returnExpensesProvider(context);
      },
      money:
          (context, amount) => formatMoneyBig(
            amount: amount,
            context: context,
          ),
      openReceipts:
          (context, period) => Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => ReceiptsReportMainPage(
                    initialPeriod: period,
                  ),
            ),
          ),
      openPurchases:
          (context, period) => Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => PurchaseReportTablePage(
                    initialPeriod: period,
                  ),
            ),
          ),
    );
  }
}

/// Shared body of the General Report page (desktop + mobile):
/// money in, money out and profit for one period, each figure from
/// the report it opens.
class GeneralReportView extends StatefulWidget {
  final bool isDesktop;
  final ReceiptsReportPeriod? initialPeriod;

  /// Null in the app: [GeneralReportEnv.live] is used.
  final GeneralReportEnv? env;

  const GeneralReportView({
    super.key,
    required this.isDesktop,
    this.initialPeriod,
    this.env,
  });

  @override
  State<GeneralReportView> createState() =>
      _GeneralReportViewState();
}

class _GeneralReportViewState
    extends State<GeneralReportView> {
  late final GeneralReportEnv _env;
  late ReceiptsReportPeriod _period;

  bool _loading = true;
  String? _error;
  GeneralReportFigures? _figures;
  GeneralReportChanges _changes = GeneralReportChanges.none;
  GeneralReportTrend _trend = GeneralReportTrend.empty;
  String _signature = '';

  static const Color _upColor = Color(0xFF059669);
  static const Color _downColor = Color(0xFFDC2626);
  static const Color _expenseColor = Color(0xFFD97706);
  static const Color _netColor = Color(0xFF7C3AED);

  @override
  void initState() {
    super.initState();
    _env = widget.env ?? GeneralReportEnv.live();
    // Without View Date the page only shows today.
    _period =
        _env.canPickDate()
            ? widget.initialPeriod ??
                ReceiptsReportPeriod.today()
            : ReceiptsReportPeriod.today();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load(refreshFromStore: false);
    });
  }

  // ---------------------------------------------------------------
  // data
  // ---------------------------------------------------------------

  bool get _profitVisible => _env.canSeeCost();

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
    final receiptRows = ReceiptsReportRowBuilder.buildAll(
      receipts: _env.receipts(),
      legacySales: _env.legacySales(),
    );
    final purchaseRows = PurchaseReportRowBuilder.buildAll(
      purchases: _env.purchases(),
      pendingDeletedUuids:
          _env.pendingDeletedPurchaseUuids(),
    );
    final expenses = _env.expenses();
    final profitVisible = _profitVisible;

    GeneralReportFigures figuresFor(
      ReceiptsReportPeriod p,
    ) => GeneralReportFigures.build(
      receiptRows: receiptRows,
      purchaseRows: purchaseRows,
      expenses: expenses,
      period: p,
      profitVisible: profitVisible,
    );

    final figures = figuresFor(_period);
    final previous = GeneralReportPeriods.previous(_period);
    _figures = figures;
    _changes = GeneralReportChanges.between(
      figures,
      previous == null ? null : figuresFor(previous),
    );
    _trend = GeneralReportTrendBuilder.build(
      receiptRows: figures.receiptRows,
      expenses: figures.expenses,
      period: _period,
      profitVisible: profitVisible,
    );
    _signature = _env.signature();
  }

  void _rebuildInState() {
    try {
      _rebuild();
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
  }

  void _setPeriod(ReceiptsReportPeriod p) {
    setState(() {
      _period = p;
      _rebuildInState();
    });
    if (!p.isAllTime) {
      _load(refreshFromStore: false);
    }
  }

  Future<void> _open(
    Future<void> Function(
      BuildContext context,
      ReceiptsReportPeriod period,
    )
    open,
  ) async {
    await open(context, _period);
    // Picks up sales, purchases or edits made in the report.
    if (mounted) setState(_rebuildInState);
  }

  // ---------------------------------------------------------------
  // formatting
  // ---------------------------------------------------------------

  String _money(num v) => _env.money(context, v);

  static String _count(int n, String noun) =>
      '$n $noun${n == 1 ? '' : 's'}';

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
    // Listen, so sales, purchases, expenses and sync update the
    // report.
    _env.listen(context);

    if (!_loading && _error == null) {
      final sig = _env.signature();
      if (sig != _signature) _rebuildInState();
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
        title: 'General Report',
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
    final figures = _figures;
    if (_error != null || figures == null) {
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

    final periodButton = ReceiptsReportPeriodButton(
      theme: theme,
      period: _period,
      enabled: _env.canPickDate(),
      onChanged: _setPeriod,
    );
    final toolbar = Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 6,
      children: [
        periodButton,
        ReportExportButton(
          buildSpec:
              () => generalReportExportSpec(
                figures: figures,
                changes: _changes,
                trend: _trend,
                period: _period,
                currency: currencySymbol(context: context),
              ),
        ),
      ],
    );
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
          widget.isDesktop
              ? Align(
                alignment: Alignment.centerLeft,
                child: toolbar,
              )
              : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: toolbar,
              ),
          ..._notes(figures),
          gap,
          ..._sections(theme, figures),
          _trendCard(theme, figures.profitVisible),
          gap,
        ],
      ),
    );
  }

  List<Widget> _notes(GeneralReportFigures f) => [
    for (final n in generalReportNotes(f)) _note(n),
  ];

  Widget _note(String text) {
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
              text,
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
  // sections
  // ---------------------------------------------------------------

  List<Widget> _sections(
    ThemeProvider theme,
    GeneralReportFigures f,
  ) {
    final c = _changes;
    final openReceipts =
        _env.canOpenReceipts()
            ? () => _open(_env.openReceipts)
            : null;
    final openPurchases =
        _env.canOpenPurchases()
            ? () => _open(_env.openPurchases)
            : null;

    Widget grossProfit(String id) => _figureCard(
      theme,
      id: id,
      title: 'Gross Profit',
      amount: f.grossProfit!,
      subtitle: 'Selling price − cost',
      icon: Icons.trending_up_rounded,
      color: _upColor,
      change: c.grossProfit,
      higherIsBetter: true,
      onTap: openReceipts,
    );

    return [
      _section(
        theme,
        id: 'money-in',
        title: 'Money In',
        cards: [
          _figureCard(
            theme,
            id: 'revenue',
            title: 'Total Revenue',
            amount: f.totalRevenue,
            subtitle: _count(f.receiptCount, 'receipt'),
            icon: Icons.payments_outlined,
            color: theme.lightModeColor.prColor300,
            change: c.revenue,
            higherIsBetter: true,
            onTap: openReceipts,
          ),
          if (f.profitVisible) grossProfit('gross-profit'),
        ],
      ),
      _section(
        theme,
        id: 'money-out',
        title: 'Money Out',
        cards: [
          _figureCard(
            theme,
            id: 'purchases',
            title: 'Total Purchases',
            amount: f.totalPurchases,
            subtitle: _count(f.purchaseCount, 'purchase'),
            icon: Icons.shopping_bag_outlined,
            color: Colors.blueGrey,
            change: c.purchases,
            higherIsBetter: null,
            onTap: openPurchases,
          ),
          _figureCard(
            theme,
            id: 'expenses',
            title: 'Total Expenses',
            amount: f.totalExpenses,
            subtitle: _count(f.expenseCount, 'expense'),
            icon: Icons.receipt_long_rounded,
            color: _expenseColor,
            change: c.expenses,
            higherIsBetter: false,
            onTap: null,
          ),
        ],
      ),
      if (f.profitVisible)
        _section(
          theme,
          id: 'profit',
          title: 'Profit',
          cards: [
            grossProfit('profit-gross-profit'),
            _figureCard(
              theme,
              id: 'net-profit',
              title: 'Net Profit',
              amount: f.netProfit!,
              subtitle: 'Gross profit − expenses',
              icon: Icons.account_balance_wallet_outlined,
              color: _netColor,
              change: c.netProfit,
              higherIsBetter: true,
              onTap: null,
              negativeIsRed: true,
            ),
          ],
        ),
    ];
  }

  Widget _section(
    ThemeProvider theme, {
    required String id,
    required String title,
    required List<Widget> cards,
  }) {
    return Padding(
      key: ValueKey('general-section-$id'),
      padding: EdgeInsets.only(
        bottom: widget.isDesktop ? 16 : 12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: theme.mobileTexts.b1.fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              const spacing = 10.0;
              final perRow = widget.isDesktop ? 2 : 1;
              final width =
                  (constraints.maxWidth -
                      spacing * (perRow - 1)) /
                  perRow;
              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  for (final card in cards)
                    SizedBox(width: width, child: card),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  /// [higherIsBetter] colours the change: true green when up, false
  /// green when down, null grey.
  Widget _figureCard(
    ThemeProvider theme, {
    required String id,
    required String title,
    required double amount,
    required String subtitle,
    required IconData icon,
    required Color color,
    required GeneralReportChange? change,
    required bool? higherIsBetter,
    required VoidCallback? onTap,
    bool negativeIsRed = false,
  }) {
    final key = 'general-card-$id';
    return InkWell(
      key: ValueKey(key),
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: _card,
        child: Row(
          spacing: 8,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    spacing: 8,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: color.withAlpha(25),
                          borderRadius:
                              BorderRadius.circular(6),
                        ),
                        child: Icon(
                          icon,
                          size: 16,
                          color: color,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b4
                                    .fontSize,
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
                      _money(amount),
                      key: ValueKey('$key-amount'),
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.h4.fontSize,
                        fontWeight: FontWeight.bold,
                        color:
                            negativeIsRed && amount < 0
                                ? _downColor
                                : Colors.black87,
                      ),
                    ),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.b4.fontSize,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  if (change != null)
                    _changeLine(
                      theme,
                      key: '$key-change',
                      change: change,
                      higherIsBetter: higherIsBetter,
                    ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.chevron_right_rounded,
                key: ValueKey('$key-chevron'),
                color: Colors.grey.shade400,
              ),
          ],
        ),
      ),
    );
  }

  Widget _changeLine(
    ThemeProvider theme, {
    required String key,
    required GeneralReportChange change,
    required bool? higherIsBetter,
  }) {
    final flat = !change.isUp && !change.isDown;
    final Color color;
    if (flat || higherIsBetter == null) {
      color = Colors.grey.shade600;
    } else {
      color =
          change.isUp == higherIsBetter
              ? _upColor
              : _downColor;
    }
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        generalReportChangeText(change, _money),
        key: ValueKey(key),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: theme.mobileTexts.b4.fontSize,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------
  // trend
  // ---------------------------------------------------------------

  /// [profitVisible] as the trend was built with.
  Widget _trendCard(
    ThemeProvider theme,
    bool profitVisible,
  ) {
    final trend = _trend;
    final points = trend.points;
    return Container(
      key: const ValueKey('general-trend'),
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: _card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Trend',
                style: TextStyle(
                  fontSize: theme.mobileTexts.b1.fontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                '${reportTrendIntervalLabel(trend.interval)}, by business day',
                style: TextStyle(
                  fontSize: theme.mobileTexts.b4.fontSize,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
          if (points.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'No sales or expenses in this period.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b3.fontSize,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
            )
          else
            ReportTrendChart(
              starts: [for (final p in points) p.start],
              interval: trend.interval,
              money: _money,
              series: [
                ReportTrendSeries(
                  label: 'Revenue',
                  color: theme.lightModeColor.prColor300,
                  values: [
                    for (final p in points) p.revenue,
                  ],
                ),
                if (profitVisible)
                  ReportTrendSeries(
                    label: 'Gross profit',
                    color: _upColor,
                    values: [
                      for (final p in points)
                        p.grossProfit!,
                    ],
                  ),
                ReportTrendSeries(
                  label: 'Expenses',
                  color: _expenseColor,
                  values: [
                    for (final p in points) p.expenses,
                  ],
                ),
                if (profitVisible)
                  ReportTrendSeries(
                    label: 'Net profit',
                    color: _netColor,
                    values: [
                      for (final p in points) p.netProfit!,
                    ],
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
