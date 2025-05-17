import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stockitt/providers/theme_provider.dart';

class EmptyWidgetDisplayOnly extends StatelessWidget {
  final String title;
  final String subText;
  final String? svg;
  final IconData? icon;
  final ThemeProvider theme;
  final double height;

  const EmptyWidgetDisplayOnly({
    super.key,
    required this.title,
    required this.subText,
    this.svg,
    this.icon,
    required this.theme,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.grey.shade300,
              ),
            ),
            child: Stack(
              children: [
                Visibility(
                  visible: svg != null,
                  child: SvgPicture.asset(
                    svg ?? '',
                    height: height,
                  ),
                ),
                Visibility(
                  visible: icon != null,
                  child: Icon(
                    icon,
                    size: height,
                    color: theme.lightModeColor.prColor300,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 15),
          Text(
            style: TextStyle(
              fontSize: theme.mobileTexts.b1.fontSize,
              fontWeight: FontWeight.bold,
            ),
            title,
          ),
          SizedBox(height: 5),
          Text(
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: theme.mobileTexts.b2.fontSize,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
            subText,
          ),
        ],
      ),
    );
  }
}
