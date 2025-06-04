import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/providers/theme_provider.dart';

class SignupTwoMobile extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController idController;
  const SignupTwoMobile({
    super.key,
    required this.idController,
    required this.phoneController,
    required this.nameController,
  });

  @override
  State<SignupTwoMobile> createState() =>
      _SignupTwoMobileState();
}

class _SignupTwoMobileState extends State<SignupTwoMobile> {
  void checkInputs() {
    if (widget.phoneController.text.isEmpty ||
        widget.nameController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          var theme = Provider.of<ThemeProvider>(context);
          return InfoAlert(
            theme: theme,
            message: 'Please fill out all Fields',
            title: 'Empty Input',
          );
        },
      );
    } else {
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) {
      //       return VerifyPhone(
      //         number: widget.phoneController.text,
      //       );
      //     },
      //   ),
      // );
      widget.nameController.clear();
      widget.idController.clear();
      widget.phoneController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = Provider.of<ThemeProvider>(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 35.0,
          ),
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(
              context,
            ).copyWith(scrollbars: false),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 60),
                  Row(
                    spacing: 10,
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Image.asset(mainLogoIcon, height: 20),
                      Text(
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 25,
                          fontWeight:
                              theme
                                  .mobileTexts
                                  .h3
                                  .fontWeightBold,
                        ),
                        appName,
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  Column(
                    spacing: 8,
                    children: [
                      Row(
                        children: [
                          Text(
                            style: TextStyle(
                              color:
                                  theme
                                      .lightModeColor
                                      .shadesColorBlack,
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .h3
                                      .fontSize,
                              fontWeight:
                                  theme
                                      .mobileTexts
                                      .h3
                                      .fontWeightBold,
                            ),
                            'Finish Setting Up',
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            style:
                                Provider.of<ThemeProvider>(
                                      context,
                                    )
                                    .mobileTexts
                                    .b1
                                    .textStyleNormal,
                            "Finish Filling out other information",
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  Column(
                    spacing: 10,
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        style:
                            theme
                                .mobileTexts
                                .b2
                                .textStyleBold,
                        'Enter Your Name',
                      ),
                      TextFormField(
                        keyboardType: TextInputType.name,
                        textCapitalization:
                            TextCapitalization.words,
                        autocorrect: true,
                        enableSuggestions: true,
                        decoration: InputDecoration(
                          hintText: 'Enter Name',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            Icons.person,
                            size: 20,
                            color:
                                theme
                                    .lightModeColor
                                    .secColor200,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color:
                                  theme
                                      .lightModeColor
                                      .prColor200,
                              width: 1.0,
                            ),
                            borderRadius:
                                BorderRadius.circular(15),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color:
                                  theme
                                      .lightModeColor
                                      .prColor300,
                              width: 1.5,
                            ),
                            borderRadius:
                                BorderRadius.circular(10),
                          ),
                        ),
                        controller: widget.nameController,
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Column(
                    spacing: 10,
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        style:
                            theme
                                .mobileTexts
                                .b2
                                .textStyleBold,
                        'Enter Your Phone number',
                      ),
                      TextFormField(
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: 'Phone Number',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            Icons.phone_outlined,
                            size: 20,
                            color:
                                theme
                                    .lightModeColor
                                    .secColor200,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color:
                                  theme
                                      .lightModeColor
                                      .prColor200,
                              width: 1.0,
                            ),
                            borderRadius:
                                BorderRadius.circular(15),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color:
                                  theme
                                      .lightModeColor
                                      .prColor300,
                              width: 1.5,
                            ),
                            borderRadius:
                                BorderRadius.circular(10),
                          ),
                        ),
                        controller: widget.phoneController,
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Column(
                    spacing: 10,
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        style:
                            theme
                                .mobileTexts
                                .b2
                                .textStyleBold,
                        'Enter Marketer Id (Optional)',
                      ),
                      TextFormField(
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          hintText: 'Enter Id',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            Icons.person_outline_outlined,
                            size: 20,
                            color:
                                theme
                                    .lightModeColor
                                    .secColor200,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color:
                                  theme
                                      .lightModeColor
                                      .prColor200,
                              width: 1.0,
                            ),
                            borderRadius:
                                BorderRadius.circular(15),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color:
                                  theme
                                      .lightModeColor
                                      .prColor300,
                              width: 1.5,
                            ),
                            borderRadius:
                                BorderRadius.circular(10),
                          ),
                        ),
                        controller: widget.idController,
                      ),
                    ],
                  ),
                  SizedBox(height: 40),
                  MainButtonP(
                    themeProvider: theme,
                    action: () {
                      // checkInputs();
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) {
                      //       return VerifyPhone(
                      //         number:
                      //             widget
                      //                 .phoneController
                      //                 .text,
                      //       );
                      //     },
                      //   ),
                      // );
                    },
                    text: 'Proceed to Verify',
                  ),
                  SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
