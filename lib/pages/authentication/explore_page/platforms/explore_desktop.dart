import 'package:flutter/material.dart';
import 'package:stockall/components/buttons/main_button_transparent.dart';
import 'package:stockall/components/major/desktop_center_container.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/authentication/login/login_page.dart';
import 'package:stockall/providers/theme_provider.dart';

class ExploreDesktop extends StatefulWidget {
  final ThemeProvider theme;
  const ExploreDesktop({super.key, required this.theme});

  @override
  State<ExploreDesktop> createState() =>
      _ExploreDesktopState();
}

class _ExploreDesktopState extends State<ExploreDesktop> {
  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Scaffold(
      body: DesktopCenterContainer(
        mainWidget: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 15.0,
          ),
          child: Column(
            children: [
              SizedBox(height: 10),
              Row(
                spacing: 10,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(mainLogoIcon, height: 20),
                  Text(
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 25,
                      fontWeight:
                          widget
                              .theme
                              .mobileTexts
                              .h3
                              .fontWeightBold,
                    ),
                    appName,
                  ),
                ],
              ),
              SizedBox(height: 20),
              LoginDemoSectionWidget(theme: theme),
              SizedBox(height: 20),
              ContactSupportSectionWidget(theme: theme),
              SizedBox(height: 20),
              MainButtonTransparent(
                themeProvider: widget.theme,
                constraints: BoxConstraints(),
                text: 'Go Back',
                action: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginDemoSectionWidget extends StatelessWidget {
  const LoginDemoSectionWidget({
    super.key,
    required this.theme,
  });

  final ThemeProvider theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: 20,
        horizontal: 25,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(20, 0, 0, 0),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        spacing: 5,
        children: [
          Text(
            style: TextStyle(
              fontSize: theme.mobileTexts.h4.fontSize,
              fontWeight: FontWeight.bold,
            ),
            'Try Out Demo?',
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b3.fontSize,
                    fontWeight: FontWeight.normal,
                  ),
                  'Do you want to try the app with a DEMO ACCOUNT, before proceeding to create your own Account and Store?',
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b3.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                  'Click The Button Below to Login to a Demo Account',
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          // Container(
          //   padding: EdgeInsets.symmetric(
          //     vertical: 10,
          //     horizontal: 10,
          //   ),
          //   decoration: BoxDecoration(
          //     borderRadius: BorderRadius.circular(5),
          //     color: const Color.fromARGB(
          //       181,
          //       245,
          //       245,
          //       245,
          //     ),
          //     border: Border.all(
          //       color: Colors.grey.shade300,
          //     ),
          //   ),
          //   child: Column(
          //     spacing: 3,
          //     children: [
          //       Row(
          //         spacing: 5,
          //         mainAxisAlignment:
          //             MainAxisAlignment.center,
          //         children: [
          //           Text(
          //             textAlign: TextAlign.center,
          //             style: TextStyle(
          //               fontSize:
          //                   theme.mobileTexts.b4.fontSize,
          //               fontWeight: FontWeight.bold,
          //               color: Colors.grey,
          //             ),
          //             'EMAIL:',
          //           ),
          //           Text(
          //             textAlign: TextAlign.center,
          //             style: TextStyle(
          //               fontSize:
          //                   theme.mobileTexts.b2.fontSize,
          //               fontWeight: FontWeight.bold,
          //               color:
          //                   theme
          //                       .lightModeColor
          //                       .secColor200,
          //             ),
          //             'stockalltest@gmail.com',
          //           ),
          //         ],
          //       ),
          //       Row(
          //         spacing: 5,
          //         mainAxisAlignment:
          //             MainAxisAlignment.center,
          //         children: [
          //           Text(
          //             textAlign: TextAlign.center,
          //             style: TextStyle(
          //               fontSize:
          //                   theme.mobileTexts.b4.fontSize,
          //               fontWeight: FontWeight.bold,
          //               color: Colors.grey,
          //             ),
          //             'PASSWORD:',
          //           ),
          //           Text(
          //             textAlign: TextAlign.center,
          //             style: TextStyle(
          //               fontSize:
          //                   theme.mobileTexts.b2.fontSize,
          //               fontWeight: FontWeight.bold,
          //               color:
          //                   theme
          //                       .lightModeColor
          //                       .secColor200,
          //             ),
          //             'test123',
          //           ),
          //         ],
          //       ),
          //       Row(
          //         spacing: 5,
          //         mainAxisAlignment:
          //             MainAxisAlignment.center,
          //         children: [
          //           Text(
          //             textAlign: TextAlign.center,
          //             style: TextStyle(
          //               fontSize:
          //                   theme.mobileTexts.b4.fontSize,
          //               fontWeight: FontWeight.bold,
          //               color: Colors.grey,
          //             ),
          //             'PIN:',
          //           ),
          //           Text(
          //             textAlign: TextAlign.center,
          //             style: TextStyle(
          //               fontSize:
          //                   theme.mobileTexts.b2.fontSize,
          //               fontWeight: FontWeight.bold,
          //               color:
          //                   theme
          //                       .lightModeColor
          //                       .secColor200,
          //             ),
          //             '0000',
          //           ),
          //         ],
          //       ),
          //     ],
          //   ),
          // ),
          // SizedBox(height: 10),
          ActionButtonAlt(
            text: 'Login Demo',
            icon: Icon(
              size: 20,
              color: Colors.white,
              Icons.login,
            ),
            action: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return LoginPage(useDemoLogin: true);
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class ContactSupportSectionWidget extends StatelessWidget {
  const ContactSupportSectionWidget({
    super.key,
    required this.theme,
  });

  final ThemeProvider theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: 20,
        horizontal: 25,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(20, 0, 0, 0),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        spacing: 5,
        children: [
          Text(
            style: TextStyle(
              fontSize: theme.mobileTexts.h4.fontSize,
              fontWeight: FontWeight.bold,
            ),
            'Contact Customer Care?',
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b3.fontSize,
                    fontWeight: FontWeight.normal,
                  ),
                  'Would You Like to Speak With Our Customer Care for Assistance and Information?',
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                phoneCall();
                copyToClipboard(
                  context: context,
                  text: getContactPhoneNumber(
                    formatIndex: 2,
                  ),
                );
              },
              mouseCursor: SystemMouseCursors.click,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  spacing: 5,
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Text(
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b3.fontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                      'CALL:',
                    ),
                    Icon(
                      size: 20,
                      color: Colors.grey,
                      Icons.phone,
                    ),
                    Text(
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b2.fontSize,
                        fontWeight: FontWeight.bold,
                        color:
                            theme
                                .lightModeColor
                                .secColor200,
                      ),
                      getContactPhoneNumber(formatIndex: 3),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
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
    );
  }
}

class ActionButtonAlt extends StatelessWidget {
  final Function()? action;
  final String text;
  final Icon? icon;

  const ActionButtonAlt({
    super.key,
    this.action,
    required this.text,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: theme.lightModeColor.prColor300,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: theme.lightModeColor.prColor200,
            width: 1,
          ),
        ),
        child: InkWell(
          mouseCursor: SystemMouseCursors.click,
          borderRadius: BorderRadius.circular(5),
          onTap: () {
            action != null
                ? action!()
                : Navigator.of(context).pop();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 8),

            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 5,
                children: [
                  Text(
                    style: TextStyle(
                      color: Colors.white,
                      fontSize:
                          theme.mobileTexts.b3.fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                    text,
                  ),
                  Visibility(
                    visible: icon != null,
                    child: icon ?? Container(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
