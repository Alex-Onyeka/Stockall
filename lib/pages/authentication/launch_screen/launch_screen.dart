import 'package:flutter/material.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/authentication/translations/general.dart';
import 'package:stockall/pages/home/home.dart';

class LaunchScreen extends StatefulWidget {
  const LaunchScreen({super.key});

  @override
  State<LaunchScreen> createState() => _LaunchScreenState();
}

class _LaunchScreenState extends State<LaunchScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!returnNavProvider(
        context,
        listen: false,
      ).isLoadingMain) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const Home()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: returnCompProvider(
          context,
          listen: false,
        ).showLoader(General().loadingText),
      ),
    );
  }
}
