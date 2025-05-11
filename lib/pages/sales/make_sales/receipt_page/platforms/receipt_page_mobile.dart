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
  final TempMainReceipt mainReceipt;
  const ReceiptPageMobile({
    super.key,
    required this.mainReceipt,
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
                      title: 'Receipt',
                      theme: theme,
                      bottomSpace: 200,
                      topSpace: 40,
                    ),
                  ),
                  Positioned(
                    top: 90,
                    child: ReceiptDetailsContainer(
                      shop: shop,
                      user: user,
                      mainReceipt: mainReceipt,
                      theme: theme,
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

class ReceiptDetailsContainer extends StatelessWidget {
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
  });

  @override
  Widget build(BuildContext context) {
    var productRecords = returnReceiptProvider(
      context,
      // listen: false,
    ).getProductRecordsByReceiptId(mainReceipt.id, context);
    return Container(
      width: MediaQuery.of(context).size.width - 40,
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
      child: Column(
        children: [
          SizedBox(height: 5),
          Image.asset(mainLogoIcon, height: 40),
          SizedBox(height: 15),
          Column(
            spacing: 8,
            children: [
              Text(
                style: TextStyle(
                  fontSize: theme.mobileTexts.h4.fontSize,
                  fontWeight: FontWeight.bold,
                ),
                shop.name,
              ),
              Text(
                style: TextStyle(
                  fontSize: theme.mobileTexts.b2.fontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
                shop.email,
              ),
              Text(
                style: TextStyle(
                  fontSize: theme.mobileTexts.b2.fontSize,
                ),
                shop.shopAddress ?? 'Address Not Set',
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
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b1.fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                      'Casheir',
                    ),
                    Text(
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b2.fontSize,
                        fontWeight: FontWeight.normal,
                      ),
                      mainReceipt.staffName,
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b1.fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                      'Customer Name',
                    ),
                    Text(
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b2.fontSize,
                        fontWeight: FontWeight.normal,
                      ),
                      'Alex Onyeka',
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 25),
          Row(
            children: [
              Text(
                style: TextStyle(
                  fontSize: theme.mobileTexts.b1.fontSize,
                  fontWeight: FontWeight.bold,
                ),
                'Product Record',
              ),
            ],
          ),
          SizedBox(
            height:
                MediaQuery.of(context).size.height - 550,
            child: ListView.builder(
              itemCount: productRecords.length,
              itemBuilder: (context, index) {
                var productRecord = productRecords[index];
                var product = returnData(
                      context,
                      listen: false,
                    )
                    .returnOwnProducts(context)
                    .firstWhere(
                      (element) =>
                          element.id ==
                          productRecord.productId,
                    );
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                  ),
                  child: SizedBox(
                    child: Row(
                      spacing: 10,
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 6,
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
                                          .b1
                                          .fontSize,
                                ),
                                product.name,
                              ),
                              Text(
                                style: TextStyle(
                                  fontSize:
                                      theme
                                          .mobileTexts
                                          .b3
                                          .fontSize,
                                ),
                                'Qty: ${productRecord.quantity.toStringAsFixed(0)} Item(s)',
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                style: TextStyle(
                                  fontSize:
                                      theme
                                          .mobileTexts
                                          .b1
                                          .fontSize,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                                'N${product.discount != null ? formatLargeNumberDouble(productRecord.revenue * (1 - (product.discount! / 100))) : formatLargeNumberDouble(productRecord.revenue)}',
                              ),
                              Visibility(
                                visible:
                                    product.discount !=
                                    null,
                                child: Text(
                                  style: TextStyle(
                                    decoration:
                                        TextDecoration
                                            .lineThrough,
                                    fontSize:
                                        theme
                                            .mobileTexts
                                            .b2
                                            .fontSize,
                                    fontWeight:
                                        FontWeight.normal,
                                  ),
                                  'N${formatLargeNumberDouble(productRecord.revenue)}',
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
          ),
          SizedBox(height: 5),
          Divider(),
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 6,
                child: Text(
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b1.fontSize,
                  ),
                  'Subtotal',
                ),
              ),

              Expanded(
                flex: 3,
                child: Text(
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b2.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                  'N${formatLargeNumberDouble(returnReceiptProvider(context, listen: false).getTotalRevenue(context, mainReceipt))}',
                ),
              ),
            ],
          ),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 6,
                child: Text(
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b1.fontSize,
                  ),
                  'Discount',
                ),
              ),

              Expanded(
                flex: 3,
                child: Text(
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b2.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                  'N${formatLargeNumberDouble(returnReceiptProvider(context, listen: false).getTotalDiscountMainReceipt(mainReceipt, context))}',
                ),
              ),
            ],
          ),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 6,
                child: Text(
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b1.fontSize,
                  ),
                  'Total',
                ),
              ),

              Expanded(
                flex: 3,
                child: Text(
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b1.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                  'N${formatLargeNumberDouble(returnReceiptProvider(context, listen: false).getTotalRevenue(context, mainReceipt) - returnReceiptProvider(context, listen: false).getTotalDiscountMainReceipt(mainReceipt, context))}',
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 20,
            children: [
              BottomActionButton(
                text: 'Finish',
                color: Colors.grey,
                iconSize: 23,
                theme: theme,
                icon: Icons.clear,
                action: () {
                  Navigator.popUntil(
                    context,
                    ModalRoute.withName('/'),
                  );
                },
              ),
              BottomActionButton(
                text: 'Print',
                color: Colors.grey,
                iconSize: 23,
                theme: theme,
                icon: Icons.print_outlined,
              ),
            ],
          ),
        ],
      ),
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
