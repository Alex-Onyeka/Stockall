import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stockitt/providers/theme_provider.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController emailController =
      TextEditingController();
  TextEditingController phoneController =
      TextEditingController();
  TextEditingController passwordController =
      TextEditingController();

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
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
            child: Column(
              children: [
                SizedBox(height: 50),
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
                          'Get Started Now',
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
                          "Let's create you Account",
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
                    Text('Enter Email'),
                    TextFormField(
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.email_outlined,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color:
                                theme
                                    .lightModeColor
                                    .prColor300,
                            width: 1.0,
                          ),
                          borderRadius:
                              BorderRadius.circular(10),
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
                      controller: emailController,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
