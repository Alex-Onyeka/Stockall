import 'package:flutter/material.dart';
import 'package:stockall/pages/employees/employee_page/components/staff_page_env.dart';
import 'package:stockall/pages/employees/employee_page/components/staff_page_shell.dart';
import 'package:stockall/pages/employees/employee_page/components/staff_salary_history_section.dart';

/// Staff details, mobile: today's summary card, the details card,
/// then today's sections, stacked (the customer details page's
/// layout).
class EmployeePageMobile extends StatefulWidget {
  final String employeeId;

  /// Null in the app: [StaffPageEnv.live] is used.
  final StaffPageEnv? env;

  const EmployeePageMobile({
    super.key,
    required this.employeeId,
    this.env,
  });

  @override
  State<EmployeePageMobile> createState() => _EmployeePageMobileState();
}

class _EmployeePageMobileState extends State<EmployeePageMobile>
    with StaffPageStateMixin<EmployeePageMobile> {
  @override
  String get staffId => widget.employeeId;

  @override
  StaffPageEnv? get injectedEnv => widget.env;

  @override
  bool get isDesktop => false;

  @override
  Widget build(BuildContext context) {
    return buildStaffPage(
      context,
      content: (user, data) {
        final summary = summaryCard(data);
        final note = ownRecordsNote(data);
        return ListView(
          padding: const EdgeInsets.fromLTRB(15, 0, 15, 30),
          children: [
            if (summary != null) summary,
            detailsCard(user),
            if (note != null) note,
            ...sections(data),
            if (widget.env == null && data.canSeeRecords)
              StaffSalaryHistorySection(staffUuid: staffId),
          ],
        );
      },
    );
  }
}
