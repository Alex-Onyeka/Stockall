import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_item_history/item_history.dart';
import 'package:stockall/classes/temp_production_folder/temp_materials_item_history/materials_item_history.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_item_history/production_item_history.dart';
import 'package:stockall/components/alert_dialogues/dialog_template.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/components/buttons/main_button_transparent.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/production/materials_page/materials_details/materials_details_page.dart';
import 'package:stockall/pages/production/production_items/production_items_details/production_items_details_page.dart';
import 'package:stockall/pages/products/product_details/product_details_page.dart';

class ItemHistoryTile extends StatefulWidget {
  const ItemHistoryTile({
    super.key,
    this.itemHistory,
    this.productionItemHistory,
    this.materialsItemHistory,
    required this.fromDetails,
  });

  final ItemHistory? itemHistory;
  final ProductionItemHistory? productionItemHistory;
  final MaterialsItemHistory? materialsItemHistory;
  final bool fromDetails;

  @override
  State<ItemHistoryTile> createState() =>
      ItemHistoryTileState();
}

class ItemHistoryTileState extends State<ItemHistoryTile> {
  String cutLongText(String text) {
    if (text.length >
        (screenWidth(context) > mobileScreen ? 25 : 15)) {
      return '${text.substring(0, (screenWidth(context) > mobileScreen ? 25 : 15))}...';
    } else {
      return text;
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Padding(
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
            showDialog(
              context: context,
              builder: (firstContext) {
                return DialogTemplate(
                  theme: theme,
                  message: 'View Item History Details',
                  title: 'History Details',
                  action: () {},
                  showBottomActionButtons: false,
                  widget: SizedBox(
                    height: screenHeight(context) - 200,
                    child: ItemHistoryDetailsWidget(
                      itemHistory: widget.itemHistory,
                      productionItemHistory:
                          widget.productionItemHistory,
                      materialsItemHistory:
                          widget.materialsItemHistory,
                      fromDetails: widget.fromDetails,
                    ),
                  ),
                );
              },
            );
          },
          borderRadius: BorderRadius.circular(5),
          child: Container(
            padding: EdgeInsets.fromLTRB(8, 15, 15, 15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [
                Visibility(
                  visible:
                      screenWidth(context) >
                      mobileScreenSmall,
                  child: Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          (widget
                                          .itemHistory
                                          ?.isIncreased ??
                                      widget
                                          .productionItemHistory
                                          ?.isIncreased ??
                                      widget
                                          .materialsItemHistory
                                          ?.isIncreased) ==
                                  true
                              ? Colors.green.shade100
                              : Colors.red.shade100,
                    ),
                    child: Icon(
                      color:
                          (widget
                                          .itemHistory
                                          ?.isIncreased ??
                                      widget
                                          .productionItemHistory
                                          ?.isIncreased ??
                                      widget
                                          .materialsItemHistory
                                          ?.isIncreased) ==
                                  true
                              ? Colors.green
                              : Colors.red,
                      size: 20,
                      (widget.itemHistory?.isIncreased ??
                                  widget
                                      .productionItemHistory
                                      ?.isIncreased ??
                                  widget
                                      .materialsItemHistory
                                      ?.isIncreased) ==
                              true
                          ? Icons.add
                          : Icons.clear,
                    ),
                  ),
                ),
                Flexible(
                  child: Column(
                    children: [
                      Row(
                        spacing: 15,
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
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
                                        (widget
                                                .itemHistory
                                                ?.title ??
                                            widget
                                                .productionItemHistory
                                                ?.title ??
                                            widget
                                                .materialsItemHistory
                                                ?.title ??
                                            'Not Set'),
                                      ),
                                    ),
                                    Text(
                                      style: TextStyle(
                                        fontWeight:
                                            FontWeight.bold,
                                        fontSize:
                                            theme
                                                .mobileTexts
                                                .b2
                                                .fontSize,
                                        color:
                                            (widget.itemHistory?.isIncreased ??
                                                        widget.productionItemHistory?.isIncreased ??
                                                        widget.materialsItemHistory?.isIncreased) ==
                                                    true
                                                ? Colors
                                                    .green
                                                : Colors
                                                    .redAccent,
                                      ),
                                      returnHistoryQuantity(
                                        quantityChange:
                                            (widget
                                                    .itemHistory
                                                    ?.quantityChange ??
                                                widget
                                                    .productionItemHistory
                                                    ?.quantityChange ??
                                                widget
                                                    .materialsItemHistory
                                                    ?.quantityChange),
                                        isIncreased:
                                            (widget
                                                    .itemHistory
                                                    ?.isIncreased ??
                                                widget
                                                    .productionItemHistory
                                                    ?.isIncreased ??
                                                widget
                                                    .materialsItemHistory
                                                    ?.isIncreased),
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
                                  widget
                                          .itemHistory
                                          ?.desc ??
                                      widget
                                          .productionItemHistory
                                          ?.desc ??
                                      widget
                                          .materialsItemHistory
                                          ?.desc ??
                                      'Description Not Set',
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
                                          FontWeight.normal,
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
                                color: Colors.grey.shade400,
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
                          // top: 5.0,
                          // bottom: 5,
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
                                spacing: 5,
                                children: [
                                  Text(
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
                                    'Item:',
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
                                            FontWeight.bold,
                                      ),
                                      cutLongText(
                                        widget
                                                .itemHistory
                                                ?.itemName ??
                                            widget
                                                .productionItemHistory
                                                ?.itemName ??
                                            widget
                                                .materialsItemHistory
                                                ?.itemName ??
                                            'Item Name Not Set',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              spacing: 3,
                              children: [
                                Visibility(
                                  visible:
                                      screenWidth(context) >
                                      mobileScreenSmall,
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
                                            .itemHistory
                                            ?.createdAt ??
                                        widget
                                            .productionItemHistory
                                            ?.createdAt ??
                                        widget
                                            .materialsItemHistory
                                            ?.createdAt ??
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
    );
  }
}

class ItemHistoryDetailsWidget extends StatefulWidget {
  final ItemHistory? itemHistory;
  final ProductionItemHistory? productionItemHistory;
  final MaterialsItemHistory? materialsItemHistory;
  final bool fromDetails;

  const ItemHistoryDetailsWidget({
    super.key,
    this.itemHistory,
    this.productionItemHistory,
    this.materialsItemHistory,
    required this.fromDetails,
  });

  @override
  State<ItemHistoryDetailsWidget> createState() =>
      _ItemHistoryDetailsWidgetState();
}

class _ItemHistoryDetailsWidgetState
    extends State<ItemHistoryDetailsWidget> {
  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Scaffold(
      body: Column(
        spacing: 10,
        children: [
          Divider(height: 1),
          Expanded(
            child: ListView(
              children: [
                ItemHistorySectionWidget(
                  title: 'Item Name',
                  message:
                      widget.itemHistory?.itemName ??
                      widget
                          .productionItemHistory
                          ?.itemName ??
                      widget
                          .materialsItemHistory
                          ?.itemName ??
                      'Not Set',
                ),
                ItemHistorySectionWidget(
                  title: 'Title',
                  message:
                      widget.itemHistory?.title ??
                      widget.productionItemHistory?.title ??
                      widget.materialsItemHistory?.title ??
                      'Title Not Set',
                ),
                ItemHistorySectionWidget(
                  title: 'Description',
                  message:
                      widget.itemHistory?.desc ??
                      widget.productionItemHistory?.desc ??
                      widget.materialsItemHistory?.desc ??
                      'Description Not Set',
                ),
                ItemHistorySectionWidget(
                  title: 'Created Date',
                  message: formatDateWithTime(
                    widget.itemHistory?.createdAt ??
                        widget
                            .productionItemHistory
                            ?.createdAt ??
                        widget
                            .materialsItemHistory
                            ?.createdAt ??
                        DateTime.now(),
                  ),
                ),
                ItemHistorySectionWidget(
                  title: 'Quantity Change',
                  message: returnHistoryQuantity(
                    isIncreased:
                        (widget.itemHistory?.isIncreased ??
                            widget
                                .productionItemHistory
                                ?.isIncreased ??
                            widget
                                .materialsItemHistory
                                ?.isIncreased),
                    quantityChange:
                        widget
                            .itemHistory
                            ?.quantityChange ??
                        widget
                            .productionItemHistory
                            ?.quantityChange ??
                        widget
                            .materialsItemHistory
                            ?.quantityChange,
                  ),
                ),
                ItemHistorySectionWidget(
                  title: 'New Value',
                  message: formatLargeNumber(
                    widget.itemHistory?.newValue ??
                        widget
                            .productionItemHistory
                            ?.newValue ??
                        widget
                            .materialsItemHistory
                            ?.newValue ??
                        '',
                  ),
                ),
                ItemHistorySectionWidget(
                  title: 'Old Value',
                  message: formatLargeNumber(
                    widget.itemHistory?.oldValue ??
                        widget
                            .productionItemHistory
                            ?.oldValue ??
                        widget
                            .materialsItemHistory
                            ?.oldValue ??
                        '0',
                  ),
                ),
                ItemHistorySectionWidget(
                  title: 'Creator',
                  message:
                      widget.itemHistory?.staffName ??
                      widget
                          .productionItemHistory
                          ?.staffName ??
                      widget
                          .materialsItemHistory
                          ?.staffName ??
                      'Not Set',
                ),
                Visibility(
                  visible:
                      (widget.itemHistory?.departmentName ??
                          widget
                              .productionItemHistory
                              ?.departmentName ??
                          widget
                              .materialsItemHistory
                              ?.departmentName) !=
                      null,
                  child: ItemHistorySectionWidget(
                    title: 'Department Name',
                    message:
                        widget
                            .itemHistory
                            ?.departmentName ??
                        widget
                            .productionItemHistory
                            ?.departmentName ??
                        widget
                            .materialsItemHistory
                            ?.departmentName ??
                        'Not Set',
                  ),
                ),
              ],
            ),
          ),
          Visibility(
            visible:
                !widget.fromDetails &&
                (widget.itemHistory?.itemUuid ??
                        widget
                            .productionItemHistory
                            ?.itemUuid ??
                        widget
                            .materialsItemHistory
                            ?.itemUuid) !=
                    null,
            child: MainButtonP(
              themeProvider: theme,
              action: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      if (widget.materialsItemHistory !=
                          null) {
                        return MaterialsDetailsPage(
                          materialUuid:
                              widget
                                  .materialsItemHistory
                                  ?.itemUuid ??
                              '',
                        );
                      } else if (widget
                              .productionItemHistory !=
                          null) {
                        return ProductionItemsDetailsPage(
                          productionItemUuid:
                              widget
                                  .productionItemHistory
                                  ?.itemUuid ??
                              '',
                        );
                      } else {
                        return ProductDetailsPage(
                          productUuid:
                              widget
                                  .itemHistory
                                  ?.itemUuid ??
                              '',
                        );
                      }
                    },
                  ),
                );
              },
              text: 'View Item',
            ),
          ),
          MainButtonTransparent(
            themeProvider: theme,
            constraints: BoxConstraints(),
            text: 'Cancel',
          ),
        ],
      ),
    );
  }
}

class ItemHistorySectionWidget extends StatelessWidget {
  final String title;
  final String message;
  const ItemHistorySectionWidget({
    super.key,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Container(
      margin: EdgeInsets.symmetric(vertical: 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsetsGeometry.fromLTRB(
              10,
              7,
              10,
              5,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(5),
                topRight: Radius.circular(5),
              ),
              color: Colors.grey.shade200,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.b4.fontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade900,
                    ),
                    '$title:',
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsetsGeometry.fromLTRB(
              10,
              5,
              10,
              10,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: Colors.grey.shade100,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.b3.fontSize,
                      fontWeight: FontWeight.normal,
                      color: Colors.grey.shade700,
                    ),
                    message,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String returnHistoryQuantity({
  required double? quantityChange,
  required bool? isIncreased,
}) {
  final quantity = quantityChange ?? 0;

  if (isIncreased == false) {
    return '-${quantity.abs()}';
  }

  return '+${quantity.abs()}';
}
