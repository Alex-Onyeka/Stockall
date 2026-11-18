import 'package:flutter/material.dart';
import 'package:stockall/classes/checkout_response.dart';
import 'package:stockall/classes/temp_customer_account_receipts/customer_account_receipts.dart';
import 'package:stockall/classes/temp_customers/temp_customers_class.dart';
import 'package:stockall/classes/temp_invoices/temp_invoices.dart';
import 'package:stockall/classes/temp_main_receipt/temp_main_receipt.dart';
import 'package:stockall/classes/temp_orders/orders.dart';
import 'package:stockall/components/alert_dialogues/dialog_template.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/refresh_functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/customers/customer_details_page/components/customer_transactions_section.dart';
import 'package:stockall/pages/report/components/export/report_export_button.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/report_pager.dart';
import 'package:stockall/pages/report/components/report_pill.dart';
import 'package:stockall/pages/report/components/report_range_fields.dart';
import 'package:stockall/pages/report/components/report_searchable_dropdown.dart';
import 'package:stockall/pages/report/customer_report/customer_account_transactions/customer_account_transactions_page.dart';
import 'package:stockall/pages/report/customer_report/customer_analysis/customer_analysis_page.dart';
import 'package:stockall/pages/report/customer_report/customer_reward_earnings/customer_reward_earnings_page.dart';
import 'package:stockall/pages/report/customer_report/customer_report_table/class/customer_report_export_spec.dart';
import 'package:stockall/pages/report/customer_report/customer_report_table/class/customer_report_table_logic.dart';
import 'package:stockall/pages/report/invoice_report/invoice_report_table/class/invoice_report_table_logic.dart';
import 'package:stockall/pages/report/invoice_report/invoice_report_table/invoice_report_table_page.dart';
import 'package:stockall/pages/report/order_report/order_report_table/class/order_report_table_logic.dart';
import 'package:stockall/pages/report/order_report/order_report_table/order_report_table_page.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/components/receipts_report_filter_widgets.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/receipts_report_main_page.dart';
import 'package:stockall/pages/sales/make_sales/receipt_page/receipt_page.dart';
import 'package:stockall/providers/theme_provider.dart';

/// Everything the customer report screens read from the app.
/// [CustomerReportEnv.live] uses the providers; tests pass their
/// own, since the providers need Supabase.
class CustomerReportEnv {
  /// Shop settings and the user's permissions.
  final CustomerReportAccess Function() access;

  /// Loaded data. Read on every rebuild.
  final CustomerReportSource Function() source;

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
          : load(context, refreshFromStore: refreshFromStore);

  /// Changes whenever the source data, settings or the user's
  /// scope do.
  final String Function() signature;

  /// Subscribes the view to the providers it reads.
  final void Function(BuildContext context) listen;
  final String Function(BuildContext context, num amount) money;

  /// Opens the Customer Analysis page on [period].
  final Future<void> Function(
    BuildContext context,
    TempCustomersClass customer,
    ReceiptsReportPeriod period,
  )
  openAnalysis;

  // Detail pages of one record. Each returns when the user comes
  // back, so the caller can rebuild.
  final Future<void> Function(BuildContext context, TempMainReceipt r)
  openReceipt;
  final Future<void> Function(BuildContext context, TempInvoice i) openInvoice;
  final Future<void> Function(BuildContext context, Orders o) openOrder;

  /// Read only: the report never deletes an entry.
  final Future<void> Function(
    BuildContext context,
    CustomerAccountReceipts entry,
  )
  openLedgerEntry;

  // "See all": each report's own table, on the given set.
  final Future<void> Function(
    BuildContext context,
    ReceiptsReportFilters filters,
    ReceiptsReportPeriod period,
  )
  openReceiptsTable;

  /// The invoice table has no period parameter: the period is
  /// `filters.dateRange`.
  final Future<void> Function(
    BuildContext context,
    InvoiceReportFilters filters,
  )
  openInvoiceTable;
  final Future<void> Function(
    BuildContext context,
    OrderReportFilters filters,
    ReceiptsReportPeriod period,
  )
  openOrderTable;

  /// Reward Earnings or Account Transactions of [customer].
  final Future<void> Function(
    BuildContext context,
    TempCustomersClass customer,
    CustomerLedgerKind kind,
    ReceiptsReportPeriod period,
  )
  openLedgerTable;

  const CustomerReportEnv({
    required this.access,
    required this.source,
    required this.load,
    this.loadForPeriod,
    required this.signature,
    required this.listen,
    required this.money,
    required this.openAnalysis,
    required this.openReceipt,
    required this.openInvoice,
    required this.openOrder,
    required this.openLedgerEntry,
    required this.openReceiptsTable,
    required this.openInvoiceTable,
    required this.openOrderTable,
    required this.openLedgerTable,
  });

  factory CustomerReportEnv.live() {
    CustomerReportAccess access() {
      final s = shopSingle();
      return CustomerReportAccess(
        departmentsEnabled: s?.manageDepartments == true,
        canViewAllDepartments: authorization(
          authorized: Authorizations().viewAllDepartments,
        ),
        currentDepartmentUuid:
            returnDepartmentProvider().currentDepartment()?.uuid,
        canViewAllTransactions: authorization(
          authorized: Authorizations().viewAllTransactionRecords,
        ),
        currentUserId: currentUser().userId,
        manageCustomerAccount: s?.manageCustomerAccount == true,
        manageCustomerReward: s?.manageCustomerReward == true,
        canViewCustomersAccount: authorization(
          authorized: Authorizations().viewCustomersAccount,
        ),
        canPickDate: authorization(authorized: Authorizations().viewDate),
      );
    }

    Future<void> loadPeriod(
      BuildContext context, {
      required bool refreshFromStore,
      ReceiptsReportPeriod? period,
    }) async {
      final sid = shopSingle()?.shopId;
      if (sid == null) return;
      final receipts = returnReceiptProviderSingle();
      final fetchAll = period?.isAllTime ?? false;
      final startDate = period?.start;
      final endDate = period?.end ?? period?.start;
      if (refreshFromStore) {
        final refresh = RefreshFunctions(context);
        await refresh.refreshReceipts(
          context,
          startDate: startDate,
          endDate: endDate,
          fetchAll: fetchAll,
          forceRefresh: true,
        );
        if (!context.mounted) return;
        await refresh.refreshInvoices(
          context,
          startDate: startDate,
          endDate: endDate,
          fetchAll: fetchAll,
          forceRefresh: true,
        );
        if (!context.mounted) return;
        // Also pulls the customer account ledger.
        await refresh.refreshCustomers(context);
        await returnOrdersProvider().loadOrders(
          sid,
          startDate: startDate,
          endDate: endDate,
          fetchAll: fetchAll,
          forceRefresh: true,
        );
        return;
      }
      // Local (offline) reads, only when nothing is loaded yet.
      if (returnCustomersSingle().customers.isEmpty) {
        await returnCustomersSingle().fetchCustomersOffline();
      }
      final ledger = returnCustomerAccountReceiptsProvider();
      if (ledger.customerAccountReceipts.isEmpty) {
        await ledger.getCustomerAccountReceiptsOffline();
      }
      if (receipts.receipts.isEmpty) {
        await receipts.loadReceiptsOffline(sid);
      }
      if (receipts.mainSales.isEmpty) {
        await receipts.loadProductSalesRecordOffline(sid);
      }
      if (returnInvoicesProvider().invoicesMain.isEmpty) {
        await returnInvoicesProvider().loadInvoicesOffline(sid);
      }
      if (returnOrdersProvider().orders.isEmpty) {
        await returnOrdersProvider().loadOrdersOffline(sid);
      }
      if (period != null && !period.isAllTime) {
        await receipts.loadReceipts(
          sid,
          startDate: startDate,
          endDate: endDate,
          forceRefresh: false,
        );
        await returnInvoicesProvider().loadInvoices(
          sid,
          startDate: startDate,
          endDate: endDate,
          forceRefresh: false,
        );
        await returnOrdersProvider().loadOrders(
          sid,
          startDate: startDate,
          endDate: endDate,
          forceRefresh: false,
        );
      }
    }

    return CustomerReportEnv(
      access: access,
      source: () {
        final receipts = returnReceiptProviderSingle();
        return CustomerReportSource(
          customers: returnCustomersSingle().customersMain(),
          receipts: receipts.receipts,
          productSales: receipts.mainSales,
          invoices: returnInvoicesProvider().invoicesMain,
          orders: returnOrdersProvider().orders,
          ledger:
              returnCustomerAccountReceiptsProvider().customerAccountReceipts,
          shopId: shopSingle()?.shopId,
        );
      },
      load: (context, {required refreshFromStore}) async {
        await loadPeriod(
          context,
          refreshFromStore: refreshFromStore,
        );
      },
      loadForPeriod: (
        context, {
        required refreshFromStore,
        period,
      }) async {
        await loadPeriod(
          context,
          refreshFromStore: refreshFromStore,
          period: period,
        );
      },
      signature: () {
        int latest(Iterable<DateTime> times) {
          int out = 0;
          for (final t in times) {
            final ms = t.millisecondsSinceEpoch;
            if (ms > out) out = ms;
          }
          return out;
        }

        final customers = returnCustomersSingle().customersMain();
        double balances = 0;
        for (final c in customers) {
          balances += (c.balance ?? 0) + (c.cashReward ?? 0);
        }
        final receipts = returnReceiptProviderSingle();
        double revenue = 0;
        for (final r in receipts.receipts) {
          revenue += r.getTotalRevenue();
        }
        final invoices = returnInvoicesProvider().invoicesMain;
        final orders = returnOrdersProvider().orders;
        final ledger =
            returnCustomerAccountReceiptsProvider().customerAccountReceipts;
        final a = access();
        return '${customers.length}|$balances|'
            '${receipts.receipts.length}|$revenue|'
            '${latest(receipts.receipts.map((r) => r.createdAt))}|'
            '${receipts.mainSales.length}|'
            '${invoices.length}|'
            '${latest(invoices.map((i) => i.updatedAt ?? i.createdAt))}|'
            '${orders.length}|'
            '${latest(orders.map((o) => o.updatedAt ?? o.createdAt))}|'
            '${ledger.length}|'
            '${a.currentDepartmentUuid}|${a.currentUserId}|'
            '${a.departmentsEnabled}|${a.showAccount}|${a.showReward}';
      },
      listen: (context) {
        returnReceiptProvider(context);
        returnInvoicesProvider(context: context);
        returnOrdersProvider(context: context);
        returnCustomers(context);
        returnCustomerAccountReceiptsProvider(context: context);
        returnDepartmentProvider(context: context);
        shop(context);
      },
      money:
          (context, amount) => formatMoneyBig(amount: amount, context: context),
      openAnalysis:
          (context, customer, period) => _push(
            context,
            CustomerAnalysisPage(customer: customer, initialPeriod: period),
          ),
      openReceipt:
          (context, r) => _push(
            context,
            ReceiptPage(response: CheckoutResponse(receipt: r), isMain: false),
          ),
      openInvoice:
          (context, i) => _push(
            context,
            ReceiptPage(response: CheckoutResponse(invoice: i), isMain: false),
          ),
      openOrder:
          (context, o) => _push(
            context,
            ReceiptPage(response: CheckoutResponse(order: o), isMain: false),
          ),
      openLedgerEntry: (context, entry) {
        final theme = returnTheme(context, listen: false);
        // The customer details page's dialog, without Delete.
        return showDialog<void>(
          context: context,
          builder: (dialogContext) {
            return DialogTemplate(
              theme: theme,
              message: 'View This Transaction Details',
              title: 'Transaction Details',
              action: () {},
              showBottomActionButtons: false,
              topRightWidget: Material(
                type: MaterialType.transparency,
                child: InkWell(
                  onTap: () => Navigator.of(dialogContext).pop(),
                  mouseCursor: SystemMouseCursors.click,
                  child: const Padding(
                    padding: EdgeInsets.all(3.0),
                    child: Icon(Icons.clear),
                  ),
                ),
              ),
              widget: SizedBox(
                height: screenHeight(dialogContext) - 250,
                child: CustomterTransactionDetailsWidget(accountReceipt: entry),
              ),
            );
          },
        );
      },
      openReceiptsTable:
          (context, filters, period) => _push(
            context,
            ReceiptsReportMainPage(
              initialFilters: filters,
              initialPeriod: period,
            ),
          ),
      openInvoiceTable:
          (context, filters) =>
              _push(context, InvoiceReportTablePage(initialFilters: filters)),
      openOrderTable:
          (context, filters, period) => _push(
            context,
            OrderReportTablePage(
              initialFilters: filters,
              initialPeriod: period,
            ),
          ),
      openLedgerTable:
          (context, customer, kind, period) => _push(
            context,
            ledgerTablePage(customer: customer, kind: kind, period: period),
          ),
    );
  }

  /// The Reward Earnings or Account Transactions table of
  /// [customer] on [period]. Null [env] is [CustomerReportEnv.live].
  static Widget ledgerTablePage({
    required TempCustomersClass customer,
    required CustomerLedgerKind kind,
    required ReceiptsReportPeriod period,
    CustomerReportEnv? env,
  }) {
    switch (kind) {
      case CustomerLedgerKind.reward:
        return CustomerRewardEarningsPage(
          customer: customer,
          initialPeriod: period,
          env: env,
        );
      case CustomerLedgerKind.account:
        return CustomerAccountTransactionsPage(
          customer: customer,
          initialPeriod: period,
          env: env,
        );
    }
  }

  static Future<void> _push(BuildContext context, Widget page) {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }
}

class _Col {
  final String label;
  final double width;
  final CustomerReportSortField sort;
  final TextAlign align;
  final Widget Function(CustomerReportRow row) cell;

  /// Cell of the totals row; empty when null.
  final Widget Function(CustomerReportTotals totals)? total;

  const _Col({
    required this.label,
    required this.width,
    required this.sort,
    required this.cell,
    this.align = TextAlign.center,
    this.total,
  });
}

/// Shared body of the Customer Report Table page (desktop +
/// mobile).
///
/// [initialFilters] and [initialPeriod] let another page open the
/// table on a given set. Without the View Date permission the
/// period is always today.
class CustomerReportTableView extends StatefulWidget {
  final bool isDesktop;
  final CustomerReportFilters? initialFilters;
  final ReceiptsReportPeriod? initialPeriod;

  /// Null in the app: [CustomerReportEnv.live] is used.
  final CustomerReportEnv? env;

  const CustomerReportTableView({
    super.key,
    required this.isDesktop,
    this.initialFilters,
    this.initialPeriod,
    this.env,
  });

  @override
  State<CustomerReportTableView> createState() =>
      _CustomerReportTableViewState();
}

class _CustomerReportTableViewState extends State<CustomerReportTableView> {
  late final CustomerReportEnv _env;
  late final CustomerReportFilters _filters;
  final _searchCtrl = TextEditingController();
  final _hScroll = ScrollController();
  final _vScroll = ScrollController();

  CustomerReportSortField _sortField = CustomerReportSortField.name;
  bool _ascending = true;
  int _page = 1;
  bool _showFilters = false;
  bool _toolbarIsOpen = false;

  late ReceiptsReportPeriod _period;
  late CustomerReportAccess _access;

  bool _loading = true;
  String? _error;

  CustomerReportBase? _base;
  List<CustomerReportRow> _rows = [];
  CustomerReportPage? _result;
  String _signature = '';

  // Every filtered, sorted row, for the export.
  List<CustomerReportRow> _sortedRows = [];

  List<CustomerReportFilterOption> _countryOptions = [];
  List<CustomerReportFilterOption> _stateOptions = [];

  @override
  void initState() {
    super.initState();
    _env = widget.env ?? CustomerReportEnv.live();
    _access = _env.access();
    _filters = widget.initialFilters?.copy() ?? CustomerReportFilters();
    _searchCtrl.text = _filters.search;
    _period =
        _access.canPickDate
            ? (widget.initialPeriod ?? const ReceiptsReportPeriod.allTime())
            : _access.initialPeriod();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load(refreshFromStore: false);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _hScroll.dispose();
    _vScroll.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------
  // data
  // ---------------------------------------------------------------

  bool get _showAccount => _access.showAccount;

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
      _rebuildBase();
      _recompute();
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

  void _rebuildBase() {
    _access = _env.access();
    _base = CustomerReportBase.build(source: _env.source(), access: _access);
    _signature = _env.signature();
    _rebuildRows();
  }

  /// Rows of the current period.
  void _rebuildRows() {
    final base = _base;
    if (base == null) return;
    _rows = CustomerReportRowBuilder.buildAll(
      CustomerReportSlice.of(base, _period),
    );
    _countryOptions = CustomerReportOptions.countries(_rows);
  }

  void _recompute() {
    _stateOptions = CustomerReportOptions.states(
      _rows,
      countryKey: _filters.countryKey,
    );
    final stateKey = _filters.stateKey;
    if (stateKey != null && !_stateOptions.any((o) => o.key == stateKey)) {
      _filters.stateKey = null;
    }
    final sorted = CustomerReportQuery.filterAndSort(
      rows: _rows,
      filters: _filters,
      sortField: _sortField,
      ascending: _ascending,
      access: _access,
    );
    _sortedRows = sorted;
    final page = CustomerReportQuery.paginate(sorted, _page);
    _page = page.page;
    _result = page;
  }

  ReportExportSpec _exportSpec() {
    return customerReportExportSpec(
      rows: _sortedRows,
      filters: _filters,
      countryOptions: _countryOptions,
      stateOptions: _stateOptions,
      sortField: _sortField,
      ascending: _ascending,
      access: _access,
      period: _period,
      currency: currencySymbol(context: context),
    );
  }

  void _apply(VoidCallback change, {bool resetPage = true}) {
    setState(() {
      change();
      if (resetPage) _page = 1;
      try {
        _recompute();
        _error = null;
      } catch (e) {
        _error = e.toString();
      }
    });
  }

  void _goToPage(int p) {
    final res = _result;
    if (res == null || p < 1 || p > res.totalPages || p == res.page) {
      return;
    }
    _apply(() => _page = p, resetPage: false);
    if (_vScroll.hasClients) {
      _vScroll.jumpTo(0);
    }
  }

  CustomerReportSortField get _visibleSort =>
      CustomerReportQuery.visibleSort(_sortField, _access);

  void _setSort(CustomerReportSortField f) {
    _apply(() {
      if (_visibleSort == f) {
        _ascending = !_ascending;
      } else {
        _sortField = f;
        // Text A-Z first; amounts largest first.
        _ascending =
            f == CustomerReportSortField.name ||
            f == CustomerReportSortField.phone ||
            f == CustomerReportSortField.location;
      }
    });
  }

  /// Clears the search and filters only: the period stays.
  void _resetAll() {
    _searchCtrl.clear();
    _apply(_filters.clearAll);
  }

  void _setPeriod(ReceiptsReportPeriod p) {
    _apply(() {
      _period = p;
      _rebuildRows();
    });
    if (!p.isAllTime) {
      _load(refreshFromStore: false);
    }
  }

  Future<void> _openAnalysis(CustomerReportRow row) async {
    await _env.openAnalysis(context, row.customer, _period);
    // Picks up anything changed while the analysis was open.
    if (mounted) {
      setState(() {
        try {
          _rebuildBase();
          _recompute();
          _error = null;
        } catch (e) {
          _error = e.toString();
        }
      });
    }
  }

  // ---------------------------------------------------------------
  // build
  // ---------------------------------------------------------------

  String _money(num v) => _env.money(context, v);

  @override
  Widget build(BuildContext context) {
    final theme = returnTheme(context);
    // Listen, so sales, payments and sync update the table.
    _env.listen(context);

    if (!_loading && _error == null) {
      final sig = _env.signature();
      if (sig != _signature) {
        try {
          _rebuildBase();
          _recompute();
        } catch (e) {
          _error = e.toString();
        }
      }
    }

    final res = _result;
    return Scaffold(
      appBar: appBar(
        context: context,
        title: 'Customer Report',
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
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: widget.isDesktop ? 20 : 12),
        child: Column(
          children: [
            const SizedBox(height: 8),
            _toolbar(theme),
            if (_showFilters) _filterPanel(theme),
            _activeChips(theme),
            _notes(),
            Expanded(child: _content(theme)),
            if (!_loading && _error == null && res != null)
              ReportPager(
                theme: theme,
                page: res.page,
                totalPages: res.totalPages,
                totalCount: res.totalCount,
                firstIndex: res.firstIndex,
                lastIndex: res.lastIndex,
                itemLabel: 'customers',
                onPage: _goToPage,
              ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }

  Widget _content(ThemeProvider theme) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
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
              onPressed: () => _load(refreshFromStore: false),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
            ),
          ],
        ),
      );
    }
    final res = _result;
    if (res == null || res.totalCount == 0) {
      final hasFilters = _filters.hasAnything(showAccount: _showAccount);
      return Padding(
        padding: const EdgeInsets.only(top: 60),
        child: EmptyWidgetDisplayOnly(
          title: hasFilters ? 'No Matching Customers' : 'Empty List',
          subText:
              hasFilters
                  ? 'No customer matches your search and filters'
                  : 'No customer has been added yet',
          theme: theme,
          height: 35,
          icon: Icons.clear,
          altAction: hasFilters ? _resetAll : null,
          altActionText: hasFilters ? 'Clear all filters' : null,
          altIcon: hasFilters ? Icons.filter_alt_off : null,
        ),
      );
    }
    return _table(theme, res);
  }

  // ---------------------------------------------------------------
  // toolbar / filters
  // ---------------------------------------------------------------

  Widget _toolbar(ThemeProvider theme) {
    final active = _filters.activeCount(showAccount: _showAccount);
    final accent = theme.lightModeColor.prColor300;
    return Wrap(
      spacing: 2,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 6.0),
          child: SizedBox(
            width: widget.isDesktop ? 320 : double.infinity,
            height: 38,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => _apply(() => _filters.search = v),
                    decoration: InputDecoration(
                      hintText: 'Search name, phone or address',
                      hintStyle: TextStyle(
                        fontSize: theme.mobileTexts.b3.fontSize,
                      ),
                      prefixIcon: const Icon(Icons.search, size: 20),
                      suffixIcon:
                          _searchCtrl.text.isEmpty
                              ? null
                              : IconButton(
                                icon: const Icon(Icons.close, size: 18),
                                onPressed: () {
                                  _searchCtrl.clear();
                                  _apply(() => _filters.search = '');
                                },
                              ),
                      contentPadding: EdgeInsets.zero,
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                if (screenWidth(context) < mobileScreen) ...[
                  const SizedBox(width: 5),
                  InkWell(
                    onTap:
                        () => setState(() => _toolbarIsOpen = !_toolbarIsOpen),
                    mouseCursor: SystemMouseCursors.click,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10.0, 6, 6, 6),
                      child: Row(
                        spacing: 1,
                        children: [
                          Text(
                            style: TextStyle(
                              fontSize: theme.mobileTexts.b4.fontSize,
                            ),
                            _toolbarIsOpen ? 'Hide' : 'View',
                          ),
                          Icon(
                            _toolbarIsOpen
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (_toolbarIsOpen || screenWidth(context) > mobileScreen) ...[
          // Scrolls on narrow screens, where a range label is wider
          // than the page.
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ReceiptsReportPeriodButton(
              theme: theme,
              period: _period,
              enabled: _access.canPickDate,
              onChanged: _setPeriod,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 6.0, right: 5),
            child: ReportPill(
              theme: theme,
              icon: Icons.tune_rounded,
              label: active == 0 ? 'Filters' : 'Filters ($active)',
              highlighted: _showFilters || active > 0,
              onTap: () => setState(() => _showFilters = !_showFilters),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 5),
            child: ReportExportButton(buildSpec: _exportSpec),
          ),
          if (_filters.hasAnything(showAccount: _showAccount))
            ReportPill(
              theme: theme,
              icon: Icons.filter_alt_off,
              label: 'Reset All Filters',
              onTap: _resetAll,
              color: accent,
            ),
        ],
      ],
    );
  }

  Widget _placeDropdown(
    ThemeProvider theme, {
    required String title,
    required String allLabel,
    required String? value,
    required List<CustomerReportFilterOption> options,
    required ValueChanged<String?> onChanged,
  }) {
    return ReportLabeledField(
      label: title,
      width: 220,
      child: ReportSearchableDropdown<String?>(
        title: title,
        value: value,
        options: [
          ReportSearchableOption(value: null, label: allLabel),
          ...options.map(
            (o) =>
                ReportSearchableOption<String?>(value: o.key, label: o.label),
          ),
        ],
        onChanged: (v) => _apply(() => onChanged(v)),
        theme: theme,
        searchHint: 'Search ${title.toLowerCase()}...',
      ),
    );
  }

  Widget _toggle(
    ThemeProvider theme, {
    required String label,
    required String text,
    required bool selected,
    required ValueChanged<bool> onSelected,
  }) {
    return ReportLabeledField(
      label: label,
      width: 190,
      child: Align(
        alignment: Alignment.centerLeft,
        child: FilterChip(
          label: Text(
            text,
            style: TextStyle(fontSize: theme.mobileTexts.b4.fontSize),
          ),
          selected: selected,
          onSelected: (v) => _apply(() => onSelected(v)),
          visualDensity: VisualDensity.compact,
        ),
      ),
    );
  }

  Widget _filterPanel(ThemeProvider theme) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 5)],
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 12,
        children: [
          _placeDropdown(
            theme,
            title: 'Country',
            allLabel: 'All countries',
            value: _filters.countryKey,
            options: _countryOptions,
            onChanged: (v) => _filters.countryKey = v,
          ),
          _placeDropdown(
            theme,
            title: 'State',
            allLabel: 'All states',
            value: _filters.stateKey,
            options: _stateOptions,
            onChanged: (v) => _filters.stateKey = v,
          ),
          _toggle(
            theme,
            label: 'Credit',
            text: 'Has credit',
            selected: _filters.hasCredit,
            onSelected: (v) => _filters.hasCredit = v,
          ),
          if (_showAccount)
            _toggle(
              theme,
              label: 'Account',
              text: 'Has account balance',
              selected: _filters.hasAccountBalance,
              onSelected: (v) => _filters.hasAccountBalance = v,
            ),
        ],
      ),
    );
  }

  Widget _activeChips(ThemeProvider theme) {
    final chips = <Widget>[];
    void chip(String text, VoidCallback clear) {
      chips.add(
        InputChip(
          label: Text(text, style: const TextStyle(fontSize: 10)),
          onDeleted: () => _apply(clear),
          deleteIcon: const Icon(Icons.close, size: 12),
          visualDensity: VisualDensity.compact,
          backgroundColor: theme.lightModeColor.prColor300.withAlpha(25),
          side: BorderSide.none,
        ),
      );
    }

    String labelOf(List<CustomerReportFilterOption> options, String key) {
      for (final o in options) {
        if (o.key == key) return o.label;
      }
      return key;
    }

    final country = _filters.countryKey;
    if (country != null) {
      chip(
        'Country: ${labelOf(_countryOptions, country)}',
        () => _filters.countryKey = null,
      );
    }
    final state = _filters.stateKey;
    if (state != null) {
      chip(
        'State: ${labelOf(_stateOptions, state)}',
        () => _filters.stateKey = null,
      );
    }
    if (_filters.hasCredit) {
      chip('Has credit', () => _filters.hasCredit = false);
    }
    if (_showAccount && _filters.hasAccountBalance) {
      chip('Has account balance', () => _filters.hasAccountBalance = false);
    }
    if (chips.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Wrap(spacing: 6, runSpacing: 4, children: chips),
      ),
    );
  }

  Widget _notes() {
    final notes = customerReportNotes(period: _period);
    if (notes.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Align(
        alignment: Alignment.centerLeft,
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
                notes.join('\n'),
                style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------
  // table
  // ---------------------------------------------------------------

  TextStyle _cellStyle(
    ThemeProvider theme, {
    bool bold = false,
    Color? color,
  }) => TextStyle(
    fontSize: theme.mobileTexts.b3.fontSize,
    fontWeight: bold ? FontWeight.bold : FontWeight.w500,
    color: color ?? Colors.black87,
  );

  Widget _txt(
    ThemeProvider theme,
    String text, {
    bool bold = false,
    Color? color,
    TextAlign? align,
    String? tooltip,
  }) {
    final t = Text(
      text,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      textAlign: align,
      style: _cellStyle(theme, bold: bold, color: color),
    );
    return tooltip == null ? t : Tooltip(message: tooltip, child: t);
  }

  List<_Col> _columns(ThemeProvider theme) {
    const dash = '—';
    Widget money(double v, {bool bold = false, Color? color}) =>
        _txt(theme, _money(v), bold: bold, color: color);
    Widget total(double v, {Color? color}) =>
        money(v, bold: true, color: color);
    Color? creditColor(double v) =>
        v > 0 ? theme.lightModeColor.errorColor200 : null;

    return [
      _Col(
        label: 'Name',
        width: 200,
        sort: CustomerReportSortField.name,
        align: TextAlign.start,
        cell: (r) => _txt(theme, r.name, bold: true, align: TextAlign.start),
        total: (_) => _txt(theme, 'TOTAL', bold: true, align: TextAlign.start),
      ),
      _Col(
        label: 'Phone',
        width: 150,
        sort: CustomerReportSortField.phone,
        align: TextAlign.start,
        cell:
            (r) => _txt(
              theme,
              r.phone ?? dash,
              align: TextAlign.start,
              color: r.phone == null ? Colors.grey : null,
            ),
      ),
      _Col(
        label: 'Address',
        width: 260,
        sort: CustomerReportSortField.location,
        align: TextAlign.start,
        cell: (r) {
          final label = r.locationLabel;
          return _txt(
            theme,
            label ?? dash,
            align: TextAlign.start,
            color: label == null ? Colors.grey : null,
            tooltip: (label?.length ?? 0) > 40 ? label : null,
          );
        },
      ),
      if (_access.showAccount)
        _Col(
          label: 'Account Balance',
          width: 160,
          sort: CustomerReportSortField.accountBalance,
          cell: (r) => money(r.accountBalance),
          total: (t) => total(t.accountBalance),
        ),
      if (_access.showReward)
        _Col(
          label: 'Reward Earnings',
          width: 160,
          sort: CustomerReportSortField.rewardEarnings,
          cell: (r) => money(r.rewardEarnings),
          total: (t) => total(t.rewardEarnings),
        ),
      if (_access.showTotalBalance)
        _Col(
          label: 'Total Balance',
          width: 160,
          sort: CustomerReportSortField.totalBalance,
          cell: (r) => money(r.totalBalance, bold: true),
          total: (t) => total(t.totalBalance),
        ),
      _Col(
        label: 'Receipt Purchases',
        width: 170,
        sort: CustomerReportSortField.receiptPurchases,
        cell: (r) => money(r.receiptPurchases),
        total: (t) => total(t.receiptPurchases),
      ),
      _Col(
        label: 'Invoice Purchases',
        width: 170,
        sort: CustomerReportSortField.invoicePurchases,
        cell: (r) => money(r.invoicePurchases),
        total: (t) => total(t.invoicePurchases),
      ),
      _Col(
        label: 'Revenue',
        width: 160,
        sort: CustomerReportSortField.revenue,
        cell: (r) => money(r.revenue, bold: true),
        total: (t) => total(t.revenue),
      ),
      _Col(
        label: 'Credit',
        width: 160,
        sort: CustomerReportSortField.credit,
        cell: (r) => money(r.credit, color: creditColor(r.credit)),
        total: (t) => total(t.credit, color: creditColor(t.credit)),
      ),
    ];
  }

  Alignment _alignment(TextAlign a) =>
      a == TextAlign.start
          ? Alignment.centerLeft
          : (a == TextAlign.end ? Alignment.centerRight : Alignment.center);

  Widget _header(
    ThemeProvider theme, {
    required String label,
    required double width,
    required TextAlign align,
    required bool isSorted,
    required bool ascending,
    required VoidCallback onTap,
  }) {
    final accent = theme.lightModeColor.prColor300;
    final content = Row(
      mainAxisAlignment:
          align == TextAlign.start
              ? MainAxisAlignment.start
              : MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      spacing: 3,
      children: [
        Flexible(
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: align,
            style: TextStyle(
              fontSize: theme.mobileTexts.b3.fontSize,
              fontWeight: FontWeight.bold,
              color: isSorted ? accent : Colors.black87,
            ),
          ),
        ),
        Icon(
          isSorted
              ? (ascending
                  ? Icons.arrow_upward_rounded
                  : Icons.arrow_downward_rounded)
              : Icons.unfold_more_rounded,
          size: 14,
          color: isSorted ? accent : Colors.grey,
        ),
      ],
    );
    return SizedBox(
      width: width,
      child: InkWell(
        mouseCursor: SystemMouseCursors.click,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Align(alignment: _alignment(align), child: content),
        ),
      ),
    );
  }

  Widget _cells(List<_Col> cols, Widget Function(_Col c) cell) {
    return Row(
      children: [
        for (final c in cols)
          SizedBox(
            width: c.width,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Align(alignment: _alignment(c.align), child: cell(c)),
            ),
          ),
      ],
    );
  }

  Widget _row(
    ThemeProvider theme,
    List<_Col> cols,
    CustomerReportRow r,
    int i,
  ) {
    return Material(
      color: i.isEven ? Colors.white : Colors.grey.shade50,
      child: InkWell(
        mouseCursor: SystemMouseCursors.click,
        hoverColor: theme.lightModeColor.prColor300.withAlpha(20),
        onTap: () => _openAnalysis(r),
        child: Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
          ),
          child: _cells(cols, (c) => c.cell(r)),
        ),
      ),
    );
  }

  Widget _table(ThemeProvider theme, CustomerReportPage res) {
    final cols = _columns(theme);
    final sort = _visibleSort;
    final totalWidth = cols.fold<double>(0, (s, c) => s + c.width);
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: const [
            BoxShadow(color: Color(0x14000000), blurRadius: 12),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w =
                totalWidth > constraints.maxWidth
                    ? totalWidth
                    : constraints.maxWidth;
            return Scrollbar(
              controller: _vScroll,
              thumbVisibility: true,
              notificationPredicate:
                  (notif) => notif.metrics.axis == Axis.vertical,
              child: Scrollbar(
                controller: _hScroll,
                thumbVisibility: true,
                notificationPredicate:
                    (notif) => notif.metrics.axis == Axis.horizontal,
                child: SingleChildScrollView(
                  controller: _hScroll,
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: w,
                    height: constraints.maxHeight,
                    child: Column(
                      children: [
                        Container(
                          height: 48,
                          color: theme.lightModeColor.prColor300.withAlpha(22),
                          child: Row(
                            children: [
                              for (final c in cols)
                                _header(
                                  theme,
                                  label: c.label,
                                  width: c.width,
                                  align: c.align,
                                  isSorted: c.sort == sort,
                                  ascending: _ascending,
                                  onTap: () => _setSort(c.sort),
                                ),
                            ],
                          ),
                        ),
                        const Divider(height: 1),
                        Expanded(
                          child: ScrollConfiguration(
                            behavior: ScrollConfiguration.of(
                              context,
                            ).copyWith(scrollbars: false),
                            child: ListView.builder(
                              controller: _vScroll,
                              itemCount: res.rows.length,
                              itemExtent: 52,
                              itemBuilder:
                                  (context, i) =>
                                      _row(theme, cols, res.rows[i], i),
                            ),
                          ),
                        ),
                        const Divider(height: 1, thickness: 1),
                        // Totals of the whole filtered set.
                        Container(
                          height: 46,
                          color: theme.lightModeColor.prColor300.withAlpha(25),
                          child: _cells(
                            cols,
                            (c) =>
                                c.total?.call(res.totals) ??
                                const SizedBox.shrink(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
