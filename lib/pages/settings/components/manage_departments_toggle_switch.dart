import 'package:flutter/material.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/major/drawer_widget/platforms/my_drawer_widget_desktop.dart';
import 'package:stockall/components/toggle_button/my_toggle_button.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/subscription/general_settings_auth.dart';
import 'package:stockall/constants/subscription/subscription_func.dart';
import 'package:stockall/main.dart';

class ManageDepartmentsToggleSwitch
    extends StatelessWidget {
  const ManageDepartmentsToggleSwitch({super.key});

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
                .manageDeparmtmentsAction(context: context),
        mainWidget: NavListTileDesktopAlt(
          height: 18,
          action: () {
            GeneralSettingsAuthAction().manageDeparmtmentsAction(
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
                                  .manageDepartments!
                              ? 'You can no Create and manage Multiple Departments, are you sure you want to proceed?'
                              : 'You can now Create and manage Multiple Departments, are you sure you want to proceed?',
                      title:
                          shopProvider
                                  .userShop()!
                                  .manageDepartments!
                              ? 'Turn Off Manage Departments'
                              : 'Turn On Manage Departments',
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
                      ).userShop()?.manageDepartments ??
                      true,
                  toggle: () {
                    GeneralSettingsAuthAction().manageDeparmtmentsAction(
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
                                          .manageDepartments!
                                      ? 'You can no Create and manage Multiple Departments, are you sure you want to proceed?'
                                      : 'You can now Create and manage Multiple Departments, are you sure you want to proceed?',
                              title:
                                  shopProvider
                                          .userShop()!
                                          .manageDepartments!
                                      ? 'Turn Off Manage Departments'
                                      : 'Turn On Manage Departments',
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
          title: 'Manage Departments',
          icon: Icons.manage_search,
        ),
      ),
    );
  }
}
