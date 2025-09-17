import 'package:flutter/material.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/authentication/auth_screens/auth_screens_page.dart';
import 'package:stockall/pages/authentication/launch_screen/launch_screen.dart';
import 'package:stockall/pages/home/home.dart';
import 'package:stockall/services/auth_service.dart';

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

  String? userAuthId;

  Future<void> getUserAuthId() async {
    String? temp = await AuthService().checkAuth();
    setState(() {
      userAuthId = temp;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      switchLoading();
      returnCompProvider(
        context,
        listen: false,
      ).setVisible();
      await getUserAuthId();
    });
  }

  @override
  Widget build(BuildContext context) {
    // final userId = AuthService().checkAuth();
    if (returnNavProvider(context).isLoadingMain) {
      return const LaunchScreen();
    } else {
      if (userAuthId != null) {
        return const Home();
      } else {
        return const AuthScreensPage();
      }
    }
  }
}
