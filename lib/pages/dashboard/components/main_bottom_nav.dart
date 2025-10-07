import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/dashboard/components/nav_button.dart';
import 'package:stockall/pages/sales/make_sales/page1/make_sales_page.dart';
import 'package:stockall/providers/nav_provider.dart';

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
          height: 100,
          color: Colors.white,
          padding: EdgeInsets.fromLTRB(20, 10, 20, 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: NavButton(
                  currentPage:
                      Provider.of<NavProvider>(
                        context,
                      ).currentPage,
                  index: 0,
                  icon: Icons.home_filled,
                  title: 'Home',
                ),
              ),
              Expanded(
                child: NavButton(
                  currentPage:
                      Provider.of<NavProvider>(
                        context,
                      ).currentPage,
                  index: 1,
                  icon: Icons.book,
                  title: 'Items',
                ),
              ),
              SizedBox(width: 90),
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
              Expanded(
                child: InkWell(
                  onTap: () {
                    if (context.mounted) {
                      Provider.of<NavProvider>(
                        context,
                        listen: false,
                      ).setSettings();
                      returnReceiptProvider(
                        context,
                        listen: false,
                      ).clearReceiptDate();
                      globalKey.currentState?.openDrawer();
                    } else {
                      print('Context not mounted');
                    }
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
              if (!authorization(
                authorized: Authorizations().addProduct,
                context: context,
              )) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return MakeSalesPage();
                    },
                  ),
                );
              } else {
                action!();
              }
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
            if (context.mounted) {
              returnReceiptProvider(
                context,
                listen: false,
              ).clearReceiptDate();
            } else {
              print("Context not Mounted");
            }
          },
          child: Stack(
            children: [
              Visibility(
                visible:
                    returnNavProvider(
                          context,
                          listen: false,
                        ).currentPage ==
                        1 &&
                    authorization(
                      authorized:
                          Authorizations().addProduct,
                      context: context,
                    ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [],
                        border: Border.all(
                          color:
                              returnTheme(
                                context,
                              ).lightModeColor.prColor300,
                        ),
                      ),
                      child: SvgPicture.asset(
                        plusIconSvg,
                        height: 23,
                        color:
                            returnTheme(
                              context,
                            ).lightModeColor.prColor300,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      style: TextStyle(
                        color: const Color.fromARGB(
                          255,
                          4,
                          49,
                          199,
                        ),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      'Add Item',
                    ),
                    SizedBox(height: 5),
                  ],
                ),
              ),
              Visibility(
                visible:
                    returnNavProvider(
                          context,
                          listen: false,
                        ).currentPage !=
                        1 ||
                    !authorization(
                      authorized:
                          Authorizations().addProduct,
                      context: context,
                    ),
                child: Column(
                  spacing: 3,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(makeSalesIconSvg),
                    Text(
                      style: TextStyle(
                        color: const Color.fromARGB(
                          255,
                          4,
                          49,
                          199,
                        ),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      'Make Sale',
                    ),
                    SizedBox(height: 5),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
