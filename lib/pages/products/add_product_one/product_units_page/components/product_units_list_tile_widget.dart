import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_product_class/units_class/product_units_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/products/add_product_one/product_units_page/components/create_product_unit_widget.dart';

class ProductUnitListTileWidget extends StatefulWidget {
  final String unitUuid;
  final bool isDimensional;
  const ProductUnitListTileWidget({
    super.key,
    required this.unitUuid,
    this.isDimensional = false,
  });

  @override
  State<ProductUnitListTileWidget> createState() =>
      _ProductUnitListTileWidgetState();
}

class _ProductUnitListTileWidgetState
    extends State<ProductUnitListTileWidget> {
  // bool isLoading = false;
  // bool isDeleteLoading = false;
  TextEditingController nameController =
      TextEditingController();

  TextEditingController quantityController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    ProductUnitsClass unit =
        returnData(context: context).tempUnitsList
                .where(
                  (unit) => unit.uuid == widget.unitUuid,
                )
                .isNotEmpty
            ? returnData(context: context).tempUnitsList
                .where(
                  (unit) => unit.uuid == widget.unitUuid,
                )
                .first
            : ProductUnitsClass(
              name: 'Not Set',
              uuid: uuidGen(),
              conversion: 1,
              createdAt: DateTime.now(),
              isPrimary: true,
              productUuid: '',
              staffName: currentUser().name,
              staffUuid: currentUser().userId!,
              dimensionType: null,
            );
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(10, 0, 0, 0),
            blurRadius: 10,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 10,
            ),

            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    spacing: 10,
                    children: [
                      Icon(
                        size: 18,
                        color:
                            theme
                                .lightModeColor
                                .secColor200,
                        Icons.workspaces_outline,
                      ),
                      Flexible(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          spacing: 2,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(
                                    top: 2.0,
                                  ),
                              child: Text(
                                style: TextStyle(
                                  fontSize:
                                      theme
                                          .mobileTexts
                                          .b3
                                          .fontSize,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                                unit.getUnitName(),
                              ),
                            ),
                            Row(
                              spacing: 3,
                              children: [
                                Text(
                                  style: TextStyle(
                                    fontSize:
                                        theme
                                            .mobileTexts
                                            .b4
                                            .fontSize,
                                    fontWeight:
                                        FontWeight.normal,
                                  ),
                                  "Conversion:",
                                ),
                                Text(
                                  style: TextStyle(
                                    fontSize:
                                        theme
                                            .mobileTexts
                                            .b4
                                            .fontSize,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                  formatLargeNumberDouble(
                                    unit.conversion,
                                  ),
                                ),
                              ],
                            ),
                            if (widget.isDimensional)
                              Text(
                                unit.dimensionType ==
                                        ProductUnitsClass.areaUnit
                                    ? 'Area unit'
                                    : 'Whole slab / sheet unit',
                                style: theme.mobileTexts.b4.textStyleNormal,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.end,
                  spacing: 8,
                  children: [
                    InkWell(
                      onTap: () {
                        if (!unit.isPrimary) {
                          showDialog(
                            context: context,
                            builder: (confirmContext) {
                              return ConfirmationAlert(
                                theme: theme,
                                message:
                                    'You are about to make this Unit your Business Primary Unit. This means, all your items quantities are represented in this unit, unless manually Changed.',
                                title: 'Make Primary Unit',
                                action: () {
                                  Navigator.of(
                                    confirmContext,
                                  ).pop();
                                  returnData()
                                      .selectPrimaryUnit(
                                        unitListSingle:
                                            unit,
                                      );
                                },
                              );
                            },
                          );
                        }
                      },
                      mouseCursor: SystemMouseCursors.click,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          8.0,
                          10,
                          8,
                          5,
                        ),
                        child: Row(
                          spacing: 3,
                          children: [
                            Text(
                              style: TextStyle(
                                fontSize:
                                    theme
                                        .mobileTexts
                                        .b4
                                        .fontSize,
                                fontWeight:
                                    FontWeight.normal,
                              ),
                              "${unit.isPrimary ? '' : 'Make '}Primary Unit:",
                            ),
                            Container(
                              padding: EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(
                                      4,
                                    ),
                                color:
                                    unit.isPrimary
                                        ? theme
                                            .lightModeColor
                                            .prColor250
                                        : Colors
                                            .transparent,
                                border: Border.all(
                                  color:
                                      Colors.grey.shade100,
                                ),
                              ),
                              child: Icon(
                                size: 13,
                                color:
                                    unit.isPrimary
                                        ? Colors.white
                                        : Colors
                                            .grey
                                            .shade100,
                                Icons.check,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      spacing: 2,
                      children: [
                        Visibility(
                          visible:
                              returnData(
                                context: context,
                              ).tempUnitsList.length >
                              1,
                          child: Material(
                            type: MaterialType.transparency,
                            child: InkWell(
                              mouseCursor:
                                  SystemMouseCursors.click,
                              borderRadius:
                                  BorderRadius.circular(5),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (mainDialog) {
                                    return ConfirmationAlert(
                                      theme: theme,
                                      message:
                                          'You are about to delete this Product Unit, Are you sure you want to proceed?',
                                      title:
                                          'Delete Product Unit',
                                      action: () async {
                                        Navigator.of(
                                          mainDialog,
                                        ).pop();
                                        returnData()
                                            .deleteProductUnit(
                                              unitListSingle:
                                                  unit,
                                            );
                                      },
                                    );
                                  },
                                );
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(
                                      horizontal: 18,
                                      vertical: 3,
                                    ),
                                child: Icon(
                                  size: 18,
                                  color:
                                      Colors.red.shade400,
                                  Icons
                                      .delete_outline_rounded,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Material(
                          type: MaterialType.transparency,
                          child: InkWell(
                            mouseCursor:
                                SystemMouseCursors.click,
                            borderRadius:
                                BorderRadius.circular(5),
                            onTap: () {
                              addProductUnitAction(
                                context: context,
                                quantityController:
                                    quantityController,
                                nameController:
                                    nameController,
                                productUuid:
                                    unit.productUuid,
                                isDimensional:
                                    widget.isDimensional,
                                unit: unit,
                                setStateAction: () {
                                  setState(() {});
                                },
                              );
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 3,
                                  ),
                              child: Icon(
                                size: 16,
                                color: Colors.grey,
                                Icons.edit,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
