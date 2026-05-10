import 'package:flutter/material.dart';
import 'package:stockall/components/buttons/floating_action_butto.dart';
import 'package:stockall/components/list_tiles/main_waybill_tile.dart';
import 'package:stockall/components/major/desktop_page_container.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/date_picker_function.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/waybills/create_waybill/create_waybill.dart';
import 'package:stockall/pages/waybills/waybill_page/waybill_page.dart';

class WaybillListDesktop extends StatefulWidget {
  final String? id;
  final String? customerUuid;
  const WaybillListDesktop({
    super.key,
    this.id,
    this.customerUuid,
  });

  @override
  State<WaybillListDesktop> createState() =>
      _WaybillListDesktopState();
}

class _WaybillListDesktopState
    extends State<WaybillListDesktop> {
  Future<void> getWaybills() async {
    await returnWaybillProvider().loadWaybills(shopId());
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      clearDate();
    });
  }

  bool isLoading = false;

  int paidWaybillIndex = 1;

  void switchWaybillPaymentIndex(int index) {
    setState(() {
      paidWaybillIndex = index;
    });
  }

  void clearDate() {
    returnWaybillProvider().clearDate();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: [
          Row(
            spacing: 15,
            children: [
              Container(
                width:
                    screenWidth(context) < tabletScreenSmall
                        ? 50
                        : (screenWidth(context) >
                                tabletScreenSmall &&
                            screenWidth(context) <
                                tabletScreen + 100)
                        ? 100
                        : 230,
              ),
              Expanded(
                child: DesktopPageContainer(
                  widget: Scaffold(
                    appBar: appBar(
                      context: context,
                      title: 'All Waybills',
                      widget: Row(
                        spacing: 15,
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment:
                            MainAxisAlignment.end,
                        children: [
                          Visibility(
                            visible:
                                screenWidth(context) >
                                mobileScreen,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius:
                                    BorderRadius.circular(
                                      10,
                                    ),
                                onTap: () async {
                                  getWaybills();
                                },
                                child: Padding(
                                  padding:
                                      const EdgeInsets.all(
                                        10,
                                      ),
                                  child: Row(
                                    spacing: 5,
                                    children: [
                                      Text(
                                        style: TextStyle(
                                          fontSize:
                                              theme
                                                  .mobileTexts
                                                  .b3
                                                  .fontSize,
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                        ),
                                        'Refresh',
                                      ),
                                      Icon(
                                        size: 18,
                                        Icons
                                            .refresh_rounded,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              right: 15.0,
                            ),
                            child: PopupMenuButton(
                              offset: Offset(-20, 30),
                              color: Colors.white,
                              itemBuilder: (context) {
                                return [
                                  PopupMenuItem(
                                    onTap: () {
                                      switchWaybillPaymentIndex(
                                        1,
                                      );
                                    },
                                    child: Text(
                                      style: TextStyle(
                                        fontSize:
                                            theme
                                                .mobileTexts
                                                .b2
                                                .fontSize,
                                        fontWeight:
                                            paidWaybillIndex ==
                                                    1
                                                ? FontWeight
                                                    .bold
                                                : null,
                                      ),
                                      'All',
                                    ),
                                  ),
                                  PopupMenuItem(
                                    onTap: () {
                                      switchWaybillPaymentIndex(
                                        2,
                                      );
                                      returnData()
                                          .toggleFloatingAction(
                                            context,
                                          );
                                    },
                                    child: Text(
                                      style: TextStyle(
                                        fontSize:
                                            theme
                                                .mobileTexts
                                                .b2
                                                .fontSize,
                                        fontWeight:
                                            paidWaybillIndex ==
                                                    2
                                                ? FontWeight
                                                    .bold
                                                : null,
                                      ),
                                      'Fully Paid',
                                    ),
                                  ),
                                  PopupMenuItem(
                                    onTap: () {
                                      switchWaybillPaymentIndex(
                                        3,
                                      );
                                      returnData()
                                          .toggleFloatingAction(
                                            context,
                                          );
                                    },
                                    child: Text(
                                      style: TextStyle(
                                        fontSize:
                                            theme
                                                .mobileTexts
                                                .b2
                                                .fontSize,
                                        fontWeight:
                                            paidWaybillIndex ==
                                                    4
                                                ? FontWeight
                                                    .bold
                                                : null,
                                      ),
                                      'UnPaid',
                                    ),
                                  ),
                                ];
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment
                                        .center,
                                mainAxisSize:
                                    MainAxisSize.min,
                                children: [
                                  Text(
                                    style: TextStyle(
                                      fontSize:
                                          theme
                                              .mobileTexts
                                              .b3
                                              .fontSize,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                    paidWaybillIndex == 1
                                        ? 'All'
                                        : paidWaybillIndex ==
                                            2
                                        ? 'Fully Paid'
                                        : 'UnPaid',
                                  ),
                                  Icon(
                                    Icons.more_vert_rounded,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    floatingActionButton:
                        FloatingActionButtonMain(
                          action: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return CreateWaybill();
                                },
                              ),
                            ).then((_) {
                              setState(() {
                                // getProductList(context);
                              });
                            });
                            //       },
                            //     );
                          },
                          color:
                              theme
                                  .lightModeColor
                                  .secColor100,
                          text: 'Create Waybill',
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
                                      value: returnWaybillProvider(
                                        context: context,
                                      ).getTotalRevenueForSelectedDayAll(
                                        customerUuid:
                                            widget
                                                .customerUuid,
                                        staffId: widget.id,
                                        index:
                                            paidWaybillIndex,
                                      ),
                                    ),
                                    ValueSummaryTabSmall(
                                      value:
                                          widget.id != null
                                              ? returnWaybillProvider(
                                                    context:
                                                        context,
                                                  )
                                                  .returnOwnWaybillsByDayOrWeek(
                                                    index:
                                                        paidWaybillIndex,
                                                  )
                                                  .where(
                                                    (
                                                      waybill,
                                                    ) =>
                                                        waybill.staffId ==
                                                        widget.id,
                                                  )
                                                  .toList()
                                                  .length
                                                  .toDouble()
                                              : widget.customerUuid !=
                                                  null
                                              ? returnWaybillProvider(
                                                    context:
                                                        context,
                                                  )
                                                  .returnOwnWaybillsByDayOrWeek(
                                                    index:
                                                        paidWaybillIndex,
                                                  )
                                                  .where(
                                                    (
                                                      waybill,
                                                    ) =>
                                                        waybill.customerId ==
                                                        widget.customerUuid,
                                                  )
                                                  .toList()
                                                  .length
                                                  .toDouble()
                                              : returnWaybillProvider(
                                                    context:
                                                        context,
                                                  )
                                                  .returnOwnWaybillsByDayOrWeek(
                                                    index:
                                                        paidWaybillIndex,
                                                  )
                                                  .toList()
                                                  .length
                                                  .toDouble(),
                                      title:
                                          'Waybill Number',
                                      color: Colors.green,
                                      isMoney: false,
                                    ),
                                  ],
                                ),
                                // SizedBox(height: 20),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(
                                        vertical: 10.0,
                                      ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment
                                            .spaceBetween,
                                    children: [
                                      Visibility(
                                        visible: authorization(
                                          authorized:
                                              Authorizations()
                                                  .viewDate,
                                        ),
                                        child: Text(
                                          style: TextStyle(
                                            fontSize:
                                                theme
                                                    .mobileTexts
                                                    .b1
                                                    .fontSize,
                                          ),
                                          returnWaybillProvider(
                                                        context:
                                                            context,
                                                      ).dateSet !=
                                                      null ||
                                                  returnWaybillProvider(
                                                        context:
                                                            context,
                                                      ).rangeStartDate !=
                                                      null
                                              ? 'All Waybills'
                                              : 'For Today',
                                        ),
                                      ),
                                      Visibility(
                                        visible: authorization(
                                          authorized:
                                              Authorizations()
                                                  .viewDate,
                                        ),
                                        child: MaterialButton(
                                          onPressed: () {
                                            if (returnWaybillProvider()
                                                        .dateSet !=
                                                    null ||
                                                returnWaybillProvider()
                                                        .rangeStartDate !=
                                                    null) {
                                              returnWaybillProvider()
                                                  .clearDate();
                                            } else {
                                              mainDatePicker(
                                                context:
                                                    context,
                                                theme:
                                                    theme,
                                                singleDate: (
                                                  date,
                                                ) {
                                                  returnWaybillProvider()
                                                      .setDate(
                                                        date!,
                                                      );
                                                },
                                                rangeDate: (
                                                  firstDate,
                                                  lastDate,
                                                ) {
                                                  returnWaybillProvider().setRange(
                                                    firstDate!,
                                                    lastDate ??
                                                        DateTime.now(),
                                                  );
                                                },
                                              );
                                            }
                                          },
                                          child: Row(
                                            spacing: 3,
                                            children: [
                                              Text(
                                                style: TextStyle(
                                                  fontSize:
                                                      theme
                                                          .mobileTexts
                                                          .b2
                                                          .fontSize,
                                                  fontWeight:
                                                      FontWeight
                                                          .bold,
                                                  color:
                                                      Colors
                                                          .grey
                                                          .shade700,
                                                ),
                                                returnWaybillProvider(
                                                              context:
                                                                  context,
                                                            ).dateSet !=
                                                            null ||
                                                        returnWaybillProvider(
                                                              context:
                                                                  context,
                                                            ).rangeStartDate !=
                                                            null
                                                    ? 'Clear'
                                                    : 'Set Date',
                                              ),
                                              Icon(
                                                size: 20,
                                                color:
                                                    theme
                                                        .lightModeColor
                                                        .secColor100,
                                                returnWaybillProvider(
                                                              context:
                                                                  context,
                                                            ).dateSet !=
                                                            null ||
                                                        returnWaybillProvider(
                                                              context:
                                                                  context,
                                                            ).rangeStartDate !=
                                                            null
                                                    ? Icons
                                                        .clear
                                                    : Icons.date_range_outlined,
                                              ),
                                            ],
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
                                    ? returnWaybillProvider(
                                          context: context,
                                        )
                                        .returnOwnWaybillsByDayOrWeek(
                                          index:
                                              paidWaybillIndex,
                                        )
                                        .toList()
                                        .where(
                                          (rec) =>
                                              rec.staffId ==
                                              widget.id,
                                        )
                                        .toList()
                                        .isEmpty
                                    : widget.customerUuid !=
                                        null
                                    ? returnWaybillProvider(
                                          context: context,
                                        )
                                        .returnOwnWaybillsByDayOrWeek(
                                          index:
                                              paidWaybillIndex,
                                        )
                                        .where(
                                          (waybill) =>
                                              waybill
                                                  .customerId ==
                                              widget
                                                  .customerUuid,
                                        )
                                        .toList()
                                        .isEmpty
                                    : returnWaybillProvider(
                                          context: context,
                                        )
                                        .returnOwnWaybillsByDayOrWeek(
                                          index:
                                              paidWaybillIndex,
                                        )
                                        .toList()
                                        .isEmpty) {
                                  return EmptyWidgetDisplayOnly(
                                    title: 'Empty List',
                                    subText:
                                        'You don\'t have any Waybill under this category',
                                    icon: Icons.clear,
                                    theme: theme,
                                    height: 35,
                                    altAction: () {
                                      getWaybills();
                                    },
                                    altActionText:
                                        'Refresh List',
                                  );
                                } else {
                                  return RefreshIndicator(
                                    onRefresh: getWaybills,
                                    backgroundColor:
                                        Colors.white,
                                    color:
                                        theme
                                            .lightModeColor
                                            .prColor300,
                                    displacement: 10,
                                    child: ListView.builder(
                                      itemCount:
                                          widget.id != null
                                              ? returnWaybillProvider(
                                                    context:
                                                        context,
                                                  )
                                                  .returnOwnWaybillsByDayOrWeek(
                                                    index:
                                                        paidWaybillIndex,
                                                  )
                                                  .where(
                                                    (rec) =>
                                                        rec.staffId ==
                                                        widget.id,
                                                  )
                                                  .toList()
                                                  .length
                                              : widget.customerUuid !=
                                                  null
                                              ? returnWaybillProvider(
                                                    context:
                                                        context,
                                                  )
                                                  .returnOwnWaybillsByDayOrWeek(
                                                    index:
                                                        paidWaybillIndex,
                                                  )
                                                  .where(
                                                    (
                                                      waybill,
                                                    ) =>
                                                        waybill.customerId ==
                                                        widget.customerUuid,
                                                  )
                                                  .toList()
                                                  .length
                                              : returnWaybillProvider(
                                                    context:
                                                        context,
                                                  )
                                                  .returnOwnWaybillsByDayOrWeek(
                                                    index:
                                                        paidWaybillIndex,
                                                  )
                                                  .toList()
                                                  .length,
                                      itemBuilder: (
                                        context,
                                        index,
                                      ) {
                                        var waybill =
                                            widget.id !=
                                                    null
                                                ? returnWaybillProvider(
                                                      context:
                                                          context,
                                                    )
                                                    .returnOwnWaybillsByDayOrWeek(
                                                      index:
                                                          paidWaybillIndex,
                                                    )
                                                    .where(
                                                      (
                                                        rec,
                                                      ) =>
                                                          rec.staffId ==
                                                          widget.id,
                                                    )
                                                    .toList()[index]
                                                : widget.customerUuid !=
                                                    null
                                                ? returnWaybillProvider(
                                                      context:
                                                          context,
                                                    )
                                                    .returnOwnWaybillsByDayOrWeek(
                                                      index:
                                                          paidWaybillIndex,
                                                    )
                                                    .where(
                                                      (
                                                        waybill,
                                                      ) =>
                                                          waybill.customerId ==
                                                          widget.customerUuid,
                                                    )
                                                    .toList()[index]
                                                : returnWaybillProvider(
                                                      context:
                                                          context,
                                                    )
                                                    .returnOwnWaybillsByDayOrWeek(
                                                      index:
                                                          paidWaybillIndex,
                                                    )
                                                    .toList()[index];
                                        return MainWaybillTile(
                                          action: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (
                                                  context,
                                                ) {
                                                  return WaybillPage(
                                                    waybillUuid:
                                                        waybill.uuid!,
                                                  );
                                                },
                                              ),
                                            ).then((_) {
                                              setState(
                                                () {},
                                              );
                                            });
                                          },
                                          key: ValueKey(
                                            waybill.uuid,
                                          ),
                                          waybill: waybill,
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
                ),
              ),
              Container(
                width:
                    screenWidth(context) < tabletScreenSmall
                        ? 50
                        : (screenWidth(context) >
                                tabletScreenSmall &&
                            screenWidth(context) <
                                tabletScreen + 100)
                        ? 100
                        : 230,
              ),
            ],
          ),
          Visibility(
            visible: isLoading,
            child: returnCompProvider(
              context,
            ).showLoader(message: 'Logging Out...'),
          ),
        ],
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
