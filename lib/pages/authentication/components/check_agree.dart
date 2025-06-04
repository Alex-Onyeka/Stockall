import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:stockall/providers/theme_provider.dart';

class CheckAgree extends StatelessWidget {
  final ThemeProvider theme;
  final bool checked;
  final Function()? onTap;
  final Function(bool?)? onChanged;
  const CheckAgree({
    super.key,
    required this.checked,
    required this.theme,
    required this.onTap,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Checkbox(
            activeColor: theme.lightModeColor.secColor200,
            side: BorderSide(
              color: Colors.grey.shade800,
              width: 1.5,
            ),
            value: checked,
            onChanged: onChanged,
          ),
          Flexible(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 14,
                ),
                children: [
                  TextSpan(
                    text: "I've read and Agreed with the ",
                  ),
                  TextSpan(
                    text: 'Terms and Conditions ',
                    recognizer:
                        TapGestureRecognizer()
                          ..onTap = () {},
                    style: TextStyle(
                      color:
                          theme.lightModeColor.secColor200,
                    ),
                  ),
                  TextSpan(text: "and the "),
                  TextSpan(
                    text: 'Privacy Policy.',
                    recognizer:
                        TapGestureRecognizer()
                          ..onTap = () {},
                    style: TextStyle(
                      color:
                          theme.lightModeColor.secColor200,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
