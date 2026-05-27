import 'package:flutter/material.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/major/drawer_widget/platforms/my_drawer_widget_desktop.dart';
import 'package:stockall/components/toggle_button/my_toggle_button.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/subscription/general_settings_auth.dart';
import 'package:stockall/constants/subscription/subscription_func.dart';
import 'package:stockall/main.dart';

class ToggleTrackCart extends StatelessWidget {
  const ToggleTrackCart({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Visibility(
      visible:
          authorization(
            authorized: Authorizations().toggleTrackCart,
          ) &&
          !isStoreKeeper(),
      child: SubWrapper(
        isVisible:
            !GeneralSettingsAuthAction().trackCart(
              context: context,
            ),
        mainWidget: NavListTileDesktopAlt(
          height: 18,
          action: () {
            GeneralSettingsAuthAction().trackCart(
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
                                  .trackCart!
                              ? 'You can no Longer Track and Manage Cart Operations, are you sure you want to proceed?'
                              : 'You can now Track and Manage Cart Operations, are you sure you want to proceed?',
                      title:
                          shopProvider
                                  .userShop()!
                                  .trackCart!
                              ? 'Turn Off Track Cart Operations'
                              : 'Turn On Track Cart Operations',
                      action: () async {
                        Navigator.of(context).pop();
                        shopProvider.toggleTrackCart();
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
              ).isTrackCartLoading) {
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
                      ).userShop()?.trackCart ??
                      true,
                  toggle: () {
                    GeneralSettingsAuthAction().trackCart(
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
                                          .trackCart!
                                      ? 'You can no Longer Track and Manage Cart Operations, are you sure you want to proceed?'
                                      : 'You can now Track and Manage Cart Operations, are you sure you want to proceed?',
                              title:
                                  shopProvider
                                          .userShop()!
                                          .trackCart!
                                      ? 'Turn Off Track Cart Operations'
                                      : 'Turn On Track Cart Operations',
                              action: () async {
                                Navigator.of(context).pop();
                                shopProvider
                                    .toggleTrackCart();
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
          title: 'Manage Cart Operations',
          icon: Icons.shopping_cart_checkout_sharp,
        ),
      ),
    );
  }
}
