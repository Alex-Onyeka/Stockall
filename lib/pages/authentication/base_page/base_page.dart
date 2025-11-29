import 'package:flutter/material.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/authentication/auth_screens/auth_screens_page.dart';
import 'package:stockall/pages/authentication/translations/general.dart';
import 'package:stockall/pages/home/home.dart';
import 'package:stockall/services/auth_service.dart';

class BasePage extends StatefulWidget {
  const BasePage({super.key});

  @override
  State<BasePage> createState() => _BasePageState();
}

class _BasePageState extends State<BasePage> {
  bool isLoading = true;
  void switchLoading() {
    Future.delayed(Duration(seconds: 2), () {
      if (context.mounted) {
        returnNavProvider(
          context,
          listen: false,
        ).offLoading();
      }
    });
  }

  String? userAuthId;

  void getUserAuthId() {
    setState(() {
      userAuthId = AuthService().currentUser;
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
      getUserAuthId();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (returnNavProvider(context).isLoadingMain) {
      return Scaffold(
        body: returnCompProvider(
          context,
          listen: false,
        ).showLoader(message: General().loadingText),
      );
    } else {
      if (userAuthId != null) {
        return const Home();
      } else {
        return const AuthScreensPage();
      }
    }
  }
}
