import 'package:flutter/material.dart';
import 'package:stockitt/classes/temp_main_receipt.dart';
import 'package:stockitt/constants/calculations.dart';
import 'package:stockitt/main.dart';
import 'package:stockitt/pages/sales/make_sales/receipt_page/receipt_page.dart';
import 'package:stockitt/providers/theme_provider.dart';

class ReceiptTileMain extends StatefulWidget {
  final TempMainReceipt mainReceipt;
  const ReceiptTileMain({
    super.key,
    required this.theme,
    required this.mainReceipt,
  });

  final ThemeProvider theme;

  @override
  State<ReceiptTileMain> createState() =>
      _ReceiptTileMainState();
}

class _ReceiptTileMainState extends State<ReceiptTileMain> {
  double getTotal() {
    double totalAmount = 0;
    for (var element
        in returnReceiptProvider(context, listen: false)
            .getOwnProductSalesRecord(context)
            .where(
              (test) =>
                  test.recepitId == widget.mainReceipt.id,
            )
            .toList()) {
      totalAmount += element.revenue;
    }
    return totalAmount;
  }

  @override
  Widget build(BuildContext context) {
    var productReceipts =
        returnReceiptProvider(context, listen: false)
            .getOwnProductSalesRecord(context)
            .where(
              (test) =>
                  test.recepitId == widget.mainReceipt.id,
            )
            .toList();

    var firstProductId =
        productReceipts
            .firstWhere(
              (test) =>
                  test.recepitId == widget.mainReceipt.id,
            )
            .productId;
    var firstProduct = returnData(context, listen: false)
        .returnOwnProducts(context)
        .firstWhere(
          (product) => product.id == firstProductId,
        );

    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(
                41,
                158,
                158,
                158,
              ),
              blurRadius: 5,
            ),
          ],
        ),
        child: Material(
          borderRadius: BorderRadius.circular(10),
          elevation: 0,
          color: Colors.white,
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return ReceiptPage(
                      mainReceipt: widget.mainReceipt,
                    );
                  },
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 10,
              ),

              child: Row(
                children: [
                  // Container(
                  //   padding: EdgeInsets.all(10),
                  //   height: 45,
                  //   width: 45,
                  //   decoration: BoxDecoration(
                  //     borderRadius: BorderRadius.circular(
                  //       5,
                  //     ),
                  //     color: Colors.grey.shade200,
                  //   ),
                  //   child:
                  Icon(Icons.receipt_long_outlined),
                  // ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                          children: [
                            Row(
                              children: [
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                  children: [
                                    Text(
                                      style: TextStyle(
                                        fontSize:
                                            widget
                                                .theme
                                                .mobileTexts
                                                .b2
                                                .fontSize,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                      '${firstProduct.name} ...',
                                    ),
                                    Text(
                                      formatDateTime(
                                        widget
                                            .mainReceipt
                                            .createdAt,
                                      ),
                                      style: TextStyle(
                                        fontSize:
                                            widget
                                                .theme
                                                .mobileTexts
                                                .b3
                                                .fontSize,
                                        fontWeight:
                                            FontWeight.w600,
                                        color:
                                            widget
                                                .theme
                                                .lightModeColor
                                                .secColor200,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return ReceiptPage(
                                        mainReceipt:
                                            widget
                                                .mainReceipt,
                                      );
                                    },
                                  ),
                                );
                              },
                              icon: Icon(
                                Icons
                                    .arrow_forward_ios_rounded,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.end,
                          children: [
                            Text(
                              style: TextStyle(
                                fontSize:
                                    widget
                                        .theme
                                        .mobileTexts
                                        .b2
                                        .fontSize,
                                fontWeight: FontWeight.bold,
                                color:
                                    widget
                                        .theme
                                        .lightModeColor
                                        .prColor300,
                              ),
                              formatLargeNumberDoubleWidgetDecimal(
                                getTotal(),
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
          ),
        ),
      ),
    );
  }
}
