import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stockall/classes/temp_notification/temp_notification.dart';
import 'package:stockall/components/major/drawer_widget/drawer_nav_items.dart';
import 'package:stockall/components/major/drawer_widget/platforms/my_drawer_widget_tablet.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/theme_provider.dart';

class MyDrawerWidgetDesktop extends StatelessWidget {
  final ThemeProvider theme;
  final Function()? action;
  final GlobalKey<ScaffoldState> globalKey;
  final List<TempNotification> notifications;
  const MyDrawerWidgetDesktop({
    super.key,
    required this.theme,
    required this.notifications,
    required this.action,
    required this.globalKey,
  });

  @override
  Widget build(BuildContext context) {
    if (screenWidth(context) <= 1090) {
      return MyDrawerWidgetTablet(
        theme: theme,
        notifications: notifications,
        action: action,
        globalKey: globalKey,
      );
    } else {
      return MyDrawerWidgetDesktopMain(
        theme: theme,
        notifications: notifications,
        action: action,
        globalKey: globalKey,
      );
    }
  }
}

class MyDrawerWidgetDesktopMain extends StatefulWidget {
  final ThemeProvider theme;
  final Function()? action;
  final List<TempNotification> notifications;
  final GlobalKey<ScaffoldState> globalKey;

  const MyDrawerWidgetDesktopMain({
    super.key,
    required this.theme,
    required this.notifications,
    required this.action,
    required this.globalKey,
  });

  @override
  State<MyDrawerWidgetDesktopMain> createState() =>
      _MyDrawerWidgetDesktopMainState();
}

class _MyDrawerWidgetDesktopMainState
    extends State<MyDrawerWidgetDesktopMain> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 230,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(39, 4, 1, 41),
              blurRadius: 10,
            ),
          ],
        ),
        child: Drawer(
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10.0,
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
                                ? 20
                                : 30,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 10.0,
                        ),
                        child: Row(
                          mainAxisAlignment:
                              screenWidth(context) <=
                                      tabletScreen
                                  ? MainAxisAlignment
                                      .spaceBetween
                                  : MainAxisAlignment.start,
                          children: [
                            Row(
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
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                  appName,
                                ),
                              ],
                            ),
                            Visibility(
                              visible:
                                  screenWidth(context) <=
                                  tabletScreen,
                              child: InkWell(
                                mouseCursor:
                                    SystemMouseCursors
                                        .click,
                                onTap: () {
                                  widget
                                      .globalKey
                                      .currentState
                                      ?.closeDrawer();
                                },
                                child: Container(
                                  padding:
                                      EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                  child: Icon(
                                    size: 20,
                                    color: Colors.grey,
                                    Icons
                                        .arrow_back_ios_new_rounded,
                                  ),
                                ),
                              ),
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
                              DrawerNavItems(
                                mode: DrawerMode.desktop,
                                theme: widget.theme,
                                notifications:
                                    widget.notifications,
                                onRefresh:
                                    () => setState(() {}),
                                buildTile: ({
                                  int? itemIndex,
                                  required double height,
                                  required VoidCallback
                                  action,
                                  required String title,
                                  IconData? icon,
                                  String? svg,
                                }) {
                                  return NavListTileDesktopAlt(
                                    itemIndex: itemIndex,
                                    height: height,
                                    action: action,
                                    title: title,
                                    icon: icon,
                                    svg: svg,
                                  );
                                },
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Column(
                  children: [
                    Visibility(
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
                        child: NavListTileDesktopAlt(
                          height: 18,
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
      ),
    );
  }
}

void checkNavigate(BuildContext context) {
  if (returnNavProvider(
            context,
            listen: false,
          ).currentIndex !=
          0 ||
      returnNavProvider(
            context,
            listen: false,
          ).currentIndex !=
          1 ||
      returnNavProvider(
            context,
            listen: false,
          ).currentIndex !=
          2) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }
}

class NavListTileDesktopAlt extends StatelessWidget {
  final String title;
  final int? itemIndex;
  final IconData? icon;
  final String? svg;
  final Function()? action;
  final double height;
  final Color? color;
  final Widget? endWidget;
  const NavListTileDesktopAlt({
    super.key,
    required this.title,
    this.icon,
    required this.action,
    this.svg,
    required this.height,
    this.color,
    this.itemIndex,
    this.endWidget,
  });

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Padding(
      padding: const EdgeInsets.only(top: 2, bottom: 2),
      child: InkWell(
        mouseCursor: SystemMouseCursors.click,
        onTap: () {
          action!();
        },
        child: Container(
          color:
              returnNavProvider(context).currentIndex ==
                      itemIndex
                  ? const Color.fromARGB(36, 255, 153, 0)
                  : Colors.transparent,
          height: 44,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10.0,
              // vertical: 13,
            ),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    spacing: 10,
                    mainAxisAlignment:
                        MainAxisAlignment.start,
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
                                      returnNavProvider(
                                                context,
                                              ).currentIndex ==
                                              itemIndex
                                          ? Colors
                                              .grey
                                              .shade900
                                          : color ??
                                              Colors
                                                  .grey
                                                  .shade600,
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
                                      returnNavProvider(
                                                context,
                                              ).currentIndex ==
                                              itemIndex
                                          ? Colors
                                              .grey
                                              .shade900
                                          : color ??
                                              Colors
                                                  .grey
                                                  .shade600,
                                  svg ?? '',
                                  height: height,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      Expanded(
                        child: Text(
                          style: TextStyle(
                            color:
                                color ??
                                Colors.grey.shade900,
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b3
                                    .fontSize,
                            fontWeight:
                                returnNavProvider(
                                          context,
                                        ).currentIndex ==
                                        itemIndex
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                          ),
                          title,
                        ),
                      ),
                    ],
                  ),
                ),
                Stack(
                  children: [
                    Visibility(
                      visible: endWidget == null,
                      child: Stack(
                        children: [
                          Visibility(
                            visible:
                                returnNavProvider(
                                  context,
                                ).currentIndex !=
                                itemIndex,
                            child: Icon(
                              color: Colors.grey.shade600,
                              size: 12,
                              Icons
                                  .arrow_forward_ios_rounded,
                            ),
                          ),
                          Visibility(
                            visible:
                                returnNavProvider(
                                  context,
                                ).currentIndex ==
                                itemIndex,
                            child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(
                                    0,
                                    5,
                                    3,
                                    5,
                                  ),
                              child: Container(
                                width: 4,
                                decoration: BoxDecoration(
                                  color:
                                      theme
                                          .lightModeColor
                                          .secColor200,
                                  borderRadius:
                                      BorderRadius.circular(
                                        20,
                                      ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: endWidget != null,
                      child: endWidget ?? Container(),
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
