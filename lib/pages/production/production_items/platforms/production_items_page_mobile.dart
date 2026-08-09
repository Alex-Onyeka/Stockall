import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_items/production_item.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/buttons/floating_action_butto.dart';
import 'package:stockall/components/major/empty_widget_display.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/components/text_fields/text_field_barcode.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/scan_barcode.dart';
import 'package:stockall/constants/subscription/items_auth.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/production/production_items/add_production_item/add_production_item.dart';
import 'package:stockall/pages/production/production_items/components/production_items_tile_main.dart';
import 'package:stockall/pages/production/production_items/platforms/production_items_page_desktop.dart';
import 'package:stockall/pages/production/production_items/production_item_history_page/production_item_history_page.dart';
import 'package:stockall/pages/production/production_items/production_items_details/production_items_details_page.dart';
import 'package:stockall/pages/products/compnents/product_filter_button.dart';
import 'package:stockall/pages/products/compnents/product_filter_button_category.dart';

class ProductionItemsPageMobile extends StatefulWidget {
  final bool? seeRemainingItems;
  const ProductionItemsPageMobile({
    super.key,
    this.seeRemainingItems,
  });

  @override
  State<ProductionItemsPageMobile> createState() =>
      _ProductionItemsPageMobileState();
}

class _ProductionItemsPageMobileState
    extends State<ProductionItemsPageMobile> {
  int currentSelect = 0;
  void changeSelected(int number) {
    currentSelect = number;
  }

  void clearState() {
    setState(() {
      searchController.clear();
    });
  }

  bool isFocus = false;
  TextEditingController searchController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.seeRemainingItems == true) {
        setState(() {
          currentSelect = 1;
        });
      }
    });
    returnData().toggleFloatingAction(context);
  }

  int filterIndex = 0;
  String? categoryUuid;
  bool isDeleteLoading = false;

  Future<void> getProductionItemList() async {
    await returnProductionItemsProvider()
        .getProductionItems();
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      returnProductionItemsProvider()
          .toggleIsSelectProductionItem(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    var productionItems =
        searchController.text.isNotEmpty
            ? returnProductionItemsProvider(
                  context: context,
                )
                .productionItemList()
                .where(
                  (pr) =>
                      pr.name.toLowerCase().contains(
                        searchController.text.toLowerCase(),
                      ) ||
                      pr.barcode?.toLowerCase() ==
                          searchController.text
                              .toLowerCase(),
                )
                .toList()
            : returnProductionItemsProvider(
              context: context,
            ).productionItemList();
    List<ProductionItem> filterProductionItems() {
      switch (currentSelect) {
        case 1:
          return productionItems
              .where((p) => p.quantity != 0)
              .toList();
        case 2:
          return productionItems
              .where(
                (p) =>
                    p.quantity != null && p.quantity != 0,
              )
              .toList();
        case 3:
          return productionItems
              .where((p) => p.quantity == 0)
              .toList();
        case 4:
          return productionItems
              .where((p) => p.quantity == null)
              .toList();
        case 5:
          return productionItems
              .where((p) => p.departmentUuid == null)
              .toList();
        case 0:
        default:
          return productionItems;
      }
    }

    List<ProductionItem> categoryFilterProductionItems() {
      if (categoryUuid != null) {
        return productionItems
            .where(
              (pr) =>
                  pr.categories?.contains(categoryUuid) ==
                  true,
            )
            .toList();
      }
      return productionItems;
    }

    return Stack(
      children: [
        Scaffold(
          appBar: appBar(
            context: context,
            title: 'All Items',
            widget: PopupMenuButton(
              offset: Offset(-20, 30),
              color: Colors.white,
              itemBuilder: (context) {
                return [
                  PopupMenuItem(
                    onTap: () {
                      setState(() {
                        filterIndex = 0;
                      });
                      returnProductionItemsProvider()
                          .toggleIsSelectProductionItem(
                            false,
                          );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10.0,
                      ),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            style: TextStyle(
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b3
                                      .fontSize,
                              fontWeight:
                                  filterIndex == 0
                                      ? FontWeight.bold
                                      : null,
                            ),
                            'Inventory Record',
                          ),
                          Visibility(
                            visible:
                                filterIndex == 0 &&
                                !returnProductionItemsProvider()
                                    .isSelectProductionItems,
                            child: Icon(
                              size: 17,
                              color: Colors.grey.shade700,
                              Icons.check,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  PopupMenuItem(
                    onTap: () {
                      setState(() {
                        filterIndex = 1;
                      });
                      returnProductionItemsProvider()
                          .toggleIsSelectProductionItem(
                            false,
                          );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10.0,
                      ),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            style: TextStyle(
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b3
                                      .fontSize,
                              fontWeight:
                                  filterIndex == 1
                                      ? FontWeight.bold
                                      : null,
                            ),
                            'Categories',
                          ),
                          Visibility(
                            visible: filterIndex == 1,
                            child: Icon(
                              size: 17,
                              color: Colors.grey.shade700,
                              Icons.check,
                            ),
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
                              fromProductionItemDetails:
                                  false,
                            );
                          },
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10.0,
                      ),
                      child: Text(
                        style: TextStyle(
                          fontSize:
                              theme.mobileTexts.b3.fontSize,
                        ),
                        'View History',
                      ),
                    ),
                  ),
                  PopupMenuItem(
                    onTap: () {
                      if (returnProductionItemsProvider()
                          .isSelectProductionItems) {
                        returnProductionItemsProvider()
                            .toggleIsSelectProductionItem(
                              false,
                            );
                      } else {
                        returnProductionItemsProvider()
                            .toggleIsSelectProductionItem(
                              true,
                            );
                      }
                      setState(() {
                        filterIndex = 0;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10.0,
                      ),
                      child: Row(
                        spacing: 5,
                        children: [
                          Text(
                            style: TextStyle(
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b3
                                      .fontSize,
                              fontWeight:
                                  filterIndex == 2
                                      ? FontWeight.bold
                                      : null,
                            ),
                            returnProductionItemsProvider()
                                    .isSelectProductionItems
                                ? 'Cancel'
                                : 'Select Items',
                          ),
                          Visibility(
                            visible:
                                returnProductionItemsProvider()
                                    .isSelectProductionItems,
                            child: Icon(
                              size: 17,
                              color: Colors.grey.shade700,
                              Icons.clear,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ];
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: Container(
                  padding: EdgeInsets.all(5),
                  child: Row(
                    spacing: 4,
                    children: [
                      Text(
                        style: TextStyle(
                          fontSize:
                              theme.mobileTexts.b3.fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                        filterIndex == 0
                            ? 'Inventory'
                            : 'Categories',
                      ),
                      Icon(Icons.more_vert_rounded),
                    ],
                  ),
                ),
              ),
            ),
          ),
          floatingActionButton: Visibility(
            visible: authorization(
              authorized:
                  Authorizations().addProductionItems,
            ),
            child: FloatingActionButtonMain(
              action: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return AddProductionItem();
                    },
                  ),
                ).then((_) {
                  setState(() {
                    // getProductionItemList(context);
                  });
                });
              },
              color: theme.lightModeColor.secColor100,
              text: 'Add Items',
              theme: theme,
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.endFloat,
          body: Stack(
            children: [
              Column(
                children: [
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30.0,
                    ),
                    child: TextFieldBarcode(
                      clearTextField: () {
                        setState(() {});
                      },
                      searchController: searchController,
                      onChanged: (value) {
                        setState(() {
                          if (productionItems
                              .where(
                                (pr) =>
                                    pr.barcode
                                        ?.toLowerCase() ==
                                    searchController.text
                                        .toLowerCase(),
                              )
                              .isNotEmpty) {
                            ItemsAuthAction()
                                .useOfBArcodeAction(
                                  context: context,
                                  action: () {
                                    setState(() {});
                                  },
                                  failAction: () {
                                    setState(() {
                                      searchController
                                          .clear();
                                    });
                                  },
                                );
                          } else {
                            setState(() {});
                          }
                        });
                      },

                      onPressedScan: () async {
                        ItemsAuthAction()
                            .useOfBArcodeAction(
                              context: context,
                              action: () async {
                                String? result =
                                    await scanCode(
                                      context,
                                      'Scan Failed',
                                    );
                                setState(() {
                                  if (result != null) {
                                    searchController.text =
                                        result;
                                  } else {
                                    return;
                                  }
                                });
                              },
                            );
                      },
                    ),
                  ),
                  Expanded(
                    child: SizedBox(
                      child: Builder(
                        builder: (context) {
                          if (productionItems.isEmpty) {
                            return Center(
                              child: SingleChildScrollView(
                                child: RefreshIndicator(
                                  onRefresh:
                                      getProductionItemList,
                                  color:
                                      theme
                                          .lightModeColor
                                          .prColor300,
                                  backgroundColor:
                                      Colors.white,
                                  displacement: 10,
                                  child: EmptyWidgetDisplay(
                                    buttonText: 'Add Item',
                                    subText:
                                        'Click on the button below to start adding Production Items to your store.',
                                    title:
                                        'You have not Item Under this Category',
                                    icon: Icons.clear,
                                    height: 35,
                                    action: () {
                                      if (authorization(
                                        authorized:
                                            Authorizations()
                                                .addProductionItems,
                                      )) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (
                                              context,
                                            ) {
                                              return AddProductionItem();
                                            },
                                          ),
                                        ).then((_) {
                                          if (context
                                              .mounted) {}
                                        });
                                      }
                                    },
                                    theme: theme,
                                    altAction: () async {
                                      await returnProductionItemsProvider()
                                          .getProductionItems();
                                    },
                                    altActionText:
                                        'Refresh',
                                    altIcon: Icons.refresh,
                                  ),
                                ),
                              ),
                            );
                          } else {
                            return Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(
                                    10.0,
                                    15,
                                    10,
                                    15,
                                  ),
                              child: Column(
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.symmetric(
                                          horizontal: 10.0,
                                        ),
                                    child: SizedBox(
                                      width:
                                          double.infinity,
                                      // height: 40,
                                      child: Builder(
                                        builder: (context) {
                                          if (returnProductionItemsProvider(
                                            context:
                                                context,
                                          ).isSelectProductionItems) {
                                            return SizedBox(
                                              width:
                                                  double
                                                      .infinity,
                                              child: Center(
                                                child: SingleChildScrollView(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.center,
                                                    children: [
                                                      ProductionItemSelectionActionButton(
                                                        title:
                                                            'Delete',
                                                        action: () {
                                                          if (returnProductionItemsProvider().selectedProductionItems.isNotEmpty) {
                                                            showDialog(
                                                              context:
                                                                  context,
                                                              builder: (
                                                                confirmContext,
                                                              ) {
                                                                return ConfirmationAlert(
                                                                  theme:
                                                                      theme,
                                                                  message:
                                                                      'You are about to delete all the selected Production Items. Please not that this action can not be reversed. Are you sure you want to proceed?',
                                                                  title:
                                                                      'Delete Selected Items',
                                                                  action: () async {
                                                                    Navigator.of(
                                                                      confirmContext,
                                                                    ).pop();
                                                                    setState(
                                                                      () {
                                                                        isDeleteLoading =
                                                                            true;
                                                                      },
                                                                    );
                                                                    var res =
                                                                        await returnProductionItemsProvider().deleteSelectedProductionItems();
                                                                    if (res ==
                                                                        0) {
                                                                      setState(
                                                                        () {
                                                                          isDeleteLoading =
                                                                              false;
                                                                        },
                                                                      );
                                                                      showDialog(
                                                                        // ignore: use_build_context_synchronously
                                                                        context:
                                                                            context,
                                                                        builder: (
                                                                          context,
                                                                        ) {
                                                                          return InfoAlert(
                                                                            theme:
                                                                                theme,
                                                                            message:
                                                                                'An error occoured while deleting selected Production Items. Please try again.',
                                                                            title:
                                                                                'An Error Occured',
                                                                          );
                                                                        },
                                                                      );
                                                                    } else {
                                                                      setState(
                                                                        () {
                                                                          isDeleteLoading =
                                                                              false;
                                                                        },
                                                                      );
                                                                      // returnProductionItemsProvider().toggleIsSelectProductionItem(
                                                                      //   false,
                                                                      // );
                                                                    }
                                                                  },
                                                                );
                                                              },
                                                            );
                                                          }
                                                        },
                                                        icon:
                                                            Icons.delete_outline_rounded,
                                                        color:
                                                            Colors.red.shade600,
                                                      ),
                                                      ProductionItemSelectionActionButton(
                                                        title:
                                                            'Duplicate',
                                                        action: () {
                                                          duplicateProductionItemsAction(
                                                            context:
                                                                context,
                                                            loadingAction: (
                                                              value,
                                                            ) {
                                                              setState(
                                                                () {
                                                                  isDeleteLoading =
                                                                      value;
                                                                },
                                                              );
                                                            },
                                                          );
                                                        },
                                                        icon:
                                                            Icons.control_point_duplicate_rounded,
                                                        color:
                                                            Colors.grey,
                                                      ),
                                                      ProductionItemSelectionActionButton(
                                                        title:
                                                            'Cancel',
                                                        action: () {
                                                          returnProductionItemsProvider().toggleIsSelectProductionItem(
                                                            false,
                                                          );
                                                          setState(
                                                            () {
                                                              filterIndex =
                                                                  0;
                                                            },
                                                          );
                                                        },
                                                        icon:
                                                            Icons.clear,
                                                        color:
                                                            Colors.grey,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          } else {
                                            if (filterIndex ==
                                                0) {
                                              return SingleChildScrollView(
                                                clipBehavior:
                                                    Clip.hardEdge,
                                                scrollDirection:
                                                    Axis.horizontal,
                                                child: Row(
                                                  spacing:
                                                      5,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .center,
                                                  children: [
                                                    ProductsFilterButton(
                                                      length:
                                                          filterProductionItems().length,
                                                      action: () {
                                                        setState(() {
                                                          changeSelected(
                                                            0,
                                                          );
                                                        });
                                                      },
                                                      currentSelected:
                                                          currentSelect,
                                                      number:
                                                          0,
                                                      title:
                                                          'All Items',
                                                      theme:
                                                          theme,
                                                    ),
                                                    ProductsFilterButton(
                                                      length:
                                                          filterProductionItems().length,
                                                      action: () {
                                                        setState(() {
                                                          changeSelected(
                                                            1,
                                                          );
                                                        });
                                                      },
                                                      currentSelected:
                                                          currentSelect,
                                                      number:
                                                          1,
                                                      title:
                                                          'In Stock',
                                                      theme:
                                                          theme,
                                                    ),
                                                    // ProductsFilterButton(
                                                    //   length:
                                                    //       filterProductionItems().length,
                                                    //   action: () {
                                                    //     setState(() {
                                                    //       changeSelected(
                                                    //         2,
                                                    //       );
                                                    //     });
                                                    //   },
                                                    //   currentSelected:
                                                    //       currentSelect,
                                                    //   number:
                                                    //       2,
                                                    //   title:
                                                    //       'Low Stock',
                                                    //   theme:
                                                    //       theme,
                                                    // ),
                                                    ProductsFilterButton(
                                                      length:
                                                          filterProductionItems().length,
                                                      currentSelected:
                                                          currentSelect,
                                                      action: () {
                                                        setState(() {
                                                          changeSelected(
                                                            3,
                                                          );
                                                        });
                                                      },
                                                      number:
                                                          3,
                                                      title:
                                                          'Out of Stock',
                                                      theme:
                                                          theme,
                                                    ),
                                                    ProductsFilterButton(
                                                      length:
                                                          filterProductionItems().length,
                                                      currentSelected:
                                                          currentSelect,
                                                      action: () {
                                                        setState(() {
                                                          changeSelected(
                                                            4,
                                                          );
                                                        });
                                                      },
                                                      number:
                                                          4,
                                                      title:
                                                          'UnManaged',
                                                      theme:
                                                          theme,
                                                    ),
                                                    Visibility(
                                                      visible:
                                                          returnShopProvider().userShop()?.manageDepartments ==
                                                          true,
                                                      child: ProductsFilterButton(
                                                        length:
                                                            filterProductionItems().length,
                                                        currentSelected:
                                                            currentSelect,
                                                        action: () {
                                                          setState(
                                                            () {
                                                              changeSelected(
                                                                5,
                                                              );
                                                            },
                                                          );
                                                        },
                                                        number:
                                                            5,
                                                        title:
                                                            'No Department',
                                                        theme:
                                                            theme,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            } else {
                                              return Center(
                                                child: SingleChildScrollView(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  child: Row(
                                                    spacing:
                                                        6,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.center,
                                                    children:
                                                        returnCategoriesProvider()
                                                            .categories()
                                                            .map(
                                                              (
                                                                cat,
                                                              ) => ProductFilterButtonCategory(
                                                                theme:
                                                                    theme,
                                                                action: () {
                                                                  setState(
                                                                    () {
                                                                      categoryUuid =
                                                                          cat.uuid;
                                                                    },
                                                                  );
                                                                },
                                                                currentSelected:
                                                                    categoryUuid ??
                                                                    '',
                                                                title:
                                                                    cat.name,
                                                                uuid:
                                                                    cat.uuid,
                                                              ),
                                                            )
                                                            .toList(),
                                                  ),
                                                ),
                                              );
                                            }
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Expanded(
                                    child: Builder(
                                      builder: (context) {
                                        if (filterIndex ==
                                            0) {
                                          if (filterProductionItems()
                                              .isNotEmpty) {
                                            return RefreshIndicator(
                                              onRefresh:
                                                  getProductionItemList,
                                              color:
                                                  theme
                                                      .lightModeColor
                                                      .prColor300,
                                              backgroundColor:
                                                  Colors
                                                      .white,
                                              displacement:
                                                  10,
                                              child: ListView.builder(
                                                itemCount:
                                                    filterProductionItems()
                                                        .length,
                                                itemBuilder: (
                                                  context,
                                                  index,
                                                ) {
                                                  List<
                                                    ProductionItem
                                                  >
                                                  productionItems =
                                                      filterProductionItems();

                                                  ProductionItem
                                                  productionItem =
                                                      productionItems[index];

                                                  return ProductionItemsTileMain(
                                                    isSelectProductionItem:
                                                        returnProductionItemsProvider(
                                                          context:
                                                              context,
                                                        ).isSelectProductionItems,
                                                    uuidList:
                                                        returnProductionItemsProvider(
                                                              context:
                                                                  context,
                                                            ).selectedProductionItems
                                                            .map(
                                                              (
                                                                pr,
                                                              ) =>
                                                                  pr.uuid!,
                                                            )
                                                            .toList(),
                                                    action: () {
                                                      if (returnProductionItemsProvider()
                                                          .isSelectProductionItems) {
                                                        returnProductionItemsProvider().selectProductionItem(
                                                          productionItem,
                                                        );
                                                      } else {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (
                                                              context,
                                                            ) {
                                                              return ProductionItemsDetailsPage(
                                                                productionItemUuid:
                                                                    productionItem.uuid!,
                                                              );
                                                            },
                                                          ),
                                                        ).then((
                                                          _,
                                                        ) {
                                                          if (context.mounted) {
                                                            setState(
                                                              () {},
                                                            );
                                                          }
                                                        });
                                                      }
                                                    },
                                                    longPress: () {
                                                      returnProductionItemsProvider().toggleIsSelectProductionItem(
                                                        true,
                                                      );
                                                      setState(() {
                                                        filterIndex =
                                                            0;
                                                      });
                                                      returnProductionItemsProvider().selectProductionItem(
                                                        productionItem,
                                                      );
                                                    },
                                                    theme:
                                                        theme,
                                                    productionItem:
                                                        productionItem,
                                                  );
                                                },
                                              ),
                                            );
                                          } else {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.only(
                                                    bottom:
                                                        30.0,
                                                  ),
                                              child: EmptyWidgetDisplayOnly(
                                                title:
                                                    'Empty List',
                                                subText:
                                                    'You Don\'t have any Production Item under this category',

                                                icon:
                                                    Icons
                                                        .dangerous_outlined,
                                                theme:
                                                    theme,
                                                height: 40,
                                              ),
                                            );
                                          }
                                        } else {
                                          if (categoryFilterProductionItems()
                                              .isNotEmpty) {
                                            return RefreshIndicator(
                                              onRefresh:
                                                  getProductionItemList,
                                              color:
                                                  theme
                                                      .lightModeColor
                                                      .prColor300,
                                              backgroundColor:
                                                  Colors
                                                      .white,
                                              displacement:
                                                  10,
                                              child: ListView.builder(
                                                itemCount:
                                                    categoryFilterProductionItems()
                                                        .length,
                                                itemBuilder: (
                                                  context,
                                                  index,
                                                ) {
                                                  List<
                                                    ProductionItem
                                                  >
                                                  productionItems =
                                                      categoryFilterProductionItems();

                                                  ProductionItem
                                                  productionItem =
                                                      productionItems[index];

                                                  return ProductionItemsTileMain(
                                                    isSelectProductionItem:
                                                        returnProductionItemsProvider(
                                                          context:
                                                              context,
                                                        ).isSelectProductionItems,
                                                    uuidList:
                                                        returnProductionItemsProvider(
                                                              context:
                                                                  context,
                                                            ).selectedProductionItems
                                                            .map(
                                                              (
                                                                pr,
                                                              ) =>
                                                                  pr.uuid!,
                                                            )
                                                            .toList(),
                                                    action: () {
                                                      if (returnProductionItemsProvider()
                                                          .isSelectProductionItems) {
                                                        returnProductionItemsProvider().selectProductionItem(
                                                          productionItem,
                                                        );
                                                      } else {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (
                                                              context,
                                                            ) {
                                                              return ProductionItemsDetailsPage(
                                                                productionItemUuid:
                                                                    productionItem.uuid!,
                                                              );
                                                            },
                                                          ),
                                                        ).then((
                                                          _,
                                                        ) {
                                                          if (context.mounted) {
                                                            setState(
                                                              () {},
                                                            );
                                                          }
                                                        });
                                                      }
                                                    },
                                                    longPress: () {
                                                      returnProductionItemsProvider().toggleIsSelectProductionItem(
                                                        true,
                                                      );
                                                      setState(() {
                                                        filterIndex =
                                                            0;
                                                      });
                                                      returnProductionItemsProvider().selectProductionItem(
                                                        productionItem,
                                                      );
                                                    },
                                                    theme:
                                                        theme,
                                                    productionItem:
                                                        productionItem,
                                                  );
                                                },
                                              ),
                                            );
                                          } else {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.only(
                                                    bottom:
                                                        30.0,
                                                  ),
                                              child: EmptyWidgetDisplayOnly(
                                                title:
                                                    'Empty List',
                                                subText:
                                                    'You Don\'t have any Item under this category',

                                                icon:
                                                    Icons
                                                        .dangerous_outlined,
                                                theme:
                                                    theme,
                                                height: 40,
                                              ),
                                            );
                                          }
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Visibility(
          visible: isDeleteLoading,
          child: returnCompProvider(
            context,
          ).showLoader(message: 'Loading'),
        ),
      ],
    );
  }
}
