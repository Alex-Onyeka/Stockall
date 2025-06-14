import 'package:flutter/material.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/authentication/base_page/base_page.dart';

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
    // Future.delayed(const Duration(milliseconds: 2500), () {
    //   if (context.mounted) {
    //     Navigator.pushReplacement(
    //       // ignore: use_build_context_synchronously
    //       context,
    //       MaterialPageRoute(
    //         builder: (_) => const BasePage(),
    //       ),
    //     );
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    print('LaunchScreen Build: ${DateTime.now()}');
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: returnCompProvider(
          context,
          listen: false,
        ).showLoader('Loading'),
      ),
    );
  }
}
