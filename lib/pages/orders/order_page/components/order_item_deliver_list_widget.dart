import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_orders/order_items.dart';
import 'package:stockall/components/text_fields/edit_cart_text_field.dart';
import 'package:stockall/constants/bottom_sheet_widgets.dart';
import 'package:stockall/local_database/on_screen_keyboard_pin/on_screen_keyboard_pin_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/theme_provider.dart';

class OrderItemDeliverListWidget extends StatefulWidget {
  const OrderItemDeliverListWidget({
    super.key,
    required this.action,
    required this.list,
    required this.theme,
    required this.item,
  });

  final List<OrderItems> list;
  final ThemeProvider theme;
  final OrderItems item;
  final Function()? action;

  @override
  State<OrderItemDeliverListWidget> createState() =>
      _OrderItemDeliverListWidgetState();
}

class _OrderItemDeliverListWidgetState
    extends State<OrderItemDeliverListWidget> {
  OrderItems? newItem;
  TextEditingController controller =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        newItem = widget.item.copyWith();
        controller.text =
            (widget.item.remainingQuantity ?? 0).toString();
      });
    });
  }

  void fireAction() {
    if (widget.action != null) {
      widget.action!();
    }
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
              fireAction();
              if (controller.text.isEmpty) {
                newItem?.remainingQuantity =
                    (newItem?.remainingQuantity ?? 0) + 1;
                controller.text =
                    (newItem?.remainingQuantity ?? 0)
                        .toString();
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
                  newItem?.productName ?? 'Name',
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
                          if ((newItem?.remainingQuantity ??
                                  0) >
                              0) {
                            newItem?.remainingQuantity =
                                (newItem?.remainingQuantity ??
                                    0) -
                                1;
                            controller.text =
                                (newItem?.remainingQuantity ??
                                        0)
                                    .toString();
                          }
                          if ((newItem?.remainingQuantity ??
                                  0) ==
                              0) {
                            widget.list.remove(newItem);
                          } else {
                            setState(() {
                              if (!widget.list.contains(
                                newItem,
                              )) {
                                fireAction();
                                widget.list.add(newItem!);
                              }
                            });
                          }
                          controller.text =
                              (newItem?.remainingQuantity ??
                                      0)
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
                    height: 45,
                    width: 100,
                    child: EditCartTextField(
                      title: '',
                      hint: '0',
                      showTitle: false,
                      onTap: () {
                        if (OnScreenKeyboardPinFunc()
                                .getOnScreenKeyboardPinClass()
                                ?.isOn ==
                            true) {
                          showOnScreenKeyboard();
                        }
                      },
                      onChanged: (value) {
                        if (((widget
                                        .item
                                        .remainingQuantity ??
                                    0) +
                                1) >
                            (double.tryParse(
                                  value.replaceAll(',', ''),
                                ) ??
                                0)) {
                          setState(() {
                            newItem?.remainingQuantity =
                                double.tryParse(
                                  controller.text
                                      .replaceAll(',', ''),
                                ) ??
                                0;
                          });
                        } else {
                          setState(() {
                            newItem?.remainingQuantity =
                                widget
                                    .item
                                    .remainingQuantity;
                            controller.text =
                                (newItem?.remainingQuantity ??
                                        0)
                                    .toString();
                          });
                        }
                        setState(() {
                          if ((double.tryParse(
                                    value.replaceAll(
                                      ',',
                                      '',
                                    ),
                                  ) ??
                                  0) >
                              0) {
                            if (!widget.list.contains(
                              newItem,
                            )) {
                              fireAction();
                              widget.list.add(newItem!);
                            }
                          } else {
                            widget.list.remove(newItem!);
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
                        // await mainLocalLog(widget.item.remainingQuantity);
                        setState(() {
                          if ((widget
                                      .item
                                      .remainingQuantity ??
                                  0) >
                              (newItem?.remainingQuantity ??
                                  0)) {
                            newItem?.remainingQuantity =
                                (newItem?.remainingQuantity ??
                                    0) +
                                1;
                            if (!widget.list.contains(
                              newItem,
                            )) {
                              fireAction();
                              widget.list.add(newItem!);
                            }
                            controller.text =
                                (newItem?.remainingQuantity ??
                                        0)
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
