import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stockitt/components/buttons/main_button_p.dart';
import 'package:stockitt/constants/constants_main.dart';
import 'package:stockitt/pages/authentication/verify_phone/verify_phone.dart';
import 'package:stockitt/providers/theme_provider.dart';

class SignupTwo extends StatefulWidget {
  const SignupTwo({super.key});

  @override
  State<SignupTwo> createState() => _SignupTwoState();
}

class _SignupTwoState extends State<SignupTwo> {
  TextEditingController phoneController =
      TextEditingController();
  TextEditingController nameController =
      TextEditingController();
  TextEditingController idController =
      TextEditingController();

  bool checked = false;

  @override
  void dispose() {
    super.dispose();
    phoneController.dispose();
    idController.dispose();
    nameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Provider.of<ThemeProvider>(context);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
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
                    SizedBox(height: 50),
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
                          'Stockitt',
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
                          keyboardType: TextInputType.name,
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
                            enabledBorder:
                                OutlineInputBorder(
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
                            focusedBorder:
                                OutlineInputBorder(
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
                          controller: phoneController,
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
                            enabledBorder:
                                OutlineInputBorder(
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
                            focusedBorder:
                                OutlineInputBorder(
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
                          controller: phoneController,
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
                          'Enter Marketer Id',
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
                            enabledBorder:
                                OutlineInputBorder(
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
                            focusedBorder:
                                OutlineInputBorder(
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
                          controller: idController,
                        ),
                      ],
                    ),
                    SizedBox(height: 40),
                    MainButtonP(
                      themeProvider: theme,
                      action: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return VerifyPhone();
                            },
                          ),
                        );
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
      ),
    );
  }
}
