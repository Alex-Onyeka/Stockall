import 'package:flutter/material.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/dialog_template.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/main.dart';
import 'package:stockall/components/text_fields/pin_code.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/pages/dashboard/employee_auth_page/emp_auth.dart';

class ManagePinWidget extends StatefulWidget {
  const ManagePinWidget({super.key});

  @override
  State<ManagePinWidget> createState() =>
      _ManagePinWidgetState();
}

class _ManagePinWidgetState extends State<ManagePinWidget> {
  TextEditingController pinController =
      TextEditingController();
  TextEditingController confirmPinController =
      TextEditingController();

  TextEditingController getController() {
    return currentForm == 1
        ? pinController
        : confirmPinController;
  }

  FocusNode confirmControllerFocus = FocusNode();

  void addDigit(String digit) {
    if (getController().text.length < 4) {
      getController().text += digit;

      getController()
          .selection = TextSelection.fromPosition(
        TextPosition(offset: getController().text.length),
      );
    }
  }

  void removeDigit() {
    if (getController().text.isNotEmpty) {
      getController().text = getController().text.substring(
        0,
        getController().text.length - 1,
      );

      getController()
          .selection = TextSelection.fromPosition(
        TextPosition(offset: getController().text.length),
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

  int currentForm = 1;

  void switchFormField(int value) {
    setState(() {
      currentForm = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return SizedBox(
      height:
          screenWidth(context) < mobileScreen
              ? 420
              : screenHeight(context) - 120,
      width:
          screenWidth(context) < mobileScreenSmall
              ? screenWidth(context) * 0.95
              : mobileScreen - 100,
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  height:
                      screenWidth(context) < mobileScreen
                          ? 420
                          : screenHeight(context) - 120,
                  width:
                      screenWidth(context) <
                              mobileScreenSmall
                          ? screenWidth(context) * 0.95
                          : mobileScreen - 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(
                          31,
                          0,
                          0,
                          0,
                        ),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  padding: EdgeInsetsDirectional.symmetric(
                    horizontal:
                        screenWidth(context) <
                                mobileScreenSmall
                            ? 10
                            : 20,
                    vertical: 10,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            SizedBox(height: 20),
                            Text(
                              style: TextStyle(
                                fontSize:
                                    theme
                                        .mobileTexts
                                        .h2
                                        .fontSize,
                                fontWeight: FontWeight.bold,
                              ),
                              'Update PIN',
                            ),
                            SizedBox(height: 7),
                            Text(
                              style: TextStyle(
                                fontSize:
                                    theme
                                        .mobileTexts
                                        .b2
                                        .fontSize,
                                fontWeight:
                                    FontWeight.normal,
                              ),
                              'Enter New Access PIN Below and Save, To Update',
                            ),
                            SizedBox(height: 7),
                            Container(
                              padding: EdgeInsets.symmetric(
                                vertical: 7,
                                horizontal: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius:
                                    BorderRadius.circular(
                                      3,
                                    ),
                              ),
                              child: Row(
                                mainAxisSize:
                                    MainAxisSize.min,
                                spacing: 5,
                                children: [
                                  Text(
                                    style: TextStyle(
                                      fontSize:
                                          theme
                                              .mobileTexts
                                              .b3
                                              .fontSize,
                                    ),
                                    'Current Pin:',
                                  ),
                                  Text(
                                    style: TextStyle(
                                      fontSize:
                                          theme
                                              .mobileTexts
                                              .b3
                                              .fontSize,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                    returnShopProvider()
                                            .userShop()
                                            ?.accessPin ??
                                        'Null',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 15),
                        Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  style: TextStyle(
                                    fontWeight:
                                        FontWeight.bold,
                                    color:
                                        Colors
                                            .grey
                                            .shade700,
                                  ),
                                  'Enter New PIN',
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            PinCodeWidget(
                              onTap: () {
                                switchFormField(1);
                              },
                              focus: true,
                              hideText: false,
                              controller: pinController,
                              action: () {
                                confirmControllerFocus
                                    .requestFocus();
                                switchFormField(2);
                              },
                              // text: pin1Controller.text,
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                Text(
                                  style: TextStyle(
                                    fontWeight:
                                        FontWeight.bold,
                                    color:
                                        Colors
                                            .grey
                                            .shade700,
                                  ),
                                  'Confirm PIN',
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            PinCodeWidget(
                              focusNode:
                                  confirmControllerFocus,
                              onTap: () {
                                switchFormField(2);
                              },
                              hideText: false,
                              controller:
                                  confirmPinController,
                              action: () async {
                                // if (confirmPinController.text !=
                                //     currentUser().pin) {
                                //   showDialog(
                                //     context: context,
                                //     builder: (context) {
                                //       return InfoAlert(
                                //         theme: theme,
                                //         message:
                                //             'Pin is Incorrect. Please Try again',
                                //         title: 'Incorrect PIN',
                                //       );
                                //     },
                                //   );
                                //   await mainLocalLog(
                                //     "Pin Code Now: ${confirmPinController.text}",
                                //   );
                                //   setState(() {
                                //     confirmPinController.clear();
                                //   });
                                // } else {
                                //   Navigator.of(context).pop(true);
                                // }
                              },
                              // text: pin1Controller.text,
                            ),
                            SizedBox(height: 15),
                            Visibility(
                              visible:
                                  screenWidth(context) >
                                  mobileScreen,
                              child: Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color:
                                      Colors.grey.shade200,
                                ),
                                child: Column(
                                  spacing: 10,
                                  children: [
                                    Row(
                                      spacing: 10,
                                      mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                      children: [
                                        CalcButtonPin(
                                          theme: theme,
                                          action: () {
                                            actionPressed(
                                              '1',
                                            );
                                          },
                                          text: '1',
                                        ),
                                        CalcButtonPin(
                                          theme: theme,
                                          action: () {
                                            actionPressed(
                                              '2',
                                            );
                                          },
                                          text: '2',
                                        ),
                                        CalcButtonPin(
                                          theme: theme,
                                          action: () {
                                            actionPressed(
                                              '3',
                                            );
                                          },
                                          text: '3',
                                        ),
                                        CalcButtonPin(
                                          theme: theme,
                                          action: () {
                                            actionPressed(
                                              '4',
                                            );
                                          },
                                          text: '4',
                                        ),
                                      ],
                                    ),
                                    Row(
                                      spacing: 10,
                                      mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                      children: [
                                        CalcButtonPin(
                                          theme: theme,
                                          action: () {
                                            actionPressed(
                                              '5',
                                            );
                                          },
                                          text: '5',
                                        ),
                                        CalcButtonPin(
                                          theme: theme,
                                          action: () {
                                            actionPressed(
                                              '6',
                                            );
                                          },
                                          text: '6',
                                        ),
                                        CalcButtonPin(
                                          theme: theme,
                                          action: () {
                                            actionPressed(
                                              '7',
                                            );
                                          },
                                          text: '7',
                                        ),
                                        CalcButtonPin(
                                          theme: theme,
                                          action: () {
                                            actionPressed(
                                              '8',
                                            );
                                          },
                                          text: '8',
                                        ),
                                      ],
                                    ),
                                    Row(
                                      spacing: 10,
                                      mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                      children: [
                                        CalcButtonPin(
                                          theme: theme,
                                          action: () {
                                            actionPressed(
                                              '9',
                                            );
                                          },
                                          text: '9',
                                        ),
                                        CalcButtonPin(
                                          theme: theme,
                                          action: () {
                                            actionPressed(
                                              '0',
                                            );
                                          },
                                          text: '0',
                                        ),
                                        CalcButtonPin(
                                          theme: theme,
                                          action: () {
                                            actionPressed(
                                              '00',
                                            );
                                          },
                                          // text:
                                          //     '<=',
                                          icon:
                                              Icons
                                                  .backspace_outlined,
                                          height: 20,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 15),
                          ],
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
                Visibility(
                  visible:
                      returnShopProvider(
                        context: context,
                      ).isUpdatePin,
                  child: Container(
                    height:
                        screenWidth(context) < mobileScreen
                            ? 420
                            : screenHeight(context) - 120,
                    width:
                        screenWidth(context) <
                                mobileScreenSmall
                            ? screenWidth(context) * 0.95
                            : mobileScreen - 100,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(
                        34,
                        158,
                        158,
                        158,
                      ),
                    ),
                    child: Center(
                      child: returnCompProvider(
                        context,
                      ).showLoader(message: 'Updating'),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Row(
            spacing: 15,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Ink(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.grey.shade200,
                  ),
                  child: InkWell(
                    mouseCursor: SystemMouseCursors.click,
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),

                      child: Center(
                        child: Text(
                          style: TextStyle(
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b3
                                    .fontSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                          'Cancel',
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Ink(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color:
                        theme.lightModeColor.errorColor200,
                  ),
                  child: InkWell(
                    mouseCursor: SystemMouseCursors.click,
                    onTap: () {
                      if (!returnShopProvider()
                          .isUpdatePin) {
                        if (pinController.text.isEmpty ||
                            confirmPinController
                                .text
                                .isEmpty) {
                          showDialog(
                            context: context,
                            builder: (errorContext) {
                              return InfoAlert(
                                theme: theme,
                                message:
                                    'Empty Field(s) Detected. Please enter PIN to Proceed.',
                                title: 'Empty Field(s)',
                              );
                            },
                          );
                        } else if (pinController.text !=
                            confirmPinController.text) {
                          showDialog(
                            context: context,
                            builder: (errorContext) {
                              return InfoAlert(
                                theme: theme,
                                message:
                                    'Pin Fields 1 and 2 are not the same. Please Correct and try again.',
                                title: 'Pins Not The Same',
                              );
                            },
                          );
                        } else {
                          showDialog(
                            context: context,
                            builder: (confirmContext) {
                              return ConfirmationAlert(
                                theme: theme,
                                message:
                                    'You are about to update your PIN. Are you sure you want to proceed?',
                                title: 'Are you Sure?',
                                action: () async {
                                  Navigator.of(
                                    confirmContext,
                                  ).pop();
                                  var res =
                                      await returnShopProvider()
                                          .updateShopPin(
                                            newPin:
                                                confirmPinController
                                                    .text
                                                    .trim(),
                                          );
                                  if (res == 1 &&
                                      context.mounted) {
                                    Navigator.of(
                                      context,
                                    ).pop();
                                  }
                                },
                              );
                            },
                          );
                        }
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),

                      child: Center(
                        child: Text(
                          style: TextStyle(
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b3
                                    .fontSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          'Proceed',
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

void manageAccessPinAction({
  required BuildContext context,
}) {
  var theme = returnTheme(context, listen: false);
  showDialog(
    context: context,
    builder: (accessContext) {
      return DialogTemplate(
        theme: theme,
        message: 'message',
        title: 'title',
        action: () {},
        showTopSection: false,
        showBottomActionButtons: false,
        widget: ManagePinWidget(),
      );
    },
  );
}
