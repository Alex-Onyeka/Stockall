import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/report/item_history_summary/class/item_history_summary_logic.dart';
import 'package:stockall/pages/report/item_level_stock_movements/platforms/item_level_stock_movements_desktop.dart';
import 'package:stockall/pages/report/item_level_stock_movements/platforms/item_level_stock_movements_mobile.dart';

class ItemLevelStockMovementsPage extends StatelessWidget {
  final ItemHistoryPeriod? initialPeriod;
  final DateTimeRange? initialCustomRange;
  final String? initialCategoryKey;
  final String? initialDepartmentKey;
  final String? initialSearch;
  final ItemHistoryMovementFilter? initialMovementFilter;

  const ItemLevelStockMovementsPage({
    super.key,
    this.initialPeriod,
    this.initialCustomRange,
    this.initialCategoryKey,
    this.initialDepartmentKey,
    this.initialSearch,
    this.initialMovementFilter,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < tabletScreen) {
          return ItemLevelStockMovementsMobile(
            initialPeriod: initialPeriod,
            initialCustomRange: initialCustomRange,
            initialCategoryKey: initialCategoryKey,
            initialDepartmentKey: initialDepartmentKey,
            initialSearch: initialSearch,
            initialMovementFilter: initialMovementFilter,
          );
        } else {
          return ItemLevelStockMovementsDesktop(
            initialPeriod: initialPeriod,
            initialCustomRange: initialCustomRange,
            initialCategoryKey: initialCategoryKey,
            initialDepartmentKey: initialDepartmentKey,
            initialSearch: initialSearch,
            initialMovementFilter: initialMovementFilter,
          );
        }
      },
    );
  }
}

