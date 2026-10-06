import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/classes/temp_product_class/prices_class/product_prices_class.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/providers/theme_provider.dart';

class PriceSelectionWidget extends StatefulWidget {
  final TempProductClass? product;
  final ThemeProvider theme;
  final String? priceUuid;
  final Function(String? uuid)? setPriceUuid;
  final bool? showSelectPriceText;
  final List<ProductPricesClass>? priceList;
  final double? conversion;
  const PriceSelectionWidget({
    super.key,
    this.product,
    this.conversion,
    required this.theme,
    required this.priceUuid,
    required this.setPriceUuid,
    this.priceList,
    this.showSelectPriceText,
  });

  @override
  State<PriceSelectionWidget> createState() =>
      _PriceSelectionWidgetState();
}

class _PriceSelectionWidgetState
    extends State<PriceSelectionWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 5,
      children: [
        Visibility(
          visible: widget.showSelectPriceText != false,
          child: Text(
            style: TextStyle(
              fontSize:
                  widget.theme.mobileTexts.b4.fontSize,
              fontWeight: FontWeight.bold,
            ),
            'Select Price:',
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 450),
          child: PopupMenuButton(
            // offset: Offset(-20, 30),
            color: Colors.white,
            itemBuilder:
                (context) =>
                    widget.priceList
                        ?.map(
                          (item) =>
                              myPopUpMenuItemPriceSelection(
                                priceList: widget.priceList,
                                conversion:
                                    widget.conversion,
                                item: item,
                                product: widget.product,
                                setPriceUuid:
                                    widget.setPriceUuid,
                                theme: widget.theme,
                                priceUuid: widget.priceUuid,
                                context: context,
                              ),
                        )
                        .toList() ??
                    widget.product
                        ?.getPricesList()
                        .map(
                          (item) =>
                              myPopUpMenuItemPriceSelection(
                                priceList: widget.priceList,
                                item: item,
                                product: widget.product,
                                conversion:
                                    widget.conversion,
                                setPriceUuid:
                                    widget.setPriceUuid,
                                theme: widget.theme,
                                priceUuid: widget.priceUuid,
                                context: context,
                              ),
                        )
                        .toList() ??
                    [],
            child: Container(
              padding: EdgeInsets.fromLTRB(10, 5, 5, 5),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.shade200,
                ),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    style: TextStyle(
                      fontSize:
                          widget
                              .theme
                              .mobileTexts
                              .b3
                              .fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                    widget.priceList != null
                        ? "${widget.priceList?.firstWhere((item) => item.uuid == widget.priceUuid).name ?? ''}: ${formatMoneyBig(amount: ((widget.priceList?.firstWhere((item) => item.uuid == widget.priceUuid).priceValue ?? 0) * (widget.conversion ?? 0)), context: context)}"
                        : "${widget.product?.getProductPrice(priceUuid: widget.priceUuid).name ?? 'Name'}: ${formatMoneyBig(amount: ((widget.product?.getProductPrice(priceUuid: widget.priceUuid).priceValue ?? 0) * (widget.conversion ?? 0)), context: context)}",
                  ),
                  Icon(Icons.keyboard_arrow_down),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 10),
      ],
    );
  }
}

PopupMenuItem myPopUpMenuItemPriceSelection({
  required Function(String? uuid)? setPriceUuid,
  required ProductPricesClass item,
  required double? conversion,
  required ThemeProvider theme,
  required String? priceUuid,
  required TempProductClass? product,
  required List<ProductPricesClass>? priceList,
  required BuildContext context,
}) {
  bool getBold() {
    if (priceList != null && item.uuid == priceUuid) {
      return true;
    } else if ((product
            ?.getProductPrice(priceUuid: priceUuid)
            .uuid) ==
        item.uuid) {
      return true;
    } else {
      return false;
    }
  }

  bool getVisibility() {
    if (priceList != null && item.uuid == priceUuid) {
      return true;
    } else if ((product
            ?.getProductPrice(priceUuid: priceUuid)
            .uuid) ==
        item.uuid) {
      return true;
    } else {
      return false;
    }
  }

  return PopupMenuItem(
    onTap: () {
      setPriceUuid != null ? setPriceUuid(item.uuid) : {};
    },
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              style: TextStyle(
                fontSize: theme.mobileTexts.b3.fontSize,
                fontWeight:
                    getBold() ? FontWeight.bold : null,
              ),
              "${item.name ?? 'Name'}: ${formatMoneyBig(amount: item.priceValue * (conversion ?? 1), context: context)}",
            ),
          ),
          Visibility(
            visible: getVisibility(),
            child: Icon(
              size: 17,
              color: Colors.grey.shade700,
              Icons.check,
            ),
          ),
        ],
      ),
    ),
  );
}
