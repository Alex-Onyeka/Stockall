import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/pages/report/components/report_period_loader.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/report/components/export/report_export_button.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/report_pill.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/components/receipts_report_filter_widgets.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/receipts_report_main_page.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_summary/class/receipts_report_summary_export_spec.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_summary/class/receipts_report_summary_logic.dart';
import 'package:stockall/providers/theme_provider.dart';

/// One column of a summary table.
class _SCol<T> {
  final String label;
  final double width;
  final bool alignStart;
  final Widget Function(T item, int index) cell;
  final ReceiptsGroupSortField? sort;

  const _SCol({
    required this.label,
    required this.width,
    required this.cell,
    this.alignStart = false,
    this.sort,
  });
}

/// Shared body of the Receipt Summary page (desktop + mobile).
///
/// Opens on today's business day with no filters. It is reached
/// only from its Sales Reports tile, never from the table.
class ReceiptsReportSummaryView extends StatefulWidget {
  final bool isDesktop;

  const ReceiptsReportSummaryView({
    super.key,
    required this.isDesktop,
  });

  @override
  State<ReceiptsReportSummaryView> createState() =>
      _ReceiptsReportSummaryViewState();
}

class _ReceiptsReportSummaryViewState
    extends State<ReceiptsReportSummaryView> {
  late final ReceiptsReportFilters _filters;
  late ReceiptsReportPeriod _period;
  bool _showFilters = false;

  bool _loading = true;
  String? _error;
  String _signature = '';

  List<ReceiptsReportRow> _baseRows = [];
  ReceiptsFilterChoices _choices =
      ReceiptsFilterChoices.empty;

  // Results for the current period and filters.
  List<ReceiptsReportRow> _rows = [];
  ReceiptsSummaryStats _stats =
      ReceiptsSummaryBuilder.stats(const []);
  List<ReceiptsSummaryGroup> _customers = [];
  List<ReceiptsSummaryGroup> _staff = [];
  List<ReceiptsSummaryGroup> _subStaff = [];
  List<ReceiptsSummaryGroup> _departments = [];
  List<ReceiptsChannelSummary> _channels = [];
  List<ReceiptsTypeSummary> _types = [];
  List<ReceiptsTrendPoint> _trend = [];
  ReceiptsTrendInterval _interval =
      ReceiptsTrendInterval.daily;

  ReceiptsGroupSortField _customerSort =
      ReceiptsGroupSortField.revenue;
  bool _customerAscending = false;
  bool _showAllCustomers = false;

  static const int _customerPreview = 20;

  @override
  void initState() {
    super.initState();
    _filters = ReceiptsReportFilters();
    _period = ReceiptsReportPeriod.today();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load(refreshFromStore: true);
    });
  }

  // ---------------------------------------------------------------
  // data
  // ---------------------------------------------------------------

  bool get _departmentsEnabled =>
      shopSingle()?.manageDepartments == true;

  bool get _subStaffEnabled =>
      shopSingle()?.bulkSale == true;

  bool get _canSeeCost => authorization(
    authorized: Authorizations().manageCostPrice,
  );

  bool get _canPickDate =>
      authorization(authorized: Authorizations().viewDate);

  Future<void> _load({
    required bool refreshFromStore,
  }) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await loadReceiptsForReportPeriod(
        context,
        period: _period,
        refreshFromStore: refreshFromStore,
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

  // Same signature as the table, so both refresh on the same
  // changes.
  String _sourceSignature() {
    final provider = returnReceiptProviderSingle();
    int latest = 0;
    int withItems = 0;
    double total = 0;
    for (final r in provider.receipts) {
      final t = r.createdAt.millisecondsSinceEpoch;
      if (t > latest) latest = t;
      if (r.items?.isNotEmpty == true) withItems++;
      total += r.getTotalRevenue();
    }
    return '${provider.receipts.length}|$latest|$total|'
        '$withItems|${provider.mainSales.length}|'
        '${returnDepartmentProvider().currentDepartment()?.uuid}|'
        '${currentUser().userId}|$_departmentsEnabled';
  }

  void _rebuildBase() {
    final provider = returnReceiptProviderSingle();
    final scoped = ReceiptsReportAccess.scope(
      receipts: provider.receipts,
      departmentsEnabled: _departmentsEnabled,
      canViewAllDepartments: authorization(
        authorized: Authorizations().viewAllDepartments,
      ),
      currentDepartmentUuid:
          returnDepartmentProvider()
              .currentDepartment()
              ?.uuid,
      canViewAllTransactions: authorization(
        authorized:
            Authorizations().viewAllTransactionRecords,
      ),
      currentUserId: currentUser().userId,
    );
    _baseRows = ReceiptsReportRowBuilder.buildAll(
      receipts: scoped,
      legacySales: provider.mainSales,
    );
    _choices = ReceiptsFilterChoices.fromRows(_baseRows);
    _signature = _sourceSignature();
  }

  void _recompute() {
    _rows = ReceiptsReportQuery.filterAndSort(
      rows: _baseRows,
      period: _period,
      filters: _filters,
      sortField: ReceiptsSortField.createdAt,
      ascending: false,
      departmentsEnabled: _departmentsEnabled,
      subStaffEnabled: _subStaffEnabled,
      profitVisible: _canSeeCost,
    );
    _stats = ReceiptsSummaryBuilder.stats(_rows);
    _customers = ReceiptsSummaryBuilder.customers(_rows);
    _staff = ReceiptsSummaryBuilder.staff(_rows);
    _subStaff = ReceiptsSummaryBuilder.subStaff(_rows);
    _departments = ReceiptsSummaryBuilder.departments(
      _rows,
    );
    _channels = ReceiptsSummaryBuilder.channels(_rows);
    _types = ReceiptsSummaryBuilder.types(_rows);
    _trend = ReceiptsTrendBuilder.build(
      rows: _rows,
      period: _period,
    );
    final span = ReceiptsTrendBuilder.span(
      rows: _rows,
      period: _period,
      now: DateTime.now(),
    );
    _interval =
        span == null
            ? ReceiptsTrendInterval.daily
            : ReceiptsTrendBuilder.intervalFor(
              span.start,
              span.end,
            );
  }

  void _apply(VoidCallback change) {
    setState(() {
      change();
      try {
        _recompute();
        _error = null;
      } catch (e) {
        _error = e.toString();
      }
    });
  }

  void _resetAll() => _apply(_filters.clearAll);

  /// Opens the table on the summary's period and filters, plus
  /// the clicked row's key.
  void _openTable(ReceiptsReportFilters filters) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ReceiptsReportMainPage(
              initialFilters: filters,
              initialPeriod: _period,
            ),
      ),
    );
  }

  // ---------------------------------------------------------------
  // formatting
  // ---------------------------------------------------------------

  String _money(num v) =>
      formatMoneyBig(amount: v, context: context);

  String _percent(double? v) =>
      v == null
          ? 'N/A'
          : '${formatLargeNumberDouble(double.parse(v.toStringAsFixed(1)))}%';

  Color? _signColor(ThemeProvider theme, double v) =>
      v > 0
          ? Colors.green.shade700
          : (v < 0
              ? theme.lightModeColor.errorColor200
              : null);

  String _bucketLabel(DateTime d) {
    switch (_interval) {
      case ReceiptsTrendInterval.hourly:
        return DateFormat('ha').format(d);
      case ReceiptsTrendInterval.daily:
      case ReceiptsTrendInterval.weekly:
        return formatMonthAndDay(d);
      case ReceiptsTrendInterval.monthly:
        return DateFormat('MMM yy').format(d);
    }
  }

  String get _intervalLabel {
    switch (_interval) {
      case ReceiptsTrendInterval.hourly:
        return 'Hourly';
      case ReceiptsTrendInterval.daily:
        return 'Daily';
      case ReceiptsTrendInterval.weekly:
        return 'Weekly (from Monday)';
      case ReceiptsTrendInterval.monthly:
        return 'Monthly';
    }
  }

  static Color _typeColor(ReceiptType t) {
    switch (t) {
      case ReceiptType.sales:
        return Colors.blueGrey;
      case ReceiptType.invoicePayment:
        return Colors.deepPurple;
      case ReceiptType.orderDelivery:
        return Colors.teal;
      case ReceiptType.unknown:
        return Colors.orange.shade800;
    }
  }

  // ---------------------------------------------------------------
  // build
  // ---------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = returnTheme(context);
    // Listen, so sales, edits and sync update the summary.
    returnReceiptProvider(context);
    shop(context);

    if (!_loading && _error == null) {
      final sig = _sourceSignature();
      if (sig != _signature) {
        try {
          _rebuildBase();
          _recompute();
        } catch (e) {
          _error = e.toString();
        }
      }
    }

    // final accent = theme.lightModeColor.prColor300;
    return Scaffold(
      appBar: appBar(
        context: context,
        title: 'Receipt Summary',
        widget: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // TextButton.icon(
            //   style: TextButton.styleFrom(
            //     backgroundColor: accent.withAlpha(20),
            //     foregroundColor: accent,
            //     padding: const EdgeInsets.symmetric(
            //       horizontal: 10,
            //       vertical: 6,
            //     ),
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(6),
            //     ),
            //   ),
            //   onPressed:
            //       _loading
            //           ? null
            //           : () => _openTable(_filters.copy()),
            //   icon: const Icon(
            //     Icons.table_chart_outlined,
            //     size: 15,
            //   ),
            //   label: Text(
            //     'View Table',
            //     style: TextStyle(
            //       fontSize: theme.mobileTexts.b3.fontSize,
            //       fontWeight: FontWeight.bold,
            //     ),
            //   ),
            // ),
            IconButton(
              tooltip: 'Refresh',
              icon: const Icon(
                Icons.refresh_rounded,
                size: 20,
              ),
              onPressed:
                  _loading
                      ? null
                      : () => _load(refreshFromStore: true),
            ),
            const SizedBox(width: 6),
          ],
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
              'The summary could not be generated.',
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

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: widget.isDesktop ? 20 : 12,
        vertical: 10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          _toolbar(theme),
          if (_showFilters) _filterPanel(),
          ReceiptsReportFilterChips(
            theme: theme,
            filters: _filters,
            choices: _choices,
            departmentsEnabled: _departmentsEnabled,
            subStaffEnabled: _subStaffEnabled,
            profitVisible: _canSeeCost,
            showSearch: true,
            money: _money,
            onApply: _apply,
          ),
          _notes(),
          if (_rows.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: EmptyWidgetDisplayOnly(
                title:
                    _filters.hasAnything
                        ? 'No Matching Receipts'
                        : 'Empty List',
                subText:
                    _filters.hasAnything
                        ? 'No receipt matches your filters'
                        : 'No receipt was recorded in this period',
                theme: theme,
                height: 35,
                icon: Icons.clear,
                altAction:
                    _filters.hasAnything ? _resetAll : null,
                altActionText:
                    _filters.hasAnything
                        ? 'Clear all filters'
                        : null,
                altIcon:
                    _filters.hasAnything
                        ? Icons.filter_alt_off
                        : null,
              ),
            )
          else ...[
            _statCards(theme),
            _pair([
              _trendCard(theme),
              _activityCard(theme),
            ]),
            _pair([
              _rankingCard(
                theme,
                title: 'Top 3 Customers',
                groups: ReceiptsSummaryBuilder.top3(
                  _customers,
                ),
                nameLabel: 'Customer',
                showAverage: true,
                onTap:
                    (g) => _openTable(
                      ReceiptsSummaryBuilder.handoff(
                        _filters,
                        customerKey: g.key,
                      ),
                    ),
              ),
              _rankingCard(
                theme,
                title: 'Least 3 Customers',
                groups: ReceiptsSummaryBuilder.least3(
                  _customers,
                ),
                nameLabel: 'Customer',
                showAverage: false,
                onTap:
                    (g) => _openTable(
                      ReceiptsSummaryBuilder.handoff(
                        _filters,
                        customerKey: g.key,
                      ),
                    ),
              ),
            ]),
            _pair([
              _rankingCard(
                theme,
                title: 'Top 3 Staff',
                groups: ReceiptsSummaryBuilder.top3(_staff),
                nameLabel: 'Staff',
                showAverage: true,
                onTap:
                    (g) => _openTable(
                      ReceiptsSummaryBuilder.handoff(
                        _filters,
                        staffKey: g.key,
                      ),
                    ),
              ),
              _rankingCard(
                theme,
                title: 'Least 3 Staff',
                groups: ReceiptsSummaryBuilder.least3(
                  _staff,
                ),
                nameLabel: 'Staff',
                showAverage: false,
                onTap:
                    (g) => _openTable(
                      ReceiptsSummaryBuilder.handoff(
                        _filters,
                        staffKey: g.key,
                      ),
                    ),
              ),
            ]),
            _pair([_channelCard(theme), _typeCard(theme)]),
            if (_departmentsEnabled) _departmentCard(theme),
            _customerCard(theme),
            _staffCard(theme),
            if (_subStaffEnabled) _subStaffCard(theme),
          ],
        ],
      ),
    );
  }

  /// Side by side on desktop, stacked on mobile.
  Widget _pair(List<Widget> children) {
    if (!widget.isDesktop) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: children,
      );
    }
    // Not IntrinsicHeight: the tables and charts use
    // LayoutBuilder, which cannot report intrinsic sizes.
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        for (final c in children) Expanded(child: c),
      ],
    );
  }

  // ---------------------------------------------------------------
  // toolbar / filters / notes
  // ---------------------------------------------------------------

  Widget _toolbar(ThemeProvider theme) {
    final active = _filters.activeCount;
    return Wrap(
      spacing: 2,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ReceiptsReportPeriodButton(
          theme: theme,
          period: _period,
          enabled: _canPickDate,
          onChanged: (p) {
            _apply(() => _period = p);
            if (!p.isAllTime) {
              _load(refreshFromStore: false);
            }
          },
        ),
        Padding(
          padding: const EdgeInsets.only(
            left: 6.0,
            right: 5,
          ),
          child: ReportPill(
            theme: theme,
            icon: Icons.tune_rounded,
            label:
                active == 0
                    ? 'Filters'
                    : 'Filters ($active)',
            highlighted: _showFilters || active > 0,
            onTap:
                () => setState(
                  () => _showFilters = !_showFilters,
                ),
          ),
        ),
        if (_filters.hasAnything)
          ReportPill(
            theme: theme,
            icon: Icons.filter_alt_off,
            label: 'Reset All Filters',
            onTap: _resetAll,
            color: theme.lightModeColor.prColor300,
          ),
        Padding(
          padding: const EdgeInsets.only(left: 5),
          child: ReportExportButton(buildSpec: _exportSpec),
        ),
      ],
    );
  }

  /// What the Export button exports: the statistic cards and the
  /// tables, with the period, filters and notes on screen.
  ReportExportSpec _exportSpec() {
    return receiptsSummaryExportSpec(
      stats: _stats,
      customers: ReceiptsSummaryBuilder.sortGroups(
        _customers,
        field: _customerSort,
        ascending: _customerAscending,
      ),
      staff: _staff,
      subStaff: _subStaff,
      departments: _departments,
      channels: _channels,
      types: _types,
      filters: _filters,
      choices: _choices,
      period: _period,
      currency: currencySymbol(context: context),
      canSeeCost: _canSeeCost,
      departmentsEnabled: _departmentsEnabled,
      subStaffEnabled: _subStaffEnabled,
    );
  }

  Widget _filterPanel() {
    final theme = returnTheme(context, listen: false);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 5,
          ),
        ],
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 12,
        children: receiptsKeyFilterFields(
          theme: theme,
          filters: _filters,
          choices: _choices,
          departmentsEnabled: _departmentsEnabled,
          subStaffEnabled: _subStaffEnabled,
          onApply: _apply,
        ),
      ),
    );
  }

  Widget _notes() {
    // Shared with the export, so both always match.
    final notes = receiptsSummaryNotes(
      period: _period,
      stats: _stats,
      canSeeCost: _canSeeCost,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 2,
      children: [
        for (final n in notes)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Icon(
                  Icons.info_outline_rounded,
                  size: 13,
                  color: Colors.grey.shade600,
                ),
              ),
              Expanded(
                child: Text(
                  n,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  // ---------------------------------------------------------------
  // cards
  // ---------------------------------------------------------------

  Widget _card(
    ThemeProvider theme, {
    required String title,
    String? subtitle,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 2,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: theme.mobileTexts.b2.fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
            ],
          ),
          child,
        ],
      ),
    );
  }

  Widget _statCards(ThemeProvider theme) {
    final s = _stats;
    final width =
        widget.isDesktop
            ? 210.0
            : ((MediaQuery.of(context).size.width -
                        24 -
                        10) /
                    2)
                .clamp(130.0, 400.0);

    Widget stat(
      String label,
      String value, {
      String? sub,
      Color? color,
      IconData icon = Icons.receipt_long_rounded,
    }) {
      return Container(
        width: width,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 4,
          children: [
            Row(
              spacing: 6,
              children: [
                Icon(
                  icon,
                  size: 15,
                  color: theme.lightModeColor.prColor300,
                ),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: theme.mobileTexts.b1.fontSize,
                fontWeight: FontWeight.bold,
                color: color ?? Colors.black87,
              ),
            ),
            if (sub != null)
              Text(
                sub,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade600,
                ),
              ),
          ],
        ),
      );
    }

    String n(num v) => formatLargeNumberDouble(v);
    final unknown = s.typeCount(ReceiptType.unknown);

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        stat(
          'Total Receipts',
          n(s.totalReceipts),
          sub:
              unknown > 0
                  ? '$unknown of unknown type'
                  : null,
        ),
        stat(
          'Sales Receipts',
          n(s.typeCount(ReceiptType.sales)),
        ),
        stat(
          'Invoice Payments',
          n(s.typeCount(ReceiptType.invoicePayment)),
        ),
        stat(
          'Order Deliveries',
          n(s.typeCount(ReceiptType.orderDelivery)),
        ),
        stat(
          'Total Revenue',
          _money(s.totalRevenue),
          sub: 'All receipt types',
          icon: Icons.payments_rounded,
        ),
        if (_canSeeCost)
          stat(
            'Total Profit/Loss',
            _money(s.knownProfit),
            sub:
                'From ${s.profitKnownCount} of ${s.totalReceipts} '
                'receipts',
            color: _signColor(theme, s.knownProfit),
            icon: Icons.trending_up_rounded,
          ),
        stat(
          'Average Receipt Value',
          _money(s.averageReceiptValue),
          sub: 'Per Sales receipt',
          icon: Icons.functions_rounded,
        ),
        stat(
          'Total Discounts',
          _money(s.totalDiscount),
          sub: 'Sales receipts',
          icon: Icons.discount_rounded,
        ),
        stat(
          'Total VAT',
          _money(s.totalVat),
          sub: 'Sales receipts',
          icon: Icons.account_balance_rounded,
        ),
        stat(
          'Total Items Sold',
          n(s.totalItems),
          sub: 'Invoice payments not counted',
          icon: Icons.inventory_2_rounded,
        ),
        stat(
          'Total Customers',
          n(s.distinctCustomers),
          sub:
              s.walkInReceipts > 0
                  ? '+ ${s.walkInReceipts} walk-in receipts'
                  : null,
          icon: Icons.people_alt_rounded,
        ),
        stat(
          'Total Staff Involved',
          n(s.distinctStaff),
          sub:
              s.noStaffReceipts > 0
                  ? '+ ${s.noStaffReceipts} receipts without staff'
                  : null,
          icon: Icons.badge_rounded,
        ),
        for (final c in ReceiptChannel.values)
          stat(
            '${c.label} Transactions',
            n(s.channelCount(c)),
            icon: Icons.swap_horiz_rounded,
          ),
      ],
    );
  }

  // ---------------------------------------------------------------
  // charts
  // ---------------------------------------------------------------

  String _compact(double v) =>
      NumberFormat.compact().format(v);

  Widget _bottomTitle(double value, TitleMeta meta) {
    final i = value.round();
    if (i < 0 || i >= _trend.length || value != i) {
      return const SizedBox.shrink();
    }
    final step = math.max(1, (_trend.length / 6).ceil());
    if (i % step != 0) return const SizedBox.shrink();
    return SideTitleWidget(
      meta: meta,
      child: Text(
        _bucketLabel(_trend[i].start),
        style: const TextStyle(fontSize: 9),
      ),
    );
  }

  Widget _legend(List<(String, Color)> items) {
    return Wrap(
      spacing: 12,
      runSpacing: 4,
      children: [
        for (final (label, color) in items)
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 4,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                label,
                style: const TextStyle(fontSize: 10),
              ),
            ],
          ),
      ],
    );
  }

  Widget _trendCard(ThemeProvider theme) {
    final revenueColor = theme.lightModeColor.prColor300;
    final profitColor = Colors.green.shade600;
    final showProfit = _canSeeCost;
    double minY = 0;
    double maxY = 0;
    for (final p in _trend) {
      maxY = math.max(maxY, p.revenue);
      if (showProfit) {
        maxY = math.max(maxY, p.knownProfit);
        minY = math.min(minY, p.knownProfit);
      }
    }
    if (maxY == minY) maxY = minY + 1;

    LineChartBarData series(
      double Function(ReceiptsTrendPoint) value,
      Color color,
    ) {
      return LineChartBarData(
        spots: [
          for (var i = 0; i < _trend.length; i++)
            FlSpot(i.toDouble(), value(_trend[i])),
        ],
        color: color,
        barWidth: 2,
        isCurved: false,
        dotData: FlDotData(show: _trend.length <= 31),
      );
    }

    return _card(
      theme,
      title:
          showProfit
              ? 'Revenue and Profit Trend'
              : 'Revenue Trend',
      subtitle: '$_intervalLabel, by business day',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          _legend([
            ('Revenue', revenueColor),
            if (showProfit)
              ('Profit/Loss (known)', profitColor),
          ]),
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                minY: minY,
                maxY: maxY * 1.1,
                gridData: const FlGridData(
                  drawVerticalLine: false,
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(),
                  rightTitles: const AxisTitles(),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 44,
                      getTitlesWidget:
                          (value, meta) => SideTitleWidget(
                            meta: meta,
                            child: Text(
                              _compact(value),
                              style: const TextStyle(
                                fontSize: 9,
                              ),
                            ),
                          ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      interval: 1,
                      getTitlesWidget: _bottomTitle,
                    ),
                  ),
                ),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => Colors.white,
                    getTooltipItems:
                        (spots) =>
                            spots.map((s) {
                              final label =
                                  s.barIndex == 0
                                      ? 'Revenue'
                                      : 'Profit/Loss';
                              final when = _bucketLabel(
                                _trend[s.x.round()].start,
                              );
                              return LineTooltipItem(
                                '$when\n$label: ${_money(s.y)}',
                                TextStyle(
                                  fontSize: 10,
                                  color: s.bar.color,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              );
                            }).toList(),
                  ),
                ),
                lineBarsData: [
                  series((p) => p.revenue, revenueColor),
                  if (showProfit)
                    series(
                      (p) => p.knownProfit,
                      profitColor,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _activityCard(ThemeProvider theme) {
    double maxY = 1;
    for (final p in _trend) {
      maxY = math.max(maxY, p.receiptCount.toDouble());
    }
    final barWidth =
        _trend.length > 40
            ? 3.0
            : (_trend.length > 20 ? 6.0 : 10.0);

    BarChartGroupData group(int i) {
      final p = _trend[i];
      final parts = [
        (p.sales, _typeColor(ReceiptType.sales)),
        (
          p.invoicePayments,
          _typeColor(ReceiptType.invoicePayment),
        ),
        (
          p.orderDeliveries,
          _typeColor(ReceiptType.orderDelivery),
        ),
        (p.unknown, _typeColor(ReceiptType.unknown)),
      ];
      final stack = <BarChartRodStackItem>[];
      double from = 0;
      for (final (count, color) in parts) {
        if (count == 0) continue;
        stack.add(
          BarChartRodStackItem(from, from + count, color),
        );
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

    return _card(
      theme,
      title: 'Receipt Activity',
      subtitle: '$_intervalLabel receipt counts by type',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          _legend([
            for (final t in ReceiptType.values)
              if (t != ReceiptType.unknown ||
                  _stats.typeCount(t) > 0)
                (t.label, _typeColor(t)),
          ]),
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                maxY: maxY * 1.15,
                gridData: const FlGridData(
                  drawVerticalLine: false,
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(),
                  rightTitles: const AxisTitles(),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (value, meta) {
                        if (value !=
                            value.roundToDouble()) {
                          return const SizedBox.shrink();
                        }
                        return SideTitleWidget(
                          meta: meta,
                          child: Text(
                            value.toStringAsFixed(0),
                            style: const TextStyle(
                              fontSize: 9,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      getTitlesWidget: _bottomTitle,
                    ),
                  ),
                ),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => Colors.white,
                    getTooltipItem: (group, _, rod, _) {
                      final p = _trend[group.x];
                      return BarTooltipItem(
                        '${_bucketLabel(p.start)}\n'
                        'Sales: ${p.sales}\n'
                        'Invoice Payments: ${p.invoicePayments}\n'
                        'Order Deliveries: ${p.orderDeliveries}'
                        '${p.unknown > 0 ? '\nUnknown: ${p.unknown}' : ''}',
                        const TextStyle(
                          fontSize: 10,
                          color: Colors.black87,
                        ),
                      );
                    },
                  ),
                ),
                barGroups: [
                  for (var i = 0; i < _trend.length; i++)
                    group(i),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------
  // tables
  // ---------------------------------------------------------------

  Widget _cellText(
    String text, {
    bool bold = false,
    Color? color,
    bool alignStart = false,
  }) {
    return Text(
      text,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      textAlign:
          alignStart ? TextAlign.start : TextAlign.end,
      style: TextStyle(
        fontSize: 11,
        fontWeight:
            bold ? FontWeight.bold : FontWeight.w500,
        color: color ?? Colors.black87,
      ),
    );
  }

  /// Known profit, coloured, with a note when some receipts have
  /// no item data or a missing cost.
  Widget _profitCell(
    ThemeProvider theme,
    double profit,
    int unknown,
    int costMissing,
    int receipts,
  ) {
    final text = _cellText(
      _money(profit),
      bold: true,
      color: _signColor(theme, profit),
    );
    if (unknown == 0 && costMissing == 0) return text;
    return Tooltip(
      message:
          'From ${receipts - unknown} of $receipts receipts'
          '${costMissing > 0 ? '; $costMissing with a missing cost price' : ''}',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        spacing: 3,
        children: [
          Flexible(child: text),
          Icon(
            Icons.info_outline_rounded,
            size: 12,
            color: Colors.orange.shade800,
          ),
        ],
      ),
    );
  }

  Widget _table<T>(
    ThemeProvider theme, {
    required List<_SCol<T>> columns,
    required List<T> items,
    void Function(T item)? onTap,
    ReceiptsGroupSortField? sortField,
    bool ascending = false,
    void Function(ReceiptsGroupSortField field)? onSort,
  }) {
    final accent = theme.lightModeColor.prColor300;
    final total = columns.fold<double>(
      0,
      (s, c) => s + c.width,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale =
            total < constraints.maxWidth
                ? constraints.maxWidth / total
                : 1.0;
        Widget cellBox(_SCol<T> c, Widget child) =>
            SizedBox(
              width: c.width * scale,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                ),
                child: Align(
                  alignment:
                      c.alignStart
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                  child: child,
                ),
              ),
            );

        Widget header(_SCol<T> c) {
          final sorted =
              c.sort != null && c.sort == sortField;
          final label = Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 2,
            children: [
              Flexible(
                child: Text(
                  c.label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: sorted ? accent : Colors.black87,
                  ),
                ),
              ),
              if (c.sort != null && onSort != null)
                Icon(
                  sorted
                      ? (ascending
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded)
                      : Icons.unfold_more_rounded,
                  size: 12,
                  color: sorted ? accent : Colors.grey,
                ),
            ],
          );
          final box = cellBox(c, label);
          if (c.sort == null || onSort == null) return box;
          return InkWell(
            mouseCursor: SystemMouseCursors.click,
            onTap: () => onSort(c.sort!),
            child: box,
          );
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            children: [
              Container(
                height: 38,
                color: accent.withAlpha(22),
                child: Row(
                  children: [
                    for (final c in columns) header(c),
                  ],
                ),
              ),
              for (var i = 0; i < items.length; i++)
                Material(
                  color:
                      i.isEven
                          ? Colors.white
                          : Colors.grey.shade50,
                  child: InkWell(
                    mouseCursor:
                        onTap == null
                            ? MouseCursor.defer
                            : SystemMouseCursors.click,
                    hoverColor: accent.withAlpha(20),
                    onTap:
                        onTap == null
                            ? null
                            : () => onTap(items[i]),
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey.shade100,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          for (final c in columns)
                            cellBox(c, c.cell(items[i], i)),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _emptyTableText() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Text(
      'Nothing to show for this period.',
      style: TextStyle(
        fontSize: 11,
        color: Colors.grey.shade600,
      ),
    ),
  );

  List<_SCol<ReceiptsSummaryGroup>> _groupColumns(
    ThemeProvider theme, {
    required String nameLabel,
    bool average = true,
    bool share = false,
    bool lastDate = false,
    bool sortable = false,
  }) {
    return [
      _SCol(
        label: 'No.',
        width: 44,
        alignStart: true,
        cell:
            (g, i) =>
                _cellText('${i + 1}', alignStart: true),
      ),
      _SCol(
        label: nameLabel,
        width: 180,
        alignStart: true,
        cell:
            (g, i) => _cellText(
              g.label,
              bold: true,
              alignStart: true,
              color: g.isNone ? Colors.grey.shade700 : null,
            ),
      ),
      _SCol(
        label: 'Receipts',
        width: 80,
        sort:
            sortable
                ? ReceiptsGroupSortField.receiptCount
                : null,
        cell: (g, i) => _cellText('${g.receiptCount}'),
      ),
      _SCol(
        label: 'Total Revenue',
        width: 130,
        sort:
            sortable
                ? ReceiptsGroupSortField.revenue
                : null,
        cell:
            (g, i) =>
                _cellText(_money(g.revenue), bold: true),
      ),
      if (_canSeeCost)
        _SCol(
          label: 'Profit/Loss',
          width: 130,
          sort:
              sortable
                  ? ReceiptsGroupSortField.profit
                  : null,
          cell:
              (g, i) => _profitCell(
                theme,
                g.knownProfit,
                g.profitUnknownCount,
                g.costMissingCount,
                g.receiptCount,
              ),
        ),
      if (average)
        _SCol(
          label: 'Avg Receipt',
          width: 120,
          cell:
              (g, i) =>
                  g.salesCount == 0
                      ? _cellText('—', color: Colors.grey)
                      : _cellText(_money(g.average)),
        ),
      if (share)
        _SCol(
          label: '% of Revenue',
          width: 100,
          cell:
              (g, i) => _cellText(_percent(g.revenueShare)),
        ),
      if (lastDate)
        _SCol(
          label: 'Last Purchase',
          width: 120,
          sort:
              sortable
                  ? ReceiptsGroupSortField.lastDate
                  : null,
          cell:
              (g, i) => _cellText(
                g.lastDate == null
                    ? '—'
                    : formatDateTime(g.lastDate!),
              ),
        ),
    ];
  }

  Widget _rankingCard(
    ThemeProvider theme, {
    required String title,
    required List<ReceiptsSummaryGroup> groups,
    required String nameLabel,
    required bool showAverage,
    required void Function(ReceiptsSummaryGroup g) onTap,
  }) {
    return _card(
      theme,
      title: title,
      subtitle: 'By total revenue',
      child:
          groups.isEmpty
              ? _emptyTableText()
              : _table<ReceiptsSummaryGroup>(
                theme,
                columns: _groupColumns(
                  theme,
                  nameLabel: nameLabel,
                  average: showAverage,
                ),
                items: groups,
                onTap: onTap,
              ),
    );
  }

  Widget _departmentCard(ThemeProvider theme) {
    return _card(
      theme,
      title: 'Department Summary',
      subtitle: 'Tap a department to see its receipts',
      child:
          _departments.isEmpty
              ? _emptyTableText()
              : _table<ReceiptsSummaryGroup>(
                theme,
                columns: _groupColumns(
                  theme,
                  nameLabel: 'Department',
                  share: true,
                ),
                items: _departments,
                onTap:
                    (g) => _openTable(
                      ReceiptsSummaryBuilder.handoff(
                        _filters,
                        departmentKey: g.key,
                      ),
                    ),
              ),
    );
  }

  Widget _customerCard(ThemeProvider theme) {
    final sorted = ReceiptsSummaryBuilder.sortGroups(
      _customers,
      field: _customerSort,
      ascending: _customerAscending,
    );
    final shown =
        _showAllCustomers ||
                sorted.length <= _customerPreview
            ? sorted
            : sorted.take(_customerPreview).toList();
    return _card(
      theme,
      title: 'Customer Summary',
      subtitle:
          'Tap a customer to see their receipts. '
          'Walk-in receipts are under No Customer.',
      child:
          sorted.isEmpty
              ? _emptyTableText()
              : Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch,
                children: [
                  _table<ReceiptsSummaryGroup>(
                    theme,
                    columns: _groupColumns(
                      theme,
                      nameLabel: 'Customer',
                      lastDate: true,
                      sortable: true,
                    ),
                    items: shown,
                    sortField: _customerSort,
                    ascending: _customerAscending,
                    onSort:
                        (f) => setState(() {
                          if (_customerSort == f) {
                            _customerAscending =
                                !_customerAscending;
                          } else {
                            _customerSort = f;
                            _customerAscending = false;
                          }
                        }),
                    onTap:
                        (g) => _openTable(
                          ReceiptsSummaryBuilder.handoff(
                            _filters,
                            customerKey: g.key,
                          ),
                        ),
                  ),
                  if (sorted.length > _customerPreview)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed:
                            () => setState(
                              () =>
                                  _showAllCustomers =
                                      !_showAllCustomers,
                            ),
                        child: Text(
                          _showAllCustomers
                              ? 'Show fewer'
                              : 'Show all ${sorted.length}',
                        ),
                      ),
                    ),
                ],
              ),
    );
  }

  Widget _staffCard(ThemeProvider theme) {
    return _card(
      theme,
      title: 'Staff Summary',
      subtitle: 'Tap a staff member to see their receipts',
      child:
          _staff.isEmpty
              ? _emptyTableText()
              : _table<ReceiptsSummaryGroup>(
                theme,
                columns: _groupColumns(
                  theme,
                  nameLabel: 'Staff',
                  share: true,
                ),
                items: _staff,
                onTap:
                    (g) => _openTable(
                      ReceiptsSummaryBuilder.handoff(
                        _filters,
                        staffKey: g.key,
                      ),
                    ),
              ),
    );
  }

  Widget _subStaffCard(ThemeProvider theme) {
    return _card(
      theme,
      title: 'Sub-Staff Summary',
      subtitle:
          'Tap a sub-staff member to see their receipts',
      child:
          _subStaff.isEmpty
              ? _emptyTableText()
              : _table<ReceiptsSummaryGroup>(
                theme,
                columns: _groupColumns(
                  theme,
                  nameLabel: 'Sub-Staff',
                  average: false,
                ),
                items: _subStaff,
                onTap:
                    (g) => _openTable(
                      ReceiptsSummaryBuilder.handoff(
                        _filters,
                        subStaffKey: g.key,
                      ),
                    ),
              ),
    );
  }

  Widget _channelCard(ThemeProvider theme) {
    final s = _stats;
    return _card(
      theme,
      title: 'Payment Channel Summary',
      subtitle:
          'Each receipt counts once; Split = paid with 2 or more '
          'methods',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10,
        children: [
          _table<ReceiptsChannelSummary>(
            theme,
            columns: [
              _SCol(
                label: 'No.',
                width: 44,
                alignStart: true,
                cell:
                    (c, i) => _cellText(
                      '${i + 1}',
                      alignStart: true,
                    ),
              ),
              _SCol(
                label: 'Channel',
                width: 140,
                alignStart: true,
                cell:
                    (c, i) => _cellText(
                      c.channel.label,
                      bold: true,
                      alignStart: true,
                    ),
              ),
              _SCol(
                label: 'Receipts',
                width: 80,
                cell:
                    (c, i) =>
                        _cellText('${c.receiptCount}'),
              ),
              _SCol(
                label: 'Value',
                width: 130,
                cell:
                    (c, i) => _cellText(
                      _money(c.value),
                      bold: true,
                    ),
              ),
              _SCol(
                label: '% of Receipts',
                width: 100,
                cell:
                    (c, i) =>
                        _cellText(_percent(c.countShare)),
              ),
              _SCol(
                label: '% of Value',
                width: 100,
                cell:
                    (c, i) =>
                        _cellText(_percent(c.valueShare)),
              ),
            ],
            items: _channels,
            onTap:
                (c) => _openTable(
                  ReceiptsSummaryBuilder.handoff(
                    _filters,
                    channel: c.channel,
                  ),
                ),
          ),
          Text(
            'Collected by method: Cash ${_money(s.collectedCash)}'
            ' · Bank ${_money(s.collectedBank)}'
            ' · Customer Account ${_money(s.collectedAccount)}',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade800,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _typeCard(ThemeProvider theme) {
    return _card(
      theme,
      title: 'Transaction Type Summary',
      subtitle:
          'Invoice payments are payments received, not new sales',
      child: _table<ReceiptsTypeSummary>(
        theme,
        columns: [
          _SCol(
            label: 'No.',
            width: 44,
            alignStart: true,
            cell:
                (t, i) =>
                    _cellText('${i + 1}', alignStart: true),
          ),
          _SCol(
            label: 'Type',
            width: 150,
            alignStart: true,
            cell:
                (t, i) => _cellText(
                  t.type.label,
                  bold: true,
                  alignStart: true,
                  color: _typeColor(t.type),
                ),
          ),
          _SCol(
            label: 'Receipts',
            width: 80,
            cell: (t, i) => _cellText('${t.receiptCount}'),
          ),
          _SCol(
            label: 'Value',
            width: 130,
            cell:
                (t, i) =>
                    _cellText(_money(t.value), bold: true),
          ),
          if (_canSeeCost)
            _SCol(
              label: 'Profit/Loss',
              width: 130,
              cell:
                  (t, i) => _profitCell(
                    theme,
                    t.knownProfit,
                    t.receiptCount - t.profitKnownCount,
                    0,
                    t.receiptCount,
                  ),
            ),
        ],
        items: _types,
        onTap:
            (t) => _openTable(
              ReceiptsSummaryBuilder.handoff(
                _filters,
                type: t.type,
              ),
            ),
      ),
    );
  }
}
