import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stockall/classes/temp_customers_class.dart';
import 'package:stockall/classes/temp_main_receipt.dart';
import 'package:stockall/classes/temp_product_sale_record.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/sales/make_sales/receipt_page/receipt_page.dart';

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
    if (text.length < 7) {
      return text;
    } else {
      return '${text.substring(0, 7)}...';
    }
  }

  late Future<TempCustomersClass?> customerFuture;

  Future<TempCustomersClass?> getCustomer() async {
    if (widget.mainReceipt.customerId != null) {
      var tempCustomer = await returnCustomers(
        context,
        listen: false,
      ).fetchCustomers(
        returnShopProvider(
          context,
          listen: false,
        ).userShop!.shopId!,
      );
      return tempCustomer.firstWhere(
        (customer) =>
            customer.id != null &&
            customer.id == widget.mainReceipt.customerId!,
      );
    } else {
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

  late Future<List<TempProductSaleRecord>> productFuture;
  @override
  void initState() {
    super.initState();
    productFuture = getProductRecord();
    customerFuture = getCustomer();
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return FutureBuilder(
      future: productFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.white,
            child: Container(
              margin: EdgeInsets.symmetric(
                vertical: 5,
                horizontal: 15,
              ),
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.grey.shade400,
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Container(
            margin: EdgeInsets.symmetric(
              vertical: 5,
              horizontal: 15,
            ),
            height: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.grey.shade400,
            ),
            child: Center(
              child: Text('Error Loading Receipt'),
            ),
          );
        } else {
          double getTotal() {
            double totalAmount = 0;
            for (var element
                in snapshot.data!
                    .where(
                      (test) =>
                          test.recepitId ==
                          widget.mainReceipt.id,
                    )
                    .toList()) {
              totalAmount += element.revenue;
            }
            return totalAmount;
          }

          var productReceipts =
              snapshot.data!
                  .where(
                    (test) =>
                        test.recepitId ==
                        widget.mainReceipt.id,
                  )
                  .toList();

          var firstProductId =
              productReceipts
                  .firstWhere(
                    (test) =>
                        test.recepitId ==
                        widget.mainReceipt.id,
                  )
                  .productId;
          var firstProduct = returnData(
                context,
                listen: false,
              )
              .getProducts(
                returnShopProvider(
                  context,
                  listen: false,
                ).userShop!.shopId!,
              )
              .then((products) {
                final product = products.firstWhere(
                  (product) => product.id == firstProductId,
                );
                return product;
              });
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
                                formatDateWithDay(
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
                            '${snapshot.data!.length} Item(s) Sold',
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
                                  FutureBuilder(
                                    future: firstProduct,
                                    builder: (
                                      context,
                                      snapshot,
                                    ) {
                                      if (snapshot
                                              .connectionState ==
                                          ConnectionState
                                              .waiting) {
                                        return Text(
                                          style: TextStyle(
                                            fontSize:
                                                theme
                                                    .mobileTexts
                                                    .b2
                                                    .fontSize,
                                            fontWeight:
                                                FontWeight
                                                    .bold,
                                          ),
                                          cutLongText(
                                            cutLongText(
                                              'Product',
                                            ),
                                          ),
                                        );
                                      } else {
                                        var product =
                                            snapshot.data;
                                        return Text(
                                          style: TextStyle(
                                            fontSize:
                                                theme
                                                    .mobileTexts
                                                    .b2
                                                    .fontSize,
                                            fontWeight:
                                                FontWeight
                                                    .bold,
                                          ),
                                          cutLongText(
                                            cutLongText(
                                              product?.name ??
                                                  'N/A',
                                            ),
                                          ),
                                        );
                                      }
                                    },
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
                                    textAlign:
                                        TextAlign.left,
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
                                      '#${returnShopProvider(context, listen: false).userShop!.name.substring(0, 2).toUpperCase()}${widget.mainReceipt.id.toString()}',
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
                                    '$nairaSymbol${formatLargeNumberDoubleWidgetDecimal(getTotal())}',
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
                          FutureBuilder<
                            TempCustomersClass?
                          >(
                            future: customerFuture,
                            builder: (context, snapshot) {
                              if (snapshot
                                      .connectionState ==
                                  ConnectionState.waiting) {
                                return Text(
                                  style: TextStyle(
                                    fontSize:
                                        theme
                                            .mobileTexts
                                            .b2
                                            .fontSize,
                                    fontWeight:
                                        FontWeight.bold,
                                    color:
                                        theme
                                            .lightModeColor
                                            .secColor200,
                                  ),
                                  'Customer',
                                );
                              } else if (snapshot
                                  .hasError) {
                                return Text(
                                  style: TextStyle(
                                    fontSize:
                                        theme
                                            .mobileTexts
                                            .b2
                                            .fontSize,
                                    fontWeight:
                                        FontWeight.bold,
                                    color:
                                        theme
                                            .lightModeColor
                                            .secColor200,
                                  ),
                                  'Not Sett',
                                );
                              } else {
                                TempCustomersClass?
                                customer = snapshot.data;
                                return Text(
                                  style: TextStyle(
                                    fontSize:
                                        theme
                                            .mobileTexts
                                            .b2
                                            .fontSize,
                                    fontWeight:
                                        FontWeight.bold,
                                    color:
                                        theme
                                            .lightModeColor
                                            .secColor200,
                                  ),

                                  "Customer: ${cutLongText(customer != null ? customer.name : 'Not Set')}",
                                );
                              }
                            },
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
                            'Cashier: ${cutLongText(widget.mainReceipt.staffName)}',
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
