import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_cart_items/temp_cart_item.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/components/text_fields/text_field_barcode.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/play_sounds.dart';
import 'package:stockall/constants/subscription/sales_auth.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/sales/make_sales/page1/platforms/components/right_bar_section.dart';
import 'package:stockall/providers/theme_provider.dart';

class BarcodeAndSearchTextField extends StatefulWidget {
  final ThemeProvider theme;
  final TextEditingController searchController;
  final FocusNode priceNode;
  final FocusNode qtyNode;
  final TextEditingController quantityController;
  final TextEditingController priceController;
  final Function() close;

  const BarcodeAndSearchTextField({
    super.key,
    required this.theme,
    required this.searchController,
    required this.priceNode,
    required this.qtyNode,
    required this.quantityController,
    required this.priceController,
    required this.close,
  });

  @override
  State<BarcodeAndSearchTextField> createState() =>
      _BarcodeAndSearchTextFieldState();
}

class _BarcodeAndSearchTextFieldState
    extends State<BarcodeAndSearchTextField> {
  @override
  Widget build(BuildContext context) {
    List<TempProductClass> products =
        returnData()
            .productList()
            .where(
              (pro) => pro.name.toLowerCase().contains(
                widget.searchController.text.toLowerCase(),
              ),
            )
            .toList();
    return Column(
      children: [
        TextFieldBarcode(
          node:
              returnSalesProvider().scanBarcodeCartPageNode,
          hintText: 'Search Or Scan Barcode',
          clearTextField: () {
            setState(() {});
          },
          searchController: widget.searchController,
          onChanged: (value) {
            if (value.isNotEmpty) {
              var items = returnData().productList().where(
                (product) => product.barcode == value,
              );
              SalesAuthAction().useBarcodeAction(
                context: context,
                action: () async {
                  if (items.isNotEmpty) {
                    await playBeep();
                    await returnSalesProvider()
                        .addItemToCart(
                          // isEdit: false,
                          context: context,
                          newItem: TempCartItem(
                            uuid: uuidGen(),
                            itemUuid: items.first.uuid,
                            isVoid: false,
                            qttyPerGroup: null,
                            useGroupQuantity: false,
                            useWholeSalePrice: false,
                            setCustomPrice: false,
                            item: items.first,
                            quantity: 1,
                            discount: null,
                            addToStock: false,
                            setTotalPrice: false,
                          ),
                          isCustomEdit: false,
                        );

                    widget.searchController.clear();
                    setState(() {});

                    returnSalesProvider()
                        .requestFocusScanBarcode();
                  }
                },
                failAction: () {
                  widget.searchController.clear();
                },
              );
            }

            setState(() {});
          },
          onPressedScan: () async {},
        ),
        Visibility(
          visible: widget.searchController.text.isNotEmpty,
          child: Column(
            children: [
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 10,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Builder(
                  builder: (context) {
                    if (products.isEmpty) {
                      return Center(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            mouseCursor:
                                SystemMouseCursors.click,
                            borderRadius:
                                BorderRadius.circular(10),
                            onTap: () {
                              setState(() {
                                widget.searchController
                                    .clear();
                              });
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(
                                    15,
                                    3,
                                    15,
                                    8.0,
                                  ),
                              child: Column(
                                spacing: 2,
                                children: [
                                  Icon(
                                    size: 16,
                                    color: Colors.grey,
                                    Icons.clear,
                                  ),
                                  Text(
                                    style: TextStyle(
                                      fontSize:
                                          returnTheme(
                                                context,
                                              )
                                              .mobileTexts
                                              .b3
                                              .fontSize,
                                    ),
                                    'No Item Found',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    } else {
                      return Column(
                        spacing: 5,
                        children:
                            (products.length > 5
                                    ? products.getRange(
                                      0,
                                      5,
                                    )
                                    : products)
                                .map(
                                  (item) => Material(
                                    color:
                                        Colors
                                            .grey
                                            .shade100,
                                    child: InkWell(
                                      mouseCursor:
                                          SystemMouseCursors
                                              .click,
                                      onTap: () {
                                        addItemToCartFromCartItemList(
                                          closeAction:
                                              () {},
                                          context: context,
                                          priceController:
                                              widget
                                                  .priceController,
                                          priceNode:
                                              widget
                                                  .priceNode,
                                          product: item,
                                          qttyNode:
                                              widget
                                                  .qtyNode,
                                          quantityController:
                                              widget
                                                  .quantityController,
                                          searchController:
                                              widget
                                                  .searchController,
                                        );
                                      },
                                      child: Container(
                                        padding:
                                            EdgeInsets.symmetric(
                                              vertical: 5,
                                              horizontal: 5,
                                            ),

                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment
                                                  .spaceBetween,
                                          spacing: 5,
                                          children: [
                                            Expanded(
                                              child: Row(
                                                spacing: 5,
                                                children: [
                                                  Icon(
                                                    size:
                                                        20,
                                                    color:
                                                        widget.theme.lightModeColor.secColor200,
                                                    Icons
                                                        .arrow_right_rounded,
                                                  ),
                                                  Flexible(
                                                    child: Text(
                                                      style: TextStyle(
                                                        fontSize:
                                                            widget.theme.mobileTexts.b4.fontSize,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                      item.name,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  style: TextStyle(
                                                    fontSize:
                                                        widget.theme.mobileTexts.b4.fontSize,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                  ),
                                                  "- (${formatLargeNumberDouble(item.quantity ?? 0)})  ",
                                                ),
                                                Text(
                                                  style: TextStyle(
                                                    fontSize:
                                                        widget.theme.mobileTexts.b4.fontSize,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                  ),
                                                  formatMoneyMid(
                                                    amount:
                                                        item.sellingPrice ??
                                                        0,
                                                    context:
                                                        context,
                                                  ),
                                                ),
                                              ],
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
            ],
          ),
        ),
      ],
    );
  }
}
