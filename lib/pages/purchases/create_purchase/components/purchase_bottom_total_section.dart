import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_purchase/temp_purchase.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/dialog_template.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/components/text_fields/money_textfield.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/purchases/components/purchase_payment_channel_selector.dart';

class PurchaseBottomTotalSection extends StatefulWidget {
  final TextEditingController priceController;
  final TextEditingController quantityController;
  final TempPurchase? purchase;
  final Function(bool value) toggleIsLoading;
  final Function(bool value) showSuccess;
  const PurchaseBottomTotalSection({
    super.key,
    required this.priceController,
    required this.quantityController,
    required this.purchase,
    required this.toggleIsLoading,
    required this.showSuccess,
  });

  @override
  State<PurchaseBottomTotalSection> createState() =>
      _PurchaseBottomTotalSectionState();
}

class _PurchaseBottomTotalSectionState
    extends State<PurchaseBottomTotalSection> {
  bool updateInventory = true;
  int paymentSelected = 2;
  int paymentChannelOption = 0; // 0 = Cash, 1 = Bank
  String? selectedBankName;

  void checkFields() async {
    if (returnPurchaseActionProvider()
        .purchaseListItems
        .isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          var theme = returnTheme(context);
          return InfoAlert(
            theme: theme,
            message:
                'No Item has been added to the List. Please add items to the list before proceeding',
            title: 'Empty List',
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (firstDialog) {
          paymentSelected = 2;
          paymentChannelOption = 0;
          selectedBankName = null;
          widget.priceController.text =
              returnPurchaseActionProvider()
                  .totalPurchaseAmount()
                  .toString();
          return StatefulBuilder(
            builder:
                (newContext, setStatee) => DialogTemplate(
                  theme: returnTheme(context, listen: false),
                  message:
                      widget.purchase != null
                          ? "Click on the button below to confirm to create purchase."
                          : 'Set the payment amount below',
                  title:
                      widget.purchase != null
                          ? "Proceed with action"
                          : 'Set Payment Amount',
                  action: () async {
                    showDialog(
                      context: context,
                      builder: (confirmDialog) {
                        return ConfirmationAlert(
                          theme: returnTheme(
                            context,
                            listen: false,
                          ),
                          message:
                              'You are about to record a purchase and update the items, are you sure you want to proceed?',
                          title: 'Proceed With Action',
                          action: () async {
                            Navigator.of(firstDialog).pop();
                            Navigator.of(
                              confirmDialog,
                            ).pop();

                            widget.toggleIsLoading(true);

                            final purchaseProvider =
                                returnPurchaseActionProvider();
                            var res = await purchaseProvider
                                .createPurchaseAction(
                                  purchase: widget.purchase,
                                  updateInventory:
                                      widget.purchase !=
                                      null,
                                  paymentMethod:
                                      PurchasePaymentChannelSelector
                                          .resolvePaymentMethod(
                                        paymentOption:
                                            paymentChannelOption,
                                        selectedBankName:
                                            selectedBankName,
                                      ),
                                  paymentAmount:
                                      widget
                                              .priceController
                                              .text
                                              .isEmpty
                                          ? null
                                          : double.tryParse(
                                            widget
                                                .priceController
                                                .text
                                                .replaceAll(
                                                  ',',
                                                  '',
                                                ),
                                          ),
                                );
                            widget.toggleIsLoading(false);
                            if (res == 0) {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return InfoAlert(
                                    theme: returnTheme(
                                      context,
                                      listen: false,
                                    ),
                                    message:
                                        'An Error Occoured while Creating this purchase. Please try again later.',
                                    title:
                                        'An Error Occoured',
                                  );
                                },
                              );
                              return;
                            }
                            widget.showSuccess(true);

                            Future.delayed(
                              Duration(seconds: 2),
                              () {
                                if (context.mounted) {
                                  Navigator.of(
                                    context,
                                  ).pop();
                                }
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                  widget: Visibility(
                    visible: widget.purchase == null,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 5,
                      children: [
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                          spacing: 4,
                          children: [
                            Text(
                              style: TextStyle(
                                fontSize:
                                    returnTheme(
                                          context,
                                          listen: false,
                                        )
                                        .mobileTexts
                                        .b3
                                        .fontSize,
                                fontWeight: FontWeight.bold,
                              ),
                              'Make Payment',
                            ),
                            Row(
                              spacing: 5,
                              children: [
                                InkWell(
                                  mouseCursor:
                                      SystemMouseCursors
                                          .click,
                                  onTap: () {
                                    setStatee(() {
                                      paymentSelected = 1;
                                      widget.priceController
                                          .clear();
                                    });
                                  },
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.all(
                                          4,
                                        ),
                                    child: Row(
                                      spacing: 4,
                                      children: [
                                        Text(
                                          style: TextStyle(
                                            fontSize:
                                                returnTheme(
                                                      context,
                                                      listen:
                                                          false,
                                                    )
                                                    .mobileTexts
                                                    .b3
                                                    .fontSize,
                                            fontWeight:
                                                paymentSelected ==
                                                        1
                                                    ? FontWeight
                                                        .bold
                                                    : null,
                                          ),
                                          'Part',
                                        ),
                                        Container(
                                          padding:
                                              EdgeInsets.all(
                                                2,
                                              ),
                                          decoration: BoxDecoration(
                                            shape:
                                                BoxShape
                                                    .circle,
                                            border: Border.all(
                                              color:
                                                  Colors
                                                      .grey
                                                      .shade400,
                                            ),
                                          ),
                                          child: Container(
                                            padding:
                                                EdgeInsets.all(
                                                  3.5,
                                                ),
                                            decoration: BoxDecoration(
                                              shape:
                                                  BoxShape
                                                      .circle,
                                              color:
                                                  paymentSelected ==
                                                          1
                                                      ? returnTheme(
                                                        context,
                                                        listen:
                                                            false,
                                                      ).lightModeColor.prColor250
                                                      : null,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                InkWell(
                                  mouseCursor:
                                      SystemMouseCursors
                                          .click,
                                  onTap: () {
                                    setStatee(() {
                                      paymentSelected = 2;
                                      widget
                                              .priceController
                                              .text =
                                          returnPurchaseActionProvider()
                                              .totalPurchaseAmount()
                                              .toString();
                                    });
                                  },
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.all(
                                          6,
                                        ),
                                    child: Row(
                                      spacing: 4,
                                      children: [
                                        Text(
                                          style: TextStyle(
                                            fontSize:
                                                returnTheme(
                                                      context,
                                                      listen:
                                                          false,
                                                    )
                                                    .mobileTexts
                                                    .b3
                                                    .fontSize,
                                            fontWeight:
                                                paymentSelected ==
                                                        2
                                                    ? FontWeight
                                                        .bold
                                                    : null,
                                          ),
                                          'Full',
                                        ),
                                        Container(
                                          padding:
                                              EdgeInsets.all(
                                                2,
                                              ),
                                          decoration: BoxDecoration(
                                            shape:
                                                BoxShape
                                                    .circle,
                                            border: Border.all(
                                              color:
                                                  Colors
                                                      .grey
                                                      .shade400,
                                            ),
                                          ),
                                          child: Container(
                                            padding:
                                                EdgeInsets.all(
                                                  3.5,
                                                ),
                                            decoration: BoxDecoration(
                                              shape:
                                                  BoxShape
                                                      .circle,
                                              color:
                                                  paymentSelected ==
                                                          2
                                                      ? returnTheme(
                                                        context,
                                                        listen:
                                                            false,
                                                      ).lightModeColor.prColor250
                                                      : null,
                                            ),
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
                        MoneyTextfield(
                          onChanged: (value) {
                            if ((double.tryParse(
                                      value.replaceAll(
                                        ',',
                                        '',
                                      ),
                                    ) ??
                                    0) <
                                returnPurchaseActionProvider()
                                    .totalPurchaseAmount()) {
                              setStatee(() {
                                paymentSelected = 1;
                              });
                            }
                            if ((double.tryParse(
                                      value.replaceAll(
                                        ',',
                                        '',
                                      ),
                                    ) ??
                                    0) >=
                                returnPurchaseActionProvider()
                                    .totalPurchaseAmount()) {
                              widget.priceController.text =
                                  returnPurchaseActionProvider()
                                      .totalPurchaseAmount()
                                      .toStringAsFixed(0);
                              setStatee(() {
                                paymentSelected = 2;
                              });
                            }
                          },
                          showTitle: false,
                          title: 'Amount',
                          hint: 'Enter Amount',
                          controller:
                              widget.priceController,
                          theme: returnTheme(
                            context,
                            listen: false,
                          ),
                        ),
                        PurchasePaymentChannelSelector(
                          paymentOption: paymentChannelOption,
                          selectedBankName: selectedBankName,
                          onOptionChanged: (val) {
                            setStatee(() {
                              paymentChannelOption = val;
                              if (val == 0) {
                                selectedBankName = null;
                              }
                            });
                          },
                          onBankSelected: (bank) {
                            setStatee(() {
                              selectedBankName = bank;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
          );
        },
      ).then((_) {
        widget.priceController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.only(
          bottom: 10.0,
          top: 10,
          left: 20,
          right: 20,
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.b2.fontSize,
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
                          mouseCursor:
                              SystemMouseCursors.click,
                          onTap: () {
                            widget.priceController.text =
                                returnPurchaseActionProvider()
                                    .totalPurchaseAmount()
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
                                      returnPurchaseActionProvider()
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
                                      Navigator.of(
                                        context,
                                      ).pop();
                                    }
                                  },
                                  widget: MoneyTextfield(
                                    title: 'Total',
                                    hint: 'Enter Total',
                                    controller:
                                        widget
                                            .priceController,
                                    theme: theme,
                                  ),
                                );
                              },
                            ).then((_) {
                              widget.priceController
                                  .clear();
                            });
                          },
                          child: Padding(
                            padding:
                                const EdgeInsets.fromLTRB(
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
                                            .b1
                                            .fontSize,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                  formatMoneyBig(
                                    amount:
                                        returnPurchaseActionProvider(
                                          context: context,
                                        ).totalPurchaseAmount(),
                                    context: context,
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.all(
                                        8.0,
                                      ),
                                  child: Icon(
                                    size: 20,
                                    color:
                                        Colors
                                            .grey
                                            .shade700,
                                    Icons
                                        .mode_edit_outlined,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible:
                            returnPurchaseActionProvider(
                              context: context,
                            ).customTotalAmount !=
                            null,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            mouseCursor:
                                SystemMouseCursors.click,
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (confirmContext) {
                                  return ConfirmationAlert(
                                    theme: theme,
                                    message:
                                        'You are about to cancel the custom total price, and return to the original total price. Are you sure you want to proceed?',
                                    title:
                                        'Reset Total Price',
                                    action: () {
                                      returnPurchaseActionProvider()
                                          .setCustomTotalAmount(
                                            null,
                                          );
                                      Navigator.of(
                                        context,
                                      ).pop();
                                    },
                                  );
                                },
                              );
                            },
                            borderRadius:
                                BorderRadius.circular(20),
                            child: Padding(
                              padding: const EdgeInsets.all(
                                8.0,
                              ),
                              child: Icon(
                                size: 20,
                                Icons.clear,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            MainButtonP(
              themeProvider: theme,
              action: () {
                checkFields();
              },
              text:
                  widget.purchase != null
                      ? 'Update Purchase'
                      : 'Create Purchase',
            ),
          ],
        ),
      ),
    );
  }
}
