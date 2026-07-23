import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stockall/classes/user_class/temp_user_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/dialog_template.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/components/buttons/main_button_transparent.dart';
import 'package:stockall/components/major/top_banner.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/employees/add_employee_page/add_employee_page.dart';
import 'package:stockall/pages/employees/customize_role/customize_role_page.dart';
import 'package:stockall/pages/sales/total_sales/total_sales_page.dart';
import 'package:stockall/providers/comp_provider.dart';
import 'package:stockall/providers/theme_provider.dart';

class EmployeePageMobile extends StatefulWidget {
  final String employeeId;
  const EmployeePageMobile({
    super.key,
    required this.employeeId,
  });

  @override
  State<EmployeePageMobile> createState() =>
      _EmployeePageMobileState();
}

class _EmployeePageMobileState
    extends State<EmployeePageMobile> {
  @override
  void initState() {
    super.initState();

    returnData().toggleFloatingAction(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      List<TempUserClass> employees =
          returnUserProviderSingle().usersMain
              .where(
                (user) => user.userId == widget.employeeId,
              )
              .toList();
      if (employees.isNotEmpty) {
        setState(() {
          employee = employees.first;
        });
      } else {
        setState(() {
          employee = TempUserClass(
            password: 'password',
            name: 'name',
            email: 'email',
            role: 'role',
            departmentUuids: [],
            access: [],
          );
        });
        Navigator.of(context).pop();
      }
    });
  }

  TempUserClass? employee;

  bool isLoading = false;
  bool showSuccess = false;

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  // }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return SafeArea(
      child: Stack(
        children: [
          Scaffold(
            body: Column(
              children: [
                SizedBox(
                  height:
                      MediaQuery.of(context).size.height -
                      50,
                  child: Stack(
                    alignment: Alignment(0, 1),
                    children: [
                      Align(
                        alignment: Alignment(0, -1),
                        child: TopBanner(
                          isMain: false,
                          subTitle:
                              'Full Details about employee',
                          title: 'Staff Details',
                          theme: theme,
                          bottomSpace: 100,
                          topSpace: 30,
                          iconData: Icons.person,
                        ),
                      ),
                      Builder(
                        builder: (context) {
                          if (employee == null) {
                            return Positioned(
                              top: 100,
                              child: SizedBox(
                                height:
                                    screenHeight(context) -
                                    200,
                                width: screenWidth(context),
                                child: returnCompProvider(
                                  context,
                                ).showLoader(
                                  message: 'Loading',
                                ),
                              ),
                            );
                          } else {
                            return Positioned(
                              top: 90,
                              child: DetailsPageContainer(
                                editAction: () {
                                  showDialog(
                                    context: context,
                                    builder: (editDialoge) {
                                      return DialogTemplate(
                                        theme: theme,
                                        message:
                                            'Select the action you want to perform.',
                                        title:
                                            'Select Action',
                                        action: () {},
                                        showBottomActionButtons:
                                            false,
                                        topRightWidget: IconButton(
                                          mouseCursor:
                                              SystemMouseCursors
                                                  .click,
                                          onPressed: () {
                                            Navigator.of(
                                              editDialoge,
                                            ).pop();
                                          },
                                          icon: Icon(
                                            Icons.clear,
                                          ),
                                        ),
                                        widget: Column(
                                          mainAxisSize:
                                              MainAxisSize
                                                  .min,
                                          spacing: 10,
                                          children: [
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Visibility(
                                              visible:
                                                  widget
                                                      .employeeId !=
                                                  currentUser()
                                                      .userId,
                                              child: MainButtonP(
                                                themeProvider:
                                                    theme,
                                                action: () {
                                                  Navigator.of(
                                                    editDialoge,
                                                  ).pop();
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (
                                                        context,
                                                      ) {
                                                        return CustomizeRolePage(
                                                          user:
                                                              employee ??
                                                              TempUserClass(
                                                                password:
                                                                    'password',
                                                                name:
                                                                    'name',
                                                                email:
                                                                    'email',
                                                                role:
                                                                    'role',
                                                                departmentUuids:
                                                                    [],
                                                                access:
                                                                    [],
                                                              ),
                                                        );
                                                      },
                                                    ),
                                                  );
                                                },
                                                text:
                                                    'Customize Access',
                                              ),
                                            ),
                                            Visibility(
                                              visible:
                                                  returnShopProvider()
                                                          .userShop()
                                                          ?.manageDepartments ==
                                                      true &&
                                                  widget.employeeId !=
                                                      currentUser()
                                                          .userId,
                                              child: MainButtonTransparent(
                                                themeProvider:
                                                    theme,
                                                constraints:
                                                    BoxConstraints(),
                                                text:
                                                    'Manage Staff Departments',
                                                action: () {
                                                  List<
                                                    String
                                                  >
                                                  list = [];
                                                  setState(() {
                                                    list.addAll(
                                                      employee?.departmentUuids ??
                                                          [],
                                                    );
                                                  });
                                                  showDialog(
                                                    context:
                                                        context,
                                                    builder: (
                                                      firstContext,
                                                    ) {
                                                      return StatefulBuilder(
                                                        builder: (
                                                          secondContext,
                                                          setState,
                                                        ) {
                                                          return DialogTemplate(
                                                            theme:
                                                                theme,
                                                            message:
                                                                'Select Department for this Staff',
                                                            title:
                                                                'Select Department',
                                                            topRightWidget:
                                                                returnDepartmentsDashboardProvider().isLoading
                                                                    ? SizedBox(
                                                                      height:
                                                                          20,
                                                                      width:
                                                                          20,
                                                                      child: CircularProgressIndicator(
                                                                        color:
                                                                            theme.lightModeColor.secColor200,
                                                                        strokeWidth:
                                                                            2.5,
                                                                      ),
                                                                    )
                                                                    : null,
                                                            action: () {
                                                              if (!returnDepartmentsDashboardProvider().isLoading) {
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
                                                                          'You are about to update this users Department(s). Are you sure you want to proceed?',
                                                                      title:
                                                                          'Update Departments',
                                                                      action: () async {
                                                                        Navigator.of(
                                                                          confirmContext,
                                                                        ).pop();
                                                                        returnDepartmentsDashboardProvider().toggleIsLoading(
                                                                          true,
                                                                        );
                                                                        setState(
                                                                          () {},
                                                                        );
                                                                        await returnUserProviderSingle().updateStaffDepartments(
                                                                          user:
                                                                              employee ??
                                                                              TempUserClass(
                                                                                password:
                                                                                    'password',
                                                                                name:
                                                                                    'name',
                                                                                email:
                                                                                    'email',
                                                                                role:
                                                                                    'role',
                                                                                departmentUuids:
                                                                                    [],
                                                                                access:
                                                                                    [],
                                                                              ),
                                                                          newDepartments:
                                                                              list,
                                                                        );
                                                                        if (secondContext.mounted) {
                                                                          Navigator.of(
                                                                            secondContext,
                                                                          ).pop();
                                                                        }
                                                                        if (firstContext.mounted) {
                                                                          Navigator.of(
                                                                            firstContext,
                                                                          ).pop();
                                                                        }
                                                                      },
                                                                    );
                                                                  },
                                                                );
                                                              }
                                                            },
                                                            widget: SizedBox(
                                                              height:
                                                                  screenHeight(
                                                                    context,
                                                                  ) -
                                                                  370,
                                                              child: SingleChildScrollView(
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
                                                                        returnDepartmentProvider().departments
                                                                            .map(
                                                                              (
                                                                                dept,
                                                                              ) => Material(
                                                                                color:
                                                                                    Colors.transparent,
                                                                                child: InkWell(
                                                                                  mouseCursor:
                                                                                      SystemMouseCursors.click,
                                                                                  onTap: () {
                                                                                    setState(
                                                                                      () {
                                                                                        if (list.contains(
                                                                                          dept.uuid,
                                                                                        )) {
                                                                                          list.remove(
                                                                                            dept.uuid,
                                                                                          );
                                                                                        } else {
                                                                                          list.add(
                                                                                            dept.uuid,
                                                                                          );
                                                                                        }
                                                                                      },
                                                                                    );
                                                                                  },
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
                                                                                          dept.name,
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
                                                                                                  list.contains(
                                                                                                        dept.uuid,
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
                                                  ).then((
                                                    _,
                                                  ) {
                                                    returnDepartmentsDashboardProvider().toggleIsLoading(
                                                      false,
                                                    );
                                                  });
                                                },
                                              ),
                                            ),
                                            MainButtonTransparent(
                                              themeProvider:
                                                  theme,
                                              constraints:
                                                  BoxConstraints(),
                                              text:
                                                  'Select New Role',
                                              action: () {
                                                Navigator.of(
                                                  editDialoge,
                                                ).pop();
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (
                                                      context,
                                                    ) {
                                                      return AddEmployeePage(
                                                        employee:
                                                            employee,
                                                      );
                                                    },
                                                  ),
                                                ).then((_) {
                                                  WidgetsBinding.instance.addPostFrameCallback((
                                                    _,
                                                  ) {
                                                    List<
                                                      TempUserClass
                                                    >
                                                    employees =
                                                        returnUserProviderSingle().usersMain
                                                            .where(
                                                              (
                                                                user,
                                                              ) =>
                                                                  user.userId ==
                                                                  widget.employeeId,
                                                            )
                                                            .toList();
                                                    if (employees
                                                        .isNotEmpty) {
                                                      setState(() {
                                                        employee =
                                                            employees.first;
                                                      });
                                                    } else {
                                                      setState(() {
                                                        employee = TempUserClass(
                                                          password:
                                                              'password',
                                                          name:
                                                              'name',
                                                          email:
                                                              'email',
                                                          role:
                                                              'role',
                                                          departmentUuids:
                                                              [],
                                                          access:
                                                              [],
                                                        );
                                                      });
                                                      Navigator.of(
                                                        context,
                                                      ).pop();
                                                    }
                                                  });
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                                deleteAction: () async {
                                  var isOnline =
                                      returnConnectivityProvider()
                                          .isConnected;
                                  if (!isOnline) {
                                    showDialog(
                                      // ignore: use_build_context_synchronously
                                      context: context,
                                      builder: (context) {
                                        return InfoAlert(
                                          theme:
                                              returnTheme(
                                                context,
                                                listen:
                                                    false,
                                              ),
                                          message:
                                              'Internet connection is not detected, therefore, You cannot delete a Staff.',
                                          title:
                                              'No Internet Connection',
                                        );
                                      },
                                    );
                                    return;
                                  }
                                  final safeContext =
                                      context;
                                  final shopProvider =
                                      returnShopProvider();
                                  showDialog(
                                    context: safeContext,
                                    builder: (context) {
                                      return ConfirmationAlert(
                                        theme: theme,
                                        message:
                                            'You are about to delete your staff, are you sure you want to proceed?',
                                        title:
                                            'Are you sure?',
                                        action: () async {
                                          if (safeContext
                                              .mounted) {
                                            Navigator.of(
                                              safeContext,
                                            ).pop();
                                          }
                                          setState(() {
                                            isLoading =
                                                true;
                                          });

                                          await shopProvider
                                              .removeEmployeeFromShop(
                                                context:
                                                    context,
                                                employeeIdToRemove:
                                                    widget
                                                        .employeeId,
                                              );
                                          setState(() {
                                            isLoading =
                                                false;
                                            showSuccess =
                                                true;
                                          });

                                          await Future.delayed(
                                            Duration(
                                              seconds: 2,
                                            ),
                                          );

                                          if (safeContext
                                              .mounted) {
                                            Navigator.of(
                                              safeContext,
                                            ).pop();
                                          }
                                        },
                                      );
                                    },
                                  );
                                },
                                theme: theme,
                                employee:
                                    employee ??
                                    TempUserClass(
                                      password: 'password',
                                      name: 'name',
                                      email: 'email',
                                      role: 'role',
                                      departmentUuids: [],
                                      access: [],
                                    ),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Visibility(
            visible: isLoading,
            child: returnCompProvider(
              context,
              listen: false,
            ).showLoader(message: 'Loading'),
          ),
          Visibility(
            visible: showSuccess,
            child: returnCompProvider(
              context,
              listen: false,
            ).showSuccess('Deleted Successfully'),
          ),
        ],
      ),
    );
  }
}

class DetailsPageContainer extends StatefulWidget {
  final ThemeProvider theme;
  final Function() deleteAction;
  final Function() editAction;
  final TempUserClass employee;
  const DetailsPageContainer({
    super.key,
    required this.theme,
    required this.employee,
    required this.deleteAction,
    required this.editAction,
  });

  @override
  State<DetailsPageContainer> createState() =>
      _DetailsPageContainerState();
}

class _DetailsPageContainerState
    extends State<DetailsPageContainer> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    compProvider = returnCompProvider(
      context,
      listen: false,
    );
  }

  late CompProvider compProvider;

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      compProvider.swtichTab(0);
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width - 20,
      height: MediaQuery.of(context).size.height - 150,
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(32, 0, 0, 0),
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          Column(
            children: [
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    spacing: 10,
                    children: [
                      Container(
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.shade200,
                        ),
                        child: SvgPicture.asset(
                          customersIconSvg,
                        ),
                      ),
                      Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  widget
                                      .theme
                                      .mobileTexts
                                      .b1
                                      .fontSize,
                            ),
                            widget.employee.name,
                          ),
                          Text(
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize:
                                  widget
                                      .theme
                                      .mobileTexts
                                      .b3
                                      .fontSize,
                            ),
                            widget.employee.email,
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        5,
                      ),
                      border: Border.all(
                        color: Colors.grey.shade300,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize:
                              widget
                                  .theme
                                  .mobileTexts
                                  .b3
                                  .fontSize,
                          color:
                              widget
                                  .theme
                                  .lightModeColor
                                  .secColor200,
                        ),
                        'Staff',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 10),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 20,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: Colors.grey.shade200,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TabBarTabButton(
                          index: 0,
                          text: 'Basic Info',
                          theme: widget.theme,
                        ),
                      ),
                      Expanded(
                        child: TabBarTabButton(
                          index: 1,
                          text: 'View Sales',
                          theme: widget.theme,
                          action: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return TotalSalesPage(
                                    id:
                                        widget
                                            .employee
                                            .userId!,
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  EmployeeDetailsContainer(
                    employee: widget.employee,
                    theme: widget.theme,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
          Row(
            spacing: 15,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Visibility(
                visible: authorization(
                  authorized:
                      Authorizations().deleteEmployee,
                ),
                child: CustomerActionButton(
                  icon: Icons.delete_outline_rounded,
                  color:
                      widget
                          .theme
                          .lightModeColor
                          .errorColor200,
                  iconSize: 18,
                  text: 'Delete',
                  action: widget.deleteAction,
                  theme: widget.theme,
                ),
              ),
              Visibility(
                visible: authorization(
                  authorized:
                      Authorizations().updateEmployee,
                ),
                child: CustomerActionButton(
                  svg: editIconSvg,
                  color: Colors.grey,
                  iconSize: 15,
                  text: 'Edit',
                  action: widget.editAction,
                  theme: widget.theme,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}

class EmployeeDetailsContainer extends StatelessWidget {
  const EmployeeDetailsContainer({
    super.key,
    required this.employee,
    required this.theme,
  });

  final TempUserClass employee;
  final ThemeProvider theme;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height - 450,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              spacing: 15,
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 9,
                  child: TabBarUserInfoSection(
                    mainText: employee.name,
                    text: 'Name',
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: TabBarUserInfoSection(
                    mainText: formatDateTime(
                      employee.createdAt!,
                    ),
                    text: 'Date Added',
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),
            Row(
              spacing: 15,
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 9,
                  child: TabBarUserInfoSection(
                    mainText: employee.email,
                    text: 'Email',
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: TabBarUserInfoSection(
                    mainText:
                        employee.phone == null
                            ? 'Not Set'
                            : employee.phone!,
                    text: 'Phone Number',
                  ),
                ),
              ],
            ),
            SizedBox(height: 40),
            Row(
              spacing: 15,
              children: [
                Text(
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b2.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                  'OTHER DETAILS:',
                ),
              ],
            ),
            SizedBox(height: 5),
            Divider(),
            SizedBox(height: 10),
            Row(
              spacing: 15,
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 9,
                  child: TabBarUserInfoSection(
                    mainText: 'Not Set',
                    text: 'Address',
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: TabBarUserInfoSection(
                    mainText: employee.role,

                    text: 'Role',
                  ),
                ),
              ],
            ),

            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class CustomerActionButton extends StatelessWidget {
  final String text;
  final Function()? action;
  final IconData? icon;
  final Color color;
  final double iconSize;
  final ThemeProvider theme;
  final String? svg;

  const CustomerActionButton({
    super.key,
    required this.text,
    this.action,
    this.icon,
    required this.color,
    required this.iconSize,
    required this.theme,
    this.svg,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        mouseCursor: SystemMouseCursors.click,
        onTap: action,
        borderRadius: BorderRadius.circular(5),
        child: Container(
          height: 35,
          width: 100,
          padding: EdgeInsets.symmetric(
            vertical: 7,
            horizontal: 10,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: Colors.grey.shade400),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceAround,
              children: [
                Text(
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b3.fontSize,
                  ),
                  text,
                ),
                Stack(
                  children: [
                    Visibility(
                      visible: icon != null,
                      child: Icon(
                        size: iconSize,
                        color: color,
                        icon ??
                            Icons.delete_outline_rounded,
                      ),
                    ),
                    Visibility(
                      visible: svg != null,
                      child: SvgPicture.asset(
                        svg ?? '',
                        height: iconSize,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TabBarUserInfoSection extends StatelessWidget {
  final String text;
  final String mainText;
  const TabBarUserInfoSection({
    super.key,
    required this.text,
    required this.mainText,
  });

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return SizedBox(
      child: Column(
        spacing: 8,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(text),
          Row(
            children: [
              Flexible(
                child: Text(
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b2.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                  mainText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TabBarTabButton extends StatelessWidget {
  final String text;
  final int index;
  final Function()? action;
  const TabBarTabButton({
    super.key,
    required this.theme,
    required this.index,
    required this.text,
    this.action,
  });

  final ThemeProvider theme;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color:
              returnCompProvider(context).activeTab == index
                  ? const Color.fromARGB(50, 255, 193, 7)
                  : Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color:
                  returnCompProvider(context).activeTab ==
                          index
                      ? theme.lightModeColor.secColor200
                      : Colors.grey.shade400,
              width: 3,
            ),
          ),
        ),
        child: InkWell(
          mouseCursor: SystemMouseCursors.click,
          onTap: () {
            action!();
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 10),

            child: Center(
              child: Text(
                style: TextStyle(
                  fontWeight:
                      returnCompProvider(
                                context,
                              ).activeTab ==
                              index
                          ? FontWeight.bold
                          : FontWeight.normal,
                ),
                text,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
