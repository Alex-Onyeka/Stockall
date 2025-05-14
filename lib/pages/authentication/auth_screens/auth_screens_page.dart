import 'package:flutter/material.dart';
import 'package:stockitt/main.dart';
import 'package:stockitt/pages/authentication/auth_landing/auth_landing.dart';
import 'package:stockitt/pages/authentication/login/login_page.dart';
import 'package:stockitt/pages/authentication/sign_up/sign_up_page.dart';
import 'package:stockitt/pages/authentication/splash_screens/splash_screen.dart';

class AuthScreensPage extends StatelessWidget {
  const AuthScreensPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (returnNavProvider(context).currentAuth == 0) {
      return SplashScreen();
    } else if (returnNavProvider(context).currentAuth ==
        1) {
      return AuthLanding();
    } else if (returnNavProvider(context).currentAuth ==
        2) {
      return LoginPage();
    } else {
      return SignUpPage();
    }
  }
}
