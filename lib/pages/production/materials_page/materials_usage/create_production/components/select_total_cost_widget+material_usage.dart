import 'package:flutter/material.dart';
import 'package:stockall/main.dart';

class SelectTotalCostWidgetMaterialUsage
    extends StatelessWidget {
  final int index;
  final int currentSelection;
  final Function()? action;
  final String title;
  final String subText;
  const SelectTotalCostWidgetMaterialUsage({
    super.key,
    required this.index,
    required this.currentSelection,
    required this.title,
    required this.subText,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: InkWell(
          mouseCursor: SystemMouseCursors.click,
          onTap: action,
          child: SizedBox(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                7,
                10,
                7,
              ),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
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
                            fontWeight: FontWeight.bold,
                            color: null,
                          ),
                          title,
                        ),
                        Text(
                          style: TextStyle(
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b4
                                    .fontSize,
                            fontWeight: FontWeight.normal,
                            color:
                                theme
                                    .lightModeColor
                                    .secColor200,
                          ),
                          subText,
                        ),
                      ],
                    ),
                  ),
                  Checkbox(
                    activeColor:
                        index != currentSelection
                            ? Colors.grey
                            : theme
                                .lightModeColor
                                .prColor250,
                    shape: CircleBorder(side: BorderSide()),
                    side: BorderSide(
                      width: 1,
                      color:
                          theme.lightModeColor.secColor200,
                    ),
                    value: index == currentSelection,
                    onChanged: (value) {},
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
