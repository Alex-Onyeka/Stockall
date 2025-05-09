import 'package:flutter/material.dart';
import 'package:stockitt/main.dart';
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
      color: const Color.fromRGBO(0, 0, 0, 0),
      child: AnimatedSize(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: Ink(
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
            child: Container(
              padding: EdgeInsets.only(
                right: 15,
                left:
                    returnData(
                          context,
                        ).isFloatingButtonVisible
                        ? 20
                        : 15,
                top: 8,
                bottom: 8,
              ),
              child: Row(
                spacing:
                    returnData(
                          context,
                        ).isFloatingButtonVisible
                        ? 5
                        : 0,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Visibility(
                    visible:
                        returnData(
                          context,
                        ).isFloatingButtonVisible,
                    child: Text(
                      style: TextStyle(
                        color: color,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                      text,
                    ),
                  ),
                  Icon(color: color, size: 22, Icons.add),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
