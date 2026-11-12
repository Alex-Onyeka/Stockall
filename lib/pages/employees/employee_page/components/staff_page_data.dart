// Data of the staff details page: one staff's figures and records on
// today's business day, built with the Staff Report's own logic
// (StaffReportBase / StaffReportSlice / StaffAnalysis), so the page
// always agrees with the Staff Report on Today filtered to the staff.

import 'package:flutter/material.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/staff_report/staff_analysis/class/staff_analysis_export_spec.dart';
import 'package:stockall/pages/report/staff_report/staff_analysis/class/staff_analysis_logic.dart';
import 'package:stockall/pages/report/staff_report/staff_report_table/class/staff_report_table_logic.dart';
import 'package:stockall/pages/report/staff_report/staff_report_table/components/staff_report_table_view.dart';

/// One staff on today's business day.
class StaffPageData {
  /// `TempUserClass.userId`, the staff id every record carries.
  final String staffKey;

  /// Today's business day (the shop's closing time), as the Staff
  /// Report's "today".
  final ReceiptsReportPeriod period;

  /// Every record of the period, grouped by staff, in the viewer's
  /// scope.
  final StaffReportSlice slice;

  /// The card figures ([StaffAnalysis.summary], the staff's Staff
  /// Report row) and the latest records of each kind, under the
  /// report's gates.
  final StaffAnalysis analysis;

  /// False on another staff's page without View All Transaction
  /// Records: the scope leaves out their records, so every figure is
  /// 0. The page shows no figures, records or lists then.
  final bool canSeeRecords;

  const StaffPageData._({
    required this.staffKey,
    required this.period,
    required this.slice,
    required this.analysis,
    required this.canSeeRecords,
  });

  /// [now] and [closingTime] default to the clock and the shop's
  /// closing time, as in the app.
  factory StaffPageData.build({
    required StaffReportBase base,
    required String staffKey,
    DateTime? now,
    TimeOfDay? closingTime,
  }) {
    final period = ReceiptsReportPeriod.today(
      now: now,
      closingTime: closingTime,
    );
    final slice = StaffReportSlice.of(base, period, closingTime: closingTime);
    return StaffPageData._(
      staffKey: staffKey,
      period: period,
      slice: slice,
      analysis: StaffAnalysis.build(staffKey: staffKey, slice: slice),
      canSeeRecords: base.access.canSeeStaff(staffKey),
    );
  }

  StaffReportRow get summary => analysis.summary;
  bool get showOrders => analysis.showOrders;
  bool get showPurchases => analysis.showPurchases;
  bool get showExpenses => analysis.showExpenses;

  /// Whether [other] is this data's day.
  bool isPeriod(ReceiptsReportPeriod other) =>
      other.start == period.start && other.end == period.end;

  /// [analysis] with every record of today, not only the latest:
  /// a day's report prints the whole day. Hidden kinds stay empty.
  StaffAnalysis get printAnalysis => StaffAnalysis(
    summary: summary,
    recentReceipts: slice.receiptsOf(staffKey),
    recentInvoices: slice.invoicesOf(staffKey),
    recentOrders: showOrders ? slice.ordersOf(staffKey) : const [],
    recentPurchases: showPurchases ? slice.purchasesOf(staffKey) : const [],
    recentExpenses: showExpenses ? slice.expensesOf(staffKey) : const [],
    showOrders: showOrders,
    showPurchases: showPurchases,
    showExpenses: showExpenses,
  );

  /// The Print Report export: the Staff Analysis spec for this staff
  /// and today, which names the staff in its filters.
  ReportExportSpec printSpec({required String currency}) =>
      staffAnalysisExportSpec(
        analysis: printAnalysis,
        period: period,
        currency: currency,
      );
}

/// Loads and rebuilds [StaffPageData] the way the Staff Analysis page
/// does: [load] once (and on refresh), [sync] at the top of every
/// build.
class StaffPageController extends ChangeNotifier {
  final String staffKey;

  /// [StaffReportEnv.live] in the app; tests pass their own.
  final StaffReportEnv env;

  /// Null is the shop's closing time, as the Staff Report uses.
  final TimeOfDay? closingTime;

  final DateTime Function() _clock;

  StaffPageController({
    required this.staffKey,
    StaffReportEnv? env,
    DateTime Function()? clock,
    this.closingTime,
  }) : env = env ?? StaffReportEnv.live(),
       _clock = clock ?? DateTime.now;

  bool _loading = true;
  String? _error;
  StaffReportBase? _base;
  StaffPageData? _data;
  String _signature = '';
  bool _disposed = false;

  bool get loading => _loading;
  String? get error => _error;
  StaffPageData? get data => _data;

  /// Reads the data ([refreshFromStore] fetches it again first), then
  /// builds today's figures. Call it after the first frame.
  Future<void> load(
    BuildContext context, {
    bool refreshFromStore = false,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await env.load(context, refreshFromStore: refreshFromStore);
      if (_disposed || !context.mounted) return;
      _rebuild(context);
    } catch (e) {
      if (_disposed) return;
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  /// Call at the top of the page's build. Subscribes the page to the
  /// providers the figures read, then rebuilds the data when they
  /// changed or the business day has rolled over. Does not notify:
  /// the page is already building.
  void sync(BuildContext context) {
    env.listen(context);
    final base = _base;
    if (_loading || _error != null || base == null) return;
    try {
      if (env.signature(context) != _signature) {
        _rebuild(context);
      } else if (!(_data?.isPeriod(_today()) ?? false)) {
        _data = _build(base);
      }
    } catch (e) {
      _error = e.toString();
    }
  }

  ReceiptsReportPeriod _today() =>
      ReceiptsReportPeriod.today(now: _clock(), closingTime: closingTime);

  void _rebuild(BuildContext context) {
    final base = StaffReportBase.build(
      source: env.source(),
      access: env.access(context),
    );
    _base = base;
    _signature = env.signature(context);
    _data = _build(base);
  }

  StaffPageData _build(StaffReportBase base) => StaffPageData.build(
    base: base,
    staffKey: staffKey,
    now: _clock(),
    closingTime: closingTime,
  );

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
