import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/classes/temp_storage_product/temp_storage_products.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
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
  double getTotalInStorage() {
    return widget.product.quantity ?? 0;
  }

  double getTotalInSales() {
    List<TempProductClass> items =
        returnData().productListMain
            .where(
              (item) =>
                  item.storageUuid == widget.product.uuid,
            )
            .toList();

    return items
        .map((item) => (item.quantity ?? 0))
        .fold(0, (a, b) => a + b);
  }

  double getOverallTotal() {
    return getTotalInSales() + getTotalInStorage();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      mouseCursor: SystemMouseCursors.click,
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
        // padding: EdgeInsets.symmetric(vertical: 5),
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
            Container(
              width: 50,
              padding: EdgeInsets.all(10),
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
                                    ).storageProductListMain
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
            Expanded(
              flex: 2,
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(color: Colors.grey),
                    // right: BorderSide(color: Colors.grey),
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
              flex: 1,
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(color: Colors.grey),
                    // right: BorderSide(color: Colors.grey),
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
                          formatLargeNumberDouble(
                            getTotalInStorage(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(color: Colors.grey),
                    // right: BorderSide(color: Colors.grey),
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
                          formatLargeNumberDouble(
                            getTotalInSales(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(color: Colors.grey),
                    // right: BorderSide(color: Colors.grey),
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
                          formatLargeNumberDouble(
                            getOverallTotal(),
                          ),
                        ),
                      ),
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
