import 'package:flutter/material.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/date_picker_function.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';

class SetCustomReceiptCreatedDateWidget
    extends StatelessWidget {
  const SetCustomReceiptCreatedDateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Visibility(
      visible:
      // (returnSalesProviderContext(
      //           context,
      //         ).currentCart().invoiceUuidEdit !=
      //         null ||
      //     returnSalesProviderContext(
      //           context,
      //         ).currentCart().receiptUuidEdit !=
      //         null) &&
      authorization(
        authorized:
            Authorizations().setCustomReceiptCreatedDate,
      ),
      child: Column(
        children: [
          Divider(color: Colors.grey.shade300),
          SizedBox(height: 10),
          Row(
            spacing: 5,
            children: [
              Expanded(
                child: Builder(
                  builder: (context) {
                    if (returnSalesProviderContext(
                          context,
                        ).currentCart().customDate ==
                        null) {
                      return Material(
                        color: Colors.transparent,
                        child: Ink(
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(5),
                            border: Border.all(
                              color: Colors.grey.shade400,
                              width: 1,
                            ),
                          ),
                          child: InkWell(
                            mouseCursor:
                                SystemMouseCursors.click,
                            onTap: () async {
                              var date =
                                  await myDatePickerAction(
                                    theme,
                                    context,
                                  );
                              returnSalesProvider()
                                  .updateReceiptCreatedDate(
                                    createdDate: date,
                                  );
                            },
                            borderRadius:
                                BorderRadius.circular(5),
                            child: Container(
                              padding: EdgeInsets.only(
                                left: 10,
                                right: 5,
                                bottom: 6,
                                top: 6,
                              ),

                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment
                                        .spaceBetween,
                                children: [
                                  Text(
                                    style: TextStyle(
                                      color:
                                          Colors
                                              .grey
                                              .shade700,
                                      fontWeight:
                                          FontWeight.bold,
                                      fontSize:
                                          theme
                                              .mobileTexts
                                              .b3
                                              .fontSize,
                                    ),
                                    'Custom Date',
                                  ),
                                  Icon(
                                    color: Colors.orange,
                                    size: 20,
                                    Icons.date_range,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    } else {
                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(5),
                          color: Colors.grey.shade200,
                        ),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                          children: [
                            Row(
                              spacing: 5,
                              children: [
                                Icon(
                                  size: 20,
                                  Icons.date_range_outlined,
                                ),
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                  children: [
                                    // Text(
                                    //   style: TextStyle(
                                    //     fontSize:
                                    //         theme
                                    //             .mobileTexts
                                    //             .b4
                                    //             .fontSize,
                                    //   ),
                                    //   'Custom Created Date:',
                                    // ),
                                    // SizedBox(height: 2),
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
                                      formatDateTime(
                                        returnSalesProviderContext(
                                                  context,
                                                )
                                                .currentCart()
                                                .customDate ??
                                            DateTime.now(),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Visibility(
                              visible:
                                  returnSalesProviderContext(
                                        context,
                                      )
                                      .currentCart()
                                      .customDate !=
                                  null,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  mouseCursor:
                                      SystemMouseCursors
                                          .click,
                                  borderRadius:
                                      BorderRadius.circular(
                                        5,
                                      ),
                                  onTap: () {
                                    returnSalesProvider()
                                        .updateReceiptCreatedDate();
                                  },
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.symmetric(
                                          horizontal: 6.0,
                                          vertical: 5,
                                        ),
                                    child: Icon(
                                      size: 20,
                                      Icons.clear,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ),
              Expanded(
                child: Builder(
                  builder: (context) {
                    if (returnSalesProviderContext(
                          context,
                        ).currentCart().timeOfDay ==
                        null) {
                      return Material(
                        color: Colors.transparent,
                        child: Ink(
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(5),
                            border: Border.all(
                              color: Colors.grey.shade400,
                              width: 1,
                            ),
                          ),
                          child: InkWell(
                            mouseCursor:
                                SystemMouseCursors.click,
                            onTap: () async {
                              var date =
                                  await myTimePickerAction(
                                    theme,
                                    context,
                                  );
                              returnSalesProvider()
                                  .updateReceiptCreatedTime(
                                    timeOfDay: date,
                                  );
                            },
                            borderRadius:
                                BorderRadius.circular(5),
                            child: Container(
                              padding: EdgeInsets.only(
                                left: 10,
                                right: 5,
                                bottom: 6,
                                top: 6,
                              ),

                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment
                                        .spaceBetween,
                                children: [
                                  Text(
                                    style: TextStyle(
                                      color:
                                          Colors
                                              .grey
                                              .shade700,
                                      fontWeight:
                                          FontWeight.bold,
                                      fontSize:
                                          theme
                                              .mobileTexts
                                              .b3
                                              .fontSize,
                                    ),
                                    'Custom Time',
                                  ),
                                  Icon(
                                    color: Colors.orange,
                                    size: 20,
                                    Icons.access_time,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    } else {
                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(5),
                          color: Colors.grey.shade200,
                        ),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                          children: [
                            Row(
                              spacing: 5,
                              children: [
                                Icon(
                                  size: 18,
                                  Icons.access_time,
                                ),
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                  children: [
                                    // Text(
                                    //   style: TextStyle(
                                    //     fontSize:
                                    //         theme
                                    //             .mobileTexts
                                    //             .b4
                                    //             .fontSize,
                                    //   ),
                                    //   'Custom Created Date:',
                                    // ),
                                    // SizedBox(height: 2),
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
                                      formatTimeOfDay(
                                        returnSalesProviderContext(
                                                  context,
                                                )
                                                .currentCart()
                                                .timeOfDay ??
                                            TimeOfDay.now(),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Visibility(
                              visible:
                                  returnSalesProviderContext(
                                        context,
                                      )
                                      .currentCart()
                                      .timeOfDay !=
                                  null,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  mouseCursor:
                                      SystemMouseCursors
                                          .click,
                                  borderRadius:
                                      BorderRadius.circular(
                                        5,
                                      ),
                                  onTap: () {
                                    returnSalesProvider()
                                        .updateReceiptCreatedTime();
                                  },
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.symmetric(
                                          horizontal: 10.0,
                                          vertical: 5,
                                        ),
                                    child: Icon(
                                      size: 20,
                                      Icons.clear,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
