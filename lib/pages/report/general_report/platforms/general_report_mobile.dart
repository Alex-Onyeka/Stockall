import 'package:flutter/material.dart';
import 'package:stockitt/constants/calculations.dart';
import 'package:stockitt/constants/constants_main.dart';
import 'package:stockitt/main.dart';
import 'package:stockitt/providers/theme_provider.dart';

class GeneralReportMobile extends StatefulWidget {
  const GeneralReportMobile({super.key});

  @override
  State<GeneralReportMobile> createState() =>
      _GeneralReportMobileState();
}

class _GeneralReportMobileState
    extends State<GeneralReportMobile> {
  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Padding(
            padding: const EdgeInsets.only(
              left: 20.0,
              right: 10,
            ),
            child: Icon(Icons.arrow_back_ios_new_rounded),
          ),
        ),
        centerTitle: true,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              style: TextStyle(
                fontSize: theme.mobileTexts.h4.fontSize,
                fontWeight: FontWeight.bold,
              ),
              'General Report',
            ),
            SizedBox(height: 5),
            Text(
              style: TextStyle(
                fontSize: theme.mobileTexts.b2.fontSize,
              ),
              'Summary of General Report',
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 15.0,
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 5.0,
              ),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Text('For Today'),
                  // Visibility(
                  //   visible:
                  //       returnLocalDatabase(
                  //         context,
                  //       ).currentEmployee!.role !=
                  //       'Owner',
                  //   child: SizedBox(height: 30),
                  // ),
                  Visibility(
                    visible:
                        returnLocalDatabase(
                          context,
                        ).currentEmployee!.role ==
                        'Owner',
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.end,
                      children: [
                        MaterialButton(
                          onPressed: () {
                            if (returnExpensesProvider(
                                  context,
                                  listen: false,
                                ).isDateSet ||
                                returnExpensesProvider(
                                  context,
                                  listen: false,
                                ).setDate) {
                              returnExpensesProvider(
                                context,
                                listen: false,
                              ).clearExpenseDate();
                            } else {
                              returnExpensesProvider(
                                context,
                                listen: false,
                              ).openExpenseDatePicker();
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
                                returnExpensesProvider(
                                          context,
                                        ).isDateSet ||
                                        returnExpensesProvider(
                                          context,
                                        ).setDate
                                    ? 'Clear Date'
                                    : 'Set Date',
                              ),
                              Icon(
                                size: 20,
                                color:
                                    theme
                                        .lightModeColor
                                        .secColor100,
                                returnExpensesProvider(
                                          context,
                                        ).isDateSet ||
                                        returnExpensesProvider(
                                          context,
                                        ).setDate
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
            SizedBox(height: 15),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5.0,
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 5),
                      // Container(
                      //   padding: EdgeInsets.symmetric(
                      //     horizontal: 20,
                      //     vertical: 20,
                      //   ),
                      //   decoration: BoxDecoration(
                      //     borderRadius:
                      //         BorderRadius.circular(5),
                      //     color: Colors.white,
                      //     boxShadow: [
                      //       BoxShadow(
                      //         color: const Color.fromARGB(
                      //           20,
                      //           0,
                      //           0,
                      //           0,
                      //         ),
                      //         blurRadius: 10,
                      //       ),
                      //     ],
                      //   ),
                      //   child: Column(
                      //     crossAxisAlignment:
                      //         CrossAxisAlignment.start,
                      //     children: [
                      //       Text(
                      //         style: TextStyle(
                      //           fontWeight: FontWeight.bold,
                      //           color:
                      //               theme
                      //                   .lightModeColor
                      //                   .secColor200,
                      //         ),
                      //         'Sales',
                      //       ),
                      //       Divider(height: 20),
                      //       Column(
                      //         children: [
                      //           Row(
                      //             spacing: 10,
                      //             crossAxisAlignment:
                      //                 CrossAxisAlignment
                      //                     .start,
                      //             mainAxisAlignment:
                      //                 MainAxisAlignment
                      //                     .spaceBetween,
                      //             children: [
                      //               Column(
                      //                 spacing: 10,
                      //                 crossAxisAlignment:
                      //                     CrossAxisAlignment
                      //                         .start,
                      //                 children: [
                      //                   Column(
                      //                     crossAxisAlignment:
                      //                         CrossAxisAlignment
                      //                             .start,
                      //                     children: [
                      //                       Text(
                      //                         style: TextStyle(
                      //                           fontSize:
                      //                               theme
                      //                                   .mobileTexts
                      //                                   .b3
                      //                                   .fontSize,
                      //                           fontWeight:
                      //                               FontWeight
                      //                                   .normal,
                      //                         ),
                      //                         'Total Revenue:',
                      //                       ),
                      //                       Text(
                      //                         style: TextStyle(
                      //                           fontSize:
                      //                               theme
                      //                                   .mobileTexts
                      //                                   .h3
                      //                                   .fontSize,
                      //                           fontWeight:
                      //                               FontWeight
                      //                                   .bold,
                      //                           color:
                      //                               Colors
                      //                                   .grey
                      //                                   .shade700,
                      //                         ),
                      //                         '$nairaSymbol 23,000,000',
                      //                       ),
                      //                     ],
                      //                   ),
                      //                 ],
                      //               ),
                      //               Column(
                      //                 crossAxisAlignment:
                      //                     CrossAxisAlignment
                      //                         .start,
                      //                 children: [
                      //                   Text(
                      //                     style: TextStyle(
                      //                       fontSize:
                      //                           theme
                      //                               .mobileTexts
                      //                               .b3
                      //                               .fontSize,
                      //                       fontWeight:
                      //                           FontWeight
                      //                               .normal,
                      //                     ),
                      //                     'Sales Profit:',
                      //                   ),
                      //                   Text(
                      //                     style: TextStyle(
                      //                       fontSize:
                      //                           theme
                      //                               .mobileTexts
                      //                               .b1
                      //                               .fontSize,
                      //                       color:
                      //                           const Color.fromARGB(
                      //                             255,
                      //                             50,
                      //                             168,
                      //                             54,
                      //                           ),
                      //                       fontWeight:
                      //                           FontWeight
                      //                               .w700,
                      //                     ),
                      //                     '$nairaSymbol 23,000',
                      //                   ),
                      //                 ],
                      //               ),
                      //             ],
                      //           ),
                      //         ],
                      //       ),
                      //       Divider(
                      //         color: Colors.grey.shade200,
                      //         height: 30,
                      //       ),
                      //       Row(
                      //         mainAxisAlignment:
                      //             MainAxisAlignment
                      //                 .spaceBetween,
                      //         children: [
                      //           Expanded(
                      //             child: Column(
                      //               crossAxisAlignment:
                      //                   CrossAxisAlignment
                      //                       .center,
                      //               children: [
                      //                 Text(
                      //                   style: TextStyle(
                      //                     fontSize:
                      //                         theme
                      //                             .mobileTexts
                      //                             .b3
                      //                             .fontSize,
                      //                     fontWeight:
                      //                         FontWeight
                      //                             .normal,
                      //                   ),
                      //                   'No. of Sales:',
                      //                 ),
                      //                 Text(
                      //                   style: TextStyle(
                      //                     fontSize:
                      //                         theme
                      //                             .mobileTexts
                      //                             .b1
                      //                             .fontSize,
                      //                     color:
                      //                         Colors
                      //                             .grey
                      //                             .shade600,
                      //                     fontWeight:
                      //                         FontWeight
                      //                             .w700,
                      //                   ),
                      //                   '23,000',
                      //                 ),
                      //               ],
                      //             ),
                      //           ),
                      //           Expanded(
                      //             child: Column(
                      //               crossAxisAlignment:
                      //                   CrossAxisAlignment
                      //                       .center,
                      //               children: [
                      //                 Text(
                      //                   style: TextStyle(
                      //                     fontSize:
                      //                         theme
                      //                             .mobileTexts
                      //                             .b3
                      //                             .fontSize,
                      //                     fontWeight:
                      //                         FontWeight
                      //                             .normal,
                      //                   ),
                      //                   'No. of Refunds:',
                      //                 ),
                      //                 Text(
                      //                   style: TextStyle(
                      //                     fontSize:
                      //                         theme
                      //                             .mobileTexts
                      //                             .b1
                      //                             .fontSize,
                      //                     color:
                      //                         Colors
                      //                             .grey
                      //                             .shade600,
                      //                     fontWeight:
                      //                         FontWeight
                      //                             .w700,
                      //                   ),
                      //                   '0',
                      //                 ),
                      //               ],
                      //             ),
                      //           ),
                      //           Expanded(
                      //             child: Column(
                      //               crossAxisAlignment:
                      //                   CrossAxisAlignment
                      //                       .center,
                      //               children: [
                      //                 Text(
                      //                   style: TextStyle(
                      //                     fontSize:
                      //                         theme
                      //                             .mobileTexts
                      //                             .b3
                      //                             .fontSize,
                      //                     fontWeight:
                      //                         FontWeight
                      //                             .normal,
                      //                   ),
                      //                   'Dicounted:',
                      //                 ),
                      //                 Text(
                      //                   style: TextStyle(
                      //                     fontSize:
                      //                         theme
                      //                             .mobileTexts
                      //                             .b1
                      //                             .fontSize,
                      //                     color:
                      //                         Colors
                      //                             .grey
                      //                             .shade600,
                      //                     fontWeight:
                      //                         FontWeight
                      //                             .w700,
                      //                   ),
                      //                   '$nairaSymbol 23,000',
                      //                 ),
                      //               ],
                      //             ),
                      //           ),
                      //         ],
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      // SizedBox(height: 10),
                      ReportContainer(
                        theme: theme,
                        mainTitle: 'Sales',
                        subTitle1: 'No. of Sales',
                        subTitle2: 'Sales Revenue',
                        value1: 30,
                        value2: 1000000,
                      ),
                      SizedBox(height: 10),
                      ReportContainer(
                        theme: theme,
                        mainTitle: 'Expenses',
                        subTitle1: 'No. of Expenses',
                        subTitle2: 'Amount',
                        value1: 23000,
                        value2: 0,
                        color: Colors.red,
                      ),
                      SizedBox(height: 10),
                      ReportProfitContainer(
                        theme: theme,
                        mainTitle: 'Gross Profit/Loss',
                        subTitle1:
                            '(Total Cost Revenue - Total Selling Revenue)',
                        subTitle2: 'Gross Profit',
                        costValue1: 2300,
                        costValue2: 2300,
                        value2: 0,
                        color: const Color.fromARGB(
                          255,
                          30,
                          128,
                          33,
                        ),
                      ),
                      SizedBox(height: 10),
                      ReportProfitContainer(
                        theme: theme,
                        mainTitle: 'Net Profit/Loss',
                        subTitle1:
                            '(Gross Profit - Expenses)',
                        subTitle2: 'Net Profit',
                        costValue1: 23000,
                        costValue2: 23000,
                        value2: 0,
                        color: const Color.fromARGB(
                          255,
                          30,
                          128,
                          33,
                        ),
                      ),
                      SizedBox(height: 10),
                      ReportContainer(
                        theme: theme,
                        mainTitle: 'Product',
                        subTitle1: 'Total Products Sold',
                        subTitle2: 'Best Selling Product',
                        value1: 30,
                        value2: 1000000,
                        nameOfProduct:
                            'Beans (30 Peices Sold)',
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReportContainer extends StatelessWidget {
  final ThemeProvider theme;
  final Color? color;
  final String mainTitle;
  final String subTitle1;
  final String subTitle2;
  final double value1;
  final double value2;
  final String? nameOfProduct;

  const ReportContainer({
    super.key,
    required this.theme,
    required this.mainTitle,
    required this.subTitle1,
    required this.subTitle2,
    required this.value1,
    required this.value2,
    this.color,
    this.nameOfProduct,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 20,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(20, 0, 0, 0),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: theme.lightModeColor.secColor200,
            ),
            mainTitle,
          ),
          Divider(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 7,
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b3.fontSize,
                        fontWeight: FontWeight.normal,
                      ),
                      '$subTitle1:',
                    ),
                    Text(
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b1.fontSize,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w700,
                      ),
                      formatLargeNumberDouble(value1),
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
                            theme.mobileTexts.b3.fontSize,
                        fontWeight: FontWeight.normal,
                      ),
                      '$subTitle2:',
                    ),
                    Text(
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b1.fontSize,
                        color:
                            color ?? Colors.grey.shade600,
                        fontWeight: FontWeight.w700,
                      ),
                      nameOfProduct ??
                          '$nairaSymbol ${formatLargeNumberDouble(value2)}',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ReportProfitContainer extends StatelessWidget {
  final ThemeProvider theme;
  final Color? color;
  final String mainTitle;
  final String subTitle1;
  final String subTitle2;
  final double costValue1;
  final double costValue2;
  final double value2;

  const ReportProfitContainer({
    super.key,
    required this.theme,
    required this.mainTitle,
    required this.subTitle1,
    required this.subTitle2,
    required this.costValue1,
    required this.costValue2,
    required this.value2,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 20,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(20, 0, 0, 0),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: theme.lightModeColor.secColor200,
            ),
            mainTitle,
          ),
          Divider(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 7,
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b3.fontSize,
                        fontWeight: FontWeight.normal,
                      ),
                      '$subTitle1:',
                    ),
                    Text(
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b1.fontSize,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w700,
                      ),
                      '$nairaSymbol${formatLargeNumberDouble(costValue1)} - $nairaSymbol${formatLargeNumberDouble(costValue2)}',
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
                            theme.mobileTexts.b3.fontSize,
                        fontWeight: FontWeight.normal,
                      ),
                      '$subTitle2:',
                    ),
                    Text(
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.h4.fontSize,
                        color:
                            color ?? Colors.grey.shade600,
                        fontWeight: FontWeight.w700,
                      ),
                      '$nairaSymbol ${formatLargeNumberDoubleWidgetDecimal(value2)}',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
