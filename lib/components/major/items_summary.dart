import 'package:flutter/material.dart';
import 'package:stockitt/components/text_fields/text_field_barcode.dart';
import 'package:stockitt/main.dart';
import 'package:stockitt/pages/products/compnents/products_summary_tab.dart';

class ItemsSummary extends StatefulWidget {
  final TextEditingController? searchController;
  final Function(String)? searchAction;
  final bool? onSearch;
  final String? mainTitle;
  final String? subTitle;
  final String? hintText;
  final bool secondRow;
  final bool firsRow;
  final String? title1;
  final String? title2;
  final String? title3;
  final String? title4;
  final double? value1;
  final double? value2;
  final double? value3;
  final double? value4;
  final Color? color1;
  final Color? color2;
  final Color? color3;
  final Color? color4;
  final Function()? scanAction;
  final bool? isMoney1;
  final bool? isMoney2;
  final bool? isMoney3;
  final bool? isMoney4;
  final bool? isFilter;
  final Function()? filterAction;

  const ItemsSummary({
    this.searchController,
    this.searchAction,
    super.key,
    required this.secondRow,
    required this.title1,
    required this.title2,
    this.title3,
    this.title4,
    required this.value1,
    required this.value2,
    this.value3,
    this.value4,
    required this.color1,
    required this.color2,
    this.color3,
    this.color4,
    required this.firsRow,
    this.scanAction,
    this.hintText,
    this.mainTitle,
    this.subTitle,
    this.isMoney1,
    this.isMoney2,
    this.isMoney3,
    this.isMoney4,
    this.onSearch,
    this.isFilter,
    this.filterAction,
  });

  @override
  State<ItemsSummary> createState() => _ItemsSummaryState();
}

class _ItemsSummaryState extends State<ItemsSummary> {
  double returnDouble() {
    if (widget.value1.toString().length > 6 ||
        widget.value2.toString().length > 6 ||
        widget.value3.toString().length > 6 ||
        widget.value4.toString().length > 6) {
      return 15;
    } else {
      return 20;
    }
  }

  bool isFocus = false;
  @override
  Widget build(BuildContext context) {
    var receiptProvider = returnReceiptProvider(context);
    var theme = returnTheme(context);
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.all(returnDouble()),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: const Color.fromARGB(255, 244, 244, 244),
        boxShadow: [
          BoxShadow(
            offset: Offset(0, -5),
            blurRadius: 3,
            color: const Color.fromARGB(41, 0, 0, 0),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment:
                    widget.isFilter != null
                        ? MainAxisAlignment.spaceBetween
                        : MainAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        style: TextStyle(
                          color: Colors.black,
                          fontSize:
                              theme.mobileTexts.b1.fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                        widget.mainTitle ?? '',
                      ),
                      Text(
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize:
                              theme.mobileTexts.b2.fontSize,
                          fontWeight: FontWeight.normal,
                        ),
                        widget.subTitle ?? '',
                      ),
                    ],
                  ),
                  Visibility(
                    visible: widget.isFilter != null,
                    child: MaterialButton(
                      onPressed: widget.filterAction,
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
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
                            ),
                            receiptProvider.isDateSet ||
                                    receiptProvider.setDate
                                ? 'Clear Date'
                                : 'Set Date',
                          ),
                          Icon(
                            size: 20,
                            color:
                                theme
                                    .lightModeColor
                                    .secColor100,
                            receiptProvider.isDateSet ||
                                    receiptProvider.setDate
                                ? Icons.clear
                                : Icons.date_range_outlined,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // Visibility(
              //   visible: widget.onSearch ?? true,
              //   child: SizedBox(height: 10),
              // ),
              Visibility(
                visible: widget.onSearch ?? true,
                child: SizedBox(
                  width:
                      MediaQuery.of(context).size.width -
                      ((returnDouble() * 2) + 40),
                  child: TextFieldBarcode(
                    searchController:
                        widget.searchController ??
                        TextEditingController(),
                    onChanged: widget.searchAction,
                    onPressedScan: widget.scanAction,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Visibility(
                visible: widget.firsRow,
                child: SizedBox(
                  width:
                      MediaQuery.of(context).size.width -
                      ((returnDouble() * 2) + 40),
                  child: Column(
                    spacing: 10,
                    children: [
                      Row(
                        spacing: 10,
                        children: [
                          Expanded(
                            child: ProductSummaryTab(
                              isMoney: widget.isMoney1,
                              color:
                                  widget.color1 ??
                                  Colors.amber,
                              title: widget.title1 ?? '',
                              value: widget.value1 ?? 0,
                            ),
                          ),
                          Expanded(
                            child: ProductSummaryTab(
                              isMoney: widget.isMoney2,
                              color:
                                  widget.color2 ??
                                  Colors.amber,
                              title: widget.title2 ?? '',
                              value: widget.value2 ?? 0,
                            ),
                          ),
                        ],
                      ),
                      Visibility(
                        visible: widget.secondRow,
                        child: Row(
                          spacing: 10,
                          children: [
                            Expanded(
                              child: ProductSummaryTab(
                                isMoney: widget.isMoney3,
                                color:
                                    widget.color3 ??
                                    Colors.amber,
                                title: widget.title3 ?? '',
                                value: widget.value3 ?? 0,
                              ),
                            ),
                            Expanded(
                              child: ProductSummaryTab(
                                isMoney: widget.isMoney4,
                                color:
                                    widget.color4 ??
                                    Colors.amber,
                                title: widget.title4 ?? '',
                                value: widget.value4 ?? 0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
