import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_item_history/item_history.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
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

Future<Object?> updateItemQuantity(
  BuildContext context,
  TempProductClass product,
) {
  return showGeneralDialog(
    context: context,
    pageBuilder: (context, animation, secondaryAnimation) {
      return UpdateItemQuantityWidget(product: product);
    },
  );
}

class UpdateItemQuantityWidget extends StatefulWidget {
  final TempProductClass product;
  const UpdateItemQuantityWidget({
    super.key,
    required this.product,
  });

  @override
  State<UpdateItemQuantityWidget> createState() =>
      _UpdateItemQuantityWidgetState();
}

class _UpdateItemQuantityWidgetState
    extends State<UpdateItemQuantityWidget> {
  bool isEditQuantityLoading = false;
  final quantityController = TextEditingController();
  final commentController = TextEditingController();
  bool isAddToQuantity = true;
  bool updateGroup = false;

  String returnUnitText() {
    if (updateGroup) {
      return widget.product.groupUnit == null ||
              widget.product.groupUnit == 'Others'
          ? ''
          : " Group(s)";
    } else {
      return widget.product.unit.isEmpty ||
              widget.product.unit == 'Others'
          ? ''
          : " Unit(s)";
    }
  }

  double returnGroupQuantity() {
    if (updateGroup) {
      return (widget.product.quantity ?? 0) /
          (widget.product.qttyPerGroup ?? 0);
    } else {
      return (widget.product.quantity ?? 0);
    }
  }

  double returnUnitQuantity(double value) {
    if (updateGroup) {
      return value * (widget.product.qttyPerGroup ?? 0);
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
                              widget.product.quantity ==
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
                                } else if (value
                                        .toString()[0] ==
                                    '0') {
                                  setState(() {
                                    quantityController
                                        .text = value
                                        .substring(1);
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
                              widget.product.useGroupUnit ==
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

                            final dataProvider =
                                returnData();

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
                                            ? 'You are about to empty your entire product stock, are you sure?'
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
                                                      .product
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
                                                  .product
                                                  .quantity ??
                                              0);
                                      ItemHistory
                                      itemHistory = ItemHistory(
                                        shopId: shopId(),
                                        title:
                                            'Item Quantity ${isIncrement ? "Increased" : 'Reduced'}',
                                        quantityChange:
                                            (setQuantity() -
                                                (widget
                                                        .product
                                                        .quantity ??
                                                    0)),
                                        newValue:
                                            setQuantity()
                                                .toString(),
                                        desc:
                                            commentController
                                                    .text
                                                    .isNotEmpty
                                                ? commentController
                                                    .text
                                                : 'This Item Quantity Was Updated.',
                                        isIncreased:
                                            isIncrement,
                                        oldValue:
                                            (widget.product.quantity ??
                                                    0)
                                                .toString(),
                                      );

                                      await dataProvider.updateProduct(
                                        itemHistory:
                                            itemHistory,
                                        includeQuantity:
                                            true,
                                        isIncrement:
                                            isIncrement,
                                        isQuantityUpdate:
                                            false,
                                        quantityChange:
                                            (setQuantity() -
                                                    (widget.product.quantity ??
                                                        0))
                                                .abs(),
                                        product: TempProductClass(
                                          categories:
                                              widget
                                                  .product
                                                  .categories,
                                          useGroupUnit:
                                              widget
                                                  .product
                                                  .useGroupUnit,
                                          storageUuid:
                                              widget
                                                  .product
                                                  .storageUuid,
                                          departmentName:
                                              widget
                                                  .product
                                                  .departmentName,
                                          departmentUuid:
                                              widget
                                                  .product
                                                  .departmentUuid,
                                          groupUnit:
                                              widget
                                                  .product
                                                  .groupUnit,
                                          qttyPerGroup:
                                              widget
                                                  .product
                                                  .qttyPerGroup,
                                          updatedAt:
                                              DateTime.now(),
                                          setCustomPrice:
                                              widget
                                                  .product
                                                  .setCustomPrice,
                                          totalQttyInStorageDouble:
                                              widget
                                                  .product
                                                  .totalQttyInStorageDouble,
                                          isManaged:
                                              widget
                                                  .product
                                                  .isManaged,
                                          name:
                                              widget
                                                  .product
                                                  .name,
                                          unit:
                                              widget
                                                  .product
                                                  .unit,
                                          isRefundable:
                                              widget
                                                  .product
                                                  .isRefundable,
                                          costPrice:
                                              widget
                                                  .product
                                                  .costPrice,
                                          sellingPrice:
                                              widget
                                                  .product
                                                  .sellingPrice,
                                          wholeSalePrice:
                                              widget
                                                  .product
                                                  .wholeSalePrice,
                                          quantity:
                                              setQuantity(),
                                          shopId:
                                              widget
                                                  .product
                                                  .shopId,
                                          barcode:
                                              widget
                                                  .product
                                                  .barcode,
                                          createdAt:
                                              widget
                                                  .product
                                                  .createdAt,
                                          discount:
                                              widget
                                                  .product
                                                  .discount,
                                          endDate:
                                              widget
                                                  .product
                                                  .endDate,
                                          expiryDate:
                                              widget
                                                  .product
                                                  .expiryDate,
                                          lowQtty:
                                              widget
                                                  .product
                                                  .lowQtty,
                                          sizeType:
                                              widget
                                                  .product
                                                  .sizeType,
                                          startDate:
                                              widget
                                                  .product
                                                  .startDate,
                                          uuid:
                                              widget
                                                  .product
                                                  .uuid,
                                        ),
                                        oldProduct:
                                            widget.product,
                                      );

                                      if (safeContext
                                          .mounted) {
                                        Navigator.of(
                                          safeContext,
                                        ).pop();
                                        setState(() {
                                          // productFuture =
                                          //     getProduct();
                                        });
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
