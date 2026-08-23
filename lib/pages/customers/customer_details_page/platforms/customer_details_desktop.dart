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
import 'package:stockall/pages/invoices/invoice_page/invoice_page_desktop.dart';
import 'package:stockall/pages/sales/total_sales/total_sales_page.dart';

class CustomerDetailsDesktop extends StatefulWidget {
  final String customerUuid;
  const CustomerDetailsDesktop({
    super.key,
    required this.customerUuid,
  });

  @override
  State<CustomerDetailsDesktop> createState() =>
      _CustomerDetailsDesktopState();
}

class _CustomerDetailsDesktopState
    extends State<CustomerDetailsDesktop> {
  bool isDeleting = false;
  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    TempCustomersClass? customer;
    List<TempCustomersClass> customerList =
        returnCustomers(context).customers
            .where(
              (item) => item.uuid == widget.customerUuid,
            )
            .toList();
    customer =
        customerList.isNotEmpty ? customerList.first : null;

    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 30,
              vertical: 20,
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
              spacing: 10,
              children: [
                Row(
                  spacing: 10,
                  children: [
                    InkWell(
                      mouseCursor: SystemMouseCursors.click,
                      onTap: () {
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(
                        30,
                      ),
                      child: Container(
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          size: 18,
                          color: Colors.grey.shade700,
                          Icons.arrow_back_ios_new_outlined,
                        ),
                      ),
                    ),
                    Text(
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b2.fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                      'Customer Details',
                    ),
                  ],
                ),
                Row(
                  spacing: 5,
                  children: [
                    ActionButtonSmall(
                      isLoading: isDeleting,
                      action: () {
                        if (customer != null &&
                            isDeleting == false) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return TotalSalesPage(
                                  customerUuid:
                                      widget.customerUuid,
                                );
                              },
                            ),
                          );
                        }
                      },
                      text: 'Purchases',
                      textColor: Colors.grey.shade500,
                      icon: Icon(
                        size: 14,
                        color: Colors.grey.shade500,
                        Icons.arrow_forward_ios_rounded,
                      ),
                    ),
                    Visibility(
                      visible:
                          authorization(
                            authorized:
                                Authorizations()
                                    .viewCustomersAccount,
                          ) &&
                          showAccountOrReward(),
                      child: ActionButtonSmall(
                        isLoading: isDeleting,
                        action: () {
                          if (customer != null &&
                              isDeleting == false) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return CustomerTransactionsPage(
                                    customerUuid:
                                        widget.customerUuid,
                                  );
                                },
                              ),
                            );
                          }
                        },
                        text: 'Transactions',
                        textColor: Colors.grey.shade500,
                        icon: Icon(
                          size: 14,
                          color: Colors.grey.shade500,
                          Icons.arrow_forward_ios_rounded,
                        ),
                      ),
                    ),
                    Visibility(
                      visible: authorization(
                        authorized:
                            Authorizations().deleteCustomer,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                          right: 20.0,
                        ),
                        child: ActionButtonSmall(
                          isLoading: isDeleting,
                          action: () {
                            if (customer != null &&
                                isDeleting == false) {
                              showDialog(
                                context: context,
                                builder: (confirmDialog) {
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
                                        isDeleting = true;
                                      });
                                      returnCustomers(
                                        context,
                                        listen: false,
                                      ).deleteCustomerMain(
                                        customer!,
                                      );
                                      await Future.delayed(
                                        Duration(
                                          microseconds: 500,
                                        ),
                                        () {},
                                      );
                                      if (context.mounted) {
                                        Navigator.of(
                                          context,
                                        ).pop();
                                      }
                                      setState(() {
                                        isDeleting = false;
                                      });
                                    },
                                  );
                                },
                              );
                            }
                          },
                          text: 'Delete',
                          textColor: Colors.red.shade300,
                          icon: Icon(
                            size: 16,
                            color: Colors.red.shade300,
                            Icons.delete,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Builder(
              builder: (context) {
                if (customer == null) {
                  return Center(
                    child: returnCompProvider(
                      context,
                    ).showLoader(
                      message: 'Customer Not Found',
                    ),
                  );
                } else {
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal:
                          showAccountOrReward() ? 10.0 : 50,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: 300,
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(
                                    horizontal: 10.0,
                                  ),
                              child: Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  Expanded(
                                    flex: 7,
                                    child:
                                        CustomerDetailsSectionWidget(
                                          customer:
                                              customer,
                                        ),
                                  ),
                                  Visibility(
                                    visible:
                                        authorization(
                                          authorized:
                                              Authorizations()
                                                  .viewCustomersAccount,
                                        ) &&
                                        showAccountOrReward(),
                                    child: Expanded(
                                      flex: 4,
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 10,
                                          ),
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
                                ],
                              ),
                            ),
                          ),
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: 300,
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(
                                    horizontal: 10.0,
                                  ),
                              child: Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
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
                                          SizedBox(
                                            width: 10,
                                          ),
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
                            ),
                          ),
                          SizedBox(height: 30),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  bool showAccountOrReward() {
    return returnShopProvider(
              context: context,
            ).userShop()?.manageCustomerAccount ==
            true ||
        returnShopProvider(
              context: context,
            ).userShop()?.manageCustomerReward ==
            true;
  }
}
