import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/classes/temp_product_class/units_class/product_units_class.dart';
import 'package:stockall/classes/temp_purchase/purchase_list_item/purchase_list_item.dart';
import 'package:stockall/classes/temp_storage_product/temp_storage_products.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/buttons/small_button_main.dart';
import 'package:stockall/components/text_fields/edit_cart_text_field.dart';
import 'package:stockall/components/text_fields/money_textfield.dart';
import 'package:stockall/components/text_fields/general_textfield_only.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/products/product_details/platforms/components/unit_selection_widget.dart';
import 'package:stockall/pages/suppliers/supplier_list/supplier_list.dart';

void selectProductPurchase({
  required Function() closeAction,
  required TextEditingController priceController,
  required TextEditingController quantityController,
  required BuildContext context,
  required PurchaseListItem purchaseItem,
  required bool isEdit,
}) {
  var theme = returnTheme(context, listen: false);
  bool setCustomPrice = false;

  final TempProductClass? product =
      purchaseItem.itemUuid != null
          ? returnData(context: context, listen: false)
              .productListMain
              .where((p) => p.uuid == purchaseItem.itemUuid)
              .firstOrNull
          : null;
  final TempStorageProducts? storageProduct =
      purchaseItem.storageItemUuid != null
          ? returnStorageProductProvider(
                context: context,
                listen: false,
              ).storageProductListMain
              .where(
                (s) =>
                    s.uuid == purchaseItem.storageItemUuid,
              )
              .firstOrNull
          : null;
  final bool is2D =
      (product?.quantityType == 2) ||
      (storageProduct?.quantityType == 2);
  final bool itemHasDimensions =
      (product?.hasDimensions ?? false) ||
      (storageProduct?.hasDimensions ?? false);
  final double? originalWidth =
      product?.widthDimension ??
      storageProduct?.widthDimension;
  final double? originalHeight =
      product?.heightDimension ??
      storageProduct?.heightDimension;
  final String? dimensionUnit =
      product?.dimensionUnit ??
      storageProduct?.dimensionUnit;

  final trackingNumberController = TextEditingController(
    text: purchaseItem.trackingNumber ?? '',
  );
  String? selectedSupplierId = purchaseItem.supplierId;
  String? selectedSupplierName = purchaseItem.supplierName;
  if (selectedSupplierName == null && selectedSupplierId != null) {
    selectedSupplierName =
        returnSuppliersProvider(context: context, listen: false)
            .suppliers
            .where((s) => s.uuid == selectedSupplierId)
            .firstOrNull
            ?.name;
  }
  final widthController = TextEditingController();
  final heightController = TextEditingController();
  if (purchaseItem.widthDimension != null) {
    widthController.text = formatDimension(
      purchaseItem.widthDimension!,
    ).replaceAll(',', '');
  } else if (itemHasDimensions && originalWidth != null) {
    widthController.text = formatDimension(
      originalWidth,
    ).replaceAll(',', '');
  }
  if (purchaseItem.heightDimension != null) {
    heightController.text = formatDimension(
      purchaseItem.heightDimension!,
    ).replaceAll(',', '');
  } else if (itemHasDimensions && originalHeight != null) {
    heightController.text = formatDimension(
      originalHeight,
    ).replaceAll(',', '');
  }

  String? unitUuid;

  void selectUnit(String unit) {
    unitUuid = unit;
  }

  List<ProductUnitsClass> tempUnitList = [];
  String unitName = 'Unit(s)';
  String productUuid = '';
  tempUnitList = purchaseItem.getUnitListFinal();
  final initialSelectedUnit = purchaseItem.getSelectedUnit(
    unitUuidNew: unitUuid,
  );
  unitName = initialSelectedUnit.name;
  unitUuid = initialSelectedUnit.uuid;
  productUuid =
      purchaseItem.itemUuid ??
      purchaseItem.storageItemUuid ??
      '';
  List<ProductUnitsClass> getUnitListFinal() {
    return tempUnitList
        .map((item) => item.copyWith())
        .toList();
  }

  ProductUnitsClass getPrimaryUnit() {
    var items = tempUnitList.where(
      (item) => item.uuid == unitUuid,
    );
    if (items.isEmpty) {
      var items = tempUnitList.where(
        (item) => item.isPrimary,
      );
      if (items.isNotEmpty) {
        return items.first;
      } else {
        return ProductUnitsClass(
          uuid: '${productUuid}_primary_unit',
          staffUuid: currentUser().userId,
          createdAt: DateTime.now(),
          staffName: currentUser().name,
          conversion: 1,
          name: unitName == 'Others' ? 'Unit(s)' : unitName,
          isPrimary: true,
          productUuid: productUuid,
        );
      }
    } else {
      return items.first;
    }
  }

  bool isAreaUnit() => is2D && getPrimaryUnit().isAreaUnit;

  if (purchaseItem.customPrice != null) {
    priceController.text =
        '${purchaseItem.customPrice ?? ''}';
    setCustomPrice = true;
  }
  quantityController.text =
      !isEdit
          ? (purchaseItem.quantity).toStringAsFixed(0)
          : (purchaseItem.quantity).toString();

  double amount() {
    if (setCustomPrice) {
      return (double.tryParse(
            priceController.text.replaceAll(',', ''),
          ) ??
          0);
    } else {
      final double qty =
          double.tryParse(
            quantityController.text.replaceAll(',', ''),
          ) ??
          0;
      final double? w = double.tryParse(
        widthController.text.replaceAll(',', '').trim(),
      );
      final double? h = double.tryParse(
        heightController.text.replaceAll(',', '').trim(),
      );
      final isDimensionalSheet = is2D && !isAreaUnit();
      return (purchaseItem.originalPrice ?? 0) *
          getPrimaryUnit().getQuantityEquivMultiplied(
            index: 1,
            product: product,
            newQuantity: qty,
            customWidth:
                isDimensionalSheet
                    ? (w ??
                        (itemHasDimensions
                            ? originalWidth
                            : null))
                    : null,
            customHeight:
                isDimensionalSheet
                    ? (h ??
                        (itemHasDimensions
                            ? originalHeight
                            : null))
                    : null,
          );
    }
  }

  showDialog(
    context: context,
    builder: (context) {
      return GestureDetector(
        onTap:
            () =>
                FocusManager.instance.primaryFocus
                    ?.unfocus(),
        child: StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              insetPadding: EdgeInsets.symmetric(
                horizontal: 15,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 20,
              ),
              backgroundColor: Colors.white,
              title: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Enter Item Purchase Details',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.h4.fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Divider(color: Colors.grey.shade300),
                ],
              ),

              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 450,
                      child: EditCartTextField(
                        title: 'Enter Item Quantity',
                        hint: 'Quantity',
                        controller: quantityController,
                        theme: theme,
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                    ),
                    UnitSelectionWidget(
                      unitList: tempUnitList,
                      product: null,
                      storageProduct: null,
                      productionItem: null,
                      material: null,
                      theme: theme,
                      unitUuid: getPrimaryUnit().uuid,
                      setUnitUuid: (d) {
                        setState(() {
                          selectUnit(d ?? '');
                        });
                        // quantityController.text = '0';
                      },
                    ),
                    if (is2D && !isAreaUnit())
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 10.0,
                        ),
                        child: Row(
                          spacing: 10,
                          children: [
                            Expanded(
                              child: EditCartTextField(
                                onChanged: (value) {
                                  setState(() {});
                                },
                                title:
                                    '${dimensionUnit ?? getPrimaryUnit().name} Width',
                                hint:
                                    originalWidth != null
                                        ? 'Max ${formatDimension(originalWidth)}${dimensionUnit != null ? ' $dimensionUnit' : ''}'
                                        : 'Enter Width',
                                controller: widthController,
                                theme: theme,
                              ),
                            ),
                            Expanded(
                              child: EditCartTextField(
                                onChanged: (value) {
                                  setState(() {});
                                },
                                title:
                                    '${dimensionUnit ?? getPrimaryUnit().name} Height',
                                hint:
                                    originalHeight != null
                                        ? 'Max ${formatDimension(originalHeight)}${dimensionUnit != null ? ' $dimensionUnit' : ''}'
                                        : 'Enter Height',
                                controller:
                                    heightController,
                                theme: theme,
                              ),
                            ),
                          ],
                        ),
                      ),
                    SizedBox(height: 20),
                    Builder(
                      builder: (context) {
                        if (setCustomPrice) {
                          return Column(
                            children: [
                              Row(
                                spacing: 10,
                                crossAxisAlignment:
                                    CrossAxisAlignment.end,
                                children: [
                                  Expanded(
                                    child: MoneyTextfield(
                                      title: 'Custom Price',
                                      hint: 'Enter Price',
                                      controller:
                                          priceController,
                                      theme: theme,
                                      onChanged: (value) {
                                        setState(() {});
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),
                            ],
                          );
                        } else {
                          return Container();
                        }
                      },
                    ),
                    // SizedBox(height: 20),
                    InkWell(
                      mouseCursor: SystemMouseCursors.click,
                      onTap: () {
                        setState(() {
                          setCustomPrice = !setCustomPrice;
                        });
                        priceController.clear();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 5,
                          horizontal: 10,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          spacing: 5,
                          children: [
                            Text(
                              style: TextStyle(
                                fontSize:
                                    theme
                                        .mobileTexts
                                        .b1
                                        .fontSize,
                                fontWeight: FontWeight.bold,
                              ),
                              setCustomPrice
                                  ? 'Cancel Custom Price'
                                  : 'Set Custom Price',
                            ),
                            Stack(
                              children: [
                                Visibility(
                                  visible:
                                      setCustomPrice ==
                                      false,
                                  child: SvgPicture.asset(
                                    editIconSvg,
                                    height: 20,
                                  ),
                                ),
                                Visibility(
                                  visible:
                                      setCustomPrice ==
                                      true,
                                  child: Icon(Icons.clear),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    GeneralTextfieldOnly(
                      hint: 'Tracking Number (Optional)',
                      controller: trackingNumberController,
                      lines: 1,
                      theme: theme,
                    ),
                    SizedBox(height: 10),
                    InkWell(
                      mouseCursor: SystemMouseCursors.click,
                      borderRadius: BorderRadius.circular(5),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return SupplierList(
                                isPurchase: true,
                                onSelectSupplier: (supplier) {
                                  setState(() {
                                    selectedSupplierId = supplier.uuid;
                                    selectedSupplierName = supplier.name;
                                  });
                                },
                              );
                            },
                          ),
                        );
                      },
                      child: Container(
                        height: 40,
                        padding: const EdgeInsets.only(left: 15, right: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: Colors.grey,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                selectedSupplierName ??
                                    'Select Item Supplier (Optional)',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: theme.mobileTexts.b3.fontSize,
                                  fontWeight:
                                      selectedSupplierName != null
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                  color:
                                      selectedSupplierName != null
                                          ? Colors.black87
                                          : Colors.grey.shade600,
                                ),
                              ),
                            ),
                            InkWell(
                              mouseCursor: SystemMouseCursors.click,
                              onTap: () {
                                if (selectedSupplierId != null) {
                                  setState(() {
                                    selectedSupplierId = null;
                                    selectedSupplierName = null;
                                  });
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return SupplierList(
                                          isPurchase: true,
                                          onSelectSupplier: (supplier) {
                                            setState(() {
                                              selectedSupplierId =
                                                  supplier.uuid;
                                              selectedSupplierName =
                                                  supplier.name;
                                            });
                                          },
                                        );
                                      },
                                    ),
                                  );
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(7),
                                child: Icon(
                                  size: 18,
                                  selectedSupplierId == null
                                      ? Icons.arrow_forward_ios_rounded
                                      : Icons.clear,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          10,
                        ),
                        color: Colors.grey.shade100,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 10,
                      ),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            style: TextStyle(
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b1
                                      .fontSize,
                            ),
                            'Total',
                          ),
                          Text(
                            style: TextStyle(
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b1
                                      .fontSize,
                              fontWeight:
                                  theme
                                      .mobileTexts
                                      .b1
                                      .fontWeightBold,
                            ),
                            formatMoneyMid(
                              amount: amount(),
                              context: context,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      spacing: 5,
                      children: [
                        MaterialButton(
                          mouseCursor:
                              SystemMouseCursors.click,
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('Cancel'),
                        ),
                        SmallButtonMain(
                          theme: theme,
                          action: () {
                            if (quantityController
                                .text
                                .isNotEmpty) {
                              if (!setCustomPrice ||
                                  (setCustomPrice &&
                                      priceController
                                          .text
                                          .isNotEmpty)) {
                                if (is2D && !isAreaUnit()) {
                                  final w = double.tryParse(
                                    widthController.text
                                        .replaceAll(',', '')
                                        .trim(),
                                  );
                                  final h = double.tryParse(
                                    heightController.text
                                        .replaceAll(',', '')
                                        .trim(),
                                  );
                                  if (w == null ||
                                      h == null ||
                                      w <= 0 ||
                                      h <= 0 ||
                                      (originalWidth !=
                                              null &&
                                          w > originalWidth) ||
                                      (originalHeight !=
                                              null &&
                                          h > originalHeight)) {
                                    showDialog(
                                      context: context,
                                      builder:
                                          (
                                            context,
                                          ) => InfoAlert(
                                            theme: theme,
                                            message:
                                                itemHasDimensions
                                                    ? 'Enter positive dimensions no larger than the original slab / sheet.'
                                                    : 'Enter positive Width and Height for this item.',
                                            title:
                                                'Invalid Dimensions',
                                          ),
                                    );
                                    return;
                                  }
                                }

                                final double? customW =
                                    is2D && !isAreaUnit()
                                        ? (double.tryParse(
                                              widthController
                                                  .text
                                                  .replaceAll(
                                                    ',',
                                                    '',
                                                  )
                                                  .trim(),
                                            ) ??
                                            (itemHasDimensions
                                                ? originalWidth
                                                : null))
                                        : null;
                                final double? customH =
                                    is2D && !isAreaUnit()
                                        ? (double.tryParse(
                                              heightController
                                                  .text
                                                  .replaceAll(
                                                    ',',
                                                    '',
                                                  )
                                                  .trim(),
                                            ) ??
                                            (itemHasDimensions
                                                ? originalHeight
                                                : null))
                                        : null;

                                if (isEdit) {
                                  returnPurchaseActionProvider().updateItem(
                                    item: PurchaseListItem(
                                      unitUuid: unitUuid,
                                      unitsList:
                                          getUnitListFinal(),
                                      unit:
                                          getPrimaryUnit()
                                              .name,
                                      qttyPerGroup:
                                          purchaseItem
                                              .qttyPerGroup,
                                      storageItemUuid:
                                          purchaseItem
                                              .storageItemUuid,
                                      originalPrice:
                                          purchaseItem
                                              .originalPrice,
                                      itemName:
                                          purchaseItem
                                              .itemName,
                                      customPrice:
                                          double.tryParse(
                                            priceController
                                                .text
                                                .replaceAll(
                                                  ',',
                                                  '',
                                                ),
                                          ),
                                      itemUuid:
                                          purchaseItem
                                              .itemUuid,
                                      totalPrice: amount(),
                                      quantity:
                                          (double.tryParse(
                                                quantityController
                                                    .text
                                                    .replaceAll(
                                                      ',',
                                                      '',
                                                    ),
                                              ) ??
                                              0),
                                      isGroup:
                                          getPrimaryUnit()
                                              .conversion !=
                                          1,
                                      widthDimension:
                                          customW,
                                      heightDimension:
                                          customH,
                                      trackingNumber:
                                          trackingNumberController
                                                  .text
                                                  .trim()
                                                  .isEmpty
                                              ? null
                                              : trackingNumberController
                                                  .text
                                                  .trim(),
                                      supplierId: selectedSupplierId,
                                      supplierName: selectedSupplierName,
                                    ),
                                  );
                                } else {
                                  returnPurchaseActionProvider().addItemToList(
                                    item: PurchaseListItem(
                                      unitUuid: unitUuid,
                                      unitsList:
                                          getUnitListFinal(),
                                      unit:
                                          getPrimaryUnit()
                                              .name,
                                      qttyPerGroup:
                                          purchaseItem
                                              .qttyPerGroup,
                                      storageItemUuid:
                                          purchaseItem
                                              .storageItemUuid,
                                      originalPrice:
                                          purchaseItem
                                              .originalPrice,
                                      itemName:
                                          purchaseItem
                                              .itemName,
                                      customPrice:
                                          double.tryParse(
                                            priceController
                                                .text
                                                .replaceAll(
                                                  ',',
                                                  '',
                                                ),
                                          ),
                                      itemUuid:
                                          purchaseItem
                                              .itemUuid,
                                      totalPrice: amount(),
                                      quantity:
                                          (double.tryParse(
                                                quantityController
                                                    .text
                                                    .replaceAll(
                                                      ',',
                                                      '',
                                                    ),
                                              ) ??
                                              0),
                                      isGroup:
                                          getPrimaryUnit()
                                              .conversion !=
                                          1,
                                      widthDimension:
                                          customW,
                                      heightDimension:
                                          customH,
                                      trackingNumber:
                                          trackingNumberController
                                                  .text
                                                  .trim()
                                                  .isEmpty
                                              ? null
                                              : trackingNumberController
                                                  .text
                                                  .trim(),
                                      supplierId: selectedSupplierId,
                                      supplierName: selectedSupplierName,
                                    ),
                                  );
                                  Navigator.of(
                                    context,
                                  ).pop();
                                }
                                Navigator.of(context).pop();
                              }
                            }
                          },
                          buttonText: 'Add Item',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    },
  ).then((value) {
    quantityController.clear();
    priceController.clear();
    trackingNumberController.dispose();
  });
}
