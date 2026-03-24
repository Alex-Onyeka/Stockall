import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/dialog_template.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/components/text_fields/edit_cart_text_field.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/products/product_details/platforms/product_details_desktop.dart';

class QuantityEditWidget extends StatefulWidget {
  final TempProductClass product;
  final bool isTotal;
  final bool isGroup;
  const QuantityEditWidget({
    super.key,
    required this.product,
    required this.isTotal,
    required this.isGroup,
  });

  @override
  State<QuantityEditWidget> createState() =>
      _QuantityEditWidgetState();
}

class _QuantityEditWidgetState
    extends State<QuantityEditWidget> {
  // bool isActive = false;
  bool isAddToQuantity = true;
  final node = FocusNode();
  final controller = TextEditingController();

  bool isLoading = false;

  bool errorUpdating = false;

  void updateQuantity() {
    var theme = returnTheme(context, listen: false);
    node.requestFocus();
    showDialog(
      context: context,
      builder: (firstDialog) {
        return StatefulBuilder(
          builder:
              (context, setState) => DialogTemplate(
                theme: theme,
                message: '',
                title: '',
                showTopSection: false,
                showBottomActionButtons: false,
                action: () {},
                widget: Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
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
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
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
                            'Edit ${widget.isTotal
                                ? widget.isGroup
                                    ? "Group Quantity in Storage"
                                    : "Unit Quantity in Storage"
                                : "Quantity Unit In Sales"}',
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      Column(
                        spacing: 20,
                        children: [
                          Text(
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b3
                                      .fontSize,
                            ),
                            !widget.isTotal
                                ? (widget
                                            .product
                                            .quantity ==
                                        null
                                    ? 'Not Set'
                                    : 'Current ${widget.isGroup ? 'Group' : 'Unit'} Quantity In Sales: ${widget.isGroup ? formatLargeNumber(returnValue().toString()) : formatLargeNumber(widget.product.quantity?.toString() ?? '0')}')
                                : (widget
                                            .product
                                            .totalQttyInStorageDouble ==
                                        null
                                    ? 'Not Set'
                                    : 'Current ${widget.isGroup ? 'Group' : 'Unit'} Quantity In Storage: ${widget.isGroup ? formatLargeNumber(returnValue().toString()) : formatLargeNumber(widget.product.totalQttyInStorageDouble?.toString() ?? '0')}'),
                          ),
                          EditCartTextField(
                            onChanged: (value) {
                              if (value.isEmpty) {
                                setState(() {
                                  controller.text = '0';
                                });
                              } else if (value
                                      .toString()[0] ==
                                  '0') {
                                setState(() {
                                  controller.text = value
                                      .substring(1);
                                });
                              } else {
                                if (!widget.isTotal) {
                                  if (isAddToQuantity) {
                                    if (widget
                                            .product
                                            .isManaged &&
                                        returnShopProvider()
                                                .userShop()
                                                ?.manageInventoryStorage ==
                                            true) {
                                      if (((double.tryParse(
                                                    value.replaceAll(
                                                      ',',
                                                      '',
                                                    ),
                                                  ) ??
                                                  0) +
                                              (double.tryParse(
                                                    widget.product.quantity?.toString() ??
                                                        '0',
                                                  ) ??
                                                  0)) >
                                          ((widget
                                                      .product
                                                      .totalQttyInStorageDouble ??
                                                  0) +
                                              (double.tryParse(
                                                    widget.product.quantity?.toString() ??
                                                        '0',
                                                  ) ??
                                                  0))) {
                                        controller.text =
                                            '0';
                                      }
                                    }
                                  } else if (!isAddToQuantity) {
                                    if (widget
                                            .product
                                            .isManaged &&
                                        returnShopProvider()
                                                .userShop()
                                                ?.manageInventoryStorage ==
                                            true) {
                                      if (((double.tryParse(
                                                value
                                                    .replaceAll(
                                                      ',',
                                                      '',
                                                    ),
                                              ) ??
                                              0)) >
                                          ((widget
                                                      .product
                                                      .totalQttyInStorageDouble ??
                                                  0) +
                                              (double.tryParse(
                                                    widget.product.quantity?.toString() ??
                                                        '0',
                                                  ) ??
                                                  0))) {
                                        controller.text =
                                            '0';
                                      }
                                    }
                                  }
                                }
                              }
                            },
                            title: 'Quantity',
                            hint: 'Enter Quantity Amount',
                            controller: controller,
                            theme: theme,
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        spacing: 3,
                        children: [
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                node.requestFocus();
                                setState(() {
                                  isAddToQuantity = true;
                                });
                              },
                              child: Container(
                                padding:
                                    EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 10,
                                    ),
                                child: Row(
                                  spacing: 5,
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
                                            BoxShape.circle,
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
                                            theme
                                                .mobileTexts
                                                .b4
                                                .fontSize,
                                        fontWeight:
                                            isAddToQuantity
                                                ? FontWeight
                                                    .bold
                                                : null,
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
                              onTap: () {
                                node.requestFocus();
                                setState(() {
                                  isAddToQuantity = false;
                                });
                              },
                              child: Container(
                                padding:
                                    EdgeInsets.symmetric(
                                      vertical: 10,
                                      horizontal: 10,
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
                                            BoxShape.circle,
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
                                            theme
                                                .mobileTexts
                                                .b4
                                                .fontSize,
                                        fontWeight:
                                            !isAddToQuantity
                                                ? FontWeight
                                                    .bold
                                                : null,
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
                      MainButtonP(
                        themeProvider: theme,
                        action: () {
                          saveEdit();
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
              ),
        );
      },
    ).then((_) {
      setState(() {
        isAddToQuantity = true;
      });
      controller.clear();
      if (screenWidth(context) > mobileScreen) {
        returnData().requestFocusSearchNode();
        returnData().addSearchNodeListener();
      }
    });
  }

  void saveEdit() async {
    showDialog(
      context: context,
      builder: (newC) {
        return ConfirmationAlert(
          theme: returnTheme(context, listen: false),
          message:
              controller.text.isEmpty && !isAddToQuantity
                  ? 'You are about to empty your Inventory, are you sure you want to proceed?'
                  : 'You are about to permanently Save this update, are you sure you want to proceed?',
          title:
              controller.text.isEmpty && !isAddToQuantity
                  ? 'Clear Inventory'
                  : 'Update Quantity',
          action: () async {
            Navigator.of(newC).pop();
            Navigator.of(context).pop();
            node.unfocus();
            setState(() {
              errorUpdating = false;
              isLoading = true;
            });

            double totalQttyInStorageCalc() {
              if (widget.isTotal) {
                if (isAddToQuantity) {
                  return widget.isGroup
                      ? (widget
                                  .product
                                  .totalQttyInStorageDouble ??
                              0) +
                          ((double.tryParse(
                                    controller.text
                                        .replaceAll(
                                          ',',
                                          '',
                                        ),
                                  ) ??
                                  0) *
                              (widget
                                      .product
                                      .qttyPerGroup ??
                                  0))
                      : (widget
                                  .product
                                  .totalQttyInStorageDouble ??
                              0) +
                          (double.tryParse(
                                controller.text.replaceAll(
                                  ',',
                                  '',
                                ),
                              ) ??
                              0);
                } else {
                  return widget.isGroup
                      ? ((double.tryParse(
                                controller.text.replaceAll(
                                  ',',
                                  '',
                                ),
                              ) ??
                              0) *
                          (widget.product.qttyPerGroup ??
                              0))
                      : (double.tryParse(
                            controller.text.replaceAll(
                              ',',
                              '',
                            ),
                          ) ??
                          0);
                }
              } else {
                if (isAddToQuantity) {
                  return widget.isGroup
                      ? (widget
                                  .product
                                  .totalQttyInStorageDouble ??
                              0) -
                          (((double.tryParse(
                                        controller.text
                                            .replaceAll(
                                              ',',
                                              '',
                                            ),
                                      ) ??
                                      0))
                                  .toDouble() *
                              (widget
                                      .product
                                      .qttyPerGroup ??
                                  0))
                      : (widget
                                  .product
                                  .totalQttyInStorageDouble ??
                              0) -
                          ((double.tryParse(
                                    controller.text
                                        .replaceAll(
                                          ',',
                                          '',
                                        ),
                                  ) ??
                                  0))
                              .toDouble();
                } else {
                  return widget.isGroup
                      ? (widget
                                  .product
                                  .totalQttyInStorageDouble ??
                              0) -
                          (((double.tryParse(
                                            controller.text
                                                .replaceAll(
                                                  ',',
                                                  '',
                                                ),
                                          ) ??
                                          0) -
                                      (widget
                                              .product
                                              .quantity ??
                                          0))
                                  .toDouble() *
                              (widget
                                      .product
                                      .qttyPerGroup ??
                                  0))
                      : (widget
                                  .product
                                  .totalQttyInStorageDouble ??
                              0) -
                          ((double.tryParse(
                                        controller.text
                                            .replaceAll(
                                              ',',
                                              '',
                                            ),
                                      ) ??
                                      0) -
                                  (widget
                                          .product
                                          .quantity ??
                                      0))
                              .toDouble();
                }
              }
            }

            double? quantityCalc() {
              if (widget.isTotal) {
                return widget.product.quantity;
              } else {
                if (isAddToQuantity) {
                  return ((double.tryParse(
                            controller.text.replaceAll(
                              ',',
                              '',
                            ),
                          ) ??
                          0) +
                      (widget.product.quantity ?? 0));
                } else {
                  return ((double.tryParse(
                        controller.text.replaceAll(',', ''),
                      ) ??
                      0));
                }
              }
            }

            if (widget.isTotal) {
              var tempPro = TempProductClass(
                groupUnit: widget.product.groupUnit,
                qttyPerGroup: widget.product.qttyPerGroup,
                id: widget.product.id,
                uuid: widget.product.uuid,
                barcode: widget.product.barcode,
                brand: widget.product.brand,
                category: widget.product.category,
                color: widget.product.color,
                createdAt: widget.product.createdAt,
                departmentName:
                    widget.product.departmentName,
                departmentUuid:
                    widget.product.departmentUuid,
                discount: widget.product.discount,
                endDate: widget.product.endDate,
                expiryDate: widget.product.expiryDate,
                lowQtty: widget.product.lowQtty,
                sellingPrice: widget.product.sellingPrice,
                size: widget.product.size,
                sizeType: widget.product.sizeType,
                startDate: widget.product.startDate,
                updatedAt: widget.product.updatedAt,
                quantity: quantityCalc(),
                totalQttyInStorageDouble:
                    totalQttyInStorageCalc(),
                name: widget.product.name,
                unit: widget.product.unit,
                isRefundable: widget.product.isRefundable,
                costPrice: widget.product.costPrice,
                shopId: widget.product.shopId,
                setCustomPrice:
                    widget.product.setCustomPrice,
                isManaged: widget.product.isManaged,
              );
              var res = await returnData().updateProduct(
                product: tempPro,
                oldProduct: widget.product,
              );
              setState(() {
                isLoading = false;
              });
              if (res == null) {
                setState(() {
                  errorUpdating = true;
                });
              }
            } else {
              var tempPro = TempProductClass(
                groupUnit: widget.product.groupUnit,
                qttyPerGroup: widget.product.qttyPerGroup,
                id: widget.product.id,
                uuid: widget.product.uuid,
                barcode: widget.product.barcode,
                brand: widget.product.brand,
                category: widget.product.category,
                color: widget.product.color,
                createdAt: widget.product.createdAt,
                departmentName:
                    widget.product.departmentName,
                departmentUuid:
                    widget.product.departmentUuid,
                discount: widget.product.discount,
                endDate: widget.product.endDate,
                expiryDate: widget.product.expiryDate,
                lowQtty: widget.product.lowQtty,
                sellingPrice: widget.product.sellingPrice,
                size: widget.product.size,
                sizeType: widget.product.sizeType,
                startDate: widget.product.startDate,
                updatedAt: widget.product.updatedAt,
                quantity: quantityCalc(),
                totalQttyInStorageDouble:
                    totalQttyInStorageCalc(),
                name: widget.product.name,
                unit: widget.product.unit,
                isRefundable: widget.product.isRefundable,
                costPrice: widget.product.costPrice,
                shopId: widget.product.shopId,
                setCustomPrice:
                    widget.product.setCustomPrice,
                isManaged: widget.product.isManaged,
              );
              var res = await returnData().updateProduct(
                product: tempPro,
                oldProduct: widget.product,
              );
              setState(() {
                isLoading = false;
              });
              if (res == null) {
                setState(() {
                  errorUpdating = true;
                });
              }
            }
          },
        );
      },
    ).then((_) {
      if (screenWidth(context) > mobileScreen) {
        returnData().requestFocusSearchNode();
        returnData().addSearchNodeListener();
      }
    });
  }

  double returnValue() {
    if (widget.isGroup) {
      if (widget.isTotal) {
        return widget.product.qttyPerGroup != null
            ? (widget.product.totalQttyInStorageDouble ??
                    0) /
                (widget.product.qttyPerGroup ?? 0)
            : 0;
      } else {
        return widget.product.qttyPerGroup != null
            ? (widget.product.quantity ?? 0) /
                (widget.product.qttyPerGroup ?? 0)
            : 0;
      }
    } else {
      if (widget.isTotal) {
        return (widget.product.totalQttyInStorageDouble ??
            0);
      } else {
        return (widget.product.quantity ?? 0);
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
    node.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Container(
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: Colors.grey.shade500),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Opacity(
            opacity: 1,
            child: Padding(
              padding: const EdgeInsets.only(left: 13.0),
              child: Text(
                style: TextStyle(
                  fontSize: theme.mobileTexts.b3.fontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade900,
                ),
                formatLargeNumberDouble(returnValue()),
              ),
            ),
          ),
          Stack(
            children: [
              Visibility(
                visible: !isLoading && !errorUpdating,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 2,
                  children: [
                    InkWell(
                      onTap: () {
                        returnData().unFocusSearchNode();
                        returnData()
                            .removeSearchNodeListener();
                        updateQuantity();
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(9.0),
                        child: Icon(size: 12, Icons.edit),
                      ),
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: isLoading && !errorUpdating,
                child: Padding(
                  padding: const EdgeInsets.all(9.0),
                  child: SizedBox(
                    height: 15,
                    width: 15,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color:
                          theme.lightModeColor.secColor200,
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: errorUpdating,
                child: InkWell(
                  onTap: () {
                    returnData().unFocusSearchNode();
                    returnData().removeSearchNodeListener();
                    updateQuantity();
                  },
                  child: Padding(
                    padding: EdgeInsetsGeometry.all(9),
                    child: Icon(
                      size: 18,
                      color: Colors.red,
                      Icons.error_outline_outlined,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
