import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_customers/temp_customers_class.dart';
import 'package:stockall/components/text_fields/money_textfield.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/subscription/general_settings_auth.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/customers/customer_details_page/components/customer_account_details_section_widget.dart';

class PaymentTypeButton extends StatefulWidget {
  final int index;
  final Function()? action;
  const PaymentTypeButton({
    super.key,
    required this.index,
    this.action,
  });

  @override
  State<PaymentTypeButton> createState() =>
      _PaymentTypeButtonState();
}

class _PaymentTypeButtonState
    extends State<PaymentTypeButton> {
  TextEditingController topUpController =
      TextEditingController();
  @override
  Widget build(BuildContext context) {
    TempCustomersClass? customersClass;
    if (widget.index == 3) {
      if (returnSalesProviderContext(
            context,
          ).currentCart().selectedCustomer !=
          null) {
        var customerUuid =
            returnSalesProviderContext(
              context,
            ).currentCart().selectedCustomer;
        List<TempCustomersClass> customers =
            returnCustomersSingle().customers
                .where((item) => item.uuid == customerUuid)
                .toList();
        if (customers.isNotEmpty) {
          customersClass = customers.first;
        }
      }
    }
    var theme = returnTheme(context);
    void selectOptionAction() {
      if (returnSalesProvider()
                  .currentCart()
                  .cartItemTypeIndex ==
              2 &&
          (widget.index == 2 || widget.index == 3)) {
        return;
      }
      //  else if (widget.index == 3 &&
      //     !returnSalesProvider().isBalanceSufficient()) {
      //   showDialog(
      //     context: context,
      //     builder: (erroContext) {
      //       return InfoAlert(
      //         theme: theme,
      //         message:
      //             'This Customers Balance is not enough to make this Purchase. Please Select Another Payment Method and Proceed.',
      //         title: 'Insufficient Balance',
      //       );
      //     },
      //   );
      //   return;
      // }
      else {
        returnSalesProvider().changePaymentMethod(
          index: widget.index,
          context: context,
        );
        widget.action != null ? widget.action!() : {};
      }
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 5.0,
          ),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: Colors.grey.shade300,
              ),
            ),
            child: InkWell(
              mouseCursor: SystemMouseCursors.click,
              onTap: () {
                selectOptionAction();
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
                              color:
                                  returnSalesProviderContext(
                                                    context,
                                                  )
                                                  .currentCart()
                                                  .cartItemTypeIndex ==
                                              2 &&
                                          widget.index == 2
                                      ? Colors.grey
                                      : null,
                            ),
                            "${returnSalesProviderContext(context).returnPaymentMethodSalesPage(widget.index)['method']}${customersClass != null ? " (${formatMoneyBig(amount: customersClass.getBalance(), context: context)})" : ''}",
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
                                  returnSalesProviderContext(
                                                    context,
                                                  )
                                                  .currentCart()
                                                  .cartItemTypeIndex ==
                                              2 &&
                                          widget.index == 2
                                      ? Colors.grey
                                      : theme
                                          .lightModeColor
                                          .secColor200,
                            ),
                            returnSalesProviderContext(
                              context,
                            ).returnPaymentMethodSalesPage(
                              widget.index,
                            )['subText'],
                          ),
                        ],
                      ),
                      Checkbox(
                        activeColor:
                            returnSalesProviderContext(
                                              context,
                                            )
                                            .currentCart()
                                            .cartItemTypeIndex ==
                                        2 &&
                                    widget.index == 2
                                ? Colors.grey
                                : theme
                                    .lightModeColor
                                    .prColor250,
                        shape: CircleBorder(
                          side: BorderSide(),
                        ),
                        side: BorderSide(
                          width: 1,
                          color:
                              theme
                                  .lightModeColor
                                  .secColor200,
                        ),
                        value:
                            returnSalesProviderContext(
                              context,
                            ).currentCart().paymentMethod ==
                            widget.index,
                        onChanged: (value) {
                          selectOptionAction();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Visibility(
          visible:
              widget.index == 3 &&
              returnSalesProviderContext(
                    context,
                  ).currentCart().paymentMethod ==
                  3 &&
              !returnSalesProviderContext(
                context,
              ).isBalanceSufficient(),
          child: Container(
            padding: EdgeInsetsGeometry.only(
              top: 10,
              bottom: 10,
              left: 10,
              right: 10,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(5),
                bottomRight: Radius.circular(5),
              ),
              color: Colors.grey.shade100,
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.shade300,
                ),
                left: BorderSide(
                  color: Colors.grey.shade300,
                ),
                right: BorderSide(
                  color: Colors.grey.shade300,
                ),
              ),
            ),
            child: Column(
              spacing: 10,
              children: [
                Row(
                  children: [
                    Text(
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b3.fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                      'Insufficient Balance. Top Up;',
                    ),
                  ],
                ),
                Row(
                  spacing: 5,
                  children: [
                    Expanded(
                      child: SizedBox(
                        child: MoneyTextfield(
                          title: 'title',
                          hint: 'Enter Amount',
                          controller: topUpController,
                          theme: theme,
                          autoFocus: true,
                          onSubmitted: (p0) async {
                            if (returnSalesProvider()
                                    .currentCart()
                                    .getCustomer() !=
                                null) {
                              await topUpAction(
                                popSecondContext: false,
                                context: context,
                                theme: theme,
                                moneyTextField:
                                    topUpController,
                                customer:
                                    returnSalesProvider()
                                        .currentCart()
                                        .getCustomer()!,
                              );
                              widget.action != null
                                  ? widget.action!()
                                  : {};
                            }
                          },
                          showTitle: false,
                        ),
                      ),
                    ),
                    Material(
                      type: MaterialType.transparency,
                      child: Ink(
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(3),
                          gradient:
                              theme
                                  .lightModeColor
                                  .prGradient,
                          border: Border.all(
                            color: Colors.grey,
                          ),
                        ),
                        child: InkWell(
                          mouseCursor:
                              SystemMouseCursors.click,
                          onTap: () async {
                            if (returnSalesProvider()
                                    .currentCart()
                                    .getCustomer() !=
                                null) {
                              await topUpAction(
                                popSecondContext: false,
                                context: context,
                                theme: theme,
                                moneyTextField:
                                    topUpController,
                                customer:
                                    returnSalesProvider()
                                        .currentCart()
                                        .getCustomer()!,
                              );
                              widget.action != null
                                  ? widget.action!()
                                  : {};
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 15,
                            ),
                            child: Text(
                              style: TextStyle(
                                fontSize:
                                    theme
                                        .mobileTexts
                                        .b4
                                        .fontSize,
                                fontWeight:
                                    FontWeight.normal,
                                color: Colors.white,
                              ),
                              'Top Up',
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
        ),
      ],
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
    TempCustomersClass? customersClass;
    if (returnSalesProviderContext(
          context,
        ).currentCart().paymentMethod ==
        3) {
      if (returnSalesProviderContext(
            context,
          ).currentCart().selectedCustomer !=
          null) {
        var customerUuid =
            returnSalesProviderContext(
              context,
            ).currentCart().selectedCustomer;
        List<TempCustomersClass> customers =
            returnCustomersSingle().customers
                .where((item) => item.uuid == customerUuid)
                .toList();
        if (customers.isNotEmpty) {
          customersClass = customers.first;
        }
      }
    }
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
                            "${returnSalesProviderContext(context).returnPaymentMethodSalesPage(returnSalesProviderContext(context).currentCart().paymentMethod)['method']}${customersClass != null ? " (${formatMoneyBig(amount: customersClass.getBalance(), context: context)})" : ''}",
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
                    // toggleIsOpen();
                  },
                ),
                PaymentTypeButton(
                  index: 1,
                  action: () {
                    // toggleIsOpen();
                  },
                ),
                Visibility(
                  visible:
                      GeneralSettingsAuthAction()
                              .manageCustomersAccountAndPoints(
                                context: null,
                              ) ==
                          true &&
                      returnShopProvider()
                              .userShop()
                              ?.manageCustomerAccount ==
                          true &&
                      returnSalesProviderContext(context)
                              .currentCart()
                              .selectedCustomer !=
                          null,
                  child: PaymentTypeButton(
                    index: 3,
                    action: () {
                      setState(() {});
                    },
                  ),
                ),
                PaymentTypeButton(
                  index: 2,
                  action: () {
                    // toggleIsOpen();
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
