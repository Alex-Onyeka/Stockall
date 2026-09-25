import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_production_folder/temp_material_class/material_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/components/text_fields/money_textfield.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/products/product_details/platforms/components/edit_button.dart';
import 'package:stockall/providers/theme_provider.dart';

void updateCostPriceActionMaterialItem({
  required MaterialClass material,
  required BuildContext context,
  required TextEditingController costController,
  required ThemeProvider theme,
}) {
  costController.text =
      material.costPrice.toString().toString();
  bool isEditPriceLoading = false;
  showGeneralDialog(
    context: context,
    pageBuilder: (context, animation, secondaryAnimation) {
      return StatefulBuilder(
        builder:
            (context, setState) => Material(
              color: Colors.transparent,
              child: GestureDetector(
                onTap:
                    () =>
                        FocusManager.instance.primaryFocus
                            ?.unfocus(),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 30.0,
                      top: 40,
                      right: 30,
                    ),
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(40),
                          margin: EdgeInsets.only(
                            bottom: 100,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: const Color.fromARGB(
                                  39,
                                  4,
                                  1,
                                  41,
                                ),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          width: 500,
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment
                                        .spaceBetween,
                                children: [
                                  Opacity(
                                    opacity: 0,
                                    child: IconButton(
                                      mouseCursor:
                                          SystemMouseCursors
                                              .click,
                                      onPressed: () {},
                                      icon: Icon(
                                        Icons.clear,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    style: TextStyle(
                                      fontSize:
                                          theme
                                              .mobileTexts
                                              .b1
                                              .fontSize,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                    'Edit Prices',
                                  ),
                                  Builder(
                                    builder: (context) {
                                      if (isEditPriceLoading ==
                                          true) {
                                        return SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth:
                                                1.5,
                                            color:
                                                theme
                                                    .lightModeColor
                                                    .secColor200,
                                          ),
                                        );
                                      } else {
                                        return IconButton(
                                          mouseCursor:
                                              SystemMouseCursors
                                                  .click,
                                          onPressed: () {
                                            Navigator.of(
                                              context,
                                            ).pop();
                                          },
                                          icon: Icon(
                                            Icons.clear,
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                              SizedBox(height: 15),
                              Column(
                                children: [
                                  MoneyTextfield(
                                    title: 'Cost Price',
                                    hint:
                                        'Enter Cost Price',
                                    controller:
                                        costController,
                                    theme: theme,
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),
                              MainButtonP(
                                themeProvider: theme,
                                action: () {
                                  final safeContext =
                                      context;
                                  if (isEditPriceLoading ==
                                      false) {
                                    showDialog(
                                      context: safeContext,
                                      builder: (
                                        confirmDialog,
                                      ) {
                                        return ConfirmationAlert(
                                          theme: theme,
                                          message:
                                              'Are you sure you want to proceed?',
                                          title: 'Proceed?',
                                          action: () async {
                                            final materialsProvider =
                                                returnMaterialsProvider();
                                            Navigator.of(
                                              confirmDialog,
                                            ).pop();
                                            setState(() {
                                              isEditPriceLoading =
                                                  true;
                                            });
                                            await materialsProvider.updateMaterial(
                                              isMultipleUpdate:
                                                  false,
                                              materialsItemHistory:
                                                  null,
                                              includeQuantity:
                                                  false,
                                              isIncrement:
                                                  null,
                                              isQuantityUpdate:
                                                  false,
                                              quantityChange:
                                                  null,
                                              material: MaterialClass(
                                                unitsList:
                                                    material
                                                        .unitsList,
                                                useGroupUnit:
                                                    material
                                                        .useGroupUnit,
                                                categories:
                                                    material
                                                        .categories,
                                                departmentName:
                                                    material
                                                        .departmentName,
                                                departmentUuid:
                                                    material
                                                        .departmentUuid,
                                                groupUnit:
                                                    material
                                                        .groupUnit,
                                                qttyPerGroup:
                                                    material
                                                        .qttyPerGroup,
                                                updatedAt:
                                                    DateTime.now(),
                                                isManaged:
                                                    material
                                                        .isManaged,
                                                name:
                                                    material
                                                        .name,
                                                unit:
                                                    material
                                                        .unit,
                                                costPrice:
                                                    double.tryParse(
                                                      costController.text.replaceAll(
                                                        ',',
                                                        '',
                                                      ),
                                                    ) ??
                                                    0,
                                                quantity:
                                                    material
                                                        .quantity,
                                                shopId:
                                                    material
                                                        .shopId,
                                                barcode:
                                                    material
                                                        .barcode,
                                                // categoryUuid:
                                                //     material
                                                //         .categoryUuid,
                                                createdAt:
                                                    material
                                                        .createdAt,
                                                expiryDate:
                                                    material
                                                        .expiryDate,
                                                lowQtty:
                                                    material
                                                        .lowQtty,
                                                sizeType:
                                                    material
                                                        .sizeType,
                                                uuid:
                                                    material
                                                        .uuid,
                                              ),
                                              oldMaterial:
                                                  material,
                                            );
                                            if (safeContext
                                                .mounted) {
                                              Navigator.of(
                                                safeContext,
                                              ).pop();
                                              setState(
                                                () {},
                                              );
                                            }
                                          },
                                        );
                                      },
                                    );
                                  }
                                },
                                text: 'Update Price',
                              ),
                              SizedBox(height: 15),
                              Material(
                                color: Colors.transparent,
                                child: EditButton(
                                  text: 'Cancel',
                                  action: () {
                                    Navigator.of(
                                      context,
                                    ).pop();
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
    },
  );
}
