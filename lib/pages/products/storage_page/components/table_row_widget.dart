import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/products/product_details/product_details_page.dart';
import 'package:stockall/pages/products/storage_page/components/is_managed_toggle_widget.dart';
import 'package:stockall/pages/products/storage_page/components/quantity_edit_widget.dart';
import 'package:stockall/providers/theme_provider.dart';

class TableRowRecordWidget extends StatefulWidget {
  const TableRowRecordWidget({
    super.key,
    required this.theme,
    required this.product,
  });

  final ThemeProvider theme;
  final TempProductClass product;

  @override
  State<TableRowRecordWidget> createState() =>
      _TableRowRecordWidgetState();
}

class _TableRowRecordWidgetState
    extends State<TableRowRecordWidget> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return ProductDetailsPage(
                productUuid: widget.product.uuid!,
                comingFromInventoryUpdatesPage: true,
              );
            },
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey),
            left: BorderSide(color: Colors.grey),
            right: BorderSide(color: Colors.grey),
          ),
        ),
        child: Row(
          spacing: 0,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Container(
                padding: EdgeInsets.all(5),
                child: Center(
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          style: TextStyle(
                            fontSize:
                                widget
                                    .theme
                                    .mobileTexts
                                    .b3
                                    .fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                          (returnData(
                                    context: context,
                                  ).productList.indexWhere(
                                    (item) =>
                                        item.uuid ==
                                        widget.product.uuid,
                                  ) +
                                  1)
                              .toString(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 9,
              child: Container(
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(color: Colors.grey),
                  ),
                ),
                child: Center(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          style: TextStyle(
                            fontSize:
                                widget
                                    .theme
                                    .mobileTexts
                                    .b3
                                    .fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                          widget.product.name,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 7,
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(color: Colors.grey),
                    left: BorderSide(color: Colors.grey),
                  ),
                ),
                padding: EdgeInsets.all(5),
                child: Center(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          style: TextStyle(
                            fontSize:
                                widget
                                    .theme
                                    .mobileTexts
                                    .b3
                                    .fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                          formatLargeNumber(
                            ((widget.product.totalQttyInStorage ??
                                        0) +
                                    (widget
                                            .product
                                            .quantity ??
                                        0))
                                .toStringAsFixed(0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 7,
              child: QuantityEditWidget(
                isTotal: true,
                product: widget.product,
              ),
            ),
            Expanded(
              flex: 7,
              child: QuantityEditWidget(
                isTotal: false,
                product: widget.product,
              ),
            ),
            Expanded(
              flex: 7,
              child: Container(
                padding: EdgeInsets.all(5),
                child: Center(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          style: TextStyle(
                            fontSize:
                                widget
                                    .theme
                                    .mobileTexts
                                    .b3
                                    .fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                          formatMoneyBig(
                            amount:
                                widget
                                    .product
                                    .sellingPrice ??
                                0,
                            context: context,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 7,
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(color: Colors.grey),
                    left: BorderSide(color: Colors.grey),
                  ),
                ),
                padding: EdgeInsets.all(5),
                child: Center(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          style: TextStyle(
                            fontSize:
                                widget
                                    .theme
                                    .mobileTexts
                                    .b3
                                    .fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                          formatMoneyBig(
                            amount:
                                widget.product.costPrice,
                            context: context,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    // right: BorderSide(color: Colors.grey),
                    // left: BorderSide(color: Colors.grey),
                  ),
                ),
                padding: EdgeInsets.all(5),
                child: Center(
                  child: Row(
                    children: [
                      IsManagedToggleWidget(
                        product: widget.product,
                      ),
                      // Flexible(
                      //   child: Text(
                      //     style: TextStyle(
                      //       fontSize:
                      //           widget
                      //               .theme
                      //               .mobileTexts
                      //               .b3
                      //               .fontSize,
                      //       fontWeight: FontWeight.bold,
                      //       color:
                      //           getDayDifference(
                      //                         widget
                      //                                 .product
                      //                                 .expiryDate ??
                      //                             DateTime.now(),
                      //                       ) <
                      //                       1 &&
                      //                   widget
                      //                           .product
                      //                           .expiryDate !=
                      //                       null
                      //               ? widget
                      //                   .theme
                      //                   .lightModeColor
                      //                   .errorColor200
                      //               : null,
                      //     ),

                      //     widget.product.expiryDate != null
                      //         ? getDayDifference(
                      //                   widget
                      //                           .product
                      //                           .expiryDate ??
                      //                       DateTime.now(),
                      //                 ) >=
                      //                 1
                      //             ? formatDateTime(
                      //               widget
                      //                       .product
                      //                       .expiryDate ??
                      //                   DateTime.now(),
                      //             )
                      //             : 'Item Expired'
                      //         : 'Not Set',
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
