import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_customers/temp_customers_class.dart';
import 'package:stockall/components/buttons/floating_action_butto.dart';
import 'package:stockall/components/major/empty_widget_display.dart';
import 'package:stockall/components/text_fields/general_textfield_only.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/refresh_functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/customers/add_customer/add_customer.dart';
import 'package:stockall/pages/customers/components/customer_main_tile.dart';
import 'package:stockall/pages/customers/customer_details_page/customer_details.dart';
import 'package:stockall/pages/customers/customer_settings/customer_settings_page.dart';

class CustomerListMobile extends StatefulWidget {
  final TextEditingController searchController;
  final bool? isSales;
  final bool? isWaybill;
  const CustomerListMobile({
    super.key,
    required this.searchController,
    this.isSales,
    this.isWaybill,
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      returnData().showFloatingActionButton();
    });
  }

  TextEditingController searchController =
      TextEditingController();

  Future<void> getCustomerList(BuildContext context) async {
    await RefreshFunctions(
      context,
    ).refreshCustomers(context);
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Scaffold(
      floatingActionButton: Visibility(
        visible: authorization(
          authorized: Authorizations().addCustomer,
        ),
        child: FloatingActionButtonMain(
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
              setState(() {});
            });
          },
          color:
              returnTheme(
                context,
              ).lightModeColor.prColor300,
          text: 'Add Customer',
        ),
      ),
      appBar: AppBar(
        toolbarHeight: 60,
        leading: IconButton(
          mouseCursor: SystemMouseCursors.click,
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Padding(
            padding: const EdgeInsets.only(
              left: 10.0,
              right: 0,
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
              widget.isSales == null &&
                      widget.isWaybill == null
                  ? 'Your Customers'
                  : 'Select Customer',
            ),
          ],
        ),
        actions: [
          Visibility(
            visible:
                widget.isSales == null &&
                widget.isWaybill == null,
            child: Padding(
              padding: EdgeInsets.only(right: 15),
              child: InkWell(
                mouseCursor: SystemMouseCursors.click,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return CustomerSettingsPage();
                      },
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 10,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Icon(size: 22, Icons.settings),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(
          bottom: 30.0,
          left: 10,
        ),
        child: Builder(
          builder: (context) {
            var customers =
                returnCustomers(context).customersMain();
            if (customers.isEmpty) {
              return EmptyWidgetDisplay(
                title: 'Empty Customer List',
                subText:
                    'You Have not Created Any Customer.',
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
                    setState(() {});
                  });
                },
                altAction: () async {
                  await returnCustomers(
                    context,
                    listen: false,
                  ).fetchCustomers(shopId());
                },
                altActionText: 'Refresh',
                altIcon: Icons.refresh,
              );
            } else {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15.0,
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
                        setState(() {});
                      },
                    ),
                    SizedBox(height: 15),
                    Expanded(
                      child: Builder(
                        builder: (context) {
                          List<TempCustomersClass>
                          customersMain =
                              customers
                                  .where(
                                    (customer) => customer
                                        .name
                                        .toLowerCase()
                                        .contains(
                                          widget
                                              .searchController
                                              .text
                                              .toLowerCase(),
                                        ),
                                  )
                                  .toList();
                          if (customersMain.isNotEmpty) {
                            return ListView.builder(
                              itemCount:
                                  customersMain.length,
                              itemBuilder: (
                                context,
                                index,
                              ) {
                                TempCustomersClass
                                customer =
                                    customersMain[index];

                                return CustomersMainTile(
                                  action: () {
                                    if (widget.isSales !=
                                        null) {
                                      returnCustomers(
                                        context,
                                        listen: false,
                                      ).selectCustomer(
                                        id: customer.uuid!,
                                        name: customer.name,
                                        context: context,
                                      );
                                      Navigator.of(
                                        context,
                                      ).pop(context);
                                    } else if (widget
                                            .isWaybill !=
                                        null) {
                                      Navigator.of(
                                        context,
                                      ).pop(context);
                                    } else {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (
                                            context,
                                          ) {
                                            return CustomerDetails(
                                              customerUuid:
                                                  customer
                                                      .uuid!,
                                            );
                                          },
                                        ),
                                      );
                                    }
                                  },
                                  theme: theme,
                                  customer: customer,
                                  isSales:
                                      widget.isSales ??
                                      widget.isWaybill,
                                );
                              },
                            );
                          } else {
                            return Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
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
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
