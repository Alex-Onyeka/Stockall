import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_cart_items/temp_cart_item.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/my_calculator_desktop.dart';
import 'package:stockall/constants/bottom_sheet_widgets.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/products/compnents/product_tile_cart_search.dart';

class RIghtBarSection extends StatefulWidget {
  const RIghtBarSection({super.key});

  @override
  State<RIghtBarSection> createState() =>
      _RIghtBarSectionState();
}

class _RIghtBarSectionState extends State<RIghtBarSection> {
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
                child: ListView(
                  children:
                      returnData()
                          .productList()
                          .map(
                            (
                              product,
                            ) => ProductTileCartSearch(
                              theme: theme,
                              product: product,
                              action: () {
                                if (!product.isManaged) {
                                  if (returnSalesProvider()
                                      .currentCart()
                                      .cartItems
                                      .where(
                                        (item) =>
                                            (item.itemUuid ??
                                                item
                                                    .item
                                                    .uuid) ==
                                            product.uuid,
                                      )
                                      .isNotEmpty) {
                                    selectProductSales(
                                      isEdit: false,
                                      context: context,
                                      qttyNode: qttyNode,
                                      priceNode: priceNode,
                                      quantityController:
                                          quantityController,
                                      searchController:
                                          searchController,
                                      theme: theme,
                                      cartItem: TempCartItem(
                                        uuid:
                                            returnSalesProvider()
                                                .currentCart()
                                                .cartItems
                                                .firstWhere(
                                                  (item) =>
                                                      (item.itemUuid ??
                                                          item.item.uuid) ==
                                                      product
                                                          .uuid!,
                                                )
                                                .uuid,
                                        itemUuid:
                                            product.uuid,
                                        isVoid: false,
                                        qttyPerGroup:
                                            returnSalesProvider()
                                                .currentCart()
                                                .cartItems
                                                .firstWhere(
                                                  (item) =>
                                                      (item.itemUuid ??
                                                          item.item.uuid) ==
                                                      product
                                                          .uuid!,
                                                )
                                                .qttyPerGroup,
                                        useGroupQuantity:
                                            returnSalesProvider()
                                                .currentCart()
                                                .cartItems
                                                .firstWhere(
                                                  (item) =>
                                                      (item.itemUuid ??
                                                          item.item.uuid) ==
                                                      product
                                                          .uuid!,
                                                )
                                                .useGroupQuantity,
                                        setTotalPrice:
                                            returnSalesProvider()
                                                .setTotalPrice,
                                        useWholeSalePrice:
                                            returnSalesProvider()
                                                .currentCart()
                                                .cartItems
                                                .firstWhere(
                                                  (item) =>
                                                      (item.itemUuid ??
                                                          item.item.uuid) ==
                                                      product
                                                          .uuid!,
                                                )
                                                .useWholeSalePrice,
                                        addToStock: false,
                                        discount:
                                            product
                                                .discount,
                                        item: product,
                                        quantity:
                                            returnSalesProvider()
                                                .currentCart()
                                                .cartItems
                                                .firstWhere(
                                                  (item) =>
                                                      (item.itemUuid ??
                                                          item.item.uuid) ==
                                                      product
                                                          .uuid!,
                                                )
                                                .quantity,
                                      ),
                                      closeAction:
                                          closeAction,
                                      priceController:
                                          priceController,
                                    );
                                  } else {
                                    selectProductSales(
                                      isEdit: false,
                                      context: context,
                                      qttyNode: qttyNode,
                                      priceNode: priceNode,
                                      quantityController:
                                          quantityController,
                                      searchController:
                                          searchController,
                                      theme: theme,
                                      cartItem: TempCartItem(
                                        uuid: uuidGen(),
                                        itemUuid:
                                            product.uuid,
                                        isVoid: false,
                                        qttyPerGroup:
                                            product
                                                .qttyPerGroup,
                                        useGroupQuantity:
                                            false,
                                        setTotalPrice:
                                            returnSalesProvider()
                                                .setTotalPrice,
                                        useWholeSalePrice:
                                            false,
                                        addToStock: false,
                                        discount:
                                            product
                                                .discount,
                                        item: product,
                                        quantity:
                                            double.tryParse(
                                              quantityController
                                                  .text
                                                  .replaceAll(
                                                    ',',
                                                    '',
                                                  )
                                                  .trim(),
                                            ) ??
                                            0.0,
                                      ),
                                      closeAction:
                                          closeAction,
                                      priceController:
                                          priceController,
                                    );
                                  }
                                } else {
                                  if (product.quantity ==
                                      0) {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        var theme =
                                            returnTheme(
                                              context,
                                              listen: false,
                                            );
                                        return InfoAlert(
                                          theme: theme,
                                          message:
                                              'Item Quantity is Zero, Therefore, this item cannot be sold',
                                          title:
                                              'Item out of Stock',
                                        );
                                      },
                                    );
                                  } else if (returnSalesProvider()
                                      .currentCart()
                                      .cartItems
                                      .where(
                                        (item) =>
                                            (item.itemUuid ??
                                                item
                                                    .item
                                                    .uuid) ==
                                            product.uuid,
                                      )
                                      .isNotEmpty) {
                                    selectProductSales(
                                      isEdit: false,
                                      context: context,
                                      qttyNode: qttyNode,
                                      priceNode: priceNode,
                                      quantityController:
                                          quantityController,
                                      searchController:
                                          searchController,
                                      theme: theme,
                                      cartItem: TempCartItem(
                                        uuid:
                                            returnSalesProvider()
                                                .currentCart()
                                                .cartItems
                                                .firstWhere(
                                                  (item) =>
                                                      (item.itemUuid ??
                                                          item.item.uuid) ==
                                                      product
                                                          .uuid!,
                                                )
                                                .uuid,
                                        itemUuid:
                                            product.uuid,
                                        isVoid: false,
                                        qttyPerGroup:
                                            returnSalesProvider()
                                                .currentCart()
                                                .cartItems
                                                .firstWhere(
                                                  (item) =>
                                                      (item.itemUuid ??
                                                          item.item.uuid) ==
                                                      product
                                                          .uuid!,
                                                )
                                                .qttyPerGroup,
                                        useGroupQuantity:
                                            returnSalesProvider()
                                                .currentCart()
                                                .cartItems
                                                .firstWhere(
                                                  (item) =>
                                                      (item.itemUuid ??
                                                          item.item.uuid) ==
                                                      product
                                                          .uuid!,
                                                )
                                                .useGroupQuantity,
                                        setTotalPrice:
                                            returnSalesProvider()
                                                .setTotalPrice,
                                        useWholeSalePrice:
                                            returnSalesProvider()
                                                .currentCart()
                                                .cartItems
                                                .firstWhere(
                                                  (item) =>
                                                      (item.itemUuid ??
                                                          item.item.uuid) ==
                                                      product
                                                          .uuid!,
                                                )
                                                .useWholeSalePrice,
                                        addToStock: false,
                                        discount:
                                            product
                                                .discount,
                                        item: product,
                                        quantity:
                                            returnSalesProvider()
                                                .currentCart()
                                                .cartItems
                                                .firstWhere(
                                                  (item) =>
                                                      (item.itemUuid ??
                                                          item.item.uuid) ==
                                                      product
                                                          .uuid!,
                                                )
                                                .quantity,
                                      ),
                                      closeAction:
                                          closeAction,
                                      priceController:
                                          priceController,
                                    );
                                  } else {
                                    selectProductSales(
                                      isEdit: false,
                                      context: context,
                                      qttyNode: qttyNode,
                                      priceNode: priceNode,
                                      quantityController:
                                          quantityController,
                                      searchController:
                                          searchController,
                                      theme: theme,
                                      cartItem: TempCartItem(
                                        uuid: uuidGen(),
                                        itemUuid:
                                            product.uuid,
                                        isVoid: false,
                                        qttyPerGroup:
                                            product
                                                .qttyPerGroup,
                                        useGroupQuantity:
                                            false,
                                        setTotalPrice:
                                            returnSalesProvider()
                                                .setTotalPrice,
                                        useWholeSalePrice:
                                            false,
                                        addToStock: false,
                                        discount:
                                            product
                                                .discount,
                                        item: product,
                                        quantity:
                                            double.tryParse(
                                              quantityController
                                                  .text
                                                  .replaceAll(
                                                    ',',
                                                    '',
                                                  )
                                                  .trim(),
                                            ) ??
                                            0.0,
                                      ),
                                      closeAction:
                                          closeAction,
                                      priceController:
                                          priceController,
                                    );
                                  }
                                }
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
    );
  }
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
