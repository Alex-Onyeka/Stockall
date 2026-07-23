import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/components/buttons/main_button_transparent.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/subscription_page/subscription_page.dart';

class ExpirySubPopUpDesktop extends StatelessWidget {
  const ExpirySubPopUpDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Visibility(
      visible: !returnSubcsription(context).isClicked,
      child: Align(
        alignment: Alignment(0, -0.8),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Material(
            // elevation: 2,
            color: Colors.transparent,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 500),
              child: Container(
                // height: 300,
                width: 500,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(
                        25,
                        0,
                        0,
                        0,
                      ),
                      blurRadius: 40,
                      spreadRadius: 30,
                    ),
                  ],
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: SingleChildScrollView(
                    child: Column(
                      spacing: 5,
                      mainAxisAlignment:
                          MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                          children: [
                            Opacity(
                              opacity: 0,
                              child: Padding(
                                padding:
                                    const EdgeInsets.all(
                                      12.0,
                                    ),
                                child: Icon(
                                  size: 26,
                                  Icons.clear,
                                ),
                              ),
                            ),
                            LottieBuilder.asset(
                              fit: BoxFit.contain,
                              height: 130,
                              premium,
                            ),
                            Material(
                              type:
                                  MaterialType.transparency,
                              child: InkWell(
                                mouseCursor:
                                    SystemMouseCursors
                                        .click,
                                borderRadius:
                                    BorderRadius.circular(
                                      50,
                                    ),
                                onTap: () {
                                  returnSubcsription(
                                    context,
                                    listen: false,
                                  ).toggleIsClicked(true);
                                },
                                child: Padding(
                                  padding:
                                      const EdgeInsets.all(
                                        12.0,
                                      ),
                                  child: Icon(
                                    size: 26,
                                    Icons.clear,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(
                                horizontal: 5.0,
                              ),
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            spacing: 5,
                            children: [
                              Text(
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                                'Subscription Plan Expires In ${returnSubcsription(context).remainingDays()} Days',
                              ),
                              Flexible(
                                child: Text(
                                  textAlign:
                                      TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight:
                                        FontWeight.w500,
                                  ),
                                  'Your current subscription plan will expire in ${returnSubcsription(context).remainingDays()} days. If your subscription expires, you will lose access to all the privileges of your current plan. You can renew your subscription to continue enjoying these benefits. If you switch to a free plan or a lower plan, you will have a one-month grace period before any data that is not supported by the new plan is permanently deleted.',
                                ),
                              ),
                              SizedBox(height: 15),
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: 400,
                                ),
                                child: Column(
                                  spacing: 10,
                                  children: [
                                    MainButtonP(
                                      themeProvider: theme,
                                      action: () {
                                        returnSubcsription(
                                          context,
                                          listen: false,
                                        ).toggleIsClicked(
                                          true,
                                        );
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (
                                              context,
                                            ) {
                                              return SubscriptionPage();
                                            },
                                          ),
                                        );
                                      },
                                      text:
                                          'Renew Subscription',
                                    ),
                                    MainButtonTransparent(
                                      themeProvider: theme,
                                      constraints:
                                          BoxConstraints(),
                                      action: () {
                                        returnSubcsription(
                                          context,
                                          listen: false,
                                        ).toggleIsClicked(
                                          true,
                                        );
                                      },
                                      text: 'Close',
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
