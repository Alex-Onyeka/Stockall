import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_customers/temp_customers_class.dart';
import 'package:stockall/classes/temp_invoices/temp_invoices.dart';
import 'package:stockall/classes/temp_main_receipt/temp_main_receipt.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/date_picker_function.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/refresh_functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/report/components/export/report_export_button.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/invoice_report/invoice_report_table/class/invoice_report_table_logic.dart';
import 'package:stockall/pages/report/invoice_report/invoice_report_table/invoice_report_table_page.dart';
import 'package:stockall/pages/report/invoice_report/invoice_summary/class/invoice_summary_export_spec.dart';
import 'package:stockall/pages/report/invoice_report/invoice_summary/class/invoice_summary_logic.dart';
import 'package:stockall/providers/theme_provider.dart';
import 'package:stockall/pages/report/components/report_department_scope.dart';

class InvoiceSummaryView extends StatefulWidget {
  final bool isDesktop;

  const InvoiceSummaryView({
    super.key,
    required this.isDesktop,
  });

  @override
  State<InvoiceSummaryView> createState() =>
      _InvoiceSummaryViewState();
}

class _InvoiceSummaryViewState
    extends State<InvoiceSummaryView>
    with SingleTickerProviderStateMixin {
  bool _loading = true;
  String? _error;

  List<TempInvoice> _invoices = [];
  List<TempMainReceipt> _receipts = [];
  List<InvoiceReportRow> _allRows = [];

  InvoiceSummaryPeriod _period =
      InvoiceSummaryPeriod.allTime;
  DateTimeRange? _customRange;
  final InvoiceSummaryFilters _filters =
      InvoiceSummaryFilters();

  InvoiceSummaryResult _result = InvoiceSummaryResult.empty;

  // Leaderboard tab toggle: 0 = Top Creditors, 1 = Least Creditors
  int _leaderboardTab = 0;

  // Active table view tab: 0 = Customers, 1 = Staff, 2 = Departments, 3 = Sub-Staff, 4 = Statuses
  int _tableTab = 0;

  final TextEditingController _customerSearchCtrl =
      TextEditingController();
  String _customerSearch = '';
  final ScrollController _tableHScroll = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load(refreshFromStore: true);
    });
  }

  @override
  void dispose() {
    _customerSearchCtrl.dispose();
    _tableHScroll.dispose();
    super.dispose();
  }

  bool get _departmentsEnabled =>
      shopSingle()?.manageDepartments == true;

  bool get _canViewAllDepartments => authorization(
    authorized: Authorizations().viewAllDepartments,
  );

  bool get _bulkSaleEnabled =>
      shopSingle()?.bulkSale == true;

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
      final currentShop = shopSingle();
      final sid = currentShop?.shopId ?? 0;

      final isAllTime =
          _period == InvoiceSummaryPeriod.allTime;
      final resolvedRange =
          isAllTime ? null : _currentResolvedDateRange();
      final startDate = resolvedRange?.start;
      final endDate = resolvedRange?.end;

      if (refreshFromStore && sid != 0 && mounted) {
        await RefreshFunctions(context).refreshInvoices(
          context,
          startDate: startDate,
          endDate: endDate,
          fetchAll: isAllTime,
          forceRefresh: true,
        );
        if (!mounted) return;
        await RefreshFunctions(context).refreshReceipts(
          context,
          startDate: startDate,
          endDate: endDate,
          fetchAll: isAllTime,
          forceRefresh: true,
        );
        if (!mounted) return;
        await RefreshFunctions(
          context,
        ).refreshCustomers(context);
      } else if (sid != 0) {
        await returnInvoicesProvider().loadInvoicesOffline(
          sid,
        );
        await returnReceiptProviderSingle()
            .loadReceiptsOffline(sid);
        await returnCustomersSingle()
            .fetchCustomersOffline();
        if (!isAllTime &&
            startDate != null &&
            endDate != null) {
          await returnInvoicesProvider().loadInvoices(
            sid,
            startDate: startDate,
            endDate: endDate,
            forceRefresh: false,
          );
          await returnReceiptProviderSingle().loadReceipts(
            sid,
            startDate: startDate,
            endDate: endDate,
            forceRefresh: false,
          );
        }
      }

      // Shop scoped invoices
      final allInvs = returnInvoicesProvider().invoicesMain;
      final shopInvoices =
          allInvs
              .where((inv) => inv.shopId == sid)
              .toList();

      // Department restriction check
      if (_departmentsEnabled && !_canViewAllDepartments) {
        final curDept = _currentDepartmentUuid;
        // With no current department (staff assigned to none)
        // only invoices in no department.
        _invoices =
            shopInvoices
                .where(
                  (inv) => reportDepartmentMatches(
                    inv.departmentUuidNew,
                    curDept,
                  ),
                )
                .toList();
      } else {
        _invoices = shopInvoices;
      }

      // Receipts
      _receipts =
          returnReceiptProviderSingle().receipts
              .where((r) => r.shopId == sid)
              .toList();

      final allProductSales =
          returnReceiptProviderSingle().mainSales;
      final customers = returnCustomersSingle().customers;
      final Map<String, TempCustomersClass> customerMap = {
        for (final c in customers)
          if (c.uuid != null && c.uuid!.isNotEmpty)
            c.uuid!: c,
      };

      // Reuse authoritative InvoiceReportRowBuilder
      _allRows = InvoiceReportRowBuilder.buildAll(
        invoices: _invoices,
        allReceipts: _receipts,
        allProductSales: allProductSales,
        customerMap: customerMap,
        context: context,
      );

      _recompute();

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

  void _recompute() {
    final businessNow = resolveBusinessDate(DateTime.now());
    _result = InvoiceSummaryBuilder.build(
      allRows: _allRows,
      allReceipts: _receipts,
      period: _period,
      businessNow: businessNow,
      customRange: _customRange,
      filters: _filters,
      departmentsEnabled: _departmentsEnabled,
      bulkSaleEnabled: _bulkSaleEnabled,
    );
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
          _period = InvoiceSummaryPeriod.custom;
          _customRange = DateTimeRange(start: d, end: d);
          _recompute();
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
          _period = InvoiceSummaryPeriod.custom;
          _customRange = DateTimeRange(start: s, end: e);
          _recompute();
        });
        _load(refreshFromStore: false);
      },
    );
  }

  DateTimeRange _currentResolvedDateRange() {
    final now = resolveBusinessDate(DateTime.now());
    return InvoiceSummaryBuilder.resolveDateRange(
      period: _period,
      businessNow: now,
      customRange: _customRange,
    );
  }

  void _navigateToTableWithFilter({
    String? departmentKey,
    String? customerUuid,
    String? staffId,
    String? subStaffUuid,
    InvoicePaymentStatusFilter? paymentStatus,
    InvoicePaymentChannelFilter? paymentChannel,
  }) {
    final dateRange = _currentResolvedDateRange();
    final filters = InvoiceReportFilters(
      dateRange:
          _period == InvoiceSummaryPeriod.allTime
              ? null
              : dateRange,
      departmentKey:
          departmentKey ?? _filters.departmentKey,
      customerUuid: customerUuid ?? _filters.customerUuid,
      staffId: staffId ?? _filters.staffId,
      subStaffUuid: subStaffUuid ?? _filters.subStaffUuid,
      paymentStatus:
          paymentStatus ?? _filters.paymentStatus,
      paymentChannel:
          paymentChannel ?? _filters.paymentChannel,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => InvoiceReportTablePage(
              initialFilters: filters,
            ),
      ),
    );
  }

  ReportExportSpec _exportSpec() {
    return invoiceSummaryExportSpec(
      result: _result,
      customers: invoiceSummaryCustomers(
        _result.allCustomerSummaries,
        _customerSearch,
      ),
      customerSearch: _customerSearch,
      period: _period,
      customRange: _customRange,
      resolvedRange: _currentResolvedDateRange(),
      currency: currencySymbol(context: context),
      canSeeCost: _canSeeCost,
      departmentsEnabled: _departmentsEnabled,
      bulkSaleEnabled: _bulkSaleEnabled,
    );
  }

  String _fmt(double? v) {
    if (v == null) return '—';
    return formatMoneyBig(amount: v, context: context);
  }

  String _fmtNum(double? v) {
    if (v == null) return '—';
    return formatLargeNumberDouble(v);
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
        title: 'Invoice Summary and Analysis',
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
                  final range = _currentResolvedDateRange();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (
                            context,
                          ) => InvoiceReportTablePage(
                            initialFilters:
                                InvoiceReportFilters(
                                  dateRange:
                                      _period ==
                                              InvoiceSummaryPeriod
                                                  .allTime
                                          ? null
                                          : range,
                                ),
                          ),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.table_chart_rounded,
                  size: 15,
                ),
                label: Text(
                  'Invoice Table',
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
                  size: 20,
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
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 40,
            color: theme.lightModeColor.errorColor200,
          ),
          const SizedBox(height: 10),
          Text(
            'Unable to generate invoice summary',
            style: TextStyle(
              fontSize: theme.mobileTexts.b1.fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _error ?? 'An unexpected error occurred',
            style: TextStyle(
              fontSize: theme.mobileTexts.b3.fontSize,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 12),
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
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: widget.isDesktop ? 16 : 10,
        vertical: 10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderBar(theme),
          const SizedBox(height: 12),
          _buildHeadlineKpis(theme),
          const SizedBox(height: 12),
          _buildSummaryBreakdownPills(theme),
          const SizedBox(height: 14),
          _buildMiddleSection(theme),
          const SizedBox(height: 14),
          _buildTablesSection(theme),
          const SizedBox(height: 24),
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Invoice Analysis',
              style: TextStyle(
                fontSize: theme.mobileTexts.b1.fontSize,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
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
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 0,
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
            child: DropdownButton<InvoiceSummaryPeriod>(
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
                  InvoiceSummaryPeriod.values.map((p) {
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
                if (val == InvoiceSummaryPeriod.custom) {
                  _pickCustomRange();
                } else {
                  setState(() {
                    _period = val;
                    _customRange = null;
                    _recompute();
                  });
                  if (val != InvoiceSummaryPeriod.allTime) {
                    _load(refreshFromStore: false);
                  }
                }
              },
            ),
          ),
          if (_period == InvoiceSummaryPeriod.custom &&
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
  // Top 4 Headline KPI Cards (Section 4.2)
  // ---------------------------------------------------------------------------
  Widget _buildHeadlineKpis(ThemeProvider theme) {
    final stats = _result.stats;
    final isDesktop = widget.isDesktop;

    final cards = [
      _buildKpiCard(
        theme: theme,
        title: 'Total Invoice Value',
        value: _fmt(stats.totalInvoiceValue),
        subtitle:
            '${stats.totalInvoices} Qualifying Invoices',
        badgeText: 'Total Value',
        badgeColor: const Color(0xFF2563EB),
        icon: Icons.receipt_long_rounded,
        iconBg: const Color(0xFFEFF6FF),
        iconColor: const Color(0xFF2563EB),
      ),
      _buildKpiCard(
        theme: theme,
        title: 'Total Invoices',
        value: stats.totalInvoices.toString(),
        subtitle:
            '${stats.fullyPaidInvoices} Paid  •  ${stats.partiallyPaidInvoices} Partial  •  ${stats.unpaidInvoices} Unpaid',
        badgeText: 'Invoices Issued',
        badgeColor: const Color(0xFF7E22CE),
        icon: Icons.description_outlined,
        iconBg: const Color(0xFFF3E8FF),
        iconColor: const Color(0xFF7E22CE),
      ),
      _buildKpiCard(
        theme: theme,
        title: 'Total Amount Paid',
        value: _fmt(stats.totalAmountPaid),
        subtitle:
            'Collections in Period: ${_fmt(stats.totalCollectionsInPeriod)}',
        badgeText: 'Collected',
        badgeColor: const Color(0xFF059669),
        icon: Icons.payments_outlined,
        iconBg: const Color(0xFFECFDF5),
        iconColor: const Color(0xFF059669),
      ),
      _buildKpiCard(
        theme: theme,
        title: 'Total Outstanding Balance',
        value: _fmt(stats.totalOutstandingBalance),
        subtitle: 'Customer Balance Owed',
        badgeText: 'Owed Balance',
        badgeColor: const Color(0xFFDC2626),
        icon: Icons.account_balance_wallet_outlined,
        iconBg: const Color(0xFFFEF2F2),
        iconColor: const Color(0xFFDC2626),
      ),
    ];

    if (isDesktop) {
      return Row(
        children:
            cards
                .map(
                  (c) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                      ),
                      child: c,
                    ),
                  ),
                )
                .toList(),
      );
    } else {
      return GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
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
                    fontSize: theme.mobileTexts.b5.fontSize,
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
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
  // Secondary Summary Statistics Mini Stat Pills (Section 4.2)
  // ---------------------------------------------------------------------------
  Widget _buildSummaryBreakdownPills(ThemeProvider theme) {
    final stats = _result.stats;

    final pills = [
      _buildMiniStatPill(
        theme: theme,
        label: 'Fully Paid Invoices',
        value: stats.fullyPaidInvoices.toString(),
        icon: Icons.check_circle_outline_rounded,
        color: const Color(0xFF059669),
        onTap:
            () => _navigateToTableWithFilter(
              paymentStatus:
                  InvoicePaymentStatusFilter.paid,
            ),
      ),
      _buildMiniStatPill(
        theme: theme,
        label: 'Partially Paid Invoices',
        value: stats.partiallyPaidInvoices.toString(),
        icon: Icons.timelapse_rounded,
        color: const Color(0xFFD97706),
        onTap:
            () => _navigateToTableWithFilter(
              paymentStatus:
                  InvoicePaymentStatusFilter.partial,
            ),
      ),
      _buildMiniStatPill(
        theme: theme,
        label: 'Unpaid Invoices',
        value: stats.unpaidInvoices.toString(),
        icon: Icons.error_outline_rounded,
        color: const Color(0xFFDC2626),
        onTap:
            () => _navigateToTableWithFilter(
              paymentStatus:
                  InvoicePaymentStatusFilter.unpaid,
            ),
      ),
      if (stats.unresolvedInvoices > 0)
        _buildMiniStatPill(
          theme: theme,
          label: 'Unresolved Statuses',
          value: stats.unresolvedInvoices.toString(),
          icon: Icons.help_outline_rounded,
          color: const Color(0xFF6B7280),
        ),
      _buildMiniStatPill(
        theme: theme,
        label: 'Total Customers',
        value: stats.totalCustomers.toString(),
        icon: Icons.people_outline_rounded,
        color: const Color(0xFF0891B2),
      ),
      _buildMiniStatPill(
        theme: theme,
        label: 'Total Staff Involved',
        value: stats.totalStaffInvolved.toString(),
        icon: Icons.badge_outlined,
        color: const Color(0xFF78350F),
      ),
    ];

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
              Text(
                'Invoice Statistics',
                style: TextStyle(
                  fontSize: theme.mobileTexts.b2.fontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              if (_departmentsEnabled &&
                  screenWidth(context) > mobileScreen)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(
                      0xFF8B5CF6,
                    ).withAlpha(20),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Departments Enabled',
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.b5.fontSize,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF8B5CF6),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          widget.isDesktop
              ? Wrap(
                spacing: 10,
                runSpacing: 10,
                children:
                    pills
                        .map(
                          (w) => SizedBox(
                            width: 180,
                            child: w,
                          ),
                        )
                        .toList(),
              )
              : GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics:
                    const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 2.2,
                children: pills,
              ),
        ],
      ),
    );
  }

  Widget _buildMiniStatPill({
    required ThemeProvider theme,
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Icon(icon, size: 14, color: color),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.b5.fontSize,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.b3.fontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Middle Section: Status Donut Chart & Top Performers Leaderboards
  // ---------------------------------------------------------------------------
  Widget _buildMiddleSection(ThemeProvider theme) {
    final donutCard = _buildStatusDonutCard(theme);
    final leaderboardCard = _buildLeaderboardsCard(theme);

    if (widget.isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 38, child: donutCard),
          const SizedBox(width: 12),
          Expanded(flex: 62, child: leaderboardCard),
        ],
      );
    } else {
      return Column(
        children: [
          donutCard,
          const SizedBox(height: 12),
          leaderboardCard,
        ],
      );
    }
  }

  Widget _buildStatusDonutCard(ThemeProvider theme) {
    final stats = _result.stats;
    final int total = stats.totalInvoices;
    final int paid = stats.fullyPaidInvoices;
    final int partial = stats.partiallyPaidInvoices;
    final int unpaid = stats.unpaidInvoices;
    final int unresolved = stats.unresolvedInvoices;

    final double paidPct =
        total > 0 ? (paid / total) * 100 : 0;
    final double partialPct =
        total > 0 ? (partial / total) * 100 : 0;
    final double unpaidPct =
        total > 0 ? (unpaid / total) * 100 : 0;
    final double unresolvedPct =
        total > 0 ? (unresolved / total) * 100 : 0;

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
            'Invoice Status Distribution',
            style: TextStyle(
              fontSize: theme.mobileTexts.b1.fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            'Settlement status of qualifying invoices',
            style: TextStyle(
              fontSize: theme.mobileTexts.b4.fontSize,
              color: Colors.grey.shade500,
            ),
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
                              if (paid > 0)
                                PieChartSectionData(
                                  color: const Color(
                                    0xFF059669,
                                  ),
                                  value: paid.toDouble(),
                                  radius: 20,
                                  showTitle: false,
                                ),
                              if (partial > 0)
                                PieChartSectionData(
                                  color: const Color(
                                    0xFFD97706,
                                  ),
                                  value: partial.toDouble(),
                                  radius: 20,
                                  showTitle: false,
                                ),
                              if (unpaid > 0)
                                PieChartSectionData(
                                  color: const Color(
                                    0xFFDC2626,
                                  ),
                                  value: unpaid.toDouble(),
                                  radius: 20,
                                  showTitle: false,
                                ),
                              if (unresolved > 0)
                                PieChartSectionData(
                                  color: const Color(
                                    0xFF6B7280,
                                  ),
                                  value:
                                      unresolved.toDouble(),
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
                      total.toString(),
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b1.fontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Invoices',
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
          Column(
            children: [
              _buildLegendRow(
                theme: theme,
                color: const Color(0xFF059669),
                label: 'Fully Paid',
                percentage: paidPct,
                value: '$paid Invoices',
              ),
              const SizedBox(height: 6),
              _buildLegendRow(
                theme: theme,
                color: const Color(0xFFD97706),
                label: 'Partially Paid',
                percentage: partialPct,
                value: '$partial Invoices',
              ),
              const SizedBox(height: 6),
              _buildLegendRow(
                theme: theme,
                color: const Color(0xFFDC2626),
                label: 'Unpaid',
                percentage: unpaidPct,
                value: '$unpaid Invoices',
              ),
              if (unresolved > 0) ...[
                const SizedBox(height: 6),
                _buildLegendRow(
                  theme: theme,
                  color: const Color(0xFF6B7280),
                  label: 'Unresolved',
                  percentage: unresolvedPct,
                  value: '$unresolved Invoices',
                ),
              ],
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
    required String value,
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
          '${_fmtNum(percentage)}% ($value)',
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
  // Leaderboards: Top Creditors & Least Creditors
  // ---------------------------------------------------------------------------
  Widget _buildLeaderboardsCard(ThemeProvider theme) {
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
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              Text(
                'Performance Rankings',
                style: TextStyle(
                  fontSize: theme.mobileTexts.b1.fontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: const EdgeInsets.all(2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTabButton(
                      theme: theme,
                      label: 'Top Creditors',
                      index: 0,
                    ),
                    _buildTabButton(
                      theme: theme,
                      label: 'Least Creditors',
                      index: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (_leaderboardTab == 0)
            _buildTopCreditorsList(theme),
          if (_leaderboardTab == 1)
            _buildLeastCreditorsList(theme),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required ThemeProvider theme,
    required String label,
    required int index,
  }) {
    final active = _leaderboardTab == index;
    return InkWell(
      onTap: () => setState(() => _leaderboardTab = index),
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          boxShadow:
              active
                  ? [
                    BoxShadow(
                      color: Colors.black.withAlpha(10),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ]
                  : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: theme.mobileTexts.b4.fontSize,
            fontWeight:
                active ? FontWeight.bold : FontWeight.w500,
            color:
                active
                    ? theme.lightModeColor.prColor300
                    : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _buildTopCreditorsList(ThemeProvider theme) {
    final list = _result.topCreditors;
    if (list.isEmpty) {
      return _buildEmptyRankings(
        theme,
        'No creditors with outstanding balances found.',
      );
    }
    return Column(
      children:
          list.asMap().entries.map((e) {
            return _buildRankingRow(
              theme: theme,
              rank: e.key + 1,
              title: e.value.customerName,
              subtitle:
                  '${e.value.invoiceCount} invoices  •  Total Value: ${_fmt(e.value.totalInvoiceValue)}  •  Paid: ${_fmt(e.value.amountPaid)}',
              value: _fmt(e.value.outstandingBalance),
              trailingLabel: 'Outstanding Balance',
              onTap:
                  () => _navigateToTableWithFilter(
                    customerUuid: e.value.customerUuid,
                  ),
            );
          }).toList(),
    );
  }

  Widget _buildLeastCreditorsList(ThemeProvider theme) {
    final list = _result.leastCreditors;
    if (list.isEmpty) {
      return _buildEmptyRankings(
        theme,
        'No creditors with outstanding balances found.',
      );
    }
    return Column(
      children:
          list.asMap().entries.map((e) {
            return _buildRankingRow(
              theme: theme,
              rank: e.key + 1,
              title: e.value.customerName,
              subtitle:
                  '${e.value.invoiceCount} invoices  •  Total Value: ${_fmt(e.value.totalInvoiceValue)}  •  Paid: ${_fmt(e.value.amountPaid)}',
              value: _fmt(e.value.outstandingBalance),
              trailingLabel: 'Outstanding Balance',
              onTap:
                  () => _navigateToTableWithFilter(
                    customerUuid: e.value.customerUuid,
                  ),
            );
          }).toList(),
    );
  }

  Widget _buildRankingRow({
    required ThemeProvider theme,
    required int rank,
    required String title,
    required String subtitle,
    required String value,
    required String trailingLabel,
    VoidCallback? onTap,
  }) {
    final Color badgeBg;
    final Color badgeText;
    if (rank == 1) {
      badgeBg = const Color(0xFFFEF3C7);
      badgeText = const Color(0xFFB45309);
    } else if (rank == 2) {
      badgeBg = const Color(0xFFE0E7FF);
      badgeText = const Color(0xFF3730A3);
    } else {
      badgeBg = const Color(0xFFF3F4F6);
      badgeText = const Color(0xFF4B5563);
    }

    return InkWell(
      onTap: onTap,
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
          children: [
            Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: badgeBg,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$rank',
                style: TextStyle(
                  fontSize: theme.mobileTexts.b4.fontSize,
                  fontWeight: FontWeight.bold,
                  color: badgeText,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.b3.fontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.b4.fontSize,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b4.fontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                Text(
                  trailingLabel,
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b5.fontSize,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyRankings(
    ThemeProvider theme,
    String message,
  ) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Text(
          message,
          style: TextStyle(
            fontSize: theme.mobileTexts.b3.fontSize,
            color: Colors.grey.shade500,
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Detailed Breakdown Tables Section (4.6, 4.7, 4.8, 4.9, 4.10, 4.11, 4.14)
  // ---------------------------------------------------------------------------
  // ---------------------------------------------------------------------------
  // Detailed Breakdown Tables Section (4.6, 4.7, 4.8, 4.10, 4.14)
  // ---------------------------------------------------------------------------
  Widget _buildTablesSection(ThemeProvider theme) {
    final availableTabs = [
      'Customers',
      'Staff',
      if (_departmentsEnabled) 'Departments',
      if (_bulkSaleEnabled) 'Sub-Staff',
      'Invoice Statuses',
    ];

    return Container(
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
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                Text(
                  'Detailed Invoice Breakdown & Analysis',
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b1.fontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children:
                        availableTabs.asMap().entries.map((
                          entry,
                        ) {
                          final active =
                              _tableTab == entry.key;
                          return Padding(
                            padding: const EdgeInsets.only(
                              right: 6,
                            ),
                            child: ChoiceChip(
                              label: Text(entry.value),
                              selected: active,
                              onSelected:
                                  (_) => setState(
                                    () =>
                                        _tableTab =
                                            entry.key,
                                  ),
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
                                    active
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                color:
                                    active
                                        ? theme
                                            .lightModeColor
                                            .prColor300
                                        : Colors
                                            .grey
                                            .shade700,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                      6,
                                    ),
                                side: BorderSide(
                                  color:
                                      active
                                          ? theme
                                              .lightModeColor
                                              .prColor200
                                          : Colors
                                              .transparent,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          _buildCurrentTableTab(
            theme,
            availableTabs[_tableTab.clamp(
              0,
              availableTabs.length - 1,
            )],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentTableTab(
    ThemeProvider theme,
    String tabTitle,
  ) {
    switch (tabTitle) {
      case 'Customers':
        return _buildCustomerSummaryTable(theme);
      case 'Staff':
        return _buildStaffSummaryTable(theme);
      case 'Departments':
        return _buildDepartmentSummaryTable(theme);
      case 'Sub-Staff':
        return _buildSubStaffSummaryTable(theme);
      case 'Invoice Statuses':
        return _buildStatusSummaryTable(theme);
      default:
        return _buildCustomerSummaryTable(theme);
    }
  }

  Widget _badge(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 8,
      vertical: 3,
    ),
    decoration: BoxDecoration(
      color: color.withAlpha(25),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withAlpha(80)),
    ),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: color,
      ),
    ),
  );

  Widget _tableHeaderCell(
    ThemeProvider theme,
    _SummaryCol c,
  ) {
    return SizedBox(
      width: c.width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Align(
          alignment:
              c.align == TextAlign.start
                  ? Alignment.centerLeft
                  : (c.align == TextAlign.end
                      ? Alignment.centerRight
                      : Alignment.center),
          child: Text(
            c.label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: c.align,
            style: TextStyle(
              fontSize: theme.mobileTexts.b3.fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget _cell({
    required double width,
    required Widget child,
    TextAlign align = TextAlign.start,
  }) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Align(
          alignment:
              align == TextAlign.start
                  ? Alignment.centerLeft
                  : (align == TextAlign.end
                      ? Alignment.centerRight
                      : Alignment.center),
          child: child,
        ),
      ),
    );
  }

  Widget _txtCell(
    ThemeProvider theme,
    String text, {
    required double width,
    bool bold = false,
    Color? color,
    TextAlign align = TextAlign.start,
  }) {
    return _cell(
      width: width,
      align: align,
      child: Text(
        text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: align,
        style: TextStyle(
          fontSize: theme.mobileTexts.b3.fontSize,
          fontWeight:
              bold ? FontWeight.bold : FontWeight.w500,
          color: color ?? Colors.black87,
        ),
      ),
    );
  }

  Widget _renderStyledTable<T>({
    required ThemeProvider theme,
    required List<_SummaryCol> columns,
    required List<T> items,
    required List<Widget> Function(T item, int index)
    buildCells,
    VoidCallback? Function(T item)? onRowTap,
  }) {
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(
            'No records found.',
            style: TextStyle(
              fontSize: theme.mobileTexts.b3.fontSize,
              color: Colors.grey.shade500,
            ),
          ),
        ),
      );
    }

    final double totalWidth = columns.fold<double>(
      0,
      (s, c) => s + c.width,
    );

    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
          ),
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
            controller: _tableHScroll,
            thumbVisibility: true,
            notificationPredicate:
                (notif) =>
                    notif.metrics.axis == Axis.horizontal,
            child: SingleChildScrollView(
              controller: _tableHScroll,
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: w,
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 46,
                      color: theme.lightModeColor.prColor300
                          .withAlpha(22),
                      child: Row(
                        children:
                            columns
                                .map(
                                  (c) => _tableHeaderCell(
                                    theme,
                                    c,
                                  ),
                                )
                                .toList(),
                      ),
                    ),
                    const Divider(height: 1, thickness: 1),
                    ...items.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      final isEven = index.isEven;
                      final onTap = onRowTap?.call(item);
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Material(
                            color:
                                isEven
                                    ? Colors.white
                                    : Colors.grey.shade50
                                        .withAlpha(120),
                            child: InkWell(
                              mouseCursor:
                                  onTap != null
                                      ? SystemMouseCursors
                                          .click
                                      : SystemMouseCursors
                                          .basic,
                              onTap: onTap,
                              child: Container(
                                height: 48,
                                padding:
                                    const EdgeInsets.symmetric(
                                      horizontal: 0,
                                    ),
                                child: Row(
                                  children: buildCells(
                                    item,
                                    index,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Divider(
                            height: 1,
                            color: Colors.grey.shade100,
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // 4.7 Customer Summary Table
  Widget _buildCustomerSummaryTable(ThemeProvider theme) {
    final filtered = invoiceSummaryCustomers(
      _result.allCustomerSummaries,
      _customerSearch,
    );

    final cols = [
      const _SummaryCol(
        label: '#',
        width: 50,
        align: TextAlign.center,
      ),
      const _SummaryCol(
        label: 'Customer',
        width: 170,
        align: TextAlign.start,
      ),
      const _SummaryCol(
        label: 'Invoices',
        width: 90,
        align: TextAlign.center,
      ),
      const _SummaryCol(
        label: 'Total Value',
        width: 130,
        align: TextAlign.center,
      ),
      const _SummaryCol(
        label: 'Amount Paid',
        width: 130,
        align: TextAlign.center,
      ),
      const _SummaryCol(
        label: 'Balance',
        width: 130,
        align: TextAlign.center,
      ),
      if (_canSeeCost)
        const _SummaryCol(
          label: 'Profit/Loss',
          width: 120,
          align: TextAlign.center,
        ),
      const _SummaryCol(
        label: 'Avg Value',
        width: 120,
        align: TextAlign.center,
      ),
      const _SummaryCol(
        label: 'Last Invoice',
        width: 140,
        align: TextAlign.start,
      ),
      const _SummaryCol(
        label: 'Last Payment',
        width: 140,
        align: TextAlign.start,
      ),
    ];

    final green = Colors.green.shade700;
    final red = theme.lightModeColor.errorColor200;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 38,
                  child: TextField(
                    controller: _customerSearchCtrl,
                    onChanged:
                        (val) => setState(
                          () =>
                              _customerSearch = val.trim(),
                        ),
                    decoration: InputDecoration(
                      hintText: 'Search customer...',
                      hintStyle: TextStyle(
                        fontSize:
                            theme.mobileTexts.b3.fontSize,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        size: 18,
                      ),
                      suffixIcon:
                          _customerSearch.isNotEmpty
                              ? IconButton(
                                icon: const Icon(
                                  Icons.clear,
                                  size: 16,
                                ),
                                onPressed: () {
                                  _customerSearchCtrl
                                      .clear();
                                  setState(
                                    () =>
                                        _customerSearch =
                                            '',
                                  );
                                },
                              )
                              : null,
                      contentPadding:
                          const EdgeInsets.symmetric(
                            vertical: 0,
                            horizontal: 10,
                          ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          6,
                        ),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.b3.fontSize,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${filtered.length} Customers',
                style: TextStyle(
                  fontSize: theme.mobileTexts.b3.fontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        _renderStyledTable<CustomerInvoiceSummary>(
          theme: theme,
          columns: cols,
          items: filtered,
          onRowTap:
              (c) =>
                  () => _navigateToTableWithFilter(
                    customerUuid: c.customerUuid,
                  ),
          buildCells:
              (c, idx) => [
                _txtCell(
                  theme,
                  '${idx + 1}',
                  width: 50,
                  align: TextAlign.center,
                ),
                _txtCell(
                  theme,
                  c.customerName,
                  width: 170,
                  bold: true,
                  align: TextAlign.start,
                ),
                _txtCell(
                  theme,
                  c.invoiceCount.toString(),
                  width: 90,
                  align: TextAlign.center,
                ),
                _txtCell(
                  theme,
                  _fmt(c.totalInvoiceValue),
                  width: 130,
                  bold: true,
                  align: TextAlign.center,
                ),
                _txtCell(
                  theme,
                  _fmt(c.amountPaid),
                  width: 130,
                  bold: true,
                  color: c.amountPaid > 0 ? green : null,
                  align: TextAlign.center,
                ),
                _txtCell(
                  theme,
                  _fmt(c.outstandingBalance),
                  width: 130,
                  bold: true,
                  color:
                      c.outstandingBalance > 0
                          ? red
                          : green,
                  align: TextAlign.center,
                ),
                if (_canSeeCost)
                  _txtCell(
                    theme,
                    _fmt(c.totalProfit),
                    width: 120,
                    bold: true,
                    color:
                        (c.totalProfit ?? 0) >= 0
                            ? green
                            : red,
                    align: TextAlign.center,
                  ),
                _txtCell(
                  theme,
                  _fmt(c.averageInvoiceValue),
                  width: 120,
                  align: TextAlign.center,
                ),
                _txtCell(
                  theme,
                  c.lastInvoiceDate != null
                      ? formatDateTime(c.lastInvoiceDate!)
                      : '—',
                  width: 140,
                  align: TextAlign.start,
                ),
                _txtCell(
                  theme,
                  c.lastPaymentDate != null
                      ? formatDateTime(c.lastPaymentDate!)
                      : '—',
                  width: 140,
                  align: TextAlign.start,
                ),
              ],
        ),
      ],
    );
  }

  // 4.8 Staff Summary Table
  Widget _buildStaffSummaryTable(ThemeProvider theme) {
    final list = _result.allStaffSummaries;
    final cols = [
      const _SummaryCol(
        label: '#',
        width: 50,
        align: TextAlign.center,
      ),
      const _SummaryCol(
        label: 'Staff Member',
        width: 180,
        align: TextAlign.start,
      ),
      const _SummaryCol(
        label: 'Invoices',
        width: 90,
        align: TextAlign.center,
      ),
      const _SummaryCol(
        label: 'Total Value',
        width: 140,
        align: TextAlign.center,
      ),
      const _SummaryCol(
        label: 'Collected',
        width: 130,
        align: TextAlign.center,
      ),
      const _SummaryCol(
        label: 'Balance',
        width: 130,
        align: TextAlign.center,
      ),
      if (_canSeeCost)
        const _SummaryCol(
          label: 'Profit/Loss',
          width: 120,
          align: TextAlign.center,
        ),
      const _SummaryCol(
        label: 'Avg Value',
        width: 120,
        align: TextAlign.center,
      ),
      const _SummaryCol(
        label: '% of Value',
        width: 110,
        align: TextAlign.center,
      ),
    ];

    final green = Colors.green.shade700;
    final red = theme.lightModeColor.errorColor200;

    return _renderStyledTable<StaffInvoiceSummary>(
      theme: theme,
      columns: cols,
      items: list,
      onRowTap:
          (s) =>
              () => _navigateToTableWithFilter(
                staffId: s.staffId,
              ),
      buildCells:
          (s, idx) => [
            _txtCell(
              theme,
              '${idx + 1}',
              width: 50,
              align: TextAlign.center,
            ),
            _txtCell(
              theme,
              s.staffName,
              width: 180,
              bold: true,
              align: TextAlign.start,
            ),
            _txtCell(
              theme,
              s.invoiceCount.toString(),
              width: 90,
              align: TextAlign.center,
            ),
            _txtCell(
              theme,
              _fmt(s.totalInvoiceValue),
              width: 140,
              bold: true,
              align: TextAlign.center,
            ),
            _txtCell(
              theme,
              _fmt(s.amountPaid),
              width: 130,
              bold: true,
              color: s.amountPaid > 0 ? green : null,
              align: TextAlign.center,
            ),
            _txtCell(
              theme,
              _fmt(s.outstandingBalance),
              width: 130,
              bold: true,
              color: s.outstandingBalance > 0 ? red : green,
              align: TextAlign.center,
            ),
            if (_canSeeCost)
              _txtCell(
                theme,
                _fmt(s.totalProfit),
                width: 120,
                bold: true,
                color:
                    (s.totalProfit ?? 0) >= 0 ? green : red,
                align: TextAlign.center,
              ),
            _txtCell(
              theme,
              _fmt(s.averageInvoiceValue),
              width: 120,
              align: TextAlign.center,
            ),
            _txtCell(
              theme,
              '${_fmtNum(s.percentageOfTotalValue)}%',
              width: 110,
              align: TextAlign.center,
            ),
          ],
    );
  }

  // 4.6 Department Summary Table
  Widget _buildDepartmentSummaryTable(ThemeProvider theme) {
    final list = _result.departmentSummaries;
    final cols = [
      const _SummaryCol(
        label: '#',
        width: 50,
        align: TextAlign.center,
      ),
      const _SummaryCol(
        label: 'Department',
        width: 180,
        align: TextAlign.start,
      ),
      const _SummaryCol(
        label: 'Invoices',
        width: 90,
        align: TextAlign.center,
      ),
      const _SummaryCol(
        label: 'Total Value',
        width: 140,
        align: TextAlign.center,
      ),
      const _SummaryCol(
        label: 'Amount Paid',
        width: 130,
        align: TextAlign.center,
      ),
      const _SummaryCol(
        label: 'Balance',
        width: 130,
        align: TextAlign.center,
      ),
      if (_canSeeCost)
        const _SummaryCol(
          label: 'Profit/Loss',
          width: 120,
          align: TextAlign.center,
        ),
      const _SummaryCol(
        label: 'Avg Value',
        width: 120,
        align: TextAlign.center,
      ),
      const _SummaryCol(
        label: '% of Value',
        width: 110,
        align: TextAlign.center,
      ),
    ];

    final green = Colors.green.shade700;
    final red = theme.lightModeColor.errorColor200;

    return _renderStyledTable<DepartmentInvoiceSummary>(
      theme: theme,
      columns: cols,
      items: list,
      onRowTap:
          (d) => () {
            if (d.departmentName == 'Others') {
              _navigateToTableWithFilter(
                departmentKey: invoiceReportNoDepartmentKey,
              );
            } else {
              _navigateToTableWithFilter(
                departmentKey: d.departmentKey,
              );
            }
          },
      buildCells:
          (d, idx) => [
            _txtCell(
              theme,
              '${idx + 1}',
              width: 50,
              align: TextAlign.center,
            ),
            _txtCell(
              theme,
              d.departmentName,
              width: 180,
              bold: true,
              align: TextAlign.start,
            ),
            _txtCell(
              theme,
              d.invoiceCount.toString(),
              width: 90,
              align: TextAlign.center,
            ),
            _txtCell(
              theme,
              _fmt(d.totalInvoiceValue),
              width: 140,
              bold: true,
              align: TextAlign.center,
            ),
            _txtCell(
              theme,
              _fmt(d.amountPaid),
              width: 130,
              bold: true,
              color: d.amountPaid > 0 ? green : null,
              align: TextAlign.center,
            ),
            _txtCell(
              theme,
              _fmt(d.outstandingBalance),
              width: 130,
              bold: true,
              color: d.outstandingBalance > 0 ? red : green,
              align: TextAlign.center,
            ),
            if (_canSeeCost)
              _txtCell(
                theme,
                _fmt(d.totalProfit),
                width: 120,
                bold: true,
                color:
                    (d.totalProfit ?? 0) >= 0 ? green : red,
                align: TextAlign.center,
              ),
            _txtCell(
              theme,
              _fmt(d.averageInvoiceValue),
              width: 120,
              align: TextAlign.center,
            ),
            _txtCell(
              theme,
              '${_fmtNum(d.percentageOfInvoiceValue)}%',
              width: 110,
              align: TextAlign.center,
            ),
          ],
    );
  }

  // 4.14 Sub-Staff Summary Table
  Widget _buildSubStaffSummaryTable(ThemeProvider theme) {
    final list = _result.subStaffSummaries;
    final cols = [
      const _SummaryCol(
        label: '#',
        width: 50,
        align: TextAlign.center,
      ),
      const _SummaryCol(
        label: 'Sub-Staff Member',
        width: 180,
        align: TextAlign.start,
      ),
      const _SummaryCol(
        label: 'Invoices',
        width: 90,
        align: TextAlign.center,
      ),
      const _SummaryCol(
        label: 'Total Value',
        width: 140,
        align: TextAlign.center,
      ),
      const _SummaryCol(
        label: 'Amount Paid',
        width: 130,
        align: TextAlign.center,
      ),
      const _SummaryCol(
        label: 'Balance',
        width: 130,
        align: TextAlign.center,
      ),
      if (_canSeeCost)
        const _SummaryCol(
          label: 'Profit/Loss',
          width: 120,
          align: TextAlign.center,
        ),
    ];

    final green = Colors.green.shade700;
    final red = theme.lightModeColor.errorColor200;

    return _renderStyledTable<SubStaffInvoiceSummary>(
      theme: theme,
      columns: cols,
      items: list,
      onRowTap:
          (s) =>
              () => _navigateToTableWithFilter(
                subStaffUuid: s.subStaffUuid,
              ),
      buildCells:
          (s, idx) => [
            _txtCell(
              theme,
              '${idx + 1}',
              width: 50,
              align: TextAlign.center,
            ),
            _txtCell(
              theme,
              s.subStaffName,
              width: 180,
              bold: true,
              align: TextAlign.start,
            ),
            _txtCell(
              theme,
              s.invoiceCount.toString(),
              width: 90,
              align: TextAlign.center,
            ),
            _txtCell(
              theme,
              _fmt(s.totalInvoiceValue),
              width: 140,
              bold: true,
              align: TextAlign.center,
            ),
            _txtCell(
              theme,
              _fmt(s.amountPaid),
              width: 130,
              bold: true,
              color: s.amountPaid > 0 ? green : null,
              align: TextAlign.center,
            ),
            _txtCell(
              theme,
              _fmt(s.outstandingBalance),
              width: 130,
              bold: true,
              color: s.outstandingBalance > 0 ? red : green,
              align: TextAlign.center,
            ),
            if (_canSeeCost)
              _txtCell(
                theme,
                _fmt(s.totalProfit),
                width: 120,
                bold: true,
                color:
                    (s.totalProfit ?? 0) >= 0 ? green : red,
                align: TextAlign.center,
              ),
          ],
    );
  }

  // 4.10 Invoice Status Summary Table
  Widget _buildStatusSummaryTable(ThemeProvider theme) {
    final list = _result.statusSummaries;
    final cols = [
      const _SummaryCol(
        label: '#',
        width: 50,
        align: TextAlign.center,
      ),
      const _SummaryCol(
        label: 'Invoice Status',
        width: 150,
        align: TextAlign.center,
      ),
      const _SummaryCol(
        label: 'Invoices',
        width: 100,
        align: TextAlign.center,
      ),
      const _SummaryCol(
        label: 'Total Value',
        width: 140,
        align: TextAlign.center,
      ),
      const _SummaryCol(
        label: 'Amount Paid',
        width: 140,
        align: TextAlign.center,
      ),
      const _SummaryCol(
        label: 'Balance',
        width: 140,
        align: TextAlign.center,
      ),
      const _SummaryCol(
        label: '% of Invoices',
        width: 120,
        align: TextAlign.center,
      ),
    ];

    final green = Colors.green.shade700;
    final amber = Colors.amber.shade800;
    final red = theme.lightModeColor.errorColor200;

    return _renderStyledTable<InvoicePaymentStatusSummary>(
      theme: theme,
      columns: cols,
      items: list,
      onRowTap:
          (s) => () {
            if (s.statusCode == 2) {
              _navigateToTableWithFilter(
                paymentStatus:
                    InvoicePaymentStatusFilter.paid,
              );
            } else if (s.statusCode == 1) {
              _navigateToTableWithFilter(
                paymentStatus:
                    InvoicePaymentStatusFilter.partial,
              );
            } else if (s.statusCode == 0) {
              _navigateToTableWithFilter(
                paymentStatus:
                    InvoicePaymentStatusFilter.unpaid,
              );
            }
          },
      buildCells:
          (s, idx) => [
            _txtCell(
              theme,
              '${idx + 1}',
              width: 50,
              align: TextAlign.center,
            ),
            _cell(
              width: 150,
              align: TextAlign.center,
              child:
                  s.statusCode == 2
                      ? _badge('Paid', green)
                      : (s.statusCode == 1
                          ? _badge('Partial', amber)
                          : (s.statusCode == 0
                              ? _badge('Unpaid', red)
                              : _badge(
                                s.statusName,
                                Colors.grey,
                              ))),
            ),
            _txtCell(
              theme,
              s.invoiceCount.toString(),
              width: 100,
              align: TextAlign.center,
            ),
            _txtCell(
              theme,
              _fmt(s.totalInvoiceValue),
              width: 140,
              bold: true,
              align: TextAlign.center,
            ),
            _txtCell(
              theme,
              _fmt(s.amountPaid),
              width: 140,
              bold: true,
              color: s.amountPaid > 0 ? green : null,
              align: TextAlign.center,
            ),
            _txtCell(
              theme,
              _fmt(s.outstandingBalance),
              width: 140,
              bold: true,
              color: s.outstandingBalance > 0 ? red : green,
              align: TextAlign.center,
            ),
            _txtCell(
              theme,
              '${_fmtNum(s.percentageOfInvoices)}%',
              width: 120,
              align: TextAlign.center,
            ),
          ],
    );
  }
}

class _SummaryCol {
  final String label;
  final double width;
  final TextAlign align;

  const _SummaryCol({
    required this.label,
    required this.width,
    this.align = TextAlign.start,
  });
}
