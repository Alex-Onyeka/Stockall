import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_product_slaes_record/temp_product_sale_record.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/report/general_report/class/general_report_class.dart';
import 'package:stockall/providers/theme_provider.dart';

class DepartmentsSectionListWidget extends StatelessWidget {
  const DepartmentsSectionListWidget({
    super.key,
    // required this.isSummary,
    required this.summary,
    required this.theme,
    required this.salesRecords,
  });

  // final bool isSummary;
  final List<GeneralReportSalesSummaryItem> summary;
  final ThemeProvider theme;
  final List<TempProductSaleRecord> salesRecords;

  @override
  Widget build(BuildContext context) {
    if (screenWidth(context) > mobileScreen) {
      return Expanded(
        child: ListView(
          children: [
            Column(
              spacing: 10,
              children:
                  returnDepartmentProvider().departments
                      .where((item) {
                        for (var rec in salesRecords) {
                          if (rec.departmentUuid ==
                              item.uuid) {
                            return true;
                          }
                        }
                        return false;
                      })
                      .map((dept) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(),
                          child: Column(
                            spacing: 5,
                            children: [
                              Row(
                                spacing: 5,
                                children: [
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
                                    "Department:",
                                  ),
                                  Container(
                                    padding:
                                        EdgeInsets.symmetric(
                                          vertical: 3,
                                          horizontal: 6,
                                        ),
                                    decoration:
                                        BoxDecoration(
                                          color:
                                              Colors
                                                  .grey
                                                  .shade200,
                                        ),
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
                                      dept.name,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                width: double.infinity,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: Colors.amber,
                                ),
                              ),
                              Column(
                                children:
                                    salesRecords
                                        .where(
                                          (sum) =>
                                              sum.departmentUuid ==
                                              dept.uuid,
                                        )
                                        .map((record) {
                                          return Container(
                                            margin:
                                                EdgeInsets.symmetric(
                                                  vertical:
                                                      4,
                                                ),
                                            padding:
                                                EdgeInsets.symmetric(
                                                  vertical:
                                                      10,
                                                  horizontal:
                                                      10,
                                                ),
                                            decoration:
                                                BoxDecoration(
                                                  color:
                                                      Colors
                                                          .grey
                                                          .shade100,
                                                ),
                                            child: Row(
                                              spacing: 10,
                                              children: [
                                                Expanded(
                                                  child: Row(
                                                    children: [
                                                      SizedBox(
                                                        width:
                                                            60,
                                                        child: Row(
                                                          children: [
                                                            Expanded(
                                                              child: Text(
                                                                style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight.bold,
                                                                  fontSize:
                                                                      theme.mobileTexts.b3.fontSize,
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
                                                                theme.mobileTexts.b3.fontSize,
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
                                                        theme.mobileTexts.b3.fontSize,
                                                  ),
                                                  formatMoneyMid(
                                                    amount:
                                                        record.revenue,
                                                    context:
                                                        context,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        })
                                        .toList(),
                              ),
                              Visibility(
                                visible:
                                    returnReceiptProviderSingle()
                                        .returnGeneralReportSalesSummaryVoid()
                                        .where(
                                          (sum) =>
                                              sum.departmentUuid ==
                                              dept.uuid,
                                        )
                                        .toList()
                                        .isNotEmpty,
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment
                                              .center,
                                      children: [
                                        Text(
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
                                          'Deleted Items',
                                        ),
                                      ],
                                    ),
                                    Column(
                                      children:
                                          returnReceiptProviderSingle()
                                              .returnGeneralReportSalesSummaryVoid()
                                              .where(
                                                (sum) =>
                                                    sum.departmentUuid ==
                                                    dept.uuid,
                                              )
                                              .toList()
                                              .map((
                                                record,
                                              ) {
                                                return Container(
                                                  margin: EdgeInsets.symmetric(
                                                    vertical:
                                                        4,
                                                  ),
                                                  padding: EdgeInsets.symmetric(
                                                    vertical:
                                                        10,
                                                    horizontal:
                                                        10,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: const Color.fromARGB(
                                                      255,
                                                      255,
                                                      231,
                                                      233,
                                                    ),
                                                  ),
                                                  child: Row(
                                                    spacing:
                                                        10,
                                                    children: [
                                                      Icon(
                                                        size:
                                                            16,
                                                        Icons.clear,
                                                      ),
                                                      Expanded(
                                                        child: Row(
                                                          children: [
                                                            SizedBox(
                                                              width:
                                                                  60,
                                                              child: Row(
                                                                children: [
                                                                  Expanded(
                                                                    child: Text(
                                                                      style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        fontSize:
                                                                            theme.mobileTexts.b3.fontSize,
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
                                                                      theme.mobileTexts.b3.fontSize,
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
                                                              theme.mobileTexts.b3.fontSize,
                                                        ),
                                                        formatMoneyMid(
                                                          amount:
                                                              record.totalCost,
                                                          context:
                                                              context,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              })
                                              .toList(),
                                    ),
                                  ],
                                ),
                              ),
                              Divider(),
                            ],
                          ),
                        );
                      })
                      .toList(),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(),
              child: Column(
                spacing: 5,
                children: [
                  Row(
                    spacing: 5,
                    children: [
                      Text(
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize:
                              theme.mobileTexts.b3.fontSize,
                        ),
                        "Department:",
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 3,
                          horizontal: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                        ),
                        child: Text(
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b3
                                    .fontSize,
                          ),
                          'No Department',
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: double.infinity,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.amber,
                    ),
                  ),
                  Column(
                    children:
                        returnReceiptProviderSingle().returnGeneralReportSalesSummaryNoDepartment().map((
                          record,
                        ) {
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
                                    amount:
                                        record.totalCost,
                                    context: context,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                  ),
                  Divider(),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      return Column(
        children: [
          Column(
            spacing: 10,
            children:
                returnDepartmentProvider().departments
                    .where((item) {
                      for (var rec in salesRecords) {
                        if (rec.departmentUuid ==
                            item.uuid) {
                          return true;
                        }
                      }
                      return false;
                    })
                    .map((dept) {
                      return Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(),
                        child: Column(
                          spacing: 5,
                          children: [
                            Row(
                              spacing: 5,
                              children: [
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
                                  "Department:",
                                ),
                                Container(
                                  padding:
                                      EdgeInsets.symmetric(
                                        vertical: 3,
                                        horizontal: 6,
                                      ),
                                  decoration: BoxDecoration(
                                    color:
                                        Colors
                                            .grey
                                            .shade200,
                                  ),
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
                                    dept.name,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              width: double.infinity,
                              height: 6,
                              decoration: BoxDecoration(
                                color: Colors.amber,
                              ),
                            ),
                            Column(
                              children:
                                  salesRecords
                                      .where(
                                        (sum) =>
                                            sum.departmentUuid ==
                                            dept.uuid,
                                      )
                                      .map((record) {
                                        return Container(
                                          margin:
                                              EdgeInsets.symmetric(
                                                vertical: 4,
                                              ),
                                          padding:
                                              EdgeInsets.symmetric(
                                                vertical:
                                                    10,
                                                horizontal:
                                                    10,
                                              ),
                                          decoration:
                                              BoxDecoration(
                                                color:
                                                    Colors
                                                        .grey
                                                        .shade100,
                                              ),
                                          child: Row(
                                            spacing: 10,
                                            children: [
                                              Expanded(
                                                child: Row(
                                                  children: [
                                                    SizedBox(
                                                      width:
                                                          60,
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                            child: Text(
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight.bold,
                                                                fontSize:
                                                                    theme.mobileTexts.b3.fontSize,
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
                                                              theme.mobileTexts.b3.fontSize,
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
                                                      FontWeight
                                                          .bold,
                                                  fontSize:
                                                      theme
                                                          .mobileTexts
                                                          .b3
                                                          .fontSize,
                                                ),
                                                formatMoneyMid(
                                                  amount:
                                                      record
                                                          .revenue,
                                                  context:
                                                      context,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      })
                                      .toList(),
                            ),
                            Visibility(
                              visible:
                                  returnReceiptProviderSingle()
                                      .returnGeneralReportSalesSummaryVoid()
                                      .where(
                                        (sum) =>
                                            sum.departmentUuid ==
                                            dept.uuid,
                                      )
                                      .toList()
                                      .isNotEmpty,
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment
                                            .center,
                                    children: [
                                      Text(
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
                                        'Deleted Items',
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children:
                                        returnReceiptProviderSingle()
                                            .returnGeneralReportSalesSummaryVoid()
                                            .where(
                                              (sum) =>
                                                  sum.departmentUuid ==
                                                  dept.uuid,
                                            )
                                            .toList()
                                            .map((record) {
                                              return Container(
                                                margin:
                                                    EdgeInsets.symmetric(
                                                      vertical:
                                                          4,
                                                    ),
                                                padding: EdgeInsets.symmetric(
                                                  vertical:
                                                      10,
                                                  horizontal:
                                                      10,
                                                ),
                                                decoration:
                                                    BoxDecoration(
                                                      color: const Color.fromARGB(
                                                        255,
                                                        255,
                                                        231,
                                                        233,
                                                      ),
                                                    ),
                                                child: Row(
                                                  spacing:
                                                      10,
                                                  children: [
                                                    Icon(
                                                      size:
                                                          16,
                                                      Icons
                                                          .clear,
                                                    ),
                                                    Expanded(
                                                      child: Row(
                                                        children: [
                                                          SizedBox(
                                                            width:
                                                                60,
                                                            child: Row(
                                                              children: [
                                                                Expanded(
                                                                  child: Text(
                                                                    style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight.bold,
                                                                      fontSize:
                                                                          theme.mobileTexts.b3.fontSize,
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
                                                                    theme.mobileTexts.b3.fontSize,
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
                                                            theme.mobileTexts.b3.fontSize,
                                                      ),
                                                      formatMoneyMid(
                                                        amount:
                                                            record.totalCost,
                                                        context:
                                                            context,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            })
                                            .toList(),
                                  ),
                                ],
                              ),
                            ),
                            Divider(),
                          ],
                        ),
                      );
                    })
                    .toList(),
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(),
            child: Column(
              spacing: 5,
              children: [
                Row(
                  spacing: 5,
                  children: [
                    Text(
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize:
                            theme.mobileTexts.b3.fontSize,
                      ),
                      "Department:",
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 3,
                        horizontal: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                      ),
                      child: Text(
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize:
                              theme.mobileTexts.b3.fontSize,
                        ),
                        'No Department',
                      ),
                    ),
                  ],
                ),
                Container(
                  width: double.infinity,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.amber,
                  ),
                ),
                Column(
                  children:
                      returnReceiptProviderSingle().returnGeneralReportSalesSummaryNoDepartment().map((
                        record,
                      ) {
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
                ),
                Divider(),
              ],
            ),
          ),
        ],
      );
    }
  }
}
