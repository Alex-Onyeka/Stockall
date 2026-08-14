import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_item_history/production_item_history.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_items/production_item.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/components/text_fields/money_textfield.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/subscription/items_auth.dart';
import 'package:stockall/constants/subscription/subscription_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/production/production_dashboard/productions_section/production_records_list/production_records_list.dart';
import 'package:stockall/pages/production/production_items/add_production_item/add_production_item.dart';
import 'package:stockall/pages/production/production_items/production_item_history_page/production_item_history_page.dart';
import 'package:stockall/pages/production/production_items/production_items_details/platforms/components/transfer_production_item_quantity.dart';
import 'package:stockall/pages/production/production_items/production_items_details/platforms/components/update_production_item_quantity.dart';
import 'package:stockall/pages/products/product_details/platforms/product_details_desktop.dart';
import 'package:stockall/providers/theme_provider.dart';

class ProductionItemsDetailsDesktop extends StatefulWidget {
  final ThemeProvider theme;
  final String productionItemUuid;
  const ProductionItemsDetailsDesktop({
    super.key,
    required this.theme,
    required this.productionItemUuid,
  });

  @override
  State<ProductionItemsDetailsDesktop> createState() =>
      _ProductionItemsDetailsDesktopState();
}

class _ProductionItemsDetailsDesktopState
    extends State<ProductionItemsDetailsDesktop> {
  late Future<ProductionItem> productionItemFuture;

  bool isLoading = false;
  bool showSuccess = false;
  bool setDate = false;

  TextEditingController costController =
      TextEditingController();
  TextEditingController quantityController =
      TextEditingController();
  TextEditingController qttyPerUnitController =
      TextEditingController();

  @override
  void dispose() {
    super.dispose();
    costController.dispose();
    quantityController.dispose();
    qttyPerUnitController.dispose();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final shopI = returnShopProvider().userShop()!.shopId!;
    List<ProductionItem>? productionItemList =
        returnProductionItemsProvider(context: context)
            .productionItemListMain
            .where(
              (productionItem) =>
                  productionItem.uuid! ==
                  widget.productionItemUuid,
            )
            .toList();
    if (productionItemList.isEmpty) {
      return Scaffold(
        body: returnCompProvider(
          context,
          listen: false,
        ).showLoader(message: 'Loading...'),
      );
    } else {
      ProductionItem productionItem =
          productionItemList.first;
      return Scaffold(
        key: _scaffoldKey,
        body: Row(
          spacing: 15,
          children: [
            Container(
              width:
                  screenWidth(context) < tabletScreenSmall
                      ? 50
                      : (screenWidth(context) >
                              tabletScreenSmall &&
                          screenWidth(context) <
                              tabletScreen + 100)
                      ? 100
                      : 230,
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 15),
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
                child: Stack(
                  children: [
                    Scaffold(
                      appBar: appBar(
                        context: context,
                        title: 'Item Details',
                        widget: Visibility(
                          visible: !isStoreKeeper(),
                          child: PopupMenuButton(
                            offset: Offset(-20, 30),
                            color: Colors.white,
                            itemBuilder: (context) {
                              return [
                                PopupMenuItem(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return ProductionRecordsList(
                                            productionItemUuid:
                                                widget
                                                    .productionItemUuid,
                                          );
                                        },
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.only(
                                          left: 5.0,
                                          right: 15,
                                        ),
                                    child: Row(
                                      spacing: 10,
                                      children: [
                                        Icon(
                                          size: 16,
                                          Icons
                                              .view_in_ar_rounded,
                                        ),
                                        Text(
                                          style: TextStyle(
                                            fontWeight:
                                                FontWeight
                                                    .bold,
                                            fontSize:
                                                widget
                                                    .theme
                                                    .mobileTexts
                                                    .b3
                                                    .fontSize,
                                          ),
                                          'View Productions',
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                PopupMenuItem(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return ProductionItemHistoryPage(
                                            productionItemUuid:
                                                widget
                                                    .productionItemUuid,
                                            fromProductionItemDetails:
                                                true,
                                          );
                                        },
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.only(
                                          left: 5.0,
                                          right: 15,
                                        ),
                                    child: Row(
                                      spacing: 10,
                                      children: [
                                        Icon(
                                          size: 16,
                                          Icons
                                              .receipt_long_rounded,
                                        ),
                                        Text(
                                          style: TextStyle(
                                            fontWeight:
                                                FontWeight
                                                    .bold,
                                            fontSize:
                                                widget
                                                    .theme
                                                    .mobileTexts
                                                    .b3
                                                    .fontSize,
                                          ),
                                          'View History',
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ];
                            },
                            child: Container(
                              padding: EdgeInsets.all(5),
                              child: Icon(
                                Icons.more_vert_rounded,
                              ),
                            ),
                          ),
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
                                      CrossAxisAlignment
                                          .center,
                                  children: [
                                    SizedBox(height: 10),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment
                                              .center,
                                      children: [
                                        Text(
                                          textAlign:
                                              TextAlign
                                                  .center,
                                          style: TextStyle(
                                            fontSize:
                                                widget
                                                    .theme
                                                    .mobileTexts
                                                    .h4
                                                    .fontSize,
                                            fontWeight:
                                                FontWeight
                                                    .bold,
                                          ),
                                          productionItem
                                              .name,
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
                                                FontWeight
                                                    .normal,
                                          ),
                                          'Date Created:  ${formatDateTime(productionItem.createdAt!)}',
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 20),
                                    Visibility(
                                      visible: authorization(
                                        authorized:
                                            Authorizations()
                                                .manageCostPrice,
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              spacing: 10,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .center,
                                                  children: [
                                                    Expanded(
                                                      child: TabContainer(
                                                        isMoney:
                                                            true,
                                                        text:
                                                            'Cost Price',
                                                        price:
                                                            productionItem.costPrice,
                                                        theme:
                                                            widget.theme,
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
                                                  ],
                                                ),
                                                Visibility(
                                                  visible: authorization(
                                                    authorized:
                                                        Authorizations().updateProductionItems,
                                                  ),
                                                  child: EditButton(
                                                    theme:
                                                        widget.theme,
                                                    action: () {
                                                      updateCostPriceAction(
                                                        productionItem:
                                                            productionItem,
                                                      );
                                                    },
                                                    text:
                                                        'Edit Price',
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    Column(
                                      children: [
                                        SizedBox(
                                          height: 15,
                                        ),
                                        Row(
                                          children: [
                                            quantityInStockWidget(
                                              context,
                                              productionItem,
                                              shopI,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 20),
                                    Divider(
                                      height: 15,
                                      color:
                                          Colors
                                              .grey
                                              .shade200,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment
                                              .center,
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
                                                    .bold,
                                          ),
                                          'Other Details',
                                        ),
                                      ],
                                    ),
                                    Divider(
                                      height: 15,
                                      color:
                                          Colors
                                              .grey
                                              .shade200,
                                    ),
                                    SizedBox(height: 10),
                                    Padding(
                                      padding:
                                          const EdgeInsets.symmetric(
                                            horizontal:
                                                10.0,
                                          ),
                                      child: Column(
                                        spacing: 0,
                                        children: [
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.symmetric(
                                                  vertical:
                                                      5.0,
                                                ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  style: TextStyle(
                                                    fontSize:
                                                        widget.theme.mobileTexts.b1.fontSize,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                  ),
                                                  'Manage this Item?',
                                                ),
                                                InkWell(
                                                  mouseCursor:
                                                      SystemMouseCursors
                                                          .click,
                                                  onTap: () {
                                                    ItemsAuthAction().allowStockallToManageItemAction(
                                                      context:
                                                          context,
                                                      action: () async {
                                                        if (authorization(
                                                          authorized:
                                                              Authorizations().updateProductionItems,
                                                        )) {
                                                          var productionItemProvider =
                                                              returnProductionItemsProvider();
                                                          showDialog(
                                                            context:
                                                                context,
                                                            builder: (
                                                              confirmDialog,
                                                            ) {
                                                              return ConfirmationAlert(
                                                                theme:
                                                                    widget.theme,
                                                                message:
                                                                    productionItem.isManaged
                                                                        ? 'This item quantity will no longer be automatically managed by Stockall, are you sure you want to proceed?'
                                                                        : 'This item quantity will now be automatically managed by Stockall, are you sure you want to proceed?',
                                                                title:
                                                                    'Proceed with Action?',
                                                                action: () async {
                                                                  Navigator.of(
                                                                    confirmDialog,
                                                                  ).pop();
                                                                  setState(
                                                                    () {
                                                                      isLoading =
                                                                          true;
                                                                    },
                                                                  );
                                                                  await productionItemProvider.updateProductionItem(
                                                                    productionItemHistory:
                                                                        null,
                                                                    includeQuantity:
                                                                        false,
                                                                    isIncrement:
                                                                        null,
                                                                    isQuantityUpdate:
                                                                        false,
                                                                    quantityChange:
                                                                        null,
                                                                    productionItem: ProductionItem(
                                                                      useGroupUnit:
                                                                          productionItem.useGroupUnit,
                                                                      categories:
                                                                          productionItem.categories,
                                                                      departmentName:
                                                                          productionItem.departmentName,
                                                                      departmentUuid:
                                                                          productionItem.departmentUuid,
                                                                      groupUnit:
                                                                          productionItem.groupUnit,
                                                                      qttyPerGroup:
                                                                          productionItem.qttyPerGroup,
                                                                      updatedAt:
                                                                          DateTime.now(),
                                                                      isManaged:
                                                                          productionItem.isManaged
                                                                              ? false
                                                                              : true,
                                                                      name:
                                                                          productionItem.name,
                                                                      unit:
                                                                          productionItem.unit,
                                                                      costPrice:
                                                                          productionItem.costPrice,
                                                                      quantity:
                                                                          !productionItem.isManaged &&
                                                                                  productionItem.quantity ==
                                                                                      null
                                                                              ? 0
                                                                              : productionItem.quantity,
                                                                      shopId:
                                                                          productionItem.shopId,
                                                                      barcode:
                                                                          productionItem.barcode,
                                                                      // categoryUuid:
                                                                      //     productionItem.categoryUuid,
                                                                      createdAt:
                                                                          productionItem.createdAt,
                                                                      expiryDate:
                                                                          productionItem.expiryDate,
                                                                      sizeType:
                                                                          productionItem.sizeType,
                                                                      uuid:
                                                                          productionItem.uuid,
                                                                    ),
                                                                    oldProductionItem:
                                                                        productionItem,
                                                                  );
                                                                  setState(
                                                                    () {
                                                                      isLoading =
                                                                          false;
                                                                    },
                                                                  );
                                                                },
                                                              );
                                                            },
                                                          );
                                                        }
                                                      },
                                                    );
                                                  },
                                                  child: SubWrapper(
                                                    isVisible:
                                                        !ItemsAuthAction().allowStockallToManageItemAction(
                                                          context:
                                                              context,
                                                        ),
                                                    mainWidget: Container(
                                                      width:
                                                          50,
                                                      padding: EdgeInsets.symmetric(
                                                        horizontal:
                                                            10,
                                                        vertical:
                                                            5,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(
                                                          20,
                                                        ),
                                                        border: Border.all(
                                                          color:
                                                              productionItem.isManaged
                                                                  ? widget.theme.lightModeColor.prColor250
                                                                  : Colors.grey,
                                                        ),
                                                        color:
                                                            productionItem.isManaged
                                                                ? widget.theme.lightModeColor.prColor250
                                                                : Colors.grey.shade200,
                                                      ),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            productionItem.isManaged
                                                                ? MainAxisAlignment.end
                                                                : MainAxisAlignment.start,
                                                        children: [
                                                          Container(
                                                            padding: EdgeInsets.all(
                                                              5,
                                                            ),
                                                            decoration: BoxDecoration(
                                                              shape:
                                                                  BoxShape.circle,
                                                              color:
                                                                  productionItem.isManaged
                                                                      ? Colors.white
                                                                      : Colors.grey.shade600,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Visibility(
                                            visible:
                                                productionItem
                                                    .expiryDate !=
                                                null,
                                            child: BottomInfoSection(
                                              theme:
                                                  widget
                                                      .theme,
                                              mainText:
                                                  productionItem.expiryDate !=
                                                          null
                                                      ? getDayDifference(
                                                                productionItem.expiryDate ??
                                                                    DateTime.now(),
                                                              ) >=
                                                              1
                                                          ? formatDateTime(
                                                            productionItem.expiryDate ??
                                                                DateTime.now(),
                                                          )
                                                          : 'Item Expired'
                                                      : 'Not Set',
                                              text:
                                                  'Expiry Date',
                                            ),
                                          ),
                                          Visibility(
                                            visible:
                                                productionItem
                                                    .useGroupUnit ==
                                                true,
                                            child: BottomInfoSection(
                                              theme:
                                                  widget
                                                      .theme,
                                              mainText:
                                                  productionItem.qttyPerGroup !=
                                                          null
                                                      ? formatLargeNumberDouble(
                                                        (productionItem.qttyPerGroup ??
                                                            0),
                                                      )
                                                      : 'Not Set',
                                              text:
                                                  'Quantity Per Group',
                                            ),
                                          ),
                                          // BottomInfoSection(
                                          //   theme:
                                          //       widget
                                          //           .theme,
                                          //   mainText:
                                          //       productionItem
                                          //           .barcode ??
                                          //       'Not Set',
                                          //   text: 'Barcode',
                                          //   onClick: () {
                                          //     if (authorization(
                                          //       authorized:
                                          //           Authorizations()
                                          //               .updateProductionItems,
                                          //     )) {
                                          //       // ItemsAuthAction().generateBarcodeAction(
                                          //       //   context:
                                          //       //       context,
                                          //       //   action: () {
                                          //       //     if (kIsWeb) {
                                          //       //       showDialog(
                                          //       //         context:
                                          //       //             context,
                                          //       //         builder: (
                                          //       //           firstContext,
                                          //       //         ) {
                                          //       //           return ConfirmationAlert(
                                          //       //             theme:
                                          //       //                 widget.theme,
                                          //       //             message:
                                          //       //                 'You are about to regenrate and print the barcode of this item, are you sure you want to proceed?',
                                          //       //             actionButtonText:
                                          //       //                 'Generate',
                                          //       //             title:
                                          //       //                 'Regenerate and Print Barcode?',
                                          //       //             action: () async {
                                          //       //               Navigator.of(
                                          //       //                 firstContext,
                                          //       //               ).pop();
                                          //       //               setState(
                                          //       //                 () {
                                          //       //                   isLoading =
                                          //       //                       true;
                                          //       //                 },
                                          //       //               );
                                          //       //               returnProductionItemsProvider().addToBarcodeGenerationList(
                                          //       //                 ProductionItemBarcode(
                                          //       //                   productionItem:
                                          //       //                       productionItem,
                                          //       //                   number:
                                          //       //                       1,
                                          //       //                 ),
                                          //       //               );
                                          //       //               generateBarcodeAndPrint(
                                          //       //                 context,
                                          //       //                 returnProductionItemsProvider().barcodeGenerationList,
                                          //       //                 false,
                                          //       //               ).then(
                                          //       //                 (
                                          //       //                   _,
                                          //       //                 ) {
                                          //       //                   returnProductionItemsProvider().clearBarcodeGenerationList();
                                          //       //                   setState(
                                          //       //                     () {
                                          //       //                       isLoading =
                                          //       //                           false;
                                          //       //                     },
                                          //       //                   );
                                          //       //                 },
                                          //       //               );

                                          //       //               await mainLocalLog(
                                          //       //                 'Generate Clicked',
                                          //       //               );
                                          //       //             },
                                          //       //           );
                                          //       //         },
                                          //       //       );
                                          //       //     } else {
                                          //       //       Navigator.push(
                                          //       //         context,
                                          //       //         MaterialPageRoute(
                                          //       //           builder: (
                                          //       //             context,
                                          //       //           ) {
                                          //       //             return BarcodePrintingPage(
                                          //       //               productionItem:
                                          //       //                   productionItem,
                                          //       //             );
                                          //       //           },
                                          //       //         ),
                                          //       //       );
                                          //       //     }
                                          //       //   },
                                          //       // );
                                          //     }
                                          //   },
                                          //   setBarcodeAction:
                                          //       productionItem.barcode ==
                                          //               null
                                          //           ? () {
                                          //             if (authorization(
                                          //               authorized:
                                          //                   Authorizations().updateProductionItems,
                                          //             )) {
                                          //               // ItemsAuthAction().generateBarcodeAction(
                                          //               //   context:
                                          //               //       context,
                                          //               //   action: () {
                                          //               //     if (kIsWeb) {
                                          //               //       returnProductionItemsProvider().addToBarcodeGenerationList(
                                          //               //         ProductionItemBarcode(
                                          //               //           productionItem:
                                          //               //               productionItem,
                                          //               //           number:
                                          //               //               1,
                                          //               //         ),
                                          //               //       );
                                          //               //       generateBarcodeAndPrint(
                                          //               //         context,
                                          //               //         returnProductionItemsProvider().barcodeGenerationList,
                                          //               //         false,
                                          //               //       );
                                          //               //     } else {
                                          //               //       Navigator.push(
                                          //               //         context,
                                          //               //         MaterialPageRoute(
                                          //               //           builder: (
                                          //               //             context,
                                          //               //           ) {
                                          //               //             return BarcodePrintingPage(
                                          //               //               productionItem:
                                          //               //                   productionItem,
                                          //               //             );
                                          //               //           },
                                          //               //         ),
                                          //               //       );
                                          //               //     }
                                          //               //   },
                                          //               // );
                                          //             }
                                          //           }
                                          //           : null,
                                          //   actionText:
                                          //       productionItem.barcode ==
                                          //               null
                                          //           ? 'Create Barcode'
                                          //           : null,
                                          // ),

                                          // BottomInfoSection(
                                          //   theme:
                                          //       widget
                                          //           .theme,
                                          //   mainText:
                                          //       productionItem.discount !=
                                          //               null
                                          //           ? "${productionItem.discount}%"
                                          //           : 'Not Set',
                                          //   text:
                                          //       'Discount',
                                          // ),
                                          BottomInfoSection(
                                            theme:
                                                widget
                                                    .theme,
                                            mainText:
                                                '${productionItem.unit.substring(0, 1).toUpperCase()}${productionItem.unit.substring(1)}',
                                            text: 'Unit',
                                          ),
                                          Visibility(
                                            visible:
                                                productionItem
                                                    .sizeType !=
                                                null,
                                            child: BottomInfoSection(
                                              theme:
                                                  widget
                                                      .theme,
                                              mainText:
                                                  productionItem
                                                      .sizeType ??
                                                  'Not Set',
                                              text:
                                                  'Size Type',
                                            ),
                                          ),
                                          BottomInfoSection(
                                            theme:
                                                widget
                                                    .theme,
                                            mainText:
                                                "(${productionItem.categories?.length ?? 0}) Category(s)",
                                            text:
                                                'Categories',
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
                                            .transferProductionItems,
                                  ),
                                  child: Expanded(
                                    child: EditButton(
                                      text: 'Transfer',
                                      action: () {
                                        transferProductionItemQuantity(
                                          context,
                                          productionItem,
                                        );
                                      },
                                      theme: returnTheme(
                                        context,
                                      ),
                                      icon:
                                          Icons
                                              .rotate_left_rounded,
                                      color: Colors.amber,
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: authorization(
                                    authorized:
                                        Authorizations()
                                            .deleteProductionItems,
                                  ),
                                  child: Expanded(
                                    child: EditButton(
                                      text: 'Delete Item',
                                      action: () {
                                        final safeContext =
                                            context;
                                        showDialog(
                                          context:
                                              safeContext,
                                          builder: (
                                            confirmDialog,
                                          ) {
                                            var provider =
                                                returnProductionItemsProvider();
                                            return ConfirmationAlert(
                                              theme:
                                                  returnTheme(
                                                    context,
                                                  ),
                                              message:
                                                  'Are you sure you want to proceed with action?',
                                              title:
                                                  'Are you sure?',
                                              action: () async {
                                                Navigator.of(
                                                  confirmDialog,
                                                ).pop();
                                                setState(() {
                                                  isLoading =
                                                      true;
                                                });
                                                ProductionItemHistory
                                                productionItemHistory = ProductionItemHistory(
                                                  shopId:
                                                      shopId(),
                                                  title:
                                                      'Item Deleted',
                                                  quantityChange:
                                                      0,
                                                  newValue:
                                                      (productionItem.quantity ??
                                                              0)
                                                          .toString(),
                                                  desc:
                                                      'Item Deleted Now',
                                                  isIncreased:
                                                      false,
                                                  oldValue:
                                                      (productionItem.quantity ??
                                                              0)
                                                          .toString(),
                                                );
                                                await provider.deleteProductionItemMain(
                                                  productionItemHistory:
                                                      productionItemHistory,
                                                  productionItem:
                                                      productionItem,
                                                );
                                                setState(() {
                                                  isLoading =
                                                      false;
                                                  showSuccess =
                                                      true;
                                                });
                                                Future.delayed(
                                                  Duration(
                                                    seconds:
                                                        1,
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
                                      theme: returnTheme(
                                        context,
                                      ),
                                      icon:
                                          Icons
                                              .delete_forever_outlined,
                                      color:
                                          Colors.redAccent,
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: authorization(
                                    authorized:
                                        Authorizations()
                                            .updateProductionItems,
                                  ),
                                  child: Expanded(
                                    child: EditButton(
                                      text: 'Edit Item',
                                      action: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (
                                              context,
                                            ) {
                                              return AddProductionItem(
                                                productionItem:
                                                    productionItem,
                                              );
                                            },
                                          ),
                                        ).then((context) {
                                          setState(() {});
                                        });
                                      },
                                      theme: returnTheme(
                                        context,
                                      ),
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
                ),
              ),
            ),
            Container(
              width:
                  screenWidth(context) < tabletScreenSmall
                      ? 50
                      : (screenWidth(context) >
                              tabletScreenSmall &&
                          screenWidth(context) <
                              tabletScreen + 100)
                      ? 100
                      : 230,
            ),
          ],
        ),
      );
    }
  }

  Widget quantityInStockWidget(
    BuildContext context,
    ProductionItem productionItem,
    int shopI,
  ) {
    return Expanded(
      child: Column(
        spacing: 10,
        children: [
          Row(
            children: [
              Visibility(
                visible:
                    productionItem.useGroupUnit == true,
                child: Expanded(
                  child: TabContainer(
                    isMoney: false,
                    text:
                        productionItem.groupUnit != null &&
                                productionItem.groupUnit !=
                                    'Others'
                            ? ' Quantity Of ${productionItem.groupUnit}'
                            : 'Group Quantity',
                    price: returnProductionItemsProvider(
                      context: context,
                    ).returnGroupQuantityValue(
                      productionItem,
                    ),
                    theme: widget.theme,
                    backGround: const Color.fromARGB(
                      48,
                      158,
                      158,
                      158,
                    ),
                    border: const Color.fromARGB(
                      45,
                      158,
                      158,
                      158,
                    ),
                  ),
                ),
              ),
              Visibility(
                visible:
                    productionItem.useGroupUnit == true,
                child: SizedBox(width: 10),
              ),
              Expanded(
                child: TabContainer(
                  isMoney: false,
                  text:
                      productionItem.unit != 'Others'
                          ? ' Quantity Of ${productionItem.unit}'
                          : 'Unit Quantity',
                  price: productionItem.quantity ?? 0,
                  theme: widget.theme,
                  backGround: const Color.fromARGB(
                    48,
                    158,
                    158,
                    158,
                  ),
                  border: const Color.fromARGB(
                    45,
                    158,
                    158,
                    158,
                  ),
                ),
              ),
            ],
          ),
          Visibility(
            visible:
                authorization(
                  authorized:
                      Authorizations()
                          .updateProductionItems,
                ) &&
                authorization(
                  authorized:
                      Authorizations()
                          .updateProductionItemQuantity,
                ),
            child: Row(
              children: [
                Expanded(
                  child: EditButton(
                    theme: widget.theme,
                    action: () {
                      updateProductionItemQuantity(
                        context,
                        productionItem,
                      );
                    },
                    text: 'Edit Qtty',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void updateCostPriceAction({
    required ProductionItem productionItem,
  }) {
    setState(() {
      costController.text =
          productionItem.costPrice.toString().toString();
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
                                        onPressed: () {},
                                        icon: Icon(
                                          Icons.clear,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      style: TextStyle(
                                        fontSize:
                                            widget
                                                .theme
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
                                                  widget
                                                      .theme
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
                                      theme: widget.theme,
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20),
                                MainButtonP(
                                  themeProvider:
                                      widget.theme,
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
                                                widget
                                                    .theme,
                                            message:
                                                'Are you sure you want to proceed?',
                                            title:
                                                'Proceed?',
                                            action: () async {
                                              final productionItemProvider =
                                                  returnProductionItemsProvider();
                                              Navigator.of(
                                                confirmDialog,
                                              ).pop();
                                              setState(() {
                                                isEditPriceLoading =
                                                    true;
                                              });
                                              await productionItemProvider.updateProductionItem(
                                                productionItemHistory:
                                                    null,
                                                includeQuantity:
                                                    false,
                                                isIncrement:
                                                    null,
                                                isQuantityUpdate:
                                                    false,
                                                quantityChange:
                                                    null,
                                                productionItem: ProductionItem(
                                                  useGroupUnit:
                                                      productionItem
                                                          .useGroupUnit,
                                                  categories:
                                                      productionItem
                                                          .categories,
                                                  departmentName:
                                                      productionItem
                                                          .departmentName,
                                                  departmentUuid:
                                                      productionItem
                                                          .departmentUuid,
                                                  groupUnit:
                                                      productionItem
                                                          .groupUnit,
                                                  qttyPerGroup:
                                                      productionItem
                                                          .qttyPerGroup,
                                                  updatedAt:
                                                      DateTime.now(),
                                                  isManaged:
                                                      productionItem
                                                          .isManaged,
                                                  name:
                                                      productionItem
                                                          .name,
                                                  unit:
                                                      productionItem
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
                                                      productionItem
                                                          .quantity,
                                                  shopId:
                                                      productionItem
                                                          .shopId,
                                                  barcode:
                                                      productionItem
                                                          .barcode,
                                                  // categoryUuid:
                                                  //     productionItem
                                                  //         .categoryUuid,
                                                  createdAt:
                                                      productionItem
                                                          .createdAt,
                                                  expiryDate:
                                                      productionItem
                                                          .expiryDate,
                                                  sizeType:
                                                      productionItem
                                                          .sizeType,
                                                  uuid:
                                                      productionItem
                                                          .uuid,
                                                ),
                                                oldProductionItem:
                                                    productionItem,
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
                                    theme: widget.theme,
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
}

class TabContainer extends StatelessWidget {
  const TabContainer({
    super.key,
    required this.theme,
    required this.backGround,
    required this.border,
    required this.price,
    required this.text,
    required this.isMoney,
    this.priceTextSize,
    this.isDiscount,
  });
  final Color backGround;
  final Color border;
  final double price;
  final ThemeProvider theme;
  final String text;
  final bool isMoney;
  final bool? isDiscount;
  final double? priceTextSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 7,
        horizontal: 2,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: backGround,
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: theme.mobileTexts.b4.fontSize,
                  fontWeight: FontWeight.normal,
                ),
                text,
              ),
              Text(
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize:
                      priceTextSize ??
                      theme.mobileTexts.b2.fontSize,
                  fontWeight: FontWeight.bold,
                ),
                '${isMoney ? currencySymbol(context: context) : ''}${isMoney
                    ? formatLargeNumberDouble(price)
                    : authorization(authorized: Authorizations().viewProductionItemQuantity)
                    ? formatLargeNumberDouble(price)
                    : 'Restricted'}${isDiscount != null ? '%' : ''}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
