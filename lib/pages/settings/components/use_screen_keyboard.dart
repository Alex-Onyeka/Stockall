import 'dart:io';

import 'package:flutter/material.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/major/drawer_widget/platforms/my_drawer_widget_desktop.dart';
import 'package:stockall/components/toggle_button/my_toggle_button.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/subscription/general_settings_auth.dart';
import 'package:stockall/constants/subscription/subscription_func.dart';
import 'package:stockall/main.dart';

class UseScreenKeyboard extends StatelessWidget {
  const UseScreenKeyboard({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Visibility(
      visible:
          authorization(
            authorized:
                Authorizations().toggleOnScreenKeyboard,
          ) &&
          !isStoreKeeper() &&
          Platform.isWindows,
      child: SubWrapper(
        isVisible:
            !GeneralSettingsAuthAction()
                .useOnScreenKeyboardAction(
                  context: context,
                ),
        mainWidget: NavListTileDesktopAlt(
          height: 18,
          action: () {
            GeneralSettingsAuthAction().useOnScreenKeyboardAction(
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
                                  .isOnScreenKeyboardOn()
                              ? 'You are about to turn off Auto On-Screen Keyboard, are you sure you want to proceed?'
                              : 'You are about to turn on Auto On-Screen Keyboard, are you sure you want to proceed?',
                      title:
                          shopProvider
                                  .isOnScreenKeyboardOn()
                              ? 'Turn Off On-Screen Keyboard'
                              : 'Turn On On-Screen Keyboard',
                      action: () async {
                        Navigator.of(context).pop();
                        shopProvider
                            .toggleOnScreenKeyboard();
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
              ).isOnScreenKeyboardLoading) {
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
                      ).isOnScreenKeyboardOn(),
                  toggle: () {
                    GeneralSettingsAuthAction().useOnScreenKeyboardAction(
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
                                          .isOnScreenKeyboardOn()
                                      ? 'You are about to turn off Auto On-Screen Keyboard, are you sure you want to proceed?'
                                      : 'You are about to turn on Auto On-Screen Keyboard, are you sure you want to proceed?',
                              title:
                                  shopProvider
                                          .isOnScreenKeyboardOn()
                                      ? 'Turn Off On-Screen Keyboard'
                                      : 'Turn On On-Screen Keyboard',
                              action: () async {
                                Navigator.of(context).pop();
                                shopProvider
                                    .toggleOnScreenKeyboard();
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
          title: 'Use On-Screen Keyboard',
          icon: Icons.keyboard_alt_outlined,
        ),
      ),
    );
  }
}
