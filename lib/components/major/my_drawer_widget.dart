import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stockall/classes/temp_notification.dart';
import 'package:stockall/classes/temp_user_class.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/customers/customers_list/customer_list.dart';
import 'package:stockall/pages/employees/employee_list/employee_list_page.dart';
import 'package:stockall/pages/expenses/expenses_page.dart';
import 'package:stockall/pages/notifications/notifications_page.dart';
import 'package:stockall/pages/profile/profile_page.dart';
import 'package:stockall/pages/referrals/referrals.dart';
import 'package:stockall/pages/report/general_report/general_report_page.dart';
import 'package:stockall/pages/shop_setup/shop_page/shop_page.dart';
import 'package:stockall/providers/theme_provider.dart';
import 'package:stockall/services/auth_service.dart';

class MyDrawerWidget extends StatefulWidget {
  final ThemeProvider theme;
  final Function()? action;
  final List<TempNotification> notifications;
  // final String role;
  const MyDrawerWidget({
    super.key,
    required this.theme,
    required this.notifications,
    required this.action,
    // required this.role,
  });

  @override
  State<MyDrawerWidget> createState() =>
      _MyDrawerWidgetState();
}

class _MyDrawerWidgetState extends State<MyDrawerWidget> {
  late Future<List<TempUserClass>> employeesFuture;

  // Future<List<TempUserClass>> getEmployees() async {
  //   var tempEmployees =
  //       await returnUserProvider(
  //         context,
  //         listen: false,
  //       ).fetchUsers();

  //   var mainBeans =
  //       tempEmployees
  //           .where(
  //             (emp) =>
  //                 emp.userId !=
  //                 AuthService().currentUser!.id,
  //           )
  //           .toList();

  //   // returnLocalDatabase(
  //   //   // ignore: use_build_context_synchronously
  //   //   context,
  //   //   listen: false,
  //   // ).currentEmployees.addAll(mainBeans);

  //   return mainBeans;
  // }

  @override
  void initState() {
    super.initState();
    // employeesFuture = getEmployees();
  }

  @override
  Widget build(BuildContext context) {
    var user = returnUserProvider(context).currentUserMain;
    return Drawer(
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 10.0,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 15.0,
          ),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  children: [
                    SizedBox(
                      height:
                          MediaQuery.of(
                                    context,
                                  ).size.height <
                                  680
                              ? 35
                              : 50,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 10.0,
                      ),
                      child: Row(
                        spacing: 10,
                        mainAxisAlignment:
                            MainAxisAlignment.start,
                        children: [
                          Image.asset(
                            mainLogoIcon,
                            height: 22,
                          ),
                          Text(
                            style: TextStyle(
                              fontSize:
                                  widget
                                      .theme
                                      .mobileTexts
                                      .h3
                                      .fontSize,
                              fontWeight: FontWeight.bold,
                            ),
                            appName,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height:
                          MediaQuery.of(
                                    context,
                                  ).size.height <
                                  680
                              ? 10
                              : 20,
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Visibility(
                              // visible:
                              //     widget.role == 'Owner',
                              child: NavListTileAlt(
                                height: 20,
                                action: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return ProfilePage();
                                      },
                                    ),
                                  );
                                },
                                title: 'Profile',
                                icon: Icons.person,
                              ),
                            ),
                            Visibility(
                              visible:
                                  user?.role == 'Owner',
                              child: NavListTileAlt(
                                height: 20,
                                action: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return ShopPage();
                                      },
                                    ),
                                  );
                                },
                                title: 'Manage Shop',
                                icon: Icons.home_filled,
                              ),
                            ),
                            // NavListTile(
                            //   thisIndex: 0,
                            //   title: 'Home',
                            //   icon: Icons.home_rounded,
                            // ),
                            // NavListTile(
                            //   thisIndex: 1,
                            //   title: 'Products',
                            //   // icon: Icons.home_rounded,
                            //   svg: productIconSvg,
                            //   height: 16,
                            // ),
                            // NavListTile(
                            //   thisIndex: 2,
                            //   title: 'Sales',
                            //   // icon: Icons.home_rounded,
                            //   svg: salesIconSvg,
                            //   height: 16,
                            // ),
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
                            Visibility(
                              visible:
                                  user?.role == 'Owner',
                              child: NavListTileAlt(
                                height: 16,
                                action: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return EmployeeListPage(
                                          empId:
                                              AuthService()
                                                  .currentUser!
                                                  .id,
                                          // returnLocalDatabase(
                                          //           context,
                                          //           listen:
                                          //               false,
                                          //         ).currentEmployee !=
                                          //         null
                                          //     ? returnLocalDatabase(
                                          //       context,
                                          //       listen:
                                          //           false,
                                          //     ).currentEmployee!.userId!
                                          //     : '',
                                          // returnLocalDatabase(
                                          //           context,
                                          //           listen:
                                          //               false,
                                          //         ).currentEmployee !=
                                          //         null
                                          //     ? returnLocalDatabase(
                                          //       context,
                                          //       listen:
                                          //           false,
                                          //     ).currentEmployee!.role
                                          //     : '',
                                        );
                                      },
                                    ),
                                  );
                                },
                                title: 'Empolyees',
                                svg: employeesIconSvg,
                              ),
                            ),
                            NavListTileAlt(
                              height: 16,
                              action: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return ExpensesPage(
                                        isMain: true,
                                      );
                                    },
                                  ),
                                ).then((_) {
                                  setState(() {});
                                });
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
                                      return GeneralReportPage();
                                    },
                                  ),
                                );
                              },
                              title: 'Report',
                              svg: reportIconSvg,
                            ),
                            SizedBox(height: 5),
                            Divider(
                              height:
                                  MediaQuery.of(
                                            context,
                                          ).size.height <
                                          680
                                      ? 15
                                      : 20,
                              color: Colors.grey.shade200,
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.of(context).pop();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return NotificationsPage();
                                    },
                                  ),
                                );
                              },
                              child: Visibility(
                                visible:
                                    user?.role == 'Owner',
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
                                              MainAxisAlignment
                                                  .start,
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
                                                        .shade900,
                                                fontSize:
                                                    14,
                                                fontWeight:
                                                    FontWeight
                                                        .normal,
                                              ),
                                              'Notifications',
                                            ),
                                          ],
                                        ),
                                        Stack(
                                          clipBehavior:
                                              Clip.none,
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
                                                      return NotificationsPage();
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
                                                      BoxShape
                                                          .circle,
                                                ),
                                                child: SvgPicture.asset(
                                                  height:
                                                      25,
                                                  width: 25,
                                                  notifIconSvg,
                                                  color:
                                                      widget.notifications
                                                              .where(
                                                                (
                                                                  notif,
                                                                ) =>
                                                                    !notif.isViewed,
                                                              )
                                                              .isNotEmpty
                                                          ? null
                                                          : Colors.grey.shade500,
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              bottom: 25,
                                              left: 32,
                                              child: Visibility(
                                                visible:
                                                    widget
                                                        .notifications
                                                        .where(
                                                          (
                                                            notif,
                                                          ) =>
                                                              !notif.isViewed,
                                                        )
                                                        .isNotEmpty,
                                                child: Container(
                                                  padding:
                                                      EdgeInsets.all(
                                                        6,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    shape:
                                                        BoxShape.circle,
                                                    gradient:
                                                        widget.theme.lightModeColor.secGradient,
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize:
                                                            14,
                                                        color:
                                                            Colors.white,
                                                      ),
                                                      '${widget.notifications.where((notif) => !notif.isViewed).length}',
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
                            Visibility(
                              visible:
                                  user?.role == 'Owner',
                              child: NavListTileAlt(
                                height: 20,
                                action: () async {
                                  phoneCall();
                                },
                                title: 'Contact Us',
                                icon: Icons.phone,
                              ),
                            ),
                            Visibility(
                              visible:
                                  user?.role == 'Owner',
                              child: NavListTileAlt(
                                height: 20,
                                action: () async {
                                  openWhatsApp();
                                },
                                title: 'Chat With Us',
                                svg: whatsappIconSvg,
                              ),
                            ),
                            Visibility(
                              visible: false,
                              // widget.role == 'Owner',
                              child: NavListTileAlt(
                                height: 20,
                                action: () {},
                                title:
                                    'Privacy P. & Terms/C.',
                                icon:
                                    Icons.menu_book_rounded,
                              ),
                            ),
                            NavListTileAlt(
                              height: 20,
                              action: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return Referrals();
                                    },
                                  ),
                                );
                              },
                              title: 'Referrals',
                              icon:
                                  Icons
                                      .card_giftcard_rounded,
                            ),
                            SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Column(
                children: [
                  // FutureBuilder(
                  //   future: employeesFuture,
                  //   builder: (context, snapshot) {
                  //     if (snapshot.connectionState ==
                  //         ConnectionState.waiting) {
                  //       return Shimmer.fromColors(
                  //         baseColor: Colors.grey.shade300,
                  //         highlightColor: Colors.white,
                  //         child: Container(height: 20),
                  //       );
                  //     } else if (snapshot.hasError) {
                  //       return Container(height: 20);
                  //     } else {
                  //       var employees = snapshot.data!;
                  //       return Visibility(
                  //         visible: employees.isNotEmpty,
                  //         child: Padding(
                  //           padding:
                  //               widget.role == 'Owner'
                  //                   ? const EdgeInsets.only(
                  //                     bottom: 2,
                  //                   )
                  //                   : const EdgeInsets.only(
                  //                     bottom: 20,
                  //                   ),
                  //           child: NavListTileAlt(
                  //             height: 20,
                  //             action: () {
                  //               showDialog(
                  //                 context: context,
                  //                 builder: (context) {
                  //                   return ConfirmationAlert(
                  //                     theme: widget.theme,
                  //                     message:
                  //                         'You are about to Logout',
                  //                     title:
                  //                         'Are you Sure?',
                  //                     action: () async {
                  //                       await returnLocalDatabase(
                  //                         context,
                  //                         listen: false,
                  //                       ).deleteUser();

                  //                       if (context
                  //                           .mounted) {
                  //                         Navigator.pushAndRemoveUntil(
                  //                           context,
                  //                           MaterialPageRoute(
                  //                             builder:
                  //                                 (
                  //                                   context,
                  //                                 ) =>
                  //                                     EmpAuth(),
                  //                           ),
                  //                           (route) =>
                  //                               false, // removes all previous routes
                  //                         );
                  //                         returnNavProvider(
                  //                           context,
                  //                           listen: false,
                  //                         ).navigate(0);
                  //                       }
                  //                     },
                  //                   );
                  //                 },
                  //               );
                  //             },
                  //             title: 'Employee Logout',
                  //             // svg: reportIconSvg,
                  //             icon:
                  //                 Icons
                  //                     .person_remove_alt_1_outlined,
                  //           ),
                  //         ),
                  //       );
                  //     }
                  //   },
                  // ),
                  Visibility(
                    // visible: widget.role == 'Owner',
                    child: Padding(
                      padding:
                          MediaQuery.of(
                                    context,
                                  ).size.height <
                                  680
                              ? const EdgeInsets.only(
                                bottom: 15.0,
                              )
                              : const EdgeInsets.only(
                                bottom: 20.0,
                              ),
                      child: NavListTileAlt(
                        height: 20,
                        action: widget.action,
                        title: 'Logout',
                        // svg: reportIconSvg,
                        icon: Icons.logout_rounded,
                        color: Colors.redAccent,
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
                              : Colors.grey.shade900,
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
                              ? FontWeight.bold
                              : FontWeight.normal,
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
                        : Colors.grey.shade900,
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
  final Color? color;
  const NavListTileAlt({
    super.key,
    required this.title,
    this.icon,
    required this.action,
    this.svg,
    required this.height,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
        action!();
      },
      child: SizedBox(
        height: 45,
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
                  SizedBox(
                    width: 20,
                    child: Center(
                      child: Stack(
                        children: [
                          Visibility(
                            visible: icon != null,
                            child: Icon(
                              color:
                                  color ??
                                  Colors.grey.shade600,
                              size: height,
                              icon ??
                                  Icons
                                      .arrow_forward_ios_rounded,
                            ),
                          ),
                          Visibility(
                            visible: svg != null,
                            child: SvgPicture.asset(
                              color:
                                  color ??
                                  Colors.grey.shade600,
                              svg ?? '',
                              height: height,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Text(
                    style: TextStyle(
                      color: color ?? Colors.grey.shade900,
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
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
