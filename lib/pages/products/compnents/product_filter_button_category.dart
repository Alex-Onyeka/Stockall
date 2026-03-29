import 'package:flutter/material.dart';
import 'package:stockall/providers/theme_provider.dart';

class ProductFilterButtonCategory extends StatelessWidget {
  final String title;
  final String currentSelected;
  final String uuid;
  final Function()? action;
  const ProductFilterButtonCategory({
    super.key,
    required this.theme,
    required this.title,
    required this.uuid,
    required this.currentSelected,
    required this.action,
  });

  final ThemeProvider theme;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color:
              currentSelected == uuid
                  ? theme.lightModeColor.prColor300
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color:
                currentSelected == uuid
                    ? Colors.transparent
                    : theme.lightModeColor.prColor300,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(5),
          onTap: action,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 5,
            ),

            child: Center(
              child: Text(
                style: TextStyle(
                  color:
                      currentSelected == uuid
                          ? Colors.white
                          : theme.lightModeColor.prColor300,
                  fontWeight: FontWeight.bold,
                  fontSize:
                      currentSelected == uuid
                          ? theme.mobileTexts.b3.fontSize
                          : theme.mobileTexts.b4.fontSize,
                ),
                title,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
