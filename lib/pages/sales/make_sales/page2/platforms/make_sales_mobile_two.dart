import 'package:flutter/material.dart';
import 'package:stockitt/components/buttons/main_button_p.dart';
import 'package:stockitt/components/buttons/payment_type_button.dart';
import 'package:stockitt/components/text_fields/edit_cart_text_field.dart';
import 'package:stockitt/components/text_fields/general_textfield.dart';
import 'package:stockitt/constants/calculations.dart';
import 'package:stockitt/main.dart';

class MakeSalesMobileTwo extends StatelessWidget {
  final TextEditingController searchController;
  final TextEditingController cashController;
  final TextEditingController bankController;
  final TextEditingController customerController;
  const MakeSalesMobileTwo({
    super.key,
    required this.searchController,
    required this.bankController,
    required this.cashController,
    required this.customerController,
  });

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Padding(
            padding: const EdgeInsets.only(
              left: 20.0,
              right: 10,
            ),
            child: Icon(Icons.arrow_back_ios_new_rounded),
          ),
        ),
        centerTitle: true,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              style: TextStyle(
                fontSize: theme.mobileTexts.h4.fontSize,
                fontWeight: FontWeight.bold,
              ),
              'Select Payment Method',
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20.0,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    GeneralTextField(
                      title: 'Add Customer (Optional)',
                      controller: bankController,
                      hint: 'Enter Customer Name',
                      lines: 1,
                      theme: theme,
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Text(
                          style: TextStyle(
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b1
                                    .fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                          'Select Payment Method',
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    PaymentTypeButton(index: 0),
                    PaymentTypeButton(index: 1),
                    PaymentTypeButton(index: 2),
                    SizedBox(height: 20),
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
                              MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: EditCartTextField(
                                title: 'Cash',
                                hint: 'Cash Amount',
                                controller: cashController,
                                theme: theme,
                              ),
                            ),
                            Expanded(
                              child: EditCartTextField(
                                title: 'Bank',
                                hint: 'Bank Amount',
                                controller: bankController,
                                theme: theme,
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
            Material(
              color: Colors.white,
              child: Column(
                children: [
                  Visibility(
                    visible:
                        returnSalesProvider(
                          context,
                        ).cartItems.isNotEmpty,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: 15),
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
                                  // fontWeight: FontWeight.bold,
                                ),
                                'Subtotal',
                              ),
                              Text(
                                style: TextStyle(
                                  fontSize:
                                      theme
                                          .mobileTexts
                                          .b1
                                          .fontSize,
                                  // fontWeight: FontWeight.bold,
                                ),
                                'N${formatLargeNumberDouble(returnSalesProvider(context).calcTotalMain(returnSalesProvider(context).cartItems))}',
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
                                  // fontWeight: FontWeight.bold,
                                ),
                                'Discount',
                              ),
                              Text(
                                style: TextStyle(
                                  fontSize:
                                      theme
                                          .mobileTexts
                                          .b1
                                          .fontSize,
                                  // fontWeight: FontWeight.bold,
                                ),
                                '- N${formatLargeNumberDouble(returnSalesProvider(context).calcDiscountMain(returnSalesProvider(context).cartItems))}',
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
                                          .h4
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
                                          .h4
                                          .fontSize,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                                'N${formatLargeNumberDouble(returnSalesProvider(context).calcFinalTotalMain(returnSalesProvider(context).cartItems))}',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Visibility(
                    visible:
                        returnSalesProvider(
                          context,
                        ).cartItems.isNotEmpty,
                    child: MainButtonP(
                      themeProvider: theme,
                      action: () {},
                      text: 'Check Out',
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
