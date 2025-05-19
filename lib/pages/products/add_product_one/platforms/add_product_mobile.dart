import 'package:flutter/material.dart';
import 'package:stockitt/classes/temp_product_class.dart';
import 'package:stockitt/classes/temp_shop_class.dart';
import 'package:stockitt/components/alert_dialogues/info_alert.dart';
import 'package:stockitt/components/buttons/main_button_p.dart';
import 'package:stockitt/components/calendar/calendar_widget.dart';
import 'package:stockitt/components/text_fields/barcode_scanner.dart';
import 'package:stockitt/components/text_fields/edit_cart_text_field.dart';
import 'package:stockitt/components/text_fields/general_textfield.dart';
import 'package:stockitt/components/text_fields/main_dropdown.dart';
import 'package:stockitt/components/text_fields/money_textfield.dart';
import 'package:stockitt/components/text_fields/number_textfield.dart';
import 'package:stockitt/constants/bottom_sheet_widgets.dart';
import 'package:stockitt/constants/calculations.dart';
import 'package:stockitt/constants/scan_barcode.dart';
import 'package:stockitt/main.dart';

class AddProductMobile extends StatefulWidget {
  final TextEditingController costController;
  final TextEditingController sellingController;
  final TextEditingController categoryController;
  final TextEditingController nameController;
  final TextEditingController sizeController;
  final TextEditingController quantityController;
  final TextEditingController discountController;
  final TextEditingController brandController;

  const AddProductMobile({
    super.key,
    required this.costController,
    required this.sellingController,
    required this.categoryController,
    required this.nameController,
    required this.brandController,
    required this.sizeController,
    required this.quantityController,
    required this.discountController,
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
      setState(() {
        isLoading = true;
      });
      await returnData(
        context,
        listen: false,
      ).createProduct(
        TempProductClass(
          name: widget.nameController.text.trim(),
          unit:
              returnData(
                context,
                listen: false,
              ).selectedUnit!,
          isRefundable:
              returnData(
                context,
                listen: false,
              ).isProductRefundable,
          costPrice: double.parse(
            widget.costController.text.replaceAll(',', ''),
          ),
          shopId: userShop!.shopId!,

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
          barcode: barcode,
          size: widget.sizeController.text.replaceAll(
            ',',
            '',
          ),
          discount: double.tryParse(
            widget.discountController.text,
          ),
          endDate:
              returnData(context, listen: false).endDate,
          startDate:
              returnData(
                context,
                listen: false,
              ).startDate ??
              DateTime.now(),
        ),
      );
      setState(() {
        isLoading = false;
        showSuccess = true;
      });
      if (context.mounted) {
        // ignore: use_build_context_synchronously
        returnData(context, listen: false).clearEndDate();
        // ignore: use_build_context_synchronously
        returnData(context, listen: false).clearStartDate();
      }
      Future.delayed(Duration(seconds: 3), () {
        if (!context.mounted) return;
        // ignore: use_build_context_synchronously
        Navigator.of(context).pop();
      });
    }
  }

  //
  @override
  void initState() {
    super.initState();
    // widget.costController.text = '0';
    // widget.sellingController.text = '0';
    // widget.discountController.text = '0';
    setShop();
  }

  TempShopClass? userShop;
  void setShop() async {
    var shop = await returnShopProvider(
      context,
      listen: false,
    ).getUserShop(userIdMain());

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
    final discountedPrice =
        cost - (cost * (discount / 100));
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
                  'New Product',
                ),
                SizedBox(height: 5),
                Text(
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b2.fontSize,
                  ),
                  'Add New Product to you Store',
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
                                          'Enter the actual Amount of the Item',
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
                                          'Enter the Amount you wish to sell this Product',
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
                                onChanged: (value) {
                                  setState(() {
                                    discount =
                                        double.tryParse(
                                          value,
                                        ) ??
                                        0;
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
                                              'Cost-price:',
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
                                              formatLargeNumberDouble(
                                                costDiscount,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Divider(),
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
                                              formatLargeNumberDouble(
                                                sellingDiscount,
                                              ),
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
                          checkFields();
                        },
                        text: 'Create Product',
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
                      32,
                      0,
                      0,
                      0,
                    ),
                    height:
                        MediaQuery.of(context).size.height,
                    width:
                        MediaQuery.of(context).size.width,
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 20,
                          horizontal: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromARGB(
                                30,
                                0,
                                0,
                                0,
                              ),
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        height:
                            MediaQuery.of(
                              context,
                            ).size.height -
                            300,
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
          ).showLoader('Creating Product'),
        ),
        Visibility(
          visible: showSuccess,
          child: returnCompProvider(
            context,
            listen: false,
          ).showSuccess('Product Created Successfully'),
        ),
      ],
    );
  }
}
