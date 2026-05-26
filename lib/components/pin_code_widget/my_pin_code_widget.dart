import 'package:flutter/material.dart';
import 'package:stockall/components/alert_dialogues/dialog_template.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/text_fields/pin_code.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/dashboard/employee_auth_page/emp_auth.dart';

class MyPinCodeWidget extends StatefulWidget {
  const MyPinCodeWidget({super.key});

  @override
  State<MyPinCodeWidget> createState() =>
      _MyPinCodeWidgetState();
}

class _MyPinCodeWidgetState extends State<MyPinCodeWidget> {
  TextEditingController pinController =
      TextEditingController();

  void addDigit(String digit) {
    if (pinController.text.length < 4) {
      pinController.text += digit;

      pinController.selection = TextSelection.fromPosition(
        TextPosition(offset: pinController.text.length),
      );
    }
  }

  void removeDigit() {
    if (pinController.text.isNotEmpty) {
      pinController.text = pinController.text.substring(
        0,
        pinController.text.length - 1,
      );

      pinController.selection = TextSelection.fromPosition(
        TextPosition(offset: pinController.text.length),
      );
    }
  }

  void actionPressed(String value) {
    if (value != '00') {
      addDigit(value);
    } else {
      removeDigit();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Container(
      width:
          screenWidth(context) < mobileScreenSmall
              ? screenWidth(context) * 0.95
              : mobileScreen - 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(31, 0, 0, 0),
            blurRadius: 5,
          ),
        ],
      ),
      padding: EdgeInsetsDirectional.symmetric(
        horizontal:
            screenWidth(context) < mobileScreenSmall
                ? 10
                : 20,
        vertical: 20,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            children: [
              SizedBox(height: 20),
              Text(
                style: TextStyle(
                  fontSize: theme.mobileTexts.h2.fontSize,
                  fontWeight: FontWeight.bold,
                ),
                'Enter PIN',
              ),
              SizedBox(height: 10),
              Text(
                style: TextStyle(
                  fontSize: theme.mobileTexts.b2.fontSize,
                  fontWeight: FontWeight.normal,
                ),
                'Enter Access PIN before you can proceed to perform this action',
              ),
            ],
          ),
          SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 0,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                      'Enter PIN',
                    ),
                  ],
                ),
                SizedBox(height: 10),
                PinCodeWidget(
                  focus: true,
                  hideText: true,
                  controller: pinController,
                  action: () async {
                    if (pinController.text !=
                        currentUser().pin) {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return InfoAlert(
                            theme: theme,
                            message:
                                'Pin is Incorrect. Please Try again',
                            title: 'Incorrect PIN',
                          );
                        },
                      );
                      print(
                        "Pin Code Now: ${pinController.text}",
                      );
                      setState(() {
                        pinController.clear();
                      });
                    } else {
                      Navigator.of(context).pop(true);
                    }
                  },
                  // text: pin1Controller.text,
                ),
                SizedBox(height: 15),
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                  ),
                  child: Column(
                    spacing: 10,
                    children: [
                      Row(
                        spacing: 10,
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          CalcButtonPin(
                            theme: theme,
                            action: () {
                              actionPressed('1');
                            },
                            text: '1',
                          ),
                          CalcButtonPin(
                            theme: theme,
                            action: () {
                              actionPressed('2');
                            },
                            text: '2',
                          ),
                          CalcButtonPin(
                            theme: theme,
                            action: () {
                              actionPressed('3');
                            },
                            text: '3',
                          ),
                          CalcButtonPin(
                            theme: theme,
                            action: () {
                              actionPressed('4');
                            },
                            text: '4',
                          ),
                        ],
                      ),
                      Row(
                        spacing: 10,
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          CalcButtonPin(
                            theme: theme,
                            action: () {
                              actionPressed('5');
                            },
                            text: '5',
                          ),
                          CalcButtonPin(
                            theme: theme,
                            action: () {
                              actionPressed('6');
                            },
                            text: '6',
                          ),
                          CalcButtonPin(
                            theme: theme,
                            action: () {
                              actionPressed('7');
                            },
                            text: '7',
                          ),
                          CalcButtonPin(
                            theme: theme,
                            action: () {
                              actionPressed('8');
                            },
                            text: '8',
                          ),
                        ],
                      ),
                      Row(
                        spacing: 10,
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          CalcButtonPin(
                            theme: theme,
                            action: () {
                              actionPressed('9');
                            },
                            text: '9',
                          ),
                          CalcButtonPin(
                            theme: theme,
                            action: () {
                              actionPressed('0');
                            },
                            text: '0',
                          ),
                          CalcButtonPin(
                            theme: theme,
                            action: () {
                              actionPressed('00');
                            },
                            // text:
                            //     '<=',
                            icon: Icons.backspace_outlined,
                            height: 20,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 15),
              ],
            ),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}

Future<bool> pinCodeAction({
  required BuildContext context,
}) async {
  var theme = returnTheme(context, listen: false);
  // var tempRes  = false;
  bool? res = await showDialog(
    context: context,
    builder: (customContext) {
      return DialogTemplate(
        theme: theme,
        message: 'message',
        title: 'title',
        action: () {},
        showBottomActionButtons: false,
        showTopSection: false,
        widget: MyPinCodeWidget(),
      );
    },
  );
  // tempRes = res;
  return res ?? false;
}
