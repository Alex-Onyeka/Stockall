// Scope, unit and cost helpers shared by the Production Report pages.
//
// Pure Dart: no BuildContext and no providers. Callers pass the
// permissions and the current user/department in, so it can be tested.

import 'package:stockall/classes/temp_product_class/units_class/product_units_class.dart';
import 'package:stockall/classes/temp_production_folder/production_unit_snapshot.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_materials_usage/production_materials_usage.dart';
import 'package:stockall/classes/temp_production_folder/temp_productions/production_record.dart';
import 'package:stockall/classes/temp_production_folder/temp_productions/production_record_materials.dart';
import 'package:stockall/pages/report/components/report_department_scope.dart';

/// Where a production record's recorded cost came from.
enum ProductionCostSource { itemCost, materials, custom, unknown }

extension ProductionCostSourceLabel on ProductionCostSource {
  String get label {
    switch (this) {
      case ProductionCostSource.itemCost:
        return 'Item Cost';
      case ProductionCostSource.materials:
        return 'Materials';
      case ProductionCostSource.custom:
        return 'Custom';
      case ProductionCostSource.unknown:
        return 'Not Set';
    }
  }
}

/// Where a production record's output went.
enum ProductionOutputType { producedItem, salesItem }

extension ProductionOutputTypeLabel on ProductionOutputType {
  String get label {
    switch (this) {
      case ProductionOutputType.producedItem:
        return 'Produced Item';
      case ProductionOutputType.salesItem:
        return 'Sales Item';
    }
  }
}

class ProductionReportAccess {
  /// The records the user may see. Same rule as the other reports
  /// (`ReceiptsReportAccess`): with departments on, a user who can't
  /// view all departments, or who has a current department, sees only
  /// that department; a user without "View All Transaction Records"
  /// sees only their own records.
  static List<T> scope<T>({
    required List<T> records,
    required String? Function(T record) departmentOf,
    required String? Function(T record) staffOf,
    required bool departmentsEnabled,
    required bool canViewAllDepartments,
    required String? currentDepartmentUuid,
    required bool canViewAllTransactions,
    required String? currentUserId,
  }) {
    final restrictDepartment =
        departmentsEnabled &&
        (!canViewAllDepartments || currentDepartmentUuid != null);
    return records.where((record) {
      if (restrictDepartment &&
          !reportDepartmentMatches(
            departmentOf(record),
            currentDepartmentUuid,
          )) {
        return false;
      }
      if (!canViewAllTransactions && staffOf(record) != currentUserId) {
        return false;
      }
      return true;
    }).toList();
  }

  /// Materials, produced items and their history: the rule of the
  /// production item lists (`ProductionItemsProvider.productionItemList`).
  /// With departments on, a user who can't view all departments, or who
  /// has a current department, sees records with no department and the
  /// current department's. There is no own-records rule for stock.
  static List<T> scopeStock<T>({
    required List<T> records,
    required String? Function(T record) departmentOf,
    required bool departmentsEnabled,
    required bool canViewAllDepartments,
    required String? currentDepartmentUuid,
  }) {
    final restrict =
        departmentsEnabled &&
        (!canViewAllDepartments || currentDepartmentUuid != null);
    if (!restrict) return List<T>.from(records);
    return records.where((record) {
      final d = departmentOf(record)?.trim();
      return d == null || d.isEmpty || d == currentDepartmentUuid;
    }).toList();
  }

  static List<ProductionRecord> scopeRecords({
    required List<ProductionRecord> records,
    required bool departmentsEnabled,
    required bool canViewAllDepartments,
    required String? currentDepartmentUuid,
    required bool canViewAllTransactions,
    required String? currentUserId,
  }) {
    return scope<ProductionRecord>(
      records: records,
      departmentOf: (r) => r.departmentId,
      staffOf: (r) => r.staffId,
      departmentsEnabled: departmentsEnabled,
      canViewAllDepartments: canViewAllDepartments,
      currentDepartmentUuid: currentDepartmentUuid,
      canViewAllTransactions: canViewAllTransactions,
      currentUserId: currentUserId,
    );
  }

  static List<ProductionMaterialsUsage> scopeUsages({
    required List<ProductionMaterialsUsage> usages,
    required bool departmentsEnabled,
    required bool canViewAllDepartments,
    required String? currentDepartmentUuid,
    required bool canViewAllTransactions,
    required String? currentUserId,
  }) {
    return scope<ProductionMaterialsUsage>(
      records: usages,
      departmentOf: (u) => u.departmentUuid,
      staffOf: (u) => u.staffUuid,
      departmentsEnabled: departmentsEnabled,
      canViewAllDepartments: canViewAllDepartments,
      currentDepartmentUuid: currentDepartmentUuid,
      canViewAllTransactions: canViewAllTransactions,
      currentUserId: currentUserId,
    );
  }
}

/// Unit conversions. Quantities are stored in base units; the primary
/// unit holds `conversion` base units. These read the unit snapshot
/// only and never call `getPrimaryUnit()`, which needs the current user
/// when an item has no units.
class ProductionReportUnits {
  /// Base units in one primary unit (1 when the item has no units).
  static double primaryConversion(List<ProductUnitsClass>? unitsList) =>
      productionPrimaryUnitConversion(unitsList);

  /// The primary unit's name, or the legacy [unit] when there are no
  /// units ("Others" shows as "Unit(s)", as on the item pages).
  static String primaryUnitName(
    List<ProductUnitsClass>? unitsList, {
    required String? unit,
  }) {
    final legacy =
        unit == null || unit.trim().isEmpty || unit == 'Others'
            ? 'Unit(s)'
            : unit;
    return productionPrimaryUnitName(unitsList, fallback: legacy);
  }

  static double toPrimary(
    double baseQuantity,
    List<ProductUnitsClass>? unitsList,
  ) {
    final value = baseQuantity / primaryConversion(unitsList);
    return value.isFinite ? value : 0;
  }

  /// Quantity produced, in the output's primary unit.
  static double recordPrimaryQty(ProductionRecord record) =>
      toPrimary(record.getQuantity(), record.unitsList);

  /// Quantity of one material line, in the material's primary unit.
  static double materialLinePrimaryQty(ProductionRecordMaterials line) =>
      toPrimary(line.getActualQuantity(), line.unitsList);

  /// Quantity of a usage record, in the material's primary unit.
  static double usagePrimaryQty(ProductionMaterialsUsage usage) =>
      toPrimary(usage.getQuantity(), usage.unitsList);

  /// Stock of a material or produced item, in its primary unit.
  static double stockPrimaryQty(
    double? quantity,
    List<ProductUnitsClass>? unitsList,
  ) => toPrimary(quantity ?? 0, unitsList);

  /// Cost of one primary unit (`costPrice` is per base unit, as on
  /// the Items report).
  static double primaryCostPrice(
    double costPrice,
    List<ProductUnitsClass>? unitsList,
  ) => costPrice * primaryConversion(unitsList);
}

class ProductionReportCosts {
  /// Sum of the material lines' costs, as saved on the record.
  static double materialCost(ProductionRecord record) => record.materials
      .map((line) => line.getTotalCost())
      .fold(0.0, (a, b) => a + b);

  /// The cost the app uses for the record (`customCost ?? totalCost`).
  static double recordedCost(ProductionRecord record) =>
      record.getTotalCost();

  /// Recorded cost minus material cost. Zero when the cost came from
  /// the materials.
  static double costVariance(ProductionRecord record) =>
      recordedCost(record) - materialCost(record);

  /// Recorded cost of one primary unit produced. Null when nothing
  /// was produced.
  static double? costPerUnitProduced(ProductionRecord record) {
    final qty = ProductionReportUnits.recordPrimaryQty(record);
    if (!qty.isFinite || qty <= 0) return null;
    final value = recordedCost(record) / qty;
    return value.isFinite ? value : null;
  }

  /// Where [recordedCost] came from. A saved custom cost always wins,
  /// because `getTotalCost()` uses it whatever option was selected.
  static ProductionCostSource costSource(ProductionRecord record) {
    if (record.customCost != null) return ProductionCostSource.custom;
    switch (record.selectedCostPriceOption) {
      case 1:
        return ProductionCostSource.itemCost;
      case 2:
        return ProductionCostSource.materials;
      default:
        return ProductionCostSource.unknown;
    }
  }

  static double usageCost(ProductionMaterialsUsage usage) =>
      usage.getTotalCost();

  /// Cost of one base unit when the usage was saved.
  static double? usageUnitCost(ProductionMaterialsUsage usage) =>
      usage.originalCostPerItem;

  /// Stock value at cost: base quantity × cost per base unit.
  static double stockValue(double? quantity, double costPrice) {
    final value = (quantity ?? 0) * costPrice;
    return value.isFinite ? value : 0;
  }

  /// True when a production created this usage record.
  static bool isProductionUsage(ProductionMaterialsUsage usage) {
    final id = usage.productionRecordUuid?.trim();
    return id != null && id.isNotEmpty;
  }

  /// Where the record's output went. A record with both ids, or
  /// neither, follows the shop's "Manage Production Items" setting,
  /// as the production provider does.
  static ProductionOutputType outputType(
    ProductionRecord record, {
    required bool manageProductionItems,
  }) {
    if (record.itemUuid != null && record.salesItemUuid == null) {
      return ProductionOutputType.producedItem;
    }
    if (record.salesItemUuid != null && record.itemUuid == null) {
      return ProductionOutputType.salesItem;
    }
    return manageProductionItems
        ? ProductionOutputType.producedItem
        : ProductionOutputType.salesItem;
  }
}
