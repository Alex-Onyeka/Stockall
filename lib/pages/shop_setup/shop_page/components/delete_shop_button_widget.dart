import 'package:flutter/material.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/dialog_template.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/buttons/main_button_transparent.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/authentication/components/email_text_field.dart';

class DeleteShopButtonWidget extends StatefulWidget {
  final Function(bool value) toggleLoading;
  const DeleteShopButtonWidget({
    super.key,
    required this.toggleLoading,
  });

  @override
  State<DeleteShopButtonWidget> createState() =>
      _DeleteShopButtonWidgetState();
}

class _DeleteShopButtonWidgetState
    extends State<DeleteShopButtonWidget> {
  final passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context, listen: false);
    return Visibility(
      visible: authorization(
        authorized: Authorizations().deleteShop,
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: 30),
        padding: EdgeInsets.fromLTRB(20, 15, 20, 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Colors.grey.shade100,
        ),
        child: Column(
          spacing: 10,
          children: [
            Row(
              spacing: 15,
              children: [
                Expanded(child: Divider(thickness: 0.5)),
                Text(
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b4.fontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                  'CRITICAL',
                ),
                Expanded(child: Divider(thickness: 0.5)),
              ],
            ),
            MainButtonTransparent(
              themeProvider: theme,
              constraints: BoxConstraints(),
              text: 'Delete Shop',
              action: () {
                var safeContext = context;
                var shopP = returnShopProvider();
                var userP = returnUserProvider(
                  context,
                  listen: false,
                );
                showDialog(
                  context: context,
                  builder: (confirmDialog) {
                    return ConfirmationAlert(
                      theme: theme,
                      message:
                          'You are about to delete an entire Store, with all its data. You will loose all the data of this store after this process. This Action can not be reversed. Are you sure you want to proceed?',
                      title: 'Delete Shop?',
                      action: () async {
                        Navigator.of(confirmDialog).pop();
                        showDialog(
                          context: safeContext,
                          builder: (newDialog) {
                            return DialogTemplate(
                              theme: theme,
                              message:
                                  'You have to enter your password to verify that you are the owner this shop, in other to delete',
                              title: 'Enter Password',
                              action: () async {
                                var password =
                                    userP
                                        .currentUserMain!
                                        .password;
                                if (passwordController
                                    .text
                                    .isEmpty) {
                                  if (!context.mounted) {
                                    return;
                                  }
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return InfoAlert(
                                        theme: returnTheme(
                                          context,
                                          listen: false,
                                        ),
                                        message:
                                            'Password field cannot be empty. You must enter you password in the password field to proceed.',
                                        title:
                                            'Password Empty',
                                      );
                                    },
                                  );
                                  return;
                                }
                                if (password !=
                                    passwordController
                                        .text) {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return InfoAlert(
                                        theme: returnTheme(
                                          context,
                                          listen: false,
                                        ),
                                        message:
                                            'The Password you entered is Incorrect. Please check the password and try again.',
                                        title:
                                            'Password Incorrect.',
                                      );
                                    },
                                  );
                                  return;
                                }
                                Navigator.of(
                                  newDialog,
                                ).pop();
                                widget.toggleLoading(true);
                                var res = await shopP
                                    .deleteShop(
                                      context: context,
                                    );
                                if (res == 0) {
                                  widget.toggleLoading(
                                    false,
                                  );
                                }
                              },
                              widget: SizedBox(
                                width: double.infinity,
                                child: EmailTextField(
                                  controller:
                                      passwordController,
                                  theme: theme,
                                  isEmail: false,
                                  hint: 'Enter Password',
                                  title: 'Password',
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
              color: Colors.red,
              icon: Icon(
                size: 20,
                color: Colors.red,
                Icons.delete_forever_rounded,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
