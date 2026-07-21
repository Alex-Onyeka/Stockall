import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_product_slaes_record/temp_product_sale_record.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/pages/report/general_report/class/general_report_class.dart';
import 'package:stockall/providers/theme_provider.dart';

class TotalSalesListWidget extends StatelessWidget {
  const TotalSalesListWidget({
    super.key,
    required this.isSummary,
    required this.summary,
    required this.theme,
    required this.salesRecords,
  });

  final bool isSummary;
  final List<GeneralReportSalesSummaryItem> summary;
  final ThemeProvider theme;
  final List<TempProductSaleRecord> salesRecords;

  @override
  Widget build(BuildContext context) {
    if (screenWidth(context) > mobileScreen) {
      return Expanded(
        child:
            isSummary
                ? ListView(
                  children:
                      summary.map((record) {
                        return Container(
                          margin: EdgeInsets.symmetric(
                            vertical: 4,
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                          ),
                          child: Row(
                            spacing: 10,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 60,
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              style: TextStyle(
                                                fontWeight:
                                                    FontWeight
                                                        .bold,
                                                fontSize:
                                                    theme
                                                        .mobileTexts
                                                        .b3
                                                        .fontSize,
                                              ),
                                              "${[formatLargeNumber(record.quantity.toString())]} - ",
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Flexible(
                                      child: Text(
                                        style: TextStyle(
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                          fontSize:
                                              theme
                                                  .mobileTexts
                                                  .b3
                                                  .fontSize,
                                        ),
                                        record.itemName,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                style: TextStyle(
                                  fontWeight:
                                      FontWeight.bold,
                                  fontSize:
                                      theme
                                          .mobileTexts
                                          .b3
                                          .fontSize,
                                ),
                                formatMoneyMid(
                                  amount: record.totalCost,
                                  context: context,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                )
                : ListView(
                  children:
                      salesRecords.map((record) {
                        return Container(
                          margin: EdgeInsets.symmetric(
                            vertical: 4,
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                          ),
                          child: Row(
                            spacing: 10,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 60,
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              style: TextStyle(
                                                fontWeight:
                                                    FontWeight
                                                        .bold,
                                                fontSize:
                                                    theme
                                                        .mobileTexts
                                                        .b3
                                                        .fontSize,
                                              ),
                                              "${[formatLargeNumber(record.quantity.toString())]} - ",
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Flexible(
                                      child: Text(
                                        style: TextStyle(
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                          fontSize:
                                              theme
                                                  .mobileTexts
                                                  .b3
                                                  .fontSize,
                                        ),
                                        record.productName,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                style: TextStyle(
                                  fontWeight:
                                      FontWeight.bold,
                                  fontSize:
                                      theme
                                          .mobileTexts
                                          .b3
                                          .fontSize,
                                ),
                                formatMoneyMid(
                                  amount: record.revenue,
                                  context: context,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                ),
      );
    } else {
      return Column(
        children:
            isSummary
                ? summary.map((record) {
                  return Container(
                    margin: EdgeInsets.symmetric(
                      vertical: 4,
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                    ),
                    child: Row(
                      spacing: 10,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              SizedBox(
                                width: 60,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        style: TextStyle(
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                          fontSize:
                                              theme
                                                  .mobileTexts
                                                  .b3
                                                  .fontSize,
                                        ),
                                        "${[formatLargeNumber(record.quantity.toString())]} - ",
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Flexible(
                                child: Text(
                                  style: TextStyle(
                                    fontWeight:
                                        FontWeight.bold,
                                    fontSize:
                                        theme
                                            .mobileTexts
                                            .b3
                                            .fontSize,
                                  ),
                                  record.itemName,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b3
                                    .fontSize,
                          ),
                          formatMoneyMid(
                            amount: record.totalCost,
                            context: context,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList()
                : salesRecords.map((record) {
                  return Container(
                    margin: EdgeInsets.symmetric(
                      vertical: 4,
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                    ),
                    child: Row(
                      spacing: 10,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              SizedBox(
                                width: 60,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        style: TextStyle(
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                          fontSize:
                                              theme
                                                  .mobileTexts
                                                  .b3
                                                  .fontSize,
                                        ),
                                        "${[formatLargeNumber(record.quantity.toString())]} - ",
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Flexible(
                                child: Text(
                                  style: TextStyle(
                                    fontWeight:
                                        FontWeight.bold,
                                    fontSize:
                                        theme
                                            .mobileTexts
                                            .b3
                                            .fontSize,
                                  ),
                                  record.productName,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b3
                                    .fontSize,
                          ),
                          formatMoneyMid(
                            amount: record.revenue,
                            context: context,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
      );
    }
  }
}
