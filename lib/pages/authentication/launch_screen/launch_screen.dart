import 'package:flutter/material.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/authentication/translations/general.dart';

class LaunchScreen extends StatefulWidget {
  const LaunchScreen({super.key});

  @override
  State<LaunchScreen> createState() => _LaunchScreenState();
}

class _LaunchScreenState extends State<LaunchScreen> {
  @override
  void initState() {
    print('LaunchScreen Init: ${DateTime.now()}');
    super.initState();
    // Future.delayed(const Duration(milliseconds: 1500), () {
    //   // if (context.mounted) {
    //   //   Navigator.pushReplacement(
    //   //     // ignore: use_build_context_synchronously
    //   //     context,
    //   //     MaterialPageRoute(
    //   //       builder: (_) => const BasePage(),
    //   //     ),
    //   //   );
    //   // }
    // });
  }

  @override
  Widget build(BuildContext context) {
    print('LaunchScreen Build: ${DateTime.now()}');
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child:
        // Image.asset(
        //   'assets/images/logos/App_Png.png',
        //   width: 170, // Adjust size as needed
        // ),
        returnCompProvider(
          context,
          listen: false,
        ).showLoader(General().loadingText),
      ),
    );
  }
}
