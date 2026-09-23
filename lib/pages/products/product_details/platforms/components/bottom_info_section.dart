import 'package:flutter/material.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/theme_provider.dart';

class BottomInfoSection extends StatefulWidget {
  const BottomInfoSection({
    super.key,
    required this.theme,
    required this.text,
    required this.mainText,
    this.setBarcodeAction,
    this.actionText,
    this.onClick,
  });

  final ThemeProvider theme;
  final String text;
  final String mainText;
  final Function()? setBarcodeAction;
  final String? actionText;
  final Function()? onClick;

  @override
  State<BottomInfoSection> createState() =>
      _BottomInfoSectionState();
}

class _BottomInfoSectionState
    extends State<BottomInfoSection> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            style: TextStyle(
              fontSize:
                  widget.theme.mobileTexts.b3.fontSize,
              fontWeight: FontWeight.normal,
            ),
            '${widget.text}:',
          ),
          Row(
            children: [
              Visibility(
                visible: widget.setBarcodeAction != null,
                child: Material(
                  color: Colors.transparent,
                  child: Ink(
                    decoration: BoxDecoration(
                      color:
                          widget
                              .theme
                              .lightModeColor
                              .prColor300,
                      borderRadius: BorderRadius.circular(
                        3,
                      ),
                    ),
                    child: InkWell(
                      mouseCursor: SystemMouseCursors.click,
                      borderRadius: BorderRadius.circular(
                        3,
                      ),
                      onTap: widget.setBarcodeAction,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        child: Center(
                          child: Text(
                            style: TextStyle(
                              fontSize:
                                  widget
                                      .theme
                                      .mobileTexts
                                      .b4
                                      .fontSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            widget.actionText ?? '',
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: widget.setBarcodeAction == null,
                child: InkWell(
                  mouseCursor: SystemMouseCursors.click,
                  onTap: () {
                    widget.onClick != null
                        ? widget.onClick!()
                        : {};
                    mainLocalLog('Clicked');
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Visibility(
                        visible: widget.onClick != null,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              color: Colors.grey.shade600,
                              Icons.arrow_left,
                            ),
                            // SizedBox(width: 2),
                          ],
                        ),
                      ),
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
                        widget.mainText,
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
