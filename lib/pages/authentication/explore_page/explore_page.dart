import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/authentication/explore_page/platforms/explore_desktop.dart';
import 'package:stockall/pages/authentication/explore_page/platforms/explore_mobile.dart';
import 'package:stockall/providers/theme_provider.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  @override
  Widget build(BuildContext context) {
    var theme = Provider.of<ThemeProvider>(context);
    return GestureDetector(
      onTap:
          () =>
              FocusManager.instance.primaryFocus?.unfocus(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < mobileScreen) {
            return ExploreMobile(theme: theme);
          } else {
            return ExploreDesktop(theme: theme);
          }
        },
      ),
    );
  }
}
