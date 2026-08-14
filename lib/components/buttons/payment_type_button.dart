import 'package:flutter/material.dart';
import 'package:stockall/main.dart';

class PaymentTypeButton extends StatelessWidget {
  final int index;
  final Function()? action;
  const PaymentTypeButton({
    super.key,
    required this.index,
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
          onTap: () {
            if (returnSalesProvider()
                    .currentCart()
                    .isInvoice &&
                index == 2) {
              return;
            } else {
              returnSalesProvider().changeMethod(
                index: index,
                context: context,
              );
              action != null ? action!() : {};
            }
          },
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
                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        style: TextStyle(
                          fontSize:
                              theme.mobileTexts.b3.fontSize,
                          fontWeight: FontWeight.bold,
                          color:
                              returnSalesProviderContext(
                                            context,
                                          )
                                          .currentCart()
                                          .isInvoice &&
                                      index == 2
                                  ? Colors.grey
                                  : null,
                        ),
                        returnSalesProviderContext(
                          context,
                        ).returnPaymentMethodSalesPage(
                          index,
                        )['method'],
                      ),
                      Text(
                        style: TextStyle(
                          fontSize:
                              theme.mobileTexts.b4.fontSize,
                          fontWeight: FontWeight.normal,
                          color:
                              returnSalesProviderContext(
                                            context,
                                          )
                                          .currentCart()
                                          .isInvoice &&
                                      index == 2
                                  ? Colors.grey
                                  : theme
                                      .lightModeColor
                                      .secColor200,
                        ),
                        returnSalesProviderContext(
                          context,
                        ).returnPaymentMethodSalesPage(
                          index,
                        )['subText'],
                      ),
                    ],
                  ),
                  Checkbox(
                    activeColor:
                        returnSalesProviderContext(
                                  context,
                                ).currentCart().isInvoice &&
                                index == 2
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
                    value:
                        returnSalesProviderContext(
                          context,
                        ).currentCart().paymentMethod ==
                        index,
                    onChanged: (value) {
                      if (returnSalesProvider()
                              .currentCart()
                              .isInvoice &&
                          index == 2) {
                        return;
                      } else {
                        returnSalesProvider().changeMethod(
                          context: context,
                          index: index,
                        );
                      }
                    },
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

class PaymentTypeDropdown extends StatefulWidget {
  const PaymentTypeDropdown({super.key});

  @override
  State<PaymentTypeDropdown> createState() =>
      _PaymentTypeDropdownState();
}

class _PaymentTypeDropdownState
    extends State<PaymentTypeDropdown> {
  bool isOpen = false;

  void toggleIsOpen() {
    setState(() {
      isOpen = !isOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Column(
        children: [
          Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: Colors.grey.shade300,
              ),
            ),
            child: InkWell(
              mouseCursor: SystemMouseCursors.click,
              onTap: () {
                toggleIsOpen();
              },
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
                      Column(
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
                            ),
                            returnSalesProviderContext(
                              context,
                            ).selectedPaymentMethod()['method'],
                          ),
                          Text(
                            style: TextStyle(
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b4
                                      .fontSize,
                              fontWeight: FontWeight.normal,
                            ),
                            returnSalesProviderContext(
                              context,
                            ).selectedPaymentMethod()['subText'],
                          ),
                        ],
                      ),
                      Icon(
                        size: 30,
                        isOpen
                            ? Icons
                                .keyboard_arrow_up_rounded
                            : Icons
                                .keyboard_arrow_down_rounded,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Visibility(
            visible: isOpen,
            child: Column(
              children: [
                SizedBox(height: 5),
                PaymentTypeButton(
                  index: 0,
                  action: () {
                    toggleIsOpen();
                  },
                ),
                PaymentTypeButton(
                  index: 1,
                  action: () {
                    toggleIsOpen();
                  },
                ),
                PaymentTypeButton(
                  index: 2,
                  action: () {
                    toggleIsOpen();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
