import 'package:flutter/material.dart';
import 'package:stockitt/providers/theme_provider.dart';

class ProductsFilterButton extends StatelessWidget {
  final String title;
  final int currentSelected;
  final int number;
  final Function()? action;
  const ProductsFilterButton({
    super.key,
    required this.theme,
    required this.title,
    required this.number,
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
              currentSelected == number
                  ? theme.lightModeColor.prColor300
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color:
                currentSelected == number
                    ? Colors.transparent
                    : theme.lightModeColor.prColor300,
            width: currentSelected == number ? 1 : 1,
          ),
        ),
        child: InkWell(
          radius: 15,
          onTap: action,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 10,
            ),

            child: Center(
              child: Text(
                style: TextStyle(
                  color:
                      currentSelected == number
                          ? Colors.white
                          : theme.lightModeColor.prColor300,
                  fontWeight: FontWeight.bold,
                  fontSize:
                      currentSelected == number ? 13 : 12,
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
