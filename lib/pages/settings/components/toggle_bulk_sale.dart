import 'package:flutter/material.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/major/drawer_widget/platforms/my_drawer_widget_desktop.dart';
import 'package:stockall/components/toggle_button/my_toggle_button.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/subscription/sales_auth.dart';
import 'package:stockall/constants/subscription/subscription_func.dart';
import 'package:stockall/main.dart';

class ToggleBulkSale extends StatelessWidget {
  const ToggleBulkSale({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Visibility(
      visible:
          authorization(
            authorized: Authorizations().toggleBulkSale,
          ) &&
          !isStoreKeeper(),
      child: SubWrapper(
        isVisible:
            !SalesAuthAction().allowBulkSaleAction(
              context: context,
            ),
        mainWidget: NavListTileDesktopAlt(
          height: 18,
          action: () {
            SalesAuthAction().allowBulkSaleAction(
              context: context,
              action: () {
                var shopProvider = returnShopProvider();
                showDialog(
                  context: context,
                  builder: (context) {
                    return ConfirmationAlert(
                      theme: theme,
                      message:
                          shopProvider.userShop()!.bulkSale!
                              ? 'You can no longer perform bulk Sale, are you sure you want to proceed?'
                              : 'You can now perform bulk Sale, are you sure you want to proceed?',
                      title:
                          shopProvider.userShop()!.bulkSale!
                              ? 'Turn Off Bulk Sale'
                              : 'Turn On Bulk Sale',
                      action: () async {
                        Navigator.of(context).pop();
                        shopProvider.toggleAllowBulkSale();
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
              ).allowBulkSale) {
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
                      ).userShop()?.bulkSale ??
                      true,
                  toggle: () {
                    SalesAuthAction().allowBulkSaleAction(
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
                                          .bulkSale!
                                      ? 'You can no longer perform bulk Sale, are you sure you want to proceed?'
                                      : 'You can now perform bulk Sale, are you sure you want to proceed?',
                              title:
                                  shopProvider
                                          .userShop()!
                                          .bulkSale!
                                      ? 'Turn Off Bulk Sale'
                                      : 'Turn On Bulk Sale',
                              action: () async {
                                Navigator.of(context).pop();
                                shopProvider
                                    .toggleAllowBulkSale();
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
          title: 'Manage Bulk Sale',
          icon: Icons.manage_search,
        ),
      ),
    );
  }
}
