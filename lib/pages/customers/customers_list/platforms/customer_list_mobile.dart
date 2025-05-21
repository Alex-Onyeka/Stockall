import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stockitt/classes/temp_customers_class.dart';
import 'package:stockitt/components/buttons/floating_action_butto.dart';
import 'package:stockitt/components/major/empty_widget_display.dart';
import 'package:stockitt/components/major/empty_widget_display_only.dart';
import 'package:stockitt/components/text_fields/general_textfield_only.dart';
import 'package:stockitt/constants/constants_main.dart';
import 'package:stockitt/main.dart';
import 'package:stockitt/pages/customers/add_customer/add_customer.dart';
import 'package:stockitt/pages/customers/components/customer_main_tile.dart';
import 'package:stockitt/pages/customers/customer_page/customer_page.dart';

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
  @override
  void initState() {
    super.initState();
    _customersFuture = getCustomerList(context);
    returnData(
      context,
      listen: false,
    ).showFloatingActionButton();
  }

  String searchResult = '';

  late Future<List<TempCustomersClass>> _customersFuture;

  TextEditingController searchController =
      TextEditingController();

  Future<List<TempCustomersClass>> getCustomerList(
    BuildContext context,
  ) async {
    return await returnCustomers(
      context,
      listen: false,
    ).fetchCustomers(
      returnShopProvider(
        context,
        listen: false,
      ).userShop!.shopId!,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _customersFuture = getCustomerList(context);
  }

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
          ).then((_) {
            setState(() {
              _customersFuture = getCustomerList(context);
            });
          });
        },
        color:
            returnTheme(context).lightModeColor.prColor300,
        text: 'Add Customer',
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
      body: FutureBuilder(
        future: _customersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30.0,
                  ),
                  child: GeneralTextfieldOnly(
                    hint: 'Search Customer Name',
                    controller: TextEditingController(),
                    lines: 1,
                    theme: theme,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      return Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.white,
                        child: Container(
                          height: 70,
                          margin: EdgeInsets.symmetric(
                            vertical: 5,
                            horizontal: 30,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius:
                                BorderRadius.circular(10),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return EmptyWidgetDisplayOnly(
              title: 'An Error Occured',
              subText:
                  'Check you internet connection and Try again',
              theme: theme,
              height: 35,
            );
          } else {
            return Padding(
              padding: const EdgeInsets.only(
                bottom: 30.0,
                left: 10,
              ),
              child: Builder(
                builder: (context) {
                  var customers = snapshot.data!;
                  if (customers.isEmpty) {
                    return EmptyWidgetDisplay(
                      title: 'Empty Customer List',
                      subText:
                          'Your Have not Created Any Customer.',
                      buttonText: 'Create Customer',
                      svg: custBookIconSvg,
                      theme: theme,
                      height: 30,
                      action: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return AddCustomer();
                            },
                          ),
                        ).then((_) {
                          setState(() {
                            _customersFuture =
                                getCustomerList(context);
                          });
                        });
                      },
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
                            controller:
                                widget.searchController,
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
                                      if (customers
                                          .where(
                                            (
                                              customer,
                                            ) => customer
                                                .name
                                                .toLowerCase()
                                                .contains(
                                                  widget
                                                      .searchController
                                                      .text
                                                      .toLowerCase(),
                                                ),
                                          )
                                          .isNotEmpty) {
                                        return ListView.builder(
                                          itemCount:
                                              customers
                                                  .where(
                                                    (
                                                      customer,
                                                    ) => customer
                                                        .name
                                                        .toLowerCase()
                                                        .contains(
                                                          widget.searchController.text.toLowerCase(),
                                                        ),
                                                  )
                                                  .length,
                                          itemBuilder: (
                                            context,
                                            index,
                                          ) {
                                            TempCustomersClass
                                            customer =
                                                customers
                                                    .where(
                                                      (
                                                        customer,
                                                      ) => customer
                                                          .name
                                                          .toLowerCase()
                                                          .contains(
                                                            widget.searchController.text.toLowerCase(),
                                                          ),
                                                    )
                                                    .toList()[index];

                                            return CustomersMainTile(
                                              action: () {
                                                if (widget
                                                        .isSales !=
                                                    null) {
                                                  returnCustomers(
                                                    context,
                                                    listen:
                                                        false,
                                                  ).selectCustomer(
                                                    customer
                                                        .id!,
                                                  );
                                                  Navigator.of(
                                                    context,
                                                  ).pop(
                                                    context,
                                                  );
                                                } else {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (
                                                        context,
                                                      ) {
                                                        return CustomerPage(
                                                          customer:
                                                              customer,
                                                        );
                                                      },
                                                    ),
                                                  );
                                                }
                                              },
                                              theme: theme,
                                              customer:
                                                  customer,
                                              isSales:
                                                  widget
                                                      .isSales,
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
                                                        theme.mobileTexts.b1.fontSize,
                                                    fontWeight:
                                                        FontWeight.bold,
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
                                        customers.length,
                                    itemBuilder: (
                                      context,
                                      index,
                                    ) {
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
                                              customer.id!,
                                            );
                                            Navigator.of(
                                              context,
                                            ).pop(context);
                                          } else {
                                            returnCompProvider(
                                              context,
                                              listen: false,
                                            ).swtichTab(0);
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (
                                                  context,
                                                ) {
                                                  return CustomerPage(
                                                    customer:
                                                        customer,
                                                  );
                                                },
                                              ),
                                            ).then((_) {
                                              setState(() {
                                                _customersFuture =
                                                    getCustomerList(
                                                      context,
                                                    );
                                              });
                                            });
                                          }
                                        },
                                        theme: theme,
                                        customer: customer,
                                        isSales:
                                            widget.isSales,
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
        },
      ),
    );
  }
}
