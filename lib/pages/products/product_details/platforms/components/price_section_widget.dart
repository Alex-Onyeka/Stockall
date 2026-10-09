import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_product_class/prices_class/product_prices_class.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/components/text_fields/main_dropdown.dart';
import 'package:stockall/components/text_fields/money_textfield.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/products/add_product_one/product_prices_page/product_prices_page.dart';
import 'package:stockall/pages/products/product_details/platforms/components/edit_button.dart';

Widget priceSectionWidget(
  BuildContext context,
  TempProductClass product,
  int shopI,
) {
  var theme = returnTheme(context, listen: false);
  final costController = TextEditingController();
  return Container(
    padding: EdgeInsets.all(10),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: Colors.grey.shade300),
      color: const Color.fromARGB(255, 255, 255, 255),
    ),
    child: Column(
      spacing: 5,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              style: TextStyle(
                fontSize: theme.mobileTexts.b3.fontSize,
                fontWeight: FontWeight.bold,
              ),
              'Price Section'.toUpperCase(),
            ),
          ],
        ),
        PricesGridSectionWidget(product: product),
        Row(
          children: [
            Expanded(
              child: Material(
                child: EditButton(
                  theme: theme,
                  action: () {
                    costController.text =
                        product.costPrice
                            .toString()
                            .toString();
                    bool isEditPriceLoading = false;
                    returnData().initPricesList(
                      productUuid: product.uuid,
                      pricesListNew:
                          product.getPricesList(),
                    );
                    showGeneralDialog(
                      context: context,
                      pageBuilder: (
                        context,
                        animation,
                        secondaryAnimation,
                      ) {
                        return StatefulBuilder(
                          builder:
                              (
                                context,
                                setState,
                              ) => Material(
                                color: Colors.transparent,
                                child: GestureDetector(
                                  onTap:
                                      () =>
                                          FocusManager
                                              .instance
                                              .primaryFocus
                                              ?.unfocus(),
                                  child: Container(
                                    decoration:
                                        BoxDecoration(
                                          color:
                                              Colors.white,
                                        ),
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(
                                            left: 20.0,
                                            top: 40,
                                            right: 20,
                                          ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment
                                                .center,
                                        children: [
                                          Container(
                                            padding:
                                                EdgeInsets.all(
                                                  20,
                                                ),
                                            margin:
                                                EdgeInsets.only(
                                                  bottom:
                                                      100,
                                                ),
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors
                                                      .white,
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
                                                  blurRadius:
                                                      10,
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
                                                      opacity:
                                                          0,
                                                      child: IconButton(
                                                        mouseCursor:
                                                            SystemMouseCursors.click,
                                                        onPressed:
                                                            () {},
                                                        icon: Icon(
                                                          Icons.clear,
                                                        ),
                                                      ),
                                                    ),
                                                    Text(
                                                      style: TextStyle(
                                                        fontSize:
                                                            theme.mobileTexts.b1.fontSize,
                                                        fontWeight:
                                                            FontWeight.bold,
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
                                                  height:
                                                      15,
                                                ),
                                                Column(
                                                  children: [
                                                    Visibility(
                                                      visible: authorization(
                                                        authorized:
                                                            Authorizations().manageCostPrice,
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
                                                            Authorizations().manageCostPrice,
                                                      ),
                                                      child: SizedBox(
                                                        height:
                                                            10,
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.only(
                                                        bottom:
                                                            10.0,
                                                      ),
                                                      child: MainDropdown(
                                                        valueSet:
                                                            returnData().tempPricesList.isNotEmpty,
                                                        onTap: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (
                                                                context,
                                                              ) {
                                                                return ProductPricesPage(
                                                                  productUuid:
                                                                      product.uuid ??
                                                                      '',
                                                                );
                                                              },
                                                            ),
                                                          );
                                                        },
                                                        isOpen:
                                                            returnData().tempPricesList.isNotEmpty,
                                                        title:
                                                            'Selling Price(s)',
                                                        hint:
                                                            returnData(
                                                                  context:
                                                                      context,
                                                                ).tempPricesList.isEmpty
                                                                ? 'Add Price(s)'
                                                                : "${returnData(context: context).tempPricesList.firstWhere((item) => item.isPrimary).priceValue} and (${returnData(context: context).tempPricesList.length - 1}) More",
                                                        theme:
                                                            theme,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height:
                                                      20,
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
                                                              setState(
                                                                () {
                                                                  isEditPriceLoading =
                                                                      true;
                                                                },
                                                              );
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
                                                                  heightDimension:
                                                                      product.heightDimension,
                                                                  widthDimension:
                                                                      product.widthDimension,
                                                                  quantityType:
                                                                      product.quantityType,
                                                                  unitsList:
                                                                      product.unitsList,
                                                                  pricesList:
                                                                      returnData().tempPricesList,
                                                                  useGroupUnit:
                                                                      product.useGroupUnit,
                                                                  categories:
                                                                      product.categories,
                                                                  storageUuid:
                                                                      product.storageUuid,
                                                                  departmentName:
                                                                      product.departmentName,
                                                                  departmentUuid:
                                                                      product.departmentUuid,
                                                                  groupUnit:
                                                                      product.groupUnit,
                                                                  qttyPerGroup:
                                                                      product.qttyPerGroup,
                                                                  updatedAt:
                                                                      DateTime.now(),
                                                                  totalQttyInStorageDouble:
                                                                      product.totalQttyInStorageDouble,
                                                                  setCustomPrice:
                                                                      product.setCustomPrice,
                                                                  isManaged:
                                                                      product.isManaged,
                                                                  // id:
                                                                  //     product.id,
                                                                  name:
                                                                      product.name,
                                                                  unit:
                                                                      product.unit,
                                                                  isRefundable:
                                                                      product.isRefundable,
                                                                  costPrice:
                                                                      double.tryParse(
                                                                        costController.text.replaceAll(
                                                                          ',',
                                                                          '',
                                                                        ),
                                                                      ) ??
                                                                      0,
                                                                  sellingPrice:
                                                                      returnData().tempPricesList.isEmpty
                                                                          ? null
                                                                          : product.sellingPrice,
                                                                  wholeSalePrice:
                                                                      product.wholeSalePrice,
                                                                  quantity:
                                                                      product.quantity,
                                                                  shopId:
                                                                      product.shopId,
                                                                  barcode:
                                                                      product.barcode,
                                                                  // categoryUuid:
                                                                  //     product.categoryUuid,
                                                                  createdAt:
                                                                      product.createdAt,
                                                                  discount:
                                                                      product.discount,
                                                                  endDate:
                                                                      product.endDate,
                                                                  expiryDate:
                                                                      product.expiryDate,
                                                                  lowQtty:
                                                                      product.lowQtty,
                                                                  sizeType:
                                                                      product.sizeType,
                                                                  startDate:
                                                                      product.startDate,
                                                                  uuid:
                                                                      product.uuid,
                                                                ),
                                                                oldProduct:
                                                                    product,
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
                                                  height:
                                                      15,
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
                                                    theme:
                                                        theme,
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
                  text: 'Edit Price',
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class PricesGridSectionWidget extends StatefulWidget {
  final TempProductClass product;
  const PricesGridSectionWidget({
    super.key,
    required this.product,
  });

  @override
  State<PricesGridSectionWidget> createState() =>
      _PricesGridSectionWidgetState();
}

class _PricesGridSectionWidgetState
    extends State<PricesGridSectionWidget> {
  int getNumberOfPrices() {
    return widget.product.getPricesList().length;
  }

  int getFirstEndRand() {
    return widget.product.getPricesList().length > 2
        ? 2
        : 1;
  }

  int getSecondEndRand() {
    return widget.product.getPricesList().length > 4
        ? 4
        : 3;
  }

  @override
  Widget build(BuildContext context) {
    final prices = widget.product.getPricesList();

    return Column(
      children: [
        Visibility(
          visible: authorization(
            authorized: Authorizations().manageCostPrice,
          ),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 5,
                      horizontal: 8,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        3,
                      ),
                      border: Border.all(
                        color: const Color.fromARGB(
                          75,
                          255,
                          214,
                          79,
                        ),
                      ),
                      color: const Color.fromARGB(
                        64,
                        255,
                        226,
                        138,
                      ),
                    ),
                    child: Row(
                      spacing: 5,
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Text(
                          style: TextStyle(
                            fontSize:
                                returnTheme(
                                  context,
                                  listen: false,
                                ).mobileTexts.b4.fontSize,
                            color: null,
                          ),
                          'Cost Price',
                        ),
                        Text(
                          style: TextStyle(
                            fontSize:
                                returnTheme(
                                  context,
                                  listen: false,
                                ).mobileTexts.b4.fontSize,
                            fontWeight: FontWeight.bold,
                            color: null,
                          ),
                          formatMoneyBig(
                            amount:
                                widget.product.costPrice,
                            context: context,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        ...List.generate((prices.length / 2).ceil(), (
          rowIndex,
        ) {
          final start = rowIndex * 2;
          final end = (start + 2).clamp(0, prices.length);

          return Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 3.0,
            ),
            child: Row(
              spacing: 5,
              children:
                  prices
                      .sublist(start, end)
                      .map(
                        (item) => Expanded(
                          child: PriceWidgetProductDetails(
                            price: item,
                          ),
                        ),
                      )
                      .toList(),
            ),
          );
        }),
      ],
    );
  }
}

class PriceWidgetProductDetails extends StatelessWidget {
  final ProductPricesClass price;
  const PriceWidgetProductDetails({
    super.key,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            vertical: 5,
            horizontal: 8,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            border: Border.all(
              color:
                  price.isPrimary
                      ? theme.lightModeColor.prColor300
                      : Colors.grey.shade300,
            ),
            color:
                price.isPrimary
                    ? theme.lightModeColor.prColor300
                    : Colors.grey.shade100,
          ),
          child: Row(
            spacing: 5,
            children: [
              Expanded(
                child: Text(
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b4.fontSize,
                    color:
                        price.isPrimary
                            ? Colors.grey.shade200
                            : null,
                  ),
                  "${price.name}:",
                ),
              ),
              Text(
                style: TextStyle(
                  fontSize: theme.mobileTexts.b4.fontSize,
                  fontWeight: FontWeight.bold,
                  color:
                      price.isPrimary
                          ? Colors.grey.shade200
                          : null,
                ),
                formatMoneyBig(
                  amount: price.priceValue,
                  context: context,
                ),
              ),
              SizedBox(width: 2),
            ],
          ),
        ),
        Visibility(
          visible: price.isPrimary,
          child: Align(
            alignment: AlignmentGeometry.xy(1, 1),
            child: Icon(
              size: 13,
              color: Colors.white,
              Icons.check,
            ),
          ),
        ),
      ],
    );
  }
}
