import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/components/buttons/payment_type_button.dart';
import 'package:stockall/components/major/desktop_page_container.dart';
import 'package:stockall/components/my_calculator_desktop.dart';
import 'package:stockall/components/text_fields/edit_cart_text_field.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/customers/customers_list/customer_list.dart';
import 'package:stockall/pages/sales/make_sales/receipt_page/receipt_page.dart';
import 'package:stockall/providers/theme_provider.dart';
import 'package:stockall/services/auth_service.dart';

class MakeSalesDesktopTwo extends StatefulWidget {
  final double totalAmount;
  final TextEditingController searchController;
  final TextEditingController cashController;
  final TextEditingController bankController;
  final TextEditingController customerController;
  const MakeSalesDesktopTwo({
    super.key,
    required this.searchController,
    required this.bankController,
    required this.cashController,
    required this.customerController,
    required this.totalAmount,
  });

  @override
  State<MakeSalesDesktopTwo> createState() =>
      _MakeSalesDesktopTwoState();
}

class _MakeSalesDesktopTwoState
    extends State<MakeSalesDesktopTwo> {
  bool isUpdating = false;
  bool isLoading = false;
  bool showSuccess = false;

  @override
  void initState() {
    super.initState();
    widget.cashController.text =
        widget.totalAmount.toString();

    widget.bankController.text = '0';
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(backGroundImage),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Container(
            color: const Color.fromARGB(201, 255, 255, 255),
          ),
          Center(
            child: Container(
              margin: EdgeInsets.symmetric(
                vertical: 15,
                horizontal: 10,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 15,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(
                      46,
                      0,
                      0,
                      0,
                    ),
                    blurRadius: 10,
                    spreadRadius: 5,
                    offset: Offset(0, 0),
                  ),
                ],
              ),
              child: Scaffold(
                body: Row(
                  children: [
                    Visibility(
                      visible:
                          screenWidth(context) >
                          tabletScreen,
                      child: Expanded(
                        flex: 4,
                        child: MyCalculatorDesktop(),
                      ),
                    ),
                    Visibility(
                      visible:
                          screenWidth(context) >
                          tabletScreen,
                      child: SizedBox(width: 15),
                    ),
                    Expanded(
                      flex: 10,
                      child: DesktopPageContainer(
                        widget: Scaffold(
                          appBar: appBar(
                            context: context,
                            title: 'Select Payment Method',
                          ),
                          body: Padding(
                            padding:
                                const EdgeInsets.symmetric(
                                  horizontal: 10.0,
                                ),
                            child: Column(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .spaceBetween,
                              children: [
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Builder(
                                          builder: (
                                            context,
                                          ) {
                                            if (returnCustomers(
                                                  context,
                                                ).selectedCustomerId ==
                                                null) {
                                              return Material(
                                                color:
                                                    Colors
                                                        .transparent,
                                                child: Ink(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          5,
                                                        ),
                                                    border: Border.all(
                                                      color:
                                                          Colors.grey.shade400,
                                                      width:
                                                          1,
                                                    ),
                                                  ),
                                                  child: InkWell(
                                                    onTap: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (
                                                            context,
                                                          ) {
                                                            return CustomerList(
                                                              isSales:
                                                                  true,
                                                            );
                                                          },
                                                        ),
                                                      );
                                                    },
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          5,
                                                        ),
                                                    child: Container(
                                                      padding: EdgeInsets.only(
                                                        left:
                                                            20,
                                                        right:
                                                            15,
                                                        bottom:
                                                            12,
                                                        top:
                                                            12,
                                                      ),

                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Text(
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.grey,
                                                              fontWeight:
                                                                  FontWeight.bold,
                                                            ),
                                                            'Select Customer (Optional)',
                                                          ),
                                                          Icon(
                                                            color:
                                                                Colors.grey,
                                                            size:
                                                                20,
                                                            Icons.arrow_forward_ios_rounded,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            } else {
                                              return Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal:
                                                      20,
                                                  vertical:
                                                      5,
                                                ),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        10,
                                                      ),
                                                  color:
                                                      Colors
                                                          .grey
                                                          .shade200,
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Row(
                                                      spacing:
                                                          10,
                                                      children: [
                                                        Icon(
                                                          Icons.person,
                                                        ),
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              style: TextStyle(
                                                                fontSize:
                                                                    theme.mobileTexts.b3.fontSize,
                                                              ),
                                                              'Selected Customer:',
                                                            ),
                                                            SizedBox(
                                                              height:
                                                                  2,
                                                            ),
                                                            Text(
                                                              style: TextStyle(
                                                                fontSize:
                                                                    theme.mobileTexts.b1.fontSize,
                                                                fontWeight:
                                                                    FontWeight.bold,
                                                              ),
                                                              returnCustomers(
                                                                    context,
                                                                    listen:
                                                                        false,
                                                                  )
                                                                  .getCustomerByIdMain(
                                                                    returnCustomers(
                                                                          context,
                                                                        ).selectedCustomerId ??
                                                                        '',
                                                                  )!
                                                                  .name,
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    IconButton(
                                                      onPressed: () {
                                                        returnCustomers(
                                                          context,
                                                          listen:
                                                              false,
                                                        ).clearSelectedCustomer();
                                                      },
                                                      icon: Icon(
                                                        Icons.clear,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Divider(
                                          color:
                                              Colors
                                                  .grey
                                                  .shade300,
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              style: TextStyle(
                                                fontSize:
                                                    theme
                                                        .mobileTexts
                                                        .b1
                                                        .fontSize,
                                                fontWeight:
                                                    FontWeight
                                                        .bold,
                                              ),
                                              'Change Sale Type',
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 5),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment
                                                  .spaceBetween,
                                          children: [
                                            Text(
                                              style: TextStyle(
                                                fontSize:
                                                    theme
                                                        .mobileTexts
                                                        .b2
                                                        .fontSize,
                                                fontWeight:
                                                    FontWeight
                                                        .normal,
                                              ),
                                              'Is this Sale On Credit?',
                                            ),
                                            InkWell(
                                              onTap: () {
                                                returnSalesProvider(
                                                  context,
                                                  listen:
                                                      false,
                                                ).switchInvoiceSale();
                                                returnSalesProvider(
                                                  context,
                                                  listen:
                                                      false,
                                                ).changeMethod(
                                                  0,
                                                );
                                              },
                                              child: Container(
                                                width: 50,
                                                padding: EdgeInsets.symmetric(
                                                  horizontal:
                                                      10,
                                                  vertical:
                                                      5,
                                                ),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        20,
                                                      ),
                                                  border: Border.all(
                                                    color:
                                                        returnSalesProvider(
                                                              context,
                                                            ).isInvoice
                                                            ? theme.lightModeColor.prColor250
                                                            : Colors.grey,
                                                  ),
                                                  color:
                                                      returnSalesProvider(
                                                            context,
                                                          ).isInvoice
                                                          ? theme.lightModeColor.prColor250
                                                          : Colors.grey.shade200,
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      returnSalesProvider(
                                                            context,
                                                          ).isInvoice
                                                          ? MainAxisAlignment.end
                                                          : MainAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      padding:
                                                          EdgeInsets.all(
                                                            5,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        shape:
                                                            BoxShape.circle,
                                                        color:
                                                            returnSalesProvider(
                                                                  context,
                                                                ).isInvoice
                                                                ? Colors.white
                                                                : Colors.grey.shade600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Divider(
                                          color:
                                              Colors
                                                  .grey
                                                  .shade300,
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Column(
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  style: TextStyle(
                                                    fontSize:
                                                        theme.mobileTexts.b1.fontSize,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                  ),
                                                  'Select Payment Method',
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            PaymentTypeButton(
                                              index: 0,
                                            ),
                                            PaymentTypeButton(
                                              index: 1,
                                            ),
                                            PaymentTypeButton(
                                              index: 2,
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Visibility(
                                          visible:
                                              returnSalesProvider(
                                                context,
                                              ).currentPayment ==
                                              2,
                                          child: SizedBox(
                                            // width: 300,
                                            // height: 200,
                                            child: Row(
                                              spacing: 10,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .center,
                                              children: [
                                                Expanded(
                                                  child: EditCartTextField(
                                                    title:
                                                        'Cash',
                                                    hint:
                                                        'Cash Amount',
                                                    controller:
                                                        widget.cashController,
                                                    theme:
                                                        theme,
                                                    onChanged: (
                                                      value,
                                                    ) {
                                                      if (isUpdating)
                                                        // ignore: curly_braces_in_flow_control_structures
                                                        return;
                                                      isUpdating =
                                                          true;

                                                      double
                                                      cash =
                                                          double.tryParse(
                                                            value,
                                                          ) ??
                                                          0;
                                                      if (cash >
                                                          widget.totalAmount) {
                                                        showDialog(
                                                          context:
                                                              context,
                                                          builder: (
                                                            context,
                                                          ) {
                                                            var theme = Provider.of<
                                                              ThemeProvider
                                                            >(
                                                              context,
                                                            );
                                                            return InfoAlert(
                                                              theme:
                                                                  theme,
                                                              message:
                                                                  'Cash cannot exceed total amount.',
                                                              title:
                                                                  'Overpayment',
                                                            );
                                                          },
                                                        );
                                                        // Reset to max allowed
                                                        widget.cashController.text = widget.totalAmount.toStringAsFixed(
                                                          2,
                                                        );
                                                        widget.bankController.text =
                                                            '0.00';
                                                      } else {
                                                        double
                                                        bank =
                                                            widget.totalAmount -
                                                            cash;
                                                        widget.bankController.text = bank.toStringAsFixed(
                                                          2,
                                                        );
                                                      }

                                                      isUpdating =
                                                          false;
                                                    },
                                                  ),
                                                ),
                                                Expanded(
                                                  child: EditCartTextField(
                                                    title:
                                                        'Bank',
                                                    hint:
                                                        'Bank Amount',
                                                    controller:
                                                        widget.bankController,
                                                    theme:
                                                        theme,
                                                    onChanged: (
                                                      value,
                                                    ) {
                                                      if (isUpdating)
                                                        // ignore: curly_braces_in_flow_control_structures
                                                        return;
                                                      isUpdating =
                                                          true;

                                                      double
                                                      bank =
                                                          double.tryParse(
                                                            value,
                                                          ) ??
                                                          0;
                                                      if (bank >
                                                          widget.totalAmount) {
                                                        showDialog(
                                                          context:
                                                              context,
                                                          builder: (
                                                            context,
                                                          ) {
                                                            var theme = Provider.of<
                                                              ThemeProvider
                                                            >(
                                                              context,
                                                            );
                                                            return InfoAlert(
                                                              theme:
                                                                  theme,
                                                              message:
                                                                  'Bank cannot exceed total amount.',
                                                              title:
                                                                  'Overpayment',
                                                            );
                                                          },
                                                        );
                                                        widget.bankController.text = widget.totalAmount.toStringAsFixed(
                                                          2,
                                                        );
                                                        widget.cashController.text =
                                                            '0.00';
                                                      } else {
                                                        double
                                                        cash =
                                                            widget.totalAmount -
                                                            bank;
                                                        widget.cashController.text = cash.toStringAsFixed(
                                                          2,
                                                        );
                                                      }

                                                      isUpdating =
                                                          false;
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      flex:
                          screenWidth(context) <
                                  tabletScreen
                              ? 6
                              : 5,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15),
                          ),
                        ),
                        child: Padding(
                          padding:
                              const EdgeInsets.fromLTRB(
                                15,
                                50,
                                15,
                                15,
                              ),
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment.start,
                            children: [
                              SizedBox(height: 50),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment
                                        .spaceBetween,
                                children: [
                                  Text(
                                    style: TextStyle(
                                      fontSize:
                                          theme
                                              .mobileTexts
                                              .b3
                                              .fontSize,
                                    ),
                                    'Subtotal',
                                  ),
                                  Text(
                                    style: TextStyle(
                                      fontSize:
                                          theme
                                              .mobileTexts
                                              .b3
                                              .fontSize,
                                      // fontWeight: FontWeight.bold,
                                    ),
                                    formatMoneyBig(
                                      amount: returnSalesProvider(
                                        context,
                                      ).calcTotalMain(
                                        returnSalesProvider(
                                          context,
                                        ).cartItems,
                                      ),
                                      context: context,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment
                                        .spaceBetween,
                                children: [
                                  Text(
                                    style: TextStyle(
                                      fontSize:
                                          theme
                                              .mobileTexts
                                              .b3
                                              .fontSize,
                                      // fontWeight: FontWeight.bold,
                                    ),
                                    'Discount',
                                  ),
                                  Text(
                                    style: TextStyle(
                                      fontSize:
                                          theme
                                              .mobileTexts
                                              .b3
                                              .fontSize,
                                      // fontWeight: FontWeight.bold,
                                    ),
                                    '- ${formatMoney(returnSalesProvider(context).calcDiscountMain(returnSalesProvider(context).cartItems), context)}',
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment
                                        .spaceBetween,
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
                                    'Total',
                                  ),
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
                                      amount: returnSalesProvider(
                                        context,
                                      ).calcFinalTotalMain(
                                        returnSalesProvider(
                                          context,
                                        ).cartItems,
                                      ),
                                      context: context,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),
                              Visibility(
                                visible:
                                    returnSalesProvider(
                                      context,
                                    ).cartItems.isNotEmpty,
                                child: MainButtonP(
                                  themeProvider: theme,
                                  action: () {
                                    var suggP =
                                        returnSuggestionProvider(
                                          context,
                                          listen: false,
                                        );
                                    BuildContext
                                    safeContext = context;
                                    showDialog(
                                      context: safeContext,
                                      builder: (_) {
                                        return ConfirmationAlert(
                                          theme: theme,
                                          message:
                                              returnSalesProvider(
                                                    context,
                                                    listen:
                                                        false,
                                                  ).isInvoice
                                                  ? 'You are about to record a Sale on Credit, are you sure you want to proceed?'
                                                  : 'You are about to record a Sale, are you sure you want to proceed?',
                                          title:
                                              returnSalesProvider(
                                                    context,
                                                    listen:
                                                        false,
                                                  ).isInvoice
                                                  ? 'Sell on Credit?'
                                                  : 'Are you sure?',
                                          action: () async {
                                            setState(() {
                                              isLoading =
                                                  true;
                                            });
                                            if (safeContext
                                                .mounted) {
                                              Navigator.of(
                                                safeContext,
                                              ).pop();
                                            }
                                            var receipt = await returnSalesProvider(
                                              context,
                                              listen: false,
                                            ).checkoutMain(
                                              context:
                                                  context,
                                              cartItems:
                                                  returnSalesProvider(
                                                    context,
                                                    listen:
                                                        false,
                                                  ).cartItems,
                                              staffId:
                                                  AuthService()
                                                      .currentUser!,
                                              staffName:
                                                  returnUserProvider(
                                                    context,
                                                    listen:
                                                        false,
                                                  ).currentUserMain!.name,
                                              shopId:
                                                  returnShopProvider(
                                                    context,
                                                    listen:
                                                        false,
                                                  ).userShop!.shopId!,
                                              bank:
                                                  returnSalesProvider(
                                                            context,
                                                            listen:
                                                                false,
                                                          ).returnPaymentMethod() ==
                                                          'Split'
                                                      ? double.tryParse(
                                                            widget.bankController.text,
                                                          ) ??
                                                          0
                                                      : returnSalesProvider(
                                                            context,
                                                            listen:
                                                                false,
                                                          ).returnPaymentMethod() ==
                                                          'Bank'
                                                      ? returnSalesProvider(
                                                        context,
                                                        listen:
                                                            false,
                                                      ).calcFinalTotalMain(
                                                        returnSalesProvider(
                                                          context,
                                                          listen:
                                                              false,
                                                        ).cartItems,
                                                      )
                                                      : 0,
                                              cashAlt:
                                                  returnSalesProvider(
                                                                context,
                                                                listen:
                                                                    false,
                                                              )
                                                              .returnPaymentMethod() ==
                                                          'Split'
                                                      ? double.tryParse(
                                                            widget.cashController.text,
                                                          ) ??
                                                          0
                                                      : returnSalesProvider(
                                                            context,
                                                            listen:
                                                                false,
                                                          ).returnPaymentMethod() ==
                                                          'Bank'
                                                      ? 0
                                                      : returnSalesProvider(
                                                        context,
                                                        listen:
                                                            false,
                                                      ).calcFinalTotalMain(
                                                        returnSalesProvider(
                                                          context,
                                                          listen:
                                                              false,
                                                        ).cartItems,
                                                      ),
                                              paymentMethod:
                                                  returnSalesProvider(
                                                    context,
                                                    listen:
                                                        false,
                                                  ).returnPaymentMethod(),
                                              // customerId: int.tryParse(
                                              //   returnCustomers(
                                              //     context,
                                              //     listen:
                                              //         false,
                                              //   ).selectedCustomerId,
                                              // ),
                                              customerUuid:
                                                  returnCustomers(
                                                    context,
                                                    listen:
                                                        false,
                                                  ).selectedCustomerId,

                                              customerName:
                                                  returnCustomers(
                                                    context,
                                                    listen:
                                                        false,
                                                  ).selectedCustomerName,
                                            );

                                            await suggP
                                                .createSuggestions();
                                            suggP
                                                .clearSuggestions();
                                            setState(() {
                                              isLoading =
                                                  false;
                                              showSuccess =
                                                  true;
                                            });

                                            await Future.delayed(
                                              Duration(
                                                seconds: 3,
                                              ),
                                              () {},
                                            );
                                            if (context
                                                .mounted) {
                                              Navigator.pushAndRemoveUntil(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (
                                                    context,
                                                  ) {
                                                    return ReceiptPage(
                                                      receiptUuid:
                                                          receipt.uuid!,
                                                      isMain:
                                                          true,
                                                    );
                                                  },
                                                ),
                                                (route) =>
                                                    false,
                                              );
                                            }
                                            setState(() {
                                              showSuccess =
                                                  false;
                                            });
                                          },
                                        );
                                      },
                                    );
                                  },
                                  text: 'Check Out',
                                ),
                              ),
                              SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Visibility(
            visible: isLoading,
            child: returnCompProvider(
              context,
            ).showLoader(message: 'Loading'),
          ),
          Visibility(
            visible: showSuccess,
            child: returnCompProvider(
              context,
            ).showSuccess('Sales Successful'),
          ),
        ],
      ),
    );
  }
}
