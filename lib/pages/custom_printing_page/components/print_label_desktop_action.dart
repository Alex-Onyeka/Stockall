import 'package:flutter/material.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/main.dart';
import 'package:stockall/services/barcode_generation/barcode_import_helper.dart';

void printLabelDesktopAction({
  required BuildContext context,
  required TextEditingController customLabelTextController,
  required TextEditingController?
  customLabelTitleController,
}) {
  var theme = returnTheme(context, listen: false);
  showDialog(
    context: context,
    builder: (firstContext) {
      return ConfirmationAlert(
        theme: theme,
        message:
            'You are about to Print A Label/Sticker, are you sure you want to proceed?',
        actionButtonText: 'Print',
        title: 'Print Label',
        action: () async {
          Navigator.of(firstContext).pop();

          var res = await printLabelDesktop(
            printerName:
                returnShopProvider().printerCache?.name ??
                '',
            text: customLabelTextController.text.trim(),
            title:
                customLabelTitleController == null ||
                        customLabelTitleController
                                .text
                                .isEmpty ==
                            true
                    ? null
                    : customLabelTitleController.text
                        .trim(),
          );

          if (res) {
            // customLabelTextController.clear();
            // customLabelTitleController?.clear();
          }

          await mainLocalLog('Generate Clicked');
        },
      );
    },
  );
}
