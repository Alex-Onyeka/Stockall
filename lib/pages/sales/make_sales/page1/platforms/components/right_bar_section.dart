import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_cart_items/temp_cart_item.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/my_calculator_desktop.dart';
import 'package:stockall/constants/bottom_sheet_widgets.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/products/compnents/product_tile_cart_search.dart';

class RightBarSection extends StatefulWidget {
  const RightBarSection({super.key});

  @override
  State<RightBarSection> createState() =>
      _RightBarSectionState();
}

class _RightBarSectionState extends State<RightBarSection> {
  int currentIndex = 1;

  void switchCurrentIndex(int value) {
    setState(() {
      currentIndex = value;
    });
  }

  FocusNode qttyNode = FocusNode();
  FocusNode priceNode = FocusNode();

  TextEditingController quantityController =
      TextEditingController(text: '');
  TextEditingController priceController =
      TextEditingController();
  TextEditingController searchController =
      TextEditingController();

  void closeAction() {
    // setState(() {
    //   Navigator.of(context).pop();
    //   searchController.clear();
    // });
  }

  String? currentCat;

  void selectCat(String uuid) {
    setState(() {
      if (currentCat == uuid) {
        currentCat = null;
      } else {
        currentCat = uuid;
      }
    });
  }

  final ScrollController horizontalController =
      ScrollController();

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            5.0,
            20,
            5,
            10,
          ),
          child: Row(
            children: [
              ToggleButton(
                index: currentIndex,
                myIndex: 1,
                action: () {
                  switchCurrentIndex(1);
                },
              ),
              ToggleButton(
                index: currentIndex,
                myIndex: 2,
                action: () {
                  switchCurrentIndex(2);
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              Visibility(
                visible: currentIndex == 2,
                child: ListView(
                  children: [
                    SizedBox(
                      height: screenHeight(context) - 100,
                      child: MyCalculatorDesktop(
                        showHeader: false,
                      ),
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: currentIndex == 1,
                child: Column(
                  children: [
                    Visibility(
                      visible:
                          returnCategoriesProvider(
                            context: context,
                          ).categories().isNotEmpty,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          bottom: 10.0,
                        ),
                        child: Center(
                          child: Scrollbar(
                            controller:
                                horizontalController,
                            thumbVisibility: true,
                            trackVisibility: true,
                            child: Padding(
                              padding: EdgeInsets.only(
                                bottom: 15,
                              ),
                              child: SingleChildScrollView(
                                controller:
                                    horizontalController,
                                scrollDirection:
                                    Axis.horizontal,
                                child: Row(
                                  mainAxisSize:
                                      MainAxisSize.min,
                                  spacing: 3,
                                  children:
                                      returnCategoriesProvider(
                                            context:
                                                context,
                                          )
                                          .categories()
                                          .map(
                                            (
                                              item,
                                            ) => Material(
                                              type:
                                                  MaterialType
                                                      .transparency,
                                              child: Ink(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        5,
                                                      ),
                                                  color:
                                                      currentCat ==
                                                              item.uuid
                                                          ? theme.lightModeColor.tertColor200
                                                          : theme.lightModeColor.tertColor50,
                                                ),
                                                child: InkWell(
                                                  onTap: () {
                                                    selectCat(
                                                      item.uuid,
                                                    );
                                                  },
                                                  mouseCursor:
                                                      SystemMouseCursors
                                                          .click,
                                                  child: Container(
                                                    padding: EdgeInsets.symmetric(
                                                      vertical:
                                                          7,
                                                      horizontal:
                                                          10,
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        style: TextStyle(
                                                          fontSize:
                                                              theme.mobileTexts.b4.fontSize,
                                                          color:
                                                              currentCat ==
                                                                      item.uuid
                                                                  ? Colors.white
                                                                  : Colors.grey.shade600,
                                                        ),
                                                        item.name,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: 5.0,
                            ),
                            child: Row(
                              spacing: 3,
                              children: [
                                Text(
                                  style: TextStyle(
                                    fontSize:
                                        theme
                                            .mobileTexts
                                            .b4
                                            .fontSize,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                  'Items Found:',
                                ),
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
                                  returnData()
                                      .productList()
                                      .where((item) {
                                        if (currentCat ==
                                            null) {
                                          return true;
                                        } else {
                                          return item
                                                  .categories
                                                  ?.contains(
                                                    currentCat,
                                                  ) ==
                                              true;
                                        }
                                      })
                                      .length
                                      .toString(),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: ListView(
                              children:
                                  returnData()
                                      .productList()
                                      .where((item) {
                                        if (currentCat ==
                                            null) {
                                          return true;
                                        } else {
                                          return item
                                                  .categories
                                                  ?.contains(
                                                    currentCat,
                                                  ) ==
                                              true;
                                        }
                                      })
                                      .map(
                                        (
                                          product,
                                        ) => ProductTileCartSearch(
                                          theme: theme,
                                          product: product,
                                          action: () {
                                            addItemToCartFromCartItemList(
                                              closeAction:
                                                  () {},
                                              context:
                                                  context,
                                              priceController:
                                                  priceController,
                                              priceNode:
                                                  priceNode,
                                              product:
                                                  product,
                                              qttyNode:
                                                  qttyNode,
                                              quantityController:
                                                  quantityController,
                                              searchController:
                                                  searchController,
                                            );
                                          },
                                        ),
                                      )
                                      .toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

void addItemToCartFromCartItemList({
  required TempProductClass product,
  required BuildContext context,
  required FocusNode qttyNode,
  required FocusNode priceNode,
  required TextEditingController quantityController,
  required TextEditingController searchController,
  required Function() closeAction,
  required TextEditingController priceController,
}) {
  var theme = returnTheme(context, listen: false);
  TempCartItem? cartItemTemp;
  var items = returnSalesProvider()
      .currentCart()
      .cartItems
      .where(
        (item) =>
            (item.itemUuid ?? item.item.uuid) ==
            product.uuid,
      );
  if (items.isNotEmpty) {
    cartItemTemp = items.first;
  }

  if (!product.canSelectForCart()) {
    showDialog(
      context: context,
      builder: (context) {
        var theme = returnTheme(context, listen: false);
        return InfoAlert(
          theme: theme,
          message:
              'Item Quantity is Zero, Therefore, this item cannot be sold',
          title: 'Item out of Stock',
        );
      },
    );
  } else if (product.isExpired()) {
    showDialog(
      context: context,
      builder: (context) {
        var theme = returnTheme(context, listen: false);
        return InfoAlert(
          theme: theme,
          message:
              'This Item is Already Expired,therefore cannot be sold',
          title: 'Item Expired',
        );
      },
    );
  } else {
    selectProductSales(
      isEdit: false,
      context: context,
      qttyNode: qttyNode,
      priceNode: priceNode,
      quantityController: quantityController,
      searchController: searchController,
      theme: theme,
      cartItem: TempCartItem(
        uuid: cartItemTemp?.uuid ?? uuidGen(),
        itemUuid: product.uuid,
        isVoid: false,
        qttyPerGroup:
            cartItemTemp?.qttyPerGroup ??
            product.qttyPerGroup,
        useGroupQuantity:
            cartItemTemp?.useGroupQuantity ?? false,
        setTotalPrice: returnSalesProvider().setTotalPrice,
        useWholeSalePrice:
            cartItemTemp?.useWholeSalePrice ?? false,
        addToStock: false,
        discount: product.discount,
        item: product,
        quantity:
            cartItemTemp?.quantity ??
            double.tryParse(
              quantityController.text
                  .replaceAll(',', '')
                  .trim(),
            ) ??
            0.0,
      ),
      closeAction: closeAction,
      priceController: priceController,
    );
  }

  // if (!product.isManaged) {
  //   if (returnSalesProvider()
  //       .currentCart()
  //       .cartItems
  //       .where(
  //         (item) =>
  //             (item.itemUuid ?? item.item.uuid) ==
  //             product.uuid,
  //       )
  //       .isNotEmpty) {
  //     selectProductSales(
  //       isEdit: false,
  //       context: context,
  //       qttyNode: qttyNode,
  //       priceNode: priceNode,
  //       quantityController: quantityController,
  //       searchController: searchController,
  //       theme: theme,
  //       cartItem: TempCartItem(
  //         uuid:
  //             returnSalesProvider()
  //                 .currentCart()
  //                 .cartItems
  //                 .firstWhere(
  //                   (item) =>
  //                       (item.itemUuid ?? item.item.uuid) ==
  //                       product.uuid!,
  //                 )
  //                 .uuid,
  //         itemUuid: product.uuid,
  //         isVoid: false,
  //         qttyPerGroup:
  //             returnSalesProvider()
  //                 .currentCart()
  //                 .cartItems
  //                 .firstWhere(
  //                   (item) =>
  //                       (item.itemUuid ?? item.item.uuid) ==
  //                       product.uuid!,
  //                 )
  //                 .qttyPerGroup,
  //         useGroupQuantity:
  //             returnSalesProvider()
  //                 .currentCart()
  //                 .cartItems
  //                 .firstWhere(
  //                   (item) =>
  //                       (item.itemUuid ?? item.item.uuid) ==
  //                       product.uuid!,
  //                 )
  //                 .useGroupQuantity,
  //         setTotalPrice:
  //             returnSalesProvider().setTotalPrice,
  //         useWholeSalePrice:
  //             returnSalesProvider()
  //                 .currentCart()
  //                 .cartItems
  //                 .firstWhere(
  //                   (item) =>
  //                       (item.itemUuid ?? item.item.uuid) ==
  //                       product.uuid!,
  //                 )
  //                 .useWholeSalePrice,
  //         addToStock: false,
  //         discount: product.discount,
  //         item: product,
  //         quantity:
  //             returnSalesProvider()
  //                 .currentCart()
  //                 .cartItems
  //                 .firstWhere(
  //                   (item) =>
  //                       (item.itemUuid ?? item.item.uuid) ==
  //                       product.uuid!,
  //                 )
  //                 .quantity,
  //       ),
  //       closeAction: closeAction,
  //       priceController: priceController,
  //     );
  //   } else {
  //     selectProductSales(
  //       isEdit: false,
  //       context: context,
  //       qttyNode: qttyNode,
  //       priceNode: priceNode,
  //       quantityController: quantityController,
  //       searchController: searchController,
  //       theme: theme,
  //       cartItem: TempCartItem(
  //         uuid: uuidGen(),
  //         itemUuid: product.uuid,
  //         isVoid: false,
  //         qttyPerGroup: product.qttyPerGroup,
  //         useGroupQuantity: false,
  //         setTotalPrice:
  //             returnSalesProvider().setTotalPrice,
  //         useWholeSalePrice: false,
  //         addToStock: false,
  //         discount: product.discount,
  //         item: product,
  //         quantity:
  //             double.tryParse(
  //               quantityController.text
  //                   .replaceAll(',', '')
  //                   .trim(),
  //             ) ??
  //             0.0,
  //       ),
  //       closeAction: closeAction,
  //       priceController: priceController,
  //     );
  //   }
  // } else {
  //   if (product.quantity == 0) {
  //     showDialog(
  //       context: context,
  //       builder: (context) {
  //         var theme = returnTheme(context, listen: false);
  //         return InfoAlert(
  //           theme: theme,
  //           message:
  //               'Item Quantity is Zero, Therefore, this item cannot be sold',
  //           title: 'Item out of Stock',
  //         );
  //       },
  //     );
  //   } else if (returnSalesProvider()
  //       .currentCart()
  //       .cartItems
  //       .where(
  //         (item) =>
  //             (item.itemUuid ?? item.item.uuid) ==
  //             product.uuid,
  //       )
  //       .isNotEmpty) {
  //     selectProductSales(
  //       isEdit: false,
  //       context: context,
  //       qttyNode: qttyNode,
  //       priceNode: priceNode,
  //       quantityController: quantityController,
  //       searchController: searchController,
  //       theme: theme,
  //       cartItem: TempCartItem(
  //         uuid:
  //             returnSalesProvider()
  //                 .currentCart()
  //                 .cartItems
  //                 .firstWhere(
  //                   (item) =>
  //                       (item.itemUuid ?? item.item.uuid) ==
  //                       product.uuid!,
  //                 )
  //                 .uuid,
  //         itemUuid: product.uuid,
  //         isVoid: false,
  //         qttyPerGroup:
  //             returnSalesProvider()
  //                 .currentCart()
  //                 .cartItems
  //                 .firstWhere(
  //                   (item) =>
  //                       (item.itemUuid ?? item.item.uuid) ==
  //                       product.uuid!,
  //                 )
  //                 .qttyPerGroup,
  //         useGroupQuantity:
  //             returnSalesProvider()
  //                 .currentCart()
  //                 .cartItems
  //                 .firstWhere(
  //                   (item) =>
  //                       (item.itemUuid ?? item.item.uuid) ==
  //                       product.uuid!,
  //                 )
  //                 .useGroupQuantity,
  //         setTotalPrice:
  //             returnSalesProvider().setTotalPrice,
  //         useWholeSalePrice:
  //             returnSalesProvider()
  //                 .currentCart()
  //                 .cartItems
  //                 .firstWhere(
  //                   (item) =>
  //                       (item.itemUuid ?? item.item.uuid) ==
  //                       product.uuid!,
  //                 )
  //                 .useWholeSalePrice,
  //         addToStock: false,
  //         discount: product.discount,
  //         item: product,
  //         quantity:
  //             returnSalesProvider()
  //                 .currentCart()
  //                 .cartItems
  //                 .firstWhere(
  //                   (item) =>
  //                       (item.itemUuid ?? item.item.uuid) ==
  //                       product.uuid!,
  //                 )
  //                 .quantity,
  //       ),
  //       closeAction: closeAction,
  //       priceController: priceController,
  //     );
  //   } else {
  //     selectProductSales(
  //       isEdit: false,
  //       context: context,
  //       qttyNode: qttyNode,
  //       priceNode: priceNode,
  //       quantityController: quantityController,
  //       searchController: searchController,
  //       theme: theme,
  //       cartItem: TempCartItem(
  //         uuid: uuidGen(),
  //         itemUuid: product.uuid,
  //         isVoid: false,
  //         qttyPerGroup: product.qttyPerGroup,
  //         useGroupQuantity: false,
  //         setTotalPrice:
  //             returnSalesProvider().setTotalPrice,
  //         useWholeSalePrice: false,
  //         addToStock: false,
  //         discount: product.discount,
  //         item: product,
  //         quantity:
  //             double.tryParse(
  //               quantityController.text
  //                   .replaceAll(',', '')
  //                   .trim(),
  //             ) ??
  //             0.0,
  //       ),
  //       closeAction: closeAction,
  //       priceController: priceController,
  //     );
  //   }
  // }
}

class ToggleButton extends StatelessWidget {
  const ToggleButton({
    super.key,
    required this.index,
    required this.myIndex,
    required this.action,
  });

  final int index;
  final int myIndex;
  final Function()? action;

  @override
  Widget build(BuildContext context) {
    var isTrue = index == myIndex;
    var theme = returnTheme(context);
    return Expanded(
      child: InkWell(
        mouseCursor: SystemMouseCursors.click,
        onTap: action,
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: 5,
            horizontal: 10,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color:
                  isTrue
                      ? Colors.amber
                      : Colors.grey.shade200,
            ),
            color:
                isTrue
                    ? const Color.fromARGB(50, 255, 193, 7)
                    : Colors.grey.shade100,
            borderRadius:
                myIndex == 1
                    ? BorderRadius.only(
                      topLeft: Radius.circular(5),
                      bottomLeft: Radius.circular(5),
                    )
                    : BorderRadius.only(
                      topRight: Radius.circular(5),
                      bottomRight: Radius.circular(5),
                    ),
          ),
          child: Center(
            child: Text(
              style: TextStyle(
                fontSize: theme.mobileTexts.b4.fontSize,
                fontWeight: isTrue ? FontWeight.bold : null,
              ),
              myIndex == 1 ? 'Items' : "Calculator",
            ),
          ),
        ),
      ),
    );
  }
}
