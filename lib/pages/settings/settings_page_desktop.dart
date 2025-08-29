import 'package:flutter/material.dart';
import 'package:stockall/components/major/desktop_center_container.dart';
import 'package:stockall/components/major/drawer_widget/platforms/my_drawer_widget_desktop.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/profile/profile_page.dart';
import 'package:stockall/pages/shop_setup/shop_page/shop_page.dart';

class SettingsPageDesktop extends StatelessWidget {
  const SettingsPageDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return DesktopCenterContainer(
      mainWidget: SingleChildScrollView(
        child: Material(
          color: Colors.transparent,
          child: Column(
            children: [
              SizedBox(height: 5),
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 15,
                      ),
                      child: Icon(
                        color: Colors.grey,
                        size: 20,
                        Icons.arrow_back_ios_new_rounded,
                      ),
                    ),
                  ),
                  Column(
                    spacing: 8,
                    children: [
                      Text(
                        style: TextStyle(
                          color:
                              theme
                                  .lightModeColor
                                  .shadesColorBlack,
                          fontSize:
                              theme.mobileTexts.h3.fontSize,
                          fontWeight:
                              theme
                                  .mobileTexts
                                  .h3
                                  .fontWeightBold,
                        ),
                        'Settings',
                      ),
                      Text(
                        style:
                            theme
                                .mobileTexts
                                .b1
                                .textStyleNormal,
                        "Manage Your Shop, Account and General Settings.",
                      ),
                    ],
                  ),
                  Opacity(
                    opacity: 0,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 15,
                      ),
                      child: Icon(
                        color: Colors.grey,
                        size: 20,
                        Icons.arrow_back_ios_new_rounded,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              Column(
                spacing: 15,
                children: [
                  NavListTileDesktopAlt(
                    title: 'Account',
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
                    height: 18,
                    icon: Icons.person,
                  ),
                  Visibility(
                    visible: authorization(
                      authorized:
                          Authorizations().manageShop,
                      context: context,
                    ),
                    child: NavListTileDesktopAlt(
                      height: 18,
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
                  Visibility(
                    visible: authorization(
                      authorized:
                          Authorizations().contactStockall,
                      context: context,
                    ),
                    child: NavListTileDesktopAlt(
                      height: 18,
                      action: () async {
                        phoneCall();
                      },
                      title: 'Contact Us',
                      icon: Icons.phone,
                    ),
                  ),
                  Visibility(
                    visible: authorization(
                      authorized:
                          Authorizations().contactStockall,
                      context: context,
                    ),
                    child: NavListTileDesktopAlt(
                      height: 14,
                      action: () async {
                        openWhatsApp();
                      },
                      title: 'Chat With Us',
                      svg: whatsappIconSvg,
                    ),
                  ),
                  NavListTileDesktopAlt(
                    height: 18,
                    action: () {},
                    title: 'Privacy P. & Terms/C.',
                    icon: Icons.menu_book_rounded,
                  ),
                ],
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
