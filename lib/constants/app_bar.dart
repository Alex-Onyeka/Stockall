import 'package:flutter/material.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/authentication/auth_landing/auth_landing.dart';
import 'package:stockall/pages/home/home.dart';

PreferredSizeWidget appBar({
  required BuildContext context,
  required String title,
  bool? isMain,
  Widget? widget,
}) {
  var theme = returnTheme(context);
  return AppBar(
    scrolledUnderElevation: 0,
    toolbarHeight: 60,
    leading: IconButton(
      onPressed: () {
        if (isMain != null) {
          // Navigator.pushReplacement(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) {
          //       return Home();
          //     },
          //   ),
          // );
          Navigator.of(context).pop();
        } else {
          Navigator.of(context).pop();
        }
      },
      icon: Padding(
        padding: const EdgeInsets.only(
          left: 10.0,
          right: 5,
        ),
        child: Icon(Icons.arrow_back_ios_new_rounded),
      ),
    ),
    centerTitle: true,
    title: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          style: TextStyle(
            fontSize: theme.mobileTexts.h4.fontSize,
            fontWeight: FontWeight.bold,
          ),
          title,
        ),
      ],
    ),
    actions: [widget ?? Container()],
  );
}
