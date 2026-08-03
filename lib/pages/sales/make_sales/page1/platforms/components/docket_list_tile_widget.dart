import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_cart_items/temp_cart_item.dart';
import 'package:stockall/components/text_fields/edit_cart_text_field.dart';
import 'package:stockall/constants/bottom_sheet_widgets.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/theme_provider.dart';

class DocketListTileWidget extends StatefulWidget {
  const DocketListTileWidget({
    super.key,
    required this.list,
    required this.theme,
    required this.item,
  });

  final List<TempCartItem> list;
  final ThemeProvider theme;
  final TempCartItem item;

  @override
  State<DocketListTileWidget> createState() =>
      _DocketListTileWidgetState();
}

class _DocketListTileWidgetState
    extends State<DocketListTileWidget> {
  TempCartItem? newItem;
  TextEditingController controller =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        newItem = widget.item.copyWith();
        controller.text = widget.item.quantity.toString();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        mouseCursor: SystemMouseCursors.click,
        onTap: () {
          setState(() {
            if (widget.list.contains(newItem)) {
              widget.list.remove(newItem);
            } else {
              widget.list.add(newItem!);
              if (controller.text.isEmpty) {
                newItem?.quantity++;
                controller.text =
                    (newItem?.quantity ?? 0).toString();
              }
            }
          });
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 7.0,
            horizontal: 12,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  style: TextStyle(
                    fontSize:
                        widget
                            .theme
                            .mobileTexts
                            .b3
                            .fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                  newItem?.getItem()?.name ?? 'Name',
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 6,
                children: [
                  Ink(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        3,
                      ),
                      color: Colors.grey.shade200,
                    ),
                    child: InkWell(
                      mouseCursor: SystemMouseCursors.click,
                      borderRadius: BorderRadius.circular(
                        3,
                      ),
                      onTap: () {
                        setState(() {
                          if ((newItem?.quantity ?? 0) >
                              0) {
                            newItem?.quantity--;
                            controller.text =
                                (newItem?.quantity ?? 0)
                                    .toString();
                          }
                          if ((newItem?.quantity ?? 0) ==
                              0) {
                            widget.list.remove(newItem);
                          }
                          controller.text =
                              (newItem?.quantity ?? 0)
                                  .toString();
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 7.0,
                          horizontal: 8,
                        ),
                        child: Icon(
                          size: 14,
                          Icons.arrow_back_ios_new_rounded,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 40,
                    width: 100,
                    child: EditCartTextField(
                      title: '',
                      hint: '0',
                      showTitle: false,
                      onTap: () {
                        showOnScreenKeyboard();
                      },
                      onChanged: (value) {
                        if (widget.item.quantity >
                            (double.tryParse(
                                  value.replaceAll(',', ''),
                                ) ??
                                0)) {
                          setState(() {
                            newItem?.quantity =
                                double.tryParse(
                                  controller.text
                                      .replaceAll(',', ''),
                                ) ??
                                0;
                          });
                        } else {
                          setState(() {
                            newItem?.quantity =
                                widget.item.quantity;
                            controller.text =
                                (newItem?.quantity ?? 0)
                                    .toString();
                          });
                        }
                        setState(() {
                          if (!widget.list.contains(
                            newItem,
                          )) {
                            widget.list.add(newItem!);
                          }
                        });
                      },
                      controller: controller,
                      theme: returnTheme(context),
                    ),
                  ),
                  Ink(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        3,
                      ),
                      color: Colors.grey.shade200,
                    ),
                    child: InkWell(
                      mouseCursor: SystemMouseCursors.click,
                      borderRadius: BorderRadius.circular(
                        3,
                      ),
                      onTap: () {
                        // await mainLocalLog(widget.item.quantity);
                        setState(() {
                          if (widget.item.quantity >
                              (newItem?.quantity ?? 0)) {
                            newItem?.quantity++;
                            if (!widget.list.contains(
                              newItem,
                            )) {
                              widget.list.add(newItem!);
                            }
                            controller.text =
                                (newItem?.quantity ?? 0)
                                    .toString();
                          }
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 7.0,
                          horizontal: 8,
                        ),
                        child: Icon(
                          size: 14,
                          Icons.arrow_forward_ios_rounded,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey,
                        ),
                      ),
                      child: Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              widget.list.contains(newItem)
                                  ? widget
                                      .theme
                                      .lightModeColor
                                      .prColor250
                                  : Colors.transparent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
