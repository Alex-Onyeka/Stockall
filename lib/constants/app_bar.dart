import 'package:flutter/material.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/home/home.dart';

PreferredSizeWidget appBar({
  required BuildContext context,
  required String title,
  Function()? backAction,
  bool? isMain,
  bool? turnOff,
  Widget? widget,
  bool? main,
  Widget? titleWidget,
}) {
  var theme = returnTheme(context);
  return AppBar(
    scrolledUnderElevation: 0,
    toolbarHeight: 50,
    leading: IgnorePointer(
      ignoring: turnOff == true,
      child: Opacity(
        opacity:
            turnOff == null || turnOff == false ? 1 : 0,
        child: IconButton(
          mouseCursor: SystemMouseCursors.click,
          onPressed: () {
            if (turnOff == true) {
              return;
            }
            if (backAction != null) {
              backAction();
            } else {
              if (isMain != null) {
                returnNavProvider(
                  context,
                  listen: false,
                ).navigate(0);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return Home();
                    },
                  ),
                );
              } else if (main == true) {
                return;
              } else if (!Navigator.of(context).canPop()) {
                returnNavProvider(
                  context,
                  listen: false,
                ).navigate(0);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return Home();
                    },
                  ),
                );
              } else {
                Navigator.of(context).pop();
              }
            }
          },
          icon: Padding(
            padding: const EdgeInsets.only(
              left: 10.0,
              right: 5,
            ),
            child: Icon(
              size: 20,
              Icons.arrow_back_ios_new_rounded,
            ),
          ),
        ),
      ),
    ),
    centerTitle: true,
    title: Builder(
      builder: (context) {
        if (titleWidget != null) {
          return titleWidget;
        } else {
          return Column(
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
          );
        }
      },
    ),
    actions: widget != null ? [widget] : null,
  );
}
