import 'package:flutter/material.dart';
import 'package:stockall/providers/theme_provider.dart';

class ProductsFilterButton extends StatelessWidget {
  final String title;
  final int currentSelected;
  final int number;
  final Function()? action;
  final int? length;
  const ProductsFilterButton({
    super.key,
    required this.theme,
    required this.title,
    required this.number,
    required this.currentSelected,
    required this.action,
    this.length,
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
          borderRadius: BorderRadius.circular(3),
          border: Border.all(
            color:
                currentSelected == number
                    ? Colors.transparent
                    : theme.lightModeColor.prColor300,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(5),
          onTap: action,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 3,
            ),

            child: Center(
              child: Row(
                children: [
                  Text(
                    style: TextStyle(
                      color:
                          currentSelected == number
                              ? Colors.white
                              : theme
                                  .lightModeColor
                                  .prColor300,
                      fontWeight: FontWeight.normal,
                      fontSize:
                          currentSelected == number
                              ? theme
                                  .mobileTexts
                                  .b4
                                  .fontSize
                              : theme
                                  .mobileTexts
                                  .b4
                                  .fontSize,
                    ),
                    title,
                  ),
                  Visibility(
                    visible:
                        length != null &&
                        currentSelected == number,
                    child: Row(
                      children: [
                        SizedBox(width: 5),
                        Text(
                          style: TextStyle(
                            color:
                                currentSelected == number
                                    ? Colors.white
                                    : theme
                                        .lightModeColor
                                        .prColor300,
                            fontWeight: FontWeight.bold,
                            fontSize:
                                currentSelected == number
                                    ? theme
                                        .mobileTexts
                                        .b4
                                        .fontSize
                                    : theme
                                        .mobileTexts
                                        .b4
                                        .fontSize,
                          ),
                          "(${length.toString()})",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
