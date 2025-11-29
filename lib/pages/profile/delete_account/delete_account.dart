import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/profile/delete_account/platforms/delete_account_desktop.dart';
import 'package:stockall/pages/profile/delete_account/platforms/delete_account_mobile.dart';

class DeleteAccount extends StatefulWidget {
  const DeleteAccount({super.key});

  @override
  State<DeleteAccount> createState() =>
      DeleteAccountState();
}

class DeleteAccountState extends State<DeleteAccount> {
  TextEditingController passwordController =
      TextEditingController();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          () =>
              FocusManager.instance.primaryFocus?.unfocus(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < mobileScreen) {
            return DeleteAccountMobile(
              passwordController: passwordController,
            );
          } else {
            return DeleteAccountDesktop(
              passwordController: passwordController,
            );
            // return Scaffold();
          }
        },
      ),
    );
  }
}
