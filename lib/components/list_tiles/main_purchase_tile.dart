import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stockall/classes/temp_item_purchase_record/temp_item_purchase_record.dart';
import 'package:stockall/classes/temp_purchase/temp_purchase.dart';
import 'package:stockall/classes/temp_suppliers/suppliers_class.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/theme_provider.dart';

class MainPurchaseTile extends StatelessWidget {
  final TempPurchase purchase;
  final Function()? action;
  const MainPurchaseTile({
    super.key,
    required this.purchase,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    if (screenWidth(context) < mobileScreen) {
      return MainPurchaseTileMobile(
        purchase: purchase,
        action: action,
      );
    } else {
      return MainPurchaseTileDesktop(
        purchase: purchase,
        action: action,
      );
    }
  }
}

class MainPurchaseTileMobile extends StatefulWidget {
  final TempPurchase purchase;
  final Function()? action;
  const MainPurchaseTileMobile({
    super.key,
    required this.purchase,
    required this.action,
  });

  @override
  State<MainPurchaseTileMobile> createState() =>
      _MainPurchaseTileMobileState();
}

class _MainPurchaseTileMobileState
    extends State<MainPurchaseTileMobile> {
  String cutLongText(String text) {
    if (text.length < 12) {
      return text;
    } else {
      return '${text.substring(0, 12)}...';
    }
  }

  String cutLongText2(String text) {
    if (text.length < 8) {
      return text;
    } else {
      return '${text.substring(0, 8)}...';
    }
  }

  List<TempItemPurchaseRecord> getProductRecord() {
    var tempRecords =
        returnPurchaseProvider().itemPurchaseRecords;

    return tempRecords
        .where(
          (record) =>
              record.purchaseId == widget.purchase.uuid!,
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    SuppliersClass? supplier;
    List<SuppliersClass> suppliers =
        returnSuppliersProvider(context: context).suppliers
            .where(
              (supplier) =>
                  supplier.uuid != null &&
                  supplier.uuid ==
                      widget.purchase.supplierId,
            )
            .toList();
    if (suppliers.isNotEmpty) {
      supplier = suppliers.first;
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Ink(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),

          borderRadius: BorderRadius.circular(5),
          color: Colors.white,
        ),
        child: InkWell(
          mouseCursor: SystemMouseCursors.click,
          borderRadius: BorderRadius.circular(5),
          onTap: widget.action,
          child: Container(
            padding: EdgeInsetsDirectional.all(15),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.start,
                      spacing: 5,
                      children: [
                        SvgPicture.asset(receiptIconSvg),
                        Text(
                          style: TextStyle(
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b2
                                    .fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                          formatDateWithDay(
                            widget.purchase.createdAt,
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      color: Colors.grey,
                      size: 20,
                      Icons.arrow_forward_ios_rounded,
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    // Text(
                    //   style: TextStyle(
                    //     fontSize:
                    //         theme.mobileTexts.b2.fontSize,
                    //     fontWeight: FontWeight.bold,
                    //     color:
                    //         theme
                    //             .lightModeColor
                    //             .secColor200,
                    //   ),
                    //   '${widget.purchase.paymentMethod} Payment',
                    // ),
                    Text(
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b2.fontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                      '${getProductRecord().length} Item(s) Sold',
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: const Color.fromARGB(
                      162,
                      245,
                      245,
                      245,
                    ),
                    border: Border.all(
                      color: Colors.grey.shade200,
                    ),
                  ),
                  child: Row(
                    spacing: 5,
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 5,
                        child: Column(
                          spacing: 3,
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              style: TextStyle(
                                fontSize:
                                    theme
                                        .mobileTexts
                                        .b3
                                        .fontSize,
                              ),
                              'Item Name',
                            ),
                            Text(
                              style: TextStyle(
                                fontSize:
                                    theme
                                        .mobileTexts
                                        .b2
                                        .fontSize,
                                fontWeight: FontWeight.bold,
                              ),
                              cutLongText(
                                getProductRecord()
                                        .isNotEmpty
                                    ? getProductRecord()
                                            .first
                                            .itemName ??
                                        'Item Name'
                                    : '',
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Column(
                          spacing: 3,
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              style: TextStyle(
                                fontSize:
                                    theme
                                        .mobileTexts
                                        .b3
                                        .fontSize,
                              ),
                              'Total',
                            ),
                            Text(
                              style: TextStyle(
                                fontSize:
                                    theme
                                        .mobileTexts
                                        .b2
                                        .fontSize,
                                fontWeight: FontWeight.bold,
                              ),
                              formatMoneyMid(
                                amount: returnPurchaseProvider(
                                  context: context,
                                ).getTotalMainRevenuePurchase(
                                  widget.purchase,
                                ),
                                context: context,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b2.fontSize,
                        fontWeight: FontWeight.bold,
                        color:
                            theme
                                .lightModeColor
                                .secColor200,
                      ),

                      "Supplier: ${cutLongText2(supplier != null ? (supplier.name) : 'Not Set')}",
                    ),
                    SizedBox(width: 10),
                    Text(
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b2.fontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                      'Staff: ${cutLongText2((widget.purchase.staffName == null || widget.purchase.staffName!.isEmpty) ? 'Not Set' : (widget.purchase.staffName ?? 'Not Set'))}',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MainPurchaseTileDesktop extends StatefulWidget {
  final TempPurchase purchase;
  final Function()? action;
  const MainPurchaseTileDesktop({
    super.key,
    required this.purchase,
    required this.action,
  });

  @override
  State<MainPurchaseTileDesktop> createState() =>
      _MainPurchaseTileDesktopState();
}

class _MainPurchaseTileDesktopState
    extends State<MainPurchaseTileDesktop> {
  String cutLongText(String text) {
    if (text.length < 12) {
      return text;
    } else {
      return '${text.substring(0, 12)}...';
    }
  }

  String cutLongText2(String text) {
    if (text.length < 8) {
      return text;
    } else {
      return '${text.substring(0, 8)}...';
    }
  }

  List<TempItemPurchaseRecord> getProductRecord() {
    var tempRecords =
        returnPurchaseProvider().itemPurchaseRecords;

    return tempRecords
        .where(
          (record) =>
              record.purchaseId == widget.purchase.uuid!,
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    SuppliersClass? supplier =
        returnSuppliersProvider().suppliers
                .where(
                  (supplier) =>
                      supplier.uuid ==
                      widget.purchase.supplierId,
                )
                .isNotEmpty
            ? returnSuppliersProvider().suppliers
                .where(
                  (supplier) =>
                      supplier.uuid ==
                      widget.purchase.supplierId,
                )
                .first
            : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Ink(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),

          borderRadius: BorderRadius.circular(5),
          color: Colors.white,
        ),
        child: InkWell(
          mouseCursor: SystemMouseCursors.click,
          borderRadius: BorderRadius.circular(5),
          onTap: widget.action,
          child: Container(
            padding: EdgeInsetsDirectional.all(10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.start,
                      spacing: 5,
                      children: [
                        SvgPicture.asset(
                          height: 18,
                          receiptIconSvg,
                        ),
                        Text(
                          style: TextStyle(
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b2
                                    .fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                          formatDateWithDay(
                            widget.purchase.createdAt,
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      color: Colors.grey,
                      size: 15,
                      Icons.arrow_forward_ios_rounded,
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: const Color.fromARGB(
                      162,
                      245,
                      245,
                      245,
                    ),
                    border: Border.all(
                      color: Colors.grey.shade200,
                    ),
                  ),
                  child: Row(
                    spacing: 5,
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      ReceicptTileSectionDesktop(
                        flex: 5,
                        subTitle: 'First Item Name',
                        title: cutLongText(
                          getProductRecord().isNotEmpty
                              ? getProductRecord()
                                      .first
                                      .itemName ??
                                  'Not Set'
                              : '',
                        ),
                        theme: theme,
                      ),
                      ReceicptTileSectionDesktop(
                        flex: 4,
                        subTitle: 'Total',
                        title: formatMoneyMid(
                          amount: returnPurchaseProvider(
                            context: context,
                          ).getTotalMainRevenuePurchase(
                            widget.purchase,
                          ),
                          context: context,
                        ),
                        theme: theme,
                      ),
                      ReceicptTileSectionDesktop(
                        flex: 3,
                        subTitle: 'Quantity',
                        title:
                            '${getProductRecord().length} Item(s)',
                        theme: theme,
                      ),
                      // ReceicptTileSectionDesktop(
                      //   flex: 3,
                      //   subTitle: 'Payment Type',
                      //   title:
                      //       widget.purchase.paymentMethod,
                      //   theme: theme,
                      // ),
                      ReceicptTileSectionDesktop(
                        flex: 3,
                        subTitle: 'Supplier',
                        title: cutLongText(
                          supplier?.name ?? 'Not Set',
                        ),
                        theme: theme,
                      ),

                      ReceicptTileSectionDesktop(
                        flex: 3,
                        subTitle: 'Staff',
                        title:
                            'Staff: ${cutLongText2((widget.purchase.staffName == null || widget.purchase.staffName!.isEmpty) ? 'Not Set' : (widget.purchase.staffName ?? 'Not Set'))}',
                        theme: theme,
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

class ReceicptTileSectionDesktop extends StatelessWidget {
  final String title;
  final String subTitle;
  final int flex;
  const ReceicptTileSectionDesktop({
    super.key,
    required this.theme,
    required this.title,
    required this.subTitle,
    required this.flex,
  });

  final ThemeProvider theme;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Column(
        spacing: 3,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            style: TextStyle(
              fontSize: theme.mobileTexts.b4.fontSize,
            ),
            subTitle,
          ),
          Text(
            style: TextStyle(
              fontSize: theme.mobileTexts.b3.fontSize,
              fontWeight: FontWeight.bold,
            ),
            title,
          ),
        ],
      ),
    );
  }
}
