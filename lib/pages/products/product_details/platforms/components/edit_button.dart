import 'package:flutter/material.dart';
import 'package:stockall/providers/theme_provider.dart';

class EditButton extends StatelessWidget {
  final String text;
  final Function() action;
  final ThemeProvider theme;
  final IconData? icon;
  final Color? color;

  const EditButton({
    super.key,
    required this.text,
    required this.action,
    required this.theme,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Ink(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: InkWell(
        mouseCursor: SystemMouseCursors.click,
        onTap: action,
        borderRadius: BorderRadius.circular(5),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 7),

          child: Center(
            child: Row(
              spacing: 5,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  style: TextStyle(
                    color: theme.lightModeColor.prColor300,
                    fontSize: theme.mobileTexts.b3.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                  text,
                ),
                Icon(
                  size: 18,
                  color: color ?? theme.lightModeColor.prColor300,
                  icon ?? Icons.edit_note_rounded,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
