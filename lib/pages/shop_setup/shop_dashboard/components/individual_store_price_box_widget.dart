import 'package:flutter/material.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/main.dart';

class IndividualStorePriceBoxWidget
    extends StatelessWidget {
  final String title;
  final bool isMoney;
  final double value;

  const IndividualStorePriceBoxWidget({
    super.key,
    required this.title,
    required this.isMoney,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 0,
          children: [
            Text(
              style: TextStyle(
                fontSize: 7,
                fontWeight: FontWeight.normal,
                color: Colors.grey,
              ),
              '$title:',
            ),
            Text(
              style: TextStyle(
                fontSize: theme.mobileTexts.b3.fontSize,
                fontWeight: FontWeight.bold,
                // color:
                //     Colors.grey,
              ),
              isMoney
                  ? formatMoneyMid(
                    amount: value,
                    context: context,
                  )
                  : formatLargeNumber(
                    value.toStringAsFixed(0),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
