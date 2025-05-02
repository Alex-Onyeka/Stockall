import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:stockitt/components/buttons/main_button_p.dart';
import 'package:stockitt/pages/authentication/verify_phone/enter_code.dart';
import 'package:stockitt/providers/theme_provider.dart';

class VerifyPhone extends StatefulWidget {
  final String number;
  const VerifyPhone({super.key, required this.number});

  @override
  State<VerifyPhone> createState() => _VerifyPhoneState();
}

class _VerifyPhoneState extends State<VerifyPhone> {
  List<Widget> circles = [
    Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        color: Colors.pink,
        shape: BoxShape.circle,
      ),
    ),
    Container(
      height: 30,
      width: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            Color.fromRGBO(253, 200, 48, 1),
            Color.fromRGBO(243, 115, 53, 1),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    ),
    Container(
      height: 20,
      width: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color.fromRGBO(82, 213, 186, 1),
      ),
    ),
    Container(
      height: 15,
      width: 15,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            Color.fromRGBO(25, 43, 117, 1),
            Color.fromRGBO(47, 80, 219, 1),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    ),
    Container(
      height: 15,
      width: 15,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.amber,
      ),
    ),
  ];
  @override
  Widget build(BuildContext context) {
    var theme = Provider.of<ThemeProvider>(context);
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 50),
          SizedBox(
            height: 300,
            child: Stack(
              alignment: Alignment(0, 0),
              children: [
                Align(
                  alignment: Alignment(0.6, -0.9),
                  child: circles[0],
                ),
                Align(
                  alignment: Alignment(-0.8, 0),
                  child: circles[1],
                ),
                Align(
                  alignment: Alignment(-0.1, 1),
                  child: circles[2],
                ),
                Align(
                  alignment: Alignment(-0.4, -1),
                  child: circles[3],
                ),
                Align(
                  alignment: Alignment(0.6, 0.8),
                  child: circles[4],
                ),

                SizedBox(
                  width: double.infinity,
                  child: Container(
                    padding: EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.shade100,
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
            padding: const EdgeInsets.symmetric(
              horizontal: 50.0,
            ),
            child: Column(
              children: [
                Text(
                  textAlign: TextAlign.center,
                  'We have sent a code to your Phone',
                  style: TextStyle(
                    color: theme.lightModeColor.prColor300,
                    fontSize: theme.mobileTexts.h2.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  textAlign: TextAlign.center,
                  style:
                      theme.mobileTexts.b1.textStyleNormal,
                  'Check your message to verify your phone Number',
                ),
                SizedBox(height: 20),
                MainButtonP(
                  themeProvider: theme,
                  action: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return EnterCode(
                            number: widget.number,
                          );
                        },
                      ),
                    );
                  },
                  text: 'Proceed to Verify',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
