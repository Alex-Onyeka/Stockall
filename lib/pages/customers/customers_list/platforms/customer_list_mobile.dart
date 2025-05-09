import 'package:flutter/material.dart';
import 'package:stockitt/classes/temp_customers_class.dart';
import 'package:stockitt/components/buttons/floating_action_butto.dart';
import 'package:stockitt/components/major/empty_widget_display.dart';
import 'package:stockitt/components/text_fields/general_textfield_only.dart';
import 'package:stockitt/constants/constants_main.dart';
import 'package:stockitt/main.dart';
import 'package:stockitt/pages/customers/add_customer/add_customer.dart';
import 'package:stockitt/pages/customers/components/customer_main_tile.dart';
import 'package:stockitt/providers/customers_provider.dart';

class CustomerListMobile extends StatefulWidget {
  final TextEditingController searchController;
  final bool? isSales;
  const CustomerListMobile({
    super.key,
    required this.searchController,
    this.isSales,
  });

  @override
  State<CustomerListMobile> createState() =>
      _CustomerListMobileState();
}

class _CustomerListMobileState
    extends State<CustomerListMobile> {
  CustomersProvider customersProvider = CustomersProvider();
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      // ignore: use_build_context_synchronously
      final uiProvider = returnData(context, listen: false);

      if (!uiProvider.isFloatingButtonVisible) {
        uiProvider.showFloatingActionButton();
      } else {
        uiProvider.hideFloatingActionButtonWithDelay();
      }
    });
  }

  String searchResult = '';
  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Scaffold(
      floatingActionButton: FloatingActionButtonMain(
        theme: theme,
        action: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return AddCustomer();
              },
            ),
          );
        },
        color:
            returnTheme(context).lightModeColor.prColor300,
        text: 'Add New Customer',
      ),
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
              widget.isSales == null
                  ? 'Your Customers'
                  : 'Select Customer',
            ),
          ],
        ),
      ),
      body: Builder(
        builder: (context) {
          if (customersProvider.customers.isEmpty) {
            return EmptyWidgetDisplay(
              title: 'Empty Customer List',
              subText:
                  'Your Have not Created Any Customer.',
              buttonText: 'Create Customer',
              svg: productIconSvg,
              theme: theme,
              height: 35,
            );
          } else {
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 30.0,
              ),
              child: Column(
                children: [
                  SizedBox(height: 10),
                  GeneralTextfieldOnly(
                    hint: 'Search Customer Name',
                    controller: widget.searchController,
                    lines: 1,
                    theme: theme,
                    onChanged: (value) {
                      setState(() {
                        searchResult = value;
                      });
                    },
                  ),
                  SizedBox(height: 15),
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        if (searchResult != '') {
                          return Builder(
                            builder: (context) {
                              if (customersProvider
                                  .searchCustomers(
                                    widget
                                        .searchController
                                        .text,
                                  )
                                  .isNotEmpty) {
                                return ListView.builder(
                                  itemCount:
                                      customersProvider
                                          .searchCustomers(
                                            widget
                                                .searchController
                                                .text,
                                          )
                                          .length,
                                  itemBuilder: (
                                    context,
                                    index,
                                  ) {
                                    List<TempCustomersClass>
                                    customers = customersProvider
                                        .searchCustomers(
                                          widget
                                              .searchController
                                              .text,
                                        );
                                    TempCustomersClass
                                    customer =
                                        customers[index];

                                    return CustomersMainTile(
                                      action: () {
                                        if (widget
                                                .isSales !=
                                            null) {
                                          returnCustomers(
                                            context,
                                            listen: false,
                                          ).selectCustomer(
                                            customer.id,
                                          );
                                          Navigator.of(
                                            context,
                                          ).pop(context);
                                        } else {
                                          return;
                                        }
                                      },
                                      theme: theme,
                                      customer: customer,
                                      isSales:
                                          widget.isSales,
                                    );
                                  },
                                );
                              } else {
                                return Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                  children: [
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
                                          'Returned 0 Customers',
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              }
                            },
                          );
                        } else {
                          return ListView.builder(
                            itemCount:
                                customersProvider
                                    .customers
                                    .length,
                            itemBuilder: (context, index) {
                              List<TempCustomersClass>
                              customers =
                                  customersProvider
                                      .getSortedCustomers();
                              TempCustomersClass customer =
                                  customers[index];

                              return CustomersMainTile(
                                action: () {
                                  if (widget.isSales !=
                                      null) {
                                    returnCustomers(
                                      context,
                                      listen: false,
                                    ).selectCustomer(
                                      customer.id,
                                    );
                                    Navigator.of(
                                      context,
                                    ).pop(context);
                                  } else {
                                    return;
                                  }
                                },
                                theme: theme,
                                customer: customer,
                                isSales: widget.isSales,
                              );
                            },
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
