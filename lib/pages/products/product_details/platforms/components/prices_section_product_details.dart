import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/components/text_fields/money_textfield.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/products/product_details/platforms/components/edit_button.dart';
import 'package:stockall/pages/products/product_details/platforms/components/tab_container.dart';

class PricesSectionProductDetails extends StatefulWidget {
  final TempProductClass product;
  const PricesSectionProductDetails({
    super.key,
    required this.product,
  });

  @override
  State<PricesSectionProductDetails> createState() =>
      _PricesSectionProductDetailsState();
}

class _PricesSectionProductDetailsState
    extends State<PricesSectionProductDetails> {
  final sellingController = TextEditingController();
  final wholeSaleController = TextEditingController();
  final costController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context, listen: false);
    return Column(
      spacing: 10,
      children: [
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Visibility(
                  visible: authorization(
                    authorized:
                        Authorizations().manageCostPrice,
                  ),
                  child: Expanded(
                    child: TabContainer(
                      isMoney: true,
                      text: 'Cost Price',
                      price: widget.product.costPrice,
                      theme: theme,
                      backGround: const Color.fromARGB(
                        11,
                        15,
                        4,
                        114,
                      ),
                      border: const Color.fromARGB(
                        32,
                        45,
                        3,
                        255,
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: authorization(
                    authorized:
                        Authorizations().manageCostPrice,
                  ),
                  child: SizedBox(width: 10),
                ),
                Expanded(
                  child: TabContainer(
                    isMoney: true,
                    text: 'Selling Price',
                    price: widget.product.sellingPrice ?? 0,
                    theme: theme,
                    backGround: const Color.fromARGB(
                      25,
                      235,
                      150,
                      3,
                    ),
                    border: const Color.fromARGB(
                      74,
                      232,
                      148,
                      3,
                    ),
                  ),
                ),
                Visibility(
                  visible:
                      shop(context)?.wholeSale == true &&
                      screenWidth(context) > mobileScreen,
                  child: Expanded(
                    child: Row(
                      children: [
                        SizedBox(width: 10),
                        Expanded(
                          child: TabContainer(
                            isMoney: true,
                            text: 'Whole Sale Price',
                            price:
                                widget
                                    .product
                                    .wholeSalePrice ??
                                0,
                            theme: theme,
                            backGround:
                                const Color.fromARGB(
                                  24,
                                  135,
                                  235,
                                  3,
                                ),
                            border: const Color.fromARGB(
                              73,
                              106,
                              232,
                              3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Visibility(
              visible:
                  shop(context)?.wholeSale == true &&
                  screenWidth(context) <= mobileScreen,
              child: SizedBox(height: 10),
            ),
            Visibility(
              visible:
                  shop(context)?.wholeSale == true &&
                  screenWidth(context) <= mobileScreen,
              child: Row(
                children: [
                  Expanded(
                    child: TabContainer(
                      isMoney: true,
                      text: 'Whole Sale Price',
                      price:
                          widget.product.wholeSalePrice ??
                          0,
                      theme: theme,
                      backGround: const Color.fromARGB(
                        24,
                        135,
                        235,
                        3,
                      ),
                      border: const Color.fromARGB(
                        73,
                        106,
                        232,
                        3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Visibility(
          visible: authorization(
            authorized: Authorizations().updateProduct,
          ),
          child: EditButton(
            theme: theme,
            action: () {
              setState(() {
                sellingController.text =
                    widget.product.sellingPrice != null
                        ? widget.product.sellingPrice
                            .toString()
                        : '';

                wholeSaleController.text =
                    widget.product.wholeSalePrice != null
                        ? widget.product.wholeSalePrice
                            .toString()
                        : '';

                costController.text =
                    widget.product.costPrice
                        .toString()
                        .toString();
              });
              bool isEditPriceLoading = false;
              showGeneralDialog(
                context: context,
                pageBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                ) {
                  return StatefulBuilder(
                    builder:
                        (context, setState) => Material(
                          color: Colors.transparent,
                          child: GestureDetector(
                            onTap:
                                () =>
                                    FocusManager
                                        .instance
                                        .primaryFocus
                                        ?.unfocus(),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(
                                      left: 30.0,
                                      top: 40,
                                      right: 30,
                                    ),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment
                                          .center,
                                  children: [
                                    Container(
                                      padding:
                                          EdgeInsets.all(
                                            40,
                                          ),
                                      margin:
                                          EdgeInsets.only(
                                            bottom: 100,
                                          ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(
                                              15,
                                            ),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                const Color.fromARGB(
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
                                                  onPressed:
                                                      () {},
                                                  icon: Icon(
                                                    Icons
                                                        .clear,
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
                                                      FontWeight
                                                          .bold,
                                                ),
                                                'Edit Prices',
                                              ),
                                              Builder(
                                                builder: (
                                                  context,
                                                ) {
                                                  if (isEditPriceLoading ==
                                                      true) {
                                                    return SizedBox(
                                                      height:
                                                          20,
                                                      width:
                                                          20,
                                                      child: CircularProgressIndicator(
                                                        strokeWidth:
                                                            1.5,
                                                        color:
                                                            theme.lightModeColor.secColor200,
                                                      ),
                                                    );
                                                  } else {
                                                    return IconButton(
                                                      mouseCursor:
                                                          SystemMouseCursors.click,
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
                                          SizedBox(
                                            height: 15,
                                          ),
                                          Column(
                                            children: [
                                              Visibility(
                                                visible: authorization(
                                                  authorized:
                                                      Authorizations()
                                                          .manageCostPrice,
                                                ),
                                                child: MoneyTextfield(
                                                  title:
                                                      'Cost Price',
                                                  hint:
                                                      'Enter Cost Price',
                                                  controller:
                                                      costController,
                                                  theme:
                                                      theme,
                                                ),
                                              ),
                                              Visibility(
                                                visible: authorization(
                                                  authorized:
                                                      Authorizations()
                                                          .manageCostPrice,
                                                ),
                                                child:
                                                    SizedBox(
                                                      height:
                                                          10,
                                                    ),
                                              ),
                                              MoneyTextfield(
                                                title:
                                                    'Selling Price',
                                                hint:
                                                    'Enter Selling Price',
                                                controller:
                                                    sellingController,
                                                theme:
                                                    theme,
                                              ),
                                              Visibility(
                                                visible:
                                                    returnShopProvider()
                                                        .userShop()
                                                        ?.wholeSale ==
                                                    true,
                                                child:
                                                    SizedBox(
                                                      height:
                                                          10,
                                                    ),
                                              ),
                                              Visibility(
                                                visible:
                                                    returnShopProvider()
                                                        .userShop()
                                                        ?.wholeSale ==
                                                    true,
                                                child: MoneyTextfield(
                                                  title:
                                                      'Whole Sale Price',
                                                  hint:
                                                      'Enter Whole Sale Price',
                                                  controller:
                                                      wholeSaleController,
                                                  theme:
                                                      theme,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          MainButtonP(
                                            themeProvider:
                                                theme,
                                            action: () {
                                              final safeContext =
                                                  context;
                                              if (isEditPriceLoading ==
                                                  false) {
                                                showDialog(
                                                  context:
                                                      safeContext,
                                                  builder: (
                                                    confirmDialog,
                                                  ) {
                                                    return ConfirmationAlert(
                                                      theme:
                                                          theme,
                                                      message:
                                                          'Are you sure you want to proceed?',
                                                      title:
                                                          'Proceed?',
                                                      action: () async {
                                                        final dataProvider =
                                                            returnData();
                                                        Navigator.of(
                                                          confirmDialog,
                                                        ).pop();
                                                        setState(() {
                                                          isEditPriceLoading =
                                                              true;
                                                        });
                                                        await dataProvider.updateProduct(
                                                          itemHistory:
                                                              null,
                                                          includeQuantity:
                                                              false,
                                                          isIncrement:
                                                              null,
                                                          isQuantityUpdate:
                                                              false,
                                                          quantityChange:
                                                              null,
                                                          product: TempProductClass(
                                                            unitsList:
                                                                widget.product.unitsList,
                                                            useGroupUnit:
                                                                widget.product.useGroupUnit,
                                                            categories:
                                                                widget.product.categories,
                                                            storageUuid:
                                                                widget.product.storageUuid,
                                                            departmentName:
                                                                widget.product.departmentName,
                                                            departmentUuid:
                                                                widget.product.departmentUuid,
                                                            groupUnit:
                                                                widget.product.groupUnit,
                                                            qttyPerGroup:
                                                                widget.product.qttyPerGroup,
                                                            updatedAt:
                                                                DateTime.now(),
                                                            totalQttyInStorageDouble:
                                                                widget.product.totalQttyInStorageDouble,
                                                            setCustomPrice:
                                                                widget.product.setCustomPrice,
                                                            isManaged:
                                                                widget.product.isManaged,
                                                            // id:
                                                            //     widget.product.id,
                                                            name:
                                                                widget.product.name,
                                                            unit:
                                                                widget.product.unit,
                                                            isRefundable:
                                                                widget.product.isRefundable,
                                                            costPrice:
                                                                double.tryParse(
                                                                  costController.text.replaceAll(
                                                                    ',',
                                                                    '',
                                                                  ),
                                                                ) ??
                                                                0,
                                                            sellingPrice:
                                                                sellingController.text.isNotEmpty
                                                                    ? double.tryParse(
                                                                      sellingController.text.replaceAll(
                                                                        ',',
                                                                        '',
                                                                      ),
                                                                    )
                                                                    : null,
                                                            wholeSalePrice:
                                                                wholeSaleController.text.isNotEmpty
                                                                    ? double.tryParse(
                                                                      wholeSaleController.text.replaceAll(
                                                                        ',',
                                                                        '',
                                                                      ),
                                                                    )
                                                                    : null,
                                                            quantity:
                                                                widget.product.quantity,
                                                            shopId:
                                                                widget.product.shopId,
                                                            barcode:
                                                                widget.product.barcode,
                                                            // categoryUuid:
                                                            //     widget.product.categoryUuid,
                                                            createdAt:
                                                                widget.product.createdAt,
                                                            discount:
                                                                widget.product.discount,
                                                            endDate:
                                                                widget.product.endDate,
                                                            expiryDate:
                                                                widget.product.expiryDate,
                                                            lowQtty:
                                                                widget.product.lowQtty,
                                                            sizeType:
                                                                widget.product.sizeType,
                                                            startDate:
                                                                widget.product.startDate,
                                                            uuid:
                                                                widget.product.uuid,
                                                          ),
                                                          oldProduct:
                                                              widget.product,
                                                        );

                                                        // if (safeContext.mounted) {
                                                        //   await dataProvider.getProducts(
                                                        //     shopI,
                                                        //   );
                                                        // }

                                                        // setState(
                                                        //   () {
                                                        //     isLoading =
                                                        //         false;
                                                        //     showSuccess =
                                                        //         true;
                                                        //   },
                                                        // );

                                                        if (safeContext.mounted) {
                                                          Navigator.of(
                                                            safeContext,
                                                          ).pop();
                                                          setState(
                                                            () {
                                                              // productFuture =
                                                              //     getProduct();
                                                            },
                                                          );
                                                        }

                                                        // setState(
                                                        //   () {
                                                        //     showSuccess =
                                                        //         false;
                                                        //   },
                                                        // );
                                                      },
                                                    );
                                                  },
                                                );
                                              }
                                            },
                                            text:
                                                'Update Prices',
                                          ),
                                          SizedBox(
                                            height: 15,
                                          ),
                                          Material(
                                            color:
                                                Colors
                                                    .transparent,
                                            child: EditButton(
                                              text:
                                                  'Cancel',
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
            },
            text: 'Edit Prices',
          ),
        ),
      ],
    );
  }
}
