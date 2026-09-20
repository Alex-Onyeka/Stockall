import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_shop/temp_shop_class.dart';
import 'package:stockall/components/alert_dialogues/dialog_template.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/text_fields/general_textfield.dart';
import 'package:stockall/constants/subscription/general_settings_auth.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/theme_provider.dart';

void setSocialDetails({
  required BuildContext context,
  required ThemeProvider theme,
  required TempShopClass shop,
  required TextEditingController faceBookController,
  required TextEditingController instaController,
  required Function(bool value) toggleLoading,
  required Function() setShopFuture,
}) {
  GeneralSettingsAuthAction().addSocialsAction(
    context: context,
    action: () {
      showDialog(
        context: context,
        builder: (firstContext) {
          return DialogTemplate(
            theme: theme,
            message: '',
            title: 'Enter Social Details',
            widget: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 10,
              children: [
                GeneralTextField(
                  initialValue: shop.faceBookHandle,
                  isEmail: false,
                  title: 'Facebook Handle (Optional)',
                  isEnabled: true,
                  hint: 'Enter Facebook Handle',
                  controller: faceBookController,
                  lines: 1,
                  theme: theme,
                ),
                GeneralTextField(
                  initialValue: shop.instaHandle,
                  isEmail: false,
                  title: 'Instagram Handle (Optional)',
                  isEnabled: true,
                  hint: 'Enter Instagram Handle',
                  controller: instaController,
                  lines: 1,
                  theme: theme,
                ),
              ],
            ),
            action: () async {
              toggleLoading(true);
              Navigator.of(firstContext).pop();
              var res = await returnShopProvider()
                  .updateShopSocials(
                    face:
                        faceBookController.text.isEmpty
                            ? null
                            : faceBookController.text,
                    insta:
                        instaController.text.isEmpty
                            ? null
                            : instaController.text,
                  );
              toggleLoading(false);
              if (res == 1) {
                setShopFuture();
              } else {
                showDialog(
                  // ignore: use_build_context_synchronously
                  context: context,
                  builder: (context) {
                    return InfoAlert(
                      theme: theme,
                      message:
                          'The Update was not successful. Please try again.',
                      title: 'Update Failed',
                    );
                  },
                );
              }
            },
          );
        },
      );
    },
  );
}
