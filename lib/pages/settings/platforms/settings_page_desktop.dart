import 'package:flutter/material.dart';
import 'package:stockall/components/major/desktop_center_container.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/dashboard/components/contact_us_float_widget.dart';
import 'package:stockall/pages/settings/components/settings_items_list.dart';

class SettingsPageDesktop extends StatefulWidget {
  const SettingsPageDesktop({super.key});

  @override
  State<SettingsPageDesktop> createState() =>
      _SettingsPageDesktopState();
}

class _SettingsPageDesktopState
    extends State<SettingsPageDesktop> {
  final passwordController = TextEditingController();
  final productSearch = TextEditingController();
  final discountPercentController = TextEditingController();
  bool isLoading = false;
  bool success = false;
  // bool isDiscountLoading = false;
  bool isChangePlanLoading = false;
  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Stack(
      children: [
        DesktopCenterContainer(
          mainWidget: Column(
            children: [
              SizedBox(height: 10),
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
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
                                theme
                                    .mobileTexts
                                    .h4
                                    .fontSize,
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
                                  .b3
                                  .textStyleNormal,
                          "Manage Your Shop, Account and General Settings.",
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      right: 10.0,
                    ),
                    child: Material(
                      type: MaterialType.transparency,
                      child: InkWell(
                        mouseCursor:
                            SystemMouseCursors.click,
                        onTap: () {
                          contactUsAction(context: context);
                        },
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            5,
                            6,
                            5,
                            6,
                          ),
                          child: Row(
                            spacing: 3,
                            children: [
                              Text(
                                style: TextStyle(
                                  fontSize:
                                      theme
                                          .mobileTexts
                                          .b4
                                          .fontSize,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                                'Contact',
                              ),
                              Icon(
                                color: Colors.grey,
                                size: 16,
                                Icons.phone,
                              ),
                            ],
                          ),
                        ),
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
                          SettingsItemsList(
                            passwordController:
                                passwordController,
                            productSearch: productSearch,
                            discountPercentController:
                                discountPercentController,
                            isDesktop: true,
                            onLoadingChanged: (v) {
                              if (mounted)
                                setState(
                                  () => isLoading = v,
                                );
                            },
                            onChangePlanLoadingChanged: (
                              v,
                            ) {
                              if (mounted)
                                setState(
                                  () =>
                                      isChangePlanLoading =
                                          v,
                                );
                            },
                          ),
                          SizedBox(
                            height:
                                screenHeight(context) * 0.2,
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
        ),
        Visibility(
          visible: isLoading,
          child: returnCompProvider(
            context,
            listen: false,
          ).showLoader(message: 'Deleting Store'),
        ),
      ],
    );
  }
}
