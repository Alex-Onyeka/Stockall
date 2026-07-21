import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:stockall/components/major/desktop_center_container.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/date_picker_function.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';

class ReceiptSalesReportDesktop extends StatefulWidget {
  const ReceiptSalesReportDesktop({super.key});

  @override
  State<ReceiptSalesReportDesktop> createState() =>
      _ReceiptSalesReportDesktopState();
}

class _ReceiptSalesReportDesktopState
    extends State<ReceiptSalesReportDesktop> {
  int sortIndex = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      returnReceiptProviderSingle().clearDate();
      returnSalesProvider().toggleIsLoading(false);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return DesktopCenterContainer(
      width: double.infinity,
      mainWidget: Scaffold(
        appBar: appBar(
          context: context,
          title: 'Receipt Sales',
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
                        sortIndex = 1;
                      });
                    },
                    child: Text(
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b3.fontSize,
                        fontWeight:
                            sortIndex == 1
                                ? FontWeight.bold
                                : null,
                      ),
                      'View Total Sales',
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
                            theme.mobileTexts.b3.fontSize,
                        fontWeight:
                            sortIndex == 2
                                ? FontWeight.bold
                                : null,
                      ),
                      'Group By Staffs',
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
                            theme.mobileTexts.b3.fontSize,
                        fontWeight:
                            sortIndex == 3
                                ? FontWeight.bold
                                : null,
                      ),
                      'Group By Customers',
                    ),
                  ),
                  PopupMenuItem(
                    onTap: () {
                      setState(() {
                        sortIndex = 4;
                      });
                    },
                    child: Text(
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b3.fontSize,
                        fontWeight:
                            sortIndex == 4
                                ? FontWeight.bold
                                : null,
                      ),
                      'Group By Channel',
                    ),
                  ),
                  PopupMenuItem(
                    enabled:
                        returnShopProvider()
                            .userShop()
                            ?.manageDepartments ==
                        true,
                    onTap: () {
                      setState(() {
                        sortIndex = 5;
                      });
                    },
                    child: Text(
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b3.fontSize,
                        fontWeight:
                            sortIndex == 5
                                ? FontWeight.bold
                                : null,
                      ),
                      'Group By Departments',
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
                    "(${sortIndex == 1
                        ? 'Total'
                        : sortIndex == 2
                        ? 'Staffs'
                        : sortIndex == 3
                        ? 'Customers'
                        : sortIndex == 4
                        ? 'Channel'
                        : sortIndex == 5
                        ? 'Departments'
                        : 'Total'})",
                  ),
                  Icon(Icons.more_vert_rounded),
                ],
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            SizedBox(height: 15),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal:
                      screenWidth(context) > mobileScreen
                          ? 10.0
                          : 0,
                ),
                child: DataTable2(
                  sortAscending:
                      returnReceiptProvider(
                        context,
                      ).sortAscending,
                  sortColumnIndex:
                      returnReceiptProvider(
                        context,
                      ).sortColumnIndex,
                  // sortArrowIcon:
                  //     Icons.keyboard_arrow_down_rounded,sort
                  columnSpacing: 10,
                  horizontalMargin: 10,
                  headingRowHeight: 35,
                  headingRowColor: WidgetStateProperty.all(
                    const Color.fromARGB(
                      132,
                      158,
                      158,
                      158,
                    ),
                  ),
                  border: TableBorder(
                    verticalInside: BorderSide(
                      color: const Color.fromARGB(
                        54,
                        158,
                        158,
                        158,
                      ),
                    ),
                    horizontalInside: BorderSide(
                      color: const Color.fromARGB(
                        54,
                        158,
                        158,
                        158,
                      ),
                    ),
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color.fromARGB(
                        54,
                        158,
                        158,
                        158,
                      ),
                    ),
                  ),
                  minWidth: 1100,
                  empty: Center(child: Text('No Data')),
                  dataTextStyle: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                    fontFamily: 'Poppins',
                  ),
                  columns: returnReceiptProvider(
                    context,
                  ).heading(
                    context: context,
                    sortIndex: sortIndex,
                  ),
                  rows: returnReceiptProvider(context).row(
                    context: context,
                    sortIndex: sortIndex,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.symmetric(
                vertical: 5,
                horizontal: 15,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(5),
                  topRight: Radius.circular(5),
                ),
                border: Border.all(
                  color: Colors.grey.shade300,
                ),
                // boxShadow: [
                //   BoxShadow(
                //     color: const Color.fromARGB(
                //       26,
                //       0,
                //       0,
                //       0,
                //     ),
                //     blurRadius: 5,
                //     offset: Offset(0, -10),
                //   ),
                // ],
                color: Colors.white,
              ),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  // Row(
                  //   children: [
                  //     SizedBox(width: 10),
                  //     Text(
                  //       style: TextStyle(
                  //         fontSize:
                  //             theme.mobileTexts.b1.fontSize,
                  //       ),
                  //       returnReceiptProvider(
                  //                     context,
                  //                   ).dateSet !=
                  //                   null ||
                  //               returnReceiptProvider(
                  //                     context,
                  //                   ).rangeStartDate !=
                  //                   null
                  //           ? 'All Sales'
                  //           : 'For Today',
                  //     ),
                  //   ],
                  // ),
                  Visibility(
                    visible:
                        returnReceiptProvider(context)
                                .row(
                                  context: context,
                                  sortIndex: sortIndex,
                                )
                                .length >
                            1 &&
                        sortIndex == 1,
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () {},
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
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
                                    color:
                                        Colors
                                            .grey
                                            .shade700,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                  'Generate',
                                ),
                                Icon(
                                  size: 20,
                                  color: Colors.grey,
                                  Icons.print,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Visibility(
                    visible: authorization(
                      authorized: Authorizations().viewDate,
                    ),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.end,
                      children: [
                        MaterialButton(
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
                              setState(() {});
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
                                      Colors.grey.shade700,
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
          ],
        ),
      ),
    );
  }
}

class HeadingTextWidget extends StatelessWidget {
  const HeadingTextWidget({super.key, required this.title});

  final String title;
  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Text(
      style: TextStyle(
        fontSize: theme.mobileTexts.b3.fontSize,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      title.toUpperCase(),
    );
  }
}
