import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/providers/theme_provider.dart';

class VerifyPhoneDesktop extends StatelessWidget {
  final ThemeProvider theme;
  final List circles;
  const VerifyPhoneDesktop({
    super.key,
    required this.theme,
    required this.circles,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(backGroundImage),
            fit: BoxFit.cover,
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
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 50),
                          SizedBox(
                            height: 300,
                            child: Stack(
                              alignment: Alignment(0, 0),
                              children: [
                                Align(
                                  alignment: Alignment(
                                    0.6,
                                    -0.9,
                                  ),
                                  child: circles[0],
                                ),
                                Align(
                                  alignment: Alignment(
                                    -0.8,
                                    0,
                                  ),
                                  child: circles[1],
                                ),
                                Align(
                                  alignment: Alignment(
                                    -0.1,
                                    1,
                                  ),
                                  child: circles[2],
                                ),
                                Align(
                                  alignment: Alignment(
                                    -0.4,
                                    -1,
                                  ),
                                  child: circles[3],
                                ),
                                Align(
                                  alignment: Alignment(
                                    0.6,
                                    0.8,
                                  ),
                                  child: circles[4],
                                ),

                                SizedBox(
                                  width: double.infinity,
                                  child: Container(
                                    padding: EdgeInsets.all(
                                      40,
                                    ),
                                    decoration:
                                        BoxDecoration(
                                          shape:
                                              BoxShape
                                                  .circle,
                                          color:
                                              Colors
                                                  .grey
                                                  .shade100,
                                        ),
                                    child: SizedBox(
                                      height: 150,
                                      width: 100,
                                      child: Lottie.asset(
                                        'assets/animations/phone_verify.json',
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(
                                  horizontal: 50.0,
                                ),
                            child: Column(
                              children: [
                                Text(
                                  textAlign:
                                      TextAlign.center,
                                  'A Password Reset Link has been sent to your Email',
                                  style: TextStyle(
                                    color:
                                        theme
                                            .lightModeColor
                                            .prColor300,
                                    fontSize:
                                        theme
                                            .mobileTexts
                                            .h2
                                            .fontSize,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 20),
                                Text(
                                  textAlign:
                                      TextAlign.center,
                                  style:
                                      theme
                                          .mobileTexts
                                          .b1
                                          .textStyleNormal,
                                  'Check your mail to Reset Your Password',
                                ),
                                SizedBox(height: 20),
                                // MainButtonP(
                                //   themeProvider: theme,
                                //   action: () {
                                //     Navigator.push(
                                //       context,
                                //       MaterialPageRoute(
                                //         builder: (context) {
                                //           return EnterCode(
                                //             number:
                                //                 'number',
                                //           );
                                //         },
                                //       ),
                                //     );
                                //   },
                                //   text: 'Proceed to Verify',
                                // ),
                                // SizedBox(height: 20),
                              ],
                            ),
                          ),
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
