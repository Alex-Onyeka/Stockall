import 'package:flutter/material.dart';
import 'package:stockall/classes/user_class/temp_user_class.dart';
import 'package:stockall/providers/theme_provider.dart';

class ExpenseStaffSelector extends StatelessWidget {
  final ThemeProvider theme;
  final List<TempUserClass> staffList;
  final TempUserClass? selectedStaff;
  final ValueChanged<TempUserClass> onSelected;

  const ExpenseStaffSelector({
    super.key,
    required this.theme,
    required this.staffList,
    required this.selectedStaff,
    required this.onSelected,
  });

  String _fullName(TempUserClass u) {
    final last = u.lastName?.trim() ?? '';
    return last.isEmpty ? u.name : '${u.name} $last';
  }

  String _subtitle(TempUserClass u) {
    final parts = <String>[
      if (u.role.trim().isNotEmpty) u.role.trim(),
      if (u.phone != null && u.phone!.trim().isNotEmpty) u.phone!.trim(),
    ];
    return parts.join(' • ');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 5,
      children: [
        Text(
          'Select Staff Member',
          style: theme.mobileTexts.b3.textStyleBold,
        ),
        PopupMenuButton<TempUserClass>(
          color: Colors.white,
          onSelected: onSelected,
          itemBuilder: (context) {
            if (staffList.isEmpty) {
              return [
                const PopupMenuItem<TempUserClass>(
                  enabled: false,
                  child: Text('No staff members available'),
                ),
              ];
            }
            return staffList.map((staff) {
              final isSelected = selectedStaff?.userId == staff.userId;
              final sub = _subtitle(staff);
              return PopupMenuItem<TempUserClass>(
                value: staff,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _fullName(staff),
                              style: TextStyle(
                                fontSize: theme.mobileTexts.b3.fontSize,
                                fontWeight:
                                    isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                              ),
                            ),
                            if (sub.isNotEmpty)
                              Text(
                                sub,
                                style: TextStyle(
                                  fontSize: theme.mobileTexts.b5.fontSize,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check,
                          size: 17,
                          color: Colors.grey.shade700,
                        ),
                    ],
                  ),
                ),
              );
            }).toList();
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(10, 10, 8, 10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedStaff != null
                            ? _fullName(selectedStaff!)
                            : 'Select Staff Member',
                        style: TextStyle(
                          fontSize: theme.mobileTexts.b3.fontSize,
                          fontWeight:
                              selectedStaff != null
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                          color:
                              selectedStaff != null
                                  ? Colors.black87
                                  : Colors.grey.shade500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (selectedStaff != null &&
                          _subtitle(selectedStaff!).isNotEmpty)
                        Text(
                          _subtitle(selectedStaff!),
                          style: TextStyle(
                            fontSize: theme.mobileTexts.b5.fontSize,
                            color: Colors.grey.shade600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
