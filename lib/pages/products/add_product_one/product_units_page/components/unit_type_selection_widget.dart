import 'package:flutter/material.dart';
import 'package:stockall/providers/theme_provider.dart';

class UnitTypeSelectionWidget extends StatefulWidget {
  final ThemeProvider theme;
  final int? currentSelection;
  final Function(int? index)? setUnitType;
  final bool? showSelectUnitText;
  const UnitTypeSelectionWidget({
    super.key,
    required this.theme,
    required this.currentSelection,
    required this.setUnitType,
    this.showSelectUnitText,
  });

  @override
  State<UnitTypeSelectionWidget> createState() =>
      _UnitTypeSelectionWidgetState();
}

class _UnitTypeSelectionWidgetState
    extends State<UnitTypeSelectionWidget> {
  List<UnitTypeClass> priceList = [
    UnitTypeClass(index: 1, name: 'Dynamic'),
    UnitTypeClass(index: 2, name: 'Fixed'),
  ];
  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 5,
      children: [
        Visibility(
          visible: widget.showSelectUnitText != false,
          child: Text(
            style: TextStyle(
              fontSize:
                  widget.theme.mobileTexts.b4.fontSize,
              fontWeight: FontWeight.bold,
            ),
            'Select Conversion Type:',
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 450),
          child: PopupMenuButton(
            // offset: Offset(-20, 30),
            color: Colors.white,
            itemBuilder:
                (context) =>
                    priceList
                        .map(
                          (item) =>
                              myPopUpMenuItemUnitSelection(
                                item: item,
                                setUnitIndex:
                                    widget.setUnitType,
                                theme: widget.theme,
                                currentSelection:
                                    widget.currentSelection,
                                context: context,
                              ),
                        )
                        .toList(),
            child: Container(
              padding: EdgeInsets.fromLTRB(10, 5, 5, 5),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.shade500,
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
                    priceList
                        .firstWhere(
                          (item) =>
                              item.index ==
                              widget.currentSelection,
                        )
                        .name,
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

class UnitTypeClass {
  final int index;
  final String name;

  UnitTypeClass({required this.index, required this.name});
}

PopupMenuItem myPopUpMenuItemUnitSelection({
  required Function(int? index)? setUnitIndex,
  required UnitTypeClass item,
  required ThemeProvider theme,
  required int? currentSelection,
  required BuildContext context,
}) {
  bool getBold() {
    if (item.index == currentSelection) {
      return true;
    } else {
      return false;
    }
  }

  bool getVisibility() {
    if (item.index == currentSelection) {
      return true;
    } else {
      return false;
    }
  }

  return PopupMenuItem(
    onTap: () {
      setUnitIndex != null ? setUnitIndex(item.index) : {};
    },
    child: ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: 500,
        minWidth: 300,
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
