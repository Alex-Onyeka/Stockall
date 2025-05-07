import 'package:flutter/material.dart';
import 'package:stockitt/providers/theme_provider.dart';

class FloatingActionButtonMain extends StatelessWidget {
  final String text;
  final Function()? action;
  final Color color;
  const FloatingActionButtonMain({
    super.key,
    required this.theme,
    required this.action,
    required this.color,
    required this.text,
  });

  final ThemeProvider theme;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 3,
      borderRadius: BorderRadius.circular(15),
      color: Colors.transparent,
      child: Ink(
        padding: EdgeInsets.only(
          right: 15,
          left: 20,
          top: 8,
          bottom: 8,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 1),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(44, 0, 0, 0),
              blurRadius: 10,
            ),
          ],
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: action,
          child: SizedBox(
            child: Row(
              spacing: 5,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                  text,
                ),
                Icon(color: color, size: 22, Icons.add),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
