import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_item_history/item_history.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/generate_barcode.dart';
import 'package:stockall/constants/subscription/items_auth.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/products/add_product_one/add_product.dart';
import 'package:stockall/pages/products/product_details/platforms/components/bottom_info_section.dart';
import 'package:stockall/pages/products/product_details/platforms/components/edit_button.dart';
import 'package:stockall/pages/products/product_details/platforms/components/manage_this_item_toggle_switch.dart';
import 'package:stockall/pages/products/product_details/platforms/components/prices_section_product_details.dart';
import 'package:stockall/pages/products/product_details/platforms/components/product_details_more_widget.dart';
import 'package:stockall/pages/products/product_details/platforms/components/quanitity_in_stock_widget.dart';
import 'package:stockall/pages/products/product_details/platforms/components/transfer_item_quantity.dart';
import 'package:stockall/providers/data_provider.dart';
import 'package:stockall/providers/theme_provider.dart';

class ProductDetailsMobile extends StatefulWidget {
  final ThemeProvider theme;
  final String productUuid;
  const ProductDetailsMobile({
    super.key,
    required this.theme,
    required this.productUuid,
  });

  @override
  State<ProductDetailsMobile> createState() =>
      _ProductDetailsMobileState();
}

class _ProductDetailsMobileState
    extends State<ProductDetailsMobile> {
  late Future<TempProductClass> productFuture;

  bool isLoading = false;
  bool showSuccess = false;
  bool setDate = false;
  TextEditingController costController =
      TextEditingController();
  TextEditingController sellingController =
      TextEditingController();
  TextEditingController wholeSaleController =
      TextEditingController();
  TextEditingController quantityController =
      TextEditingController();
  TextEditingController discountController =
      TextEditingController();
  TextEditingController qttyPerUnitController =
      TextEditingController();

  @override
  void dispose() {
    super.dispose();
    costController.dispose();
    sellingController.dispose();
    quantityController.dispose();
    discountController.dispose();
    qttyPerUnitController.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final shopI = returnShopProvider().userShop()!.shopId!;
    List<TempProductClass>? productList =
        returnData(context: context).productListMain
            .where(
              (product) =>
                  product.uuid! == widget.productUuid,
            )
            .toList();
    if (productList.isEmpty) {
      return Scaffold(
        body: returnCompProvider(
          context,
          listen: false,
        ).showLoader(message: 'Loading...'),
      );
    } else {
      TempProductClass product = productList.first;
      return Stack(
        children: [
          Scaffold(
            appBar: appBar(
              context: context,
              title: 'Details',
              widget: ProductDetailsMoreWidget(
                productUuid: product.uuid ?? '',
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 15.0,
              ),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 10),
                          Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.center,
                            children: [
                              Text(
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize:
                                      widget
                                          .theme
                                          .mobileTexts
                                          .h4
                                          .fontSize,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                                product.name,
                              ),
                              Text(
                                style: TextStyle(
                                  fontSize:
                                      widget
                                          .theme
                                          .mobileTexts
                                          .b2
                                          .fontSize,
                                  color:
                                      widget
                                          .theme
                                          .lightModeColor
                                          .secColor200,
                                  fontWeight:
                                      FontWeight.normal,
                                ),
                                'Date Created: ${formatDateTime(product.createdAt!)}',
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          PricesSectionProductDetails(
                            product: product,
                          ),
                          SizedBox(height: 20),
                          Column(
                            children: [
                              quantityInStockWidget(
                                context,
                                product,
                                shopI,
                              ),
                            ],
                          ),
                          // SizedBox(height: 20),
                          // Divider(
                          //   height: 15,
                          //   color: Colors.grey.shade200,
                          // ),
                          // Row(
                          //   mainAxisAlignment:
                          //       MainAxisAlignment.center,
                          //   children: [
                          //     Text(
                          //       style: TextStyle(
                          //         fontSize:
                          //             widget
                          //                 .theme
                          //                 .mobileTexts
                          //                 .b2
                          //                 .fontSize,
                          //         fontWeight:
                          //             FontWeight.bold,
                          //       ),
                          //       'Other Details',
                          //     ),
                          //   ],
                          // ),
                          // Divider(
                          //   height: 15,
                          //   color: Colors.grey.shade200,
                          // ),
                          SizedBox(height: 10),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(
                                  horizontal: 10.0,
                                ),
                            child: Column(
                              spacing: 0,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(
                                        vertical: 5.0,
                                      ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment
                                            .spaceBetween,
                                    children: [
                                      Text(
                                        style: TextStyle(
                                          fontSize:
                                              widget
                                                  .theme
                                                  .mobileTexts
                                                  .b2
                                                  .fontSize,
                                          fontWeight:
                                              FontWeight
                                                  .normal,
                                        ),
                                        'Manage this Item?',
                                      ),
                                      ManageThisItemToggleSwitch(
                                        product: product,
                                        setStateAction: () {
                                          setState(() {});
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                Visibility(
                                  visible:
                                      product.expiryDate !=
                                      null,
                                  child: BottomInfoSection(
                                    theme: widget.theme,
                                    mainText:
                                        product.expiryDate !=
                                                null
                                            ? getDayDifference(
                                                      product.expiryDate ??
                                                          DateTime.now(),
                                                    ) >=
                                                    1
                                                ? formatDateTime(
                                                  product.expiryDate ??
                                                      DateTime.now(),
                                                )
                                                : 'Item Expired'
                                            : 'Not Set',
                                    text: 'Expiry Date',
                                  ),
                                ),
                                // Visibility(
                                //   visible:
                                //       product
                                //           .useGroupUnit ==
                                //       true,
                                //   child: BottomInfoSection(
                                //     theme: widget.theme,
                                //     mainText:
                                //         product.qttyPerGroup !=
                                //                 null
                                //             ? formatLargeNumberDouble(
                                //               (product.qttyPerGroup ??
                                //                   0),
                                //             )
                                //             : 'Not Set',
                                //     text: 'Qtty Per Group',
                                //   ),
                                // ),
                                BottomInfoSection(
                                  theme: widget.theme,
                                  mainText:
                                      product.barcode ??
                                      'Not Set',
                                  text: 'Barcode',
                                  onClick: () {
                                    createBarcodeActionProductDetails(
                                      context: context,
                                      product: product,
                                      toggleLoadingAction: (
                                        value,
                                      ) {
                                        setState(() {
                                          isLoading = value;
                                        });
                                      },
                                    );
                                  },
                                  setBarcodeAction:
                                      product.barcode ==
                                              null
                                          ? () {
                                            if (authorization(
                                              authorized:
                                                  Authorizations()
                                                      .updateProduct,
                                            )) {
                                              ItemsAuthAction().generateBarcodeAction(
                                                context:
                                                    context,
                                                action: () {
                                                  returnData().addToBarcodeGenerationList(
                                                    ProductBarcode(
                                                      product:
                                                          product,
                                                      number:
                                                          1,
                                                    ),
                                                  );
                                                  generateBarcodeAndPrint(
                                                    context,
                                                    returnData()
                                                        .barcodeGenerationList,
                                                    false,
                                                  );
                                                },
                                              );
                                            }
                                          }
                                          : null,
                                  actionText:
                                      product.barcode ==
                                              null
                                          ? 'Create Barcode'
                                          : null,
                                ),

                                BottomInfoSection(
                                  theme: widget.theme,
                                  mainText:
                                      product.discount !=
                                              null
                                          ? "${product.discount}%"
                                          : 'Not Set',
                                  text: 'Discount',
                                ),
                                // BottomInfoSection(
                                //   theme: widget.theme,
                                //   mainText:
                                //       product
                                //           .getSingleUnit(),
                                //   text: 'Unit',
                                // ),
                                Visibility(
                                  visible:
                                      product.sizeType !=
                                      null,
                                  child: BottomInfoSection(
                                    theme: widget.theme,
                                    mainText:
                                        product.sizeType ??
                                        'Not Set',
                                    text: 'Size Type',
                                  ),
                                ),
                                BottomInfoSection(
                                  theme: widget.theme,
                                  mainText:
                                      "(${product.categories?.length ?? 0}) Category(s)",
                                  text: 'Categories',
                                ),
                                BottomInfoSection(
                                  theme: widget.theme,
                                  mainText:
                                      product.lowQtty!
                                          .toString(),
                                  text:
                                      'Low Quantity Limit',
                                ),
                                // BottomInfoSection(
                                //   theme: widget.theme,
                                //   mainText:
                                //       product.isRefundable
                                //           ? 'True'
                                //           : 'False',
                                //   text: 'Is Refundable?',
                                // ),
                                BottomInfoSection(
                                  theme: widget.theme,
                                  mainText:
                                      product.setCustomPrice
                                          ? 'True'
                                          : 'False',
                                  text:
                                      'Can Set Custom Price?',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    spacing: 5,
                    children: [
                      Visibility(
                        visible: authorization(
                          authorized:
                              Authorizations()
                                  .transferProduct,
                        ),
                        child: Expanded(
                          child: EditButton(
                            text: 'Transfer',
                            action: () {
                              transferItemQuantity(
                                context,
                                product,
                              );
                            },
                            theme: returnTheme(context),
                            icon: Icons.rotate_left_rounded,
                            color: Colors.amber,
                          ),
                        ),
                      ),
                      Visibility(
                        visible: authorization(
                          authorized:
                              Authorizations()
                                  .deleteProduct,
                        ),
                        child: Expanded(
                          child: EditButton(
                            text: 'Delete',
                            action: () {
                              final safeContext = context;
                              showDialog(
                                context: safeContext,
                                builder: (confirmDialog) {
                                  var provider =
                                      returnData();
                                  return ConfirmationAlert(
                                    theme: returnTheme(
                                      context,
                                    ),
                                    message:
                                        'Are you sure you want to proceed with action?',
                                    title: 'Are you sure?',
                                    action: () async {
                                      Navigator.of(
                                        confirmDialog,
                                      ).pop();

                                      setState(() {
                                        isLoading = true;
                                      });
                                      ItemHistory
                                      itemHistory = ItemHistory(
                                        shopId: shopId(),
                                        title:
                                            'Item Deleted',
                                        quantityChange: 0,
                                        newValue:
                                            (product.quantity ??
                                                    0)
                                                .toString(),
                                        desc:
                                            'Item Deleted Now',
                                        isIncreased: false,
                                        oldValue:
                                            (product.quantity ??
                                                    0)
                                                .toString(),
                                      );
                                      await provider
                                          .deleteProductMain(
                                            itemHistory:
                                                itemHistory,
                                            product:
                                                product,
                                          );
                                      // await provider
                                      //     .getProducts(
                                      //       shopId,
                                      //     );
                                      setState(() {
                                        isLoading = false;
                                        showSuccess = true;
                                      });
                                      Future.delayed(
                                        Duration(
                                          seconds: 1,
                                        ),
                                        () {
                                          if (safeContext
                                              .mounted) {
                                            Navigator.of(
                                              safeContext,
                                            ).pop();
                                          }
                                        },
                                      );
                                    },
                                  );
                                },
                              );
                            },
                            theme: returnTheme(context),
                            icon:
                                Icons
                                    .delete_forever_outlined,
                            color: Colors.redAccent,
                          ),
                        ),
                      ),
                      Visibility(
                        visible: authorization(
                          authorized:
                              Authorizations()
                                  .updateProduct,
                        ),
                        child: Expanded(
                          child: EditButton(
                            text: 'Edit',
                            action: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return AddProduct(
                                      product: product,
                                    );
                                  },
                                ),
                              ).then((context) {
                                setState(() {});
                              });
                            },
                            theme: returnTheme(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
          Visibility(
            visible: isLoading,
            child: returnCompProvider(
              context,
              listen: false,
            ).showLoader(message: 'Updating'),
          ),
        ],
      );
    }
  }
}

void createBarcodeActionProductDetails({
  required BuildContext context,
  required TempProductClass product,
  required Function(bool value) toggleLoadingAction,
}) {
  var theme = returnTheme(context, listen: false);
  if (authorization(
    authorized: Authorizations().updateProduct,
  )) {
    ItemsAuthAction().generateBarcodeAction(
      context: context,
      action: () {
        returnData().addToBarcodeGenerationList(
          ProductBarcode(product: product, number: 1),
        );
        showDialog(
          context: context,
          builder: (firstContext) {
            return ConfirmationAlert(
              theme: theme,
              message:
                  'You are about to regenrate and print the barcode of this item, are you sure you want to proceed?',
              actionButtonText: 'Generate',
              title: 'Regenerate and Print Barcode?',
              action: () async {
                Navigator.of(firstContext).pop();
                toggleLoadingAction(true);
                generateBarcodeAndPrint(
                  context,
                  returnData().barcodeGenerationList,
                  false,
                ).then((_) {
                  returnData().clearBarcodeGenerationList();
                  toggleLoadingAction(false);
                });

                await mainLocalLog('Generate Clicked');
              },
            );
          },
        );
      },
    );
  }
}
