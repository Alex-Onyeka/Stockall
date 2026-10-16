import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/report/item_history_summary/platforms/item_history_summary_desktop.dart';
import 'package:stockall/pages/report/item_history_summary/platforms/item_history_summary_mobile.dart';

class ItemHistorySummaryPage extends StatelessWidget {
  const ItemHistorySummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < tabletScreen) {
          return const ItemHistorySummaryMobile();
        } else {
          return const ItemHistorySummaryDesktop();
        }
      },
    );
  }
}

