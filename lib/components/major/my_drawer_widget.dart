import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stockitt/classes/temp_notification.dart';
import 'package:stockitt/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockitt/constants/constants_main.dart';
import 'package:stockitt/main.dart';
import 'package:stockitt/pages/customers/customers_list/customer_list.dart';
import 'package:stockitt/pages/employees/employee_list/employee_list_page.dart';
import 'package:stockitt/pages/expenses/expenses_page.dart';
import 'package:stockitt/pages/notifications/notifications_page.dart';
import 'package:stockitt/pages/report/report_page.dart';
import 'package:stockitt/providers/theme_provider.dart';

class MyDrawerWidget extends StatelessWidget {
  final ThemeProvider theme;
  final Function()? action;
  final List<TempNotification> notifications;
  final String role;
  const MyDrawerWidget({
    super.key,
    required this.theme,
    required this.notifications,
    required this.action,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 10.0,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 25.0,
          ),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  SizedBox(height: 60),
                  Row(
                    spacing: 10,
                    mainAxisAlignment:
                        MainAxisAlignment.start,
                    children: [
                      Image.asset(mainLogoIcon, height: 22),
                      Text(
                        style: TextStyle(
                          fontSize:
                              theme.mobileTexts.h3.fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                        'Stockitt',
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  NavListTile(
                    thisIndex: 0,
                    title: 'Home',
                    icon: Icons.home_rounded,
                  ),
                  NavListTile(
                    thisIndex: 1,
                    title: 'Products',
                    // icon: Icons.home_rounded,
                    svg: productIconSvg,
                    height: 16,
                  ),
                  NavListTile(
                    thisIndex: 2,
                    title: 'Sales',
                    // icon: Icons.home_rounded,
                    svg: salesIconSvg,
                    height: 16,
                  ),
                  NavListTileAlt(
                    height: 16,
                    action: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return CustomerList();
                          },
                        ),
                      );
                    },
                    title: 'Customers',
                    svg: custBookIconSvg,
                  ),
                  NavListTileAlt(
                    height: 16,
                    action: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return EmployeeListPage(
                              empId: '',
                              role: '',
                            );
                          },
                        ),
                      );
                    },
                    title: 'Empolyees',
                    svg: employeesIconSvg,
                  ),
                  NavListTileAlt(
                    height: 16,
                    action: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return ExpensesPage();
                          },
                        ),
                      );
                    },
                    title: 'Expenses',
                    svg: expensesIconSvg,
                  ),
                  NavListTileAlt(
                    height: 16,
                    action: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return ReportPage();
                          },
                        ),
                      );
                    },
                    title: 'Report',
                    svg: reportIconSvg,
                  ),
                  SizedBox(height: 10),
                  Divider(
                    height: 30,
                    color: Colors.grey.shade200,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return NotificationsPage(
                              notifications: notifications,
                            );
                          },
                        ),
                      );
                    },
                    child: Visibility(
                      visible: role == 'Owner',
                      child: SizedBox(
                        height: 50,
                        child: Padding(
                          padding:
                              const EdgeInsets.symmetric(
                                horizontal: 20.0,
                              ),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .spaceBetween,
                            children: [
                              Row(
                                spacing: 10,
                                mainAxisAlignment:
                                    MainAxisAlignment.start,
                                children: [
                                  Stack(
                                    children: [
                                      Icon(
                                        color:
                                            Colors
                                                .grey
                                                .shade400,
                                        size: 22,
                                        Icons
                                            .notifications_on_outlined,
                                      ),
                                    ],
                                  ),

                                  Text(
                                    style: TextStyle(
                                      color:
                                          Colors
                                              .grey
                                              .shade600,
                                      fontSize: 14,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                    'Notifications',
                                  ),
                                ],
                              ),
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      // Provider.of<CompProvider>(
                                      //   context,
                                      //   listen: false,
                                      // ).switchNotif();
                                      Navigator.of(
                                        context,
                                      ).pop();
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (
                                            context,
                                          ) {
                                            return NotificationsPage(
                                              notifications:
                                                  notifications,
                                            );
                                          },
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding:
                                          EdgeInsets.all(
                                            10,
                                          ),
                                      decoration: BoxDecoration(
                                        color:
                                            const Color.fromARGB(
                                              208,
                                              245,
                                              245,
                                              245,
                                            ),
                                        shape:
                                            BoxShape.circle,
                                      ),
                                      child: SvgPicture.asset(
                                        height: 25,
                                        width: 25,
                                        notifIconSvg,
                                        color:
                                            notifications
                                                    .where(
                                                      (
                                                        notif,
                                                      ) =>
                                                          !notif.isViewed,
                                                    )
                                                    .isNotEmpty
                                                ? null
                                                : Colors
                                                    .grey
                                                    .shade500,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 25,
                                    left: 32,
                                    child: Visibility(
                                      visible:
                                          notifications
                                              .where(
                                                (notif) =>
                                                    !notif
                                                        .isViewed,
                                              )
                                              .isNotEmpty,
                                      child: Container(
                                        padding:
                                            EdgeInsets.all(
                                              6,
                                            ),
                                        decoration: BoxDecoration(
                                          shape:
                                              BoxShape
                                                  .circle,
                                          gradient:
                                              theme
                                                  .lightModeColor
                                                  .secGradient,
                                        ),
                                        child: Center(
                                          child: Text(
                                            style: TextStyle(
                                              fontWeight:
                                                  FontWeight
                                                      .bold,
                                              fontSize: 14,
                                              color:
                                                  Colors
                                                      .white,
                                            ),
                                            '${notifications.where((notif) => !notif.isViewed).length}',
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              Column(
                children: [
                  Visibility(
                    visible:
                        returnLocalDatabase(
                          context,
                        ).currentEmployees.isNotEmpty,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        bottom: 15.0,
                      ),
                      child: NavListTileAlt(
                        height: 16,
                        action: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return ConfirmationAlert(
                                theme: theme,
                                message:
                                    'You are about to Logout',
                                title: 'Are you Sure?',
                                action: () async {
                                  await returnLocalDatabase(
                                    context,
                                    listen: false,
                                  ).deleteUser();

                                  if (context.mounted) {
                                    Navigator.popAndPushNamed(
                                      context,
                                      '/',
                                    );
                                    returnNavProvider(
                                      context,
                                      listen: false,
                                    ).navigate(0);
                                  }
                                },
                              );
                            },
                          );
                        },
                        title: 'Employee Logout',
                        // svg: reportIconSvg,
                        icon: Icons.logout_rounded,
                      ),
                    ),
                  ),
                  Visibility(
                    visible: role == 'Owner',
                    child: Padding(
                      padding: const EdgeInsets.only(
                        bottom: 30.0,
                      ),
                      child: NavListTileAlt(
                        height: 16,
                        action: action,
                        title: 'Logout',
                        // svg: reportIconSvg,
                        icon: Icons.logout_rounded,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NavListTile extends StatelessWidget {
  final String title;
  final int thisIndex;
  final IconData? icon;
  final String? svg;
  final double? height;
  const NavListTile({
    super.key,
    required this.thisIndex,
    required this.title,
    this.icon,
    this.svg,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return InkWell(
      onTap: () {
        returnNavProvider(
          context,
          listen: false,
        ).navigate(thisIndex);
        Navigator.of(context).pop();
      },
      child: SizedBox(
        height: 50,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20.0,
          ),
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Row(
                spacing: 10,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Visibility(
                        visible: icon != null,
                        child: Icon(
                          color:
                              returnNavProvider(
                                        context,
                                      ).currentPage ==
                                      thisIndex
                                  ? theme
                                      .lightModeColor
                                      .secColor200
                                  : Colors.grey.shade600,
                          size:
                              returnNavProvider(
                                        context,
                                      ).currentPage ==
                                      thisIndex
                                  ? 22
                                  : 18,
                          icon ?? Icons.home,
                        ),
                      ),
                      Visibility(
                        visible: svg != null,
                        child: SvgPicture.asset(
                          color:
                              returnNavProvider(
                                        context,
                                      ).currentPage ==
                                      thisIndex
                                  ? theme
                                      .lightModeColor
                                      .secColor200
                                  : Colors.grey.shade600,
                          svg ?? '',
                          height:
                              returnNavProvider(
                                        context,
                                      ).currentPage ==
                                      thisIndex
                                  ? 20
                                  : height,
                        ),
                      ),
                    ],
                  ),
                  // Icon(
                  //   color:
                  //       returnNavProvider(
                  //                 context,
                  //               ).currentPage ==
                  //               thisIndex
                  //           ? const Color.fromARGB(
                  //             255,
                  //             4,
                  //             49,
                  //             199,
                  //           )
                  //           : Colors.grey,
                  //   size:
                  //       returnNavProvider(
                  //                 context,
                  //               ).currentPage ==
                  //               thisIndex
                  //           ? 22
                  //           : 18,
                  //   icon,
                  // ),
                  Text(
                    style: TextStyle(
                      color:
                          returnNavProvider(
                                    context,
                                  ).currentPage ==
                                  thisIndex
                              ? theme
                                  .lightModeColor
                                  .secColor200
                              : Colors.grey.shade600,
                      fontSize:
                          returnNavProvider(
                                    context,
                                  ).currentPage ==
                                  thisIndex
                              ? 15
                              : 14,
                      fontWeight:
                          returnNavProvider(
                                    context,
                                  ).currentPage ==
                                  thisIndex
                              ? FontWeight.w800
                              : FontWeight.bold,
                    ),
                    title,
                  ),
                ],
              ),

              Icon(
                color:
                    returnNavProvider(
                              context,
                            ).currentPage ==
                            thisIndex
                        ? theme.lightModeColor.secColor200
                        : Colors.grey.shade600,
                size:
                    returnNavProvider(
                              context,
                            ).currentPage ==
                            thisIndex
                        ? 30
                        : 18,
                returnNavProvider(context).currentPage ==
                        thisIndex
                    ? Icons.arrow_drop_down
                    : Icons.arrow_forward_ios_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NavListTileAlt extends StatelessWidget {
  final String title;
  final IconData? icon;
  final String? svg;
  final Function()? action;
  final double height;
  const NavListTileAlt({
    super.key,
    required this.title,
    this.icon,
    required this.action,
    this.svg,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
        action!();
      },
      child: SizedBox(
        height: 50,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20.0,
          ),
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Row(
                spacing: 10,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Visibility(
                        visible: icon != null,
                        child: Icon(
                          color: Colors.grey.shade600,
                          size: height,
                          icon ??
                              Icons
                                  .arrow_forward_ios_rounded,
                        ),
                      ),
                      Visibility(
                        visible: svg != null,
                        child: SvgPicture.asset(
                          color: Colors.grey.shade600,
                          svg ?? '',
                          height: height,
                        ),
                      ),
                    ],
                  ),

                  Text(
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    title,
                  ),
                ],
              ),
              Icon(
                color: Colors.grey.shade600,
                size: 18,
                Icons.arrow_forward_ios_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
