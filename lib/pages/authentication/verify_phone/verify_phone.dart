import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:stockitt/components/buttons/main_button_p.dart';
import 'package:stockitt/providers/theme_provider.dart';

class VerifyPhone extends StatefulWidget {
  const VerifyPhone({super.key});

  @override
  State<VerifyPhone> createState() => _VerifyPhoneState();
}

class _VerifyPhoneState extends State<VerifyPhone> {
  List<Widget> circles = [
    Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        color: Colors.pink,
      ),
    ),
    Container(
      height: 30,
      width: 30,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Colors.amber,
      ),
    ),
    Container(
      height: 15,
      width: 15,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: const Color.fromARGB(255, 3, 53, 93),
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
                SizedBox(
                  width: double.infinity,
                  child: SizedBox(
                    height: 170,
                    width: 100,
                    child: Lottie.asset(
                      'assets/animations/phone_verify.json',
                      fit: BoxFit.contain,
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
                    color:
                        theme
                            .lightModeColor
                            .prColor300, // Needed for ShaderMask to apply the gradient
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
                  action: () {},
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
