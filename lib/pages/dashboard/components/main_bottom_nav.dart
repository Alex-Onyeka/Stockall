import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:stockitt/constants/constants_main.dart';
import 'package:stockitt/main.dart';
import 'package:stockitt/pages/dashboard/components/nav_button.dart';
import 'package:stockitt/pages/sales/make_sales/page1/make_sales_page.dart';
import 'package:stockitt/providers/nav_provider.dart';

class MainBottomNav extends StatelessWidget {
  final GlobalKey<ScaffoldState> globalKey;
  final Function()? action;
  const MainBottomNav({
    super.key,
    required this.globalKey,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment(-0.03, -2),
      children: [
        Container(
          height: 80,
          color: Colors.white,
          padding: EdgeInsets.fromLTRB(40, 10, 40, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              NavButton(
                currentPage:
                    Provider.of<NavProvider>(
                      context,
                    ).currentPage,
                index: 0,
                icon: Icons.home_filled,
                title: 'Home',
              ),
              Expanded(
                child: NavButton(
                  currentPage:
                      Provider.of<NavProvider>(
                        context,
                      ).currentPage,
                  index: 1,
                  icon: Icons.book,
                  title: 'Products',
                ),
              ),
              SizedBox(width: 60),
              Expanded(
                child: NavButton(
                  currentPage:
                      Provider.of<NavProvider>(
                        context,
                      ).currentPage,
                  index: 2,
                  icon: Icons.menu_book_rounded,
                  title: 'Sales',
                ),
              ),
              InkWell(
                onTap: () {
                  Provider.of<NavProvider>(
                    context,
                    listen: false,
                  ).setSettings();
                  globalKey.currentState?.openDrawer();
                },
                child: SizedBox(
                  height: 42,
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        color:
                            returnNavProvider(
                                  context,
                                ).settingNow
                                ? const Color.fromARGB(
                                  255,
                                  4,
                                  49,
                                  199,
                                )
                                : Colors.grey,
                        size:
                            returnNavProvider(
                                  context,
                                ).settingNow
                                ? 22
                                : 18,
                        Icons.settings,
                      ),
                      Text(
                        style: TextStyle(
                          color:
                              returnNavProvider(
                                    context,
                                  ).settingNow
                                  ? const Color.fromARGB(
                                    255,
                                    4,
                                    49,
                                    199,
                                  )
                                  : Colors.grey,
                          fontSize:
                              returnNavProvider(
                                    context,
                                  ).settingNow
                                  ? 13
                                  : 12,
                          fontWeight:
                              returnNavProvider(
                                    context,
                                  ).settingNow
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                        ),
                        'Settings',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        InkWell(
          onTap: () {
            if (returnNavProvider(
                  context,
                  listen: false,
                ).currentPage ==
                1) {
              action!();
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return MakeSalesPage();
                  },
                ),
              );
            }
          },
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color:
                      returnNavProvider(
                                context,
                              ).currentPage ==
                              1
                          ? const Color.fromARGB(0, 0, 0, 0)
                          : const Color.fromARGB(
                            55,
                            0,
                            0,
                            0,
                          ),
                  blurRadius: 5,
                  offset: Offset(0, -1),
                ),
              ],
              border: Border.all(
                color:
                    returnTheme(
                      context,
                    ).lightModeColor.prColor300,
              ),
            ),
            child: Stack(
              alignment: Alignment(0, 0),
              children: [
                SvgPicture.asset(
                  makeSalesIconSvg,
                  color:
                      returnNavProvider(
                                context,
                              ).currentPage ==
                              1
                          ? Colors.white
                          : null,
                ),
                Visibility(
                  visible:
                      returnNavProvider(
                        context,
                      ).currentPage ==
                      1,
                  child: SvgPicture.asset(
                    plusIconSvg,
                    height: 23,
                    color:
                        returnTheme(
                          context,
                        ).lightModeColor.prColor300,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
