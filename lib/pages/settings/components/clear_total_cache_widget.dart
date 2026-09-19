import 'package:flutter/material.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/dialog_template.dart';
import 'package:stockall/components/major/drawer_widget/platforms/my_drawer_widget_desktop.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';

class ClearTotalCacheWidget extends StatelessWidget {
  const ClearTotalCacheWidget({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Visibility(
      visible: returnData(context: context).isSynced() == 0,
      child: NavListTileDesktopAlt(
        height: 18,
        action: () {
          showDialog(
            context: context,
            builder: (firstContext) {
              return DialogTemplate(
                theme: theme,
                message:
                    'View All The Records That have not been Synchronized to the Cloud',
                title: 'Unsynced Local Records',
                actionButtonText: 'Clear Local Records?',
                action: () {
                  if (authorization(
                    authorized: Authorizations().clearCache,
                  )) {
                    showDialog(
                      context: context,
                      builder: (confirmDialog) {
                        return ConfirmationAlert(
                          theme: theme,
                          message:
                              'You are about to Clear Your entire Locally Stored Data. You will loose all the data Business Records that has not been backed up in the cloud. This Action can not be reversed. Are you sure you want to proceed?',
                          title: 'Clear Local Records?',
                          action: () async {
                            Navigator.of(
                              confirmDialog,
                            ).pop();
                            await returnData()
                                .clearTotalCache();
                            Navigator.of(
                              // ignore: use_build_context_synchronously
                              firstContext,
                            ).pop();
                          },
                        );
                      },
                    );
                  }
                },
                widget: SizedBox(
                  height: screenHeight(context) - 230,
                  child: Column(
                    children: [
                      Divider(color: Colors.grey.shade300),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            spacing: 5,
                            children:
                                returnData().unsyncedItems().map((
                                  item,
                                ) {
                                  return Padding(
                                    padding:
                                        EdgeInsetsGeometry.symmetric(
                                          vertical: 10,
                                          horizontal: 10,
                                        ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                      spacing: 5,
                                      children: [
                                        Row(
                                          spacing: 5,
                                          children: [
                                            Container(
                                              padding:
                                                  EdgeInsets.all(
                                                    3,
                                                  ),
                                              decoration: BoxDecoration(
                                                shape:
                                                    BoxShape
                                                        .circle,
                                                color:
                                                    Colors
                                                        .grey,
                                              ),
                                            ),
                                            Text(
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
                                              item.name,
                                            ),
                                          ],
                                        ),
                                        Text(
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
                                          'Qtty: ${formatLargeNumberDouble(item.quantity)}',
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        title: 'View Unsynced Records',
        color: Colors.red,
        icon: Icons.receipt_long_sharp,
      ),
    );
  }
}

class UnsyncedItems {
  final String name;
  final double quantity;

  UnsyncedItems({
    required this.name,
    required this.quantity,
  });
}
