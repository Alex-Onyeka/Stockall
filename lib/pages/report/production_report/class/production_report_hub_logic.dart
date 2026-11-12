// What the Production Report hub lists and who sees it.
//
// Pure Dart: the view passes the settings and permissions in.

/// The pages of the Production Report.
enum ProductionReportPageId {
  materialsTable,
  materialsAnalysis,
  materialHistoryTable,
  materialHistorySummary,
  usageRecordsTable,
  usageSummary,
  producedItemsTable,
  producedItemsAnalysis,
  producedItemHistoryTable,
  producedItemHistorySummary,
  productionRecordsTable,
  productionSummary,
}

/// The four production elements, in the order the hub shows them.
enum ProductionReportGroupId {
  materials,
  materialUsage,
  producedItems,
  productionRecords,
}

/// Top-level report categories shown in the Production Report hub.
enum ProductionReportCategoryId {
  materials,
  productionRecords,
  productionItems,
}

class ProductionReportCategory {
  final ProductionReportCategoryId id;
  final String title;
  final String subText;
  final List<ProductionReportGroupId> groupIds;

  const ProductionReportCategory({
    required this.id,
    required this.title,
    required this.subText,
    required this.groupIds,
  });
}

class ProductionReportEntry {
  final ProductionReportPageId id;
  final String title;
  final String subText;

  /// History pages need item history tracking (plan) and the
  /// "View Items History" permission.
  final bool isHistory;

  const ProductionReportEntry({
    required this.id,
    required this.title,
    required this.subText,
    this.isHistory = false,
  });
}

class ProductionReportGroup {
  final ProductionReportGroupId id;
  final String title;
  final String subText;
  final List<ProductionReportEntry> entries;

  const ProductionReportGroup({
    required this.id,
    required this.title,
    required this.subText,
    required this.entries,
  });
}

class ProductionReportHub {
  static const List<ProductionReportGroup> allGroups = [
    ProductionReportGroup(
      id: ProductionReportGroupId.materials,
      title: 'Materials',
      subText: 'Raw materials used in production',
      entries: [
        ProductionReportEntry(
          id: ProductionReportPageId.materialsTable,
          title: 'Materials Table',
          subText:
              'Search, filter and sort a detailed table of your materials',
        ),
        ProductionReportEntry(
          id: ProductionReportPageId.materialsAnalysis,
          title: 'Materials Analysis',
          subText: 'Stock value, usage and material performance',
        ),
        ProductionReportEntry(
          id: ProductionReportPageId.materialHistoryTable,
          title: 'Material History Table',
          subText:
              'Search, filter and sort a detailed table of your material history records',
          isHistory: true,
        ),
        ProductionReportEntry(
          id: ProductionReportPageId.materialHistorySummary,
          title: 'Material History Summary',
          subText:
              'Aggregated view of material usage, transfers and restocks over a selected period',
          isHistory: true,
        ),
      ],
    ),
    ProductionReportGroup(
      id: ProductionReportGroupId.materialUsage,
      title: 'Material Usage',
      subText: 'Records of materials used, in production or manually',
      entries: [
        ProductionReportEntry(
          id: ProductionReportPageId.usageRecordsTable,
          title: 'Usage Records Table',
          subText:
              'Search, filter and sort a detailed table of your material usage records',
        ),
        ProductionReportEntry(
          id: ProductionReportPageId.usageSummary,
          title: 'Usage Summary',
          subText:
              'Usage cost, trends and breakdowns by material, source, staff and department',
        ),
      ],
    ),
    ProductionReportGroup(
      id: ProductionReportGroupId.producedItems,
      title: 'Produced Items',
      subText: 'Items made in production, before they move to sales',
      entries: [
        ProductionReportEntry(
          id: ProductionReportPageId.producedItemsTable,
          title: 'Produced Items Table',
          subText:
              'Search, filter and sort a detailed table of your produced items',
        ),
        ProductionReportEntry(
          id: ProductionReportPageId.producedItemsAnalysis,
          title: 'Produced Items Analysis',
          subText:
              'Stock value, production and transfers to sales by item',
        ),
        ProductionReportEntry(
          id: ProductionReportPageId.producedItemHistoryTable,
          title: 'Produced Item History Table',
          subText:
              'Search, filter and sort a detailed table of your produced item history records',
          isHistory: true,
        ),
        ProductionReportEntry(
          id: ProductionReportPageId.producedItemHistorySummary,
          title: 'Produced Item History Summary',
          subText:
              'Aggregated view of production, transfers and stock changes over a selected period',
          isHistory: true,
        ),
      ],
    ),
    ProductionReportGroup(
      id: ProductionReportGroupId.productionRecords,
      title: 'Production Records',
      subText: 'Each production run and what it cost',
      entries: [
        ProductionReportEntry(
          id: ProductionReportPageId.productionRecordsTable,
          title: 'Production Records Table',
          subText:
              'Search, filter and sort a detailed table of your production records',
        ),
        ProductionReportEntry(
          id: ProductionReportPageId.productionSummary,
          title: 'Production Summary',
          subText:
              'Production cost, cost per unit, yields and trends over a selected period',
        ),
      ],
    ),
  ];

  /// The groups and pages this user sees. History pages are left out
  /// without [historyAllowed]; the Produced Items group is left out
  /// when the shop doesn't manage production items.
  static List<ProductionReportGroup> groups({
    required bool historyAllowed,
    required bool producedItemsEnabled,
  }) {
    final result = <ProductionReportGroup>[];
    for (final group in allGroups) {
      if (group.id == ProductionReportGroupId.producedItems &&
          !producedItemsEnabled) {
        continue;
      }
      final entries =
          group.entries
              .where((e) => historyAllowed || !e.isHistory)
              .toList();
      if (entries.isEmpty) continue;
      result.add(
        ProductionReportGroup(
          id: group.id,
          title: group.title,
          subText: group.subText,
          entries: entries,
        ),
      );
    }
    return result;
  }

  static const List<ProductionReportCategory> allCategories = [
    ProductionReportCategory(
      id: ProductionReportCategoryId.materials,
      title: 'Material Report',
      subText:
          'Raw materials, stock value, usage records and material history',
      groupIds: [
        ProductionReportGroupId.materials,
        ProductionReportGroupId.materialUsage,
      ],
    ),
    ProductionReportCategory(
      id: ProductionReportCategoryId.productionRecords,
      title: 'Production Record Report',
      subText: 'Each production run, cost per unit, yields and trends',
      groupIds: [ProductionReportGroupId.productionRecords],
    ),
    ProductionReportCategory(
      id: ProductionReportCategoryId.productionItems,
      title: 'Production Items Report',
      subText: 'Items made in production, stock value, transfers and history',
      groupIds: [ProductionReportGroupId.producedItems],
    ),
  ];

  /// The top-level category tiles shown on the Production Report hub.
  static List<ProductionReportCategory> categories({
    required bool producedItemsEnabled,
  }) =>
      allCategories
          .where(
            (c) =>
                producedItemsEnabled ||
                c.id != ProductionReportCategoryId.productionItems,
          )
          .toList();

  /// The groups and pages inside [category] that this user sees.
  static List<ProductionReportGroup> groupsForCategory({
    required ProductionReportCategory category,
    required bool historyAllowed,
    required bool producedItemsEnabled,
  }) {
    final allowedGroupIds = category.groupIds.toSet();
    return groups(
      historyAllowed: historyAllowed,
      producedItemsEnabled: producedItemsEnabled,
    ).where((g) => allowedGroupIds.contains(g.id)).toList();
  }

  /// Whether the Reports page shows the Production Report tile: the
  /// shop manages productions, the plan allows it, and the user can
  /// view productions.
  static bool tileVisible({
    required bool manageProductions,
    required bool planAllowsProductions,
    required bool canViewProductions,
  }) =>
      manageProductions && planAllowsProductions && canViewProductions;
}
