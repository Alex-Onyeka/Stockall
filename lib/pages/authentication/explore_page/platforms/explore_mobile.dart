import 'package:flutter/material.dart';
import 'package:stockall/components/buttons/main_button_transparent.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/authentication/base_page/base_page.dart';
import 'package:stockall/pages/authentication/explore_page/platforms/explore_desktop.dart';
import 'package:stockall/providers/theme_provider.dart';

class ExploreMobile extends StatefulWidget {
  final ThemeProvider theme;

  const ExploreMobile({super.key, required this.theme});

  @override
  State<ExploreMobile> createState() =>
      _ExploreMobileState();
}

class _ExploreMobileState extends State<ExploreMobile> {
  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        leading: InkWell(
          mouseCursor: SystemMouseCursors.click,
          onTap: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => BasePage(),
                ),
              );
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 0,
            ),
            child: Icon(
              color: Colors.grey,
              Icons.arrow_back_ios_new_rounded,
            ),
          ),
        ),
        leadingWidth: 60,
        centerTitle: true,
        title: Row(
          spacing: 10,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(mainLogoIcon, height: 20),
            Text(
              style: TextStyle(
                color: Colors.grey,
                fontSize: 25,
                fontWeight:
                    widget
                        .theme
                        .mobileTexts
                        .h3
                        .fontWeightBold,
              ),
              appName,
            ),
          ],
        ),
        actions: [
          Opacity(
            opacity: 0.0,
            child: Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: Icon(Icons.clear),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10.0,
          ),
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(
              context,
            ).copyWith(scrollbars: false),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                ),
                child: Column(
                  children: [
                    SizedBox(height: 5),
                    LoginDemoSectionWidget(theme: theme),
                    SizedBox(height: 20),
                    ContactSupportSectionWidget(
                      theme: theme,
                    ),
                    SizedBox(height: 20),
                    MainButtonTransparent(
                      themeProvider: widget.theme,
                      constraints: BoxConstraints(),
                      text: 'Go Back',
                      action: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
