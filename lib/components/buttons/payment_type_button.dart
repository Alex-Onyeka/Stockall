import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_customers/temp_customers_class.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/subscription/general_settings_auth.dart';
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
    TempCustomersClass? customersClass;
    if (index == 3) {
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
      if (returnSalesProvider().currentCart().isInvoice &&
          (index == 2 || index == 3)) {
        return;
      } else if (index == 3 &&
          !returnSalesProvider().isBalanceSufficient()) {
        showDialog(
          context: context,
          builder: (erroContext) {
            return InfoAlert(
              theme: theme,
              message:
                  'This Customers Balance is not enough to make this Purchase. Please Select Another Payment Method and Proceed.',
              title: 'Insufficient Balance',
            );
          },
        );
        return;
      } else {
        returnSalesProvider().changeMethod(
          index: index,
          context: context,
        );
        action != null ? action!() : {};
      }
    }

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
                        "${returnSalesProviderContext(context).returnPaymentMethodSalesPage(index)['method']}${customersClass != null ? " (${formatMoneyBig(amount: customersClass.getBalance(), context: context)})" : ''}",
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
                      selectOptionAction();
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
                    toggleIsOpen();
                  },
                ),
                PaymentTypeButton(
                  index: 1,
                  action: () {
                    toggleIsOpen();
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
                  child: PaymentTypeButton(index: 3),
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
