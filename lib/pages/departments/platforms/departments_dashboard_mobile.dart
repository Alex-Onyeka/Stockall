import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_departments_class/department_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/dialog_template.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/components/text_fields/general_textfield.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/date_picker_function.dart';
import 'package:stockall/constants/subscription/general_settings_auth.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/departments/components/dashboard_total_widget_dept.dart';
import 'package:stockall/pages/departments/components/individual_department_list_widget.dart';
import 'package:stockall/pages/departments/components/quick_action_buttons_dept.dart';

class DepartmentsDashboardMobile extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController descController;
  const DepartmentsDashboardMobile({
    super.key,
    required this.nameController,
    required this.descController,
  });

  @override
  State<DepartmentsDashboardMobile> createState() =>
      DepartmentsDashboardMobileState();
}

class DepartmentsDashboardMobileState
    extends State<DepartmentsDashboardMobile> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Scaffold(
      appBar: appBar(
        backAction: () => Navigator.of(context).pop(),
        context: context,
        title: 'Departments Dashboard',
      ),
      body: ListView(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              vertical: 0,
              horizontal: 20,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.white,
            ),
            child: Column(
              spacing: 10,
              children: [
                Row(
                  spacing: 5,
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Opacity(
                      opacity: 0,
                      child: IconButton(
                        onPressed: () {},
                        icon: Icon(size: 18, Icons.refresh),
                      ),
                    ),
                    Text(
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b1.fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                      'General Summary',
                    ),
                    Builder(
                      builder: (context) {
                        if (returnDepartmentsDashboardProvider(
                          context: context,
                        ).isLoading) {
                          return Padding(
                            padding: const EdgeInsets.all(
                              15,
                            ),
                            child: SizedBox(
                              height: 16,
                              width: 16,
                              child:
                                  CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color:
                                        theme
                                            .lightModeColor
                                            .secColor200,
                                  ),
                            ),
                          );
                        } else {
                          return IconButton(
                            onPressed: () {
                              returnDepartmentsDashboardProvider()
                                  .fetchAllData();
                            },
                            icon: Icon(
                              size: 18,
                              Icons.refresh,
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
                Container(
                  height: 2.5,
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: theme.lightModeColor.secColor200,
                  ),
                ),
                // SizedBox(height: 5),
                Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 13,
                        horizontal: 12,
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        spacing: 10,
                        children: [
                          Text(
                            style: TextStyle(
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b4
                                      .fontSize,
                              fontWeight: FontWeight.bold,
                            ),
                            'Quick Actions',
                          ),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            spacing: 10,
                            children: [
                              QuickActionButtonsDept(
                                icon: Icons.add,
                                action: () {
                                  GeneralSettingsAuthAction().numberOfDepartmentsAction(
                                    context: context,
                                    action: () {
                                      showDialog(
                                        context: context,
                                        builder: (
                                          deptContext,
                                        ) {
                                          return DialogTemplate(
                                            theme: theme,
                                            message:
                                                'Enter Department Name and Description to Create Department',
                                            title:
                                                'Create Department',
                                            action: () {
                                              if (widget
                                                  .nameController
                                                  .text
                                                  .isEmpty) {
                                                showDialog(
                                                  context:
                                                      context,
                                                  builder: (
                                                    context,
                                                  ) {
                                                    return InfoAlert(
                                                      theme:
                                                          theme,
                                                      message:
                                                          'Department name cannot be empty.',
                                                      title:
                                                          'Empty Department Name',
                                                    );
                                                  },
                                                );
                                              } else {
                                                showDialog(
                                                  context:
                                                      context,
                                                  builder: (
                                                    confirmContext,
                                                  ) {
                                                    return ConfirmationAlert(
                                                      theme:
                                                          theme,
                                                      message:
                                                          'You are about to create a new Department. Are you sure you want to proceed?',
                                                      title:
                                                          'Create New Department?',
                                                      action: () async {
                                                        Navigator.of(
                                                          deptContext,
                                                        ).pop();
                                                        Navigator.of(
                                                          confirmContext,
                                                        ).pop();
                                                        returnDepartmentsDashboardProvider().toggleIsLoading(
                                                          true,
                                                        );
                                                        final department = DepartmentClass(
                                                          uuid:
                                                              uuidGen(),
                                                          createdAt:
                                                              DateTime.now(),
                                                          shopId:
                                                              shopId(),
                                                          name:
                                                              widget.nameController.text.trim(),
                                                          description:
                                                              widget.descController.text.trim(),
                                                          updatedAt:
                                                              DateTime.now(),
                                                        );
                                                        var res = await returnDepartmentProvider().createDepartment(
                                                          department,
                                                        );
                                                        if (res ==
                                                            0) {
                                                          returnDepartmentsDashboardProvider().toggleIsLoading(
                                                            false,
                                                          );
                                                          showDialog(
                                                            // ignore: use_build_context_synchronously
                                                            context:
                                                                context,
                                                            builder: (
                                                              context,
                                                            ) {
                                                              return InfoAlert(
                                                                theme:
                                                                    theme,
                                                                message:
                                                                    'An Error Occoured while Creating This department. Please try again.',
                                                                title:
                                                                    'An Error Occoured',
                                                              );
                                                            },
                                                          );
                                                        } else {
                                                          returnDepartmentsDashboardProvider().toggleIsLoading(
                                                            false,
                                                          );
                                                        }
                                                      },
                                                    );
                                                  },
                                                );
                                              }
                                            },
                                            actionButtonText:
                                                'Create Department',
                                            widget: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal:
                                                        20.0,
                                                  ),
                                              child: Column(
                                                mainAxisSize:
                                                    MainAxisSize
                                                        .min,
                                                spacing: 10,
                                                children: [
                                                  GeneralTextField(
                                                    title:
                                                        'Name*',
                                                    hint:
                                                        'Enter Department Name',
                                                    controller:
                                                        widget.nameController,
                                                    lines:
                                                        1,
                                                    theme:
                                                        theme,
                                                  ),
                                                  GeneralTextField(
                                                    title:
                                                        'Description (Optional)',
                                                    hint:
                                                        'Enter Description (Optional)',
                                                    controller:
                                                        widget.descController,
                                                    lines:
                                                        1,
                                                    theme:
                                                        theme,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ).then((_) {
                                        widget
                                            .nameController
                                            .clear();
                                        widget
                                            .descController
                                            .clear();
                                      });
                                    },
                                  );
                                },
                                title: 'Create Department',
                              ),
                              QuickActionButtonsDept(
                                icon:
                                    returnDepartmentsDashboardProvider(
                                                  context:
                                                      context,
                                                ).dateSet !=
                                                null ||
                                            returnDepartmentsDashboardProvider(
                                                  context:
                                                      context,
                                                ).rangeStartDate !=
                                                null
                                        ? Icons.clear
                                        : Icons
                                            .calendar_month_outlined,
                                action: () {
                                  if (returnDepartmentsDashboardProvider()
                                              .dateSet !=
                                          null ||
                                      returnDepartmentsDashboardProvider()
                                              .rangeStartDate !=
                                          null) {
                                    returnDepartmentsDashboardProvider()
                                        .clearDate();
                                  } else {
                                    mainDatePicker(
                                      context: context,
                                      theme: theme,
                                      singleDate: (date) {
                                        returnDepartmentsDashboardProvider()
                                            .setDate(
                                              date ??
                                                  DateTime.now(),
                                            );
                                      },
                                      rangeDate: (
                                        firstDate,
                                        lastDate,
                                      ) {
                                        returnDepartmentsDashboardProvider()
                                            .setRange(
                                              firstDate!,
                                              lastDate ??
                                                  DateTime.now(),
                                            );
                                      },
                                    );
                                  }
                                },
                                title:
                                    returnDepartmentsDashboardProvider()
                                                    .dateSet !=
                                                null ||
                                            returnDepartmentsDashboardProvider()
                                                    .rangeStartDate !=
                                                null
                                        ? 'Clear'
                                        : 'Set Date',
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              QuickActionButtonsDept(
                                icon:
                                    Icons.checklist_rounded,
                                action: () {
                                  returnDepartmentProvider()
                                      .selectDepartment(
                                        context: context,
                                      );
                                },
                                title:
                                    'View All Deparments',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 1),
                    Row(
                      children: [
                        Expanded(
                          child: DashboardTotalWidgetDept(
                            gradient:
                                theme
                                    .lightModeColor
                                    .prGradient,
                            title: 'Total Revenue',
                            isMoney: true,
                            value:
                                returnDepartmentsDashboardProvider(
                                  context: context,
                                ).returnTotalRevenue(),
                            fontSize:
                                theme
                                    .mobileTexts
                                    .h2
                                    .fontSize,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      spacing: 10,
                      children: [
                        Expanded(
                          child: DashboardTotalWidgetDept(
                            title: 'Total Expenses',
                            isMoney: true,
                            value:
                                returnDepartmentsDashboardProvider(
                                  context: context,
                                ).returnTotalExpenses(),
                          ),
                        ),
                        Expanded(
                          child: DashboardTotalWidgetDept(
                            title: 'Total Profit',
                            isMoney: true,
                            value:
                                returnDepartmentsDashboardProvider(
                                  context: context,
                                ).returnProfit(),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      spacing: 10,
                      children: [
                        Expanded(
                          child: DashboardTotalWidgetDept(
                            title: 'Total Sales',
                            isMoney: false,
                            value:
                                returnDepartmentsDashboardProvider(
                                      context: context,
                                    )
                                    .returnReceipts()
                                    .length
                                    .toDouble(),
                          ),
                        ),
                        Expanded(
                          child: DashboardTotalWidgetDept(
                            title: 'Total Invoices',
                            isMoney: false,
                            value:
                                returnDepartmentsDashboardProvider(
                                      context: context,
                                    )
                                    .returnInvoices()
                                    .length
                                    .toDouble(),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      spacing: 10,
                      children: [
                        Expanded(
                          child: DashboardTotalWidgetDept(
                            title: 'Total Staffs',
                            isMoney: false,
                            value:
                                returnDepartmentsDashboardProvider(
                                      context: context,
                                    ).allStaffs.length
                                    .toDouble(),
                          ),
                        ),
                        Expanded(
                          child: DashboardTotalWidgetDept(
                            title: 'Total Customers',
                            isMoney: false,
                            value:
                                returnDepartmentsDashboardProvider(
                                      context: context,
                                    ).allCustomers.length
                                    .toDouble(),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      spacing: 10,
                      children: [
                        Expanded(
                          child: DashboardTotalWidgetDept(
                            title: 'Total Items in Stock',
                            isMoney: false,
                            value:
                                returnDepartmentsDashboardProvider(
                                  context: context,
                                ).returnAllItems(),
                          ),
                        ),
                        Expanded(
                          child: DashboardTotalWidgetDept(
                            title: 'Total Items Value',
                            isMoney: true,
                            value:
                                returnDepartmentsDashboardProvider(
                                  context: context,
                                ).returnAllItemsValeu(),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              vertical: 20,
              horizontal: 15,
            ),
            child: Column(
              spacing: 10,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  spacing: 5,
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Text(
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b1.fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                      'Department List',
                    ),
                  ],
                ),
                Container(
                  height: 2.5,
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: theme.lightModeColor.secColor200,
                  ),
                ),
                SizedBox(height: 5),
                Builder(
                  builder: (context) {
                    if (returnDepartmentProvider(
                      context: context,
                    ).departments.isNotEmpty) {
                      return Column(
                        children:
                            returnDepartmentProvider(
                                  context: context,
                                ).departments
                                .map(
                                  (department) =>
                                      IndividualDepartmentListWidget(
                                        department:
                                            department,
                                      ),
                                )
                                .toList(),
                      );
                    } else {
                      return SizedBox(
                        height: 350,
                        child: Center(
                          child: EmptyWidgetDisplayOnly(
                            title: 'No Departments Found',
                            subText:
                                'You have not created any departments. Please proceed to create a department',
                            theme: theme,
                            height: 35,
                            altAction: () {
                              returnDepartmentsDashboardProvider()
                                  .fetchAllData();
                            },
                            altActionText: 'Refresh Data',
                            icon: Icons.clear,
                          ),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
