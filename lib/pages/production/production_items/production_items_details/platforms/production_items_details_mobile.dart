import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_item_history/production_item_history.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_items/production_item.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/production/production_dashboard/productions_section/production_records_list/production_records_list.dart';
import 'package:stockall/pages/production/production_items/add_production_item/add_production_item.dart';
import 'package:stockall/pages/production/production_items/production_item_history_page/production_item_history_page.dart';
import 'package:stockall/pages/production/production_items/production_items_details/platforms/components/manage_this_item_toggle_button_production_item.dart';
import 'package:stockall/pages/production/production_items/production_items_details/platforms/components/quantity_in_stock_widget_production_item.dart';
import 'package:stockall/pages/production/production_items/production_items_details/platforms/components/transfer_production_item_quantity.dart';
import 'package:stockall/pages/production/production_items/production_items_details/platforms/components/update_cost_price_section_production_item.dart';
import 'package:stockall/pages/products/product_details/platforms/components/bottom_info_section.dart';
import 'package:stockall/pages/products/product_details/platforms/components/edit_button.dart';
import 'package:stockall/pages/products/product_details/platforms/components/tab_container.dart';
import 'package:stockall/providers/theme_provider.dart';

class ProductionItemsDetailsMobile extends StatefulWidget {
  final ThemeProvider theme;
  final String productionItemUuid;
  const ProductionItemsDetailsMobile({
    super.key,
    required this.theme,
    required this.productionItemUuid,
  });

  @override
  State<ProductionItemsDetailsMobile> createState() =>
      _ProductionItemsDetailsMobileState();
}

class _ProductionItemsDetailsMobileState
    extends State<ProductionItemsDetailsMobile> {
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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // final shopI = returnShopProvider().userShop()!.shopId!;
    List<ProductionItem>? productionItemList =
        returnProductionItemsProvider()
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
      return Stack(
        children: [
          Scaffold(
            appBar: appBar(
              context: context,
              title: 'Details',
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
                          padding: const EdgeInsets.only(
                            left: 5.0,
                            right: 15,
                          ),
                          child: Row(
                            spacing: 10,
                            children: [
                              Icon(
                                size: 16,
                                Icons.view_in_ar_rounded,
                              ),
                              Text(
                                style: TextStyle(
                                  fontWeight:
                                      FontWeight.bold,
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
                          padding: const EdgeInsets.only(
                            left: 5.0,
                            right: 15,
                          ),
                          child: Row(
                            spacing: 10,
                            children: [
                              Icon(
                                size: 16,
                                Icons.receipt_long_rounded,
                              ),
                              Text(
                                style: TextStyle(
                                  fontWeight:
                                      FontWeight.bold,
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
                    child: Icon(Icons.more_vert_rounded),
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
                                productionItem.name,
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
                                'Date Created: ${formatDateTime(productionItem.createdAt!)}',
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
                                              isMoney: true,
                                              text:
                                                  'Cost Price',
                                              price:
                                                  productionItem
                                                      .costPrice,
                                              theme:
                                                  widget
                                                      .theme,
                                              backGround:
                                                  const Color.fromARGB(
                                                    11,
                                                    15,
                                                    4,
                                                    114,
                                                  ),
                                              border:
                                                  const Color.fromARGB(
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
                                              Authorizations()
                                                  .updateProductionItems,
                                        ),
                                        child: EditButton(
                                          theme:
                                              widget.theme,
                                          action: () {
                                            updateCostPriceActionProductionItem(
                                              productionItem:
                                                  productionItem,
                                              context:
                                                  context,
                                              costController:
                                                  costController,
                                              theme:
                                                  widget
                                                      .theme,
                                              setStateAction:
                                                  () {
                                                    setState(
                                                      () {},
                                                    );
                                                  },
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
                          SizedBox(height: 20),
                          quantityInStockWidgetProductItem(
                            context,
                            productionItem,
                            shopId(),
                          ),
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
                                                  .b3
                                                  .fontSize,
                                          fontWeight:
                                              FontWeight
                                                  .normal,
                                        ),
                                        'Manage this Item?',
                                      ),
                                      ManageThisItemToggleButtonProductionItem(
                                        productionItem:
                                            productionItem,
                                        setStateAction: () {
                                          setState(() {});
                                        },
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
                                    theme: widget.theme,
                                    mainText:
                                        productionItem
                                                    .expiryDate !=
                                                null
                                            ? getDayDifference(
                                                      productionItem.expiryDate ??
                                                          DateTime.now(),
                                                    ) >=
                                                    1
                                                ? formatDateTime(
                                                  productionItem
                                                          .expiryDate ??
                                                      DateTime.now(),
                                                )
                                                : 'Item Expired'
                                            : 'Not Set',
                                    text: 'Expiry Date',
                                  ),
                                ),
                                // Visibility(
                                //   visible:
                                //       productionItem
                                //           .useGroupUnit ==
                                //       true,
                                //   child: BottomInfoSection(
                                //     theme: widget.theme,
                                //     mainText:
                                //         productionItem
                                //                     .qttyPerGroup !=
                                //                 null
                                //             ? formatLargeNumberDouble(
                                //               (productionItem
                                //                       .qttyPerGroup ??
                                //                   0),
                                //             )
                                //             : 'Not Set',
                                //     text: 'Qtty Per Group',
                                //   ),
                                // ),

                                // BottomInfoSection(
                                //   theme: widget.theme,
                                //   mainText:
                                //       '${productionItem.unit.substring(0, 1).toUpperCase()}${productionItem.unit.substring(1)}',
                                //   text: 'Unit',
                                // ),
                                Visibility(
                                  visible:
                                      productionItem
                                          .sizeType !=
                                      null,
                                  child: BottomInfoSection(
                                    theme: widget.theme,
                                    mainText:
                                        productionItem
                                            .sizeType ??
                                        'Not Set',
                                    text: 'Size Type',
                                  ),
                                ),
                                BottomInfoSection(
                                  theme: widget.theme,
                                  mainText:
                                      "(${productionItem.categories?.length ?? 0}) Category(s)",
                                  text: 'Categories',
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
                                  .deleteProductionItems,
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
                                      returnProductionItemsProvider();
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
                                      ProductionItemHistory
                                      productionItemHistory = ProductionItemHistory(
                                        shopId: shopId(),
                                        title:
                                            'Item Deleted',
                                        quantityChange: 0,
                                        newValue:
                                            (productionItem
                                                        .quantity ??
                                                    0)
                                                .toString(),
                                        desc:
                                            'Item Deleted Now',
                                        isIncreased: false,
                                        oldValue:
                                            (productionItem
                                                        .quantity ??
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
                                  .updateProductionItems,
                        ),
                        child: Expanded(
                          child: EditButton(
                            text: 'Edit',
                            action: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return AddProductionItem(
                                      productionItem:
                                          productionItem,
                                    );
                                  },
                                ),
                              ).then((context) {
                                returnProductionItemsProvider()
                                    .getSingleProductionItemOnline(
                                      itemUuid:
                                          widget
                                              .productionItemUuid,
                                    );
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
