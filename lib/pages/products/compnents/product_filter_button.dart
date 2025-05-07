import 'package:flutter/material.dart';
import 'package:stockitt/main.dart';
import 'package:stockitt/providers/theme_provider.dart';

class ProductsFilterButton extends StatelessWidget {
  final String title;
  final int number;
  const ProductsFilterButton({
    super.key,
    required this.theme,
    required this.title,
    required this.number,
  });

  final ThemeProvider theme;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color:
              returnData(context).currentSelect == number
                  ? theme.lightModeColor.prColor300
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color:
                returnData(context).currentSelect == number
                    ? Colors.transparent
                    : theme.lightModeColor.prColor300,
            width:
                returnData(context).currentSelect == number
                    ? 1
                    : 1,
          ),
        ),
        child: InkWell(
          radius: 15,
          onTap: () {
            returnData(
              context,
              listen: false,
            ).changeSelected(number);
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 10,
            ),

            child: Center(
              child: Text(
                style: TextStyle(
                  color:
                      returnData(context).currentSelect ==
                              number
                          ? Colors.white
                          : theme.lightModeColor.prColor300,
                  fontWeight: FontWeight.bold,
                  fontSize:
                      returnData(context).currentSelect ==
                              number
                          ? 13
                          : 12,
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
