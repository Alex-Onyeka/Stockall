import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_production_folder/temp_material_class/material_class.dart';
import 'package:stockall/classes/temp_production_folder/temp_materials_item_history/material_item_history_event_class.dart';
import 'package:stockall/classes/temp_production_folder/temp_materials_item_history/materials_item_history.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/components/text_fields/edit_cart_text_field.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/products/product_details/platforms/components/edit_button.dart';
import 'package:stockall/pages/products/product_details/platforms/components/item_comment_widget.dart';
import 'package:stockall/pages/products/product_details/platforms/components/unit_selection_widget.dart';

Future<Object?> updateMaterialItemQuantity(
  BuildContext context,
  MaterialClass materialClass,
) {
  return showGeneralDialog(
    context: context,
    pageBuilder: (context, animation, secondaryAnimation) {
      return UpdateMaterialQuantityWidget(materialClass: materialClass);
    },
  );
}

class UpdateMaterialQuantityWidget extends StatefulWidget {
  final MaterialClass materialClass;
  const UpdateMaterialQuantityWidget({super.key, required this.materialClass});

  @override
  State<UpdateMaterialQuantityWidget> createState() =>
      _UpdateMaterialQuantityWidgetState();
}

class _UpdateMaterialQuantityWidgetState
    extends State<UpdateMaterialQuantityWidget> {
  bool isEditQuantityLoading = false;
  final quantityController = TextEditingController();
  final commentController = TextEditingController();
  bool isAddToQuantity = true;
  String? unitUuid;

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Scaffold(
      body: Center(
        child: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Container(
            decoration: BoxDecoration(color: Colors.white),
            child: Padding(
              padding: const EdgeInsets.only(left: 20.0, top: 40, right: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(30),
                    margin: EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(39, 4, 1, 41),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    width: 500,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Opacity(
                              opacity: 0,
                              child: IconButton(
                                mouseCursor: SystemMouseCursors.click,
                                onPressed: () {},
                                icon: Icon(Icons.clear),
                              ),
                            ),
                            Text(
                              style: TextStyle(
                                fontSize: theme.mobileTexts.b2.fontSize,
                                fontWeight: FontWeight.bold,
                              ),
                              'Edit ${widget.materialClass.getProductUnit(unitUuid: unitUuid).name} Quantity',
                            ),
                            Builder(
                              builder: (context) {
                                if (isEditQuantityLoading == true) {
                                  return SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: theme.lightModeColor.secColor200,
                                      strokeWidth: 3,
                                    ),
                                  );
                                } else {
                                  return IconButton(
                                    mouseCursor: SystemMouseCursors.click,
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    icon: Icon(size: 20, Icons.clear),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Column(
                          spacing: 20,
                          children: [
                            Text(
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: theme.mobileTexts.b3.fontSize,
                              ),
                              widget.materialClass.quantity == null
                                  ? 'Quantity Not Set'
                                  : 'Current Quantity in ${widget.materialClass.getProductUnit(unitUuid: unitUuid).name}: ${formatLargeNumberDouble(widget.materialClass.getProductUnit(unitUuid: unitUuid).getQuantityEquivDivided(index: 3, context: context))}',
                            ),
                            EditCartTextField(
                              onChanged: (value) {
                                if (value.isEmpty) {
                                  setState(() {
                                    quantityController.text = '0';
                                  });
                                }
                              },
                              title:
                                  '${widget.materialClass.getProductUnit(unitUuid: unitUuid).name} Quantity',
                              hint: 'Enter Quantity Amount',
                              controller: quantityController,
                              theme: theme,
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        UnitSelectionWidget(
                          storageProduct: null,
                          material: widget.materialClass,
                          productionItem: null,
                          product: null,
                          setUnitUuid: (uuid) {
                            setState(() {
                              unitUuid = uuid;
                            });
                          },
                          theme: theme,
                          unitUuid: unitUuid,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: 5,
                          children: [
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                mouseCursor: SystemMouseCursors.click,
                                onTap: () {
                                  setState(() {
                                    isAddToQuantity = true;
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 6,
                                  ),
                                  child: Row(
                                    spacing: 6,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color:
                                                !isAddToQuantity
                                                    ? Colors.grey
                                                    : Colors.transparent,
                                          ),
                                          color:
                                              isAddToQuantity
                                                  ? theme
                                                      .lightModeColor
                                                      .prColor250
                                                  : Colors.transparent,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          size: 14,
                                          color: Colors.white,
                                          Icons.check,
                                        ),
                                      ),
                                      Text(
                                        style: TextStyle(
                                          fontSize:
                                              theme.mobileTexts.b4.fontSize,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        'Add to Quantity',
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                mouseCursor: SystemMouseCursors.click,
                                onTap: () {
                                  setState(() {
                                    isAddToQuantity = false;
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 6,
                                    horizontal: 6,
                                  ),
                                  child: Row(
                                    spacing: 5,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color:
                                                isAddToQuantity
                                                    ? Colors.grey
                                                    : Colors.transparent,
                                          ),
                                          color:
                                              !isAddToQuantity
                                                  ? theme
                                                      .lightModeColor
                                                      .prColor250
                                                  : Colors.transparent,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          size: 14,
                                          color: Colors.white,
                                          Icons.check,
                                        ),
                                      ),
                                      Text(
                                        style: TextStyle(
                                          fontSize:
                                              theme.mobileTexts.b4.fontSize,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        'Replace Quantity',
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 15),
                        ItemCommentWidget(commentController: commentController),
                        SizedBox(height: 15),
                        MainButtonP(
                          themeProvider: theme,
                          action: () {
                            final safeContext = context;

                            final materialClasssProvider =
                                returnMaterialsProvider();

                            if (isEditQuantityLoading == false) {
                              showDialog(
                                context: safeContext,
                                builder: (confirmDialog) {
                                  return ConfirmationAlert(
                                    theme: theme,
                                    message:
                                        quantityController.text.isEmpty &&
                                                !isAddToQuantity
                                            ? 'You are about to empty your entire Materials Item stock, are you sure?'
                                            : 'Are you sure you want to proceed?',
                                    title:
                                        quantityController.text.isEmpty &&
                                                !isAddToQuantity
                                            ? "Empty Stock?"
                                            : 'Proceed?',
                                    action: () async {
                                      Navigator.of(confirmDialog).pop();
                                      setState(() {
                                        isEditQuantityLoading = true;
                                      });
                                      double setQuantity() {
                                        if (isAddToQuantity) {
                                          return widget.materialClass
                                                  .getProductUnit(
                                                    unitUuid: unitUuid,
                                                  )
                                                  .getQuantityEquivMultiplied(
                                                    index: 3,
                                                    newQuantity: double.parse(
                                                      quantityController.text
                                                          .replaceAll(',', ''),
                                                    ),
                                                  ) +
                                              (widget.materialClass.quantity ??
                                                  0);
                                        } else {
                                          return widget.materialClass
                                              .getProductUnit(
                                                unitUuid: unitUuid,
                                              )
                                              .getQuantityEquivMultiplied(
                                                index: 3,
                                                newQuantity: double.parse(
                                                  quantityController.text
                                                      .replaceAll(',', ''),
                                                ),
                                              );
                                        }
                                      }

                                      bool isIncrement =
                                          setQuantity() >=
                                          (widget.materialClass.quantity ?? 0);
                                      MaterialsItemHistory
                                      materialsItemHistory = MaterialsItemHistory(
                                        event:
                                            isIncrement
                                                ? MaterialItemHistoryEventClass
                                                    .quantityUpdatedIncrease
                                                : MaterialItemHistoryEventClass
                                                    .quantityUpdatedDecrease,
                                        isManaged:
                                            widget.materialClass.isManaged,
                                        source:
                                            MaterialItemHistoryEventClass
                                                .unKnownSource,
                                        primaryUnit:
                                            widget.materialClass
                                                .getProductUnit()
                                                .name,
                                        unit:
                                            widget.materialClass
                                                .getProductUnit(
                                                  unitUuid: unitUuid,
                                                )
                                                .name,
                                        shopId: shopId(),
                                        desc:
                                            commentController.text.isNotEmpty
                                                ? commentController.text
                                                : 'Item Quantity Updated',
                                        isIncreased: isIncrement,
                                        title:
                                            'Item Quantity ${isIncrement ? "Increased" : 'Reduced'}',
                                        quantityChange: widget.materialClass
                                            .getProductUnit(unitUuid: unitUuid)
                                            .getQuantityEquivDivided(
                                              index: 3,
                                              newQuantity:
                                                  (setQuantity() -
                                                      (widget
                                                              .materialClass
                                                              .quantity ??
                                                          0)),
                                            ),
                                        newValue: formatLargeNumberDouble(
                                          widget.materialClass
                                              .getProductUnit()
                                              .getQuantityEquivDivided(
                                                index: 3,
                                                newQuantity: setQuantity(),
                                              ),
                                        ),
                                        oldValue: formatLargeNumberDouble(
                                          widget.materialClass
                                              .getProductUnit()
                                              .getQuantityEquivDivided(
                                                index: 3,
                                                newQuantity:
                                                    (widget
                                                            .materialClass
                                                            .quantity ??
                                                        0),
                                              ),
                                        ),
                                      );

                                      await materialClasssProvider
                                          .updateMaterial(
                                            isMultipleUpdate: false,
                                            materialsItemHistory:
                                                materialsItemHistory,
                                            includeQuantity: true,
                                            isIncrement: isIncrement,
                                            isQuantityUpdate: true,
                                            quantityChange:
                                                (setQuantity() -
                                                    (widget
                                                            .materialClass
                                                            .quantity ??
                                                        0)),
                                            material: MaterialClass(
                                              unitsList:
                                                  widget
                                                      .materialClass
                                                      .unitsList,
                                              useGroupUnit:
                                                  widget
                                                      .materialClass
                                                      .useGroupUnit,
                                              categories:
                                                  widget
                                                      .materialClass
                                                      .categories,
                                              lowQtty:
                                                  widget.materialClass.lowQtty,
                                              departmentName:
                                                  widget
                                                      .materialClass
                                                      .departmentName,
                                              departmentUuid:
                                                  widget
                                                      .materialClass
                                                      .departmentUuid,
                                              groupUnit:
                                                  widget
                                                      .materialClass
                                                      .groupUnit,
                                              qttyPerGroup:
                                                  widget
                                                      .materialClass
                                                      .qttyPerGroup,
                                              updatedAt: DateTime.now(),
                                              isManaged:
                                                  widget
                                                      .materialClass
                                                      .isManaged,
                                              name: widget.materialClass.name,
                                              unit: widget.materialClass.unit,
                                              costPrice:
                                                  widget
                                                      .materialClass
                                                      .costPrice,
                                              quantity: setQuantity(),
                                              shopId:
                                                  widget.materialClass.shopId,
                                              barcode:
                                                  widget.materialClass.barcode,
                                              // categoryUuid:
                                              //     widget
                                              //         .materialClass
                                              //         .categoryUuid,
                                              createdAt:
                                                  widget
                                                      .materialClass
                                                      .createdAt,
                                              expiryDate:
                                                  widget
                                                      .materialClass
                                                      .expiryDate,
                                              sizeType:
                                                  widget.materialClass.sizeType,
                                              uuid: widget.materialClass.uuid,
                                            ),
                                            oldMaterial: widget.materialClass,
                                          );

                                      if (safeContext.mounted) {
                                        Navigator.of(safeContext).pop();
                                        setState(() {});
                                      }
                                    },
                                  );
                                },
                              );
                            }
                          },
                          text: 'Update Quantity',
                        ),
                        SizedBox(height: 15),
                        Material(
                          color: Colors.transparent,
                          child: EditButton(
                            text: 'Cancel',
                            action: () {
                              Navigator.of(context).pop();
                            },
                            theme: theme,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
