import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_customers/temp_customers_class.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/customers/add_customer/add_customer.dart';
import 'package:stockall/pages/invoices/invoice_page/invoice_page_desktop.dart';
import 'package:stockall/providers/theme_provider.dart';

class CustomerDetailsSectionWidget extends StatelessWidget {
  final TempCustomersClass customer;
  const CustomerDetailsSectionWidget({
    super.key,
    required this.customer,
  });

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Container(
      margin: EdgeInsets.only(top: 10),
      padding: EdgeInsets.symmetric(
        vertical: 25,
        horizontal: 15,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(26, 0, 0, 0),
            blurRadius: 10,
          ),
        ],
        color: Colors.white,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Row(
                spacing: 5,
                children: [
                  Container(
                    padding: EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.shade100,
                    ),
                    child: Icon(
                      size: 16,
                      Icons.people_outline_sharp,
                    ),
                  ),
                  Text(
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.b4.fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                    'Customer Details'.toUpperCase(),
                  ),
                ],
              ),
              ActionButtonSmall(
                isLoading: false,
                action: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return AddCustomer(
                          customer: customer,
                        );
                      },
                    ),
                  );
                },
                text: 'Edit',
                textColor: Colors.grey.shade500,
                icon: Icon(
                  size: 16,
                  color: Colors.grey.shade500,
                  Icons.edit,
                ),
              ),
            ],
          ),
          Divider(color: Colors.grey.shade300, height: 25),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                spacing: 15,
                children: [
                  Row(
                    spacing: 5,
                    children: [
                      Expanded(
                        flex: 3,
                        child: CustomerDetailsColumnSection(
                          theme: theme,
                          title: 'Name',
                          text: customer.name,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: CustomerDetailsColumnSection(
                          theme: theme,
                          title: 'Created',
                          text: formatDateTime(
                            customer.dateAdded,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    spacing: 5,
                    children: [
                      Expanded(
                        flex: 3,
                        child: CustomerDetailsColumnSection(
                          theme: theme,
                          title: 'Email',
                          text:
                              customer.email.isEmpty
                                  ? 'Not Set'
                                  : customer.email,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: CustomerDetailsColumnSection(
                          theme: theme,
                          title: 'Phone',
                          text: customer.phone,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    spacing: 5,
                    children: [
                      Expanded(
                        flex: 3,
                        child: CustomerDetailsColumnSection(
                          theme: theme,
                          title: 'Country',
                          text:
                              customer.country ?? 'Not Set',
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: CustomerDetailsColumnSection(
                          theme: theme,
                          title: 'State',
                          text: customer.state ?? 'Not Set',
                        ),
                      ),
                    ],
                  ),
                  Row(
                    spacing: 5,
                    children: [
                      Expanded(
                        flex: 3,
                        child: CustomerDetailsColumnSection(
                          theme: theme,
                          title: 'Address',
                          text:
                              customer.address ?? 'Not Set',
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: CustomerDetailsColumnSection(
                          theme: theme,
                          title: 'City',
                          text: customer.city ?? 'Not Set',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomerDetailsColumnSection extends StatelessWidget {
  const CustomerDetailsColumnSection({
    super.key,
    required this.theme,
    required this.title,
    required this.text,
  });

  final ThemeProvider theme;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 5,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          style: TextStyle(
            fontSize: theme.mobileTexts.b4.fontSize,
            color: theme.lightModeColor.secColor200,
          ),
          '$title:'.toUpperCase(),
        ),
        Row(
          children: [
            Expanded(
              child: Text(
                style: TextStyle(
                  fontSize: theme.mobileTexts.b4.fontSize,
                  fontWeight: FontWeight.bold,
                ),
                text,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
