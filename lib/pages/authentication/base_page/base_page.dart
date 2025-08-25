import 'package:flutter/material.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/authentication/auth_screens/auth_screens_page.dart';
import 'package:stockall/pages/authentication/launch_screen/launch_screen.dart';
import 'package:stockall/pages/home/home.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BasePage extends StatefulWidget {
  const BasePage({super.key});

  @override
  State<BasePage> createState() => _BasePageState();
}

class _BasePageState extends State<BasePage> {
  // bool isLoading = true;
  void switchLoading() {
    Future.delayed(Duration(seconds: 1), () {
      if (context.mounted) {
        returnNavProvider(
          context,
          listen: false,
        ).offLoading();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      switchLoading();
      returnCompProvider(
        context,
        listen: false,
      ).setVisible();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final session =
        Supabase.instance.client.auth.currentSession;
    // return LaunchScreen();
    if (session != null) {
      // User is logged in
      if (returnNavProvider(context).isLoadingMain) {
        return const LaunchScreen();
      } else {
        return const Home();
      }
    } else {
      // Not logged in
      return const AuthScreensPage();
    }
  }
}
