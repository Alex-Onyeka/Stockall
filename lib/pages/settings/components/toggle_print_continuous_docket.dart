import 'package:flutter/material.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/major/drawer_widget/platforms/my_drawer_widget_desktop.dart';
import 'package:stockall/components/toggle_button/my_toggle_button.dart';
import 'package:stockall/constants/subscription/sales_auth.dart';
import 'package:stockall/constants/subscription/subscription_func.dart';
import 'package:stockall/main.dart';

class TogglePrintContinuousDocket extends StatelessWidget {
  const TogglePrintContinuousDocket({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Visibility(
      visible: !isStoreKeeper(),
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
                var compProvider = returnCompProvider(
                  context,
                  listen: false,
                );
                showDialog(
                  context: context,
                  builder: (context) {
                    return ConfirmationAlert(
                      theme: theme,
                      message:
                          compProvider
                                  .getContinuousPrintDocket()
                              ? 'You can add Items to cart without Having to print Each docket, are you sure you want to proceed?'
                              : 'You must Print each item out as a docket before adding it to cart, are you sure you want to proceed?',
                      title:
                          compProvider
                                  .getContinuousPrintDocket()
                              ? 'Turn Off Print Continuous Docket'
                              : 'Turn On Print Continuous Docket',
                      action: () async {
                        Navigator.of(context).pop();
                        compProvider
                            .toggleContinuousPrintDocket();
                      },
                    );
                  },
                );
              },
            );
          },
          endWidget: MyToggleButton(
            isSmall: true,
            boolValue:
                returnCompProvider(
                  context,
                ).getContinuousPrintDocket(),
            toggle: () {
              SalesAuthAction().printDocketAction(
                context: context,
                action: () {
                  var compProvider = returnCompProvider(
                    context,
                    listen: false,
                  );
                  showDialog(
                    context: context,
                    builder: (context) {
                      return ConfirmationAlert(
                        theme: theme,
                        message:
                            compProvider
                                    .getContinuousPrintDocket()
                                ? 'You can add Items to cart without Having to print Each docket, are you sure you want to proceed?'
                                : 'You must Print each item out as a docket before adding it to cart, are you sure you want to proceed?',
                        title:
                            compProvider
                                    .getContinuousPrintDocket()
                                ? 'Turn Off Print Continuous Docket'
                                : 'Turn On Print Continuous Docket',
                        action: () async {
                          Navigator.of(context).pop();
                          compProvider
                              .toggleContinuousPrintDocket();
                        },
                      );
                    },
                  );
                },
              );
            },
            theme: theme,
          ),
          title: 'Print Continuous Docket',
          icon: Icons.print,
        ),
      ),
    );
  }
}
