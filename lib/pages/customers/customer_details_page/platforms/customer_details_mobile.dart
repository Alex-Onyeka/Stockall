import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_customers/temp_customers_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/customers/customer_account_transactions_page/customer_transactions_page.dart';
import 'package:stockall/pages/customers/customer_details_page/components/customer_account_details_section_widget.dart';
import 'package:stockall/pages/customers/customer_details_page/components/customer_details_section_widget.dart';
import 'package:stockall/pages/customers/customer_details_page/components/customer_purchases_section.dart';
import 'package:stockall/pages/customers/customer_details_page/components/customer_transactions_section.dart';
import 'package:stockall/pages/sales/total_sales/total_sales_page.dart';

class CustomerDetailsMobile extends StatefulWidget {
  final String customerUuid;
  const CustomerDetailsMobile({
    super.key,
    required this.customerUuid,
  });

  @override
  State<CustomerDetailsMobile> createState() =>
      _CustomerDetailsMobileState();
}

class _CustomerDetailsMobileState
    extends State<CustomerDetailsMobile> {
  bool isDeleting = false;
  bool showAccountOrReward() {
    return returnShopProvider()
                .userShop()
                ?.manageCustomerAccount ==
            true ||
        returnShopProvider()
                .userShop()
                ?.manageCustomerReward ==
            true;
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        var theme = returnTheme(context);
        TempCustomersClass? customer;
        List<TempCustomersClass> customerList =
            returnCustomers(context).customers
                .where(
                  (item) =>
                      item.uuid == widget.customerUuid,
                )
                .toList();
        customer =
            customerList.isNotEmpty
                ? customerList.first
                : null;
        return SafeArea(
          child: Scaffold(
            backgroundColor: const Color.fromARGB(
              255,
              253,
              254,
              255,
            ),
            body: Column(
              spacing: 10,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 15,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey.shade200,
                      ),
                    ),
                    color: Colors.white,
                  ),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    // spacing: 10,
                    children: [
                      Row(
                        spacing: 6,
                        children: [
                          Material(
                            type: MaterialType.transparency,
                            child: InkWell(
                              mouseCursor:
                                  SystemMouseCursors.click,
                              onTap: () {
                                Navigator.pop(context);
                              },
                              borderRadius:
                                  BorderRadius.circular(30),
                              child: Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color:
                                        Colors
                                            .grey
                                            .shade200,
                                    width: 1,
                                  ),
                                ),
                                child: Icon(
                                  size: 16,
                                  color:
                                      Colors.grey.shade700,
                                  Icons
                                      .arrow_back_ios_new_outlined,
                                ),
                              ),
                            ),
                          ),
                          Text(
                            style: TextStyle(
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b3
                                      .fontSize,
                            ),
                            'Customer Details',
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          right: 15.0,
                        ),
                        child: PopupMenuButton(
                          offset: Offset(-20, 30),
                          color: Colors.white,
                          itemBuilder: (context) {
                            return [
                              PopupMenuItem(
                                height: 35,
                                onTap: () {
                                  if (customer != null &&
                                      isDeleting == false) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return TotalSalesPage(
                                            customerUuid:
                                                widget
                                                    .customerUuid,
                                          );
                                        },
                                      ),
                                    );
                                  }
                                },
                                child: Text(
                                  style: TextStyle(
                                    fontSize:
                                        theme
                                            .mobileTexts
                                            .b3
                                            .fontSize,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                  'Purchases',
                                ),
                              ),
                              PopupMenuItem(
                                enabled:
                                    authorization(
                                      authorized:
                                          Authorizations()
                                              .viewCustomersAccount,
                                    ) &&
                                    showAccountOrReward(),
                                height: 35,
                                onTap: () {
                                  if (customer != null &&
                                      isDeleting == false) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return CustomerTransactionsPage(
                                            customerUuid:
                                                widget
                                                    .customerUuid,
                                          );
                                        },
                                      ),
                                    );
                                  }
                                },
                                child: Text(
                                  style: TextStyle(
                                    fontSize:
                                        theme
                                            .mobileTexts
                                            .b3
                                            .fontSize,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                  'Transactions',
                                ),
                              ),
                              PopupMenuItem(
                                enabled: authorization(
                                  authorized:
                                      Authorizations()
                                          .deleteCustomer,
                                ),
                                height: 35,
                                onTap: () {
                                  if (customer != null &&
                                      isDeleting == false) {
                                    showDialog(
                                      context: context,
                                      builder: (
                                        confirmDialog,
                                      ) {
                                        return ConfirmationAlert(
                                          theme: theme,
                                          message:
                                              'You are about to delete this Customer, are you sure you want to proceed?',
                                          title:
                                              'Delete Customer?',
                                          action: () async {
                                            Navigator.of(
                                              confirmDialog,
                                            ).pop();
                                            setState(() {
                                              isDeleting =
                                                  true;
                                            });
                                            returnCustomers(
                                              context,
                                              listen: false,
                                            ).deleteCustomerMain(
                                              customer!,
                                            );
                                            await Future.delayed(
                                              Duration(
                                                microseconds:
                                                    500,
                                              ),
                                              () {},
                                            );
                                            if (context
                                                .mounted) {
                                              Navigator.of(
                                                context,
                                              ).pop();
                                            }
                                            setState(() {
                                              isDeleting =
                                                  false;
                                            });
                                          },
                                        );
                                      },
                                    );
                                  }
                                },
                                child: Text(
                                  style: TextStyle(
                                    fontSize:
                                        theme
                                            .mobileTexts
                                            .b3
                                            .fontSize,
                                    fontWeight:
                                        FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                  'Delete Customer',
                                ),
                              ),
                            ];
                          },
                          child: Icon(
                            Icons.more_vert_rounded,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Builder(
                  builder: (context) {
                    if (customer == null || isDeleting) {
                      return Expanded(
                        child: Center(
                          child: returnCompProvider(
                            context,
                          ).showLoader(
                            message:
                                customer == null
                                    ? 'Customer Not Found'
                                    : isDeleting
                                    ? 'Deleting Customer'
                                    : '',
                          ),
                        ),
                      );
                    } else {
                      return Expanded(
                        child: ListView(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(
                                    horizontal: 15.0,
                                  ),
                              child: Column(
                                spacing: 5,
                                children: [
                                  Visibility(
                                    visible:
                                        authorization(
                                          authorized:
                                              Authorizations()
                                                  .viewCustomersAccount,
                                        ) &&
                                        showAccountOrReward(),
                                    child: SizedBox(
                                      height: 220,
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: CustomerAccountDetailsSectionWidget(
                                              customer:
                                                  customer,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 340,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,
                                      children: [
                                        Expanded(
                                          child:
                                              CustomerDetailsSectionWidget(
                                                customer:
                                                    customer,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child:
                                            CustomerPurchasesSection(
                                              customerUuid:
                                                  customer
                                                      .uuid ??
                                                  '',
                                            ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Visibility(
                                        visible:
                                            authorization(
                                              authorized:
                                                  Authorizations()
                                                      .viewCustomersAccount,
                                            ) &&
                                            showAccountOrReward(),
                                        child: Expanded(
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: CustomerTransactionsSection(
                                                  customerUuid:
                                                      customer
                                                          .uuid ??
                                                      '',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 30),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}

//1036886722 Access Bank
