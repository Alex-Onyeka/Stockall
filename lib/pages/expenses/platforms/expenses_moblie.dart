import 'package:flutter/material.dart';
import 'package:stockitt/components/major/empty_widget_display_only.dart';
import 'package:stockitt/components/major/top_banner.dart';
import 'package:stockitt/constants/constants_main.dart';
import 'package:stockitt/main.dart';

class ExpensesMoblie extends StatelessWidget {
  const ExpensesMoblie({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Scaffold(
      body: Column(
        children: [
          TopBanner(
            subTitle: 'Manage your business expenses',
            title: 'Expenses',
            theme: theme,
            bottomSpace: 40,
            topSpace: 30,
            isMain: true,
            iconSvg: expensesIconSvg,
          ),
          Expanded(
            child: Stack(
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      bottom: 30.0,
                    ),
                    child: EmptyWidgetDisplayOnly(
                      title: 'Comming Soon',
                      subText:
                          'This feature is not yet available... Our group of dedicated professional engineers are working on it.',
                      theme: theme,
                      height: 30,
                      icon: Icons.clear,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
