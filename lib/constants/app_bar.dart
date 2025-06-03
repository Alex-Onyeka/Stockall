import 'package:flutter/material.dart';
import 'package:storrec/main.dart';

PreferredSizeWidget appBar({
  required BuildContext context,
  required String title,
  Widget? widget,
}) {
  var theme = returnTheme(context);
  return AppBar(
    scrolledUnderElevation: 0,
    toolbarHeight: 60,
    leading: IconButton(
      onPressed: () {
        Navigator.of(context).pop();
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
