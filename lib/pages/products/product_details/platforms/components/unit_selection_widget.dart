import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/classes/temp_product_class/units_class/product_units_class.dart';
import 'package:stockall/classes/temp_production_folder/temp_material_class/material_class.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_items/production_item.dart';
import 'package:stockall/classes/temp_storage_product/temp_storage_products.dart';
import 'package:stockall/providers/theme_provider.dart';

class UnitSelectionWidget extends StatefulWidget {
  final TempProductClass? product;
  final TempStorageProducts? storageProduct;
  final ProductionItem? productionItem;
  final MaterialClass? material;
  final ThemeProvider theme;
  final String? unitUuid;
  final Function(String? uuid)? setUnitUuid;
  final bool? showSelectUnitText;
  final List<ProductUnitsClass>? unitList;
  const UnitSelectionWidget({
    super.key,
    required this.product,
    required this.storageProduct,
    required this.productionItem,
    required this.material,
    required this.theme,
    required this.unitUuid,
    required this.setUnitUuid,
    this.unitList,
    this.showSelectUnitText,
  });

  @override
  State<UnitSelectionWidget> createState() =>
      _UnitSelectionWidgetState();
}

class _UnitSelectionWidgetState
    extends State<UnitSelectionWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 5,
      children: [
        Visibility(
          visible: widget.showSelectUnitText != false,
          child: Text(
            style: TextStyle(
              fontSize:
                  widget.theme.mobileTexts.b4.fontSize,
              fontWeight: FontWeight.bold,
            ),
            'Select Unit:',
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 210),
          child: PopupMenuButton(
            // offset: Offset(-20, 30),
            color: Colors.white,
            itemBuilder:
                (context) =>
                    widget.unitList
                        ?.map(
                          (item) =>
                              myPopUpMenuItemUnitSelection(
                                unitList: widget.unitList,
                                item: item,
                                material: widget.material,
                                storageProduct:
                                    widget.storageProduct,
                                product: widget.product,
                                productionItem:
                                    widget.productionItem,
                                setUnitUuid:
                                    widget.setUnitUuid,
                                theme: widget.theme,
                                unitUuid: widget.unitUuid,
                              ),
                        )
                        .toList() ??
                    widget.product
                        ?.getUnitsList()
                        .map(
                          (item) =>
                              myPopUpMenuItemUnitSelection(
                                unitList: widget.unitList,
                                item: item,
                                material: widget.material,
                                storageProduct:
                                    widget.storageProduct,
                                product: widget.product,
                                productionItem:
                                    widget.productionItem,
                                setUnitUuid:
                                    widget.setUnitUuid,
                                theme: widget.theme,
                                unitUuid: widget.unitUuid,
                              ),
                        )
                        .toList() ??
                    widget.productionItem
                        ?.getUnitsList()
                        .map(
                          (item) =>
                              myPopUpMenuItemUnitSelection(
                                unitList: widget.unitList,
                                item: item,
                                material: widget.material,
                                storageProduct:
                                    widget.storageProduct,
                                product: widget.product,
                                productionItem:
                                    widget.productionItem,
                                setUnitUuid:
                                    widget.setUnitUuid,
                                theme: widget.theme,
                                unitUuid: widget.unitUuid,
                              ),
                        )
                        .toList() ??
                    widget.material
                        ?.getUnitsList()
                        .map(
                          (item) =>
                              myPopUpMenuItemUnitSelection(
                                unitList: widget.unitList,
                                item: item,
                                material: widget.material,
                                product: widget.product,
                                storageProduct:
                                    widget.storageProduct,
                                productionItem:
                                    widget.productionItem,
                                setUnitUuid:
                                    widget.setUnitUuid,
                                theme: widget.theme,
                                unitUuid: widget.unitUuid,
                              ),
                        )
                        .toList() ??
                    widget.storageProduct
                        ?.getUnitsList()
                        .map(
                          (item) =>
                              myPopUpMenuItemUnitSelection(
                                unitList: widget.unitList,
                                item: item,
                                material: widget.material,
                                storageProduct:
                                    widget.storageProduct,
                                product: widget.product,
                                productionItem:
                                    widget.productionItem,
                                setUnitUuid:
                                    widget.setUnitUuid,
                                theme: widget.theme,
                                unitUuid: widget.unitUuid,
                              ),
                        )
                        .toList() ??
                    [],
            child: Container(
              padding: EdgeInsets.fromLTRB(10, 5, 5, 5),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.shade200,
                ),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    style: TextStyle(
                      fontSize:
                          widget
                              .theme
                              .mobileTexts
                              .b3
                              .fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                    widget.unitList != null
                        ? widget.unitList
                                ?.firstWhere(
                                  (item) =>
                                      item.uuid ==
                                      widget.unitUuid,
                                )
                                .name ??
                            'Not Set'
                        : widget.product
                                ?.getProductUnit(
                                  unitUuid: widget.unitUuid,
                                )
                                .name ??
                            widget.productionItem
                                ?.getProductUnit(
                                  unitUuid: widget.unitUuid,
                                )
                                .name ??
                            widget.material
                                ?.getProductUnit(
                                  unitUuid: widget.unitUuid,
                                )
                                .name ??
                            widget.storageProduct
                                ?.getProductUnit(
                                  unitUuid: widget.unitUuid,
                                )
                                .name ??
                            'Name',
                  ),
                  Icon(Icons.keyboard_arrow_down),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 10),
      ],
    );
  }
}

PopupMenuItem myPopUpMenuItemUnitSelection({
  required Function(String? uuid)? setUnitUuid,
  required ProductUnitsClass item,
  required ThemeProvider theme,
  required String? unitUuid,
  required TempProductClass? product,
  required TempStorageProducts? storageProduct,
  required ProductionItem? productionItem,
  required MaterialClass? material,
  required List<ProductUnitsClass>? unitList,
}) {
  bool getBold() {
    if (unitList != null && item.uuid == unitUuid) {
      return true;
    } else if ((product
                ?.getProductUnit(unitUuid: unitUuid)
                .uuid ??
            productionItem
                ?.getProductUnit(unitUuid: unitUuid)
                .uuid ??
            material
                ?.getProductUnit(unitUuid: unitUuid)
                .uuid ??
            storageProduct
                ?.getProductUnit(unitUuid: unitUuid)
                .uuid) ==
        item.uuid) {
      return true;
    } else {
      return false;
    }
  }

  bool getVisibility() {
    if (unitList != null && item.uuid == unitUuid) {
      return true;
    } else if ((product
                ?.getProductUnit(unitUuid: unitUuid)
                .uuid ??
            productionItem
                ?.getProductUnit(unitUuid: unitUuid)
                .uuid ??
            material
                ?.getProductUnit(unitUuid: unitUuid)
                .uuid ??
            storageProduct
                ?.getProductUnit(unitUuid: unitUuid)
                .uuid) ==
        item.uuid) {
      return true;
    } else {
      return false;
    }
  }

  return PopupMenuItem(
    onTap: () {
      setUnitUuid != null ? setUnitUuid(item.uuid) : {};
    },
    child: SizedBox(
      width: 200,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 10.0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                style: TextStyle(
                  fontSize: theme.mobileTexts.b3.fontSize,
                  fontWeight:
                      getBold() ? FontWeight.bold : null,
                ),
                item.name,
              ),
            ),
            Visibility(
              visible: getVisibility(),
              child: Icon(
                size: 17,
                color: Colors.grey.shade700,
                Icons.check,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
