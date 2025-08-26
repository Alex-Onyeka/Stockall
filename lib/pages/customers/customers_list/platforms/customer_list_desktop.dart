import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_customers_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/buttons/floating_action_butto.dart';
import 'package:stockall/components/major/desktop_page_container.dart';
import 'package:stockall/components/major/empty_widget_display.dart';
import 'package:stockall/components/major/my_drawer_widget.dart';
import 'package:stockall/components/major/right_side_bar.dart';
import 'package:stockall/components/text_fields/general_textfield_only.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/customers/add_customer/add_customer.dart';
import 'package:stockall/pages/customers/components/customer_main_tile.dart';
import 'package:stockall/pages/customers/customer_page/customer_page.dart';
import 'package:stockall/services/auth_service.dart';

class CustomerListDesktop extends StatefulWidget {
  final TextEditingController searchController;
  final bool? isSales;
  const CustomerListDesktop({
    super.key,
    required this.searchController,
    this.isSales,
  });

  @override
  State<CustomerListDesktop> createState() =>
      _CustomerListDesktopState();
}

class _CustomerListDesktopState
    extends State<CustomerListDesktop> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      returnData(
        context,
        listen: false,
      ).showFloatingActionButton();
    });
    if (returnCustomers(
      context,
      listen: false,
    ).customersMain.isEmpty) {
      getCustomerList(context);
    }
  }

  String searchResult = '';

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

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Stack(
      children: [
        Row(
          spacing: 15,
          children: [
            MyDrawerWidget(
              action: () {
                var safeContext = context;
                showDialog(
                  context: context,
                  builder: (context) {
                    return ConfirmationAlert(
                      theme: theme,
                      message: 'You are about to Logout',
                      title: 'Are you Sure?',
                      action: () async {
                        Navigator.of(context).pop();
                        setState(() {
                          isLoading = true;
                        });
                        if (safeContext.mounted) {
                          await AuthService().signOut(
                            safeContext,
                          );
                        }
                      },
                    );
                  },
                );
              },
              theme: theme,
              notifications:
                  returnNotificationProvider(
                        context,
                      ).notifications.isEmpty
                      ? []
                      : returnNotificationProvider(
                        context,
                      ).notifications,
            ),
            Expanded(
              child: DesktopPageContainer(
                widget: Scaffold(
                  floatingActionButton:
                      FloatingActionButtonMain(
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
                  appBar: AppBar(
                    toolbarHeight: 60,
                    leading: Opacity(
                      opacity: 0,
                      child: IconButton(
                        onPressed: () {
                          // Navigator.of(context).pop();
                        },
                        icon: Padding(
                          padding: const EdgeInsets.only(
                            left: 10.0,
                            right: 0,
                          ),
                          child: Icon(
                            Icons
                                .arrow_back_ios_new_rounded,
                          ),
                        ),
                      ),
                    ),
                    centerTitle: true,
                    title: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          style: TextStyle(
                            fontSize:
                                theme
                                    .mobileTexts
                                    .h4
                                    .fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                          widget.isSales == null
                              ? 'Your Customers'
                              : 'Select Customer',
                        ),
                      ],
                    ),
                  ),
                  body: Padding(
                    padding: const EdgeInsets.only(
                      bottom: 30.0,
                      left: 10,
                    ),
                    child: Builder(
                      builder: (context) {
                        var customers =
                            returnCustomers(
                              context,
                            ).customersMain;
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
                                setState(() {});
                              });
                            },
                          );
                        } else {
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(
                                  horizontal: 15.0,
                                ),
                            child: Column(
                              children: [
                                SizedBox(height: 10),
                                GeneralTextfieldOnly(
                                  hint:
                                      'Search Customer Name',
                                  controller:
                                      widget
                                          .searchController,
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
                                      if (searchResult !=
                                          '') {
                                        return Builder(
                                          builder: (
                                            context,
                                          ) {
                                            if (customers
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
                                                .isNotEmpty) {
                                              return ListView.builder(
                                                itemCount:
                                                    customers
                                                        .where(
                                                          (
                                                            customer,
                                                          ) => customer.name.toLowerCase().contains(
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
                                                            ) => customer.name.toLowerCase().contains(
                                                              widget.searchController.text.toLowerCase(),
                                                            ),
                                                          )
                                                          .toList()[index];

                                                  return CustomersMainTile(
                                                    action: () {
                                                      if (widget.isSales !=
                                                          null) {
                                                        returnCustomers(
                                                          context,
                                                          listen:
                                                              false,
                                                        ).selectCustomer(
                                                          customer.id!,
                                                          customer.name,
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
                                                                id:
                                                                    customer.id!,
                                                              );
                                                            },
                                                          ),
                                                        );
                                                      }
                                                    },
                                                    theme:
                                                        theme,
                                                    customer:
                                                        customer,
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
                                              customers
                                                  .length,
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
                                                    listen:
                                                        false,
                                                  ).selectCustomer(
                                                    customer
                                                        .id!,
                                                    customer
                                                        .name,
                                                  );
                                                  Navigator.of(
                                                    context,
                                                  ).pop(
                                                    context,
                                                  );
                                                } else {
                                                  returnCompProvider(
                                                    context,
                                                    listen:
                                                        false,
                                                  ).swtichTab(
                                                    0,
                                                  );
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (
                                                        context,
                                                      ) {
                                                        return CustomerPage(
                                                          id:
                                                              customer.id!,
                                                        );
                                                      },
                                                    ),
                                                  ).then((
                                                    _,
                                                  ) {
                                                    setState(
                                                      () {},
                                                    );
                                                  });
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
                ),
              ),
            ),
            RightSideBar(theme: theme),
          ],
        ),
        Visibility(
          visible: isLoading,
          child: returnCompProvider(
            context,
          ).showLoader('Logging Out...'),
        ),
      ],
    );
  }
}
