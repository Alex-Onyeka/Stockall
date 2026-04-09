import 'package:flutter/material.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/major/drawer_widget/platforms/my_drawer_widget_desktop.dart';
import 'package:stockall/components/toggle_button/my_toggle_button.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/subscription/general_settings_auth.dart';
import 'package:stockall/constants/subscription/subscription_func.dart';
import 'package:stockall/main.dart';

class UseCloseSaleToggleSwitch extends StatelessWidget {
  const UseCloseSaleToggleSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Visibility(
      visible:
          authorization(
            authorized: Authorizations().manageShop,
          ) &&
          !isStoreKeeper(),
      child: SubWrapper(
        isVisible:
            !GeneralSettingsAuthAction()
                .useCloseSalesAction(context: context),
        mainWidget: NavListTileDesktopAlt(
          height: 18,
          action: () {
            GeneralSettingsAuthAction().useCloseSalesAction(
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
                                  .useCloseSale!
                              ? 'You can no longer use Close Sales, are you sure you want to proceed?'
                              : 'You can now use Close Sales, are you sure you want to proceed?',
                      title:
                          shopProvider
                                  .userShop()!
                                  .useCloseSale!
                              ? 'Turn Off Use Close Sales'
                              : 'Turn On Use Close Sales',
                      action: () async {
                        Navigator.of(context).pop();
                        shopProvider
                            .toggleManageDepartments();
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
              ).manageDepartmentsLoading) {
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
                      ).userShop()?.useCloseSale ??
                      true,
                  toggle: () {
                    GeneralSettingsAuthAction().useCloseSalesAction(
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
                                          .useCloseSale!
                                      ? 'You can no longer use Close Sales, are you sure you want to proceed?'
                                      : 'You can now use Close Sales, are you sure you want to proceed?',
                              title:
                                  shopProvider
                                          .userShop()!
                                          .useCloseSale!
                                      ? 'Turn Off Use Close Sales'
                                      : 'Turn On Use Close Sales',
                              action: () async {
                                Navigator.of(context).pop();
                                shopProvider
                                    .toggleManageDepartments();
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
          title: 'Use Close Sales',
          icon: Icons.manage_search,
        ),
      ),
    );
  }
}
