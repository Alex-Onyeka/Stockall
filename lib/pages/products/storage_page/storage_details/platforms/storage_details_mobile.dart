import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_storage_item_history/storage_item_history.dart';
import 'package:stockall/classes/temp_storage_item_history/storage_item_history_event_class.dart';
import 'package:stockall/classes/temp_storage_product/temp_storage_products.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/products/compnents/product_tile_main.dart';
import 'package:stockall/pages/products/product_details/platforms/components/edit_button.dart';
import 'package:stockall/pages/products/product_details/platforms/components/tab_container.dart';
import 'package:stockall/pages/products/product_details/product_details_page.dart';
import 'package:stockall/pages/products/storage_page/add_storage_item/add_storage_item.dart';
import 'package:stockall/pages/products/storage_page/storage_details/components/quantity_in_stock_storage_item.dart';
import 'package:stockall/pages/products/storage_page/storage_details/components/update_storage_item_quantity.dart';
import 'package:stockall/pages/products/storage_page/storage_item_history_page/item_history_page.dart';
import 'package:stockall/providers/theme_provider.dart';

class StorageDetailsMobile extends StatefulWidget {
  final ThemeProvider theme;
  final String productUuid;
  const StorageDetailsMobile({
    super.key,
    required this.theme,
    required this.productUuid,
  });

  @override
  State<StorageDetailsMobile> createState() =>
      _StorageDetailsMobileState();
}

class _StorageDetailsMobileState
    extends State<StorageDetailsMobile> {
  bool isLoading = false;
  bool showSuccess = false;

  @override
  Widget build(BuildContext context) {
    List<TempStorageProducts>? productList =
        returnStorageProductProvider(context: context)
            .storageProductListMain
            .where(
              (product) =>
                  product.uuid == widget.productUuid,
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
      TempStorageProducts product = productList.first;
      return Stack(
        children: [
          Scaffold(
            appBar: appBar(
              context: context,
              title: 'Details',
              widget: InkWell(
                mouseCursor: SystemMouseCursors.click,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return StorageItemHistoryPage(
                          productUuid: product.uuid,
                          fromItemDetails: true,
                        );
                      },
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 5,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Row(
                    spacing: 3,
                    children: [
                      Text(
                        style: TextStyle(
                          fontSize:
                              widget
                                  .theme
                                  .mobileTexts
                                  .b3
                                  .fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                        'History',
                      ),
                      Icon(
                        size: 16,
                        color: Colors.grey.shade600,
                        Icons.history,
                      ),
                      SizedBox(width: 10),
                    ],
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
                                product.name,
                              ),
                              Text(
                                style: TextStyle(
                                  fontSize:
                                      widget
                                          .theme
                                          .mobileTexts
                                          .b3
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
                              if (product.quantityType == 2)
                                Text(
                                  style: TextStyle(
                                    fontSize:
                                        widget
                                            .theme
                                            .mobileTexts
                                            .b3
                                            .fontSize,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                  '2D Item. Sheet Size:${formatDimensionsLabel(product.widthDimension, product.heightDimension)}',
                                ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: TabContainer(
                                  isMoney: true,
                                  text: 'Cost Price',
                                  price:
                                      product.costPrice ??
                                      0,
                                  theme: widget.theme,
                                  backGround:
                                      const Color.fromARGB(
                                        24,
                                        240,
                                        206,
                                        104,
                                      ),
                                  border:
                                      const Color.fromARGB(
                                        71,
                                        228,
                                        225,
                                        41,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          quantityInStockWidgetStorageItem(
                            context,
                            product,
                          ),
                          SizedBox(height: 20),
                          Divider(
                            height: 15,
                            color: Colors.grey.shade200,
                          ),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
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
                                      FontWeight.bold,
                                ),
                                'Products',
                              ),
                            ],
                          ),
                          Divider(
                            height: 15,
                            color: Colors.grey.shade200,
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(
                                  horizontal: 3.0,
                                ),
                            child: Column(
                              spacing: 0,
                              children: [
                                ManageProductsStorage(
                                  productUuid:
                                      widget.productUuid,
                                  theme: widget.theme,
                                ),
                                SizedBox(height: 5),
                                Column(
                                  children:
                                      returnData(
                                            context:
                                                context,
                                          ).productListMain
                                          .where(
                                            (pr) =>
                                                pr.storageUuid ==
                                                widget
                                                    .productUuid,
                                          )
                                          .toList()
                                          .map(
                                            (pro) => Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment
                                                      .start,
                                              children: [
                                                ProductTileMain(
                                                  product:
                                                      pro,
                                                  theme:
                                                      widget
                                                          .theme,
                                                  action: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (
                                                          context,
                                                        ) {
                                                          return ProductDetailsPage(
                                                            productUuid:
                                                                pro.uuid!,
                                                          );
                                                        },
                                                      ),
                                                    );
                                                  },
                                                ),
                                                DimensionMismatchLabel(
                                                  storageProduct:
                                                      product,
                                                  product:
                                                      pro,
                                                  theme:
                                                      widget
                                                          .theme,
                                                ),
                                              ],
                                            ),
                                          )
                                          .toList(),
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
                    spacing: 15,
                    children: [
                      Expanded(
                        child: EditButton(
                          text: 'Delete Item',
                          action: () {
                            final safeContext = context;
                            showDialog(
                              context: safeContext,
                              builder: (confirmDialog) {
                                var provider =
                                    returnStorageProductProvider();
                                var shopId =
                                    returnShopProvider()
                                        .userShop()!
                                        .shopId!;
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
                                    StorageItemHistory
                                    itemHistory = StorageItemHistory(
                                      event:
                                          StorageItemHistoryEventClass
                                              .itemDeleted,
                                      source:
                                          StorageItemHistoryEventClass
                                              .storageSource,
                                      destination:
                                          StorageItemHistoryEventClass
                                              .deletedDestination,
                                      shopId: shopId,
                                      title: 'Item Deleted',
                                      quantityChange: 0,
                                      storageItemNewValue:
                                          (product.quantity ??
                                                  0)
                                              .toString(),
                                      desc:
                                          'Item Deleted Now',
                                      isIncreased: false,
                                      storageItemOldValue:
                                          (product.quantity ??
                                                  0)
                                              .toString(),
                                    );
                                    await provider
                                        .deleteProductMain(
                                          product: product,
                                          itemHistory:
                                              itemHistory,
                                        );
                                    await provider
                                        .getStorageProducts(
                                          shopId,
                                        );
                                    setState(() {
                                      isLoading = false;
                                      showSuccess = true;
                                    });
                                    Future.delayed(
                                      Duration(seconds: 2),
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
                              Icons.delete_forever_outlined,
                          color: Colors.redAccent,
                        ),
                      ),
                      Expanded(
                        child: EditButton(
                          text: 'Edit Item',
                          action: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return AddStorageItem(
                                    productStorage: product,
                                  );
                                },
                              ),
                            ).then((context) {
                              returnStorageProductProvider()
                                  .getSingleStorageProductItemOnline(
                                    itemUuid:
                                        widget.productUuid,
                                  );
                              setState(() {});
                            });
                          },
                          theme: returnTheme(context),
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
