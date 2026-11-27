import 'package:flutter/material.dart';
import 'package:stockall/classes/checkout_response.dart';
import 'package:stockall/classes/temp_expenses/temp_expenses_class.dart';
import 'package:stockall/classes/temp_invoices/temp_invoices.dart';
import 'package:stockall/classes/temp_main_receipt/temp_main_receipt.dart';
import 'package:stockall/classes/temp_orders/orders.dart';
import 'package:stockall/classes/temp_purchase/temp_purchase.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/refresh_functions.dart';
import 'package:stockall/constants/subscription/sales_auth.dart';
import 'package:stockall/local_database/shop_owner/shop_owner_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/expenses/single_expense/expense_details.dart';
import 'package:stockall/pages/purchases/purchase_page/purchase_page.dart';
import 'package:stockall/pages/report/components/export/report_export_button.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/report_pager.dart';
import 'package:stockall/pages/report/components/report_pill.dart';
import 'package:stockall/pages/report/components/report_range_fields.dart';
import 'package:stockall/pages/report/components/report_searchable_dropdown.dart';
import 'package:stockall/pages/report/invoice_report/invoice_report_table/class/invoice_report_table_logic.dart';
import 'package:stockall/pages/report/invoice_report/invoice_report_table/invoice_report_table_page.dart';
import 'package:stockall/pages/report/order_report/order_report_table/class/order_report_table_logic.dart';
import 'package:stockall/pages/report/order_report/order_report_table/order_report_table_page.dart';
import 'package:stockall/pages/report/purchase_report/purchase_report_table/class/purchase_report_table_logic.dart';
import 'package:stockall/pages/report/purchase_report/purchase_report_table/components/purchase_report_table_view.dart';
import 'package:stockall/pages/report/purchase_report/purchase_report_table/purchase_report_table_page.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/components/receipts_report_filter_widgets.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/receipts_report_main_page.dart';
import 'package:stockall/pages/report/staff_report/staff_analysis/staff_analysis_page.dart';
import 'package:stockall/pages/report/staff_report/staff_expenses/staff_expenses_page.dart';
import 'package:stockall/pages/report/staff_report/staff_report_table/class/staff_report_export_spec.dart';
import 'package:stockall/pages/report/staff_report/staff_report_table/class/staff_report_table_logic.dart';
import 'package:stockall/pages/sales/make_sales/receipt_page/receipt_page.dart';
import 'package:stockall/providers/theme_provider.dart';

/// Everything the staff report screens read from the app.
/// [StaffReportEnv.live] uses the providers; tests pass their own,
/// since the providers need Supabase.
class StaffReportEnv {
  /// Shop settings and the user's permissions. Takes a context: the
  /// orders gate reads the subscription plan.
  final StaffReportAccess Function(BuildContext context) access;

  /// Loaded data. Read on every rebuild.
  final StaffReportSource Function() source;

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
  final String Function(BuildContext context) signature;

  /// Subscribes the view to the providers it reads.
  final void Function(BuildContext context) listen;
  final String Function(BuildContext context, num amount) money;

  /// Opens the Staff Analysis page of [staff] on [period]. Returns
  /// when the user comes back, so the caller can rebuild.
  final Future<void> Function(
    BuildContext context,
    StaffReportRow staff,
    ReceiptsReportPeriod period,
  )
  openAnalysis;

  // Detail pages of one record. Each returns when the user comes
  // back, so the caller can rebuild.
  final Future<void> Function(BuildContext context, TempMainReceipt r)
  openReceipt;
  final Future<void> Function(BuildContext context, TempInvoice i) openInvoice;
  final Future<void> Function(BuildContext context, Orders o) openOrder;
  final Future<void> Function(BuildContext context, TempPurchase p)
  openPurchase;
  final Future<void> Function(BuildContext context, TempExpensesClass e)
  openExpense;

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
  final Future<void> Function(
    BuildContext context,
    PurchaseReportFilters filters,
    ReceiptsReportPeriod period,
  )
  openPurchaseTable;

  /// The Staff Expenses table of [staffKey] on [period].
  final Future<void> Function(
    BuildContext context,
    String staffKey,
    ReceiptsReportPeriod period,
  )
  openExpensesTable;

  const StaffReportEnv({
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
    required this.openPurchase,
    required this.openExpense,
    required this.openReceiptsTable,
    required this.openInvoiceTable,
    required this.openOrderTable,
    required this.openPurchaseTable,
    required this.openExpensesTable,
  });

  factory StaffReportEnv.live() {
    // Purchases are read as the Purchase Report reads them, as the
    // Supplier Report does.
    final purchaseEnv = PurchaseReportEnv.live();

    StaffReportAccess access(BuildContext context) {
      final s = shopSingle();
      return StaffReportAccess(
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
        showOrders: SalesAuthAction().manageOrdersAction(context: context),
        showPurchases: authorization(
          authorized: Authorizations().managePurchases,
        ),
        showExpenses: !isStoreKeeper(),
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
      final a = access(context);
      final receipts = returnReceiptProviderSingle();
      final expenses = returnExpensesProviderSingle();
      final fetchAll = period?.isAllTime ?? false;
      final startDate = period?.start;
      final endDate = period?.end ?? period?.start;
      if (refreshFromStore) {
        final refresh = RefreshFunctions(context);
        await receipts.loadReceipts(
          sid,
          startDate: startDate,
          endDate: endDate,
          fetchAll: fetchAll,
          forceRefresh: true,
        );
        if (!context.mounted) return;
        await returnInvoicesProvider().loadInvoices(
          sid,
          startDate: startDate,
          endDate: endDate,
          fetchAll: fetchAll,
          forceRefresh: true,
        );
        if (!context.mounted) return;
        // Also refreshes the owner (getUserShops).
        await refresh.refreshEmployees(context);
        if (!context.mounted) return;
        if (a.showExpenses) {
          await expenses.getExpenses(
            sid,
            startDate: startDate,
            endDate: endDate,
            fetchAll: fetchAll,
            forceRefresh: true,
          );
          if (!context.mounted) return;
        }
        if (a.showOrders) {
          await returnOrdersProvider().loadOrders(
            sid,
            startDate: startDate,
            endDate: endDate,
            fetchAll: fetchAll,
            forceRefresh: true,
          );
        }
        if (!context.mounted) return;
        if (a.showPurchases) {
          if (period != null) {
            await purchaseEnv.loadWithPeriod(
              context,
              refreshFromStore: true,
              period: period,
            );
          } else {
            await purchaseEnv.load(context, refreshFromStore: true);
          }
        }
        return;
      }
      // Local (offline) reads, only when nothing is loaded yet.
      final users = returnUserProviderSingle();
      if (users.usersMain.isEmpty) {
        await users.fetchUsersByShopOffline();
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
      if (a.showOrders && returnOrdersProvider().orders.isEmpty) {
        await returnOrdersProvider().loadOrdersOffline(sid);
      }
      if (a.showPurchases && context.mounted) {
        if (period != null) {
          await purchaseEnv.loadWithPeriod(
            context,
            refreshFromStore: false,
            period: period,
          );
        } else {
          await purchaseEnv.load(context, refreshFromStore: false);
        }
      }
      if (a.showExpenses && expenses.expensesMain.isEmpty) {
        await expenses.getExpensesOffline(sid);
      }
      if (returnCustomersSingle().customers.isEmpty) {
        await returnCustomersSingle().fetchCustomersOffline();
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
        if (a.showExpenses) {
          await expenses.getExpenses(
            sid,
            startDate: startDate,
            endDate: endDate,
            forceRefresh: false,
          );
        }
        if (a.showOrders) {
          await returnOrdersProvider().loadOrders(
            sid,
            startDate: startDate,
            endDate: endDate,
            forceRefresh: false,
          );
        }
      }
    }

    return StaffReportEnv(
      access: access,
      source: () {
        final receipts = returnReceiptProviderSingle();
        final users = returnUserProviderSingle();
        return StaffReportSource(
          staff: users.usersMain,
          owner:
              returnShopProvider().shopOwnerUser ??
              ShopOwnerFunc().getShopOwnerUser()?.shopOwner,
          currentUser: users.currentUserMain,
          receipts: receipts.receipts,
          productSales: receipts.mainSales,
          invoices: returnInvoicesProvider().invoicesMain,
          orders: returnOrdersProvider().orders,
          purchases: returnPurchaseProvider().purchases,
          expenses: returnExpensesProviderSingle().expensesMain,
          customers: returnCustomersSingle().customers,
          purchaseLegacyLines: purchaseEnv.legacyLines(),
          supplierNames: purchaseEnv.supplierNames(),
          pendingDeletedPurchaseUuids: purchaseEnv.pendingDeletedUuids(),
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
      signature: (context) {
        int latest(Iterable<DateTime?> times) {
          int out = 0;
          for (final t in times) {
            final ms = t?.millisecondsSinceEpoch ?? 0;
            if (ms > out) out = ms;
          }
          return out;
        }

        final receipts = returnReceiptProviderSingle();
        double revenue = 0;
        for (final r in receipts.receipts) {
          revenue += r.getTotalRevenue();
        }
        final invoices = returnInvoicesProvider().invoicesMain;
        final orders = returnOrdersProvider().orders;
        final expenses = returnExpensesProviderSingle().expensesMain;
        double spent = 0;
        for (final e in expenses) {
          spent += e.amount;
        }
        final staff = returnUserProviderSingle().usersMain;
        final a = access(context);
        return '${receipts.receipts.length}|$revenue|'
            '${latest(receipts.receipts.map((r) => r.createdAt))}|'
            '${receipts.mainSales.length}|'
            '${invoices.length}|'
            '${latest(invoices.map((i) => i.updatedAt ?? i.createdAt))}|'
            '${orders.length}|'
            '${latest(orders.map((o) => o.updatedAt ?? o.createdAt))}|'
            '${purchaseEnv.signature()}|'
            '${expenses.length}|$spent|'
            '${latest(expenses.map((e) => e.updatedAt ?? e.createdDate))}|'
            '${staff.map((u) => '${u.userId}:${u.name}:${u.role}').join(',')}|'
            '${returnShopProvider().shopOwnerUser?.userId}|'
            '${a.currentDepartmentUuid}|${a.currentUserId}|'
            '${a.departmentsEnabled}|${a.canViewAllTransactions}|'
            '${a.showOrders}|${a.showPurchases}|${a.showExpenses}';
      },
      listen: (context) {
        returnReceiptProvider(context);
        returnInvoicesProvider(context: context);
        returnOrdersProvider(context: context);
        returnPurchaseProvider(context: context);
        returnExpensesProvider(context);
        returnUserProvider(context);
        returnDepartmentProvider(context: context);
        shop(context);
      },
      money:
          (context, amount) => formatMoneyBig(amount: amount, context: context),
      openAnalysis:
          (context, staff, period) =>
              _push(context, analysisPage(staffKey: staff.key, period: period)),
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
      openPurchase: (context, p) {
        final uuid = p.uuid;
        if (uuid == null) return Future.value();
        return _push(context, PurchasePage(purchaseUuid: uuid));
      },
      openExpense: (context, e) {
        final uuid = e.uuid;
        if (uuid == null) return Future.value();
        return _push(context, ExpenseDetails(expenseUuid: uuid));
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
      openPurchaseTable:
          (context, filters, period) => _push(
            context,
            PurchaseReportTablePage(
              initialFilters: filters,
              initialPeriod: period,
            ),
          ),
      openExpensesTable:
          (context, staffKey, period) => _push(
            context,
            expensesPage(staffKey: staffKey, period: period),
          ),
    );
  }

  /// The Staff Expenses table of [staffKey] on [period]. Null [env]
  /// is [StaffReportEnv.live].
  static Widget expensesPage({
    required String staffKey,
    required ReceiptsReportPeriod period,
    StaffReportEnv? env,
  }) {
    return StaffExpensesPage(
      staffKey: staffKey,
      initialPeriod: period,
      env: env,
    );
  }

  /// The Staff Analysis page of [staffKey] on [period]. Null [env]
  /// is [StaffReportEnv.live].
  static Widget analysisPage({
    required String staffKey,
    required ReceiptsReportPeriod period,
    StaffReportEnv? env,
  }) {
    return StaffAnalysisPage(
      staffKey: staffKey,
      initialPeriod: period,
      env: env,
    );
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
  final StaffReportSortField sort;
  final TextAlign align;
  final Widget Function(StaffReportRow row) cell;

  /// Cell of the totals row; empty when null.
  final Widget Function(StaffReportTotals totals)? total;

  const _Col({
    required this.label,
    required this.width,
    required this.sort,
    required this.cell,
    this.align = TextAlign.center,
    this.total,
  });
}

/// Shared body of the Staff Report Table page (desktop + mobile).
///
/// [initialFilters] and [initialPeriod] let another page open the
/// table on a given set. Without the View Date permission the
/// period is always today.
class StaffReportTableView extends StatefulWidget {
  final bool isDesktop;
  final StaffReportFilters? initialFilters;
  final ReceiptsReportPeriod? initialPeriod;

  /// Null in the app: [StaffReportEnv.live] is used.
  final StaffReportEnv? env;

  const StaffReportTableView({
    super.key,
    required this.isDesktop,
    this.initialFilters,
    this.initialPeriod,
    this.env,
  });

  @override
  State<StaffReportTableView> createState() => _StaffReportTableViewState();
}

class _StaffReportTableViewState extends State<StaffReportTableView> {
  late final StaffReportEnv _env;
  late final StaffReportFilters _filters;
  final _searchCtrl = TextEditingController();
  final _hScroll = ScrollController();
  final _vScroll = ScrollController();

  StaffReportSortField _sortField = StaffReportSortField.name;
  bool _ascending = true;
  int _page = 1;
  bool _showFilters = false;
  bool _toolbarIsOpen = false;

  late ReceiptsReportPeriod _period;
  late StaffReportAccess _access;

  bool _loading = true;
  String? _error;

  StaffReportBase? _base;
  List<StaffReportRow> _rows = [];
  StaffReportPage? _result;
  String _signature = '';

  // Every filtered, sorted row, for the export.
  List<StaffReportRow> _sortedRows = [];

  List<StaffReportFilterOption> _roleOptions = [];

  @override
  void initState() {
    super.initState();
    _env = widget.env ?? StaffReportEnv.live();
    _access = _env.access(context);
    _filters = widget.initialFilters?.copy() ?? StaffReportFilters();
    _searchCtrl.text = _filters.search;
    _period =
        _access.canPickDate
            ? (widget.initialPeriod ?? ReceiptsReportPeriod.today())
            : _access.initialPeriod();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load(refreshFromStore: true);
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
      _rebuildBase();
      _recompute();
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

  void _rebuildBase() {
    _access = _env.access(context);
    _base = StaffReportBase.build(source: _env.source(), access: _access);
    _signature = _env.signature(context);
    _rebuildRows();
  }

  /// Rows of the current period.
  void _rebuildRows() {
    final base = _base;
    if (base == null) return;
    _rows = StaffReportRowBuilder.buildAll(StaffReportSlice.of(base, _period));
    _roleOptions = StaffReportOptions.roles(_rows);
  }

  void _recompute() {
    final sorted = StaffReportQuery.filterAndSort(
      rows: _rows,
      filters: _filters,
      sortField: _sortField,
      ascending: _ascending,
      access: _access,
    );
    _sortedRows = sorted;
    final page = StaffReportQuery.paginate(sorted, _page);
    _page = page.page;
    _result = page;
  }

  ReportExportSpec _exportSpec() {
    return staffReportExportSpec(
      rows: _sortedRows,
      filters: _filters,
      roleOptions: _roleOptions,
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

  StaffReportSortField get _visibleSort =>
      StaffReportQuery.visibleSort(_sortField, _access);

  void _setSort(StaffReportSortField f) {
    _apply(() {
      if (_visibleSort == f) {
        _ascending = !_ascending;
      } else {
        _sortField = f;
        _ascending = StaffReportQuery.defaultAscending(f);
      }
    });
  }

  /// Clears the search and filters only: the period and sort stay.
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

  Future<void> _openAnalysis(StaffReportRow row) async {
    await _env.openAnalysis(context, row, _period);
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
    // Listen, so sales, purchases, expenses and sync update the
    // table.
    _env.listen(context);

    if (!_loading && _error == null) {
      final sig = _env.signature(context);
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
        title: 'Staff Report',
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
                itemLabel: 'staff',
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
      final hasFilters = _filters.hasAnything;
      return Padding(
        padding: const EdgeInsets.only(top: 60),
        child: EmptyWidgetDisplayOnly(
          title: hasFilters ? 'No Matching Staff' : 'Empty List',
          subText:
              hasFilters
                  ? 'No staff matches your search and filters'
                  : 'No staff has been added yet',
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
    final active = _filters.activeCount;
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
                      hintText: 'Search name, phone or role',
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
            child: ReportExportButton(
              showRollWidthEntries: false,
              buildSpec: _exportSpec,
            ),
          ),
          if (_filters.hasAnything)
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
          ReportLabeledField(
            label: 'Role',
            width: 220,
            child: ReportSearchableDropdown<String?>(
              title: 'Role',
              value: _filters.roleKey,
              options: [
                const ReportSearchableOption(value: null, label: 'All roles'),
                ..._roleOptions.map(
                  (o) => ReportSearchableOption<String?>(
                    value: o.key,
                    label: o.label,
                  ),
                ),
              ],
              onChanged: (v) => _apply(() => _filters.roleKey = v),
              theme: theme,
              searchHint: 'Search role...',
            ),
          ),
        ],
      ),
    );
  }

  Widget _activeChips(ThemeProvider theme) {
    final role = _filters.roleKey;
    if (role == null) return const SizedBox.shrink();
    String label = role;
    for (final o in _roleOptions) {
      if (o.key == role) label = o.label;
    }
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Wrap(
          spacing: 6,
          runSpacing: 4,
          children: [
            InputChip(
              label: Text(
                'Role: $label',
                style: const TextStyle(fontSize: 10),
              ),
              onDeleted: () => _apply(() => _filters.roleKey = null),
              deleteIcon: const Icon(Icons.close, size: 12),
              visualDensity: VisualDensity.compact,
              backgroundColor: theme.lightModeColor.prColor300.withAlpha(25),
              side: BorderSide.none,
            ),
          ],
        ),
      ),
    );
  }

  Widget _notes() {
    final notes = staffReportNotes(period: _period);
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
  }) {
    return Text(
      text,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      textAlign: align,
      style: _cellStyle(theme, bold: bold, color: color),
    );
  }

  Widget _badge(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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

  Widget _nameCell(ThemeProvider theme, StaffReportRow r) {
    final name = _txt(theme, r.name, bold: true, align: TextAlign.start);
    if (!r.isFormer) return name;
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 6,
      children: [
        Flexible(child: name),
        _badge(staffReportFormerRoleLabel, theme.lightModeColor.errorColor200),
      ],
    );
  }

  List<_Col> _columns(ThemeProvider theme) {
    const dash = '—';
    Widget money(double v, {bool bold = false}) =>
        _txt(theme, _money(v), bold: bold);
    Widget count(int v, {bool bold = false}) =>
        _txt(theme, '$v', bold: bold);
    Widget grey(String? v) => _txt(
      theme,
      v ?? dash,
      align: TextAlign.start,
      color: v == null ? Colors.grey : null,
    );

    return [
      _Col(
        label: 'Name',
        width: 240,
        sort: StaffReportSortField.name,
        align: TextAlign.start,
        cell: (r) => _nameCell(theme, r),
        total: (_) => _txt(theme, 'TOTAL', bold: true, align: TextAlign.start),
      ),
      _Col(
        label: 'Role',
        width: 150,
        sort: StaffReportSortField.role,
        align: TextAlign.start,
        // Former staff have no role: the name's badge says it.
        cell: (r) => grey(r.isFormer ? null : r.roleLabel),
      ),
      _Col(
        label: 'Phone',
        width: 140,
        sort: StaffReportSortField.phone,
        align: TextAlign.start,
        cell: (r) => grey(r.phone),
      ),
      _Col(
        label: 'Receipt Sales',
        width: 160,
        sort: StaffReportSortField.receiptSales,
        cell: (r) => money(r.receiptSales, bold: true),
        total: (t) => money(t.receiptSales, bold: true),
      ),
      _Col(
        label: 'Invoice Sales',
        width: 160,
        sort: StaffReportSortField.invoiceSales,
        cell: (r) => money(r.invoiceSales),
        total: (t) => money(t.invoiceSales, bold: true),
      ),
      if (_access.showOrders) ...[
        _Col(
          label: 'Orders',
          width: 100,
          sort: StaffReportSortField.orderCount,
          cell: (r) => count(r.orderCount),
          total: (t) => count(t.orderCount, bold: true),
        ),
        _Col(
          label: 'Order Value',
          width: 150,
          sort: StaffReportSortField.orderTotal,
          cell: (r) => money(r.orderTotal),
          total: (t) => money(t.orderTotal, bold: true),
        ),
      ],
      if (_access.showPurchases) ...[
        _Col(
          label: 'Purchases',
          width: 110,
          sort: StaffReportSortField.purchaseCount,
          cell: (r) => count(r.purchaseCount),
          total: (t) => count(t.purchaseCount, bold: true),
        ),
        _Col(
          label: 'Purchase Value',
          width: 150,
          sort: StaffReportSortField.purchaseTotal,
          cell: (r) => money(r.purchaseTotal),
          total: (t) => money(t.purchaseTotal, bold: true),
        ),
      ],
      if (_access.showExpenses) ...[
        _Col(
          label: 'Expenses',
          width: 100,
          sort: StaffReportSortField.expenseCount,
          cell: (r) => count(r.expenseCount),
          total: (t) => count(t.expenseCount, bold: true),
        ),
        _Col(
          label: 'Expense Value',
          width: 150,
          sort: StaffReportSortField.expenseTotal,
          cell: (r) => money(r.expenseTotal),
          total: (t) => money(t.expenseTotal, bold: true),
        ),
      ],
      _Col(
        label: 'Last Activity',
        width: 150,
        sort: StaffReportSortField.lastActivity,
        cell: (r) {
          final at = r.lastActivity;
          return _txt(
            theme,
            at == null ? dash : formatDateTime(at),
            color: at == null ? Colors.grey : null,
          );
        },
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

  Widget _row(ThemeProvider theme, List<_Col> cols, StaffReportRow r, int i) {
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

  Widget _table(ThemeProvider theme, StaffReportPage res) {
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
