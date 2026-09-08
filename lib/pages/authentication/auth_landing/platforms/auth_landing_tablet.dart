import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/components/buttons/main_button_transparent.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/authentication/explore_page/explore_page.dart';
import 'package:stockall/pages/authentication/login/login_page.dart';
import 'package:stockall/pages/authentication/sign_up/sign_up_page.dart';
import 'package:stockall/pages/authentication/translations/auth_texts_en.dart';
import 'package:stockall/providers/theme_provider.dart';

class AuthLandingTablet extends StatelessWidget {
  final ThemeProvider themeProvider;
  final BoxConstraints constraints;
  const AuthLandingTablet({
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
                        horizontal: 40.0,
                        vertical: 20,
                      ),
                      child: SizedBox(
                        child: Image.asset(
                          logoIconWhite,
                          fit: BoxFit.contain,
                          width: 150,
                          height: 150,
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
                      color: Colors.grey.shade100,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 40.0,
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
                              AuthLandingTexts()
                                  .authLandingWelcome,
                            ),
                            SizedBox(height: 15),
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
                                      .b2
                                      .textStyleNormal,
                              appDesc,
                            ),
                            SizedBox(height: 20),
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
                              text:
                                  AuthLandingTexts()
                                      .authLandingCreateAccount,
                              themeProvider: themeProvider,
                            ),
                            SizedBox(height: 10),
                            MainButtonTransparent(
                              themeProvider: themeProvider,
                              constraints: constraints,
                              text:
                                  AuthLandingTexts()
                                      .authLandingAlreadyHaveAnAccount,
                              action: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return LoginPage(
                                        useDemoLogin: false,
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: 10),
                            MainButtonTransparent(
                              themeProvider: themeProvider,
                              constraints: constraints,
                              text:
                                  'Contact Support/Login Test Demo',
                              action: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return ExplorePage();
                                    },
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment(0, -0.7),
            child: Image.asset(appMockUp, width: 300),
          ),
        ],
      ),
    );
  }
}
