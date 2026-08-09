import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_items/production_item.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/dialog_template.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/buttons/floating_action_butto.dart';
import 'package:stockall/components/buttons/main_button_transparent.dart';
import 'package:stockall/components/major/empty_widget_display.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/components/text_fields/text_field_barcode.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/production/production_items/add_production_item/add_production_item.dart';
import 'package:stockall/pages/production/production_items/components/production_items_tile_main.dart';
import 'package:stockall/pages/production/production_items/production_item_history_page/production_item_history_page.dart';
import 'package:stockall/pages/production/production_items/production_items_details/production_items_details_page.dart';
import 'package:stockall/pages/products/compnents/product_filter_button.dart';
import 'package:stockall/pages/products/compnents/product_filter_button_category.dart';

class ProductionItemsPageDesktop extends StatefulWidget {
  final bool? seeRemainingItems;
  const ProductionItemsPageDesktop({
    super.key,
    this.seeRemainingItems,
  });

  @override
  State<ProductionItemsPageDesktop> createState() =>
      _ProductionItemsPageDesktopState();
}

class _ProductionItemsPageDesktopState
    extends State<ProductionItemsPageDesktop> {
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

  bool isLoading = false;
  bool isDeleteLoading = false;

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

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      returnProductionItemsProvider()
          .toggleIsSelectProductionItem(false);
    });
  }

  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();
  int filterIndex = 0;
  String? categoryUuid;

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
              .where(
                (p) =>
                    p.quantity != 0 && p.quantity != null,
              )
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
              .where((p) => !p.isManaged)
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

    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: [
          Row(
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
                child: Stack(
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(
                        vertical: 15,
                      ),
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          15,
                        ),
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
                      child: Scaffold(
                        appBar: appBar(
                          context: context,
                          title: 'All Items',
                          widget: Row(
                            spacing: 5,
                            children: [
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  mouseCursor:
                                      SystemMouseCursors
                                          .click,
                                  borderRadius:
                                      BorderRadius.circular(
                                        10,
                                      ),
                                  onTap: () async {
                                    await getProductionItemList();
                                  },
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.all(
                                          10,
                                        ),
                                    child: Row(
                                      spacing: 5,
                                      children: [
                                        Visibility(
                                          visible:
                                              screenWidth(
                                                context,
                                              ) >
                                              tabletScreenSmall,
                                          child: Text(
                                            style: TextStyle(
                                              fontSize:
                                                  theme
                                                      .mobileTexts
                                                      .b3
                                                      .fontSize,
                                              fontWeight:
                                                  FontWeight
                                                      .bold,
                                            ),
                                            'Refresh',
                                          ),
                                        ),
                                        Icon(
                                          size: 18,
                                          Icons
                                              .refresh_rounded,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              PopupMenuButton(
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
                                        padding:
                                            const EdgeInsets.symmetric(
                                              horizontal:
                                                  10.0,
                                            ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment
                                                  .spaceBetween,
                                          children: [
                                            Text(
                                              style: TextStyle(
                                                fontSize:
                                                    theme
                                                        .mobileTexts
                                                        .b3
                                                        .fontSize,
                                                fontWeight:
                                                    filterIndex ==
                                                            0
                                                        ? FontWeight.bold
                                                        : null,
                                              ),
                                              'Inventory Record',
                                            ),
                                            Visibility(
                                              visible:
                                                  filterIndex ==
                                                      0 &&
                                                  !returnProductionItemsProvider()
                                                      .isSelectProductionItems,
                                              child: Icon(
                                                size: 17,
                                                color:
                                                    Colors
                                                        .grey
                                                        .shade700,
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
                                        padding:
                                            const EdgeInsets.symmetric(
                                              horizontal:
                                                  10.0,
                                            ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment
                                                  .spaceBetween,
                                          children: [
                                            Text(
                                              style: TextStyle(
                                                fontSize:
                                                    theme
                                                        .mobileTexts
                                                        .b3
                                                        .fontSize,
                                                fontWeight:
                                                    filterIndex ==
                                                            1
                                                        ? FontWeight.bold
                                                        : null,
                                              ),
                                              'Categories',
                                            ),
                                            Visibility(
                                              visible:
                                                  filterIndex ==
                                                  1,
                                              child: Icon(
                                                size: 17,
                                                color:
                                                    Colors
                                                        .grey
                                                        .shade700,
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
                                            builder: (
                                              context,
                                            ) {
                                              return ProductionItemHistoryPage(
                                                fromProductionItemDetails:
                                                    false,
                                              );
                                            },
                                          ),
                                        );
                                      },
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.symmetric(
                                              horizontal:
                                                  10.0,
                                            ),
                                        child: Text(
                                          style: TextStyle(
                                            fontSize:
                                                theme
                                                    .mobileTexts
                                                    .b3
                                                    .fontSize,
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
                                        padding:
                                            const EdgeInsets.symmetric(
                                              horizontal:
                                                  10.0,
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
                                                    filterIndex ==
                                                            2
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
                                                color:
                                                    Colors
                                                        .grey
                                                        .shade700,
                                                Icons.clear,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ];
                                },
                                child: Container(
                                  padding: EdgeInsets.all(
                                    5,
                                  ),
                                  child: Icon(
                                    Icons.more_vert_rounded,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        floatingActionButton: Visibility(
                          visible: authorization(
                            authorized:
                                Authorizations()
                                    .addProductionItems,
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
                            color:
                                theme
                                    .lightModeColor
                                    .secColor100,
                            text: 'Add Items',
                            theme: theme,
                          ),
                        ),
                        floatingActionButtonLocation:
                            FloatingActionButtonLocation
                                .endFloat,
                        body: Stack(
                          children: [
                            Column(
                              children: [
                                SizedBox(height: 10),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(
                                        horizontal: 30.0,
                                      ),
                                  child: TextFieldBarcode(
                                    clearTextField: () {
                                      setState(() {});
                                    },
                                    searchController:
                                        searchController,
                                    onChanged: (value) {
                                      setState(() {});
                                    },

                                    onPressedScan: () {},
                                  ),
                                ),
                                Expanded(
                                  child: SizedBox(
                                    child: Builder(
                                      builder: (context) {
                                        if (productionItems
                                            .isEmpty) {
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
                                                    Colors
                                                        .white,
                                                displacement:
                                                    10,
                                                child: EmptyWidgetDisplay(
                                                  buttonText:
                                                      'Add Item',
                                                  subText:
                                                      'Click on the button below to start adding Items to your store.',
                                                  title:
                                                      'You have no Item Under this Category',
                                                  icon:
                                                      Icons
                                                          .clear,
                                                  height:
                                                      35,
                                                  action: () {
                                                    if (authorization(
                                                      authorized:
                                                          Authorizations().addProductionItems,
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
                                                      ).then((
                                                        _,
                                                      ) {
                                                        if (context.mounted) {}
                                                      });
                                                    }
                                                  },
                                                  theme:
                                                      theme,
                                                  altAction: () async {
                                                    await returnProductionItemsProvider()
                                                        .getProductionItems();
                                                  },
                                                  altActionText:
                                                      'Refresh',
                                                  altIcon:
                                                      Icons
                                                          .refresh,
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
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal:
                                                        5.0,
                                                  ),
                                                  child: SizedBox(
                                                    width:
                                                        double.infinity,
                                                    // height: 40,
                                                    child: Builder(
                                                      builder: (
                                                        context,
                                                      ) {
                                                        if (returnProductionItemsProvider(
                                                          context:
                                                              context,
                                                        ).isSelectProductionItems) {
                                                          return Row(
                                                            // spacing:
                                                            //     5,
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
                                                                              'You are about to delete all the selected Items. Please note that this action can not be reversed. Are you sure you want to proceed?',
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
                                                                                        'An error occoured while deleting selected Items. Please try again.',
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
                                                          );
                                                        } else {
                                                          if (screenWidth(
                                                                context,
                                                              ) <
                                                              tabletScreen) {
                                                            return Builder(
                                                              builder: (
                                                                context,
                                                              ) {
                                                                if (filterIndex ==
                                                                    0) {
                                                                  return SingleChildScrollView(
                                                                    scrollDirection:
                                                                        Axis.horizontal,
                                                                    child: Row(
                                                                      spacing:
                                                                          6,
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment.center,
                                                                      children: [
                                                                        ProductsFilterButton(
                                                                          length:
                                                                              filterProductionItems().length,
                                                                          action: () {
                                                                            setState(
                                                                              () {
                                                                                changeSelected(
                                                                                  0,
                                                                                );
                                                                              },
                                                                            );
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
                                                                            setState(
                                                                              () {
                                                                                changeSelected(
                                                                                  1,
                                                                                );
                                                                              },
                                                                            );
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
                                                                        //     setState(
                                                                        //       () {
                                                                        //         changeSelected(
                                                                        //           2,
                                                                        //         );
                                                                        //       },
                                                                        //     );
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
                                                                            setState(
                                                                              () {
                                                                                changeSelected(
                                                                                  3,
                                                                                );
                                                                              },
                                                                            );
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
                                                                            setState(
                                                                              () {
                                                                                changeSelected(
                                                                                  4,
                                                                                );
                                                                              },
                                                                            );
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
                                                                  return SingleChildScrollView(
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
                                                                  );
                                                                }
                                                              },
                                                            );
                                                          } else {
                                                            if (filterIndex ==
                                                                0) {
                                                              return Row(
                                                                spacing:
                                                                    5,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment.center,
                                                                children: [
                                                                  ProductsFilterButton(
                                                                    length:
                                                                        filterProductionItems().length,
                                                                    action: () {
                                                                      setState(
                                                                        () {
                                                                          changeSelected(
                                                                            0,
                                                                          );
                                                                        },
                                                                      );
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
                                                                      setState(
                                                                        () {
                                                                          changeSelected(
                                                                            1,
                                                                          );
                                                                        },
                                                                      );
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
                                                                  //     setState(
                                                                  //       () {
                                                                  //         changeSelected(
                                                                  //           2,
                                                                  //         );
                                                                  //       },
                                                                  //     );
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
                                                                      setState(
                                                                        () {
                                                                          changeSelected(
                                                                            3,
                                                                          );
                                                                        },
                                                                      );
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
                                                                      setState(
                                                                        () {
                                                                          changeSelected(
                                                                            4,
                                                                          );
                                                                        },
                                                                      );
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
                                                              );
                                                            } else {
                                                              return Row(
                                                                spacing:
                                                                    5,
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
                                                              );
                                                            }
                                                          }
                                                        }
                                                      },
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height:
                                                      10,
                                                ),
                                                Expanded(
                                                  child: Builder(
                                                    builder: (
                                                      context,
                                                    ) {
                                                      if (filterIndex ==
                                                          0) {
                                                        if (filterProductionItems().isNotEmpty) {
                                                          return RefreshIndicator(
                                                            onRefresh:
                                                                getProductionItemList,
                                                            color:
                                                                theme.lightModeColor.prColor300,
                                                            backgroundColor:
                                                                Colors.white,
                                                            displacement:
                                                                10,
                                                            child: ListView.builder(
                                                              itemCount:
                                                                  filterProductionItems().length,
                                                              itemBuilder: (
                                                                context,
                                                                index,
                                                              ) {
                                                                List<
                                                                  ProductionItem
                                                                >
                                                                productionItems =
                                                                    filterProductionItems();

                                                                ProductionItem productionItem =
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
                                                                    if (returnProductionItemsProvider().isSelectProductionItems) {
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
                                                                      ).then(
                                                                        (
                                                                          _,
                                                                        ) {
                                                                          if (context.mounted) {
                                                                            setState(
                                                                              () {},
                                                                            );
                                                                          }
                                                                        },
                                                                      );
                                                                    }
                                                                  },
                                                                  longPress: () {
                                                                    returnProductionItemsProvider().toggleIsSelectProductionItem(
                                                                      true,
                                                                    );
                                                                    setState(
                                                                      () {
                                                                        filterIndex =
                                                                            0;
                                                                      },
                                                                    );
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
                                                            padding: const EdgeInsets.only(
                                                              bottom:
                                                                  30.0,
                                                            ),
                                                            child: EmptyWidgetDisplayOnly(
                                                              title:
                                                                  'Empty List',
                                                              subText:
                                                                  'You Don\'t have any Item under this category',

                                                              icon:
                                                                  Icons.dangerous_outlined,
                                                              theme:
                                                                  theme,
                                                              height:
                                                                  40,
                                                            ),
                                                          );
                                                        }
                                                      } else {
                                                        if (categoryFilterProductionItems().isNotEmpty) {
                                                          return RefreshIndicator(
                                                            onRefresh:
                                                                getProductionItemList,
                                                            color:
                                                                theme.lightModeColor.prColor300,
                                                            backgroundColor:
                                                                Colors.white,
                                                            displacement:
                                                                10,
                                                            child: ListView.builder(
                                                              itemCount:
                                                                  categoryFilterProductionItems().length,
                                                              itemBuilder: (
                                                                context,
                                                                index,
                                                              ) {
                                                                List<
                                                                  ProductionItem
                                                                >
                                                                productionItems =
                                                                    categoryFilterProductionItems();

                                                                ProductionItem productionItem =
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
                                                                    if (returnProductionItemsProvider().isSelectProductionItems) {
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
                                                                      ).then(
                                                                        (
                                                                          _,
                                                                        ) {
                                                                          if (context.mounted) {
                                                                            setState(
                                                                              () {},
                                                                            );
                                                                          }
                                                                        },
                                                                      );
                                                                    }
                                                                  },
                                                                  longPress: () {
                                                                    returnProductionItemsProvider().toggleIsSelectProductionItem(
                                                                      true,
                                                                    );
                                                                    setState(
                                                                      () {
                                                                        filterIndex =
                                                                            0;
                                                                      },
                                                                    );
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
                                                            padding: const EdgeInsets.only(
                                                              bottom:
                                                                  30.0,
                                                            ),
                                                            child: EmptyWidgetDisplayOnly(
                                                              title:
                                                                  'Empty List',
                                                              subText:
                                                                  'You Don\'t have any Item under this category',

                                                              icon:
                                                                  Icons.dangerous_outlined,
                                                              theme:
                                                                  theme,
                                                              height:
                                                                  40,
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
                    ),
                    Visibility(
                      visible: isDeleteLoading,
                      child: Container(
                        margin: EdgeInsets.symmetric(
                          vertical: 15,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(40),
                        ),
                        child: returnCompProvider(
                          context,
                        ).showLoader(message: 'Loading'),
                      ),
                    ),
                  ],
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
              // RightSideBar(theme: theme),
            ],
          ),
          Visibility(
            visible: isLoading,
            child: returnCompProvider(
              context,
            ).showLoader(message: 'Logging Out...'),
          ),
        ],
      ),
    );
  }

  Future<void> getProductionItemList() async {
    await returnProductionItemsProvider()
        .getProductionItems();
  }
}

void duplicateProductionItemsAction({
  required BuildContext context,
  required Function(bool value) loadingAction,
}) {
  var theme = returnTheme(context, listen: false);
  if (returnProductionItemsProvider()
      .selectedProductionItems
      .isNotEmpty) {
    showDialog(
      context: context,
      builder: (firstContext) {
        return DialogTemplate(
          theme: theme,
          message: 'Select the action you want to Perform',
          title: 'Select',
          action: () {},
          showBottomActionButtons: false,
          widget: Column(
            spacing: 5,
            children: [
              MainButtonTransparent(
                themeProvider: theme,
                constraints: BoxConstraints(),
                text: 'Create Copy',
                action: () {
                  showDialog(
                    context: context,
                    builder: (confirmContext) {
                      return ConfirmationAlert(
                        theme: theme,
                        message:
                            'You are about to Duplicate all the selected Items. Please not that this action can not be reversed. Are you sure you want to proceed?',
                        title: 'Duplicate Selected Items',
                        action: () async {
                          Navigator.of(
                            confirmContext,
                          ).pop();
                          Navigator.of(firstContext).pop();
                          loadingAction(true);
                          var res =
                              await returnProductionItemsProvider()
                                  .duplicateSelectedProductionItems();
                          if (res == 0) {
                            loadingAction(false);
                            showDialog(
                              // ignore: use_build_context_synchronously
                              context: context,
                              builder: (context) {
                                return InfoAlert(
                                  theme: theme,
                                  message:
                                      'An error occoured while Duplicating selected Items. Please try again.',
                                  title: 'An Error Occured',
                                );
                              },
                            );
                          } else {
                            loadingAction(false);
                          }
                        },
                      );
                    },
                  );
                },
              ),
              Visibility(
                visible:
                    returnShopProvider().userShops.length >
                    1,
                child: MainButtonTransparent(
                  themeProvider: theme,
                  constraints: BoxConstraints(),
                  text: 'Copy To Store Branch(s)',
                  action: () {
                    bool isOnline =
                        returnConnectivityProvider()
                            .isConnected;
                    if (!isOnline) {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return InfoAlert(
                            theme: theme,
                            message:
                                'You Can Only Copy Production Items Into Other Stores When you have Internet Connection. Please turn on your internet connection and try again.',
                            title: 'No Internet Connection',
                          );
                        },
                      );
                    } else {
                      selectShopsProductionItems(
                        context: context,
                        loadingAction: (value) {
                          loadingAction(value);
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

void selectShopsProductionItems({
  required BuildContext context,
  required Function(bool value) loadingAction,
}) {
  var theme = returnTheme(context, listen: false);
  showDialog(
    context: context,
    builder: (firstContext) {
      return StatefulBuilder(
        builder: (secondContext, setState) {
          return DialogTemplate(
            theme: theme,
            message: 'Select Shops(s) From the List Below',
            title: 'Select Shops(s)',
            cancelAction: () {
              Navigator.of(context).pop();
              returnShopProvider()
                  .clearMulitpleSelectedShops();
            },
            action: () {
              showDialog(
                context: context,
                builder: (confirmContext) {
                  return ConfirmationAlert(
                    theme: theme,
                    message:
                        'You are about to Copy all the selected Production Items Into these Selected Shops. Please note that this action can not be reversed. Are you sure you want to proceed?',
                    title: 'Copy Items Into Shops',
                    action: () async {
                      loadingAction(true);
                      Navigator.of(secondContext).pop();
                      Navigator.of(firstContext).pop();
                      Navigator.of(confirmContext).pop();
                      var res =
                          await returnProductionItemsProvider()
                              .duplicateSelectedProductionItemsForShops();
                      if (res == 0) {
                        loadingAction(false);
                        showDialog(
                          // ignore: use_build_context_synchronously
                          context: context,
                          builder: (context) {
                            return InfoAlert(
                              theme: theme,
                              message:
                                  'An error occoured while Duplicating selected Production Items. Please try again.',
                              title: 'An Error Occured',
                            );
                          },
                        );
                      } else {
                        loadingAction(false);
                      }
                    },
                  );
                },
              );
            },
            widget: SizedBox(
              height: screenHeight(context) - 300,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 15,
                  ),
                  child: Builder(
                    builder: (context) {
                      if (returnShopProvider().userShops
                          .where(
                            (shop) =>
                                shop.shopId !=
                                returnShopProvider()
                                    .userShop()
                                    ?.shopId,
                          )
                          .isEmpty) {
                        return SizedBox(
                          height: 400,
                          child: EmptyWidgetDisplayOnly(
                            title: 'No Shop Found',
                            subText:
                                'No Shop Branches Was Found.',
                            theme: theme,
                            height: 30,
                            altAction: () async {
                              await returnShopProvider()
                                  .getUserShops();
                              setState(() {});
                            },
                            altActionText: 'Refresh',
                            icon: Icons.clear,
                          ),
                        );
                      } else {
                        return Column(
                          spacing: 5,
                          children:
                              returnShopProvider(
                                    context: context,
                                  ).userShops
                                  .where(
                                    (shop) =>
                                        shop.shopId !=
                                        returnShopProvider()
                                            .userShop()
                                            ?.shopId,
                                  )
                                  .map(
                                    (shop) => Material(
                                      color:
                                          Colors
                                              .transparent,
                                      child: InkWell(
                                        mouseCursor:
                                            SystemMouseCursors
                                                .click,
                                        onTap: () {
                                          returnShopProvider()
                                              .selectMultipleShop(
                                                shop,
                                              );
                                        },
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.symmetric(
                                                vertical:
                                                    9.0,
                                                horizontal:
                                                    12,
                                              ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment
                                                    .spaceBetween,
                                            children: [
                                              Text(
                                                style: TextStyle(
                                                  fontSize:
                                                      theme
                                                          .mobileTexts
                                                          .b3
                                                          .fontSize,
                                                  fontWeight:
                                                      FontWeight
                                                          .bold,
                                                ),
                                                shop.name,
                                              ),
                                              Container(
                                                padding:
                                                    EdgeInsets.all(
                                                      2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  shape:
                                                      BoxShape
                                                          .circle,
                                                  border: Border.all(
                                                    color:
                                                        Colors.grey,
                                                  ),
                                                ),
                                                child: Container(
                                                  padding:
                                                      EdgeInsets.all(
                                                        5,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    shape:
                                                        BoxShape.circle,
                                                    color:
                                                        returnShopProvider().multipleSelectedShops.contains(shop)
                                                            ? theme.lightModeColor.prColor250
                                                            : Colors.transparent,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                        );
                      }
                    },
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

class ProductionItemSelectionActionButton
    extends StatelessWidget {
  const ProductionItemSelectionActionButton({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    this.action,
  });
  final String title;
  final IconData icon;
  final Function()? action;
  final Color color;

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3.0),
      child: InkWell(
        mouseCursor: SystemMouseCursors.click,
        onTap: action,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal:
                screenWidth(context) < mobileScreen
                    ? 6
                    : 10,
            vertical: 5,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: Colors.grey.shade400),
          ),
          child: Row(
            spacing:
                screenWidth(context) < mobileScreen ? 3 : 5,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                style: TextStyle(
                  fontSize: theme.mobileTexts.b4.fontSize,
                  fontWeight: FontWeight.bold,
                ),
                title,
              ),
              Icon(
                size:
                    screenWidth(context) < mobileScreen
                        ? 14
                        : 16,
                color: color,
                icon,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
