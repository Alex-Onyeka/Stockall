import 'package:flutter/material.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/dialog_template.dart';
import 'package:stockall/components/text_fields/money_textfield.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/main.dart';

class TotalRowOrdersDelivery extends StatefulWidget {
  final TextEditingController priceController;
  const TotalRowOrdersDelivery({
    super.key,
    required this.priceController,
  });

  @override
  State<TotalRowOrdersDelivery> createState() =>
      _TotalRowOrdersDeliveryState();
}

class _TotalRowOrdersDeliveryState
    extends State<TotalRowOrdersDelivery> {
  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(6.0, 0, 6, 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            style: TextStyle(
              fontSize: theme.mobileTexts.b3.fontSize,
              fontWeight: FontWeight.bold,
            ),
            'Total:',
          ),
          Row(
            spacing: 3,
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  mouseCursor: SystemMouseCursors.click,
                  onTap: () {
                    widget.priceController.text =
                        returnOrdersActionProvider()
                            .totalOrdersAmount()
                            .toString();
                    showDialog(
                      context: context,
                      builder: (context) {
                        return DialogTemplate(
                          theme: theme,
                          message:
                              'Enter a custom total Value to set.',
                          title: 'Set Custom Total',
                          action: () {
                            if (widget
                                .priceController
                                .text
                                .isNotEmpty) {
                              returnOrdersActionProvider()
                                  .setCustomTotalAmount(
                                    double.tryParse(
                                          widget
                                              .priceController
                                              .text
                                              .replaceAll(
                                                ',',
                                                '',
                                              ),
                                        ) ??
                                        0,
                                  );
                              Navigator.of(context).pop();
                            }
                          },
                          widget: MoneyTextfield(
                            title: 'Total',
                            hint: 'Enter Total',
                            controller:
                                widget.priceController,
                            theme: theme,
                          ),
                        );
                      },
                    ).then((_) {
                      widget.priceController.clear();
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      10.0,
                      4,
                      4,
                      4,
                    ),
                    child: Row(
                      spacing: 5,
                      children: [
                        Text(
                          style: TextStyle(
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b2
                                    .fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                          formatMoneyBig(
                            amount:
                                returnOrdersActionProvider(
                                  context: context,
                                ).totalOrdersAmount(),
                            context: context,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(
                            8.0,
                          ),
                          child: Icon(
                            size: 18,
                            color: Colors.grey.shade700,
                            Icons.mode_edit_outlined,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Visibility(
                visible:
                    returnOrdersActionProvider(
                      context: context,
                    ).customTotalAmount !=
                    null,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    mouseCursor: SystemMouseCursors.click,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (confirmContext) {
                          return ConfirmationAlert(
                            theme: theme,
                            message:
                                'You are about to cancel the custom total price, and return to the original total price. Are you sure you want to proceed?',
                            title: 'Reset Total Price',
                            action: () {
                              returnOrdersActionProvider()
                                  .setCustomTotalAmount(
                                    null,
                                  );
                              Navigator.of(context).pop();
                            },
                          );
                        },
                      );
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(size: 20, Icons.clear),
                    ),
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
