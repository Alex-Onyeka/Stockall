import 'package:flutter/material.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/major/drawer_widget/platforms/my_drawer_widget_desktop.dart';
import 'package:stockall/components/toggle_button/my_toggle_button.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/subscription/items_auth.dart';
import 'package:stockall/constants/subscription/subscription_func.dart';
import 'package:stockall/main.dart';

class UseGroupUnitToggle extends StatelessWidget {
  const UseGroupUnitToggle({super.key});

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
            !ItemsAuthAction().useGroupUnitAction(
              context: context,
            ),
        mainWidget: NavListTileDesktopAlt(
          height: 18,
          action: () {
            ItemsAuthAction().useGroupUnitAction(
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
                              ? 'You can no longer set item Group Unit, are you sure you want to proceed?'
                              : 'You can now set item Group Unit, are you sure you want to proceed?',
                      title:
                          shopProvider
                                  .userShop()!
                                  .manageInventoryStorage!
                              ? 'Turn Off Group Unit'
                              : 'Turn On Group Unit',
                      action: () async {
                        Navigator.of(context).pop();
                        shopProvider.toggleUseGroupUnit();
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
              ).isUseGroupUnitLoading) {
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
                      ).userShop()?.useGroupUnit ??
                      true,
                  toggle: () {
                    ItemsAuthAction().useGroupUnitAction(
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
                                      ? 'You can no longer set item Group Unit, are you sure you want to proceed?'
                                      : 'You can now set item Group Unit, are you sure you want to proceed?',
                              title:
                                  shopProvider
                                          .userShop()!
                                          .manageInventoryStorage!
                                      ? 'Turn Off Group Unit'
                                      : 'Turn On Group Unit',
                              action: () async {
                                Navigator.of(context).pop();
                                shopProvider
                                    .toggleUseGroupUnit();
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
          title: 'Use Item Group Unit',
          icon: Icons.group_work_outlined,
        ),
      ),
    );
  }
}
