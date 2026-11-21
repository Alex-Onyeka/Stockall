import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stockall/classes/temp_notification/temp_notification.dart';
import 'package:stockall/components/major/drawer_widget/drawer_nav_items.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/theme_provider.dart';

class MyDrawerWidgetMobile extends StatefulWidget {
  final ThemeProvider theme;
  final Function()? action;
  final List<TempNotification> notifications;
  const MyDrawerWidgetMobile({
    super.key,
    required this.theme,
    required this.notifications,
    required this.action,
  });

  @override
  State<MyDrawerWidgetMobile> createState() =>
      _MyDrawerWidgetMobileState();
}

class _MyDrawerWidgetMobileState
    extends State<MyDrawerWidgetMobile> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 5.0,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 5.0,
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
                        spacing: 10,
                        mainAxisAlignment:
                            MainAxisAlignment.start,
                        children: [
                          Image.asset(
                            mainLogoIcon,
                            height: 22,
                          ),
                          Expanded(
                            child: Text(
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
                          ),
                          InkWell(
                            mouseCursor:
                                SystemMouseCursors.click,
                            onTap: () {
                              if (Scaffold.maybeOf(
                                    context,
                                  )?.isDrawerOpen ==
                                  true) {
                                Scaffold.of(
                                  context,
                                ).closeDrawer();
                              } else if (Navigator.of(
                                context,
                              ).canPop()) {
                                Navigator.of(context).pop();
                              }
                            },
                            child: Padding(
                              padding:
                                  EdgeInsetsGeometry.all(
                                    10,
                                  ),
                              child: Icon(
                                size: 18,
                                Icons.clear,
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
                              mode: DrawerMode.mobile,
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
                                return NavListTileAlt(
                                  height: height,
                                  action: action,
                                  title: title,
                                  icon: icon,
                                  svg: svg,
                                );
                              },
                            ),
                            const SizedBox(height: 30),
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
                      child: NavListTileAlt(
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
    var theme = returnTheme(context);
    return InkWell(
      mouseCursor: SystemMouseCursors.click,
      onTap: () {
        Navigator.of(context).pop();
        action!();
      },
      child: SizedBox(
        height: 42,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20.0,
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

                    Expanded(
                      child: Text(
                        style: TextStyle(
                          color:
                              color ?? Colors.grey.shade900,
                          fontSize:
                              theme.mobileTexts.b3.fontSize,
                          fontWeight: FontWeight.w500,
                        ),
                        title,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                color: Colors.grey.shade600,
                size: 14,
                Icons.arrow_forward_ios_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
