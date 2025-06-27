import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  primaryColor: const Color.fromARGB(255, 25, 43, 117),
  colorScheme: ColorScheme.light(
    primary: const Color.fromRGBO(25, 43, 117, 1),
    secondary: const Color.fromRGBO(255, 165, 0, 1),
    tertiary: const Color.fromARGB(255, 195, 4, 51),
  ),
);

class LightModeColor {
  final prColor300 = Color.fromRGBO(25, 43, 117, 1);
  final prColor200 = Color.fromRGBO(101, 113, 163, 1);
  final prColor250 = Color.fromRGBO(47, 80, 219, 1);
  final prColor100 = Color.fromRGBO(149, 157, 192, 1);
  final prColor50 = Color.fromRGBO(245, 245, 255, 1);
  final prGradientColors = [
    Color.fromRGBO(25, 43, 117, 1),
    Color.fromRGBO(47, 80, 219, 1),
  ];
  final prGradientAlign = [
    Alignment.topCenter,
    Alignment.bottomCenter,
  ];
  final prGradient = LinearGradient(
    colors: [
      Color.fromRGBO(25, 43, 117, 1),
      Color.fromRGBO(47, 80, 219, 1),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  //
  //
  //
  //
  // SECONDARY COLORS

  final secColor200 = Color.fromRGBO(255, 165, 0, 1);
  final secColor100 = Color.fromRGBO(239, 124, 44, 1);
  final secColor50 = Color.fromRGBO(253, 242, 234, 1);
  final secGradientColors = [
    Color.fromRGBO(253, 200, 48, 1),
    Color.fromRGBO(243, 115, 53, 1),
  ];
  final secGradientAlign = [
    Alignment.topCenter,
    Alignment.bottomCenter,
  ];
  final secGradient = LinearGradient(
    colors: [
      Color.fromRGBO(253, 200, 48, 1),
      Color.fromRGBO(243, 115, 53, 1),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  //
  //
  //

  //
  //
  // TERTIRAY COLORS

  final tertColor200 = Color.fromRGBO(249, 22, 65, 1);
  final tertColor100 = Color.fromRGBO(253, 183, 196, 1);
  final tertColor50 = Color.fromRGBO(254, 232, 236, 1);

  //
  //
  //
  //
  // GREY COLORS

  final greyColor200 = Color.fromRGBO(51, 51, 51, 1);
  final greyColor100 = Color.fromRGBO(118, 118, 118, 1);
  final greyColor50 = Color.fromRGBO(235, 235, 235, 1);
  //
  //
  //

  //
  //
  //
  //
  // SUCCESS COLORS

  final succColor200 = Color.fromRGBO(36, 103, 45, 1);
  final succColor100 = Color.fromRGBO(187, 208, 190, 1);
  final succColor50 = Color.fromRGBO(233, 240, 234, 1);
  //
  //
  //

  //
  //
  //
  //
  // WARNING COLORS

  final warningColor200 = Color.fromRGBO(237, 196, 33, 1);
  final warningColor100 = Color.fromRGBO(220, 211, 176, 1);
  final warningColor50 = Color.fromRGBO(244, 241, 230, 1);
  //
  //
  //
  //

  //
  //
  //
  // ERROR COLORS

  final errorColor200 = Color.fromRGBO(227, 20, 59, 1);
  final errorColor100 = Color.fromRGBO(219, 176, 176, 1);
  final errorColor50 = Color.fromRGBO(243, 230, 230, 1);
  //
  //
  //

  //
  //
  //
  // SHADES COLORS

  final shadesColorBlack = Colors.black;
  final shadesColorGrey = const Color.fromARGB(
    255,
    21,
    21,
    21,
  );
  final shadesColorWhite = Colors.white;
  //
  //
  //
}

class H {
  final double fontSize;
  final double lineHeight;
  final FontWeight fontWeightBold;
  final FontWeight fontWeightRegular;
  final double letterSpacing;

  H({
    required this.fontSize,
    required this.letterSpacing,
    required this.lineHeight,
    required this.fontWeightBold,
    required this.fontWeightRegular,
  });
}

class B1 {
  final double fontSize;
  final double lineHeight;
  final FontWeight fontWeightBold;
  final FontWeight fontWeightRegular;
  final double letterSpacing;
  final TextStyle textStyleBold;
  final TextStyle textStyleNormal;

  B1({
    required this.fontSize,
    required this.letterSpacing,
    required this.lineHeight,
    required this.fontWeightBold,
    required this.fontWeightRegular,
    required this.textStyleBold,
    required this.textStyleNormal,
  });
}

class MobileTexts {
  H h1 = H(
    fontWeightBold: FontWeight.bold,
    fontWeightRegular: FontWeight.normal,
    fontSize: 30.0,
    letterSpacing: 0,
    lineHeight: 36,
  );

  H h2 = H(
    fontWeightBold: FontWeight.bold,
    fontWeightRegular: FontWeight.normal,
    fontSize: 25.0,
    letterSpacing: 0,
    lineHeight: 30,
  );

  H h3 = H(
    fontWeightBold: FontWeight.bold,
    fontWeightRegular: FontWeight.normal,
    fontSize: 22.0,
    letterSpacing: 0,
    lineHeight: 24,
  );

  H h4 = H(
    fontWeightBold: FontWeight.bold,
    fontWeightRegular: FontWeight.normal,
    fontSize: 18.0,
    letterSpacing: 0,
    lineHeight: 24,
  );

  B1 b1 = B1(
    fontWeightBold: FontWeight.bold,
    fontWeightRegular: FontWeight.normal,
    fontSize: 14.0,
    letterSpacing: 0,
    lineHeight: 24,
    textStyleBold: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: LightModeColor().greyColor100,
    ),
    textStyleNormal: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: LightModeColor().greyColor100,
    ),
  );

  B1 b2 = B1(
    fontWeightBold: FontWeight.bold,
    fontWeightRegular: FontWeight.normal,
    fontSize: 13.0,
    letterSpacing: 0,
    lineHeight: 21,
    textStyleBold: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.bold,
      color: LightModeColor().greyColor100,
    ),
    textStyleNormal: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: LightModeColor().greyColor100,
    ),
  );

  B1 b3 = B1(
    fontWeightBold: FontWeight.bold,
    fontWeightRegular: FontWeight.normal,
    fontSize: 11.0,
    letterSpacing: 0,
    lineHeight: 18,
    textStyleBold: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.bold,
      color: LightModeColor().greyColor100,
    ),
    textStyleNormal: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: LightModeColor().greyColor100,
    ),
  );

  B1 b4 = B1(
    fontWeightBold: FontWeight.bold,
    fontWeightRegular: FontWeight.normal,
    fontSize: 9.0,
    letterSpacing: 0,
    lineHeight: 15,
    textStyleBold: TextStyle(
      fontSize: 9,
      fontWeight: FontWeight.bold,
      color: LightModeColor().greyColor100,
    ),
    textStyleNormal: TextStyle(
      fontSize: 9,
      fontWeight: FontWeight.w500,
      color: LightModeColor().greyColor100,
    ),
  );
}

class TabletTexts {
  H h1 = H(
    fontWeightBold: FontWeight.bold,
    fontWeightRegular: FontWeight.normal,
    fontSize: 30.0,
    letterSpacing: 0,
    lineHeight: 36,
  );

  H h2 = H(
    fontWeightBold: FontWeight.bold,
    fontWeightRegular: FontWeight.normal,
    fontSize: 25.0,
    letterSpacing: 0,
    lineHeight: 30,
  );

  H h3 = H(
    fontWeightBold: FontWeight.bold,
    fontWeightRegular: FontWeight.normal,
    fontSize: 22.0,
    letterSpacing: 0,
    lineHeight: 24,
  );

  H h4 = H(
    fontWeightBold: FontWeight.bold,
    fontWeightRegular: FontWeight.normal,
    fontSize: 19.0,
    letterSpacing: 0,
    lineHeight: 24,
  );

  B1 b1 = B1(
    fontWeightBold: FontWeight.bold,
    fontWeightRegular: FontWeight.normal,
    fontSize: 16.0,
    letterSpacing: 0,
    lineHeight: 24,
    textStyleBold: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: LightModeColor().greyColor100,
    ),
    textStyleNormal: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: LightModeColor().greyColor100,
    ),
  );

  B1 b2 = B1(
    fontWeightBold: FontWeight.bold,
    fontWeightRegular: FontWeight.normal,
    fontSize: 14.0,
    letterSpacing: 0,
    lineHeight: 21,
    textStyleBold: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: LightModeColor().greyColor100,
    ),
    textStyleNormal: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: LightModeColor().greyColor100,
    ),
  );

  B1 b3 = B1(
    fontWeightBold: FontWeight.bold,
    fontWeightRegular: FontWeight.normal,
    fontSize: 12.0,
    letterSpacing: 0,
    lineHeight: 18,
    textStyleBold: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.bold,
      color: LightModeColor().greyColor100,
    ),
    textStyleNormal: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: LightModeColor().greyColor100,
    ),
  );

  B1 b4 = B1(
    fontWeightBold: FontWeight.bold,
    fontWeightRegular: FontWeight.normal,
    fontSize: 10.0,
    letterSpacing: 0,
    lineHeight: 15,
    textStyleBold: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.bold,
      color: LightModeColor().greyColor100,
    ),
    textStyleNormal: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w500,
      color: LightModeColor().greyColor100,
    ),
  );
}

class DesktopTexts {
  H h1 = H(
    fontWeightBold: FontWeight.bold,
    fontWeightRegular: FontWeight.normal,
    fontSize: 35.0,
    letterSpacing: 0,
    lineHeight: 36,
  );

  H h2 = H(
    fontWeightBold: FontWeight.bold,
    fontWeightRegular: FontWeight.normal,
    fontSize: 24.0,
    letterSpacing: 0,
    lineHeight: 30,
  );

  H h3 = H(
    fontWeightBold: FontWeight.bold,
    fontWeightRegular: FontWeight.normal,
    fontSize: 20.0,
    letterSpacing: 0,
    lineHeight: 24,
  );

  H h4 = H(
    fontWeightBold: FontWeight.bold,
    fontWeightRegular: FontWeight.normal,
    fontSize: 17.0,
    letterSpacing: 0,
    lineHeight: 24,
  );

  B1 b1 = B1(
    fontWeightBold: FontWeight.bold,
    fontWeightRegular: FontWeight.normal,
    fontSize: 16.0,
    letterSpacing: 0,
    lineHeight: 24,
    textStyleBold: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: LightModeColor().greyColor100,
    ),
    textStyleNormal: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: LightModeColor().greyColor100,
    ),
  );

  B1 b2 = B1(
    fontWeightBold: FontWeight.bold,
    fontWeightRegular: FontWeight.normal,
    fontSize: 14.0,
    letterSpacing: 0,
    lineHeight: 21,
    textStyleBold: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: LightModeColor().greyColor100,
    ),
    textStyleNormal: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: LightModeColor().greyColor100,
    ),
  );

  B1 b3 = B1(
    fontWeightBold: FontWeight.bold,
    fontWeightRegular: FontWeight.normal,
    fontSize: 12.0,
    letterSpacing: 0,
    lineHeight: 18,
    textStyleBold: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.bold,
      color: LightModeColor().greyColor100,
    ),
    textStyleNormal: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: LightModeColor().greyColor100,
    ),
  );

  B1 b4 = B1(
    fontWeightBold: FontWeight.bold,
    fontWeightRegular: FontWeight.normal,
    fontSize: 10.0,
    letterSpacing: 0,
    lineHeight: 15,
    textStyleBold: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.bold,
      color: LightModeColor().greyColor100,
    ),
    textStyleNormal: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w500,
      color: LightModeColor().greyColor100,
    ),
  );
}
