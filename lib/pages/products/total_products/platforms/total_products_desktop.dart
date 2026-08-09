import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
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
import 'package:stockall/constants/refresh_functions.dart';
import 'package:stockall/constants/subscription/general_settings_auth.dart';
import 'package:stockall/constants/subscription/items_auth.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/products/add_product_one/add_product.dart';
import 'package:stockall/pages/products/compnents/product_filter_button.dart';
import 'package:stockall/pages/products/compnents/product_filter_button_category.dart';
import 'package:stockall/pages/products/compnents/product_tile_main.dart';
import 'package:stockall/pages/products/item_history_page/item_history_page.dart';
import 'package:stockall/pages/products/product_details/product_details_page.dart';
import 'package:stockall/providers/theme_provider.dart';

class TotalProductsDesktop extends StatefulWidget {
  const TotalProductsDesktop({
    super.key,
    required this.theme,
    this.categoryUuid,
  });

  final ThemeProvider theme;
  final String? categoryUuid;

  @override
  State<TotalProductsDesktop> createState() =>
      _TotalProductsDesktopState();
}

class _TotalProductsDesktopState
    extends State<TotalProductsDesktop> {
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

  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();
  int filterIndex = 0;
  String? categoryUuid;

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    var products =
        searchController.text.isNotEmpty
            ? returnData()
                .productList()
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
            : widget.categoryUuid != null
            ? returnData()
                .productList()
                .where(
                  (pr) =>
                      pr.categories?.contains(
                        widget.categoryUuid,
                      ) ==
                      true,
                )
                .toList()
            : returnData().productList();
    List<TempProductClass> filterProducts() {
      switch (currentSelect) {
        case 1:
          return products
              .where(
                (p) =>
                    p.quantity != 0 && p.quantity != null,
              )
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
              .where((p) => !p.isManaged)
              .toList();
        case 5:
          return products
              .where((p) => p.departmentUuid == null)
              .toList();
        case 0:
        default:
          return products;
      }
    }

    List<TempProductClass> categoryFilterProducts() {
      if (categoryUuid != null) {
        return products
            .where(
              (pr) =>
                  pr.categories?.contains(categoryUuid) ==
                  true,
            )
            .toList();
      }
      return products;
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
                                    await getProductList();
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
                              Visibility(
                                visible:
                                    widget.categoryUuid ==
                                            null
                                        ? true
                                        : false,
                                child: PopupMenuButton(
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
                                                    !returnData()
                                                        .isSelectProducts,
                                                child: Icon(
                                                  size: 17,
                                                  color:
                                                      Colors
                                                          .grey
                                                          .shade700,
                                                  Icons
                                                      .check,
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
                                                  Icons
                                                      .check,
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
                                                return ItemHistoryPage(
                                                  fromItemDetails:
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
                                                ),
                                                'View History',
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
                                                  Icons
                                                      .clear,
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
                                      Icons
                                          .more_vert_rounded,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        floatingActionButton: Visibility(
                          visible:
                              authorization(
                                authorized:
                                    Authorizations()
                                        .addProduct,
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
                            color:
                                theme
                                    .lightModeColor
                                    .secColor100,
                            text: 'Add Products',
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
                                        if (products
                                            .isEmpty) {
                                          return Center(
                                            child: SingleChildScrollView(
                                              child: RefreshIndicator(
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
                                                child: EmptyWidgetDisplay(
                                                  buttonText:
                                                      'Add Item',
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
                                                  svg:
                                                      productIconSvg,
                                                  height:
                                                      35,
                                                  action:
                                                      widget.categoryUuid !=
                                                              null
                                                          ? () {
                                                            if (authorization(
                                                              authorized:
                                                                  Authorizations().addProduct,
                                                            )) {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder: (
                                                                    context,
                                                                  ) {
                                                                    return AddProduct();
                                                                  },
                                                                ),
                                                              ).then(
                                                                (
                                                                  _,
                                                                ) {
                                                                  if (context.mounted) {}
                                                                },
                                                              );
                                                            }
                                                          }
                                                          : () {},
                                                  theme:
                                                      widget
                                                          .theme,
                                                  altAction: () async {
                                                    await returnData().getProducts(
                                                      shopId(),
                                                    );
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
                                                Visibility(
                                                  visible:
                                                      widget
                                                          .categoryUuid ==
                                                      null,
                                                  child: Padding(
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
                                                          if (returnData().isSelectProducts) {
                                                            return Row(
                                                              // spacing:
                                                              //     5,
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
                                                                                'You are about to delete all the selected items. Please note that this action can not be reversed. Are you sure you want to proceed?',
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
                                                                    duplicateItemsAction(
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
                                                                                filterProducts().length,
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
                                                                                filterProducts().length,
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
                                                                            length:
                                                                                filterProducts().length,
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
                                                                            length:
                                                                                filterProducts().length,
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
                                                                                filterProducts().length,
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
                                                                                  filterProducts().length,
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
                                                                          filterProducts().length,
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
                                                                          filterProducts().length,
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
                                                                      length:
                                                                          filterProducts().length,
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
                                                                      length:
                                                                          filterProducts().length,
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
                                                                          filterProducts().length,
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
                                                                            filterProducts().length,
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
                                                        if (filterProducts().isNotEmpty) {
                                                          return RefreshIndicator(
                                                            onRefresh:
                                                                getProductList,
                                                            color:
                                                                theme.lightModeColor.prColor300,
                                                            backgroundColor:
                                                                Colors.white,
                                                            displacement:
                                                                10,
                                                            child: ListView.builder(
                                                              itemCount:
                                                                  filterProducts().length,
                                                              itemBuilder: (
                                                                context,
                                                                index,
                                                              ) {
                                                                List<
                                                                  TempProductClass
                                                                >
                                                                products =
                                                                    filterProducts();

                                                                TempProductClass product =
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
                                                                    if (returnData().isSelectProducts) {
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
                                                                    returnData().toggleIsSelectProduct(
                                                                      true,
                                                                    );
                                                                    setState(
                                                                      () {
                                                                        filterIndex =
                                                                            0;
                                                                      },
                                                                    );
                                                                    returnData().selectProduct(
                                                                      product,
                                                                    );
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
                                                            padding: const EdgeInsets.only(
                                                              bottom:
                                                                  30.0,
                                                            ),
                                                            child: EmptyWidgetDisplayOnly(
                                                              title:
                                                                  'Empty List',
                                                              subText:
                                                                  'You Don\'t have any item under this category',

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
                                                        if (categoryFilterProducts().isNotEmpty) {
                                                          return RefreshIndicator(
                                                            onRefresh:
                                                                getProductList,
                                                            color:
                                                                theme.lightModeColor.prColor300,
                                                            backgroundColor:
                                                                Colors.white,
                                                            displacement:
                                                                10,
                                                            child: ListView.builder(
                                                              itemCount:
                                                                  categoryFilterProducts().length,
                                                              itemBuilder: (
                                                                context,
                                                                index,
                                                              ) {
                                                                List<
                                                                  TempProductClass
                                                                >
                                                                products =
                                                                    categoryFilterProducts();

                                                                TempProductClass product =
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
                                                                    if (returnData().isSelectProducts) {
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
                                                                    returnData().toggleIsSelectProduct(
                                                                      true,
                                                                    );
                                                                    setState(
                                                                      () {
                                                                        filterIndex =
                                                                            0;
                                                                      },
                                                                    );
                                                                    returnData().selectProduct(
                                                                      product,
                                                                    );
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
                                                            padding: const EdgeInsets.only(
                                                              bottom:
                                                                  30.0,
                                                            ),
                                                            child: EmptyWidgetDisplayOnly(
                                                              title:
                                                                  'Empty List',
                                                              subText:
                                                                  'You Don\'t have any item under this category',

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
}

void duplicateItemsAction({
  required BuildContext context,
  required Function(bool value) loadingAction,
}) {
  var theme = returnTheme(context, listen: false);
  if (returnData().selectedProducts.isNotEmpty) {
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
                            'You are about to Duplicate all the selected items. Please not that this action can not be reversed. Are you sure you want to proceed?',
                        title: 'Duplicate Selected Items',
                        action: () async {
                          Navigator.of(
                            confirmContext,
                          ).pop();
                          Navigator.of(firstContext).pop();
                          loadingAction(true);
                          var res =
                              await returnData()
                                  .duplicateSelectedProducts();
                          if (res == 0) {
                            loadingAction(false);
                            showDialog(
                              // ignore: use_build_context_synchronously
                              context: context,
                              builder: (context) {
                                return InfoAlert(
                                  theme: theme,
                                  message:
                                      'An error occoured while Duplicating selected products. Please try again.',
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
                    returnShopProvider()
                        .userShop()
                        ?.manageDepartments ==
                    true,
                child: MainButtonTransparent(
                  themeProvider: theme,
                  constraints: BoxConstraints(),
                  text: 'Copy To Department(s)',
                  action: () {
                    selectDepartmentProducts(
                      context: context,
                      loadingAction: (value) {
                        loadingAction(value);
                      },
                    );
                  },
                ),
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
                                'You Can Only Copy Items Into Other Stores When you have Internet Connection. Please turn on your internet connection and try again.',
                            title: 'No Internet Connection',
                          );
                        },
                      );
                    } else {
                      selectShopsProducts(
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

void selectDepartmentProducts({
  required BuildContext context,
  required Function(bool value) loadingAction,
}) {
  var theme = returnTheme(context, listen: false);
  GeneralSettingsAuthAction().manageDeparmtmentsAction(
    context: context,
    action: () {
      showDialog(
        context: context,
        builder: (firstContext) {
          return StatefulBuilder(
            builder: (secondContext, setState) {
              return DialogTemplate(
                theme: theme,
                message:
                    'Select Department(s) From the List Below',
                title: 'Select Department(s)',
                action: () {
                  showDialog(
                    context: context,
                    builder: (confirmContext) {
                      return ConfirmationAlert(
                        theme: theme,
                        message:
                            'You are about to Copy all the selected items Into these Selected Departments. Please note that this action can not be reversed. Are you sure you want to proceed?',
                        title:
                            'Copy Items Into Departments',
                        action: () async {
                          loadingAction(true);
                          var res =
                              await returnData()
                                  .duplicateSelectedProductsForDepartments();
                          Navigator.of(
                            // ignore: use_build_context_synchronously
                            secondContext,
                          ).pop();
                          // ignore: use_build_context_synchronously
                          Navigator.of(firstContext).pop();
                          Navigator.of(
                            // ignore: use_build_context_synchronously
                            confirmContext,
                          ).pop();
                          if (res == 0) {
                            loadingAction(false);
                            showDialog(
                              // ignore: use_build_context_synchronously
                              context: context,
                              builder: (context) {
                                return InfoAlert(
                                  theme: theme,
                                  message:
                                      'An error occoured while Duplicating selected products. Please try again.',
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
                          if (returnDepartmentProvider()
                              .departments
                              .where(
                                (dept) =>
                                    dept.uuid !=
                                    returnDepartmentProvider()
                                        .currentDepartment()
                                        ?.uuid,
                              )
                              .isEmpty) {
                            return SizedBox(
                              height: 400,
                              child: EmptyWidgetDisplayOnly(
                                title:
                                    'No Department Found',
                                subText:
                                    'You have not been added to any departments.',
                                theme: theme,
                                height: 30,
                                altAction: () async {
                                  await returnDepartmentProvider()
                                      .getDepartments();
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
                                  returnDepartmentProvider(
                                        context: context,
                                      ).departments
                                      .where(
                                        (dept) =>
                                            dept.uuid !=
                                            returnDepartmentProvider()
                                                .currentDepartment()
                                                ?.uuid,
                                      )
                                      .map(
                                        (dept) => Material(
                                          color:
                                              Colors
                                                  .transparent,
                                          child: InkWell(
                                            mouseCursor:
                                                SystemMouseCursors
                                                    .click,
                                            onTap: () {
                                              returnDepartmentProvider()
                                                  .selectMultipleDepartments(
                                                    dept,
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
                                                          theme.mobileTexts.b3.fontSize,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    dept.name,
                                                  ),
                                                  Container(
                                                    padding:
                                                        EdgeInsets.all(
                                                          2,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      shape:
                                                          BoxShape.circle,
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
                                                            returnDepartmentProvider().multipleSelectedDepartments.contains(
                                                                  dept,
                                                                )
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
      ).then((_) {
        returnDepartmentProvider()
            .clearMulitpleSelectedDepartments();
      });
    },
  );
}

void selectShopsProducts({
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
                        'You are about to Copy all the selected items Into these Selected Shops. Please note that this action can not be reversed. Are you sure you want to proceed?',
                    title: 'Copy Items Into Shops',
                    action: () async {
                      loadingAction(true);
                      Navigator.of(secondContext).pop();
                      Navigator.of(firstContext).pop();
                      Navigator.of(confirmContext).pop();
                      var res =
                          await returnData()
                              .duplicateSelectedProductsForShops();
                      if (res == 0) {
                        loadingAction(false);
                        showDialog(
                          // ignore: use_build_context_synchronously
                          context: context,
                          builder: (context) {
                            return InfoAlert(
                              theme: theme,
                              message:
                                  'An error occoured while Duplicating selected products. Please try again.',
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

class ProductSelectionActionButton extends StatelessWidget {
  const ProductSelectionActionButton({
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
