import 'package:flutter/material.dart';
import 'package:stockall/main.dart';

class QuickActionButtons extends StatelessWidget {
  final String title;
  final Function()? action;
  final IconData icon;
  const QuickActionButtons({
    super.key,
    required this.title,
    required this.action,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: action,
          borderRadius: BorderRadius.circular(5),
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: 7,
              horizontal: 5,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              border: Border.all(
                color: Colors.grey.shade100,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 3,
              children: [
                Icon(size: 16, color: Colors.grey, icon),
                Text(
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b4.fontSize,
                  ),
                  title,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
