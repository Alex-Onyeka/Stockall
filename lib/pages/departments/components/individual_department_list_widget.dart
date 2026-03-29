import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_departments_class/department_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/dialog_template.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/components/text_fields/general_textfield.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/departments/components/individual_department_price_box_widget.dart';

class IndividualDepartmentListWidget
    extends StatefulWidget {
  const IndividualDepartmentListWidget({
    super.key,
    required this.department,
  });

  final DepartmentClass department;

  @override
  State<IndividualDepartmentListWidget> createState() =>
      _IndividualDepartmentListWidgetState();
}

class _IndividualDepartmentListWidgetState
    extends State<IndividualDepartmentListWidget> {
  bool isOpen = false;

  void toggleIsOpen() {
    setState(() {
      isOpen = !isOpen;
    });
  }

  final nameController = TextEditingController();
  final descController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 15,
        ),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.grey.shade300),
            // bottom: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        child: Column(
          spacing: 5,
          children: [
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Row(
                    spacing: 10,
                    children: [
                      Icon(
                        size: 20,
                        color:
                            returnDepartmentProvider()
                                        .currentDepartment()
                                        ?.uuid ==
                                    widget.department.uuid
                                ? theme
                                    .lightModeColor
                                    .prColor250
                                : Colors.grey,
                        returnDepartmentProvider()
                                    .currentDepartment()
                                    ?.uuid ==
                                widget.department.uuid
                            ? Icons.width_normal_rounded
                            : Icons.width_normal_outlined,
                      ),
                      Flexible(
                        child: Text(
                          style: TextStyle(
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b2
                                    .fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                          widget.department.name
                              .toUpperCase(),
                        ),
                      ),
                      // Visibility(
                      //   visible:
                      //       widget.shop.isHeadQuarters ==
                      //       true,
                      //   child: Text(
                      //     style: TextStyle(
                      //       fontSize:
                      //           theme
                      //               .mobileTexts
                      //               .b4
                      //               .fontSize,
                      //       fontWeight: FontWeight.normal,
                      //       color:
                      //           theme
                      //               .lightModeColor
                      //               .secColor200,
                      //     ),
                      //     '( H.Q )',
                      //   ),
                      // ),
                    ],
                  ),
                ),
                Visibility(
                  visible:
                      returnDepartmentProvider()
                          .currentDepartment()
                          ?.uuid ==
                      widget.department.uuid,
                  child: Icon(
                    size: 20,
                    color: theme.lightModeColor.secColor200,
                    Icons.check,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Container(
              padding:
                  isOpen
                      ? (screenWidth(context) > mobileScreen
                          ? EdgeInsets.all(15)
                          : EdgeInsets.all(10))
                      : (screenWidth(context) > mobileScreen
                          ? EdgeInsets.fromLTRB(
                            15,
                            5,
                            15,
                            5,
                          )
                          : EdgeInsets.fromLTRB(
                            10,
                            5,
                            10,
                            5,
                          )),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: const Color.fromARGB(
                  255,
                  245,
                  245,
                  245,
                ),
              ),
              child: Column(
                spacing: 0,
                children: [
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        spacing: 0,
                        children: [
                          Text(
                            style: TextStyle(
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b4
                                      .fontSize,
                              fontWeight: FontWeight.normal,
                              color: Colors.grey,
                            ),
                            'Total Revenue:',
                          ),
                          Text(
                            style: TextStyle(
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b1
                                      .fontSize,
                              fontWeight: FontWeight.bold,
                            ),
                            formatMoneyMid(
                              amount:
                                  returnDepartmentsDashboardProvider(
                                    context: context,
                                  ).returnTotalRevenue(
                                    departmentClass:
                                        widget.department,
                                  ),
                              context: context,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () {
                          toggleIsOpen();
                        },
                        icon: Icon(
                          size: 22,
                          color: Colors.grey,
                          isOpen
                              ? Icons
                                  .keyboard_arrow_up_rounded
                              : Icons
                                  .keyboard_arrow_down_rounded,
                        ),
                      ),
                    ],
                  ),
                  Visibility(
                    visible: isOpen,
                    child: Column(
                      spacing: 10,
                      children: [
                        SizedBox(height: 10),
                        Row(
                          spacing: 10,
                          children: [
                            IndividualDepartmentPriceBoxWidget(
                              title: 'Total Expenses',
                              isMoney: true,
                              value:
                                  returnDepartmentsDashboardProvider(
                                    context: context,
                                  ).returnTotalExpenses(
                                    departmentClass:
                                        widget.department,
                                  ),
                            ),
                            IndividualDepartmentPriceBoxWidget(
                              title: 'Total Profit',
                              isMoney: true,
                              value:
                                  returnDepartmentsDashboardProvider(
                                    context: context,
                                  ).returnProfit(
                                    departmentClass:
                                        widget.department,
                                  ),
                            ),
                          ],
                        ),
                        Row(
                          spacing: 10,
                          children: [
                            IndividualDepartmentPriceBoxWidget(
                              title: 'Total Sales',
                              isMoney: false,
                              value:
                                  returnDepartmentsDashboardProvider(
                                        context: context,
                                      )
                                      .returnReceipts(
                                        department:
                                            widget
                                                .department,
                                      )
                                      .length
                                      .toDouble(),
                            ),
                            IndividualDepartmentPriceBoxWidget(
                              title: 'Total Invoice',
                              isMoney: false,
                              value:
                                  returnDepartmentsDashboardProvider(
                                        context: context,
                                      )
                                      .returnInvoices(
                                        department:
                                            widget
                                                .department,
                                      )
                                      .length
                                      .toDouble(),
                            ),
                          ],
                        ),
                        Row(
                          spacing: 10,
                          children: [
                            IndividualDepartmentPriceBoxWidget(
                              title: 'Total Staff',
                              isMoney: false,
                              value:
                                  returnDepartmentsDashboardProvider(
                                        context: context,
                                      )
                                      .returnStaffs(
                                        department:
                                            widget
                                                .department,
                                      )
                                      .length
                                      .toDouble(),
                            ),
                            IndividualDepartmentPriceBoxWidget(
                              title: 'Total Customer',
                              isMoney: false,
                              value:
                                  returnDepartmentsDashboardProvider(
                                        context: context,
                                      )
                                      .returnCustomers(
                                        department:
                                            widget
                                                .department,
                                      )
                                      .length
                                      .toDouble(),
                            ),
                          ],
                        ),
                        Row(
                          spacing: 10,
                          children: [
                            IndividualDepartmentPriceBoxWidget(
                              title: 'Total Items',
                              isMoney: false,
                              value:
                                  returnDepartmentsDashboardProvider(
                                    context: context,
                                  ).returnAllItems(
                                    department:
                                        widget.department,
                                  ),
                            ),
                            IndividualDepartmentPriceBoxWidget(
                              title: 'Total Items Value',
                              isMoney: true,
                              value:
                                  returnDepartmentsDashboardProvider(
                                    context: context,
                                  ).returnAllItemsValeu(
                                    department:
                                        widget.department,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: isOpen,
                    child: SizedBox(height: 10),
                  ),
                  Visibility(
                    visible:
                        screenWidth(context) > mobileScreen
                            ? true
                            : isOpen,
                    child: Row(
                      mainAxisAlignment:
                          screenWidth(context) >
                                  mobileScreen
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.center,
                      spacing:
                          screenWidth(context) >
                                  mobileScreen
                              ? 10
                              : 5,
                      children: [
                        Material(
                          color: Colors.transparent,
                          child: Ink(
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(3),
                              border: Border.all(
                                color: Colors.grey.shade200,
                              ),
                              color: Colors.white,
                            ),
                            child: InkWell(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (
                                    confirmContext,
                                  ) {
                                    return ConfirmationAlert(
                                      theme: theme,
                                      message:
                                          'You are about to Delete a Department. Are you sure you want to proceed?',
                                      title:
                                          'Delete Department?',
                                      action: () async {
                                        Navigator.of(
                                          confirmContext,
                                        ).pop();
                                        returnDepartmentsDashboardProvider()
                                            .toggleIsLoading(
                                              true,
                                            );
                                        var res = await returnDepartmentProvider()
                                            .deleteDepartment(
                                              department:
                                                  widget
                                                      .department,
                                            );
                                        if (res == 0) {
                                          returnDepartmentsDashboardProvider()
                                              .toggleIsLoading(
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
                                                    'An Error Occoured while Deleting This department. Please try again.',
                                                title:
                                                    'An Error Occoured',
                                              );
                                            },
                                          );
                                        } else {
                                          returnDepartmentsDashboardProvider()
                                              .toggleIsLoading(
                                                false,
                                              );
                                        }
                                      },
                                    );
                                  },
                                );
                              },
                              borderRadius:
                                  BorderRadius.circular(5),
                              child: Container(
                                padding:
                                    EdgeInsets.symmetric(
                                      vertical: 7,
                                      horizontal: 10,
                                    ),
                                child: Row(
                                  mainAxisSize:
                                      MainAxisSize.min,
                                  mainAxisAlignment:
                                      MainAxisAlignment
                                          .center,
                                  spacing: 3,
                                  children: [
                                    Text(
                                      style: TextStyle(
                                        fontSize:
                                            theme
                                                .mobileTexts
                                                .b4
                                                .fontSize,
                                        color:
                                            Colors
                                                .grey
                                                .shade800,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                      'Delete',
                                    ),
                                    Icon(
                                      size: 18,
                                      color: Colors.grey,
                                      Icons.delete_outlined,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Material(
                          color: Colors.transparent,
                          child: Ink(
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(3),
                              border: Border.all(
                                color: Colors.grey.shade200,
                              ),
                              color: Colors.white,
                            ),
                            child: InkWell(
                              onTap: () {
                                nameController.text =
                                    widget.department.name;
                                descController.text =
                                    widget
                                        .department
                                        .description ??
                                    '';
                                showDialog(
                                  context: context,
                                  builder: (deptContext) {
                                    return DialogTemplate(
                                      theme: theme,
                                      message:
                                          'Enter Department Name and Description to Update Department',
                                      title:
                                          'Update Department',
                                      action: () {
                                        if (nameController
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
                                                    'You are about to Update this Department. Are you sure you want to proceed?',
                                                title:
                                                    'Update New Department?',
                                                action: () async {
                                                  Navigator.of(
                                                    deptContext,
                                                  ).pop();
                                                  Navigator.of(
                                                    confirmContext,
                                                  ).pop();
                                                  returnDepartmentsDashboardProvider()
                                                      .toggleIsLoading(
                                                        true,
                                                      );
                                                  final department = DepartmentClass(
                                                    uuid:
                                                        widget.department.uuid,
                                                    createdAt:
                                                        widget.department.createdAt,
                                                    shopId:
                                                        widget.department.shopId,
                                                    name:
                                                        nameController.text.trim(),
                                                    description:
                                                        descController.text.trim(),
                                                    updatedAt:
                                                        DateTime.now(),
                                                  );
                                                  var res = await returnDepartmentProvider().updateDeparment(
                                                    department:
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
                                                              'An Error Occoured while Updating This department. Please try again.',
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
                                          'Update Department',
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
                                                  nameController,
                                              lines: 1,
                                              theme: theme,
                                            ),
                                            GeneralTextField(
                                              title:
                                                  'Description (Optional)',
                                              hint:
                                                  'Enter Description (Optional)',
                                              controller:
                                                  descController,
                                              lines: 1,
                                              theme: theme,
                                            ),
                                            Material(
                                              color:
                                                  Colors
                                                      .transparent,
                                              child: InkWell(
                                                onTap: () {
                                                  showDialog(
                                                    context:
                                                        context,
                                                    builder: (
                                                      context,
                                                    ) {
                                                      return StatefulBuilder(
                                                        builder:
                                                            (
                                                              context,
                                                              setState,
                                                            ) => DialogTemplate(
                                                              theme:
                                                                  theme,
                                                              message:
                                                                  'Staffs added to this department.',
                                                              title:
                                                                  'Department Staffs Staffs',
                                                              action:
                                                                  () {},
                                                              showBottomActionButtons:
                                                                  false,
                                                              topRightWidget: IconButton(
                                                                onPressed: () {
                                                                  Navigator.of(
                                                                    context,
                                                                  ).pop();
                                                                },
                                                                icon: Icon(
                                                                  size:
                                                                      20,
                                                                  Icons.clear,
                                                                ),
                                                              ),
                                                              widget: SizedBox(
                                                                height:
                                                                    screenHeight(
                                                                      context,
                                                                    ) -
                                                                    300,
                                                                child: Column(
                                                                  children: [
                                                                    Expanded(
                                                                      child: Builder(
                                                                        builder: (
                                                                          context,
                                                                        ) {
                                                                          if (returnUserProviderSingle().usersMain
                                                                              .where(
                                                                                (
                                                                                  user,
                                                                                ) =>
                                                                                    user.departmentUuids !=
                                                                                            null
                                                                                        ? user.departmentUuids!.contains(
                                                                                          widget.department.uuid,
                                                                                        )
                                                                                        : false,
                                                                              )
                                                                              .isEmpty) {
                                                                            return EmptyWidgetDisplayOnly(
                                                                              title:
                                                                                  'No Staff Added',
                                                                              subText:
                                                                                  'Please proceed to the Employee page to add staff to this department.',
                                                                              theme:
                                                                                  theme,
                                                                              height:
                                                                                  35,
                                                                              icon:
                                                                                  Icons.clear,
                                                                            );
                                                                          } else {
                                                                            return SingleChildScrollView(
                                                                              child: Padding(
                                                                                padding: const EdgeInsets.symmetric(
                                                                                  horizontal:
                                                                                      20.0,
                                                                                  vertical:
                                                                                      15,
                                                                                ),
                                                                                child: Column(
                                                                                  spacing:
                                                                                      5,
                                                                                  children:
                                                                                      returnUserProviderSingle().usersMain
                                                                                          .where(
                                                                                            (
                                                                                              user,
                                                                                            ) =>
                                                                                                user.departmentUuids !=
                                                                                                        null
                                                                                                    ? user.departmentUuids!.contains(
                                                                                                      widget.department.uuid,
                                                                                                    )
                                                                                                    : false,
                                                                                          )
                                                                                          .map(
                                                                                            (
                                                                                              user,
                                                                                            ) => Material(
                                                                                              color:
                                                                                                  Colors.transparent,
                                                                                              child: Padding(
                                                                                                padding: const EdgeInsets.symmetric(
                                                                                                  vertical:
                                                                                                      9.0,
                                                                                                  horizontal:
                                                                                                      12,
                                                                                                ),
                                                                                                child: Row(
                                                                                                  mainAxisAlignment:
                                                                                                      MainAxisAlignment.spaceBetween,
                                                                                                  children: [
                                                                                                    Text(
                                                                                                      style: TextStyle(
                                                                                                        fontSize:
                                                                                                            theme.mobileTexts.b3.fontSize,
                                                                                                        fontWeight:
                                                                                                            FontWeight.bold,
                                                                                                      ),
                                                                                                      user.name,
                                                                                                    ),
                                                                                                    Container(
                                                                                                      padding: EdgeInsets.all(
                                                                                                        2,
                                                                                                      ),
                                                                                                      decoration: BoxDecoration(
                                                                                                        shape:
                                                                                                            BoxShape.circle,
                                                                                                        border: Border.all(
                                                                                                          color:
                                                                                                              Colors.grey,
                                                                                                        ),
                                                                                                      ),
                                                                                                      child: Container(
                                                                                                        padding: EdgeInsets.all(
                                                                                                          5,
                                                                                                        ),
                                                                                                        decoration: BoxDecoration(
                                                                                                          shape:
                                                                                                              BoxShape.circle,
                                                                                                          color:
                                                                                                              user.departmentUuids !=
                                                                                                                          null &&
                                                                                                                      user.departmentUuids!.contains(
                                                                                                                        widget.department.uuid,
                                                                                                                      )
                                                                                                                  ? theme.lightModeColor.prColor250
                                                                                                                  : Colors.transparent,
                                                                                                        ),
                                                                                                      ),
                                                                                                    ),
                                                                                                  ],
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                          )
                                                                                          .toList(),
                                                                                ),
                                                                              ),
                                                                            );
                                                                          }
                                                                        },
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      height:
                                                                          10,
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            20.0,
                                                                      ),
                                                                      child: MainButtonP(
                                                                        themeProvider:
                                                                            theme,
                                                                        action: () {
                                                                          Navigator.of(
                                                                            context,
                                                                          ).pop();
                                                                        },
                                                                        text:
                                                                            'Cancel',
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                      );
                                                    },
                                                  ).then((
                                                    _,
                                                  ) {
                                                    // returnDepartmentsDashboardProvider()
                                                    //     .clearUsers();
                                                  });
                                                },
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                        20,
                                                        10,
                                                        20,
                                                        0,
                                                      ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.center,
                                                    spacing:
                                                        5,
                                                    children: [
                                                      Text(
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize:
                                                              theme.mobileTexts.b2.fontSize,
                                                        ),
                                                        'View Staff',
                                                      ),
                                                      Icon(
                                                        size:
                                                            18,
                                                        color:
                                                            Colors.grey.shade600,
                                                        Icons.people_outline,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ).then((_) {
                                  nameController.clear();
                                  descController.clear();
                                });
                              },
                              borderRadius:
                                  BorderRadius.circular(5),
                              child: Container(
                                padding:
                                    EdgeInsets.symmetric(
                                      vertical: 7,
                                      horizontal: 10,
                                    ),
                                child: Row(
                                  mainAxisSize:
                                      MainAxisSize.min,
                                  mainAxisAlignment:
                                      MainAxisAlignment
                                          .center,
                                  spacing: 5,
                                  children: [
                                    Text(
                                      style: TextStyle(
                                        fontSize:
                                            theme
                                                .mobileTexts
                                                .b4
                                                .fontSize,
                                        color:
                                            Colors
                                                .grey
                                                .shade800,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                      'Edit${screenWidth(context) > tabletScreenSmall ? ' Department' : ''}',
                                    ),
                                    Icon(
                                      size: 15,
                                      color: Colors.grey,
                                      Icons.edit,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Material(
                          color: Colors.transparent,
                          child: Ink(
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(3),
                              border: Border.all(
                                color: Colors.grey.shade200,
                              ),
                              color: Colors.white,
                            ),
                            child: InkWell(
                              onTap: () {
                                if (returnDepartmentProvider()
                                        .currentDepartment()
                                        ?.uuid ==
                                    widget
                                        .department
                                        .uuid) {
                                  returnDepartmentProvider()
                                      .selectDepartment();
                                } else {
                                  showDialog(
                                    context: context,
                                    builder: (
                                      confirmContext,
                                    ) {
                                      return ConfirmationAlert(
                                        theme: theme,
                                        message:
                                            'You are about to Select this Department as your current Department. Are you sure you want to proceed?',
                                        title:
                                            'Select Department',
                                        action: () async {
                                          await returnDepartmentProvider()
                                              .selectDepartment(
                                                departmentClass:
                                                    widget
                                                        .department,
                                              );
                                          if (confirmContext
                                              .mounted) {
                                            Navigator.of(
                                              confirmContext,
                                            ).pop();
                                          }
                                        },
                                      );
                                    },
                                  );
                                }
                              },
                              borderRadius:
                                  BorderRadius.circular(5),
                              child: Container(
                                padding:
                                    EdgeInsets.symmetric(
                                      vertical: 7,
                                      horizontal: 10,
                                    ),
                                child: Row(
                                  mainAxisSize:
                                      MainAxisSize.min,
                                  mainAxisAlignment:
                                      MainAxisAlignment
                                          .center,
                                  spacing: 5,
                                  children: [
                                    Text(
                                      style: TextStyle(
                                        fontSize:
                                            theme
                                                .mobileTexts
                                                .b4
                                                .fontSize,
                                        color:
                                            Colors
                                                .grey
                                                .shade800,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                      returnDepartmentProvider()
                                                  .currentDepartment()
                                                  ?.uuid ==
                                              widget
                                                  .department
                                                  .uuid
                                          ? 'Clear${screenWidth(context) > tabletScreenSmall ? ' Selection' : ''}'
                                          : 'Select${screenWidth(context) > tabletScreenSmall ? ' Department' : ''}',
                                    ),
                                    Icon(
                                      size: 15,
                                      color: Colors.grey,
                                      returnDepartmentProvider()
                                                  .currentDepartment()
                                                  ?.uuid ==
                                              widget
                                                  .department
                                                  .uuid
                                          ? Icons.clear
                                          : Icons.check,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
