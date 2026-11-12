// Everything the staff page reads from the app or opens. The app uses
// StaffPageEnv.live(); tests pass their own, since the providers,
// permissions and pages need Hive, Supabase and a signed-in user.

import 'package:flutter/material.dart';
import 'package:stockall/classes/user_class/temp_user_class.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/employees/employee_page/components/staff_page_actions.dart';
import 'package:stockall/pages/invoices/invoice_list/invoice_list_page.dart';
import 'package:stockall/pages/orders/order_list/order_list_page.dart';
import 'package:stockall/pages/purchases/purchase_list/purchase_list.dart';
import 'package:stockall/pages/report/components/export/report_export_actions.dart';
import 'package:stockall/pages/report/components/export/report_export_backend.dart';
import 'package:stockall/pages/report/staff_report/staff_report_table/components/staff_report_table_view.dart';
import 'package:stockall/pages/sales/total_sales/total_sales_page.dart';

/// The full lists the Records menu opens, filtered to the staff.
enum StaffRecordsList { sales, invoices, orders, purchases, expenses }

class StaffPageEnv {
  /// Data, scope and gates, money, and the record and report-table
  /// hooks: the Staff Report's own, so the page matches it.
  final StaffReportEnv report;

  /// The staff, from the shop's staff list; null when not found.
  final TempUserClass? Function(String staffId) user;

  /// `authorization(authorized:)`.
  final bool Function(String authorization) can;

  /// The shop's Manage Departments setting.
  final bool Function() departmentsEnabled;

  /// Names of the departments [uuids], in the shop's order.
  final List<String> Function(List<String> uuids) departmentNames;

  /// The shop's currency symbol, for the print.
  final String Function(BuildContext context) currency;

  /// Opens a full list page filtered to [staffId]. Expenses has no
  /// such list: the page opens the Staff Expenses table instead.
  final Future<void> Function(
    BuildContext context,
    StaffRecordsList list,
    String staffId,
  )
  openList;

  /// The Edit (Select Action) flow. [onReturn] runs when Select New
  /// Role's page closes.
  final void Function(
    BuildContext context,
    TempUserClass user, {
    required bool isDesktop,
    required VoidCallback onReturn,
  })
  edit;

  /// The Delete flow; [onState] drives the page's overlays.
  final Future<void> Function(
    BuildContext context,
    String staffId, {
    required void Function({required bool loading, required bool success})
    onState,
  })
  delete;

  final ReportExportBackend exportBackend;

  /// Null in the app: the clock and the shop's closing time.
  final DateTime Function()? clock;
  final TimeOfDay? closingTime;

  const StaffPageEnv({
    required this.report,
    required this.user,
    required this.can,
    required this.departmentsEnabled,
    required this.departmentNames,
    required this.currency,
    required this.openList,
    required this.edit,
    required this.delete,
    this.exportBackend = const DefaultReportExportBackend(),
    this.clock,
    this.closingTime,
  });

  factory StaffPageEnv.live() {
    return StaffPageEnv(
      report: StaffReportEnv.live(),
      user: (staffId) {
        for (final u in returnUserProviderSingle().usersMain) {
          if (u.userId == staffId) return u;
        }
        return null;
      },
      can: (a) => authorization(authorized: a),
      departmentsEnabled:
          () => returnShopProvider().userShop()?.manageDepartments == true,
      departmentNames:
          (uuids) => [
            for (final d in returnDepartmentProvider().departments)
              if (uuids.contains(d.uuid)) d.name,
          ],
      currency: (context) => currencySymbol(context: context),
      openList: (context, list, staffId) {
        final Widget page;
        switch (list) {
          case StaffRecordsList.sales:
            page = TotalSalesPage(id: staffId);
          case StaffRecordsList.invoices:
            page = InvoiceListPage(agentUuid: staffId);
          case StaffRecordsList.orders:
            page = OrderListPage(agentUuid: staffId);
          case StaffRecordsList.purchases:
            page = PurchaseList(id: staffId);
          case StaffRecordsList.expenses:
            return Future.value();
        }
        return Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => page),
        );
      },
      edit:
          (context, user, {required isDesktop, required onReturn}) =>
              showStaffEditDialog(
                context: context,
                theme: returnTheme(context, listen: false),
                employee: user,
                isDesktop: isDesktop,
                onReturn: onReturn,
              ),
      delete:
          (context, staffId, {required onState}) => deleteStaffAction(
            context: context,
            theme: returnTheme(context, listen: false),
            employeeId: staffId,
            onState: onState,
          ),
    );
  }
}
