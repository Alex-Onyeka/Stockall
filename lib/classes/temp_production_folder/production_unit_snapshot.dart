import 'package:stockall/classes/temp_product_class/units_class/product_units_class.dart';

List<ProductUnitsClass>? copyProductionUnitSnapshot(
  List<ProductUnitsClass>? units,
) {
  return units?.map((unit) => unit.copyWith()).toList();
}

String? legacyProductionUnitUuid({
  required List<ProductUnitsClass>? unitsList,
  required bool? useGroupQuantity,
  String? groupUnit,
}) {
  final units = unitsList ?? [];
  if (useGroupQuantity == true) {
    final nonPrimary =
        units.where((unit) => !unit.isPrimary).toList();
    final matchingGroup =
        groupUnit == null
            ? <ProductUnitsClass>[]
            : nonPrimary
                .where((unit) => unit.name == groupUnit)
                .toList();
    if (matchingGroup.isNotEmpty)
      return matchingGroup.first.uuid;
    if (nonPrimary.length == 1)
      return nonPrimary.first.uuid;
  } else {
    final primary = units.where((unit) => unit.isPrimary);
    if (primary.isNotEmpty) return primary.first.uuid;
  }
  return null;
}

double productionUnitConversion({
  String? unitUuid,
  List<ProductUnitsClass>? unitsList,
  bool? useGroupQuantity,
  double? qttyPerGroup,
  String? groupUnitName,
}) {
  if (unitUuid != null && unitsList != null) {
    for (final unit in unitsList) {
      if (unit.uuid == unitUuid &&
          unit.conversion.isFinite &&
          unit.conversion > 0) {
        return unit.conversion;
      }
    }
  }

  if (useGroupQuantity == true) {
    final nonPrimaryUnits =
        unitsList
            ?.where((unit) => !unit.isPrimary)
            .toList() ??
        [];
    final matchingGroupUnits =
        groupUnitName == null
            ? <ProductUnitsClass>[]
            : nonPrimaryUnits
                .where((unit) => unit.name == groupUnitName)
                .toList();
    final groupUnit =
        matchingGroupUnits.isNotEmpty
            ? matchingGroupUnits.first
            : nonPrimaryUnits.isNotEmpty
            ? nonPrimaryUnits.first
            : null;
    if (groupUnit != null) {
      final conversion = groupUnit.conversion;
      if (conversion.isFinite && conversion > 0) {
        return conversion;
      }
    }
    if (qttyPerGroup != null &&
        qttyPerGroup.isFinite &&
        qttyPerGroup > 0) {
      return qttyPerGroup;
    }
  }

  return 1;
}

String productionUnitName({
  String? unitUuid,
  List<ProductUnitsClass>? unitsList,
  bool? useGroupQuantity,
  String? unit,
  String? groupUnit,
  double? qttyPerGroup,
}) {
  if (unitUuid != null && unitsList != null) {
    for (final selectedUnit in unitsList) {
      if (selectedUnit.uuid == unitUuid) {
        return selectedUnit.name;
      }
    }
  }
  if (useGroupQuantity == true) {
    final groupUnits =
        unitsList
            ?.where(
              (selectedUnit) => !selectedUnit.isPrimary,
            )
            .toList() ??
        [];
    final matchingGroupUnits =
        groupUnit == null
            ? <ProductUnitsClass>[]
            : groupUnits
                .where(
                  (selectedUnit) =>
                      selectedUnit.name == groupUnit,
                )
                .toList();
    if (matchingGroupUnits.isNotEmpty) {
      return matchingGroupUnits.first.name;
    }
    if (groupUnits.isNotEmpty) {
      return groupUnits.first.name;
    }
    return groupUnit == null || groupUnit == 'Others'
        ? 'Group(s)'
        : groupUnit;
  }
  return unit == null || unit == 'Others'
      ? 'Unit(s)'
      : unit;
}

String productionPrimaryUnitName(
  List<ProductUnitsClass>? unitsList, {
  required String fallback,
}) {
  final primaryUnits =
      unitsList?.where((unit) => unit.isPrimary).toList() ??
      [];
  return primaryUnits.isEmpty
      ? fallback
      : primaryUnits.first.name;
}

double productionPrimaryUnitConversion(
  List<ProductUnitsClass>? unitsList, {
  double fallback = 1,
}) {
  final primaryUnits =
      unitsList?.where((unit) => unit.isPrimary).toList() ??
      [];
  if (primaryUnits.isEmpty) return fallback;
  final conversion = primaryUnits.first.conversion;
  return conversion.isFinite && conversion > 0
      ? conversion
      : fallback;
}
