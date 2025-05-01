import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stockitt/components/buttons/main_button_p.dart';
import 'package:stockitt/constants/constants_main.dart';
import 'package:stockitt/pages/authentication/sign_up/sign_up_page.dart';
import 'package:stockitt/pages/authentication/splash_screens/splash_screen.dart';
import 'package:stockitt/providers/theme_provider.dart';

class AuthLandingMobile extends StatelessWidget {
  final ThemeProvider themeProvider;
  final BoxConstraints constraints;
  const AuthLandingMobile({
    super.key,
    required this.themeProvider,
    required this.constraints,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(25, 43, 117, 1),
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: SizedBox(
                  width: double.infinity,
                  child: Opacity(
                    opacity: 0.1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                      ),
                      child: SizedBox(
                        child: Image.asset(
                          logoIconWhite,
                          fit: BoxFit.contain,
                          width: 200,
                          height: 200,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 40,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 50.0,
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Text(
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                height: 0,
                                color:
                                    themeProvider
                                        .lightModeColor
                                        .shadesColorBlack,
                                fontSize:
                                    themeProvider
                                        .returnPlatform(
                                          constraints,
                                          context,
                                        )
                                        .h1
                                        .fontSize,
                                fontWeight:
                                    themeProvider
                                        .returnPlatform(
                                          constraints,
                                          context,
                                        )
                                        .h1
                                        .fontWeightBold,
                              ),
                              'Welcome to Stockitt',
                            ),
                            SizedBox(height: 20),
                            Text(
                              textAlign: TextAlign.center,
                              style:
                                  Provider.of<
                                        ThemeProvider
                                      >(context)
                                      .returnPlatform(
                                        constraints,
                                        context,
                                      )
                                      .b1
                                      .textStyleNormal,
                              'Lorem ipsum dolor sit amet, consectetur  adipiscing elit ut aliquam, purus sit  amet luctus v magna fringilla urna',
                            ),
                            SizedBox(height: 20),
                            MainButtonP(
                              action: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return SignUpPage();
                                    },
                                  ),
                                );
                              },
                              text: 'Create an Account',
                              themeProvider: themeProvider,
                            ),
                            SizedBox(height: 10),
                            InkWell(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return SplashScreen();
                                    },
                                  ),
                                );
                              },
                              child: Container(
                                margin: EdgeInsets.only(
                                  bottom: 30,
                                ),
                                padding:
                                    EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius:
                                      BorderRadius.circular(
                                        10,
                                      ),
                                  border: Border.all(
                                    color:
                                        themeProvider
                                            .lightModeColor
                                            .prColor300,
                                    width: 1.5,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    style: TextStyle(
                                      color:
                                          themeProvider
                                              .lightModeColor
                                              .prColor300,
                                      fontSize:
                                          themeProvider
                                              .returnPlatform(
                                                constraints,
                                                context,
                                              )
                                              .b1
                                              .fontSize,
                                      fontWeight:
                                          themeProvider
                                              .returnPlatform(
                                                constraints,
                                                context,
                                              )
                                              .b1
                                              .fontWeightRegular,
                                    ),
                                    'Already Have an account? Login',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Image.asset(appMockUp),
        ],
      ),
    );
  }
}
