import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stockall/classes/temp_notification.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/dashboard/employee_auth_page/emp_auth.dart';
import 'package:stockall/providers/theme_provider.dart';

class TopNavBar extends StatelessWidget {
  final List<TempNotification> notifications;
  final String? title;
  final String? subText;
  final Function()? action;
  final ThemeProvider theme;

  final String role;
  final Function()? openSideBar;

  const TopNavBar({
    super.key,
    required this.notifications,
    this.title,
    this.subText,
    required this.theme,
    required this.openSideBar,
    this.action,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 0,
        bottom: 10,
        left: 0,
        right: 15,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(30, 0, 0, 0),
            blurRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 5,
            children: [
              InkWell(
                onTap: openSideBar,
                child: SizedBox(
                  height: 70,
                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.center,
                    children: [
                      SizedBox(width: 15),
                      Icon(
                        color: Colors.grey.shade700,
                        size: 28,
                        Icons.menu_rounded,
                      ),
                      SizedBox(width: 10),
                      Container(
                        padding: EdgeInsets.all(3),
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          shopIconImage,
                          height: 35,
                          width: 35,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Column(
                spacing: 3,
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.center,
                    children: [
                      Text(
                        style: TextStyle(
                          fontSize:
                              theme.mobileTexts.b2.fontSize,
                          fontWeight:
                              theme
                                  .mobileTexts
                                  .b2
                                  .fontWeightBold,
                          color: Colors.black,
                        ),
                        cutLongText(
                          title ??
                              returnShopProvider(
                                context,
                              ).userShop!.name,
                          17,
                        ),
                      ),
                      SizedBox(width: 5),
                      SvgPicture.asset(
                        checkIconSvg,
                        height: 18,
                        width: 18,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                  Text(
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.b3.fontSize,
                      color:
                          theme.lightModeColor.prColor250,
                      fontWeight: FontWeight.w500,
                    ),
                    cutLongText(
                      subText ??
                          returnShopProvider(
                            context,
                          ).userShop!.email,
                      22,
                    ),
                  ),
                  SizedBox(height: 0),
                  Row(
                    spacing: 6,
                    mainAxisAlignment:
                        MainAxisAlignment.end,
                    children: [
                      // Text(
                      //   style: TextStyle(
                      //     fontWeight: FontWeight.bold,
                      //     fontSize:
                      //         theme.mobileTexts.b4.fontSize,
                      //     color: Colors.grey.shade500,
                      //   ),
                      //   'User:',
                      // ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          Stack(
            children: [
              Visibility(
                visible:
                    role == 'Owner' ||
                    role == "General Manager",
                child: Stack(
                  alignment: Alignment(1.2, -1.8),
                  children: [
                    InkWell(
                      onTap: () {
                        // Provider.of<CompProvider>(
                        //   context,
                        //   listen: false,
                        // ).switchNotif();
                        action!();
                      },
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(
                            208,
                            245,
                            245,
                            245,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: SvgPicture.asset(
                          height: 25,
                          width: 25,
                          notifIconSvg,
                        ),
                      ),
                    ),
                    Visibility(
                      visible:
                          notifications
                              .where(
                                (notif) => !notif.isViewed,
                              )
                              .isNotEmpty,
                      child: Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient:
                              theme
                                  .lightModeColor
                                  .secGradient,
                        ),
                        child: Center(
                          child: Text(
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  notifications
                                              .where(
                                                (notif) =>
                                                    !notif
                                                        .isViewed,
                                              )
                                              .length ==
                                          2
                                      ? 12
                                      : 14,
                              color: Colors.white,
                            ),
                            '${notifications.where((notif) => !notif.isViewed).length}',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Visibility(
                visible:
                    role != 'Owner' &&
                    role != "General Manager",
                child: Stack(
                  alignment: Alignment(1.2, -1.8),
                  children: [
                    InkWell(
                      onTap: () {
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
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                              EmpAuth(),
                                    ),
                                    (route) =>
                                        false, // removes all previous routes
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
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(
                            208,
                            245,
                            245,
                            245,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.logout_rounded),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
