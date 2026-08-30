import 'package:flutter/material.dart';
import 'package:stockall/classes/checkout_response.dart';
import 'package:stockall/components/buttons/floating_action_butto.dart';
import 'package:stockall/components/list_tiles/main_invoice_tile.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/date_picker_function.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/refresh_functions.dart';
import 'package:stockall/constants/subscription/sales_auth.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/invoices/search_receipt/search_invoice_page.dart';
import 'package:stockall/pages/products/compnents/product_filter_button.dart';
import 'package:stockall/pages/sales/make_sales/page1/make_sales_page.dart';
import 'package:stockall/pages/sales/make_sales/receipt_page/receipt_page.dart';

class InvoiceListMobile extends StatefulWidget {
  final String? agentUuid;
  final String? customerUuid;
  const InvoiceListMobile({
    super.key,
    this.agentUuid,
    this.customerUuid,
  });

  @override
  State<InvoiceListMobile> createState() =>
      InvoiceListMobileState();
}

class InvoiceListMobileState
    extends State<InvoiceListMobile> {
  Future<void> getInvoices() async {
    await RefreshFunctions(
      context,
    ).refreshInvoices(context);
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
    returnInvoicesProvider().clearDate();
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Scaffold(
      appBar: appBar(
        context: context,
        title: 'All Invoices',
        widget: Row(
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                mouseCursor: SystemMouseCursors.click,
                borderRadius: BorderRadius.circular(5),
                onTap: () {
                  showSearchInvoicePage(context);
                },
                child: Padding(
                  padding: EdgeInsetsGeometry.all(6.5),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            style: TextStyle(
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b3
                                      .fontSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
                            ),
                            'Search',
                          ),
                          SizedBox(width: 3),
                        ],
                      ),
                      Icon(
                        size: 20,
                        // color:
                        //     theme
                        //         .lightModeColor
                        //         .secColor100,
                        Icons.manage_search_rounded,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: 20),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButtonMain(
        action: () {
          SalesAuthAction().invoiceManagementAction(
            context: context,
            action: () {
              if (authorization(
                authorized: Authorizations().makeSale,
              )) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return MakeSalesPage(
                        cartItemTypeIndex: 2,
                      );
                    },
                  ),
                ).then((_) {
                  setState(() {});
                });
              }
            },
          );
        },
        color: theme.lightModeColor.secColor100,
        text: 'Create Invoice',
        theme: theme,
      ),
      body: InvoiceListBodyMobile(
        agentUuid: widget.agentUuid,
        customerUuid: widget.customerUuid,
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

class InvoiceListBodyMobile extends StatefulWidget {
  final String? customerUuid;
  final String? agentUuid;
  final String? subStaffId;
  const InvoiceListBodyMobile({
    super.key,
    this.customerUuid,
    this.agentUuid,
    this.subStaffId,
  });

  @override
  State<InvoiceListBodyMobile> createState() =>
      _InvoiceListBodyMobileState();
}

class _InvoiceListBodyMobileState
    extends State<InvoiceListBodyMobile> {
  Future<void> getInvoices() async {
    await RefreshFunctions(
      context,
    ).refreshInvoices(context);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
                      title: 'Unpaid Balance',
                      value: returnInvoicesProvider(
                        context: context,
                      ).getTotalRevenueForSelectedDayAll(
                        customerId: widget.customerUuid,
                        staffId: widget.agentUuid,
                        subStaffId: widget.subStaffId,
                      ),
                    ),
                    ValueSummaryTabSmall(
                      value:
                          widget.agentUuid != null
                              ? returnInvoicesProvider(
                                    context: context,
                                  )
                                  .returnInvoicesByDayOrWeekAll(
                                    // context,
                                  )
                                  .where(
                                    (receipt) =>
                                        receipt.staffId ==
                                        widget.agentUuid,
                                  )
                                  .toList()
                                  .length
                                  .toDouble()
                              : widget.subStaffId != null
                              ? returnInvoicesProvider(
                                    context: context,
                                  )
                                  .returnInvoicesByDayOrWeekAll(
                                    // context,
                                  )
                                  .where(
                                    (receipt) =>
                                        receipt
                                            .subStaffUuid ==
                                        widget.subStaffId,
                                  )
                                  .toList()
                                  .length
                                  .toDouble()
                              : widget.customerUuid != null
                              ? returnInvoicesProvider(
                                    context: context,
                                  )
                                  .returnInvoicesByDayOrWeekAll(
                                    // context,
                                  )
                                  .where(
                                    (receipt) =>
                                        receipt
                                            .customerUuid ==
                                        widget.customerUuid,
                                  )
                                  .toList()
                                  .length
                                  .toDouble()
                              : returnInvoicesProvider(
                                    context: context,
                                  )
                                  .returnInvoicesByDayOrWeekAll()
                                  .toList()
                                  .length
                                  .toDouble(),
                      title: 'Invoice Number',
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
                    vertical: 10.0,
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
                          'All',
                        ),
                      ),
                      SizedBox(width: 5),
                      Expanded(
                        child: Center(
                          child: SingleChildScrollView(
                            scrollDirection:
                                Axis.horizontal,
                            child: Row(
                              spacing: 6,
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                ProductsFilterButton(
                                  action: () {
                                    returnInvoicesProvider()
                                        .selectPaymentStatus(
                                          0,
                                        );
                                  },
                                  currentSelected:
                                      returnInvoicesProvider(
                                        context: context,
                                      ).invoicePaymentStatusIndex,
                                  number: 0,
                                  title: 'Unpaid',
                                  theme: theme,
                                ),
                                ProductsFilterButton(
                                  action: () {
                                    returnInvoicesProvider()
                                        .selectPaymentStatus(
                                          1,
                                        );
                                  },
                                  currentSelected:
                                      returnInvoicesProvider(
                                        context: context,
                                      ).invoicePaymentStatusIndex,
                                  number: 1,
                                  title: 'Paid',
                                  theme: theme,
                                ),
                                ProductsFilterButton(
                                  action: () {
                                    returnInvoicesProvider()
                                        .selectPaymentStatus(
                                          2,
                                        );
                                  },
                                  currentSelected:
                                      returnInvoicesProvider(
                                        context: context,
                                      ).invoicePaymentStatusIndex,
                                  number: 2,
                                  title: 'Partial',
                                  theme: theme,
                                ),
                                ProductsFilterButton(
                                  currentSelected:
                                      returnInvoicesProvider(
                                        context: context,
                                      ).invoicePaymentStatusIndex,
                                  action: () {
                                    returnInvoicesProvider()
                                        .selectPaymentStatus(
                                          3,
                                        );
                                  },
                                  number: 3,
                                  title: 'All',
                                  theme: theme,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 5),
                      Visibility(
                        visible: authorization(
                          authorized:
                              Authorizations().viewDate,
                        ),
                        child: InkWell(
                          mouseCursor:
                              SystemMouseCursors.click,
                          onTap: () {
                            if (returnInvoicesProvider()
                                        .dateSet !=
                                    null ||
                                returnInvoicesProvider()
                                        .rangeStartDate !=
                                    null) {
                              returnInvoicesProvider()
                                  .clearDate();
                            } else {
                              mainDatePicker(
                                context: context,
                                theme: theme,
                                singleDate: (date) {
                                  returnInvoicesProvider()
                                      .setDate(date!);
                                },
                                rangeDate: (
                                  firstDate,
                                  lastDate,
                                ) {
                                  returnInvoicesProvider()
                                      .setRange(
                                        firstDate!,
                                        lastDate ??
                                            DateTime.now(),
                                      );
                                },
                              );
                            }
                          },
                          child: Icon(
                            size: 20,
                            color:
                                theme
                                    .lightModeColor
                                    .secColor100,
                            returnInvoicesProvider(
                                          context: context,
                                        ).dateSet !=
                                        null ||
                                    returnInvoicesProvider(
                                          context: context,
                                        ).rangeStartDate !=
                                        null
                                ? Icons.clear
                                : Icons.date_range_outlined,
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
                if (widget.agentUuid != null
                    ? returnInvoicesProvider(
                          context: context,
                        )
                        .returnInvoicesByDayOrWeekAll(
                          // context,
                        )
                        .toList()
                        .where(
                          (rec) =>
                              rec.staffId ==
                              widget.agentUuid,
                        )
                        .toList()
                        .isEmpty
                    : widget.subStaffId != null
                    ? returnInvoicesProvider(
                          context: context,
                        )
                        .returnInvoicesByDayOrWeekAll(
                          // context,
                        )
                        .toList()
                        .where(
                          (rec) =>
                              rec.subStaffUuid ==
                              widget.subStaffId,
                        )
                        .toList()
                        .isEmpty
                    : widget.customerUuid != null
                    ? returnInvoicesProvider(
                          context: context,
                        )
                        .returnInvoicesByDayOrWeekAll()
                        .where(
                          (rec) =>
                              rec.customerUuid ==
                              widget.customerUuid,
                        )
                        .toList()
                        .isEmpty
                    : returnInvoicesProvider(
                          context: context,
                        )
                        .returnInvoicesByDayOrWeekAll()
                        .toList()
                        .isEmpty) {
                  return EmptyWidgetDisplayOnly(
                    title: 'Empty List',
                    subText:
                        'You don\'t have any Sales under this category',
                    icon: Icons.clear,
                    theme: theme,
                    height: 35,
                    altAction: () {
                      getInvoices();
                    },
                    altActionText: 'Refresh List',
                  );
                } else {
                  return RefreshIndicator(
                    onRefresh: getInvoices,
                    backgroundColor: Colors.white,
                    color: theme.lightModeColor.prColor300,
                    displacement: 10,
                    child: ListView.builder(
                      itemCount:
                          widget.agentUuid != null
                              ? returnInvoicesProvider(
                                    context: context,
                                  )
                                  .returnInvoicesByDayOrWeekAll()
                                  .where(
                                    (rec) =>
                                        rec.staffId ==
                                        widget.agentUuid,
                                  )
                                  .toList()
                                  .length
                              : widget.subStaffId != null
                              ? returnInvoicesProvider(
                                    context: context,
                                  )
                                  .returnInvoicesByDayOrWeekAll()
                                  .where(
                                    (rec) =>
                                        rec.subStaffUuid ==
                                        widget.subStaffId,
                                  )
                                  .toList()
                                  .length
                              : widget.customerUuid != null
                              ? returnInvoicesProvider(
                                    context: context,
                                  )
                                  .returnInvoicesByDayOrWeekAll(
                                    // context,
                                  )
                                  .where(
                                    (rec) =>
                                        rec.customerUuid ==
                                        widget.customerUuid,
                                  )
                                  .toList()
                                  .length
                              : returnInvoicesProvider(
                                    context: context,
                                  )
                                  .returnInvoicesByDayOrWeekAll(
                                    // context,
                                  )
                                  .toList()
                                  .length,
                      itemBuilder: (context, index) {
                        var invoice =
                            widget.agentUuid != null
                                ? returnInvoicesProvider(
                                      context: context,
                                    )
                                    .returnInvoicesByDayOrWeekAll(
                                      // context,
                                    )
                                    .where(
                                      (rec) =>
                                          rec.staffId ==
                                          widget.agentUuid,
                                    )
                                    .toList()[index]
                                : widget.subStaffId != null
                                ? returnInvoicesProvider(
                                      context: context,
                                    )
                                    .returnInvoicesByDayOrWeekAll(
                                      // context,
                                    )
                                    .where(
                                      (rec) =>
                                          rec.subStaffUuid ==
                                          widget.subStaffId,
                                    )
                                    .toList()[index]
                                : widget.customerUuid !=
                                    null
                                ? returnInvoicesProvider(
                                      context: context,
                                    )
                                    .returnInvoicesByDayOrWeekAll(
                                      // context,
                                    )
                                    .where(
                                      (rec) =>
                                          rec.customerUuid ==
                                          widget
                                              .customerUuid,
                                    )
                                    .toList()[index]
                                : returnInvoicesProvider(
                                      context: context,
                                    )
                                    .returnInvoicesByDayOrWeekAll()
                                    .toList()[index];
                        return MainInvoiceTile(
                          action: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return ReceiptPage(
                                    response:
                                        CheckoutResponse(
                                          invoice: invoice,
                                        ),
                                    isMain: false,
                                  );
                                },
                              ),
                            ).then((_) {
                              setState(() {});
                            });
                          },
                          key: ValueKey(invoice.uuid),
                          invoice: invoice,
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
    );
  }
}
