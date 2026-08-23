import 'package:flutter/material.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/dialog_template.dart';
import 'package:stockall/components/major/drawer_widget/platforms/my_drawer_widget_desktop.dart';
import 'package:stockall/components/text_fields/edit_cart_text_field.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/subscription/general_settings_auth.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/theme_provider.dart';

class SetCustomerRewardPercent extends StatefulWidget {
  const SetCustomerRewardPercent({super.key});

  @override
  State<SetCustomerRewardPercent> createState() =>
      _SetCustomerRewardPercentState();
}

class _SetCustomerRewardPercentState
    extends State<SetCustomerRewardPercent> {
  final percentController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Visibility(
      visible:
          returnShopProvider(
                context: context,
              ).userShop()?.manageCustomerReward ==
              true &&
          GeneralSettingsAuthAction()
              .manageCustomersAccountAndPoints(
                context: null,
              ) &&
          authorization(
            authorized:
                Authorizations()
                    .toggleManageCustomersReward,
          ),
      child: NavListTileDesktopAlt(
        height: 18,
        action: () async {
          showDialog(
            context: context,
            builder: (context) {
              return DialogTemplate(
                theme: theme,
                message:
                    'Set the General Cashback Reward percent for customers.',
                title: 'Reward Percent',
                action: () {
                  setRewardPercentAction(theme: theme);
                },
                widget: Column(
                  children: [
                    Divider(),
                    SizedBox(height: 3),
                    Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 15,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(
                          5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        spacing: 5,
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
                            'Current Percent:',
                          ),
                          Text(
                            style: TextStyle(
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b4
                                      .fontSize,
                              fontWeight: FontWeight.bold,
                              color:
                                  theme
                                      .lightModeColor
                                      .secColor200,
                            ),
                            "${formatLargeNumberDouble(returnShopProvider(context: context).userShop()?.customerPercentageReward ?? 0)}%",
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 5),
                    EditCartTextField(
                      title: '',
                      hint: 'Enter Percent',
                      controller: percentController,
                      theme: theme,
                      autoFocus: true,
                      showTitle: false,
                      onSubmitted: (p0) {},
                    ),
                  ],
                ),
              );
            },
          );
        },
        title: 'Reward Percent',
        endWidget: Row(
          spacing: 5,
          children: [
            Text(
              style: TextStyle(
                fontSize: theme.mobileTexts.b3.fontSize,
                fontWeight: FontWeight.bold,
              ),
              "${formatLargeNumberDouble(returnShopProvider(context: context).userShop()?.customerPercentageReward ?? 0)}%",
            ),
            Icon(
              size: 13,
              color: Colors.grey,
              Icons.arrow_forward_ios_rounded,
            ),
          ],
        ),
        icon: Icons.wallet_giftcard_outlined,
      ),
    );
  }

  void setRewardPercentAction({
    required ThemeProvider theme,
  }) {
    showDialog(
      context: context,
      builder: (confirmDialog) {
        return ConfirmationAlert(
          theme: theme,
          message:
              'You are about to set the general reward percent for customers. Are you sure you want to proceed?',
          title: 'Proceed',
          action: () {
            Navigator.of(confirmDialog).pop();
            Navigator.of(context).pop();
            returnShopProvider()
                .setCustomersRewardPercentAction(
                  amount:
                      double.tryParse(
                        percentController.text.replaceAll(
                          ',',
                          '',
                        ),
                      ) ??
                      0,
                );
          },
        );
      },
    );
  }
}
