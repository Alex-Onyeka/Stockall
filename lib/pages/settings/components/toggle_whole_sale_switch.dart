import 'package:flutter/material.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/major/drawer_widget/platforms/my_drawer_widget_desktop.dart';
import 'package:stockall/components/toggle_button/my_toggle_button.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/subscription/items_auth.dart';
import 'package:stockall/constants/subscription/subscription_func.dart';
import 'package:stockall/main.dart';

class ToggleWholeSaleSwitch extends StatelessWidget {
  const ToggleWholeSaleSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Visibility(
      visible:
          authorization(
            authorized: Authorizations().toggleUseGroupUnit,
          ) &&
          !isStoreKeeper(),
      child: SubWrapper(
        isVisible:
            !ItemsAuthAction().toggleSetWholeSaleAction(
              context: context,
            ),
        mainWidget: NavListTileDesktopAlt(
          height: 18,
          action: () {
            ItemsAuthAction().toggleSetWholeSaleAction(
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
                                  .wholeSale!
                              ? 'You can no longer set whole sale Price of Items, are you sure you want to proceed?'
                              : 'You can now set whole sale Price of Items, are you sure you want to proceed?',
                      title:
                          shopProvider
                                  .userShop()!
                                  .wholeSale!
                              ? 'Turn off Whole Sale Price'
                              : 'Turn On Whole Sale Price',
                      action: () async {
                        Navigator.of(context).pop();
                        shopProvider.toggleWholeSale();
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
              ).isWholeSaleLoading) {
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
                      ).userShop()?.wholeSale ??
                      true,
                  toggle: () {
                    ItemsAuthAction().toggleSetWholeSaleAction(
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
                                          .wholeSale!
                                      ? 'You can no longer set whole sale Price of Items, are you sure you want to proceed?'
                                      : 'You can now set whole sale Price of Items, are you sure you want to proceed?',
                              title:
                                  shopProvider
                                          .userShop()!
                                          .wholeSale!
                                      ? 'Turn off Whole Sale Price'
                                      : 'Turn On Whole Sale Price',
                              action: () async {
                                Navigator.of(context).pop();
                                shopProvider
                                    .toggleWholeSale();
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
          title: 'Manage Item Whole Sale Price',
          icon: Icons.webhook_outlined,
        ),
      ),
    );
  }
}
