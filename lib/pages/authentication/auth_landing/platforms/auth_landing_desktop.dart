import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storrec/components/buttons/main_button_p.dart';
import 'package:storrec/constants/constants_main.dart';
import 'package:storrec/main.dart';
import 'package:storrec/providers/theme_provider.dart';

class AuthLandingDesktop extends StatelessWidget {
  final ThemeProvider themeProvider;
  final BoxConstraints constraints;
  const AuthLandingDesktop({
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
          Row(
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
                      horizontal: 80,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 10),
                        Image.asset(
                          mainLogoIcon,
                          height: 50,
                        ),
                        SizedBox(height: 20),
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(
                                horizontal: 20.0,
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
                          'Lorem ipsum dolor sit amet, consectetur  adipiscing elit ut aliquam, purus sit  amet luctus v magna fringilla urna',
                        ),
                        SizedBox(height: 20),
                        MainButtonP(
                          action: () {
                            returnNavProvider(
                              context,
                              listen: false,
                            ).navigateAuth(3);
                          },
                          text: 'Create an Account',
                          themeProvider: themeProvider,
                        ),
                        SizedBox(height: 10),
                        InkWell(
                          onTap: () {
                            returnNavProvider(
                              context,
                              listen: false,
                            ).navigateAuth(2);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius:
                                  BorderRadius.circular(10),
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
            ],
          ),
          Align(
            alignment: Alignment(-0.8, 0),
            child: Image.asset(appMockUp, width: 450),
          ),
        ],
      ),
    );
  }
}
