import 'package:flutter/material.dart';
import 'package:stockall/pages/report/items_report_/item_history_summary/class/item_history_summary_logic.dart';
import 'package:stockall/pages/report/items_report_/item_level_stock_movements/components/item_level_stock_movements_view.dart';

class ItemLevelStockMovementsMobile
    extends StatelessWidget {
  final ItemHistoryPeriod? initialPeriod;
  final DateTimeRange? initialCustomRange;
  final String? initialCategoryKey;
  final String? initialDepartmentKey;
  final String? initialSearch;
  final ItemHistoryMovementFilter? initialMovementFilter;

  const ItemLevelStockMovementsMobile({
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
    return ItemLevelStockMovementsView(
      isDesktop: false,
      initialPeriod: initialPeriod,
      initialCustomRange: initialCustomRange,
      initialCategoryKey: initialCategoryKey,
      initialDepartmentKey: initialDepartmentKey,
      initialSearch: initialSearch,
      initialMovementFilter: initialMovementFilter,
    );
  }
}
