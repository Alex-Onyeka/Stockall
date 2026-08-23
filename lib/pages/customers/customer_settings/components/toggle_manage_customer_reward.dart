import 'package:flutter/material.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/major/drawer_widget/platforms/my_drawer_widget_desktop.dart';
import 'package:stockall/components/toggle_button/my_toggle_button.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/subscription/general_settings_auth.dart';
import 'package:stockall/constants/subscription/subscription_func.dart';
import 'package:stockall/main.dart';

class ToggleManageCustomerReward extends StatelessWidget {
  const ToggleManageCustomerReward({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Visibility(
      visible:
          authorization(
            authorized:
                Authorizations()
                    .toggleManageCustomersReward,
          ) &&
          !isStoreKeeper(),
      child: SubWrapper(
        isVisible:
            !GeneralSettingsAuthAction()
                .manageCustomersAccountAndPoints(
                  context: context,
                ),
        mainWidget: NavListTileDesktopAlt(
          height: 18,
          action: () {
            GeneralSettingsAuthAction().manageCustomersAccountAndPoints(
              context: context,
              action: () {
                var shopProvider = returnShopProvider();
                showDialog(
                  context: context,
                  builder: (context) {
                    return ConfirmationAlert(
                      theme: theme,
                      message:
                          shopProvider
                                      .userShop()!
                                      .manageCustomerReward ??
                                  true
                              ? 'You can no longer manage your Customer Rewards, are you sure you want to proceed?'
                              : 'You can now manage your Customer Rewards, are you sure you want to proceed?',
                      title:
                          shopProvider
                                      .userShop()!
                                      .manageCustomerReward ??
                                  true
                              ? 'Turn Off Customer Rewards'
                              : 'Turn On Customer Rewards',
                      action: () async {
                        Navigator.of(context).pop();
                        shopProvider
                            .toggleManageCustomerReward();
                      },
                    );
                  },
                );
              },
            );
          },
          endWidget: Builder(
            builder: (context) {
              if (returnShopProvider(
                context: context,
              ).manageCustomerReward) {
                return SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                    color: theme.lightModeColor.secColor200,
                    strokeWidth: 2,
                  ),
                );
              } else {
                return MyToggleButton(
                  isSmall: true,
                  boolValue:
                      returnShopProvider(
                        context: context,
                      ).userShop()?.manageCustomerReward ??
                      true,
                  toggle: () {
                    GeneralSettingsAuthAction().manageCustomersAccountAndPoints(
                      context: context,
                      action: () {
                        var shopProvider =
                            returnShopProvider();
                        showDialog(
                          context: context,
                          builder: (context) {
                            return ConfirmationAlert(
                              theme: theme,
                              message:
                                  shopProvider
                                              .userShop()!
                                              .manageCustomerReward ??
                                          true
                                      ? 'You can no longer manage your Customer Rewards, are you sure you want to proceed?'
                                      : 'You can now manage your Customer Rewards, are you sure you want to proceed?',
                              title:
                                  shopProvider
                                              .userShop()!
                                              .manageCustomerReward ??
                                          true
                                      ? 'Turn Off Customer Rewards'
                                      : 'Turn On Customer Rewards',
                              action: () async {
                                Navigator.of(context).pop();
                                shopProvider
                                    .toggleManageCustomerReward();
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                  theme: theme,
                );
              }
            },
          ),
          title: 'Manage Customer Rewards',
          icon: Icons.api_rounded,
        ),
      ),
    );
  }
}
