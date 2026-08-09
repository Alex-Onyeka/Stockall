import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_production_folder/temp_productions/production_record.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/production/production_dashboard/productions_section/production_details/production_details_page.dart';

class ProductionsRecordTile extends StatefulWidget {
  const ProductionsRecordTile({
    super.key,
    required this.productionRecord,
  });

  final ProductionRecord productionRecord;

  @override
  State<ProductionsRecordTile> createState() =>
      ProductionsRecordTileState();
}

class ProductionsRecordTileState
    extends State<ProductionsRecordTile> {
  String cutLongText(String text, int number) {
    if (text.length > number) {
      return '${text.substring(0, number)}...';
    } else {
      return text;
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Material(
      type: MaterialType.transparency,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: InkWell(
            mouseCursor: SystemMouseCursors.click,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return ProductionDetailsPage(
                      productionRecordUuid:
                          widget.productionRecord.uuid!,
                    );
                  },
                ),
              );
            },
            borderRadius: BorderRadius.circular(5),
            child: Container(
              padding: EdgeInsets.fromLTRB(8, 15, 15, 15),
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                spacing: 10,
                children: [
                  Stack(
                    children: [
                      Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.shade200,
                        ),
                        child: Icon(
                          color: Colors.grey.shade800,
                          size: 20,
                          Icons.receipt,
                        ),
                      ),
                    ],
                  ),
                  Flexible(
                    child: Column(
                      children: [
                        Row(
                          spacing: 15,
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                spacing: 5,
                                children: [
                                  Row(
                                    spacing: 5,
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
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
                                                    .b2
                                                    .fontSize,
                                          ),
                                          cutLongText(
                                            widget
                                                    .productionRecord
                                                    .itemName ??
                                                'Item Not Set',
                                            30,
                                          ),
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
                                                  .b2
                                                  .fontSize,
                                          color:
                                              theme
                                                  .lightModeColor
                                                  .secColor200,
                                        ),
                                        formatLargeNumberDouble(
                                          widget
                                                  .productionRecord
                                                  .quantity ??
                                              0,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    style: TextStyle(
                                      fontSize:
                                          theme
                                              .mobileTexts
                                              .b3
                                              .fontSize,
                                      fontWeight:
                                          FontWeight.normal,
                                      color:
                                          Colors
                                              .grey
                                              .shade700,
                                    ),

                                    'Materials Used: ${widget.productionRecord.materials.length}',
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                Visibility(
                                  visible:
                                      screenWidth(context) >
                                      mobileScreenSmall,
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.only(
                                          right: 4.0,
                                        ),
                                    child: Text(
                                      style: TextStyle(
                                        fontSize:
                                            theme
                                                .mobileTexts
                                                .b4
                                                .fontSize,
                                        fontWeight:
                                            FontWeight
                                                .normal,
                                        color:
                                            Colors
                                                .grey
                                                .shade700,
                                      ),
                                      'View More',
                                    ),
                                  ),
                                ),
                                Icon(
                                  size: 15,
                                  color:
                                      Colors.grey.shade400,
                                  Icons
                                      .arrow_forward_ios_rounded,
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                        Divider(
                          color: Colors.grey.shade400,
                          thickness: 0.5,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            right: 15,
                          ),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                  children: [
                                    Visibility(
                                      visible:
                                          screenWidth(
                                            context,
                                          ) >
                                          mobileScreenSmall,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(
                                              right: 5.0,
                                            ),
                                        child: Text(
                                          style: TextStyle(
                                            fontSize:
                                                theme
                                                    .mobileTexts
                                                    .b4
                                                    .fontSize,
                                            color:
                                                Colors
                                                    .grey
                                                    .shade600,
                                          ),
                                          'Staff:',
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      child: Text(
                                        style: TextStyle(
                                          fontSize:
                                              theme
                                                  .mobileTexts
                                                  .b4
                                                  .fontSize,
                                          color:
                                              theme
                                                  .lightModeColor
                                                  .prColor300,
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                        ),
                                        cutLongText(
                                          widget
                                                  .productionRecord
                                                  .staffName ??
                                              'Item Not Set',
                                          15,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  Visibility(
                                    visible:
                                        screenWidth(
                                          context,
                                        ) >
                                        mobileScreenSmall,
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(
                                            right: 4.0,
                                          ),
                                      child: Text(
                                        style: TextStyle(
                                          fontSize:
                                              theme
                                                  .mobileTexts
                                                  .b4
                                                  .fontSize,
                                          color:
                                              Colors
                                                  .grey
                                                  .shade600,
                                        ),
                                        'Date:',
                                      ),
                                    ),
                                  ),
                                  Text(
                                    style: TextStyle(
                                      fontSize:
                                          theme
                                              .mobileTexts
                                              .b4
                                              .fontSize,
                                      color:
                                          theme
                                              .lightModeColor
                                              .prColor300,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                    formatDateTimeTime(
                                      widget
                                              .productionRecord
                                              .createdAt ??
                                          DateTime.now(),
                                    ),
                                  ),
                                ],
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
          ),
        ),
      ),
    );
  }
}
