import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storrec/components/alert_dialogues/info_alert.dart';
import 'package:storrec/components/buttons/main_button_p.dart';
import 'package:storrec/constants/constants_main.dart';
import 'package:storrec/pages/authentication/verify_phone/verify_phone.dart';
import 'package:storrec/providers/theme_provider.dart';

class SignupTwoDesktop extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController idController;
  final TextEditingController phoneController;
  const SignupTwoDesktop({
    super.key,
    required this.idController,
    required this.phoneController,
    required this.nameController,
  });

  @override
  State<SignupTwoDesktop> createState() =>
      _SignupTwoDesktopState();
}

class _SignupTwoDesktopState
    extends State<SignupTwoDesktop> {
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
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return VerifyPhone(
              number: widget.phoneController.text,
            );
          },
        ),
      );
      widget.nameController.clear();
      widget.idController.clear();
      widget.phoneController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = Provider.of<ThemeProvider>(context);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(backGroundImage),
            fit:
                BoxFit
                    .cover, // Options: cover, contain, fill, fitWidth, fitHeight
          ),
        ),
        child: Stack(
          children: [
            Container(
              color: const Color.fromARGB(
                201,
                255,
                255,
                255,
              ),
            ),
            SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Container(
                      margin: EdgeInsets.symmetric(
                        vertical: 40,
                      ),
                      width: 550,
                      padding: EdgeInsets.symmetric(
                        horizontal: 50,
                        vertical: 30,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          20,
                        ),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(
                              46,
                              0,
                              0,
                              0,
                            ),
                            blurRadius: 10,
                            spreadRadius: 5,
                            offset: Offset(0, 0),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          SizedBox(height: 10),
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
                                      theme
                                          .mobileTexts
                                          .h3
                                          .fontWeightBold,
                                ),
                                appName,
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
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
                                        Provider.of<
                                              ThemeProvider
                                            >(context)
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
                                keyboardType:
                                    TextInputType.name,
                                autocorrect: true,
                                enableSuggestions: true,
                                decoration: InputDecoration(
                                  hintText: 'Enter Name',
                                  hintStyle: TextStyle(
                                    color:
                                        Colors
                                            .grey
                                            .shade500,
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
                                        BorderRadius.circular(
                                          15,
                                        ),
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
                                        BorderRadius.circular(
                                          10,
                                        ),
                                  ),
                                ),
                                controller:
                                    widget.nameController,
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
                                keyboardType:
                                    TextInputType.phone,
                                decoration: InputDecoration(
                                  hintText: 'Phone Number',
                                  hintStyle: TextStyle(
                                    color:
                                        Colors
                                            .grey
                                            .shade500,
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
                                        BorderRadius.circular(
                                          15,
                                        ),
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
                                        BorderRadius.circular(
                                          10,
                                        ),
                                  ),
                                ),
                                controller:
                                    widget.phoneController,
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
                                keyboardType:
                                    TextInputType.text,
                                decoration: InputDecoration(
                                  hintText: 'Enter Id',
                                  hintStyle: TextStyle(
                                    color:
                                        Colors
                                            .grey
                                            .shade500,
                                    fontSize: 14,
                                  ),
                                  prefixIcon: Icon(
                                    Icons
                                        .person_outline_outlined,
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
                                        BorderRadius.circular(
                                          15,
                                        ),
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
                                        BorderRadius.circular(
                                          10,
                                        ),
                                  ),
                                ),
                                controller:
                                    widget.idController,
                              ),
                            ],
                          ),
                          SizedBox(height: 40),
                          MainButtonP(
                            themeProvider: theme,
                            action: () {
                              checkInputs();
                            },
                            text: 'Proceed to Verify',
                          ),
                          SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
