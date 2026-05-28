import 'package:flutter/material.dart';
import 'package:stockall/main.dart';

class GenerateSectionWidget extends StatelessWidget {
  final String title;
  final Widget widget;
  const GenerateSectionWidget({
    super.key,
    required this.title,
    required this.widget,
  });

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 10,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(29, 0, 0, 0),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          spacing: 5,
          children: [
            SizedBox(height: 10),
            Text(
              style: TextStyle(
                fontSize: theme.mobileTexts.b1.fontSize,
                fontWeight: FontWeight.bold,
              ),
              title,
            ),
            widget,
          ],
        ),
      ),
    );
  }
}
