import 'package:flutter/material.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/major/drawer_widget/platforms/my_drawer_widget_desktop.dart';
import 'package:stockall/components/toggle_button/my_toggle_button.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/subscription/items_auth.dart';
import 'package:stockall/constants/subscription/subscription_func.dart';
import 'package:stockall/main.dart';

class ManageInventoryToggleSwitch extends StatelessWidget {
  const ManageInventoryToggleSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Visibility(
      visible:
          authorization(
            authorized:
                Authorizations().manageInventoryStorage,
          ) &&
          !isStoreKeeper(),
      child: SubWrapper(
        isVisible:
            !ItemsAuthAction().manageInventoryStorageAction(
              context: context,
            ),
        mainWidget: NavListTileDesktopAlt(
          height: 18,
          action: () {
            ItemsAuthAction().manageInventoryStorageAction(
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
                                  .manageInventoryStorage!
                              ? 'Your Inventory Storage will not be managed, are you sure you want to proceed?'
                              : 'Your Inventory Storage will be managed, will, are you sure you want to proceed?',
                      title:
                          shopProvider
                                  .userShop()!
                                  .manageInventoryStorage!
                              ? 'Turn Off Inventory Storage'
                              : 'Turn On Inventory Storage',
                      action: () async {
                        Navigator.of(context).pop();
                        shopProvider
                            .togglemanageInventoryStorage();
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
              ).ismanageInventoryStorageLoading) {
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
                      returnShopProvider(context: context)
                          .userShop()
                          ?.manageInventoryStorage ??
                      true,
                  toggle: () {
                    ItemsAuthAction().manageInventoryStorageAction(
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
                                          .manageInventoryStorage!
                                      ? 'Your Inventory Storage will not be managed, are you sure you want to proceed?'
                                      : 'Your Inventory Storage will be managed, will, are you sure you want to proceed?',
                              title:
                                  shopProvider
                                          .userShop()!
                                          .manageInventoryStorage!
                                      ? 'Turn Off Inventory Storage'
                                      : 'Turn On Inventory Storage',
                              action: () async {
                                Navigator.of(context).pop();
                                shopProvider
                                    .togglemanageInventoryStorage();
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
          title: 'Manage Inventory Storage',
          icon: Icons.manage_search,
        ),
      ),
    );
  }
}
