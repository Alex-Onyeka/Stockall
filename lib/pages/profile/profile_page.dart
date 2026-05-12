import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/profile/platforms/profile_page_desktop.dart';
import 'package:stockall/pages/profile/platforms/profile_page_mobile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final passwordController = TextEditingController();
  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) async {
    //   await returnNavProvider(
    //     context,
    //     listen: false,
    //   ).validate(context);
    //   setState(() {
    //     // stillLoading = false;
    //   });
    // });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < mobileScreen) {
          return ProfilePageMobile(
            passwordController: passwordController,
          );
        } else {
          return ProfilePageDesktop(
            passwordController: passwordController,
          );
        }
      },
    );
  }
}
