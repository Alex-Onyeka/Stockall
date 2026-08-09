import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_item_history/production_item_history.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_items/production_item.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/components/text_fields/edit_cart_text_field.dart';
import 'package:stockall/components/toggle_button/my_toggle_button.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/products/product_details/platforms/components/item_comment_widget.dart';
import 'package:stockall/pages/products/product_details/platforms/product_details_desktop.dart';

Future<Object?> updateProductionItemQuantity(
  BuildContext context,
  ProductionItem productionItem,
) {
  return showGeneralDialog(
    context: context,
    pageBuilder: (context, animation, secondaryAnimation) {
      return UpdateProductionItemQuantityWidget(
        productionItem: productionItem,
      );
    },
  );
}

class UpdateProductionItemQuantityWidget
    extends StatefulWidget {
  final ProductionItem productionItem;
  const UpdateProductionItemQuantityWidget({
    super.key,
    required this.productionItem,
  });

  @override
  State<UpdateProductionItemQuantityWidget> createState() =>
      _UpdateProductionItemQuantityWidgetState();
}

class _UpdateProductionItemQuantityWidgetState
    extends State<UpdateProductionItemQuantityWidget> {
  bool isEditQuantityLoading = false;
  final quantityController = TextEditingController();
  final commentController = TextEditingController();
  bool isAddToQuantity = true;
  bool updateGroup = false;

  String returnUnitText() {
    if (updateGroup) {
      return widget.productionItem.groupUnit == null ||
              widget.productionItem.groupUnit == 'Others'
          ? ''
          : " Group";
    } else {
      return widget.productionItem.unit.isEmpty ||
              widget.productionItem.unit == 'Others'
          ? ''
          : " Unit";
    }
  }

  double returnGroupQuantity() {
    if (updateGroup) {
      return (widget.productionItem.quantity ?? 0) /
          (widget.productionItem.qttyPerGroup ?? 0);
    } else {
      return (widget.productionItem.quantity ?? 0);
    }
  }

  double returnUnitQuantity(double value) {
    if (updateGroup) {
      return value *
          (widget.productionItem.qttyPerGroup ?? 0);
    } else {
      return value;
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Scaffold(
      body: Center(
        child: GestureDetector(
          onTap:
              () =>
                  FocusManager.instance.primaryFocus
                      ?.unfocus(),
          child: Container(
            decoration: BoxDecoration(color: Colors.white),
            child: Padding(
              padding: const EdgeInsets.only(
                left: 20.0,
                top: 40,
                right: 20,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(30),
                    margin: EdgeInsets.only(bottom: 100),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                        15,
                      ),
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
                                icon: Icon(Icons.clear),
                              ),
                            ),
                            Text(
                              style: TextStyle(
                                fontSize:
                                    theme
                                        .mobileTexts
                                        .b2
                                        .fontSize,
                                fontWeight: FontWeight.bold,
                              ),
                              'Edit${returnUnitText()} Quantity',
                            ),
                            Builder(
                              builder: (context) {
                                if (isEditQuantityLoading ==
                                    true) {
                                  return SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color:
                                          theme
                                              .lightModeColor
                                              .secColor200,
                                      strokeWidth: 3,
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
                                      size: 20,
                                      Icons.clear,
                                    ),
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
                                fontSize:
                                    theme
                                        .mobileTexts
                                        .b3
                                        .fontSize,
                              ),
                              widget
                                          .productionItem
                                          .quantity ==
                                      null
                                  ? 'Quantity Not Set'
                                  : 'Current${returnUnitText()} Quantity : ${formatLargeNumberDouble(returnGroupQuantity())}',
                            ),
                            EditCartTextField(
                              onChanged: (value) {
                                if (value.isEmpty) {
                                  setState(() {
                                    quantityController
                                        .text = '0';
                                  });
                                }
                              },
                              title:
                                  '${returnUnitText()} Quantity',
                              hint: 'Enter Quantity Amount',
                              controller:
                                  quantityController,
                              theme: theme,
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Visibility(
                          visible:
                              returnShopProvider()
                                  .userShop()
                                  ?.useGroupUnit ==
                              true,
                          child: Column(
                            children: [
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: 230,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment
                                          .spaceBetween,
                                  children: [
                                    Text(
                                      style: TextStyle(
                                        fontWeight:
                                            FontWeight.bold,
                                        fontSize:
                                            theme
                                                .mobileTexts
                                                .b3
                                                .fontSize,
                                      ),
                                      'Update Group Quantity?',
                                    ),
                                    MyToggleButton(
                                      isSmall:
                                          screenWidth(
                                            context,
                                          ) <=
                                          mobileScreen,
                                      boolValue:
                                          updateGroup,
                                      toggle: () {
                                        setState(() {
                                          updateGroup =
                                              !updateGroup;
                                          // quantityController
                                          //     .clear();
                                        });
                                      },
                                      theme: theme,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 20),
                            ],
                          ),
                        ),

                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          spacing: 5,
                          children: [
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                mouseCursor:
                                    SystemMouseCursors
                                        .click,
                                onTap: () {
                                  setState(() {
                                    isAddToQuantity = true;
                                  });
                                },
                                child: Container(
                                  padding:
                                      EdgeInsets.symmetric(
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
                                                    ? Colors
                                                        .grey
                                                    : Colors
                                                        .transparent,
                                          ),
                                          color:
                                              isAddToQuantity
                                                  ? theme
                                                      .lightModeColor
                                                      .prColor250
                                                  : Colors
                                                      .transparent,
                                          shape:
                                              BoxShape
                                                  .circle,
                                        ),
                                        child: Icon(
                                          size: 14,
                                          color:
                                              Colors.white,
                                          Icons.check,
                                        ),
                                      ),
                                      Text(
                                        style: TextStyle(
                                          fontSize:
                                              theme
                                                  .mobileTexts
                                                  .b4
                                                  .fontSize,
                                          fontWeight:
                                              FontWeight
                                                  .bold,
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
                                mouseCursor:
                                    SystemMouseCursors
                                        .click,
                                onTap: () {
                                  setState(() {
                                    isAddToQuantity = false;
                                  });
                                },
                                child: Container(
                                  padding:
                                      EdgeInsets.symmetric(
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
                                                    ? Colors
                                                        .grey
                                                    : Colors
                                                        .transparent,
                                          ),
                                          color:
                                              !isAddToQuantity
                                                  ? theme
                                                      .lightModeColor
                                                      .prColor250
                                                  : Colors
                                                      .transparent,
                                          shape:
                                              BoxShape
                                                  .circle,
                                        ),
                                        child: Icon(
                                          size: 14,
                                          color:
                                              Colors.white,
                                          Icons.check,
                                        ),
                                      ),
                                      Text(
                                        style: TextStyle(
                                          fontSize:
                                              theme
                                                  .mobileTexts
                                                  .b4
                                                  .fontSize,
                                          fontWeight:
                                              FontWeight
                                                  .bold,
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
                        ItemCommentWidget(
                          commentController:
                              commentController,
                        ),
                        SizedBox(height: 15),
                        MainButtonP(
                          themeProvider: theme,
                          action: () {
                            final safeContext = context;

                            final productionItemsProvider =
                                returnProductionItemsProvider();

                            if (isEditQuantityLoading ==
                                false) {
                              showDialog(
                                context: safeContext,
                                builder: (confirmDialog) {
                                  return ConfirmationAlert(
                                    theme: theme,
                                    message:
                                        quantityController
                                                    .text
                                                    .isEmpty &&
                                                !isAddToQuantity
                                            ? 'You are about to empty your entire Production Item stock, are you sure?'
                                            : 'Are you sure you want to proceed?',
                                    title:
                                        quantityController
                                                    .text
                                                    .isEmpty &&
                                                !isAddToQuantity
                                            ? "Empty Stock?"
                                            : 'Proceed?',
                                    action: () async {
                                      Navigator.of(
                                        confirmDialog,
                                      ).pop();
                                      setState(() {
                                        isEditQuantityLoading =
                                            true;
                                      });
                                      double setQuantity() {
                                        if (isAddToQuantity) {
                                          return returnUnitQuantity(
                                                double.parse(
                                                  quantityController
                                                      .text
                                                      .replaceAll(
                                                        ',',
                                                        '',
                                                      ),
                                                ),
                                              ) +
                                              (widget
                                                      .productionItem
                                                      .quantity ??
                                                  0);
                                        } else {
                                          return returnUnitQuantity(
                                            double.parse(
                                              quantityController
                                                  .text
                                                  .replaceAll(
                                                    ',',
                                                    '',
                                                  ),
                                            ),
                                          );
                                        }
                                      }

                                      bool isIncrement =
                                          setQuantity() >=
                                          (widget
                                                  .productionItem
                                                  .quantity ??
                                              0);
                                      ProductionItemHistory
                                      productionItemHistory = ProductionItemHistory(
                                        shopId: shopId(),
                                        desc:
                                            commentController
                                                    .text
                                                    .isNotEmpty
                                                ? commentController
                                                    .text
                                                : 'Item Quantity Was Updated.',
                                        isIncreased:
                                            isIncrement,
                                        title:
                                            'Item Quantity ${isIncrement ? "Increased" : 'Reduced'}',
                                        quantityChange:
                                            (setQuantity() -
                                                (widget
                                                        .productionItem
                                                        .quantity ??
                                                    0)),
                                        newValue:
                                            setQuantity()
                                                .toString(),
                                        oldValue:
                                            (widget.productionItem.quantity ??
                                                    0)
                                                .toString(),
                                      );

                                      await productionItemsProvider.updateProductionItem(
                                        productionItemHistory:
                                            productionItemHistory,
                                        includeQuantity:
                                            true,
                                        isIncrement:
                                            isIncrement,
                                        isQuantityUpdate:
                                            true,
                                        quantityChange:
                                            (setQuantity() -
                                                (widget
                                                        .productionItem
                                                        .quantity ??
                                                    0)),
                                        productionItem: ProductionItem(
                                          categories:
                                              widget
                                                  .productionItem
                                                  .categories,
                                          departmentName:
                                              widget
                                                  .productionItem
                                                  .departmentName,
                                          departmentUuid:
                                              widget
                                                  .productionItem
                                                  .departmentUuid,
                                          groupUnit:
                                              widget
                                                  .productionItem
                                                  .groupUnit,
                                          qttyPerGroup:
                                              widget
                                                  .productionItem
                                                  .qttyPerGroup,
                                          updatedAt:
                                              DateTime.now(),
                                          isManaged:
                                              widget
                                                  .productionItem
                                                  .isManaged,
                                          name:
                                              widget
                                                  .productionItem
                                                  .name,
                                          unit:
                                              widget
                                                  .productionItem
                                                  .unit,
                                          costPrice:
                                              widget
                                                  .productionItem
                                                  .costPrice,
                                          quantity:
                                              setQuantity(),
                                          shopId:
                                              widget
                                                  .productionItem
                                                  .shopId,
                                          barcode:
                                              widget
                                                  .productionItem
                                                  .barcode,
                                          // categoryUuid:
                                          //     widget
                                          //         .productionItem
                                          //         .categoryUuid,
                                          createdAt:
                                              widget
                                                  .productionItem
                                                  .createdAt,
                                          expiryDate:
                                              widget
                                                  .productionItem
                                                  .expiryDate,
                                          sizeType:
                                              widget
                                                  .productionItem
                                                  .sizeType,
                                          uuid:
                                              widget
                                                  .productionItem
                                                  .uuid,
                                        ),
                                        oldProductionItem:
                                            widget
                                                .productionItem,
                                      );

                                      if (safeContext
                                          .mounted) {
                                        Navigator.of(
                                          safeContext,
                                        ).pop();
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
