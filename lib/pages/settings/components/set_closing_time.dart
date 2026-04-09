import 'package:flutter/material.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/major/drawer_widget/platforms/my_drawer_widget_desktop.dart';
import 'package:stockall/constants/date_picker_function.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/subscription/general_settings_auth.dart';
import 'package:stockall/constants/subscription/subscription_func.dart';
import 'package:stockall/main.dart';

class SetClosingTime extends StatefulWidget {
  const SetClosingTime({super.key});

  @override
  State<SetClosingTime> createState() =>
      _SetClosingTimeState();
}

class _SetClosingTimeState extends State<SetClosingTime> {
  TimeOfDay? time;
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
                if (returnShopProvider()
                        .userShop()!
                        .closeSaleTime ==
                    null) {
                  myTimePickerAction(theme, context).then((
                    value,
                  ) {
                    setState(() {
                      time = value;
                    });
                    if (context.mounted && time != null) {
                      showDialog(
                        context: context,
                        builder: (confirmContext) {
                          return ConfirmationAlert(
                            theme: theme,
                            message:
                                returnShopProvider()
                                            .userShop()!
                                            .closeSaleTime !=
                                        null
                                    ? 'You are about to cancel your closing sales time. Your sales will now by automatically closed at 12AM, are you sure you want to proceed?'
                                    : 'You are about to select your closing sales time. Your sales will now close at the time you select, are you sure you want to proceed?',
                            title:
                                returnShopProvider()
                                            .userShop()!
                                            .closeSaleTime !=
                                        null
                                    ? 'Cancel Closing sales Time'
                                    : 'Set Closing Sales Time',
                            action: () async {
                              Navigator.of(context).pop();
                              returnShopProvider()
                                  .setCloseSaleTime(
                                    time: time,
                                  );
                            },
                          );
                        },
                      );
                    }
                  });
                } else {
                  showDialog(
                    context: context,
                    builder: (confirmContext) {
                      return ConfirmationAlert(
                        theme: theme,
                        message:
                            returnShopProvider()
                                        .userShop()!
                                        .closeSaleTime !=
                                    null
                                ? 'You are about to cancel your closing sales time. Your sales will now by automatically closed at 12AM, are you sure you want to proceed?'
                                : 'You are about to select your closing sales time. Your sales will now close at the time you select, are you sure you want to proceed?',
                        title:
                            returnShopProvider()
                                        .userShop()!
                                        .closeSaleTime !=
                                    null
                                ? 'Cancel Closing sales Time'
                                : 'Set Closing Sales Time',
                        action: () async {
                          Navigator.of(context).pop();
                          returnShopProvider()
                              .setCloseSaleTime();
                        },
                      );
                    },
                  );
                }
              },
            );
          },
          endWidget: Builder(
            builder: (context) {
              if (returnShopProvider(
                context: context,
              ).isSetCloseSaleTimeLoading) {
                return SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                    color: theme.lightModeColor.secColor200,
                    strokeWidth: 2,
                  ),
                );
              } else {
                return Text(
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b4.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                  shop(context)?.closeSaleTime == null
                      ? 'Not Set'
                      : '${shop(context)?.closeSaleTime?.hour} : ${shop(context)?.closeSaleTime?.minute} ${shop(context)?.closeSaleTime?.period.name.toUpperCase()}',
                );
              }
            },
          ),
          title:
              shop(context)?.closeSaleTime == null
                  ? 'Set Closing Time'
                  : 'Cancel Closing Time',
          icon: Icons.manage_search,
        ),
      ),
    );
  }
}
