import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_item_history/item_history.dart';
import 'package:stockall/classes/temp_item_history/item_history_event_class.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/classes/temp_product_class/units_class/product_units_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/components/text_fields/edit_cart_text_field.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/products/product_details/platforms/components/edit_button.dart';
import 'package:stockall/pages/products/product_details/platforms/components/item_comment_widget.dart';
import 'package:stockall/pages/products/product_details/platforms/components/unit_selection_widget.dart';

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
  const UpdateItemQuantityWidget({super.key, required this.product});

  @override
  State<UpdateItemQuantityWidget> createState() =>
      _UpdateItemQuantityWidgetState();
}

class _UpdateItemQuantityWidgetState extends State<UpdateItemQuantityWidget> {
  bool isEditQuantityLoading = false;
  final quantityController = TextEditingController();
  final commentController = TextEditingController();
  final widthController = TextEditingController();
  final heightController = TextEditingController();
  bool isAddToQuantity = true;
  int quantityTypeTemp = 1;
  String? unitUuid;

  ProductUnitsClass selectedUnit() =>
      widget.product.getProductUnit(unitUuid: unitUuid);

  bool isAreaUnit() =>
      widget.product.quantityType == 2 &&
      selectedUnit().dimensionType == ProductUnitsClass.areaUnit;

  double quantityInArea(double quantity) {
    final isDimensionalSheet =
        widget.product.quantityType == 2 && !isAreaUnit();
    return selectedUnit().getQuantityEquivMultiplied(
      index: 1,
      product: widget.product,
      newQuantity: quantity,
      customWidth:
          isDimensionalSheet
              ? quantityTypeTemp == 2
                  ? double.tryParse(
                    widthController.text.replaceAll(',', '').trim(),
                  )
                  : widget.product.widthDimension
              : null,
      customHeight:
          isDimensionalSheet
              ? quantityTypeTemp == 2
                  ? double.tryParse(
                    heightController.text.replaceAll(',', '').trim(),
                  )
                  : widget.product.heightDimension
              : null,
    );
  }

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
              padding: const EdgeInsets.only(left: 20.0, top: 20, right: 20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(20),
                      margin: EdgeInsets.only(bottom: 30),
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
                                'Edit ${widget.product.getProductUnit(unitUuid: unitUuid).name} Quantity',
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
                            // spacing: 20,
                            children: [
                              Text(
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: theme.mobileTexts.b3.fontSize,
                                ),
                                widget.product.getActualQuantity() == null
                                    ? 'Quantity Not Set'
                                    : 'Current Quantity in ${widget.product.getProductUnit(unitUuid: unitUuid).name}: ${formatLargeNumberDouble(widget.product.getProductUnit(unitUuid: unitUuid).getQuantityEquivDivided(index: 1, context: context, product: widget.product))}',
                              ),
                              EditCartTextField(
                                onChanged: (value) {
                                  if (value.isEmpty) {
                                    setState(() {
                                      quantityController.text = '0';
                                    });
                                  } else if (value.toString()[0] == '0') {
                                    setState(() {
                                      quantityController.text = value.substring(
                                        1,
                                      );
                                    });
                                  }
                                },
                                title:
                                    '${widget.product.getProductUnit(unitUuid: unitUuid).name} Quantity',
                                hint: 'Enter Quantity Amount',
                                controller: quantityController,
                                theme: theme,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 10.0),
                                child: Builder(
                                  builder: (context) {
                                    if (quantityTypeTemp == 1) {
                                      return Container();
                                    } else {
                                      return Row(
                                        spacing: 10,
                                        children: [
                                          Expanded(
                                            child: EditCartTextField(
                                              onChanged: (value) {
                                                if (value.isEmpty) {
                                                  setState(() {
                                                    widthController.text = '0';
                                                  });
                                                } else if (value
                                                        .toString()[0] ==
                                                    '0') {
                                                  setState(() {
                                                    widthController.text = value
                                                        .substring(1);
                                                  });
                                                }
                                              },
                                              title:
                                                  '${widget.product.getProductUnit(unitUuid: unitUuid).name} Width',
                                              hint: 'Enter Width',
                                              controller: widthController,
                                              theme: theme,
                                            ),
                                          ),
                                          Expanded(
                                            child: EditCartTextField(
                                              onChanged: (value) {
                                                if (value.isEmpty) {
                                                  setState(() {
                                                    heightController.text = '0';
                                                  });
                                                } else if (value
                                                        .toString()[0] ==
                                                    '0') {
                                                  setState(() {
                                                    heightController.text =
                                                        value.substring(1);
                                                  });
                                                }
                                              },
                                              title:
                                                  '${widget.product.getProductUnit(unitUuid: unitUuid).name} Height',
                                              hint: 'Enter Height',
                                              controller: heightController,
                                              theme: theme,
                                            ),
                                          ),
                                        ],
                                      );
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Visibility(
                            visible:
                                widget.product.quantityType == 2 &&
                                !isAreaUnit(),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              spacing: 5,
                              children: [
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    mouseCursor: SystemMouseCursors.click,
                                    onTap: () {
                                      setState(() {
                                        quantityTypeTemp = 1;
                                        widthController.clear();
                                        heightController.clear();
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
                                                    quantityTypeTemp != 1
                                                        ? Colors.grey
                                                        : Colors.transparent,
                                              ),
                                              color:
                                                  quantityTypeTemp == 1
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
                                            'Enter Whole',
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
                                        quantityTypeTemp = 2;
                                        // quantityController
                                        //     .clear();
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
                                                    quantityTypeTemp != 2
                                                        ? Colors.grey
                                                        : Colors.transparent,
                                              ),
                                              color:
                                                  quantityTypeTemp == 2
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
                                            'Enter Dimensions',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10),
                          UnitSelectionWidget(
                            storageProduct: null,
                            material: null,
                            productionItem: null,
                            product: widget.product,
                            setUnitUuid: (uuid) {
                              setState(() {
                                unitUuid = uuid;
                                if (isAreaUnit()) {
                                  quantityTypeTemp = 1;
                                  widthController.clear();
                                  heightController.clear();
                                }
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
                          ItemCommentWidget(
                            commentController: commentController,
                          ),
                          SizedBox(height: 15),
                          MainButtonP(
                            themeProvider: theme,
                            action: () {
                              final safeContext = context;

                              final dataProvider = returnData();

                              if (isEditQuantityLoading == false) {
                                final quantityText =
                                    quantityController.text
                                        .replaceAll(',', '')
                                        .trim();
                                final enteredQuantity = double.tryParse(
                                  quantityText,
                                );
                                if ((quantityText.isNotEmpty &&
                                        (enteredQuantity == null ||
                                            !enteredQuantity.isFinite ||
                                            enteredQuantity < 0)) ||
                                    (isAddToQuantity &&
                                        (enteredQuantity == null ||
                                            enteredQuantity <= 0))) {
                                  showDialog(
                                    context: safeContext,
                                    builder:
                                        (context) => InfoAlert(
                                          theme: theme,
                                          message:
                                              'Enter a valid quantity greater than zero.',
                                          title: 'Invalid Quantity',
                                        ),
                                  );
                                  return;
                                }

                                if (quantityTypeTemp == 2 && !isAreaUnit()) {
                                  final width = double.tryParse(
                                    widthController.text
                                        .replaceAll(',', '')
                                        .trim(),
                                  );
                                  final height = double.tryParse(
                                    heightController.text
                                        .replaceAll(',', '')
                                        .trim(),
                                  );
                                  if (width == null ||
                                      height == null ||
                                      width <= 0 ||
                                      height <= 0 ||
                                      (widget.product.widthDimension != null &&
                                          width >
                                              widget.product.widthDimension!) ||
                                      (widget.product.heightDimension != null &&
                                          height >
                                              widget
                                                  .product
                                                  .heightDimension!)) {
                                    showDialog(
                                      context: safeContext,
                                      builder:
                                          (context) => InfoAlert(
                                            theme: theme,
                                            message:
                                                'Enter positive dimensions no larger than the original slab / sheet.',
                                            title: 'Invalid Dimensions',
                                          ),
                                    );
                                    return;
                                  }
                                }

                                showDialog(
                                  context: safeContext,
                                  builder: (confirmDialog) {
                                    return ConfirmationAlert(
                                      theme: theme,
                                      message:
                                          quantityController.text.isEmpty &&
                                                  !isAddToQuantity
                                              ? 'You are about to empty your entire product stock, are you sure?'
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
                                            return (widget.product
                                                        .getActualQuantity() ??
                                                    0) +
                                                quantityInArea(
                                                  enteredQuantity ?? 0,
                                                );
                                          } else {
                                            return quantityInArea(
                                              enteredQuantity ?? 0,
                                            );
                                          }
                                        }

                                        bool isIncrement =
                                            setQuantity() >=
                                            (widget.product
                                                    .getActualQuantity() ??
                                                0);
                                        ItemHistory itemHistory = ItemHistory(
                                          primaryUnit:
                                              widget.product
                                                  .getProductUnit()
                                                  .name,
                                          unit:
                                              widget.product
                                                  .getProductUnit(
                                                    unitUuid: unitUuid,
                                                  )
                                                  .name,
                                          shopId: shopId(),
                                          title:
                                              'Item Quantity ${isIncrement ? "Increased" : 'Reduced'}',
                                          quantityChange: widget.product
                                              .getProductUnit(
                                                unitUuid: unitUuid,
                                              )
                                              .getQuantityEquivDivided(
                                                index: 1,
                                                newQuantity:
                                                    (setQuantity() -
                                                        (widget.product
                                                                .getActualQuantity() ??
                                                            0)),
                                                product: widget.product,
                                              ),
                                          event:
                                              isIncrement
                                                  ? ItemHistoryEventClass
                                                      .quantityUpdatedIncrease
                                                  : ItemHistoryEventClass
                                                      .quantityUpdatedDecrease,
                                          isManaged: widget.product.isManaged,
                                          source:
                                              isIncrement
                                                  ? ItemHistoryEventClass
                                                      .manualSource
                                                  : ItemHistoryEventClass
                                                      .productSource,
                                          destination:
                                              isIncrement
                                                  ? ItemHistoryEventClass
                                                      .productDestination
                                                  : ItemHistoryEventClass
                                                      .manualDestination,
                                          newValue: formatLargeNumberDouble(
                                            widget.product
                                                .getProductUnit()
                                                .getQuantityEquivDivided(
                                                  index: 1,
                                                  newQuantity: setQuantity(),
                                                  product: widget.product,
                                                ),
                                          ),
                                          desc:
                                              commentController.text.isNotEmpty
                                                  ? commentController.text
                                                  : 'This Item Quantity Was Updated.',
                                          isIncreased: isIncrement,
                                          oldValue: formatLargeNumberDouble(
                                            widget.product
                                                .getProductUnit()
                                                .getQuantityEquivDivided(
                                                  index: 1,
                                                  newQuantity:
                                                      (widget.product
                                                              .getActualQuantity() ??
                                                          0),
                                                  product: widget.product,
                                                ),
                                          ),
                                        );

                                        await dataProvider.updateProduct(
                                          itemHistory: itemHistory,
                                          includeQuantity: true,
                                          isIncrement: isIncrement,
                                          isQuantityUpdate: false,
                                          quantityChange:
                                              (setQuantity() -
                                                      (widget.product
                                                              .getActualQuantity() ??
                                                          0))
                                                  .abs(),
                                          product: TempProductClass(
                                            manageSalesWastage:
                                                widget
                                                    .product
                                                    .manageSalesWastage,
                                            heightDimension:
                                                widget.product.heightDimension,
                                            widthDimension:
                                                widget.product.widthDimension,
                                            quantityType:
                                                widget.product.quantityType,
                                            unitsList: widget.product.unitsList,
                                            pricesList:
                                                widget.product.pricesList,
                                            categories:
                                                widget.product.categories,
                                            useGroupUnit:
                                                widget.product.useGroupUnit,
                                            storageUuid:
                                                widget.product.storageUuid,
                                            departmentName:
                                                widget.product.departmentName,
                                            departmentUuid:
                                                widget.product.departmentUuid,
                                            groupUnit: widget.product.groupUnit,
                                            qttyPerGroup:
                                                widget.product.qttyPerGroup,
                                            updatedAt: DateTime.now(),
                                            setCustomPrice:
                                                widget.product.setCustomPrice,
                                            totalQttyInStorageDouble:
                                                widget
                                                    .product
                                                    .totalQttyInStorageDouble,
                                            isManaged: widget.product.isManaged,
                                            name: widget.product.name,
                                            unit: widget.product.unit,
                                            isRefundable:
                                                widget.product.isRefundable,
                                            costPrice: widget.product.costPrice,
                                            sellingPrice:
                                                widget.product.sellingPrice,
                                            wholeSalePrice:
                                                widget.product.wholeSalePrice,
                                            quantity:
                                                widget.product.quantityType == 2
                                                    ? setQuantity() /
                                                        widget.product
                                                            .dimensionArea()
                                                    : setQuantity(),
                                            shopId: widget.product.shopId,
                                            barcode: widget.product.barcode,
                                            createdAt: widget.product.createdAt,
                                            discount: widget.product.discount,
                                            endDate: widget.product.endDate,
                                            expiryDate:
                                                widget.product.expiryDate,
                                            lowQtty: widget.product.lowQtty,
                                            sizeType: widget.product.sizeType,
                                            startDate: widget.product.startDate,
                                            uuid: widget.product.uuid,
                                          ),
                                          oldProduct: widget.product,
                                        );

                                        if (safeContext.mounted) {
                                          Navigator.of(safeContext).pop();
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
      ),
    );
  }
}
