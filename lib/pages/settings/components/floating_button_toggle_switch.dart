import 'package:flutter/material.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/major/drawer_widget/platforms/my_drawer_widget_desktop.dart';
import 'package:stockall/components/toggle_button/my_toggle_button.dart';
import 'package:stockall/constants/subscription/subscription_func.dart';
import 'package:stockall/main.dart';

class FloatingButtonToggleSwitch extends StatelessWidget {
  const FloatingButtonToggleSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return SubWrapper(
      isVisible: true,
      // !GeneralSettingsAuthAction()
      //     .useFloatingButtonAction(context: context),
      mainWidget: NavListTileDesktopAlt(
        height: 18,
        action: () {
          // GeneralSettingsAuthAction().useFloatingButtonAction(
          //   context: context,
          //   action: () {
          // var shopProvider = returnShopProvider();
          showDialog(
            context: context,
            builder: (context) {
              return ConfirmationAlert(
                theme: theme,
                message:
                    returnUtilityWidgetProvider(
                          context: context,
                        ).getVisibility()
                        ? 'You are about to hide Floating utility Button, are you sure you want to proceed?'
                        : 'You are about to Show Floating utility Button, are you sure you want to proceed?',
                title:
                    returnUtilityWidgetProvider(
                          context: context,
                        ).getVisibility()
                        ? 'Turn Off Utility Button'
                        : 'Turn On Utility Button',
                action: () async {
                  Navigator.of(context).pop();
                  await returnUtilityWidgetProvider()
                      .toggleVisibility();
                },
              );
            },
          );
          //   },
          // );
        },
        endWidget: Builder(
          builder: (context) {
            return MyToggleButton(
              isSmall: true,
              boolValue:
                  returnUtilityWidgetProvider(
                    context: context,
                  ).getVisibility(),
              toggle: () {
                // GeneralSettingsAuthAction().useFloatingButtonAction(
                //   context: context,
                //   action: () {
                // var shopProvider = returnShopProvider();
                showDialog(
                  context: context,
                  builder: (context) {
                    return ConfirmationAlert(
                      theme: theme,
                      message:
                          returnUtilityWidgetProvider(
                                context: context,
                              ).getVisibility()
                              ? 'You are about to hide Floating utility Button, are you sure you want to proceed?'
                              : 'You are about to Show Floating utility Button, are you sure you want to proceed?',
                      title:
                          returnUtilityWidgetProvider(
                                context: context,
                              ).getVisibility()
                              ? 'Turn Off Utility Button'
                              : 'Turn On Utility Button',
                      action: () async {
                        Navigator.of(context).pop();
                        await returnUtilityWidgetProvider()
                            .toggleVisibility();
                      },
                    );
                  },
                );
                //   },
                // );
              },
              theme: theme,
            );
          },
        ),
        title: 'Manage Utility Button',
        icon: Icons.manage_search,
      ),
    );
  }
}
