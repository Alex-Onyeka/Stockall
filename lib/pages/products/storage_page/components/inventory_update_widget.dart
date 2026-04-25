import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_inventory_updates/temp_inventory_update_class.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/products/storage_page/storage_details/storage_details_page.dart';
import 'package:stockall/pages/report/events_log/platforms/events_log_desktop.dart';

class InventoryUpdateWidget extends StatefulWidget {
  final TempInventoryUpdateClass update;
  const InventoryUpdateWidget({
    super.key,
    required this.update,
  });

  @override
  State<InventoryUpdateWidget> createState() =>
      _InventoryUpdateWidgetState();
}

class _InventoryUpdateWidgetState
    extends State<InventoryUpdateWidget> {
  String formatValue(String value) {
    double? parsed = double.tryParse(value);
    if (parsed == null) {
      return value.isNotEmpty ? value : 'Null';
    } else {
      if (widget.update.title.split(' ')[1] == 'Selling') {
        return formatMoneyMid(
          amount: parsed,
          context: context,
        );
      } else {
        return value.isNotEmpty
            ? formatLargeNumber(value)
            : 'Null';
      }
    }
  }

  String valueChange({
    required String one,
    required String two,
  }) {
    double? parsed = double.tryParse(one);
    double? parsedOld = double.tryParse(two);
    if (parsed == null || parsedOld == null) {
      return one;
    } else {
      var res = (parsedOld - parsed);
      if (res.isNegative) {
        return formatLargeNumberDouble(res);
      } else {
        return '+${formatLargeNumberDouble(res)}';
      }
    }
  }

  bool isOpen = false;
  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: Colors.grey.shade200,
            width: 1,
          ),
          color: Colors.white,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(2),
          onTap: () {
            setState(() {
              isOpen = !isOpen;
            });
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 10,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  spacing: 10,
                  children: [
                    Icon(
                      size: 20,
                      color:
                          theme.lightModeColor.secColor200,
                      Icons.receipt,
                    ),
                    MyDivider(),
                    Expanded(
                      flex: 4,
                      child: Column(
                        spacing: 1,
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                            'Update:',
                          ),
                          Text(
                            style: TextStyle(
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b3
                                      .fontSize,
                              fontWeight: FontWeight.bold,
                            ),
                            widget.update.title,
                          ),
                        ],
                      ),
                    ),
                    MyDivider(),
                    Expanded(
                      flex: 8,
                      child: Column(
                        spacing: 1,
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                            'Item Name:',
                          ),
                          Text(
                            style: TextStyle(
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b3
                                      .fontSize,
                              fontWeight: FontWeight.bold,
                            ),
                            widget.update.itemName ?? '',
                          ),
                        ],
                      ),
                    ),
                    MyDivider(),
                    Expanded(
                      flex: 3,
                      child: Column(
                        spacing: 1,
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                            'Old Value:',
                          ),
                          Text(
                            style: TextStyle(
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b3
                                      .fontSize,
                              fontWeight: FontWeight.bold,
                            ),
                            formatValue(
                              widget.update.oldValue ?? '',
                            ),
                          ),
                        ],
                      ),
                    ),
                    MyDivider(),
                    Expanded(
                      flex: 3,
                      child: Column(
                        spacing: 1,
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                            'New Value:',
                          ),
                          Text(
                            style: TextStyle(
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b3
                                      .fontSize,
                              fontWeight: FontWeight.bold,
                            ),
                            formatValue(
                              widget.update.newValue ?? '',
                            ),
                          ),
                        ],
                      ),
                    ),
                    MyDivider(),
                    Expanded(
                      flex: 3,
                      child: Column(
                        spacing: 1,
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                            'Change:',
                          ),
                          Text(
                            style: TextStyle(
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b3
                                      .fontSize,
                              fontWeight: FontWeight.bold,
                            ),
                            formatValue(
                              valueChange(
                                one:
                                    widget
                                        .update
                                        .oldValue ??
                                    '',

                                two:
                                    widget
                                        .update
                                        .newValue ??
                                    '',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    MyDivider(),
                    Icon(
                      size: 18,
                      color: Colors.grey.shade500,
                      isOpen
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons
                              .keyboard_arrow_down_rounded,
                    ),
                  ],
                ),
                Visibility(
                  visible: isOpen,
                  child: SizedBox(height: 3),
                ),
                Visibility(
                  visible: isOpen,
                  child: Divider(
                    color: Colors.grey.shade300,
                    height: 20,
                    thickness: 0.8,
                  ),
                ),
                Visibility(
                  visible: isOpen,
                  child: Column(
                    children: [
                      Visibility(
                        visible:
                            widget.update.itemTwoUuid !=
                            null,
                        child: Column(
                          children: [
                            Row(
                              spacing: 10,
                              children: [
                                Icon(
                                  size: 20,
                                  color: Colors.grey,
                                  Icons.person,
                                ),
                                MyDivider(),
                                Expanded(
                                  flex: 4,
                                  child: Column(
                                    spacing: 1,
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                    children: [
                                      Text(
                                        style: TextStyle(
                                          fontSize: 8,
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                        ),
                                        'Staff:',
                                      ),
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
                                        widget
                                                .update
                                                .staffNameTwo ??
                                            'Not Set',
                                      ),
                                    ],
                                  ),
                                ),
                                MyDivider(),
                                Expanded(
                                  flex: 8,
                                  child: Column(
                                    spacing: 1,
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                    children: [
                                      Text(
                                        style: TextStyle(
                                          fontSize: 8,
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                        ),
                                        'Item-2 Name:',
                                      ),
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
                                        returnData()
                                                .productListMain
                                                .where(
                                                  (item) =>
                                                      item.uuid ==
                                                      widget
                                                          .update
                                                          .itemTwoUuid,
                                                )
                                                .isNotEmpty
                                            ? returnData()
                                                .productListMain
                                                .where(
                                                  (item) =>
                                                      item.uuid ==
                                                      widget
                                                          .update
                                                          .itemTwoUuid,
                                                )
                                                .first
                                                .name
                                            : 'Not Set',
                                      ),
                                    ],
                                  ),
                                ),
                                MyDivider(),
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    spacing: 1,
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                    children: [
                                      Text(
                                        style: TextStyle(
                                          fontSize: 8,
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                        ),
                                        'Item-2 Old Value:',
                                      ),
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
                                        formatValue(
                                          widget
                                                  .update
                                                  .itemTwoOldValue ??
                                              '',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                MyDivider(),
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    spacing: 1,
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                    children: [
                                      Text(
                                        style: TextStyle(
                                          fontSize: 8,
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                        ),
                                        'Item-2 New Value:',
                                      ),
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
                                        formatValue(
                                          widget
                                                  .update
                                                  .itemTwoNewValue ??
                                              '',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                MyDivider(),
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    spacing: 1,
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                    children: [
                                      Text(
                                        style: TextStyle(
                                          fontSize: 8,
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                        ),
                                        'Item-2 Change:',
                                      ),
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
                                        formatValue(
                                          valueChange(
                                            one:
                                                widget
                                                    .update
                                                    .itemTwoOldValue ??
                                                '',

                                            two:
                                                widget
                                                    .update
                                                    .itemTwoNewValue ??
                                                '',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                MyDivider(),
                                Icon(
                                  size: 18,
                                  color:
                                      Colors.grey.shade500,
                                  isOpen
                                      ? Icons
                                          .keyboard_arrow_up_rounded
                                      : Icons
                                          .keyboard_arrow_down_rounded,
                                ),
                              ],
                            ),
                            SizedBox(height: 3),
                            Divider(
                              color: Colors.grey.shade300,
                              height: 20,
                              thickness: 0.8,
                            ),
                          ],
                        ),
                      ),

                      Row(
                        mainAxisAlignment:
                            widget
                                        .update
                                        .departmentUuidTwo !=
                                    null
                                ? MainAxisAlignment
                                    .spaceBetween
                                : MainAxisAlignment.end,
                        children: [
                          Visibility(
                            visible:
                                widget
                                    .update
                                    .departmentUuidTwo !=
                                null,
                            child: Expanded(
                              child: Column(
                                spacing: 1,
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  Text(
                                    style: TextStyle(
                                      fontSize: 8,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                    'Department:',
                                  ),
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
                                    widget
                                            .update
                                            .departmentNameTwo ??
                                        '',
                                  ),
                                ],
                              ),
                            ),
                          ),
                          MyDivider(),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                            ),
                            child: Row(
                              mainAxisSize:
                                  MainAxisSize.min,
                              mainAxisAlignment:
                                  MainAxisAlignment.end,
                              spacing: 10,
                              children: [
                                Row(
                                  spacing: 5,
                                  children: [
                                    Text(
                                      style: TextStyle(
                                        fontSize:
                                            theme
                                                .mobileTexts
                                                .b4
                                                .fontSize,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                      'Creator:',
                                    ),
                                    Text(
                                      style: TextStyle(
                                        fontSize:
                                            theme
                                                .mobileTexts
                                                .b4
                                                .fontSize,
                                      ),
                                      widget
                                              .update
                                              .staffName ??
                                          '',
                                    ),
                                  ],
                                ),
                                MyDivider(),
                                Row(
                                  spacing: 5,
                                  children: [
                                    Text(
                                      style: TextStyle(
                                        fontSize:
                                            theme
                                                .mobileTexts
                                                .b4
                                                .fontSize,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                      'Date:',
                                    ),
                                    Text(
                                      style: TextStyle(
                                        fontSize:
                                            theme
                                                .mobileTexts
                                                .b4
                                                .fontSize,
                                      ),
                                      formatDateTimeTime(
                                        widget
                                                .update
                                                .createdAt ??
                                            DateTime.now(),
                                      ),
                                    ),
                                  ],
                                ),
                                Visibility(
                                  visible:
                                      widget
                                              .update
                                              .itemUuid !=
                                          null &&
                                      returnStorageProductProvider()
                                          .storageProductListMain
                                          .where(
                                            (pr) =>
                                                pr.uuid ==
                                                widget
                                                    .update
                                                    .itemUuid,
                                          )
                                          .isNotEmpty,
                                  child: Material(
                                    type:
                                        MaterialType
                                            .transparency,
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (
                                              context,
                                            ) {
                                              return StorageDetailsPage(
                                                productUuid:
                                                    widget
                                                        .update
                                                        .itemUuid!,
                                                // comingFromInventoryUpdatesPage:
                                                //     true,
                                              );
                                            },
                                          ),
                                        );
                                      },
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.symmetric(
                                              horizontal:
                                                  10.0,
                                              vertical: 5,
                                            ),
                                        child: Row(
                                          spacing: 4,
                                          children: [
                                            MyDivider(),
                                            SizedBox(
                                              width: 10,
                                            ),
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
                                              'View Item',
                                            ),
                                            Icon(
                                              size: 15,
                                              color:
                                                  const Color.fromARGB(
                                                    255,
                                                    255,
                                                    176,
                                                    7,
                                                  ),
                                              Icons
                                                  .arrow_forward_ios_rounded,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
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
        ),
      ),
    );
  }
}
