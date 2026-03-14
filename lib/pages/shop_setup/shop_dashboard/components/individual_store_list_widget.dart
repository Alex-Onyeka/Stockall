import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_shop/temp_shop_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/shop_setup/shop_dashboard/components/individual_store_price_box_widget.dart';
import 'package:stockall/pages/shop_setup/shop_page/shop_page.dart';

class IndividualStoreListWidget extends StatefulWidget {
  const IndividualStoreListWidget({
    super.key,
    required this.shop,
  });

  final TempShopClass shop;

  @override
  State<IndividualStoreListWidget> createState() =>
      _IndividualStoreListWidgetState();
}

class _IndividualStoreListWidgetState
    extends State<IndividualStoreListWidget> {
  bool isOpen = false;

  void toggleIsOpen() {
    setState(() {
      isOpen = !isOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 15,
        ),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.grey.shade300),
            // bottom: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        child: Column(
          spacing: 5,
          children: [
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Row(
                    spacing: 10,
                    children: [
                      Icon(
                        size: 20,
                        color:
                            returnShopProvider()
                                        .userShop()
                                        ?.shopId ==
                                    widget.shop.shopId
                                ? theme
                                    .lightModeColor
                                    .prColor250
                                : Colors.grey,
                        returnShopProvider()
                                    .userShop()
                                    ?.shopId ==
                                widget.shop.shopId
                            ? Icons.other_houses_rounded
                            : Icons.other_houses_outlined,
                      ),
                      Flexible(
                        child: Text(
                          style: TextStyle(
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b2
                                    .fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                          widget.shop.name.toUpperCase(),
                        ),
                      ),
                      Visibility(
                        visible:
                            widget.shop.isHeadQuarters ==
                            true,
                        child: Text(
                          style: TextStyle(
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b4
                                    .fontSize,
                            fontWeight: FontWeight.normal,
                            color:
                                theme
                                    .lightModeColor
                                    .secColor200,
                          ),
                          '( H.Q )',
                        ),
                      ),
                    ],
                  ),
                ),
                Visibility(
                  visible:
                      returnShopProvider()
                          .userShop()
                          ?.shopId ==
                      widget.shop.shopId,
                  child: Icon(
                    size: 20,
                    color: theme.lightModeColor.secColor200,
                    Icons.check,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Container(
              padding:
                  isOpen
                      ? (screenWidth(context) > mobileScreen
                          ? EdgeInsets.all(15)
                          : EdgeInsets.all(10))
                      : (screenWidth(context) > mobileScreen
                          ? EdgeInsets.fromLTRB(
                            15,
                            5,
                            15,
                            5,
                          )
                          : EdgeInsets.fromLTRB(
                            10,
                            5,
                            10,
                            5,
                          )),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: const Color.fromARGB(
                  255,
                  245,
                  245,
                  245,
                ),
              ),
              child: Column(
                spacing: 0,
                children: [
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        spacing: 0,
                        children: [
                          Text(
                            style: TextStyle(
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b4
                                      .fontSize,
                              fontWeight: FontWeight.normal,
                              color: Colors.grey,
                            ),
                            'Total Revenue:',
                          ),
                          Text(
                            style: TextStyle(
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b1
                                      .fontSize,
                              fontWeight: FontWeight.bold,
                            ),
                            formatMoneyMid(
                              amount:
                                  returnShopDashboardProvider(
                                    context: context,
                                  ).returnTotalRevenue(
                                    shop: widget.shop,
                                  ),
                              context: context,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () {
                          toggleIsOpen();
                        },
                        icon: Icon(
                          size: 22,
                          color: Colors.grey,
                          isOpen
                              ? Icons
                                  .keyboard_arrow_up_rounded
                              : Icons
                                  .keyboard_arrow_down_rounded,
                        ),
                      ),
                    ],
                  ),
                  Visibility(
                    visible: isOpen,
                    child: Column(
                      spacing: 10,
                      children: [
                        SizedBox(height: 10),
                        Row(
                          spacing: 10,
                          children: [
                            IndividualStorePriceBoxWidget(
                              title: 'Total Expenses',
                              isMoney: true,
                              value:
                                  returnShopDashboardProvider(
                                    context: context,
                                  ).returnTotalExpenses(
                                    shop: widget.shop,
                                  ),
                            ),
                            IndividualStorePriceBoxWidget(
                              title: 'Total Profit',
                              isMoney: true,
                              value:
                                  returnShopDashboardProvider(
                                    context: context,
                                  ).returnProfit(
                                    shop: widget.shop,
                                  ),
                            ),
                          ],
                        ),
                        Row(
                          spacing: 10,
                          children: [
                            IndividualStorePriceBoxWidget(
                              title: 'Total Sales',
                              isMoney: false,
                              value:
                                  returnShopDashboardProvider(
                                        context: context,
                                      )
                                      .returnReceipts(
                                        shop: widget.shop,
                                      )
                                      .length
                                      .toDouble(),
                            ),
                            IndividualStorePriceBoxWidget(
                              title: 'Total Invoice',
                              isMoney: false,
                              value:
                                  returnShopDashboardProvider(
                                        context: context,
                                      )
                                      .returnInvoices(
                                        shop: widget.shop,
                                      )
                                      .length
                                      .toDouble(),
                            ),
                          ],
                        ),
                        Row(
                          spacing: 10,
                          children: [
                            IndividualStorePriceBoxWidget(
                              title: 'Total Staff',
                              isMoney: false,
                              value:
                                  returnShopDashboardProvider(
                                        context: context,
                                      )
                                      .returnStaffs(
                                        shop: widget.shop,
                                      )
                                      .length
                                      .toDouble(),
                            ),
                            IndividualStorePriceBoxWidget(
                              title: 'Total Customer',
                              isMoney: false,
                              value:
                                  returnShopDashboardProvider(
                                        context: context,
                                      )
                                      .returnCustomers(
                                        shop: widget.shop,
                                      )
                                      .length
                                      .toDouble(),
                            ),
                          ],
                        ),
                        Row(
                          spacing: 10,
                          children: [
                            IndividualStorePriceBoxWidget(
                              title: 'Total Items',
                              isMoney: false,
                              value:
                                  returnShopDashboardProvider(
                                    context: context,
                                  ).returnAllItems(
                                    shop: widget.shop,
                                  ),
                            ),
                            IndividualStorePriceBoxWidget(
                              title: 'Total Items Value',
                              isMoney: true,
                              value:
                                  returnShopDashboardProvider(
                                    context: context,
                                  ).returnAllItemsValeu(
                                    shop: widget.shop,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: isOpen,
                    child: SizedBox(height: 10),
                  ),
                  Visibility(
                    visible:
                        screenWidth(context) > mobileScreen
                            ? true
                            : isOpen,
                    child: Row(
                      mainAxisAlignment:
                          screenWidth(context) >
                                  mobileScreen
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.center,
                      spacing:
                          screenWidth(context) >
                                  mobileScreen
                              ? 10
                              : 5,
                      children: [
                        Material(
                          color: Colors.transparent,
                          child: Ink(
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(3),
                              border: Border.all(
                                color: Colors.grey.shade200,
                              ),
                              color: Colors.white,
                            ),
                            child: InkWell(
                              onTap: () {
                                if (widget
                                            .shop
                                            .isHeadQuarters ==
                                        false &&
                                    !returnShopDashboardProvider()
                                        .isLoading) {
                                  showDialog(
                                    context: context,
                                    builder: (
                                      confirmDialog,
                                    ) {
                                      return ConfirmationAlert(
                                        theme: theme,
                                        message:
                                            'Are you sure you want to set this as your head quarter?',
                                        title:
                                            'Are you sure?',
                                        action: () async {
                                          Navigator.of(
                                            confirmDialog,
                                          ).pop();
                                          returnShopDashboardProvider()
                                              .toggleIsLoading(
                                                true,
                                              );
                                          await returnShopProvider()
                                              .setHeadQuarters(
                                                widget.shop,
                                              );
                                          returnShopDashboardProvider()
                                              .toggleIsLoading(
                                                false,
                                              );
                                        },
                                      );
                                    },
                                  );
                                }
                              },
                              borderRadius:
                                  BorderRadius.circular(5),
                              child: Container(
                                padding:
                                    EdgeInsets.symmetric(
                                      vertical: 7,
                                      horizontal: 10,
                                    ),
                                child: Row(
                                  mainAxisSize:
                                      MainAxisSize.min,
                                  mainAxisAlignment:
                                      MainAxisAlignment
                                          .center,
                                  spacing: 3,
                                  children: [
                                    Text(
                                      style: TextStyle(
                                        fontSize:
                                            theme
                                                .mobileTexts
                                                .b4
                                                .fontSize,
                                        color:
                                            Colors
                                                .grey
                                                .shade800,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                      'Make H.Q',
                                    ),
                                    Icon(
                                      size: 18,
                                      color: Colors.grey,
                                      Icons.check,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Material(
                          color: Colors.transparent,
                          child: Ink(
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(3),
                              border: Border.all(
                                color: Colors.grey.shade200,
                              ),
                              color: Colors.white,
                            ),
                            child: InkWell(
                              onTap: () {
                                if (returnShopProvider()
                                        .userShop()
                                        ?.shopId ==
                                    widget.shop.shopId) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return ShopPage();
                                      },
                                    ),
                                  );
                                } else {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return ConfirmationAlert(
                                        theme: theme,
                                        message:
                                            'You are about to Select this store as your current Store. Are you sure you want to proceed?',
                                        title:
                                            'Select Store',
                                        action: () {
                                          returnShopProvider()
                                              .selectShop(
                                                context,
                                                widget.shop,
                                              );
                                        },
                                      );
                                    },
                                  );
                                }
                              },
                              borderRadius:
                                  BorderRadius.circular(5),
                              child: Container(
                                padding:
                                    EdgeInsets.symmetric(
                                      vertical: 7,
                                      horizontal: 10,
                                    ),
                                child: Row(
                                  mainAxisSize:
                                      MainAxisSize.min,
                                  mainAxisAlignment:
                                      MainAxisAlignment
                                          .center,
                                  spacing: 3,
                                  children: [
                                    Text(
                                      style: TextStyle(
                                        fontSize:
                                            theme
                                                .mobileTexts
                                                .b4
                                                .fontSize,
                                        color:
                                            Colors
                                                .grey
                                                .shade800,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                      returnShopProvider()
                                                  .userShop()
                                                  ?.shopId ==
                                              widget
                                                  .shop
                                                  .shopId
                                          ? 'View Store'
                                          : 'Select Store',
                                    ),
                                    Icon(
                                      size: 16,
                                      color: Colors.grey,
                                      returnShopProvider()
                                                  .userShop()
                                                  ?.shopId ==
                                              widget
                                                  .shop
                                                  .shopId
                                          ? Icons
                                              .arrow_forward_ios_rounded
                                          : Icons.check,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
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
