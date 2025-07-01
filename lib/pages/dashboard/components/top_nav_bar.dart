import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stockall/classes/temp_notification.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/authentication/auth_screens/auth_screens_page.dart';
import 'package:stockall/providers/theme_provider.dart';
import 'package:stockall/services/auth_service.dart';

class TopNavBar extends StatelessWidget {
  final List<TempNotification> notifications;
  final String? title;
  final String? subText;
  final Function()? action;
  final ThemeProvider theme;

  final Function()? openSideBar;

  const TopNavBar({
    super.key,
    required this.notifications,
    this.title,
    this.subText,
    required this.theme,
    required this.openSideBar,
    this.action,
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
                    children: [],
                  ),
                ],
              ),
            ],
          ),
          Stack(
            children: [
              Visibility(
                visible: authorization(
                  authorized:
                      Authorizations().notificationsPage,
                  context: context,
                ),
                child: Stack(
                  alignment: Alignment(1.2, -1.8),
                  children: [
                    InkWell(
                      onTap: () {
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
                    !authorization(
                      authorized:
                          Authorizations()
                              .notificationsPage,
                      context: context,
                    ),
                child: Stack(
                  alignment: Alignment(1.2, -1.8),
                  children: [
                    InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (dialogContext) {
                            return ConfirmationAlert(
                              theme: theme,
                              message:
                                  'You are about to Logout',
                              title: 'Are you Sure?',
                              action: () async {
                                Navigator.of(
                                  dialogContext,
                                ).pop();

                                await AuthService()
                                    .signOut();
                                if (context.mounted) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return AuthScreensPage();
                                      },
                                    ),
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
