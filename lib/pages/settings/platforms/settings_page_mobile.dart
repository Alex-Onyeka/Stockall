import 'package:flutter/material.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/dashboard/components/contact_us_float_widget.dart';
import 'package:stockall/pages/settings/components/settings_items_list.dart';

class SettingsPageMobile extends StatefulWidget {
  const SettingsPageMobile({super.key});

  @override
  State<SettingsPageMobile> createState() =>
      _SettingsPageMobileState();
}

class _SettingsPageMobileState
    extends State<SettingsPageMobile> {
  final passwordController = TextEditingController();
  final productSearch = TextEditingController();
  final discountPercentController = TextEditingController();
  bool isLoading = false;
  bool isChangePlanLoading = false;
  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Stack(
      children: [
        Scaffold(
          appBar: appBar(
            context: context,
            title: 'Settings',
            backAction: () {
              Navigator.of(context).pop();
            },
            widget: Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(
                  mouseCursor: SystemMouseCursors.click,
                  onTap: () {
                    contactUsAction(context: context);
                  },
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      10,
                      6,
                      10,
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
                            fontWeight: FontWeight.bold,
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
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 25.0,
              ),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: SettingsItemsList(
                        passwordController:
                            passwordController,
                        productSearch: productSearch,
                        discountPercentController:
                            discountPercentController,
                        isDesktop: false,
                        onLoadingChanged: (v) {
                          if (mounted) {
                            setState(() => isLoading = v);
                          }
                        },
                        onChangePlanLoadingChanged: (v) {
                          if (mounted) {
                            setState(
                              () => isChangePlanLoading = v,
                            );
                          }
                        },
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
                                  color:
                                      Colors.grey.shade900,
                                  fontSize:
                                      theme
                                          .mobileTexts
                                          .b4
                                          .fontSize,
                                  fontStyle:
                                      FontStyle.italic,
                                ),
                                'Current Version:',
                              ),
                            ],
                          ),
                          Text(
                            style: TextStyle(
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b4
                                      .fontSize,
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
