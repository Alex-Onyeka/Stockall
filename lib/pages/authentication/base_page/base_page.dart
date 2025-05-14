import 'package:flutter/material.dart';
import 'package:stockitt/main.dart';
import 'package:stockitt/pages/authentication/auth_landing/auth_landing.dart';
import 'package:stockitt/pages/home/home.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BasePage extends StatelessWidget {
  const BasePage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream:
          Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          returnCompProvider(
            context,
            listen: false,
          ).showLoader('Loading');
        }
        final session =
            snapshot.hasData
                ? snapshot.data!.session
                : null;

        if (session != null) {
          return Home();
        } else {
          return AuthLanding();
        }
      },
    );
  }
}
