import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:storrec/components/buttons/main_button_transparent.dart';
import 'package:storrec/constants/constants_main.dart';
import 'package:storrec/main.dart';
import 'package:storrec/pages/shop_setup/shop_setup_page.dart';
import 'package:storrec/services/auth_service.dart';

class ShopBannerScreen extends StatelessWidget {
  const ShopBannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 60.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  AuthService().signOut();
                },
                child: LottieBuilder.asset(
                  shopSetup,
                  height: 140,
                ),
              ),
              SizedBox(height: 15),
              Text(
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: theme.mobileTexts.b2.fontSize,
                  fontWeight: FontWeight.bold,
                  color: theme.lightModeColor.secColor200,
                ),
                'You account has been Created Successfully',
              ),
              SizedBox(height: 10),
              Text(
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: theme.mobileTexts.h3.fontSize,
                  fontWeight: FontWeight.bold,
                ),
                'Set Up Your Store To Start Selling',
              ),
              SizedBox(height: 30),
              MainButtonTransparent(
                constraints: BoxConstraints(),
                themeProvider: theme,
                action: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return ShopSetupPage();
                      },
                    ),
                  );
                },
                text: 'Create Shop',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
