import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:stockitt/components/buttons/main_button_p.dart';
import 'package:stockitt/constants/constants_main.dart';
import 'package:stockitt/providers/theme_provider.dart';

class EnterCode extends StatelessWidget {
  final String number;
  const EnterCode({super.key, required this.number});

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context);
    return SafeArea(
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 35.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Row(
                      spacing: 10,
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          mainLogoIcon,
                          height: 20,
                        ),
                        Text(
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 25,
                            fontWeight:
                                themeProvider
                                    .mobileTexts
                                    .h3
                                    .fontWeightBold,
                          ),
                          'Stockitt',
                        ),
                      ],
                    ),
                    SizedBox(height: 30),
                    Text(
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize:
                            themeProvider
                                .mobileTexts
                                .h2
                                .fontSize,
                        fontWeight:
                            themeProvider
                                .mobileTexts
                                .h2
                                .fontWeightBold,
                      ),
                      'OTP Verification',
                    ),

                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30.0,
                      ),
                      child: Wrap(
                        spacing: 5,
                        alignment: WrapAlignment.center,
                        children: [
                          Text(
                            'A ',
                            textAlign: TextAlign.center,
                            style:
                                themeProvider
                                    .desktopTexts
                                    .b1
                                    .textStyleNormal,
                          ),
                          Text(
                            '6-digit ',
                            textAlign: TextAlign.center,
                            style:
                                themeProvider
                                    .desktopTexts
                                    .b1
                                    .textStyleBold,
                          ),
                          Text(
                            'code was sent to ',
                            textAlign: TextAlign.center,
                            style:
                                themeProvider
                                    .desktopTexts
                                    .b1
                                    .textStyleNormal,
                          ),
                          Text(
                            number,
                            textAlign: TextAlign.center,
                            style:
                                themeProvider
                                    .desktopTexts
                                    .b1
                                    .textStyleBold,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                  ),
                  child: PinCodeTextField(
                    appContext: context,
                    length: 6,
                    onChanged: (value) {
                      // print("OTP: $value");
                    },
                    onCompleted: (value) {
                      // print("Completed with OTP: $value");
                      // You can verify OTP here
                    },
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(
                        5,
                      ),
                      fieldHeight: 50,
                      fieldWidth: 40,
                      activeFillColor: Colors.white,
                      selectedFillColor:
                          Colors.grey.shade100,
                      inactiveFillColor:
                          Colors.grey.shade100,
                      activeColor:
                          themeProvider
                              .lightModeColor
                              .secColor200,
                      selectedColor:
                          themeProvider
                              .lightModeColor
                              .prColor300,
                      inactiveColor: Colors.grey,
                    ),
                    cursorColor:
                        themeProvider
                            .lightModeColor
                            .prColor300,
                    keyboardType: TextInputType.number,
                    animationType: AnimationType.fade,
                    enableActiveFill: true,
                  ),
                ),
                SizedBox(height: 20),
                MainButtonP(
                  themeProvider: themeProvider,
                  action: () {},
                  text: 'Verify Phone',
                ),
                SizedBox(height: 15),
                InkWell(
                  onTap: () {},
                  child: Row(
                    spacing: 5,
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Text("Didn't receive a Code?"),
                      Text(
                        style: TextStyle(
                          color:
                              themeProvider
                                  .lightModeColor
                                  .secColor200,
                        ),
                        'Resend',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
