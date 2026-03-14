import 'package:flutter/material.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/main.dart';

class ShopDashboardTotalWidget extends StatelessWidget {
  final String title;
  final double value;
  final double? fontSize;
  final LinearGradient? gradient;
  final bool isMoney;
  const ShopDashboardTotalWidget({
    super.key,
    required this.title,
    required this.value,
    this.fontSize,
    this.gradient,
    required this.isMoney,
  });

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 10,
        ),
        height: 70,
        // width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: const Color.fromARGB(255, 248, 248, 248),
          gradient: gradient,
          border: Border.all(
            color:
                gradient != null
                    ? Colors.transparent
                    : Colors.grey.shade300,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              style: TextStyle(
                color:
                    gradient != null ? Colors.white : null,
                fontSize: theme.mobileTexts.b4.fontSize,
                fontWeight: FontWeight.normal,
              ),
              title,
            ),
            Text(
              style: TextStyle(
                height: 0,
                color:
                    gradient != null ? Colors.white : null,
                fontSize:
                    fontSize ??
                    theme.mobileTexts.b1.fontSize,
                fontWeight: FontWeight.bold,
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
