import 'package:flutter/material.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/major/drawer_widget/platforms/my_drawer_widget_desktop.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';

class ClearTotalCacheWidget extends StatelessWidget {
  const ClearTotalCacheWidget({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Visibility(
      visible:
          authorization(
            authorized: Authorizations().clearCache,
          ) &&
          returnData(context: context).isSynced() == 0,
      child: NavListTileDesktopAlt(
        height: 18,
        action: () {
          showDialog(
            context: context,
            builder: (confirmDialog) {
              return ConfirmationAlert(
                theme: theme,
                message:
                    'You are about to Clear Your entire Locally Stored Data. You will loose all the data Business Records that has not been backed up in the cloud. This Action can not be reversed. Are you sure you want to proceed?',
                title: 'Clear Local Storage?',
                action: () async {
                  Navigator.of(confirmDialog).pop();
                  await returnData().clearTotalCache();
                },
              );
            },
          );
        },
        title: 'Clear Local Cache',
        color: Colors.red,
        icon: Icons.cleaning_services_rounded,
      ),
    );
  }
}
