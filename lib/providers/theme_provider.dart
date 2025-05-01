import 'package:flutter/material.dart';
import 'package:stockitt/theme/main_theme.dart';

class ThemeProvider extends ChangeNotifier {
  LightModeColor lightModeColor = LightModeColor();
  MobileTexts mobileTexts = MobileTexts();
  TabletTexts tabletTexts = TabletTexts();
  DesktopTexts desktopTexts = DesktopTexts();

  dynamic returnPlatform(
    BoxConstraints constraints,
    BuildContext context,
  ) {
    if (constraints.maxWidth < 600) {
      return mobileTexts;
    } else if (constraints.maxWidth > 600 &&
        constraints.maxWidth < 900) {
      return tabletTexts;
    } else {
      return desktopTexts;
    }
  }
}
