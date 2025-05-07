import 'package:flutter/material.dart';
import 'package:stockitt/providers/theme_provider.dart';

class SmallButtonMain extends StatelessWidget {
  const SmallButtonMain({
    super.key,
    required this.theme,
    required this.action,
    required this.buttonText,
  });

  final ThemeProvider theme;
  final Function()? action;
  final String buttonText;

  @override
  Widget build(BuildContext context) {
    return Ink(
      decoration: BoxDecoration(
        // gradient: theme.lightModeColor.prGradient,
        color: theme.lightModeColor.prColor300,
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: action,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 30,
            vertical: 10,
          ),

          child: Row(
            spacing: 10,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(color: Colors.white, Icons.add_rounded),
              Text(
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                buttonText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
