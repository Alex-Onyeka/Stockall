import 'package:flutter/material.dart';
import 'package:stockall/components/major/desktop_center_container.dart';
import 'package:stockall/components/major/drawer_widget/platforms/my_drawer_widget_desktop.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/customers/customer_settings/components/set_customer_reward_percent.dart';
import 'package:stockall/pages/customers/customer_settings/components/toggle_manage_customer_account.dart';
import 'package:stockall/pages/customers/customer_settings/components/toggle_manage_customer_reward.dart';

class CustomerSettingsPageDesktop extends StatefulWidget {
  const CustomerSettingsPageDesktop({super.key});

  @override
  State<CustomerSettingsPageDesktop> createState() =>
      _CustomerSettingsPageDesktopState();
}

class _CustomerSettingsPageDesktopState
    extends State<CustomerSettingsPageDesktop> {
  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return DesktopCenterContainer(
      mainWidget: Column(
        children: [
          SizedBox(height: 10),
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                mouseCursor: SystemMouseCursors.click,
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
              Expanded(
                child: Column(
                  spacing: 8,
                  children: [
                    Text(
                      style: TextStyle(
                        color:
                            theme
                                .lightModeColor
                                .shadesColorBlack,
                        fontSize:
                            theme.mobileTexts.h4.fontSize,
                        fontWeight:
                            theme
                                .mobileTexts
                                .h3
                                .fontWeightBold,
                      ),
                      'Customer Settings',
                    ),
                    Text(
                      style:
                          theme
                              .mobileTexts
                              .b3
                              .textStyleNormal,
                      "Manage Your Customer Settings.",
                    ),
                  ],
                ),
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
          SizedBox(height: 10),
          Expanded(
            child: SingleChildScrollView(
              child: Material(
                color: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5.0,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Column(
                        // spacing: 10,
                        children: [
                          ToggleManageCustomerReward(),
                          ToggleManageCustomerAccount(),
                          SetCustomerRewardPercent(),
                          Visibility(
                            visible: authorization(
                              authorized:
                                  Authorizations()
                                      .contactStockall,
                            ),
                            child: NavListTileDesktopAlt(
                              height: 18,
                              action: () async {
                                phoneCall();
                              },
                              title:
                                  'Call Us (+234 704 850 7587)',
                              icon: Icons.phone,
                            ),
                          ),
                          Visibility(
                            visible: authorization(
                              authorized:
                                  Authorizations()
                                      .contactStockall,
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
                            height: 20,
                            action: () async {
                              await launchUrlMain(
                                "https://stockallsolution.com/help-center",
                              );
                            },
                            title: 'Visit Help Center',
                            icon: Icons.people_alt_outlined,
                          ),
                          NavListTileDesktopAlt(
                            height: 18,
                            action: () async {
                              await launchUrlMain(
                                "https://stockallsolution.com/privacy-policy",
                              );
                            },
                            title: 'Privacy P. & Terms/C.',
                            icon: Icons.menu_book_rounded,
                          ),
                          NavListTileDesktopAlt(
                            height: 18,
                            action: () async {
                              await launchUrlMain(
                                "https://stockallsolution.com",
                              );
                            },
                            title: 'Go to Website.',
                            icon: Icons.language_rounded,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: screenHeight(context) * 0.2,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 15),
          Container(
            color: Colors.transparent,
            height: 20,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
              ),
              child: Row(
                spacing: 10,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    spacing: 10,
                    mainAxisAlignment:
                        MainAxisAlignment.start,
                    children: [
                      // SizedBox(
                      //   width: 20,
                      //   child: Center(),
                      // ),
                      Text(
                        style: TextStyle(
                          color: Colors.grey.shade900,
                          fontSize:
                              theme.mobileTexts.b4.fontSize,
                          fontStyle: FontStyle.italic,
                        ),
                        'Current Version:',
                      ),
                    ],
                  ),
                  Text(
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.b4.fontSize,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.bold,
                    ),
                    appVersionDesktop.toString(),
                    // returnData(
                    //   context,
                    // ).allowedRangeItems.toString(),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
