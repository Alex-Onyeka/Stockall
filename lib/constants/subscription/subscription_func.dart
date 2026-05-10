import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/subscription_page/subscription_page.dart';

class CustomerAuth {
  final bool createCustomer;

  CustomerAuth({required this.createCustomer});
}

void showUnauthorizedDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withAlpha(50),
    builder: (context) {
      return SubscribeAlertDialog();
    },
  );
}

class SubscribeAlertDialog extends StatelessWidget {
  final String? message;
  const SubscribeAlertDialog({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context, listen: false);
    return AlertDialog(
      elevation: 0,
      shadowColor: Colors.transparent,
      contentPadding: EdgeInsets.all(0),
      insetPadding: EdgeInsets.all(15),
      backgroundColor: Colors.transparent,
      shape: BoxBorder.all(
        color: Colors.transparent,
        width: 0,
      ),
      content: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 500),
        child: Container(
          // height: 300,
          width: 500,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            // border: Border.all(
            //   color: theme.lightModeColor.secColor200,
            // ),
            color: Colors.white,
          ),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              spacing: 5,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(size: 26, Icons.clear),
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  spacing: 5,
                  children: [
                    LottieBuilder.asset(
                      fit: BoxFit.contain,
                      height: 130,
                      premium,
                      repeat: false,
                    ),
                    Text(
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                      'Premium Only Feature',
                    ),
                    Flexible(
                      child: Text(
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        message ??
                            'This feature is beyond your current plan. You have to upgrade your plan to be able to access this Feature.',
                      ),
                    ),
                    SizedBox(height: 20),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: 400,
                      ),
                      child: MainButtonP(
                        themeProvider: theme,
                        action: () async {
                          // await launchUrlMain(
                          //   'https://www.stockallapp.com/#/subscription',
                          // );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return SubscriptionPage();
                              },
                            ),
                          );
                        },
                        text: 'Upgrade Subscription Plan',
                      ),
                    ),
                    SizedBox(height: 30),
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

class SubWrapper extends StatelessWidget {
  final Widget mainWidget;
  final bool isVisible;
  final double? y;
  final double? x;
  const SubWrapper({
    super.key,
    required this.mainWidget,
    required this.isVisible,
    this.y,
    this.x,
  });

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Stack(
      alignment: AlignmentGeometry.xy(x ?? 1, y ?? -1),
      children: [
        Opacity(
          opacity: isVisible ? 0.9 : 1,
          child: mainWidget,
        ),
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(
                  33,
                  255,
                  193,
                  7,
                ),
                blurRadius: 10,
                offset: Offset(-06, 0.6),
                spreadRadius: 3,
              ),
            ],
          ),
          child: Visibility(
            visible: isVisible,
            child: Icon(
              size: 18,
              color: theme.lightModeColor.secColor200,
              Icons.star_purple500_rounded,
            ),
          ),
        ),
      ],
    );
  }
}
