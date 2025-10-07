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

  void getUserAuthId() {
    String? temp = AuthService().currentUser;
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
      getUserAuthId();
    });
  }

  @override
  Widget build(BuildContext context) {
    // return Scaffold();
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
