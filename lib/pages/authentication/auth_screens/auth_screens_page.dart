import 'package:flutter/material.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/authentication/auth_landing/auth_landing.dart';
import 'package:stockall/pages/authentication/splash_screens/splash_screen.dart';

class AuthScreensPage extends StatelessWidget {
  const AuthScreensPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (returnNavProvider(context).currentAuth == 0) {
      return SplashScreen();
    } else {
      return AuthLanding();
    }
  }
}
