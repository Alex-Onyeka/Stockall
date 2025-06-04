import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stockall/pages/authentication/auth_landing/platforms/auth_landing_desktop.dart';
import 'package:stockall/pages/authentication/auth_landing/platforms/auth_landing_mobile.dart';
import 'package:stockall/pages/authentication/auth_landing/platforms/auth_landing_tablet.dart';
import 'package:stockall/providers/theme_provider.dart';

class AuthLanding extends StatelessWidget {
  const AuthLanding({super.key});

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return AuthLandingMobile(
            themeProvider: themeProvider,
            constraints: constraints,
          );
        } else if (constraints.maxWidth > 600 &&
            constraints.maxWidth < 900) {
          return AuthLandingTablet(
            themeProvider: themeProvider,
            constraints: constraints,
          );
        } else {
          return AuthLandingDesktop(
            themeProvider: themeProvider,
            constraints: constraints,
          );
        }
      },
    );
  }
}
