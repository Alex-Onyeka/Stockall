import 'package:flutter/material.dart';
import 'package:stockall/components/major/drawer_widget/platforms/my_drawer_widget_desktop.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/production/settings/components/toggle_manage_productions_storage.dart';

class ProductionSettingsPageMobile extends StatefulWidget {
  const ProductionSettingsPageMobile({super.key});

  @override
  State<ProductionSettingsPageMobile> createState() =>
      _ProductionSettingsPageMobileState();
}

class _ProductionSettingsPageMobileState
    extends State<ProductionSettingsPageMobile> {
  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Scaffold(
      appBar: appBar(
        context: context,
        title: 'Production Settings',
        backAction: () {
          Navigator.of(context).pop();
        },
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 25.0,
          ),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  // spacing: 10,
                  children: [
                    ToggleManageProductionsStorage(),
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
                    mainAxisAlignment:
                        MainAxisAlignment.center,
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
                                  theme
                                      .mobileTexts
                                      .b4
                                      .fontSize,
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
                        appVersionMobile.toString(),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              // SizedBox(
              //   height: screenHeight(context) * 0.2,
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
