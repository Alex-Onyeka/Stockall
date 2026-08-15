import 'package:flutter/material.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/major/drawer_widget/platforms/my_drawer_widget_desktop.dart';
import 'package:stockall/components/toggle_button/my_toggle_button.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/subscription/general_settings_auth.dart';
import 'package:stockall/constants/subscription/subscription_func.dart';
import 'package:stockall/main.dart';

class ToggleManageProductionItems extends StatelessWidget {
  const ToggleManageProductionItems({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Visibility(
      visible:
          authorization(
            authorized:
                Authorizations()
                    .toggleManageProductionItems,
          ) &&
          !isStoreKeeper(),
      child: SubWrapper(
        isVisible:
            !GeneralSettingsAuthAction().manageProductions(
              context: context,
            ),
        mainWidget: NavListTileDesktopAlt(
          height: 18,
          action: () {
            GeneralSettingsAuthAction().manageProductions(
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
                                      .manageProductionItems ??
                                  true
                              ? 'You can no longer manage your Production Items, are you sure you want to proceed?'
                              : 'You can now manage your Production Items, are you sure you want to proceed?',
                      title:
                          shopProvider
                                      .userShop()!
                                      .manageProductionItems ??
                                  true
                              ? 'Turn Off Production Items'
                              : 'Turn On Production Items',
                      action: () async {
                        Navigator.of(context).pop();
                        shopProvider
                            .toggleManageProductionItems();
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
              ).manageProductionItems) {
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
                      ).userShop()?.manageProductionItems ??
                      true,
                  toggle: () {
                    GeneralSettingsAuthAction().manageProductions(
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
                                              .manageProductionItems ??
                                          true
                                      ? 'You can no longer manage your Production Items, are you sure you want to proceed?'
                                      : 'You can now manage your Production Items, are you sure you want to proceed?',
                              title:
                                  shopProvider
                                              .userShop()!
                                              .manageProductionItems ??
                                          true
                                      ? 'Turn Off Production Items'
                                      : 'Turn On Production Items',
                              action: () async {
                                Navigator.of(context).pop();
                                shopProvider
                                    .toggleManageProductionItems();
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
          title: 'Manage Production Items',
          icon: Icons.api_rounded,
        ),
      ),
    );
  }
}
