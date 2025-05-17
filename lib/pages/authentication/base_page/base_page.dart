import 'package:flutter/material.dart';
import 'package:stockitt/components/major/empty_widget_display_only.dart';
import 'package:stockitt/main.dart';
import 'package:stockitt/pages/authentication/auth_screens/auth_screens_page.dart';
import 'package:stockitt/pages/home/home.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BasePage extends StatelessWidget {
  const BasePage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream:
          Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session =
            Supabase.instance.client.auth.currentSession;

        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return returnCompProvider(
            context,
            listen: false,
          ).showLoader('Loading');
        } else if (snapshot.hasError) {
          return Scaffold(
            body: EmptyWidgetDisplayOnly(
              title: 'An Error Occured',
              subText:
                  'An error occured while loading your data. Please check your internet and try again',
              theme: returnTheme(context),
              height: 35,
            ),
          );
        }

        if (session != null) {
          return const Home();
        } else {
          return const AuthScreensPage();
        }
      },
    );
  }
}
