// The staff page's details card, in the customer page's Customer
// Details style, with the staff actions (Edit, Delete) in its header.

import 'package:flutter/material.dart';
import 'package:stockall/classes/user_class/temp_user_class.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/customers/customer_details_page/components/customer_details_section_widget.dart';
import 'package:stockall/pages/invoices/invoice_page/invoice_page_desktop.dart';
import 'package:stockall/pages/report/staff_report/staff_report_table/class/staff_report_table_logic.dart';

class StaffDetailsSectionWidget extends StatelessWidget {
  final TempUserClass staff;

  /// Department names; null hides the field (departments are off).
  final List<String>? departments;

  /// Null hides the button (no permission).
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  /// Disables the actions while the staff is being deleted.
  final bool busy;

  const StaffDetailsSectionWidget({
    super.key,
    required this.staff,
    required this.departments,
    required this.onEdit,
    required this.onDelete,
    this.busy = false,
  });

  static String _orNotSet(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Not Set' : v.trim();

  @override
  Widget build(BuildContext context) {
    final theme = returnTheme(context);
    Widget field(String title, String text, {int flex = 3}) => Expanded(
      flex: flex,
      child: CustomerDetailsColumnSection(
        theme: theme,
        title: title,
        text: text,
      ),
    );

    final depts = departments;
    return Container(
      key: const ValueKey('staff-details-card'),
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        boxShadow: const [
          BoxShadow(color: Color.fromARGB(26, 0, 0, 0), blurRadius: 10),
        ],
        color: Colors.white,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade100,
                ),
                child: const Icon(size: 16, Icons.badge_outlined),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b4.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                  'Staff Details'.toUpperCase(),
                ),
              ),
              if (onEdit != null)
                ActionButtonSmall(
                  key: const ValueKey('staff-edit'),
                  isLoading: busy,
                  action: busy ? null : onEdit,
                  text: 'Edit',
                  textColor: Colors.grey.shade500,
                  icon: Icon(size: 16, color: Colors.grey.shade500, Icons.edit),
                ),
              if (onDelete != null)
                ActionButtonSmall(
                  key: const ValueKey('staff-delete'),
                  isLoading: busy,
                  action: busy ? null : onDelete,
                  text: 'Delete',
                  textColor: Colors.red.shade300,
                  icon: Icon(
                    size: 16,
                    color: Colors.red.shade300,
                    Icons.delete,
                  ),
                ),
            ],
          ),
          Divider(color: Colors.grey.shade300, height: 25),
          Column(
            spacing: 15,
            children: [
              Row(
                spacing: 5,
                children: [
                  field('Name', StaffReportRow.nameOf(staff)),
                  field(
                    'Date Added',
                    staff.createdAt == null
                        ? 'Not Set'
                        : formatDateTime(staff.createdAt!),
                    flex: 2,
                  ),
                ],
              ),
              Row(
                spacing: 5,
                children: [
                  field('Email', _orNotSet(staff.email)),
                  field('Phone', _orNotSet(staff.phone), flex: 2),
                ],
              ),
              Row(
                spacing: 5,
                children: [
                  field('Role', _orNotSet(staff.role)),
                  if (depts != null)
                    field(
                      'Departments',
                      depts.isEmpty ? 'None' : depts.join(', '),
                      flex: 2,
                    )
                  else
                    const Spacer(flex: 2),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
