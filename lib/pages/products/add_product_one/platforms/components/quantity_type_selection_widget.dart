import 'package:flutter/material.dart';
import 'package:stockall/providers/theme_provider.dart';

class QuantityTypeSelectionWidget extends StatefulWidget {
  final ThemeProvider theme;
  final int? selectedIndex;
  final Function(int? index)? setQuantityIndex;
  final bool? showSelectPriceText;
  const QuantityTypeSelectionWidget({
    super.key,
    required this.theme,
    required this.selectedIndex,
    required this.setQuantityIndex,
    this.showSelectPriceText,
  });

  @override
  State<QuantityTypeSelectionWidget> createState() =>
      _QuantityTypeSelectionWidgetState();
}

class _QuantityTypeSelectionWidgetState
    extends State<QuantityTypeSelectionWidget> {
  List<QuantityTypeClass> quantityTypeList = [
    QuantityTypeClass(index: 1, name: 'Simple Quantity'),
    QuantityTypeClass(
      index: 2,
      name: 'Dimensional Quantity (2-D)',
    ),
  ];
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
            'Select Quantity Type:',
          ),
        ),
        PopupMenuButton(
          // offset: Offset(-20, 30),
          color: Colors.white,
          itemBuilder:
              (context) =>
                  quantityTypeList
                      .map(
                        (item) =>
                            myPopUpMenuItemQuantityTypeSelection(
                              quantityTypeList:
                                  quantityTypeList,
                              item: item,
                              setQuantityIndex:
                                  widget.setQuantityIndex,
                              theme: widget.theme,
                              selectedIndex:
                                  widget.selectedIndex,
                              context: context,
                            ),
                      )
                      .toList(),
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
                  quantityTypeList
                      .firstWhere(
                        (item) =>
                            item.index ==
                            widget.selectedIndex,
                      )
                      .name,
                ),
                Icon(Icons.keyboard_arrow_down),
              ],
            ),
          ),
        ),
        SizedBox(height: 10),
      ],
    );
  }
}

PopupMenuItem myPopUpMenuItemQuantityTypeSelection({
  required Function(int? index)? setQuantityIndex,
  required QuantityTypeClass item,
  required List<QuantityTypeClass> quantityTypeList,
  required ThemeProvider theme,
  required int? selectedIndex,
  required BuildContext context,
}) {
  bool getBold() {
    if (item.index == selectedIndex) {
      return true;
    } else {
      return false;
    }
  }

  bool getVisibility() {
    if (item.index == selectedIndex) {
      return true;
    } else {
      return false;
    }
  }

  return PopupMenuItem(
    onTap: () {
      setQuantityIndex != null
          ? setQuantityIndex(item.index)
          : {};
    },
    child: ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: 700,
        minWidth: 400,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 10.0,
        ),
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
                item.name,
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
    ),
  );
}

class QuantityTypeClass {
  final int index;
  final String name;

  QuantityTypeClass({
    required this.index,
    required this.name,
  });
}
