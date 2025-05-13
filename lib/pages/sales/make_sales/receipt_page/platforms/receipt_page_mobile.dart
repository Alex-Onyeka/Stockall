import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stockitt/classes/temp_main_receipt.dart';
import 'package:stockitt/classes/temp_shop_class.dart';
import 'package:stockitt/classes/temp_user_class.dart';
import 'package:stockitt/components/major/top_banner_two.dart';
import 'package:stockitt/constants/calculations.dart';
import 'package:stockitt/constants/constants_main.dart';
import 'package:stockitt/main.dart';
import 'package:stockitt/providers/theme_provider.dart';

class ReceiptPageMobile extends StatelessWidget {
  final bool isMain;
  final TempMainReceipt mainReceipt;
  const ReceiptPageMobile({
    super.key,
    required this.mainReceipt,
    required this.isMain,
  });

  @override
  Widget build(BuildContext context) {
    var user = returnUserProvider(
      context,
    ).currentUser(userId());
    var shop = returnShopProvider(
      context,
    ).returnShop(userId());
    var theme = returnTheme(context);
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            SizedBox(
              height:
                  MediaQuery.of(context).size.height - 50,
              child: Stack(
                alignment: Alignment(0, 1),
                children: [
                  Align(
                    alignment: Alignment(0, -1),
                    child: TopBannerTwo(
                      isMain: isMain,
                      title: 'Receipt',
                      theme: theme,
                      bottomSpace: 200,
                      topSpace: 10,
                    ),
                  ),
                  Positioned(
                    top: 70,
                    child: SizedBox(
                      height:
                          MediaQuery.of(
                            context,
                          ).size.height -
                          50,
                      child: ReceiptDetailsContainer(
                        isMain: isMain,
                        shop: shop,
                        user: user,
                        mainReceipt: mainReceipt,
                        theme: theme,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReceiptDetailsContainer extends StatefulWidget {
  final bool isMain;
  final TempShopClass shop;
  final TempMainReceipt mainReceipt;
  final TempUserClass user;
  final ThemeProvider theme;
  const ReceiptDetailsContainer({
    super.key,
    required this.theme,
    required this.mainReceipt,
    required this.shop,
    required this.user,
    required this.isMain,
  });

  @override
  State<ReceiptDetailsContainer> createState() =>
      _ReceiptDetailsContainerState();
}

class _ReceiptDetailsContainerState
    extends State<ReceiptDetailsContainer> {
  String? customerName;
  @override
  Widget build(BuildContext context) {
    if (widget.mainReceipt.customerId != null) {
      setState(() {
        customerName =
            returnCustomers(context, listen: false)
                .getOwnCustomer(context)
                .firstWhere(
                  (customer) =>
                      customer.id ==
                      widget.mainReceipt.customerId,
                )
                .name;
      });
    }
    var productRecords = returnReceiptProvider(
      context,
      // listen: false,
    ).getProductRecordsByReceiptId(
      widget.mainReceipt.id,
      context,
    );
    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width - 40,
          height: MediaQuery.of(context).size.height - 180,
          padding: EdgeInsets.all(25),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(32, 0, 0, 0),
                blurRadius: 5,
              ),
            ],
          ),
          child: SizedBox(
            height:
                MediaQuery.of(context).size.height - 200,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: 5),
                        Image.asset(
                          mainLogoIcon,
                          height: 40,
                        ),
                        SizedBox(height: 15),
                        Column(
                          spacing: 8,
                          children: [
                            Text(
                              style: TextStyle(
                                fontSize:
                                    widget
                                        .theme
                                        .mobileTexts
                                        .h4
                                        .fontSize,
                                fontWeight: FontWeight.bold,
                              ),
                              widget.shop.name,
                            ),
                            Text(
                              style: TextStyle(
                                fontSize:
                                    widget
                                        .theme
                                        .mobileTexts
                                        .b2
                                        .fontSize,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade700,
                              ),
                              widget.shop.email,
                            ),
                            Text(
                              style: TextStyle(
                                fontSize:
                                    widget
                                        .theme
                                        .mobileTexts
                                        .b2
                                        .fontSize,
                              ),
                              widget.shop.shopAddress ??
                                  'Address Not Set',
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Row(
                          spacing: 10,
                          children: [
                            Expanded(
                              flex: 5,
                              child: Column(
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
                                              .b1
                                              .fontSize,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                    'Casheir',
                                  ),
                                  Text(
                                    style: TextStyle(
                                      fontSize:
                                          widget
                                              .theme
                                              .mobileTexts
                                              .b2
                                              .fontSize,
                                      fontWeight:
                                          FontWeight.normal,
                                    ),
                                    widget
                                        .mainReceipt
                                        .staffName,
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Column(
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
                                              .b1
                                              .fontSize,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                    'Customer Name',
                                  ),
                                  Text(
                                    style: TextStyle(
                                      fontSize:
                                          widget
                                              .theme
                                              .mobileTexts
                                              .b2
                                              .fontSize,
                                      fontWeight:
                                          FontWeight.normal,
                                    ),
                                    customerName ??
                                        'Not Saved',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          spacing: 10,
                          children: [
                            Expanded(
                              flex: 5,
                              child: Column(
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
                                              .b1
                                              .fontSize,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                    'Payment Method',
                                  ),
                                  Text(
                                    style: TextStyle(
                                      fontSize:
                                          widget
                                              .theme
                                              .mobileTexts
                                              .b2
                                              .fontSize,
                                      fontWeight:
                                          FontWeight.normal,
                                    ),
                                    widget
                                        .mainReceipt
                                        .paymentMethod,
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Column(
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
                                              .b1
                                              .fontSize,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                    'Amount(s)',
                                  ),
                                  Column(
                                    children: [
                                      Visibility(
                                        visible:
                                            widget
                                                    .mainReceipt
                                                    .paymentMethod ==
                                                'Split' ||
                                            widget
                                                    .mainReceipt
                                                    .paymentMethod ==
                                                'Cash',
                                        child: Row(
                                          spacing: 5,
                                          children: [
                                            Text(
                                              style: TextStyle(
                                                fontSize:
                                                    widget
                                                        .theme
                                                        .mobileTexts
                                                        .b3
                                                        .fontSize,
                                                fontWeight:
                                                    FontWeight
                                                        .normal,
                                              ),
                                              'Cash:',
                                            ),
                                            Text(
                                              style: TextStyle(
                                                fontSize:
                                                    widget
                                                        .theme
                                                        .mobileTexts
                                                        .b3
                                                        .fontSize,
                                                fontWeight:
                                                    FontWeight
                                                        .bold,
                                              ),
                                              formatLargeNumberDoubleWidgetDecimal(
                                                widget
                                                    .mainReceipt
                                                    .cashAlt,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Visibility(
                                        visible:
                                            widget
                                                    .mainReceipt
                                                    .paymentMethod ==
                                                'Split' ||
                                            widget
                                                    .mainReceipt
                                                    .paymentMethod ==
                                                'Bank',
                                        child: Row(
                                          spacing: 5,
                                          children: [
                                            Text(
                                              style: TextStyle(
                                                fontSize:
                                                    widget
                                                        .theme
                                                        .mobileTexts
                                                        .b3
                                                        .fontSize,
                                                fontWeight:
                                                    FontWeight
                                                        .normal,
                                              ),
                                              'Bank:',
                                            ),
                                            Text(
                                              style: TextStyle(
                                                fontSize:
                                                    widget
                                                        .theme
                                                        .mobileTexts
                                                        .b3
                                                        .fontSize,
                                                fontWeight:
                                                    FontWeight
                                                        .bold,
                                              ),
                                              formatLargeNumberDoubleWidgetDecimal(
                                                widget
                                                    .mainReceipt
                                                    .bank,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Divider(),
                        Row(
                          children: [
                            Text(
                              style: TextStyle(
                                fontSize:
                                    widget
                                        .theme
                                        .mobileTexts
                                        .b1
                                        .fontSize,
                                fontWeight: FontWeight.bold,
                              ),
                              'Product Record',
                            ),
                          ],
                        ),
                        ListView.builder(
                          physics:
                              NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: productRecords.length,
                          itemBuilder: (context, index) {
                            var productRecord =
                                productRecords[index];
                            var product = returnData(
                                  context,
                                  listen: false,
                                )
                                .returnOwnProducts(context)
                                .firstWhere(
                                  (record) =>
                                      record.id ==
                                      productRecord
                                          .productId,
                                );
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(
                                    vertical: 8.0,
                                  ),
                              child: SizedBox(
                                child: Row(
                                  spacing: 10,
                                  mainAxisAlignment:
                                      MainAxisAlignment
                                          .spaceBetween,
                                  children: [
                                    Expanded(
                                      flex: 6,
                                      child: Column(
                                        spacing: 3,
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
                                                      .b1
                                                      .fontSize,
                                            ),
                                            product.name,
                                          ),
                                          Text(
                                            style: TextStyle(
                                              fontSize:
                                                  widget
                                                      .theme
                                                      .mobileTexts
                                                      .b3
                                                      .fontSize,
                                            ),
                                            'Qty: ${productRecord.quantity.toStringAsFixed(0)} Item(s)',
                                          ),
                                        ],
                                      ),
                                    ),
                                    Visibility(
                                      visible:
                                          !widget.isMain,
                                      child: Checkbox(
                                        value: returnSalesProvider(
                                              context,
                                            )
                                            .productIdsToRefund
                                            .contains(
                                              productRecord
                                                  .productRecordId,
                                            ),
                                        onChanged: (value) {
                                          if (returnSalesProvider(
                                                context,
                                                listen:
                                                    false,
                                              )
                                              .productIdsToRefund
                                              .contains(
                                                productRecord
                                                    .productRecordId,
                                              )) {
                                            returnSalesProvider(
                                              context,
                                              listen: false,
                                            ).removeProductIdFromRefund(
                                              productRecord
                                                  .productRecordId,
                                            );
                                          } else {
                                            returnSalesProvider(
                                              context,
                                              listen: false,
                                            ).addproductIdToRefund(
                                              productRecord
                                                  .productRecordId,
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Column(
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
                                                      .b1
                                                      .fontSize,
                                              fontWeight:
                                                  FontWeight
                                                      .bold,
                                            ),
                                            'N${formatLargeNumberDouble(productRecord.revenue)}',
                                          ),
                                          Visibility(
                                            visible:
                                                productRecord
                                                    .discount !=
                                                null,
                                            child: Text(
                                              style: TextStyle(
                                                decoration:
                                                    TextDecoration
                                                        .lineThrough,
                                                fontSize:
                                                    widget
                                                        .theme
                                                        .mobileTexts
                                                        .b2
                                                        .fontSize,
                                                fontWeight:
                                                    FontWeight
                                                        .normal,
                                              ),
                                              'N${formatLargeNumberDouble(productRecord.originalCost!)}',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 5),
                Divider(),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 6,
                          child: Text(
                            style: TextStyle(
                              fontSize:
                                  widget
                                      .theme
                                      .mobileTexts
                                      .b1
                                      .fontSize,
                            ),
                            'Subtotal',
                          ),
                        ),

                        Expanded(
                          flex: 3,
                          child: Text(
                            style: TextStyle(
                              fontSize:
                                  widget
                                      .theme
                                      .mobileTexts
                                      .b2
                                      .fontSize,
                              fontWeight: FontWeight.bold,
                            ),
                            'N${formatLargeNumberDouble(returnReceiptProvider(context, listen: false).getSubTotalRevenueForReceipt(context, widget.mainReceipt))}',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 0),
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 6,
                          child: Text(
                            style: TextStyle(
                              fontSize:
                                  widget
                                      .theme
                                      .mobileTexts
                                      .b1
                                      .fontSize,
                            ),
                            'Discount',
                          ),
                        ),

                        Expanded(
                          flex: 3,
                          child: Text(
                            style: TextStyle(
                              fontSize:
                                  widget
                                      .theme
                                      .mobileTexts
                                      .b2
                                      .fontSize,
                              fontWeight: FontWeight.bold,
                            ),
                            'N${formatLargeNumberDoubleWidgetDecimal(returnReceiptProvider(context, listen: false).getTotalMainRevenueReceipt(widget.mainReceipt, context) - returnReceiptProvider(context, listen: false).getSubTotalRevenueForReceipt(context, widget.mainReceipt))}',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 0),
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 6,
                          child: Text(
                            style: TextStyle(
                              fontSize:
                                  widget
                                      .theme
                                      .mobileTexts
                                      .b1
                                      .fontSize,
                            ),
                            'Total',
                          ),
                        ),

                        Expanded(
                          flex: 3,
                          child: Text(
                            style: TextStyle(
                              fontSize:
                                  widget
                                      .theme
                                      .mobileTexts
                                      .b1
                                      .fontSize,
                              fontWeight: FontWeight.bold,
                            ),
                            'N${formatLargeNumberDoubleWidgetDecimal(returnReceiptProvider(context, listen: false).getTotalMainRevenueReceipt(widget.mainReceipt, context))}',
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
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 10,
          children: [
            BottomActionButton(
              text: 'Finish',
              color: Colors.grey.shade600,
              iconSize: 25,
              theme: widget.theme,
              icon: Icons.home_outlined,
              action: () {
                Navigator.popUntil(
                  context,
                  ModalRoute.withName('/'),
                );
              },
            ),
            BottomActionButton(
              text: 'Refund',
              color: Colors.grey.shade600,
              iconSize: 23,
              theme: widget.theme,
              icon: Icons.print_outlined,
              action: () {
                returnSalesProvider(
                  context,
                  listen: false,
                ).refundProducts(
                  returnSalesProvider(
                    context,
                    listen: false,
                  ).productIdsToRefund,
                  widget.mainReceipt,
                  context,
                );
              },
            ),
            BottomActionButton(
              text: 'Download',
              color: Colors.grey.shade600,
              iconSize: 23,
              theme: widget.theme,
              icon: Icons.download_outlined,
              action: () {},
            ),
          ],
        ),
      ],
    );
  }
}

class BottomActionButton extends StatelessWidget {
  final String text;
  final Function()? action;
  final IconData? icon;
  final Color color;
  final double iconSize;
  final ThemeProvider theme;
  final String? svg;

  const BottomActionButton({
    super.key,
    required this.text,
    this.action,
    this.icon,
    required this.color,
    required this.iconSize,
    required this.theme,
    this.svg,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: action,
        borderRadius: BorderRadius.circular(5),
        child: Container(
          height: 35,
          width: 100,
          padding: EdgeInsets.symmetric(
            vertical: 7,
            horizontal: 10,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: Colors.grey.shade400),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceAround,
              children: [
                Text(
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b3.fontSize,
                  ),
                  text,
                ),
                Stack(
                  children: [
                    Visibility(
                      visible: icon != null,
                      child: Icon(
                        size: iconSize,
                        color: color,
                        icon ??
                            Icons.delete_outline_rounded,
                      ),
                    ),
                    Visibility(
                      visible: svg != null,
                      child: SvgPicture.asset(
                        svg ?? '',
                        height: iconSize,
                      ),
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
