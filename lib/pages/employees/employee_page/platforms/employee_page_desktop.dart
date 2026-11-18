import 'package:flutter/material.dart';
import 'package:stockall/pages/employees/employee_page/components/staff_page_env.dart';
import 'package:stockall/pages/employees/employee_page/components/staff_page_shell.dart';
import 'package:stockall/pages/employees/employee_page/components/staff_salary_history_section.dart';

/// Staff details, desktop: the details card beside today's summary
/// card, then today's sections two per row (the customer details
/// page's layout).
class EmployeePageDesktop extends StatefulWidget {
  final String employeeId;

  /// Null in the app: [StaffPageEnv.live] is used.
  final StaffPageEnv? env;

  const EmployeePageDesktop({
    super.key,
    required this.employeeId,
    this.env,
  });

  @override
  State<EmployeePageDesktop> createState() => _EmployeePageDesktopState();
}

class _EmployeePageDesktopState extends State<EmployeePageDesktop>
    with StaffPageStateMixin<EmployeePageDesktop> {
  @override
  String get staffId => widget.employeeId;

  @override
  StaffPageEnv? get injectedEnv => widget.env;

  @override
  bool get isDesktop => true;

  @override
  Widget build(BuildContext context) {
    return buildStaffPage(
      context,
      content: (user, data) {
        final summary = summaryCard(data);
        final note = ownRecordsNote(data);
        final list = sections(data);
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 7, child: detailsCard(user)),
                    if (summary != null) ...[
                      const SizedBox(width: 10),
                      Expanded(flex: 4, child: summary),
                    ],
                  ],
                ),
              ),
              if (note != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: note,
                ),
              for (var i = 0; i < list.length; i += 2)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: list[i]),
                      const SizedBox(width: 10),
                      Expanded(
                        child:
                            i + 1 < list.length
                                ? list[i + 1]
                                : const SizedBox(),
                      ),
                    ],
                  ),
                ),
              if (widget.env == null && data.canSeeRecords)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: StaffSalaryHistorySection(staffUuid: staffId),
                ),
            ],
          ),
        );
      },
    );
  }
}
