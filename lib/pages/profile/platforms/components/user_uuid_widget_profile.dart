import 'package:flutter/material.dart';
import 'package:stockall/classes/user_class/temp_user_class.dart';
import 'package:stockall/components/alert_dialogues/dialog_template.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/pages/authentication/components/email_text_field.dart';
import 'package:stockall/providers/theme_provider.dart';

class UserUuidWidgetProfile extends StatefulWidget {
  const UserUuidWidgetProfile({
    super.key,
    required this.user,
    required this.theme,
  });

  final TempUserClass user;
  final ThemeProvider theme;

  @override
  State<UserUuidWidgetProfile> createState() =>
      _UserUuidWidgetProfileState();
}

class _UserUuidWidgetProfileState
    extends State<UserUuidWidgetProfile> {
  bool isSeen = false;
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.grey.shade400),
          color: Colors.grey.shade100,
        ),
        child: InkWell(
          mouseCursor: SystemMouseCursors.click,
          borderRadius: BorderRadius.circular(4),
          onTap: () {
            if (isSeen) {
              copyToClipboard(
                context: context,
                text: widget.user.userId ?? 'No Text',
              );
            } else {
              showDialog(
                context: context,
                builder: (firstContext) {
                  return DialogTemplate(
                    theme: widget.theme,
                    message:
                        'Please Proceed To Enter Your Account Password to View/Copy your Unique Id.',
                    title: 'Password Required',
                    action: () {
                      submitPasswordAction(
                        firstContext: firstContext,
                      );
                    },
                    widget: EmailTextField(
                      controller: passwordController,
                      onSubmit: (p0) {
                        submitPasswordAction(
                          firstContext: firstContext,
                        );
                      },
                      theme: widget.theme,
                      isEmail: false,
                      hint: 'Enter Password',
                      title: 'Password',
                    ),
                  );
                },
              ).then((_) {
                passwordController.clear();
              });
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: 3,
              horizontal: 6,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 5,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize:
                          widget
                              .theme
                              .mobileTexts
                              .b4
                              .fontSize,
                    ),
                    userIdString(),
                  ),
                ),
                Icon(
                  size: 18,
                  color:
                      widget
                          .theme
                          .lightModeColor
                          .secColor200,
                  isSeen ? Icons.copy : Icons.visibility,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String userIdString() {
    return isSeen
        ? widget.user.userId ?? 'User Id'
        : 'Unique Id: #################';
  }

  void submitPasswordAction({
    required BuildContext firstContext,
  }) {
    if (passwordController.text == widget.user.password) {
      setState(() {
        isSeen = true;
      });
      Navigator.of(firstContext).pop();
    } else {
      showDialog(
        context: context,
        builder: (errorContext) {
          return InfoAlert(
            theme: widget.theme,
            message:
                'The Password You Entered Is Incorrect. Please Try Again.',
            title: 'Incorrect Password',
          );
        },
      );
    }
  }
}
