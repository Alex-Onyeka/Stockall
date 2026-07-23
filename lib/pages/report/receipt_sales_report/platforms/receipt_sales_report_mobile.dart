import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_product_slaes_record/temp_product_sale_record.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/date_picker_function.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';

class ReceiptSalesReportMobile extends StatefulWidget {
  const ReceiptSalesReportMobile({super.key});

  @override
  State<ReceiptSalesReportMobile> createState() =>
      _ReceiptSalesReportMobileState();
}

class _ReceiptSalesReportMobileState
    extends State<ReceiptSalesReportMobile> {
  bool isSummary = false;
  int sortIndex = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      returnReceiptProvider(
        context,
        listen: false,
      ).clearDate();
      returnSalesProvider().toggleIsLoading(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    List<TempProductSaleRecord> salesRecords =
        returnReceiptProvider(context)
            .returnProductsRecordByDayOrWeek()
            .where(
              (item) =>
                  item.isVoid != true &&
                  item.invoiceUuid == null,
            )
            .toList();

    return Scaffold(
      appBar: appBar(
        context: context,
        title: 'Sales',
        widget: Padding(
          padding: const EdgeInsets.only(right: 15.0),
          child: PopupMenuButton(
            offset: Offset(-20, 30),
            color: Colors.white,
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  onTap: () {
                    setState(() {
                      isSummary = false;
                    });
                  },
                  child: Text(
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.b2.fontSize,
                      fontWeight:
                          !isSummary
                              ? FontWeight.bold
                              : null,
                    ),
                    'View Total Sales',
                  ),
                ),
                PopupMenuItem(
                  onTap: () {
                    setState(() {
                      isSummary = true;
                    });
                  },
                  child: Text(
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.b2.fontSize,
                      fontWeight:
                          isSummary
                              ? FontWeight.bold
                              : null,
                    ),
                    'View Summary of Sales',
                  ),
                ),
                PopupMenuItem(
                  onTap: () {
                    setState(() {
                      sortIndex = 1;
                    });
                  },
                  child: Text(
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.b2.fontSize,
                      fontWeight:
                          sortIndex == 1
                              ? FontWeight.bold
                              : null,
                    ),
                    'Sort By Name',
                  ),
                ),
                PopupMenuItem(
                  onTap: () {
                    setState(() {
                      sortIndex = 2;
                    });
                  },
                  child: Text(
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.b2.fontSize,
                      fontWeight:
                          sortIndex == 2
                              ? FontWeight.bold
                              : null,
                    ),
                    'Sort By Quantity',
                  ),
                ),
                PopupMenuItem(
                  onTap: () {
                    setState(() {
                      sortIndex = 3;
                    });
                  },
                  child: Text(
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.b2.fontSize,
                      fontWeight:
                          sortIndex == 3
                              ? FontWeight.bold
                              : null,
                    ),
                    'Sort By Revenue',
                  ),
                ),
                PopupMenuItem(
                  enabled: isSummary,
                  onTap: () {
                    setState(() {
                      sortIndex = 4;
                    });
                  },
                  child: Text(
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.b2.fontSize,
                      fontWeight:
                          sortIndex == 4
                              ? FontWeight.bold
                              : null,
                    ),
                    'Sort By Profit',
                  ),
                ),
                PopupMenuItem(
                  enabled: !isSummary,
                  onTap: () {
                    setState(() {
                      sortIndex = 5;
                    });
                  },
                  child: Text(
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.b2.fontSize,
                      fontWeight:
                          sortIndex == 5
                              ? FontWeight.bold
                              : null,
                    ),
                    'Sort By Created Date',
                  ),
                ),
              ];
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b2.fontSize,
                      ),
                      isSummary ? 'Summary' : 'Total',
                    ),
                    Text(
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b4.fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                      "(${sortIndex == 1
                          ? 'Name'
                          : sortIndex == 2
                          ? 'Quantity'
                          : sortIndex == 3
                          ? 'Revenue'
                          : sortIndex == 4
                          ? 'Profit'
                          : sortIndex == 5
                          ? 'Date/Time'
                          : 'Name'})",
                    ),
                  ],
                ),
                Icon(Icons.more_vert_rounded),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 5.0,
                ),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SizedBox(width: 10),
                        Text(
                          style: TextStyle(
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b1
                                    .fontSize,
                          ),
                          returnReceiptProvider(
                                        context,
                                      ).dateSet !=
                                      null ||
                                  returnReceiptProvider(
                                        context,
                                      ).rangeStartDate !=
                                      null
                              ? 'All Sales'
                              : 'For Today',
                        ),
                      ],
                    ),

                    Visibility(
                      visible: authorization(
                        authorized:
                            Authorizations().viewDate,
                      ),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.end,
                        children: [
                          MaterialButton(
                            mouseCursor:
                                SystemMouseCursors.click,
                            onPressed: () {
                              if (returnReceiptProvider(
                                        context,
                                        listen: false,
                                      ).dateSet !=
                                      null ||
                                  returnReceiptProvider(
                                        context,
                                        listen: false,
                                      ).rangeStartDate !=
                                      null) {
                                returnReceiptProvider(
                                  context,
                                  listen: false,
                                ).clearDate();
                              } else {
                                mainDatePicker(
                                  context: context,
                                  theme: theme,
                                  singleDate: (date) {
                                    returnReceiptProviderSingle()
                                        .setDate(date!);
                                  },
                                  rangeDate: (
                                    firstDate,
                                    lastDate,
                                  ) {
                                    returnReceiptProviderSingle()
                                        .setRange(
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
                                        FontWeight.bold,
                                    color:
                                        Colors
                                            .grey
                                            .shade700,
                                  ),
                                  returnReceiptProvider(
                                                context,
                                              ).dateSet !=
                                              null ||
                                          returnReceiptProvider(
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
                                  returnReceiptProvider(
                                                context,
                                              ).dateSet !=
                                              null ||
                                          returnReceiptProvider(
                                                context,
                                              ).rangeStartDate !=
                                              null
                                      ? Icons.clear
                                      : Icons
                                          .date_range_outlined,
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
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                  ),
                  child: SingleChildScrollView(
                    primary: false,
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width:
                          salesRecords.isEmpty
                              ? MediaQuery.of(
                                context,
                              ).size.width
                              : MediaQuery.of(
                                    context,
                                  ).size.width <
                                  555
                              ? MediaQuery.of(
                                    context,
                                  ).size.width +
                                  580
                              : MediaQuery.of(
                                        context,
                                      ).size.width >
                                      555 &&
                                  MediaQuery.of(
                                        context,
                                      ).size.width <
                                      755
                              ? MediaQuery.of(
                                    context,
                                  ).size.width +
                                  380
                              : MediaQuery.of(
                                context,
                              ).size.width,
                      child: Column(children: [
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Visibility(
            visible:
                returnSalesProviderContext(
                  context,
                ).isLoading,
            child: returnCompProvider(
              context,
              listen: false,
            ).showLoader(message: 'Generating Pdf'),
          ),
        ],
      ),
    );
  }
}
