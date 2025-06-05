import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_product_class.dart';
import 'package:stockall/classes/temp_shop_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/components/buttons/main_button_transparent.dart';
import 'package:stockall/components/calendar/calendar_widget.dart';
import 'package:stockall/components/text_fields/barcode_scanner.dart';
import 'package:stockall/components/text_fields/edit_cart_text_field.dart';
import 'package:stockall/components/text_fields/general_textfield.dart';
import 'package:stockall/components/text_fields/main_dropdown.dart';
import 'package:stockall/components/text_fields/money_textfield.dart';
import 'package:stockall/components/text_fields/number_textfield.dart';
import 'package:stockall/constants/bottom_sheet_widgets.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/scan_barcode.dart';
import 'package:stockall/main.dart';
import 'package:stockall/services/auth_service.dart';

class AddProductMobile extends StatefulWidget {
  final TempProductClass? product;
  final TextEditingController costController;
  final TextEditingController sellingController;
  final TextEditingController nameController;
  final TextEditingController sizeController;
  final TextEditingController quantityController;
  final TextEditingController discountController;

  const AddProductMobile({
    super.key,
    required this.costController,
    required this.sellingController,
    required this.nameController,
    required this.sizeController,
    required this.quantityController,
    required this.discountController,
    this.product,
  });

  @override
  State<AddProductMobile> createState() =>
      _AddProductMobileState();
}

class _AddProductMobileState
    extends State<AddProductMobile> {
  bool barCodeSet = false;
  bool isLoading = false;
  bool showSuccess = false;

  String? barcode;
  //
  //
  //
  //

  bool isOpenUnit = false;
  bool isSizedTypeOpen = false;
  //
  //
  //
  bool isOpen = false;

  bool setDate = false;

  void checkFields() async {
    if (widget.nameController.text.isEmpty ||
        widget.costController.text.isEmpty ||
        widget.sellingController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          var theme = returnTheme(context);
          return InfoAlert(
            theme: theme,
            message:
                'Product Name, Cost Price and Selling Price Must be set',
            title: 'Empty Input',
          );
        },
      );
    } else if (widget.quantityController.text.isEmpty ||
        returnData(context, listen: false).selectedUnit ==
            null) {
      showDialog(
        context: context,
        builder: (context) {
          var theme = returnTheme(context);
          return InfoAlert(
            theme: theme,
            message:
                'Product Quantity and Unit Must be set',
            title: 'Empty Input',
          );
        },
      );
    } else if (widget.discountController.text.isNotEmpty &&
        returnData(context, listen: false).endDate ==
            null) {
      showDialog(
        context: context,
        builder: (context) {
          var theme = returnTheme(context);
          return InfoAlert(
            theme: theme,
            message:
                'If you want to set a discount for this product, you must set end date for that discount.',
            title: 'Set End Date for Discount',
          );
        },
      );
    } else {
      final safeContext = context; // screen-level context

      showDialog(
        context: safeContext,
        builder: (context) {
          return ConfirmationAlert(
            theme: returnTheme(safeContext),
            message:
                'You are about to add a new product to your stock, are you sure you want to proceed?',
            title: 'Are you sure?',
            action: () async {
              if (safeContext.mounted) {
                Navigator.of(
                  safeContext,
                ).pop(); // close dialog
              }

              setState(() {
                isLoading = true;
              });

              final dataProvider = returnData(
                safeContext,
                listen: false,
              );

              await dataProvider.createProduct(
                TempProductClass(
                  name: widget.nameController.text.trim(),
                  unit: dataProvider.selectedUnit!,
                  sizeType: dataProvider.selectedSize,
                  isRefundable:
                      dataProvider.isProductRefundable,
                  costPrice: double.parse(
                    widget.costController.text.replaceAll(
                      ',',
                      '',
                    ),
                  ),
                  shopId: userShop!.shopId!,
                  sellingPrice: double.parse(
                    widget.sellingController.text
                        .replaceAll(',', ''),
                  ),
                  quantity: double.parse(
                    widget.quantityController.text
                        .replaceAll(',', ''),
                  ),
                  barcode: barcode,
                  size: widget.sizeController.text
                      .replaceAll(',', ''),
                  discount: double.tryParse(
                    widget.discountController.text,
                  ),
                  startDate:
                      dataProvider.startDate ??
                      DateTime.now(),
                  endDate: dataProvider.endDate,
                  category: dataProvider.selectedCategory,
                ),
              );

              setState(() {
                isLoading = false;
                showSuccess = true;
              });

              // Clear data before popping
              if (safeContext.mounted) {
                dataProvider.clearFields();
              }

              Future.delayed(Duration(seconds: 2), () {
                // Pop current screen
                if (safeContext.mounted) {
                  Navigator.of(
                    safeContext,
                  ).pop(); // pop current page
                }
              });
            },
          );
        },
      );
    }
  }

  void updateProduct() {
    final safeContext = context;
    showDialog(
      context: safeContext,
      builder: (context) {
        var theme = returnTheme(context);
        return ConfirmationAlert(
          theme: theme,
          message:
              'Are you sure you want to proceed with update?',
          title: 'Proceed?',
          action: () async {
            // ✅ GET THE PROVIDER INSTANCE EARLY
            final provider = returnData(
              context,
              listen: false,
            );

            if (safeContext.mounted) {
              Navigator.of(safeContext).pop();
            }

            setState(() {
              isLoading = true;
            });

            await provider.updateProduct(
              product: TempProductClass(
                id: widget.product!.id,
                name: widget.nameController.text,
                unit: provider.selectedUnit!,
                isRefundable: provider.isProductRefundable,
                costPrice: double.parse(
                  widget.costController.text.replaceAll(
                    ',',
                    '',
                  ),
                ),
                sellingPrice: double.parse(
                  widget.sellingController.text.replaceAll(
                    ',',
                    '',
                  ),
                ),
                quantity: double.parse(
                  widget.quantityController.text.replaceAll(
                    ',',
                    '',
                  ),
                ),
                shopId: userShop!.shopId!,
                barcode: barcode,
                category: provider.selectedCategory,
                createdAt: widget.product!.createdAt,
                discount: double.tryParse(
                  widget.discountController.text.replaceAll(
                    ',',
                    '',
                  ),
                ),
                endDate: provider.endDate,
                size: widget.sizeController.text,
                sizeType: provider.selectedSize,
                startDate: provider.startDate,
              ),
            );

            setState(() {
              isLoading = false;
              showSuccess = true;
            });

            if (safeContext.mounted) {
              provider.clearFields();
            }

            Future.delayed(Duration(seconds: 2), () {
              if (safeContext.mounted) {
                Navigator.of(safeContext).pop();
              }
            });
          },
        );
      },
    );
  }

  //
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((context) {
      clearFields();
    });

    setShop();
  }

  Future<void> clearFields() async {
    await Future.delayed(Duration(microseconds: 500), () {
      if (context.mounted) {
        returnData(context, listen: false).clearFields();
      }
    });
    if (widget.product != null && context.mounted) {
      barcode = widget.product!.barcode;
      barCodeSet =
          widget.product!.barcode != null ? true : false;
      widget.nameController.text = widget.product!.name;
      widget.costController.text = widget.product!.costPrice
          .toString()
          .substring(
            0,
            widget.product!.costPrice.toString().length - 1,
          );
      widget.sellingController.text = widget
          .product!
          .sellingPrice
          .toString()
          .substring(
            0,
            widget.product!.sellingPrice.toString().length -
                1,
          );
      widget.quantityController.text =
          widget.product!.quantity.toString();

      widget.sizeController.text =
          widget.product!.size.toString();
      widget.discountController.text =
          widget.product!.discount != null
              ? widget.product!.discount.toString()
              : '';
      returnData(
            context,
            listen: false,
          ).isProductRefundable =
          widget.product!.isRefundable;
      // returnData(context, listen: false).selectedUnit =
      //     widget.product!.unit;
      returnData(
        context,
        listen: false,
      ).selectUnit(widget.product!.unit);
      // returnData(context, listen: false).selectedSize =
      //     widget.product!.sizeType ?? '';
      widget.product!.sizeType != null
          ? returnData(
            context,
            listen: false,
          ).selectSize(widget.product!.sizeType!)
          : null;
      widget.product!.category != null
          ? returnData(
            context,
            listen: false,
          ).selectCategory(widget.product!.category!)
          : null;
      returnData(context, listen: false).setBothDates(
        widget.product!.startDate,
        widget.product!.endDate,
      );
      setState(() {
        costDiscount =
            widget.product!.discount != null
                ? widget.product!.sellingPrice *
                    (widget.product!.discount! / 100)
                : costDiscount;
        sellingDiscount =
            widget.product!.discount != null
                ? widget.product!.sellingPrice -
                    (widget.product!.sellingPrice *
                        (widget.product!.discount! / 100))
                : costDiscount;
        selling = double.parse(
          widget.sellingController.text.replaceAll(',', ''),
        );
      });
    }
  }

  TempShopClass? userShop;
  void setShop() async {
    var shop = await returnShopProvider(
      context,
      listen: false,
    ).getUserShop(AuthService().currentUser!.id);

    setState(() {
      userShop = shop;
    });
  }

  double cost = 0;
  double selling = 0;
  double discount = 0;

  double costDiscount = 0;

  double sellingDiscount = 0;

  void checkDiscount() {
    final discountedPrice = selling * (discount / 100);
    final discountedSellingPrice =
        selling - (selling * (discount / 100));
    setState(() {
      costDiscount = discountedPrice;
      sellingDiscount = discountedSellingPrice;
    });
  }

  //
  //
  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Padding(
                padding: const EdgeInsets.only(
                  left: 20.0,
                  right: 10,
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                ),
              ),
            ),
            centerTitle: true,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  style: TextStyle(
                    fontSize: theme.mobileTexts.h4.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                  widget.product != null
                      ? 'Edit Product'
                      : 'New Product',
                ),
                SizedBox(height: 5),
                Text(
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b2.fontSize,
                  ),
                  widget.product != null
                      ? 'Edit product details'
                      : 'Add a new product to your store.',
                ),
              ],
            ),
          ),
          body: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30.0,
                      ),
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            top: 10.0,
                          ),
                          child: Column(
                            children: [
                              GeneralTextField(
                                theme: theme,
                                hint: 'Enter Product Name',
                                lines: 1,
                                title: 'Product Name',
                                controller:
                                    widget.nameController,
                              ),
                              SizedBox(height: 10),
                              BarcodeScanner(
                                valueSet: barCodeSet,
                                onTap: () async {
                                  String info =
                                      await scanCode(
                                        context,
                                        'Not Saved',
                                      );

                                  setState(() {
                                    barcode = info;
                                    barCodeSet = true;
                                  });
                                },
                                title:
                                    'Product Barcode (Optional)',
                                hint:
                                    barcode ??
                                    'Click to Scan Product Barcode',
                                theme: theme,
                              ),
                              SizedBox(height: 10),
                              Row(
                                spacing: 15,
                                children: [
                                  Expanded(
                                    child: MoneyTextfield(
                                      onChanged: (value) {
                                        if (value.isEmpty) {
                                          cost = 0;
                                        } else {
                                          setState(() {
                                            cost = double.parse(
                                              widget
                                                  .costController
                                                  .text
                                                  .replaceAll(
                                                    ',',
                                                    '',
                                                  ),
                                            );
                                          });
                                        }
                                      },
                                      theme: theme,
                                      hint:
                                          'Enter Real Cost',
                                      title: 'Cost - Price',
                                      controller:
                                          widget
                                              .costController,
                                    ),
                                  ),
                                  Expanded(
                                    child: MoneyTextfield(
                                      onChanged: (value) {
                                        if (value.isEmpty) {
                                          selling = 0;
                                        } else {
                                          setState(() {
                                            selling = double.parse(
                                              widget
                                                  .sellingController
                                                  .text
                                                  .replaceAll(
                                                    ',',
                                                    '',
                                                  ),
                                            );
                                          });
                                        }
                                      },
                                      theme: theme,
                                      hint:
                                          'Enter Sale Price',
                                      title:
                                          'Selling - Price',
                                      controller:
                                          widget
                                              .sellingController,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              MainDropdown(
                                valueSet:
                                    returnData(
                                      context,
                                    ).unitValueSet,
                                onTap: () {
                                  unitsBottomSheet(
                                    context,
                                    () {
                                      setState(() {
                                        isOpenUnit =
                                            !isOpenUnit;
                                      });
                                    },
                                  );
                                  setState(() {
                                    isOpenUnit =
                                        !isOpenUnit;
                                  });
                                },
                                isOpen: isOpenUnit,
                                title: 'Unit',
                                hint:
                                    returnData(
                                      context,
                                    ).selectedUnit ??
                                    'Select Product Unit',
                                theme: theme,
                              ),
                              SizedBox(height: 10),
                              MainDropdown(
                                valueSet:
                                    returnData(
                                      context,
                                    ).sizeValueSet,
                                onTap: () {
                                  sizeTypeBottomSheet(
                                    context,
                                    () {
                                      setState(() {
                                        isSizedTypeOpen =
                                            !isSizedTypeOpen;
                                      });
                                    },
                                  );
                                  setState(() {
                                    isSizedTypeOpen =
                                        !isSizedTypeOpen;
                                  });
                                },
                                isOpen: isSizedTypeOpen,
                                title:
                                    'Size Type (Optional)',
                                hint:
                                    returnData(
                                      context,
                                    ).selectedSize ??
                                    'Select Product Size Type',
                                theme: theme,
                              ),

                              SizedBox(height: 10),
                              MainDropdown(
                                valueSet:
                                    returnData(
                                      context,
                                    ).catValueSet,
                                onTap: () {
                                  categoriesBottomSheet(
                                    context,
                                    () {
                                      setState(() {
                                        isOpen = false;
                                      });
                                    },
                                  );
                                  setState(() {
                                    isOpen = !isOpen;
                                  });
                                },
                                isOpen: isOpen,
                                title:
                                    'Category (Optional)',
                                hint:
                                    returnData(
                                      context,
                                    ).selectedCategory ??
                                    'Select Product Category',
                                theme: theme,
                              ),
                              SizedBox(height: 10),
                              Row(
                                spacing: 15,
                                children: [
                                  Expanded(
                                    child: NumberTextfield(
                                      theme: theme,
                                      hint:
                                          'Enter Quantity',
                                      title: 'Quantity',
                                      controller:
                                          widget
                                              .quantityController,
                                    ),
                                  ),

                                  Expanded(
                                    child: NumberTextfield(
                                      theme: theme,
                                      hint:
                                          'Enter Product Size',
                                      title:
                                          'Size  (Optional)',
                                      controller:
                                          widget
                                              .sizeController,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              EditCartTextField(
                                discount: true,
                                onChanged: (value) {
                                  setState(() {
                                    if (value
                                            .toString()
                                            .length >
                                        2) {
                                      discount = 100;
                                    } else {
                                      discount =
                                          double.tryParse(
                                            value,
                                          ) ??
                                          0;
                                    }
                                  });
                                  checkDiscount();

                                  if (value.isEmpty) {
                                    returnData(
                                      context,
                                      listen: false,
                                    ).clearEndDate();
                                    returnData(
                                      context,
                                      listen: false,
                                    ).clearStartDate();
                                    widget
                                        .discountController
                                        .text = '';
                                  } else if (int.parse(
                                        widget
                                            .discountController
                                            .text,
                                      ) >
                                      99) {
                                    widget
                                        .discountController
                                        .text = '100';
                                    value = '100';
                                  }
                                },
                                theme: theme,
                                hint: 'Set Discount %',
                                title:
                                    'Discount (Optional)',
                                controller:
                                    widget
                                        .discountController,
                              ),
                              Visibility(
                                visible:
                                    widget
                                        .discountController
                                        .text
                                        .isNotEmpty,
                                child: Column(
                                  children: [
                                    SizedBox(height: 5),
                                    Row(
                                      spacing: 15,
                                      mainAxisAlignment:
                                          MainAxisAlignment
                                              .center,
                                      children: [
                                        Row(
                                          spacing: 5,
                                          children: [
                                            Text(
                                              style: TextStyle(
                                                color:
                                                    Colors
                                                        .grey,
                                                fontSize:
                                                    theme
                                                        .mobileTexts
                                                        .b3
                                                        .fontSize,
                                                fontWeight:
                                                    FontWeight
                                                        .bold,
                                              ),
                                              'Selling-price',
                                            ),
                                            Text(
                                              style: TextStyle(
                                                color:
                                                    theme
                                                        .lightModeColor
                                                        .secColor200,
                                                fontSize:
                                                    theme
                                                        .mobileTexts
                                                        .b2
                                                        .fontSize,
                                                fontWeight:
                                                    FontWeight
                                                        .bold,
                                              ),
                                              '$nairaSymbol${formatLargeNumberDouble(sellingDiscount)}',
                                            ),
                                          ],
                                        ),
                                        Row(
                                          spacing: 5,
                                          children: [
                                            Text(
                                              style: TextStyle(
                                                color:
                                                    Colors
                                                        .grey,
                                                fontSize:
                                                    theme
                                                        .mobileTexts
                                                        .b3
                                                        .fontSize,
                                                fontWeight:
                                                    FontWeight
                                                        .bold,
                                              ),
                                              'Discount:',
                                            ),
                                            Text(
                                              style: TextStyle(
                                                color:
                                                    theme
                                                        .lightModeColor
                                                        .secColor200,
                                                fontSize:
                                                    theme
                                                        .mobileTexts
                                                        .b2
                                                        .fontSize,
                                                fontWeight:
                                                    FontWeight
                                                        .bold,
                                              ),
                                              '$nairaSymbol${formatLargeNumberDouble(costDiscount)}',
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 15),
                              Visibility(
                                visible:
                                    widget
                                        .discountController
                                        .text
                                        .isNotEmpty,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment
                                          .center,
                                  spacing: 10,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          setDate = true;
                                        });
                                        returnData(
                                          context,
                                          listen: false,
                                        ).changeDateBoolToTrue();
                                        FocusManager
                                            .instance
                                            .primaryFocus
                                            ?.unfocus();
                                      },
                                      child: Container(
                                        padding:
                                            EdgeInsets.symmetric(
                                              horizontal:
                                                  10,
                                              vertical: 5,
                                            ),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color:
                                                Colors
                                                    .grey
                                                    .shade200,
                                          ),
                                        ),
                                        child: Row(
                                          spacing: 5,
                                          children: [
                                            Text(
                                              style: TextStyle(
                                                fontSize:
                                                    theme
                                                        .mobileTexts
                                                        .b2
                                                        .fontSize,
                                                fontWeight:
                                                    FontWeight
                                                        .bold,
                                              ),
                                              formatDateTime(
                                                returnData(
                                                      context,
                                                    ).startDate ??
                                                    DateTime.now(),
                                              ),
                                            ),
                                            Icon(
                                              size: 20,
                                              Icons
                                                  .calendar_month_outlined,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          setDate = true;
                                        });
                                        returnData(
                                          context,
                                          listen: false,
                                        ).clearEndDate();
                                        returnData(
                                          context,
                                          listen: false,
                                        ).changeDateBoolToFalse();
                                        FocusManager
                                            .instance
                                            .primaryFocus
                                            ?.unfocus();
                                      },
                                      child: Container(
                                        padding:
                                            EdgeInsets.symmetric(
                                              horizontal:
                                                  10,
                                              vertical: 5,
                                            ),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color:
                                                Colors
                                                    .grey
                                                    .shade200,
                                          ),
                                        ),
                                        child: Row(
                                          spacing: 5,
                                          children: [
                                            Text(
                                              style: TextStyle(
                                                fontSize:
                                                    theme
                                                        .mobileTexts
                                                        .b2
                                                        .fontSize,
                                                fontWeight:
                                                    FontWeight
                                                        .bold,
                                              ),
                                              returnData(
                                                        context,
                                                      ).endDate !=
                                                      null
                                                  ? formatDateTime(
                                                    returnData(
                                                          context,
                                                        ).endDate ??
                                                        DateTime.now(),
                                                  )
                                                  : 'Set End Date',
                                            ),
                                            Icon(
                                              size: 20,
                                              Icons
                                                  .calendar_month_outlined,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 20),
                              InkWell(
                                onTap: () {
                                  returnData(
                                    context,
                                    listen: false,
                                  ).toggleRefundable();
                                  FocusManager
                                      .instance
                                      .primaryFocus
                                      ?.unfocus();
                                },
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment
                                          .spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment
                                                .start,
                                        children: [
                                          Text(
                                            style: TextStyle(
                                              fontSize:
                                                  theme
                                                      .mobileTexts
                                                      .b1
                                                      .fontSize,
                                              fontWeight:
                                                  FontWeight
                                                      .bold,
                                            ),
                                            'Refundable?',
                                          ),
                                          Text(
                                            'Allow Customers return this product after Purchase?',
                                          ),
                                        ],
                                      ),
                                    ),
                                    Checkbox(
                                      activeColor:
                                          theme
                                              .lightModeColor
                                              .secColor100,
                                      value:
                                          returnData(
                                            context,
                                          ).isProductRefundable,
                                      onChanged: (value) {
                                        returnData(
                                          context,
                                          listen: false,
                                        ).toggleRefundable();
                                        FocusManager
                                            .instance
                                            .primaryFocus
                                            ?.unfocus();
                                      },
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
                  Container(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        bottom: 30.0,
                        top: 20,
                        left: 30,
                        right: 30,
                      ),
                      child: MainButtonP(
                        themeProvider: theme,
                        action: () {
                          widget.product != null
                              ? updateProduct()
                              : checkFields();
                        },
                        text:
                            widget.product != null
                                ? 'Update Product'
                                : 'Create Product',
                      ),
                    ),
                  ),
                ],
              ),
              Visibility(
                visible: setDate,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      setDate = false;
                    });
                  },
                  child: Container(
                    color: const Color.fromARGB(
                      100,
                      0,
                      0,
                      0,
                    ),
                    height:
                        MediaQuery.of(context).size.height,
                    width:
                        MediaQuery.of(context).size.width,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height:
                                MediaQuery.of(
                                  context,
                                ).size.height *
                                0.02,
                          ),
                          Center(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        const Color.fromARGB(
                                          30,
                                          0,
                                          0,
                                          0,
                                        ),
                                    blurRadius: 5,
                                  ),
                                ],
                              ),
                              height: 480,
                              width:
                                  (MediaQuery.of(
                                        context,
                                      ).size.width /
                                      10) *
                                  9.2,
                              child: CalendarWidget(
                                isMain: false,
                                onDaySelected: (
                                  selectedDay,
                                  focusedDay,
                                ) {
                                  returnData(
                                    context,
                                    listen: false,
                                  ).setDate(selectedDay);
                                  setState(() {
                                    setDate = false;
                                  });
                                },
                                actionWeek: (
                                  startOfWeek,
                                  endOfWeek,
                                ) {
                                  returnReceiptProvider(
                                    context,
                                    listen: false,
                                  ).setReceiptWeek(
                                    startOfWeek,
                                    endOfWeek,
                                  );
                                },
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 15,
                              left: 30,
                              right: 30,
                            ),
                            child: MainButtonTransparent(
                              constraints: BoxConstraints(),
                              themeProvider: theme,
                              action: () {
                                setState(() {
                                  setDate = false;
                                });
                              },
                              text: 'Cancel',
                            ),
                          ),
                          SizedBox(
                            height:
                                MediaQuery.of(
                                  context,
                                ).size.height *
                                0.4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        Visibility(
          visible: isLoading,
          child: returnCompProvider(
            context,
            listen: false,
          ).showLoader(
            widget.product != null
                ? 'Updating Product'
                : 'Creating Product',
          ),
        ),
        Visibility(
          visible: showSuccess,
          child: returnCompProvider(
            context,
            listen: false,
          ).showSuccess(
            widget.product != null
                ? 'Product Updated Successfully'
                : 'Product Created Successfully',
          ),
        ),
      ],
    );
  }
}
