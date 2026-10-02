import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_product_class/units_class/product_units_class.dart';

class ProductionUnitDropdown extends StatelessWidget {
  const ProductionUnitDropdown({
    super.key,
    required this.units,
    required this.value,
    required this.onChanged,
  });

  final List<ProductUnitsClass> units;
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final primaryUnits =
        units.where((unit) => unit.isPrimary).toList();
    final selectedValue =
        units.any((unit) => unit.uuid == value)
            ? value
            : primaryUnits.isNotEmpty
            ? primaryUnits.first.uuid
            : units.isNotEmpty
            ? units.first.uuid
            : null;

    return DropdownButtonFormField<String>(
      value: selectedValue,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Unit',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
      ),
      items:
          units
              .map(
                (unit) => DropdownMenuItem<String>(
                  value: unit.uuid,
                  child: Text(
                    '${unit.name} (×${unit.conversion})',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
      onChanged: onChanged,
    );
  }
}
