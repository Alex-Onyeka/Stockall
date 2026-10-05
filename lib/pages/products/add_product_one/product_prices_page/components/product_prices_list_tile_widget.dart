import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_product_class/prices_class/product_prices_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/products/add_product_one/product_prices_page/components/create_product_price_widget.dart';

class ProductPriceListTileWidget extends StatefulWidget {
  final String priceUuid;
  const ProductPriceListTileWidget({
    super.key,
    required this.priceUuid,
  });

  @override
  State<ProductPriceListTileWidget> createState() =>
      _ProductPriceListTileWidgetState();
}

class _ProductPriceListTileWidgetState
    extends State<ProductPriceListTileWidget> {
  // bool isLoading = false;
  // bool isDeleteLoading = false;
  TextEditingController nameController =
      TextEditingController();

  TextEditingController quantityController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    ProductPricesClass price =
        returnData(context: context).tempPricesList
                .where(
                  (price) => price.uuid == widget.priceUuid,
                )
                .isNotEmpty
            ? returnData(context: context).tempPricesList
                .where(
                  (price) => price.uuid == widget.priceUuid,
                )
                .first
            : ProductPricesClass(
              name: 'Not Set',
              uuid: uuidGen(),
              priceValue: 0,
              createdAt: DateTime.now(),
              isPrimary: true,
              itemUuid: '',
              staffName: currentUser().name,
              staffUuid: currentUser().userId!,
            );
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(10, 0, 0, 0),
            blurRadius: 10,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 10,
            ),

            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    spacing: 10,
                    children: [
                      Icon(
                        size: 18,
                        color:
                            theme
                                .lightModeColor
                                .secColor200,
                        Icons.workspaces_outline,
                      ),
                      Flexible(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          spacing: 2,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(
                                    top: 2.0,
                                  ),
                              child: Text(
                                style: TextStyle(
                                  fontSize:
                                      theme
                                          .mobileTexts
                                          .b3
                                          .fontSize,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                                price.getPricesName(),
                              ),
                            ),
                            Row(
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
                                        FontWeight.normal,
                                  ),
                                  "Price-Value:",
                                ),
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
                                  formatLargeNumberDouble(
                                    price.priceValue,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.end,
                  spacing: 8,
                  children: [
                    InkWell(
                      onTap: () {
                        if (!price.isPrimary) {
                          showDialog(
                            context: context,
                            builder: (confirmContext) {
                              return ConfirmationAlert(
                                theme: theme,
                                message:
                                    'You are about to make this Price your Business Primary Price. This means, all your items quantities are represented in this price, unless manually Changed.',
                                title: 'Make Primary Price',
                                action: () {
                                  Navigator.of(
                                    confirmContext,
                                  ).pop();
                                  returnData()
                                      .selectPrimaryPrice(
                                        priceListSingle:
                                            price,
                                      );
                                },
                              );
                            },
                          );
                        }
                      },
                      mouseCursor: SystemMouseCursors.click,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          8.0,
                          10,
                          8,
                          5,
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
                                    FontWeight.normal,
                              ),
                              "${price.isPrimary ? '' : 'Make '}Primary Price:",
                            ),
                            Container(
                              padding: EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(
                                      4,
                                    ),
                                color:
                                    price.isPrimary
                                        ? theme
                                            .lightModeColor
                                            .prColor250
                                        : Colors
                                            .transparent,
                                border: Border.all(
                                  color:
                                      Colors.grey.shade100,
                                ),
                              ),
                              child: Icon(
                                size: 13,
                                color:
                                    price.isPrimary
                                        ? Colors.white
                                        : Colors
                                            .grey
                                            .shade100,
                                Icons.check,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      spacing: 2,
                      children: [
                        Visibility(
                          visible:
                              returnData(
                                context: context,
                              ).tempPricesList.length >
                              1,
                          child: Material(
                            type: MaterialType.transparency,
                            child: InkWell(
                              mouseCursor:
                                  SystemMouseCursors.click,
                              borderRadius:
                                  BorderRadius.circular(5),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (mainDialog) {
                                    return ConfirmationAlert(
                                      theme: theme,
                                      message:
                                          'You are about to delete this Product Price, Are you sure you want to proceed?',
                                      title:
                                          'Delete Product Price',
                                      action: () async {
                                        Navigator.of(
                                          mainDialog,
                                        ).pop();
                                        returnData()
                                            .deleteProductPrice(
                                              priceListSingle:
                                                  price,
                                            );
                                      },
                                    );
                                  },
                                );
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(
                                      horizontal: 18,
                                      vertical: 3,
                                    ),
                                child: Icon(
                                  size: 18,
                                  color:
                                      Colors.red.shade400,
                                  Icons
                                      .delete_outline_rounded,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Material(
                          type: MaterialType.transparency,
                          child: InkWell(
                            mouseCursor:
                                SystemMouseCursors.click,
                            borderRadius:
                                BorderRadius.circular(5),
                            onTap: () {
                              addProductPriceAction(
                                context: context,
                                priceController:
                                    quantityController,
                                nameController:
                                    nameController,
                                productUuid: price.itemUuid,
                                price: price,
                                setStateAction: () {
                                  setState(() {});
                                },
                              );
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 3,
                                  ),
                              child: Icon(
                                size: 16,
                                color: Colors.grey,
                                Icons.edit,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
