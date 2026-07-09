import 'package:flutter/material.dart';
import 'package:stockall/components/buttons/floating_action_butto.dart';
import 'package:stockall/components/list_tiles/main_purchase_tile.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/date_picker_function.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/purchases/create_purchase/create_purchase.dart';
import 'package:stockall/pages/purchases/purchase_page/purchase_page.dart';

class PurchaseListMobile extends StatefulWidget {
  final String? id;
  final String? supplierId;
  const PurchaseListMobile({
    super.key,
    this.id,
    this.supplierId,
  });

  @override
  State<PurchaseListMobile> createState() =>
      _PurchaseListMobileState();
}

class _PurchaseListMobileState
    extends State<PurchaseListMobile> {
  Future<void> getPurchases() async {
    await returnPurchaseProvider().loadPurchases(shopId());
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      clearDate();
    });
  }

  void clearDate() {
    returnPurchaseProvider().clearDate();
  }

  int paidPurchaseIndex = 1;

  void switchPurchasePaymentIndex(int index) {
    setState(() {
      paidPurchaseIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return GestureDetector(
      onTap: () {
        returnPurchaseProvider().clearDate();
      },
      child: Scaffold(
        appBar: appBar(
          context: context,
          title: 'All Purchases',
          widget: Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: PopupMenuButton(
              offset: Offset(-20, 30),
              color: Colors.white,
              itemBuilder: (context) {
                return [
                  PopupMenuItem(
                    onTap: () {
                      switchPurchasePaymentIndex(1);
                    },
                    child: Text(
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b2.fontSize,
                        fontWeight:
                            paidPurchaseIndex == 1
                                ? FontWeight.bold
                                : null,
                      ),
                      'All',
                    ),
                  ),
                  PopupMenuItem(
                    onTap: () {
                      switchPurchasePaymentIndex(2);
                      returnData().toggleFloatingAction(
                        context,
                      );
                    },
                    child: Text(
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b2.fontSize,
                        fontWeight:
                            paidPurchaseIndex == 2
                                ? FontWeight.bold
                                : null,
                      ),
                      'Fully Paid',
                    ),
                  ),
                  PopupMenuItem(
                    onTap: () {
                      switchPurchasePaymentIndex(3);
                      returnData().toggleFloatingAction(
                        context,
                      );
                    },
                    child: Text(
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b2.fontSize,
                        fontWeight:
                            paidPurchaseIndex == 4
                                ? FontWeight.bold
                                : null,
                      ),
                      'UnPaid',
                    ),
                  ),
                ];
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.b3.fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                    paidPurchaseIndex == 1
                        ? 'All'
                        : paidPurchaseIndex == 2
                        ? 'Fully Paid'
                        : 'UnPaid',
                  ),
                  Icon(Icons.more_vert_rounded),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButtonMain(
          action: () {
            // SalesAuthAction().invoiceManagementAction(
            //   context: context,
            //   action: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return CreatePurchase();
                },
              ),
            ).then((_) {
              getPurchases();
            });
          },
          color: theme.lightModeColor.secColor100,
          text: 'Create Purchase',
          theme: theme,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20.0,
          ),
          child: Column(
            children: [
              Material(
                color: Colors.white,
                child: Column(
                  children: [
                    Row(
                      spacing: 10,
                      children: [
                        ValueSummaryTabSmall(
                          color: Colors.amber,
                          isMoney: true,
                          title: 'Total Amount',
                          value: returnPurchaseProvider()
                              .getTotalRevenueForSelectedDayAll(
                                supplierUuid:
                                    widget.supplierId,
                                staffId: widget.id,
                                index: paidPurchaseIndex,
                              ),
                        ),
                        ValueSummaryTabSmall(
                          value:
                              widget.id != null
                                  ? returnPurchaseProvider(
                                        context: context,
                                      )
                                      .returnOwnPurchasesByDayOrWeek(
                                        index:
                                            paidPurchaseIndex,
                                      )
                                      .where(
                                        (purchase) =>
                                            purchase
                                                .staffId ==
                                            widget.id,
                                      )
                                      .toList()
                                      .length
                                      .toDouble()
                                  : widget.supplierId !=
                                      null
                                  ? returnPurchaseProvider(
                                        context: context,
                                      )
                                      .returnOwnPurchasesByDayOrWeek(
                                        index:
                                            paidPurchaseIndex,
                                      )
                                      .where(
                                        (purchase) =>
                                            purchase
                                                .supplierId ==
                                            widget
                                                .supplierId,
                                      )
                                      .toList()
                                      .length
                                      .toDouble()
                                  : returnPurchaseProvider(
                                        context: context,
                                      )
                                      .returnOwnPurchasesByDayOrWeek(
                                        index:
                                            paidPurchaseIndex,
                                      )
                                      .toList()
                                      .length
                                      .toDouble(),
                          title: 'Purchase Number',
                          color: Colors.green,
                          isMoney: false,
                        ),
                      ],
                    ),
                    Visibility(
                      visible:
                          !authorization(
                            authorized:
                                Authorizations().viewDate,
                          ),
                      child: SizedBox(height: 20),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 6.0,
                      ),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Visibility(
                            visible: authorization(
                              authorized:
                                  Authorizations().viewDate,
                            ),
                            child: Text(
                              style: TextStyle(
                                fontSize:
                                    theme
                                        .mobileTexts
                                        .b3
                                        .fontSize,
                                fontWeight: FontWeight.bold,
                              ),
                              returnPurchaseProvider(
                                            context:
                                                context,
                                          ).dateSet !=
                                          null ||
                                      returnPurchaseProvider(
                                            context:
                                                context,
                                          ).rangeStartDate !=
                                          null
                                  ? 'All'
                                  : 'Today',
                            ),
                          ),
                          Visibility(
                            visible: authorization(
                              authorized:
                                  Authorizations().viewDate,
                            ),
                            child: InkWell(
                              onTap: () {
                                if (returnPurchaseProvider()
                                            .dateSet !=
                                        null ||
                                    returnPurchaseProvider()
                                            .rangeStartDate !=
                                        null) {
                                  returnPurchaseProvider()
                                      .clearDate();
                                } else {
                                  mainDatePicker(
                                    context: context,
                                    theme: theme,
                                    singleDate: (date) {
                                      returnPurchaseProvider()
                                          .setDate(date!);
                                    },
                                    rangeDate: (
                                      firstDate,
                                      lastDate,
                                    ) {
                                      returnPurchaseProvider()
                                          .setRange(
                                            firstDate!,
                                            lastDate ??
                                                DateTime.now(),
                                          );
                                    },
                                  );
                                }
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.all(
                                      4.0,
                                    ),
                                child: Icon(
                                  size: 20,
                                  color:
                                      theme
                                          .lightModeColor
                                          .secColor100,
                                  returnPurchaseProvider(
                                                context:
                                                    context,
                                              ).dateSet !=
                                              null ||
                                          returnPurchaseProvider(
                                                context:
                                                    context,
                                              ).rangeStartDate !=
                                              null
                                      ? Icons.clear
                                      : Icons
                                          .date_range_outlined,
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
              Expanded(
                child: Builder(
                  builder: (context) {
                    if (widget.id != null
                        ? returnPurchaseProvider(
                              context: context,
                            )
                            .returnOwnPurchasesByDayOrWeek(
                              index: paidPurchaseIndex,
                            )
                            .toList()
                            .where(
                              (rec) =>
                                  rec.staffId == widget.id,
                            )
                            .toList()
                            .isEmpty
                        : widget.supplierId != null
                        ? returnPurchaseProvider(
                              context: context,
                            )
                            .returnOwnPurchasesByDayOrWeek(
                              index: paidPurchaseIndex,
                            )
                            .where(
                              (rec) =>
                                  rec.supplierId ==
                                  widget.supplierId,
                            )
                            .toList()
                            .isEmpty
                        : returnPurchaseProvider(
                              context: context,
                            )
                            .returnOwnPurchasesByDayOrWeek(
                              index: paidPurchaseIndex,
                            )
                            .toList()
                            .isEmpty) {
                      return EmptyWidgetDisplayOnly(
                        title: 'Empty List',
                        subText:
                            'You don\'t have any Purchases under this category',
                        icon: Icons.clear,
                        theme: theme,
                        height: 35,
                        altAction: () {
                          getPurchases();
                        },
                        altActionText: 'Refresh List',
                      );
                    } else {
                      return RefreshIndicator(
                        onRefresh: getPurchases,
                        backgroundColor: Colors.white,
                        color:
                            theme.lightModeColor.prColor300,
                        displacement: 10,
                        child: ListView.builder(
                          itemCount:
                              widget.id != null
                                  ? returnPurchaseProvider(
                                        context: context,
                                      )
                                      .returnOwnPurchasesByDayOrWeek(
                                        index:
                                            paidPurchaseIndex,
                                      )
                                      .where(
                                        (rec) =>
                                            rec.staffId ==
                                            widget.id,
                                      )
                                      .toList()
                                      .length
                                  : widget.supplierId !=
                                      null
                                  ? returnPurchaseProvider(
                                        context: context,
                                      )
                                      .returnOwnPurchasesByDayOrWeek(
                                        index:
                                            paidPurchaseIndex,
                                      )
                                      .where(
                                        (rec) =>
                                            rec.supplierId ==
                                            widget
                                                .supplierId,
                                      )
                                      .toList()
                                      .length
                                  : returnPurchaseProvider(
                                        context: context,
                                      )
                                      .returnOwnPurchasesByDayOrWeek(
                                        index:
                                            paidPurchaseIndex,
                                      )
                                      .toList()
                                      .length,
                          itemBuilder: (context, index) {
                            var purchase =
                                widget.id != null
                                    ? returnPurchaseProvider(
                                          context: context,
                                        )
                                        .returnOwnPurchasesByDayOrWeek(
                                          index:
                                              paidPurchaseIndex,
                                        )
                                        .where(
                                          (rec) =>
                                              rec.staffId ==
                                              widget.id,
                                        )
                                        .toList()[index]
                                    : widget.supplierId !=
                                        null
                                    ? returnPurchaseProvider(
                                          context: context,
                                        )
                                        .returnOwnPurchasesByDayOrWeek(
                                          index:
                                              paidPurchaseIndex,
                                        )
                                        .where(
                                          (rec) =>
                                              rec.supplierId ==
                                              widget
                                                  .supplierId,
                                        )
                                        .toList()[index]
                                    : returnPurchaseProvider(
                                          context: context,
                                        )
                                        .returnOwnPurchasesByDayOrWeek(
                                          index:
                                              paidPurchaseIndex,
                                        )
                                        .toList()[index];
                            return MainPurchaseTile(
                              action: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return PurchasePage(
                                        purchaseUuid:
                                            purchase.uuid!,
                                      );
                                    },
                                  ),
                                ).then((_) {
                                  getPurchases();
                                });
                              },
                              key: ValueKey(purchase.uuid),
                              purchase: purchase,
                            );
                          },
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ValueSummaryTabSmall extends StatelessWidget {
  final double value;
  final String title;
  final Color color;
  final bool isMoney;

  const ValueSummaryTabSmall({
    super.key,
    required this.value,
    required this.title,
    required this.color,
    required this.isMoney,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.grey.shade300),
          color: Colors.grey.shade200,
        ),
        child: Row(
          spacing: 10,
          children: [
            Container(
              height: 10,
              width: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
              ),
            ),
            Column(
              spacing: 0,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                  title,
                ),
                Row(
                  children: [
                    Visibility(
                      visible: false,
                      child: Text(
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                        "N",
                      ),
                    ),
                    SizedBox(width: 2),
                    Text(
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: Colors.grey.shade700,
                      ),
                      isMoney
                          ? formatMoneyMid(
                            amount: value,
                            context: context,
                          )
                          : formatLargeNumberDoubleWidgetDecimal(
                            value,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
