import 'package:flutter/material.dart';
import 'package:stockall/main.dart';

class UnsupportedPlatform extends StatelessWidget {
  const UnsupportedPlatform({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context, listen: false);
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 550 &&
            constraints.maxWidth < 1000) {
          return Center(
            child: Column(
              children: [
                Stack(
                  alignment: Alignment(0, 0),
                  children: [
                    Icon(
                      size: 40,
                      color: Colors.grey.shade800,
                      Icons.tablet_android_rounded,
                    ),
                    Icon(
                      size: 25,
                      color: Colors.grey.shade700,
                      Icons.clear,
                    ),
                  ],
                ),
                Text(
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: theme.mobileTexts.h3.fontSize,
                    fontWeight: FontWeight.bold,
                    color: theme.lightModeColor.secColor200,
                  ),
                  'Not Yet Available For Tablet. Only Available on Mobile',
                ),
              ],
            ),
          );
        } else if (constraints.maxWidth > 1000) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  size: 60,
                  color: Colors.grey.shade800,
                  Icons.desktop_access_disabled_rounded,
                ),
                Text(
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: theme.mobileTexts.h1.fontSize,
                    fontWeight: FontWeight.bold,
                    color: theme.lightModeColor.secColor200,
                  ),
                  'Not Yet Available For Desktop, Only Available on Mobile',
                ),
              ],
            ),
          );
        } else {
          return Scaffold();
        }
      },
    );
  }
}
