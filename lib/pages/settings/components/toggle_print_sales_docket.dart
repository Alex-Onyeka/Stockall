import 'package:flutter/material.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/major/drawer_widget/platforms/my_drawer_widget_desktop.dart';
import 'package:stockall/components/toggle_button/my_toggle_button.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/subscription/sales_auth.dart';
import 'package:stockall/constants/subscription/subscription_func.dart';
import 'package:stockall/main.dart';

class TogglePrintSalesDocket extends StatelessWidget {
  const TogglePrintSalesDocket({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Visibility(
      visible:
          authorization(
            authorized:
                Authorizations().togglePrintSalesDocket,
          ) &&
          !isStoreKeeper(),
      child: SubWrapper(
        isVisible:
            !SalesAuthAction().printDocketAction(
              context: context,
            ),
        mainWidget: NavListTileDesktopAlt(
          height: 18,
          action: () {
            SalesAuthAction().printDocketAction(
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
                                  .printSalesDocket!
                              ? 'You can no Longer Generate and Print Sales Docket, are you sure you want to proceed?'
                              : 'You can now Generate and Print Sales Docket, are you sure you want to proceed?',
                      title:
                          shopProvider
                                  .userShop()!
                                  .printSalesDocket!
                              ? 'Turn Off Print Sales Docket'
                              : 'Turn On Print Sales Docket',
                      action: () async {
                        Navigator.of(context).pop();
                        shopProvider
                            .togglePrintSalesDocket();
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
              ).printSalesDocketLoading) {
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
                      ).userShop()?.printSalesDocket ??
                      true,
                  toggle: () {
                    SalesAuthAction().printDocketAction(
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
                                          .printSalesDocket!
                                      ? 'You can no Longer Generate and Print Sales Docket, are you sure you want to proceed?'
                                      : 'You can now Generate and Print Sales Docket, are you sure you want to proceed?',
                              title:
                                  shopProvider
                                          .userShop()!
                                          .printSalesDocket!
                                      ? 'Turn Off Print Sales Docket'
                                      : 'Turn On Print Sales Docket',
                              action: () async {
                                Navigator.of(context).pop();
                                shopProvider
                                    .togglePrintSalesDocket();
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
          title: 'Toggle Print Sales Docket',
          icon: Icons.print,
        ),
      ),
    );
  }
}
