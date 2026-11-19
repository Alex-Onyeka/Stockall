// What the staff page's desktop and mobile layouts share: the data
// (StaffPageController), the staff lookup, the Edit / Delete wiring and
// overlays, the header with the Records menu, and the loading, error
// and "own records only" states. Each layout only arranges the cards.

import 'package:flutter/material.dart';
import 'package:stockall/classes/user_class/temp_user_class.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/employees/employee_page/components/staff_details_section_widget.dart';
import 'package:stockall/pages/employees/employee_page/components/staff_page_data.dart';
import 'package:stockall/pages/employees/employee_page/components/staff_page_env.dart';
import 'package:stockall/pages/employees/employee_page/components/staff_records_menu.dart';
import 'package:stockall/pages/employees/employee_page/components/staff_today_section.dart';
import 'package:stockall/pages/employees/employee_page/components/staff_today_summary_card.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/providers/theme_provider.dart';

const String staffOwnRecordsNote = 'You can only view your own records.';

mixin StaffPageStateMixin<T extends StatefulWidget> on State<T> {
  /// `TempUserClass.userId` of the staff shown.
  String get staffId;

  /// Null in the app: [StaffPageEnv.live] is used.
  StaffPageEnv? get injectedEnv;

  bool get isDesktop;

  late final StaffPageEnv env;
  late final StaffPageController controller;

  // The Delete flow's overlays.
  bool isLoading = false;
  bool showSuccess = false;
  bool _popped = false;

  @override
  void initState() {
    super.initState();
    env = injectedEnv ?? StaffPageEnv.live();
    controller = StaffPageController(
      staffKey: staffId,
      env: env.report,
      clock: env.clock,
      closingTime: env.closingTime,
    );
    controller.addListener(_changed);
    WidgetsBinding.instance.addPostFrameCallback((_) => load());
  }

  @override
  void dispose() {
    controller.removeListener(_changed);
    controller.dispose();
    super.dispose();
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  Future<void> load({bool refreshFromStore = false}) async {
    if (_popped) return;
    await controller.load(context, refreshFromStore: refreshFromStore);
    if (mounted) _popIfMissing();
  }

  /// `Authorizations().employeePage`: the Staffs list and every
  /// staff's page. Without it the viewer only has their own page.
  bool get canManageStaff => env.can(Authorizations().employeePage);

  /// Another staff's page without [canManageStaff]: not shown.
  bool _isBlocked(BuildContext context) =>
      !canManageStaff &&
      staffId != env.report.access(context).currentUserId;

  void _closeBlocked() {
    if (_popped) return;
    _popped = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.of(context).pop();
    });
  }

  /// As before: a staff no longer in the shop's list closes the page.
  void _popIfMissing() {
    if (_popped || isLoading || showSuccess) return;
    if (env.user(staffId) == null) {
      _popped = true;
      Navigator.of(context).pop();
    }
  }

  // ---------------------------------------------------------------
  // parts the layouts arrange
  // ---------------------------------------------------------------

  Widget detailsCard(TempUserClass user) {
    final busy = isLoading || showSuccess;
    return StaffDetailsSectionWidget(
      staff: user,
      busy: busy,
      departments:
          env.departmentsEnabled()
              ? env.departmentNames(user.departmentUuids ?? const [])
              : null,
      onEdit:
          canManageStaff && env.can(Authorizations().updateEmployee)
              ? () => env.edit(
                context,
                user,
                isDesktop: isDesktop,
                onReturn: () {
                  if (!mounted) return;
                  setState(() {});
                  _popIfMissing();
                },
              )
              : null,
      onDelete:
          canManageStaff && env.can(Authorizations().deleteEmployee)
              ? () => env.delete(
                context,
                staffId,
                onState: ({required loading, required success}) {
                  if (!mounted) return;
                  setState(() {
                    isLoading = loading;
                    showSuccess = success;
                  });
                },
              )
              : null,
    );
  }

  /// Null without the right to see this staff's records.
  Widget? summaryCard(StaffPageData data) {
    if (!data.canSeeRecords) return null;
    return StaffTodaySummaryCard(
      data: data,
      money: (v) => env.report.money(context, v),
      currency: env.currency(context),
      exportBackend: env.exportBackend,
    );
  }

  /// Empty without the right to see this staff's records.
  List<Widget> sections(StaffPageData data) {
    if (!data.canSeeRecords) return const [];
    return staffTodaySections(
      context: context,
      data: data,
      report: env.report,
    );
  }

  /// Null when the records are shown.
  Widget? ownRecordsNote(StaffPageData data) {
    if (data.canSeeRecords) return null;
    final theme = returnTheme(context);
    return Container(
      key: const ValueKey('staff-own-records-note'),
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Colors.grey.shade100,
      ),
      child: Row(
        spacing: 8,
        children: [
          Icon(size: 18, color: Colors.grey.shade600, Icons.lock_outline),
          Expanded(
            child: Text(
              style: TextStyle(
                fontSize: theme.mobileTexts.b3.fontSize,
                color: Colors.grey.shade700,
              ),
              staffOwnRecordsNote,
            ),
          ),
        ],
      ),
    );
  }

  void _openList(StaffRecordsList list) {
    if (list == StaffRecordsList.expenses) {
      // No expenses list takes a staff: the Staff Expenses table, on
      // All time (today without the View Date permission).
      env.report.openExpensesTable(
        context,
        staffId,
        const ReceiptsReportPeriod.allTime(),
      );
    } else {
      env.openList(context, list, staffId);
    }
  }

  // ---------------------------------------------------------------
  // the page
  // ---------------------------------------------------------------

  /// The page around [content], which gets the staff and today's
  /// data once both are ready.
  Widget buildStaffPage(
    BuildContext context, {
    required Widget Function(TempUserClass user, StaffPageData data) content,
  }) {
    if (_isBlocked(context)) {
      _closeBlocked();
      return const Scaffold(key: ValueKey('staff-page-blocked'));
    }
    // Subscribes to the providers and rebuilds the figures when the
    // data or the business day changed.
    controller.sync(context);
    final theme = returnTheme(context);
    final data = controller.data;
    final user = env.user(staffId);

    Widget body;
    if (controller.loading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (controller.error != null || data == null) {
      body = Center(
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
              style: TextStyle(
                fontSize: theme.mobileTexts.b2.fontSize,
                fontWeight: FontWeight.bold,
              ),
              'The staff details could not be loaded.',
            ),
            OutlinedButton.icon(
              onPressed: () => load(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
            ),
          ],
        ),
      );
    } else if (user == null) {
      body = const Center(child: CircularProgressIndicator());
    } else {
      body = content(user, data);
    }

    final page = Scaffold(
      backgroundColor: const Color.fromARGB(255, 253, 254, 255),
      body: Column(
        children: [
          _header(theme, data),
          Expanded(child: body),
        ],
      ),
    );

    return Stack(
      children: [
        isDesktop ? page : SafeArea(child: page),
        if (isLoading)
          returnCompProvider(context, listen: false).showLoader(
            message: 'Loading',
          ),
        if (showSuccess)
          returnCompProvider(
            context,
            listen: false,
          ).showSuccess('Deleted Successfully'),
      ],
    );
  }

  Widget _header(ThemeProvider theme, StaffPageData? data) {
    final showMenu =
        !controller.loading && data != null && data.canSeeRecords;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 30 : 15,
        vertical: isDesktop ? 20 : 15,
      ),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Material(
            type: MaterialType.transparency,
            child: InkWell(
              key: const ValueKey('staff-back'),
              mouseCursor: SystemMouseCursors.click,
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(30),
              child: Container(
                padding: EdgeInsets.all(isDesktop ? 15 : 10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade200, width: 1),
                ),
                child: Icon(
                  size: isDesktop ? 18 : 16,
                  color: Colors.grey.shade700,
                  Icons.arrow_back_ios_new_outlined,
                ),
              ),
            ),
          ),
          SizedBox(width: isDesktop ? 10 : 6),
          Expanded(
            child: Text(
              style: TextStyle(
                fontSize:
                    isDesktop
                        ? theme.mobileTexts.b2.fontSize
                        : theme.mobileTexts.b3.fontSize,
                fontWeight: isDesktop ? FontWeight.bold : FontWeight.normal,
              ),
              'Staff Details',
            ),
          ),
          if (showMenu)
            StaffRecordsMenu(
              showOrders: data.showOrders,
              showPurchases: data.showPurchases,
              showExpenses: data.showExpenses,
              onSelected: _openList,
            ),
        ],
      ),
    );
  }
}
