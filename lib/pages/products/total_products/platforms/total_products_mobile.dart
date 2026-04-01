import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/buttons/floating_action_butto.dart';
import 'package:stockall/components/major/empty_widget_display.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/components/text_fields/text_field_barcode.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/refresh_functions.dart';
import 'package:stockall/constants/scan_barcode.dart';
import 'package:stockall/constants/subscription/items_auth.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/products/add_product_one/add_product.dart';
import 'package:stockall/pages/products/compnents/product_filter_button.dart';
import 'package:stockall/pages/products/compnents/product_filter_button_category.dart';
import 'package:stockall/pages/products/compnents/product_tile_main.dart';
import 'package:stockall/pages/products/product_details/product_details_page.dart';
import 'package:stockall/pages/products/total_products/platforms/total_products_desktop.dart';
import 'package:stockall/providers/theme_provider.dart';

class TotalProductsMobile extends StatefulWidget {
  const TotalProductsMobile({
    super.key,
    required this.theme,
    this.categoryUuid,
  });

  final ThemeProvider theme;
  final String? categoryUuid;

  @override
  State<TotalProductsMobile> createState() =>
      _TotalProductsMobileState();
}

class _TotalProductsMobileState
    extends State<TotalProductsMobile> {
  int currentSelect = 0;
  void changeSelected(int number) {
    currentSelect = number;
  }

  void clearState() {
    setState(() {
      // searchResult = null;
      searchController.clear();
      // productsResult.clear();
    });
  }

  // List<TempProductClass> productsResult = [];
  // String? searchResult;
  bool isFocus = false;
  TextEditingController searchController =
      TextEditingController();

  // late Future<List<TempProductClass>> _productsFuture;
  @override
  void initState() {
    super.initState();
    returnData().toggleFloatingAction(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (returnCategoriesProvider()
          .categories()
          .isNotEmpty) {
        setState(() {
          categoryUuid =
              returnCategoriesProvider()
                  .categories()
                  .first
                  .uuid;
        });
      }
    });
  }

  int filterIndex = 0;
  String? categoryUuid;
  bool isDeleteLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<void> getProductList() async {
    await RefreshFunctions(
      context,
    ).refreshProducts(context);
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      returnData().toggleIsSelectProduct(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    var products =
        searchController.text.isNotEmpty
            ? returnData()
                .productList()
                .where(
                  (pr) => pr.name.toLowerCase().contains(
                    searchController.text.toLowerCase(),
                  ),
                )
                .toList()
            : widget.categoryUuid != null
            ? returnData()
                .productList()
                .where(
                  (pr) =>
                      pr.categoryUuid ==
                      widget.categoryUuid,
                )
                .toList()
            : returnData().productList();
    List<TempProductClass> filterProducts() {
      switch (currentSelect) {
        case 1:
          return products
              .where((p) => p.quantity != 0)
              .toList();
        case 2:
          return products
              .where(
                (p) =>
                    p.quantity != null &&
                    p.quantity! <= p.lowQtty! &&
                    p.quantity != 0,
              )
              .toList();
        case 3:
          return products
              .where((p) => p.quantity == 0)
              .toList();
        case 4:
          return products
              .where((p) => p.quantity == null)
              .toList();
        case 0:
        default:
          return products;
      }
    }

    List<TempProductClass> categoryFilterProducts() {
      if (categoryUuid != null) {
        return products
            .where((pr) => pr.categoryUuid == categoryUuid)
            .toList();
      }
      return products;
    }

    return Stack(
      children: [
        Scaffold(
          appBar: appBar(
            context: context,
            title: 'All Items',
            widget:
                widget.categoryUuid != null
                    ? null
                    : PopupMenuButton(
                      offset: Offset(-20, 30),
                      color: Colors.white,
                      itemBuilder: (context) {
                        return [
                          PopupMenuItem(
                            onTap: () {
                              setState(() {
                                filterIndex = 0;
                              });
                              returnData()
                                  .toggleIsSelectProduct(
                                    false,
                                  );
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(
                                    horizontal: 10.0,
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
                                          filterIndex == 0
                                              ? FontWeight
                                                  .bold
                                              : null,
                                    ),
                                    'Inventory Record',
                                  ),
                                  Visibility(
                                    visible:
                                        filterIndex == 0 &&
                                        !returnData()
                                            .isSelectProducts,
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
                              returnData()
                                  .toggleIsSelectProduct(
                                    false,
                                  );
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(
                                    horizontal: 10.0,
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
                                          filterIndex == 1
                                              ? FontWeight
                                                  .bold
                                              : null,
                                    ),
                                    'Categories',
                                  ),
                                  Visibility(
                                    visible:
                                        filterIndex == 1,
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
                              if (returnData()
                                  .isSelectProducts) {
                                returnData()
                                    .toggleIsSelectProduct(
                                      false,
                                    );
                              } else {
                                returnData()
                                    .toggleIsSelectProduct(
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
                                              ? FontWeight
                                                  .bold
                                              : null,
                                    ),
                                    returnData()
                                            .isSelectProducts
                                        ? 'Cancel'
                                        : 'Select Items',
                                  ),
                                  Visibility(
                                    visible:
                                        returnData()
                                            .isSelectProducts,
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
                      child: Padding(
                        padding: const EdgeInsets.only(
                          right: 10.0,
                        ),
                        child: Container(
                          padding: EdgeInsets.all(5),
                          child: Row(
                            spacing: 4,
                            children: [
                              Text(
                                style: TextStyle(
                                  fontSize:
                                      theme
                                          .mobileTexts
                                          .b3
                                          .fontSize,
                                  fontWeight:
                                      FontWeight.bold,
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
            visible:
                authorization(
                  authorized: Authorizations().addProduct,
                ) &&
                widget.categoryUuid == null,
            child: FloatingActionButtonMain(
              action: () {
                ItemsAuthAction().numberOfItemsAction(
                  context: context,
                  action: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return AddProduct();
                        },
                      ),
                    ).then((_) {
                      setState(() {
                        // getProductList(context);
                      });
                    });
                  },
                );
              },
              color: theme.lightModeColor.secColor100,
              text: 'Add Products',
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
                          if (products
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
                        ItemsAuthAction().useOfBArcodeAction(
                          context: context,
                          action: () async {
                            String? result = await scanCode(
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
                            // if (!context.mounted) return;
                            // setState(() {
                            //   productsResult =
                            //       products
                            //           .where(
                            //             (product) =>
                            //                 product.barcode ==
                            //                 result,
                            //           )
                            //           .toList();
                            // });
                          },
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: SizedBox(
                      child: Builder(
                        builder: (context) {
                          if (products.isEmpty) {
                            return Center(
                              child: SingleChildScrollView(
                                child: RefreshIndicator(
                                  onRefresh: getProductList,
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
                                        widget.categoryUuid ==
                                                null
                                            ? 'Click on the button below to start adding Items to your store.'
                                            : 'Go to your Items Page to add items to your store.',
                                    title:
                                        widget.categoryUuid ==
                                                null
                                            ? 'You have not Item Under this Category'
                                            : 'You have no Items Yet',
                                    svg: productIconSvg,
                                    height: 35,
                                    action:
                                        widget.categoryUuid !=
                                                null
                                            ? () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (
                                                    context,
                                                  ) {
                                                    return AddProduct();
                                                  },
                                                ),
                                              ).then((_) {
                                                if (context
                                                    .mounted) {}
                                              });
                                            }
                                            : () {},
                                    theme: widget.theme,
                                    altAction: () async {
                                      await returnData()
                                          .getProducts(
                                            shopId(),
                                          );
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
                                  Visibility(
                                    visible:
                                        widget
                                            .categoryUuid ==
                                        null,
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.symmetric(
                                            horizontal:
                                                10.0,
                                          ),
                                      child: SizedBox(
                                        width:
                                            double.infinity,
                                        // height: 40,
                                        child: Builder(
                                          builder: (
                                            context,
                                          ) {
                                            if (returnData()
                                                .isSelectProducts) {
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
                                                        ProductSelectionActionButton(
                                                          title:
                                                              'Delete',
                                                          action: () {
                                                            if (returnData().selectedProducts.isNotEmpty) {
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
                                                                        'You are about to delete all the selected items. Please not that this action can not be reversed. Are you sure you want to proceed?',
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
                                                                          await returnData().deleteSelectedProducts();
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
                                                                                  'An error occoured while deleting selected products. Please try again.',
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
                                                                        // returnData().toggleIsSelectProduct(
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
                                                        ProductSelectionActionButton(
                                                          title:
                                                              'Duplicate',
                                                          action: () {
                                                            if (returnData().selectedProducts.isNotEmpty) {
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
                                                                        'You are about to Duplicate all the selected items. Please not that this action can not be reversed. Are you sure you want to proceed?',
                                                                    title:
                                                                        'Duplicate Selected Items',
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
                                                                          await returnData().duplicateSelectedProducts();
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
                                                                                  'An error occoured while Duplicating selected products. Please try again.',
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
                                                                      }
                                                                    },
                                                                  );
                                                                },
                                                              );
                                                            }
                                                          },
                                                          icon:
                                                              Icons.control_point_duplicate_rounded,
                                                          color:
                                                              Colors.grey,
                                                        ),
                                                        Visibility(
                                                          visible:
                                                              shop(
                                                                context,
                                                              )?.manageInventoryStorage ==
                                                              true,
                                                          child: ProductSelectionActionButton(
                                                            title:
                                                                'Generate Storage',
                                                            action: () {
                                                              if (returnData().selectedProducts.isNotEmpty) {
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
                                                                          'You are about to Generate The Storage Product equivalent for each of the selected items. This Generated item in the storage will be used to manage this selected items storage quantity. Are you sure you want to proceed?',
                                                                      title:
                                                                          'Generate Selected Items',
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
                                                                            await returnData().generateStorageSelectedProducts();
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
                                                                                    'An error occoured while Generating selected products. Please try again.',
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
                                                                        }
                                                                      },
                                                                    );
                                                                  },
                                                                );
                                                              }
                                                            },
                                                            icon:
                                                                Icons.storage_rounded,
                                                            color:
                                                                Colors.grey,
                                                          ),
                                                        ),
                                                        ProductSelectionActionButton(
                                                          title:
                                                              'Cancel',
                                                          action: () {
                                                            returnData().toggleIsSelectProduct(
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
                                                        MainAxisAlignment.center,
                                                    children: [
                                                      ProductsFilterButton(
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
                                                      ProductsFilterButton(
                                                        action: () {
                                                          setState(
                                                            () {
                                                              changeSelected(
                                                                2,
                                                              );
                                                            },
                                                          );
                                                        },
                                                        currentSelected:
                                                            currentSelect,
                                                        number:
                                                            2,
                                                        title:
                                                            'Low Stock',
                                                        theme:
                                                            theme,
                                                      ),
                                                      ProductsFilterButton(
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
                                                                      categoryUuid!,
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
                                  ),
                                  SizedBox(height: 10),
                                  Expanded(
                                    child: Builder(
                                      builder: (context) {
                                        if (filterIndex ==
                                            0) {
                                          if (filterProducts()
                                              .isNotEmpty) {
                                            return RefreshIndicator(
                                              onRefresh:
                                                  getProductList,
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
                                                    filterProducts()
                                                        .length,
                                                itemBuilder: (
                                                  context,
                                                  index,
                                                ) {
                                                  List<
                                                    TempProductClass
                                                  >
                                                  products =
                                                      filterProducts();

                                                  TempProductClass
                                                  product =
                                                      products[index];

                                                  return ProductTileMain(
                                                    isSelectProduct:
                                                        returnData(
                                                          context:
                                                              context,
                                                        ).isSelectProducts,
                                                    uuidList:
                                                        returnData(
                                                              context:
                                                                  context,
                                                            ).selectedProducts
                                                            .map(
                                                              (
                                                                pr,
                                                              ) =>
                                                                  pr.uuid!,
                                                            )
                                                            .toList(),
                                                    action: () {
                                                      if (returnData()
                                                          .isSelectProducts) {
                                                        returnData().selectProduct(
                                                          product,
                                                        );
                                                      } else {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (
                                                              context,
                                                            ) {
                                                              return ProductDetailsPage(
                                                                productUuid:
                                                                    product.uuid!,
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
                                                    theme:
                                                        theme,
                                                    product:
                                                        product,
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
                                                    'You Don\'t have any item under this category',

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
                                          if (categoryFilterProducts()
                                              .isNotEmpty) {
                                            return RefreshIndicator(
                                              onRefresh:
                                                  getProductList,
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
                                                    categoryFilterProducts()
                                                        .length,
                                                itemBuilder: (
                                                  context,
                                                  index,
                                                ) {
                                                  List<
                                                    TempProductClass
                                                  >
                                                  products =
                                                      categoryFilterProducts();

                                                  TempProductClass
                                                  product =
                                                      products[index];

                                                  return ProductTileMain(
                                                    action: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (
                                                            context,
                                                          ) {
                                                            return ProductDetailsPage(
                                                              productUuid:
                                                                  product.uuid!,
                                                            );
                                                          },
                                                        ),
                                                      ).then((
                                                        _,
                                                      ) {
                                                        if (context.mounted) {
                                                          setState(
                                                            () {
                                                              // _productsFuture =
                                                              // getProductList(
                                                              //   context,
                                                              // );
                                                            },
                                                          );
                                                        }
                                                      });
                                                    },
                                                    theme:
                                                        theme,
                                                    product:
                                                        product,
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
                                                    'You Don\'t have any item under this category',

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
