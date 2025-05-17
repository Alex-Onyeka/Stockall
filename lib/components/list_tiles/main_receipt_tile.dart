import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stockitt/classes/temp_customers_class.dart';
import 'package:stockitt/classes/temp_main_receipt.dart';
import 'package:stockitt/classes/temp_product_class.dart';
import 'package:stockitt/classes/temp_product_sale_record.dart';
import 'package:stockitt/constants/calculations.dart';
import 'package:stockitt/constants/constants_main.dart';
import 'package:stockitt/main.dart';
import 'package:stockitt/pages/sales/make_sales/receipt_page/receipt_page.dart';

class MainReceiptTile extends StatefulWidget {
  final TempMainReceipt mainReceipt;
  const MainReceiptTile({
    super.key,
    required this.mainReceipt,
  });

  @override
  State<MainReceiptTile> createState() =>
      _MainReceiptTileState();
}

class _MainReceiptTileState extends State<MainReceiptTile> {
  String cutLongText(String text) {
    if (text.length < 12) {
      return text;
    } else {
      return '${text.substring(0, 12)}...';
    }
  }

  String cutLongText2(String text) {
    if (text.length < 8) {
      return text;
    } else {
      return '${text.substring(0, 8)}...';
    }
  }

  TempCustomersClass? returnCustomer() {
    final customers = returnCustomers(
      context,
      listen: false,
    ).getOwnCustomer(context);
    for (var customer in customers) {
      if (customer.id == widget.mainReceipt.customerId) {
        return customer;
      }
    }
    return null; // No match found
  }

  List<TempProductSaleRecord> salesRecord() {
    return returnReceiptProvider(context, listen: false)
        .getOwnProductSalesRecord(context)
        .where(
          (record) =>
              record.recepitId == widget.mainReceipt.id,
        )
        .toList();
  }

  TempProductClass? firstProductRecord() {
    final sales = salesRecord();
    if (sales.isEmpty) return null;

    try {
      return returnData(context, listen: false)
          .returnOwnProducts(context)
          .firstWhere(
            (product) =>
                product.id == sales.first.productId,
          );
    } catch (e) {
      return null;
    }
  }

  Future<List<TempProductSaleRecord>>
  getProductRecord() async {
    var tempRecords = await returnReceiptProvider(
      context,
      listen: false,
    ).loadProductSalesRecord(
      returnShopProvider(
        context,
        listen: false,
      ).userShop!.shopId!,
    );

    return tempRecords
        .where(
          (record) =>
              record.recepitId == widget.mainReceipt.id!,
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return FutureBuilder(
      future: getProductRecord(),
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return Container();
        } else if (snapshot.hasError) {
          return Container();
        } else {
          return Padding(
            padding: const EdgeInsets.only(bottom: 15.0),
            child: Ink(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.shade200,
                ),

                borderRadius: BorderRadius.circular(5),
                color: Colors.white,
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(5),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return ReceiptPage(
                          mainReceipt: widget.mainReceipt,
                          isMain: false,
                        );
                      },
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsetsDirectional.all(15),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.start,
                            spacing: 5,
                            children: [
                              SvgPicture.asset(
                                receiptIconSvg,
                              ),
                              Text(
                                style: TextStyle(
                                  fontSize:
                                      theme
                                          .mobileTexts
                                          .b2
                                          .fontSize,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                                formatDateTime(
                                  widget
                                      .mainReceipt
                                      .createdAt,
                                ),
                              ),
                            ],
                          ),
                          Icon(
                            color: Colors.grey,
                            size: 20,
                            Icons.arrow_forward_ios_rounded,
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            style: TextStyle(
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b2
                                      .fontSize,
                              fontWeight: FontWeight.bold,
                              color:
                                  theme
                                      .lightModeColor
                                      .secColor200,
                            ),
                            '${widget.mainReceipt.paymentMethod} Payment',
                          ),
                          Text(
                            style: TextStyle(
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b2
                                      .fontSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                            '${salesRecord().length} Items Sold',
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Container(
                        padding: EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(5),
                          color: const Color.fromARGB(
                            162,
                            245,
                            245,
                            245,
                          ),
                          border: Border.all(
                            color: Colors.grey.shade200,
                          ),
                        ),
                        child: Row(
                          spacing: 5,
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                          children: [
                            Expanded(
                              flex: 4,
                              child: Column(
                                spacing: 3,
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  Text(
                                    style: TextStyle(
                                      fontSize:
                                          theme
                                              .mobileTexts
                                              .b3
                                              .fontSize,
                                    ),
                                    'Product Name',
                                  ),
                                  Text(
                                    style: TextStyle(
                                      fontSize:
                                          theme
                                              .mobileTexts
                                              .b2
                                              .fontSize,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                    cutLongText(
                                      cutLongText(
                                        firstProductRecord()
                                                ?.name ??
                                            'N/A',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Column(
                                spacing: 3,
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  Text(
                                    style: TextStyle(
                                      fontSize:
                                          theme
                                              .mobileTexts
                                              .b3
                                              .fontSize,
                                    ),
                                    'Receipt NO.',
                                  ),
                                  Text(
                                    style: TextStyle(
                                      fontSize:
                                          theme
                                              .mobileTexts
                                              .b2
                                              .fontSize,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                    cutLongText2(
                                      '${widget.mainReceipt.id}',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Column(
                                spacing: 3,
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  Text(
                                    style: TextStyle(
                                      fontSize:
                                          theme
                                              .mobileTexts
                                              .b3
                                              .fontSize,
                                    ),
                                    'Total',
                                  ),
                                  Text(
                                    style: TextStyle(
                                      fontSize:
                                          theme
                                              .mobileTexts
                                              .b2
                                              .fontSize,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                    formatLargeNumberDouble(
                                      returnReceiptProvider(
                                        context,
                                      ).getTotalMainRevenueReceipt(
                                        snapshot.data!,
                                        context,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            style: TextStyle(
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b2
                                      .fontSize,
                              fontWeight: FontWeight.bold,
                              color:
                                  theme
                                      .lightModeColor
                                      .secColor200,
                            ),
                            'Customer: ${returnCustomer() != null ? returnCustomer()!.name : 'Not Found'}',
                          ),
                          Text(
                            style: TextStyle(
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b2
                                      .fontSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
                            ),
                            'Staff: Alex',
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
      },
    );
  }
}
