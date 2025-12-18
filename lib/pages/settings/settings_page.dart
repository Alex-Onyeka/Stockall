import 'package:flutter/material.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/dialog_template.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/settings/platforms/settings_page_desktop.dart';
import 'package:stockall/pages/settings/platforms/settings_page_mobile.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= mobileScreen) {
          return SettingsPageMobile();
        } else {
          return SettingsPageDesktop();
        }
      },
    );
  }
}

Future<dynamic> setStoreAsHeadquarters(
  BuildContext context,
) {
  bool isUpdating = false;
  var theme = returnTheme(context, listen: false);
  return showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return DialogTemplate(
            actionButtonText: 'Save',
            // showBottomActionButtons: false,
            theme: theme,
            message:
                'Select One Of Your Stores to Set as your head quarter',
            title: 'Select Head Quarter',
            action: () {
              Navigator.of(context).pop();
            },
            widget: SizedBox(
              height: screenHeight(context) - 350,
              width: screenWidth(context) - 10,
              child: ListView(
                scrollDirection: Axis.vertical,
                children:
                    returnShopProvider(
                      context,
                      listen: false,
                    ).userShops.map((shop) {
                      bool isLoadingg = false;
                      return StatefulBuilder(
                        builder:
                            (context, setState) => ListTile(
                              shape: Border(
                                bottom: BorderSide(
                                  color:
                                      Colors.grey.shade100,
                                ),
                              ),
                              title: Row(
                                spacing: 10,
                                children: [
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                style: TextStyle(
                                                  fontSize:
                                                      theme
                                                          .mobileTexts
                                                          .b3
                                                          .fontSize,
                                                  fontWeight:
                                                      FontWeight
                                                          .bold,
                                                ),
                                                shop.name,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Visibility(
                                          visible:
                                              shop.isHeadQuarters!,
                                          child: Row(
                                            children: [
                                              Text(
                                                style: TextStyle(
                                                  color:
                                                      theme
                                                          .lightModeColor
                                                          .secColor200,
                                                  fontSize:
                                                      8,
                                                  // fontStyle:
                                                  //     FontStyle
                                                  //         .italic,
                                                  fontWeight:
                                                      FontWeight
                                                          .bold,
                                                ),
                                                "(Head Quarter)",
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Stack(
                                    children: [
                                      Visibility(
                                        visible:
                                            shop.isHeadQuarters!,
                                        child: Icon(
                                          size: 18,
                                          color:
                                              theme
                                                  .lightModeColor
                                                  .secColor200,
                                          Icons.check,
                                        ),
                                      ),
                                      Visibility(
                                        visible: isLoadingg,
                                        child: SizedBox(
                                          height: 16,
                                          width: 16,
                                          child: CircularProgressIndicator(
                                            color:
                                                theme
                                                    .lightModeColor
                                                    .secColor100,
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              onTap: () async {
                                if (!shop.isHeadQuarters! &&
                                    isUpdating == false) {
                                  showDialog(
                                    context: context,
                                    builder: (
                                      confirmDialog,
                                    ) {
                                      return ConfirmationAlert(
                                        theme: theme,
                                        message:
                                            'Are you sure you want to set this as your head quarter?',
                                        title:
                                            'Are you sure?',
                                        action: () async {
                                          Navigator.of(
                                            confirmDialog,
                                          ).pop();
                                          setState(() {
                                            isLoadingg =
                                                !isLoadingg;
                                            isUpdating =
                                                true;
                                          });
                                          await returnShopProvider(
                                            context,
                                            listen: false,
                                          ).setHeadQuarters(
                                            shop,
                                          );
                                          setState(() {
                                            isUpdating =
                                                false;
                                            // isLoadingg =
                                            //     false;
                                          });
                                          if (!context
                                              .mounted) {
                                            return;
                                          }
                                          Navigator.of(
                                            context,
                                          ).pop();
                                        },
                                      );
                                    },
                                  );
                                }
                              },
                            ),
                      );
                    }).toList(),
              ),
            ),
          );
        },
      );
    },
  );
}
