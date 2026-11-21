import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stockall/classes/temp_notification/temp_notification.dart';
import 'package:stockall/components/major/drawer_widget/drawer_nav_items.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/theme_provider.dart';

class MyDrawerWidgetTablet extends StatefulWidget {
  final GlobalKey<ScaffoldState> globalKey;
  final ThemeProvider theme;
  final Function()? action;
  final List<TempNotification> notifications;
  const MyDrawerWidgetTablet({
    super.key,
    required this.theme,
    required this.notifications,
    required this.action,
    required this.globalKey,
  });

  @override
  State<MyDrawerWidgetTablet> createState() =>
      _MyDrawerWidgetTabletState();
}

class _MyDrawerWidgetTabletState
    extends State<MyDrawerWidgetTablet> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 90,
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
                        child: InkWell(
                          mouseCursor:
                              SystemMouseCursors.click,
                          onTap: () {
                            widget.globalKey.currentState
                                ?.openDrawer();
                          },
                          child: Container(
                            color: Colors.white,
                            child: Row(
                              spacing: 2,
                              mainAxisAlignment:
                                  screenWidth(context) <
                                          tabletScreenSmall
                                      ? MainAxisAlignment
                                          .spaceBetween
                                      : MainAxisAlignment
                                          .start,
                              children: [
                                Image.asset(
                                  mainLogoIcon,
                                  height: 18,
                                ),
                                Icon(
                                  size: 20,
                                  color: Colors.grey,
                                  Icons
                                      .arrow_forward_ios_rounded,
                                ),
                              ],
                            ),
                          ),
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
                                mode: DrawerMode.tablet,
                                theme: widget.theme,
                                notifications:
                                    widget.notifications,
                                isHovered: false,
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
                                  return NavListTileTablet(
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
                        child: NavListTileTablet(
                          height: 18,
                          action: widget.action,
                          title: 'Logout',
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

class NavListTileTablet extends StatelessWidget {
  final String title;
  final int? itemIndex;
  final IconData? icon;
  final String? svg;
  final Function()? action;
  final double height;
  final Color? color;
  const NavListTileTablet({
    super.key,
    required this.title,
    this.icon,
    required this.action,
    this.svg,
    required this.height,
    this.color,
    this.itemIndex,
  });

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return InkWell(
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
        height: 38,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10.0,
          ),
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Row(
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
                                  returnNavProvider(
                                            context,
                                          ).currentIndex ==
                                          itemIndex
                                      ? Colors.grey.shade900
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
                                      ? Colors.grey.shade900
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
                ],
              ),
              Visibility(
                visible:
                    returnNavProvider(
                      context,
                    ).currentIndex ==
                    itemIndex,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    0,
                    5,
                    3,
                    5,
                  ),
                  child: Container(
                    width: 4,
                    decoration: BoxDecoration(
                      color:
                          theme.lightModeColor.secColor200,
                      borderRadius: BorderRadius.circular(
                        20,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
