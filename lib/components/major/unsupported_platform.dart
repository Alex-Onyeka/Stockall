import 'package:flutter/material.dart';
import 'package:stockall/main.dart';

class UnsupportedPlatform extends StatelessWidget {
  const UnsupportedPlatform({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context, listen: false);
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 550 &&
              constraints.maxWidth < 1000) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 150.0,
                ),
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  spacing: 20,
                  children: [
                    Stack(
                      alignment: Alignment(0, 0),
                      children: [
                        Icon(
                          size: 160,
                          color: Colors.grey.shade800,
                          Icons.tablet_android_rounded,
                        ),
                        Icon(
                          size: 100,
                          color: Colors.grey.shade700,
                          Icons.clear,
                        ),
                      ],
                    ),
                    Text(
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.h1.fontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                      'Not Yet Available For This Sreen Size. Only Available on Mobile',
                    ),
                  ],
                ),
              ),
            );
          } else if (constraints.maxWidth > 1000) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 150.0,
                ),
                child: Column(
                  spacing: 10,
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Icon(
                      size: 250,
                      color: Colors.grey,
                      Icons.desktop_access_disabled_rounded,
                    ),
                    Text(
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.h1.fontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                      'Not Yet Available For This Screen Size, Only Available on Mobile',
                    ),
                  ],
                ),
              ),
            );
          } else {
            return Scaffold();
          }
        },
      ),
    );
  }
}
