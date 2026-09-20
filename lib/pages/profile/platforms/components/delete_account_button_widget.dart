import 'package:flutter/material.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/buttons/main_button_transparent.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/profile/delete_account/delete_account.dart';

class DeleteAccountButtonWidget extends StatefulWidget {
  const DeleteAccountButtonWidget({super.key});

  @override
  State<DeleteAccountButtonWidget> createState() =>
      _DeleteAccountButtonWidgetState();
}

class _DeleteAccountButtonWidgetState
    extends State<DeleteAccountButtonWidget> {
  final passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context, listen: false);
    return Container(
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
            color: Colors.red,
            action: () {
              if (returnConnectivityProvider()
                  .isConnected) {
                showDialog(
                  context: context,
                  builder: (confirmDialog) {
                    return ConfirmationAlert(
                      theme: theme,
                      message:
                          'Deleting your account means loosing all your account information. This action cannot be reversed. Are you sure you want to proceed?',
                      title: 'Are you Sure?',
                      action: () {
                        Navigator.of(confirmDialog).pop();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return DeleteAccount();
                            },
                          ),
                        );
                      },
                    );
                  },
                );
              } else {
                showDialog(
                  context: context,
                  builder: (context) {
                    return InfoAlert(
                      theme: theme,
                      message:
                          'Please Turn on your internet connection to Proceed with this action.',
                      title: 'No Internet',
                    );
                  },
                );
              }
            },
            text: 'Delete Your Account',
            constraints: BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
