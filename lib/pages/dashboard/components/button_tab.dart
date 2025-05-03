import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stockitt/providers/theme_provider.dart';

class ButtonTab extends StatelessWidget {
  final String title;
  final String icon;
  final Function()? action;

  final ThemeProvider theme;

  const ButtonTab({
    super.key,
    required this.title,
    required this.icon,
    this.action,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: action,
      child: Container(
        width:
            MediaQuery.of(context).size.width < 600
                ? 94
                : 100,
        height:
            MediaQuery.of(context).size.width < 600
                ? 94
                : 100,
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              color: const Color.fromARGB(10, 0, 0, 0),
              spreadRadius: 3,
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(icon, height: 23, width: 23),
              SizedBox(height: 10),
              Text(
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: theme.mobileTexts.b3.fontSize,
                  fontWeight: FontWeight.w600,
                ),
                title,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
