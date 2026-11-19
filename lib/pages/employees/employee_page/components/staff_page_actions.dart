// The staff page's Edit and Delete flows, moved out of
// employee_page_desktop.dart / employee_page_mobile.dart unchanged.
// The few differences between the two copies stay behind isDesktop.

import 'package:flutter/material.dart';
import 'package:stockall/classes/user_class/temp_user_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/dialog_template.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/components/buttons/main_button_transparent.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/employees/add_employee_page/add_employee_page.dart';
import 'package:stockall/pages/employees/customize_role/customize_role_page.dart';
import 'package:stockall/providers/theme_provider.dart';

/// The Select Action dialog: Customize Access, Manage Staff
/// Departments and Select New Role. [onReturn] runs after Select New
/// Role's page closes, so the page can read the staff again.
void showStaffEditDialog({
  required BuildContext context,
  required ThemeProvider theme,
  required TempUserClass employee,
  required bool isDesktop,
  required VoidCallback onReturn,
}) {
  showDialog(
    context: context,
    builder: (editDialoge) {
      return DialogTemplate(
        theme: theme,
        message: 'Select the action you want to perform.',
        title: 'Select Action',
        action: () {},
        showBottomActionButtons: false,
        topRightWidget: IconButton(
          mouseCursor: SystemMouseCursors.click,
          onPressed: () {
            Navigator.of(editDialoge).pop();
          },
          icon: Icon(Icons.clear),
        ),
        widget: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 10,
          children: [
            SizedBox(height: 10),
            Visibility(
              visible: employee.userId != currentUser().userId,
              child: MainButtonP(
                themeProvider: theme,
                action: () {
                  Navigator.of(editDialoge).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return CustomizeRolePage(user: employee);
                      },
                    ),
                  );
                },
                text: 'Customize Access',
              ),
            ),
            Visibility(
              visible:
                  returnShopProvider().userShop()?.manageDepartments ==
                      true &&
                  employee.userId != currentUser().userId,
              child: MainButtonTransparent(
                themeProvider: theme,
                constraints: BoxConstraints(),
                text: 'Manage Staff Departments',
                action: () {
                  _manageDepartments(
                    context: context,
                    theme: theme,
                    employee: employee,
                    isDesktop: isDesktop,
                  );
                },
              ),
            ),
            MainButtonTransparent(
              themeProvider: theme,
              constraints: BoxConstraints(),
              text: 'Select New Role',
              action: () {
                Navigator.of(editDialoge).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return AddEmployeePage(employee: employee);
                    },
                  ),
                ).then((_) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    onReturn();
                  });
                });
              },
            ),
          ],
        ),
      );
    },
  );
}

void _manageDepartments({
  required BuildContext context,
  required ThemeProvider theme,
  required TempUserClass employee,
  required bool isDesktop,
}) {
  List<String> list = [];
  list.addAll(employee.departmentUuids ?? []);
  showDialog(
    context: context,
    builder: (firstContext) {
      return StatefulBuilder(
        builder: (secondContext, setState) {
          return DialogTemplate(
            theme: theme,
            message: 'Select Department for this Staff',
            title:
                isDesktop ? 'Select Department(s)' : 'Select Department',
            topRightWidget:
                returnDepartmentsDashboardProvider().isLoading
                    ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: theme.lightModeColor.secColor200,
                        strokeWidth: 2.5,
                      ),
                    )
                    : null,
            action: () {
              if (!returnDepartmentsDashboardProvider().isLoading) {
                showDialog(
                  context: context,
                  builder: (confirmContext) {
                    return ConfirmationAlert(
                      theme: theme,
                      message:
                          'You are about to update this users Department(s). Are you sure you want to proceed?',
                      title: 'Update Departments',
                      action: () async {
                        Navigator.of(confirmContext).pop();
                        returnDepartmentsDashboardProvider()
                            .toggleIsLoading(true);
                        setState(() {});
                        final res = await returnUserProviderSingle()
                            .updateStaffDepartments(
                              user: employee,
                              newDepartments: list,
                            );
                        returnDepartmentsDashboardProvider()
                            .toggleIsLoading(false);
                        if (res == 1) {
                          if (secondContext.mounted) {
                            Navigator.of(secondContext).pop();
                          }
                          if (firstContext.mounted) {
                            Navigator.of(firstContext).pop();
                          }
                        } else {
                          setState(() {});
                        }
                      },
                    );
                  },
                );
              }
            },
            widget: SizedBox(
              height: screenHeight(context) - (isDesktop ? 300 : 370),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 15,
                  ),
                  child: Column(
                    spacing: 5,
                    children:
                        returnDepartmentProvider().departments
                            .map(
                              (dept) => Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  mouseCursor: SystemMouseCursors.click,
                                  onTap: () {
                                    setState(() {
                                      if (list.contains(dept.uuid)) {
                                        list.remove(dept.uuid);
                                      } else {
                                        list.add(dept.uuid);
                                      }
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 9.0,
                                      horizontal: 12,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          style: TextStyle(
                                            fontSize:
                                                theme.mobileTexts.b3.fontSize,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          dept.name,
                                        ),
                                        Container(
                                          padding: EdgeInsets.all(2),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.grey,
                                            ),
                                          ),
                                          child: Container(
                                            padding: EdgeInsets.all(5),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color:
                                                  list.contains(dept.uuid)
                                                      ? theme
                                                          .lightModeColor
                                                          .prColor250
                                                      : Colors.transparent,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  ).then((_) {
    returnDepartmentsDashboardProvider().toggleIsLoading(false);
  });
}

/// Removes the staff from the shop: online only, after a
/// confirmation. [onState] drives the page's loading and success
/// overlays; the page closes 2 seconds after success.
Future<void> deleteStaffAction({
  required BuildContext context,
  required ThemeProvider theme,
  required String employeeId,
  required void Function({required bool loading, required bool success})
  onState,
}) async {
  var isOnline = returnConnectivityProvider().isConnected;
  if (!isOnline) {
    showDialog(
      // ignore: use_build_context_synchronously
      context: context,
      builder: (context) {
        return InfoAlert(
          theme: returnTheme(context, listen: false),
          message:
              'Internet connection is not detected, therefore, You cannot delete a Staff.',
          title: 'No Internet Connection',
        );
      },
    );
    return;
  }
  final safeContext = context;
  final shopProvider = returnShopProvider();
  showDialog(
    context: safeContext,
    builder: (confirmDialg) {
      return ConfirmationAlert(
        theme: theme,
        message:
            'You are about to delete your staff, are you sure you want to proceed?',
        title: 'Are you sure?',
        action: () async {
          if (confirmDialg.mounted) {
            Navigator.of(confirmDialg).pop();
          }
          onState(loading: true, success: false);

          await shopProvider.removeEmployeeFromShop(
            context: safeContext,
            employeeIdToRemove: employeeId,
          );
          onState(loading: false, success: true);

          await Future.delayed(Duration(seconds: 2));

          if (safeContext.mounted) {
            Navigator.of(safeContext).pop();
          }
        },
      );
    },
  );
}
