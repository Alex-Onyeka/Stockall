import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
// import 'package:shimmer/shimmer.dart';
import 'package:stockall/classes/temp_customers_class.dart';
import 'package:stockall/classes/temp_main_receipt.dart';
import 'package:stockall/classes/temp_product_sale_record.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';

class MainReceiptTile extends StatefulWidget {
  final TempMainReceipt mainReceipt;
  final Function()? action;
  const MainReceiptTile({
    super.key,
    required this.mainReceipt,
    required this.action,
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

  List<TempProductSaleRecord> getProductRecord() {
    var tempRecords =
        returnReceiptProvider(
          context,
          listen: false,
        ).produtRecordSalesMain;

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
    // productFuture = getProductRecord();
    customerFuture = getCustomer();
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    double getTotal() {
      double totalAmount = 0;
      for (var element
          in getProductRecord()
              .where(
                (test) =>
                    test.recepitId == widget.mainReceipt.id,
              )
              .toList()) {
        totalAmount += element.revenue;
      }
      return totalAmount;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Ink(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),

          borderRadius: BorderRadius.circular(5),
          color: Colors.white,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(5),
          onTap: widget.action,
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
                        SvgPicture.asset(receiptIconSvg),
                        Text(
                          style: TextStyle(
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b2
                                    .fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                          formatDateWithDay(
                            widget.mainReceipt.createdAt,
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
                            theme.mobileTexts.b2.fontSize,
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
                            theme.mobileTexts.b2.fontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                      '${getProductRecord().length} Item(s) Sold',
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
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
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 5,
                        child: Column(
                          spacing: 3,
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              style: TextStyle(
                                fontSize:
                                    theme
                                        .mobileTexts
                                        .b3
                                        .fontSize,
                              ),
                              'Item Name',
                            ),
                            Text(
                              style: TextStyle(
                                fontSize:
                                    theme
                                        .mobileTexts
                                        .b2
                                        .fontSize,
                                fontWeight: FontWeight.bold,
                              ),
                              cutLongText(
                                getProductRecord()
                                        .isNotEmpty
                                    ? getProductRecord()
                                        .first
                                        .productName
                                    : '',
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
                              CrossAxisAlignment.start,
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
                                fontWeight: FontWeight.bold,
                              ),
                              formatMoneyMid(
                                amount: getTotal(),
                                context: context,
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
                    FutureBuilder<TempCustomersClass?>(
                      future: customerFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Text(
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
                            'Customer',
                          );
                        } else if (snapshot.hasError) {
                          return Text(
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
                            'Customer: Not Set',
                          );
                        } else {
                          TempCustomersClass? customer =
                              snapshot.data;
                          return Text(
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

                            "Customer: ${cutLongText2(customer != null ? customer.name.split(' ').first : 'Not Set')}",
                          );
                        }
                      },
                    ),
                    SizedBox(width: 10),
                    Text(
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b2.fontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                      'Cashier: ${cutLongText2(widget.mainReceipt.staffName.split(' ')[0])} ${widget.mainReceipt.staffName.split(' ').length > 1 ? widget.mainReceipt.staffName.split(' ')[1].split('')[0] : ''}.',
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
