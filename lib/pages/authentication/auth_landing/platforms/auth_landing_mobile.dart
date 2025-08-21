import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/components/buttons/main_button_transparent.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/authentication/login/login_page.dart';
import 'package:stockall/pages/authentication/sign_up/sign_up_page.dart';
import 'package:stockall/providers/theme_provider.dart';

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
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height:
                  MediaQuery.of(context).size.height * 0.52,
              color: Color.fromRGBO(25, 43, 117, 1),
              child: Stack(
                alignment: Alignment(0, 0.3),
                children: [
                  SizedBox(
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
                  Positioned(
                    top: 20,
                    child: Image.asset(
                      appMockUp,
                      height: 420,
                    ),
                  ),
                ],
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 30,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 50.0,
                        ),
                        child: Text(
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
                          'Welcome to $appName',
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        textAlign: TextAlign.center,
                        style:
                            Provider.of<ThemeProvider>(
                                  context,
                                )
                                .returnPlatform(
                                  constraints,
                                  context,
                                )
                                .b1
                                .textStyleNormal,
                        appDesc,
                      ),
                      SizedBox(height: 20),

                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                        ),
                        child: Column(
                          children: [
                            MainButtonP(
                              action: () {
                                Navigator.push(
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
                            MainButtonTransparent(
                              text: 'Login',
                              themeProvider: themeProvider,
                              constraints: constraints,
                              action: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return LoginPage();
                                    },
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
