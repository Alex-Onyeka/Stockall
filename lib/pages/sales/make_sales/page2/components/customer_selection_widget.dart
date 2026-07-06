import 'package:flutter/material.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/dialog_template.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/components/buttons/main_button_transparent.dart';
import 'package:stockall/components/text_fields/general_textfield.dart';
import 'package:stockall/constants/subscription/sales_auth.dart';
import 'package:stockall/constants/subscription/subscription_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/customers/customers_list/customer_list.dart';

class CustomerSelectionWidget extends StatefulWidget {
  const CustomerSelectionWidget({super.key});

  @override
  State<CustomerSelectionWidget> createState() =>
      _CustomerSelectionWidgetState();
}

class _CustomerSelectionWidgetState
    extends State<CustomerSelectionWidget> {
  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Builder(
      builder: (context) {
        if (returnSalesProviderContext(
              context,
            ).currentCart().selectedCustomerName ==
            null) {
          return SubWrapper(
            isVisible:
                !SalesAuthAction().addCustomerToSaleAction(
                  context: context,
                ),
            mainWidget: Material(
              color: Colors.transparent,
              child: Ink(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: Colors.grey.shade400,
                    width: 1,
                  ),
                ),
                child: InkWell(
                  onTap: () {
                    SalesAuthAction().addCustomerToSaleAction(
                      context: context,
                      action: () {
                        showDialog(
                          context: context,
                          builder: (customContext) {
                            return DialogTemplate(
                              theme: theme,
                              message:
                                  'Choose Wether to Select A Customer From Your Customer List Or To Create a Temporary Customer Just For this Sale.',
                              title:
                                  'Select Action to Perform',
                              action: () {},
                              showBottomActionButtons:
                                  false,
                              widget: Padding(
                                padding:
                                    const EdgeInsets.symmetric(
                                      horizontal: 15.0,
                                    ),
                                child: Column(
                                  mainAxisSize:
                                      MainAxisSize.min,
                                  spacing: 15,
                                  children: [
                                    Column(
                                      spacing: 10,
                                      children: [
                                        SizedBox(
                                          height: 20,
                                        ),
                                        MainButtonP(
                                          themeProvider:
                                              theme,
                                          action: () {
                                            Navigator.of(
                                              customContext,
                                            ).pop();
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
                                            ).then((_) {
                                              setState(
                                                () {},
                                              );
                                            });
                                          },
                                          text:
                                              'Select Customer',
                                        ),
                                        MainButtonP(
                                          themeProvider:
                                              theme,
                                          action: () {
                                            showDialog(
                                              context:
                                                  context,
                                              builder: (
                                                confirmDialog,
                                              ) {
                                                return CreateTemporaryCustomerWidget();
                                              },
                                            ).then((_) {
                                              setState(
                                                () {},
                                              );
                                            });
                                          },
                                          text:
                                              'Create Temporary Customer',
                                        ),
                                      ],
                                    ),
                                    MainButtonTransparent(
                                      themeProvider: theme,
                                      constraints:
                                          BoxConstraints(),
                                      text: 'Cancel',
                                      action: () {
                                        Navigator.of(
                                          context,
                                        ).pop();
                                      },
                                    ),
                                    SizedBox(height: 20),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                  borderRadius: BorderRadius.circular(5),
                  child: Container(
                    padding: EdgeInsets.only(
                      left: 20,
                      right: 15,
                      bottom: 12,
                      top: 12,
                    ),

                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                          'Select Customer ${returnSalesProviderContext(context).currentCart().isInvoice ? '' : '(Optional)'}',
                        ),
                        Icon(
                          color: Colors.grey,
                          size: 20,
                          Icons.arrow_forward_ios_rounded,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        } else {
          return Container(
            padding: EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey.shade200,
            ),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  spacing: 10,
                  children: [
                    Icon(Icons.person),
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
                          ),
                          'Selected Customer:',
                        ),
                        SizedBox(height: 2),
                        Text(
                          style: TextStyle(
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b1
                                    .fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                          returnSalesProviderContext(
                                    context,
                                  )
                                  .currentCart()
                                  .selectedCustomerName ??
                              '',
                        ),
                      ],
                    ),
                  ],
                ),
                Visibility(
                  visible:
                      (returnSalesProvider()
                                      .currentCart()
                                      .isReceiptEdit &&
                                  returnSalesProvider()
                                          .currentCart()
                                          .invoiceUuidEdit !=
                                      null) ==
                              true
                          ? false
                          : true,
                  child: IconButton(
                    onPressed: () {
                      returnCustomers(
                        context,
                        listen: false,
                      ).clearSelectedCustomer(context);
                      setState(() {});
                    },
                    icon: Icon(Icons.clear),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}

class CreateTemporaryCustomerWidget extends StatefulWidget {
  const CreateTemporaryCustomerWidget({super.key});

  @override
  State<CreateTemporaryCustomerWidget> createState() =>
      _CreateTemporaryCustomerWidgetState();
}

class _CreateTemporaryCustomerWidgetState
    extends State<CreateTemporaryCustomerWidget> {
  bool isLoading = false;
  final nameController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return StatefulBuilder(
      builder: (context, setState) {
        return DialogTemplate(
          theme: theme,
          message: 'Enter Customer Name',
          title: 'Create Temporary Customer',
          action: () async {
            if (!isLoading) {
              if (nameController.text.isEmpty) {
                showDialog(
                  context: context,
                  builder: (context) {
                    return InfoAlert(
                      theme: theme,
                      message:
                          'Customer Name Cannot be empty. Please enter Customer name and try again.',
                      title: 'Customer Name Empty',
                    );
                  },
                );
              } else {
                showDialog(
                  context: context,
                  builder: (mainDialog) {
                    return ConfirmationAlert(
                      theme: theme,
                      message:
                          'Are you sure you want to proceed?',
                      title: 'Proceed with action?',
                      action: () async {
                        Navigator.of(mainDialog).pop();
                        setState(() {
                          isLoading = true;
                        });
                        returnCustomers(
                          context,
                          listen: false,
                        ).selectCustomer(
                          name: nameController.text,
                          context: context,
                        );

                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                    );
                  },
                );
              }
            }
          },
          widget: Stack(
            alignment: AlignmentGeometry.xy(0, 0),
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 500),
                child: Stack(
                  alignment: AlignmentGeometry.xy(0, 0),
                  children: [
                    Container(
                      color: const Color.fromARGB(
                        47,
                        255,
                        255,
                        255,
                      ),
                      height: 120,
                      width: 500,
                      child: Center(
                        child: Padding(
                          padding:
                              const EdgeInsets.symmetric(
                                horizontal: 30.0,
                              ),
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            spacing: 10,
                            children: [
                              GeneralTextField(
                                title: 'Customer Name *',
                                hint: 'Enter Name',
                                controller: nameController,
                                lines: 1,
                                theme: theme,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: isLoading,
                      child: Container(
                        height: 120,
                        width: 300,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(
                            61,
                            255,
                            255,
                            255,
                          ),
                        ),
                        child: Center(
                          child:
                              CircularProgressIndicator(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
