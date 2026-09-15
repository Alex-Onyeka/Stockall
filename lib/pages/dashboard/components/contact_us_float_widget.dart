import 'package:flutter/material.dart';
import 'package:stockall/components/alert_dialogues/dialog_template.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/authentication/explore_page/platforms/explore_desktop.dart';
import 'package:stockall/providers/theme_provider.dart';

class ContactUsFloatWidget extends StatelessWidget {
  const ContactUsFloatWidget({
    super.key,
    required this.theme,
  });

  final ThemeProvider theme;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: authorization(
        authorized: Authorizations().contactStockall,
      ),
      child: Align(
        alignment: Alignment(1, 0.98),
        child: Material(
          elevation: 2,
          color: Colors.transparent,
          child: Ink(
            decoration: BoxDecoration(
              color: theme.lightModeColor.prColor300,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(5),
                topRight: Radius.circular(5),
                bottomLeft: Radius.circular(5),
              ),
            ),
            child: InkWell(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(5),
                topRight: Radius.circular(5),
                bottomLeft: Radius.circular(5),
              ),
              mouseCursor: SystemMouseCursors.click,
              onTap: () {
                contactUsAction(context: context);
              },
              child: Container(
                padding: EdgeInsets.fromLTRB(
                  10,
                  10,
                  10,
                  10,
                ),

                child: Row(
                  spacing: 5,
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Text(
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b3.fontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      'Contact',
                    ),
                    Icon(
                      size: 16,
                      color: Colors.white,
                      Icons.contacts_outlined,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void contactUsAction({required BuildContext context}) {
  var theme = returnTheme(context, listen: false);
  showDialog(
    context: context,
    builder: (firstContext) {
      return DialogTemplate(
        theme: theme,
        message:
            'Use any of the options below to Contact our Customer Care',
        title: 'Contact Support',
        action: () {},
        showBottomActionButtons: false,
        widget: Column(
          spacing: 15,
          children: [
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.fromLTRB(15, 15, 15, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(
                      20,
                      0,
                      0,
                      0,
                    ),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                spacing: 15,
                children: [
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b3
                                    .fontSize,
                          ),
                          'Chat With Our Customer Agent On Whatsapp for Professional Assistance.',
                        ),
                      ),
                    ],
                  ),
                  ActionButtonAlt(
                    text: 'Chat On Whatsapp',
                    icon: Icon(
                      size: 20,
                      color: Colors.white,
                      Icons.wechat_rounded,
                    ),
                    action: () {
                      openWhatsApp();
                    },
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(15, 15, 15, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(
                      20,
                      0,
                      0,
                      0,
                    ),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                spacing: 15,
                children: [
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b3
                                    .fontSize,
                          ),
                          'Call Our Customer Service For Professional Assistance',
                        ),
                      ),
                    ],
                  ),
                  ActionButtonAlt(
                    text:
                        "CALL: ${getContactPhoneNumber(formatIndex: 3)}",
                    icon: Icon(
                      size: 20,
                      color: Colors.white,
                      Icons.phone,
                    ),
                    action: () {
                      phoneCall();
                      copyToClipboard(
                        context: context,
                        text: getContactPhoneNumber(
                          formatIndex: 2,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}
