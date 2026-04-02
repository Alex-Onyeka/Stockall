import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_storage_product/temp_storage_products.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/products/storage_page/components/quantity_edit_widget.dart';
import 'package:stockall/pages/products/storage_page/storage_details/storage_details_page.dart';
import 'package:stockall/providers/theme_provider.dart';

class TableRowRecordWidget extends StatefulWidget {
  const TableRowRecordWidget({
    super.key,
    required this.theme,
    required this.product,
  });

  final ThemeProvider theme;
  final TempStorageProducts product;

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
        if (screenWidth(context) > mobileScreen) {
          returnData().unFocusSearchNode();
          returnData().removeSearchNodeListener();
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return StorageDetailsPage(
                productUuid: widget.product.uuid!,
              );
            },
          ),
        ).then((_) {
          if (screenWidth(context) > mobileScreen) {
            returnData().requestFocusSearchNode();
            returnData().addSearchNodeListener();
          }
        });
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
                          (returnStorageProductProvider(
                                        context: context,
                                      )
                                      .storageProductListMain
                                      .indexWhere(
                                        (item) =>
                                            item.uuid ==
                                            widget
                                                .product
                                                .uuid,
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
                    right: BorderSide(color: Colors.grey),
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
            // Visibility(
            //   visible: shop(context)?.useGroupUnit == true,
            //   child: Expanded(
            //     flex: 6,
            //     child: QuantityEditWidget(
            //       isGroup: true,
            //       isTotal: true,
            //       product: widget.product,
            //     ),
            //   ),
            // ),
            // Expanded(
            //   flex: 6,
            //   child: QuantityEditWidget(
            //     isGroup: false,
            //     isTotal: true,
            //     product: widget.product,
            //   ),
            // ),
            // Visibility(
            //   visible: shop(context)?.useGroupUnit == true,
            //   child: Expanded(
            //     flex: 6,
            //     child: Container(
            //       decoration: BoxDecoration(
            //         border: Border(
            //           right: BorderSide(color: Colors.grey),
            //           // left: BorderSide(color: Colors.grey),
            //         ),
            //       ),
            //       padding: EdgeInsets.all(5),
            //       child: Center(
            //         child: Row(
            //           children: [
            //             Flexible(
            //               child: Text(
            //                 style: TextStyle(
            //                   fontSize:
            //                       widget
            //                           .theme
            //                           .mobileTexts
            //                           .b3
            //                           .fontSize,
            //                   fontWeight: FontWeight.bold,
            //                 ),
            //                 formatLargeNumberDouble(
            //                   // returnData(
            //                   //   context: context,
            //                   // ).returnGroupQuantityValue(
            //                   //   widget.product,
            //                   // ),
            //                   2000,
            //                 ),
            //               ),
            //             ),
            //           ],
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
            // Expanded(
            //   flex: 6,
            //   child: QuantityEditWidget(
            //     isGroup: false,
            //     isTotal: false,
            //     product: widget.product,
            //   ),
            // ),
            // Visibility(
            //   visible: shop(context)?.wholeSale == true,
            //   child: Expanded(
            //     flex: 6,
            //     child: Container(
            //       decoration: BoxDecoration(
            //         border: Border(
            //           right: BorderSide(color: Colors.grey),
            //           // left: BorderSide(color: Colors.grey),
            //         ),
            //       ),
            //       padding: EdgeInsets.all(5),
            //       child: Center(
            //         child: Row(
            //           children: [
            //             Flexible(
            //               child: Text(
            //                 style: TextStyle(
            //                   fontSize:
            //                       widget
            //                           .theme
            //                           .mobileTexts
            //                           .b3
            //                           .fontSize,
            //                   fontWeight: FontWeight.bold,
            //                 ),
            //                 formatMoneyBig(
            //                   amount: 2000,
            //                   context: context,
            //                 ),
            //               ),
            //             ),
            //           ],
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
