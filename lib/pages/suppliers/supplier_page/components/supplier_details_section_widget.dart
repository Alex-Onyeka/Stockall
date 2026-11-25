import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_suppliers/suppliers_class.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/invoices/invoice_page/invoice_page_desktop.dart';
import 'package:stockall/pages/suppliers/add_supplier/add_supplier.dart';
import 'package:stockall/providers/theme_provider.dart';

class SupplierDetailsSectionWidget extends StatelessWidget {
  final SuppliersClass supplier;
  const SupplierDetailsSectionWidget({
    super.key,
    required this.supplier,
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
                    'Supplier Details'.toUpperCase(),
                  ),
                ],
              ),
              Visibility(
                visible: authorization(
                  authorized:
                      Authorizations().updateSupplier,
                ),
                child: ActionButtonSmall(
                  isLoading: false,
                  action: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return AddSupplier(
                            supplier: supplier,
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
                        child: SupplierDetailsColumnSection(
                          theme: theme,
                          title: 'Name',
                          text: supplier.name,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: SupplierDetailsColumnSection(
                          theme: theme,
                          title: 'Created',
                          text: formatDateTime(
                            supplier.createdAt,
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
                        child: SupplierDetailsColumnSection(
                          theme: theme,
                          title: 'Email',
                          text:
                              (supplier.email != null &&
                                      supplier.email!
                                          .trim()
                                          .isNotEmpty)
                                  ? supplier.email!
                                  : 'Not Set',
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: SupplierDetailsColumnSection(
                          theme: theme,
                          title: 'Phone',
                          text:
                              (supplier.phone != null &&
                                      supplier.phone!
                                          .trim()
                                          .isNotEmpty)
                                  ? supplier.phone!
                                  : 'Not Set',
                        ),
                      ),
                    ],
                  ),
                  Row(
                    spacing: 5,
                    children: [
                      Expanded(
                        flex: 3,
                        child: SupplierDetailsColumnSection(
                          theme: theme,
                          title: 'Country',
                          text:
                              (supplier.country != null &&
                                      supplier.country!
                                          .trim()
                                          .isNotEmpty)
                                  ? supplier.country!
                                  : 'Not Set',
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: SupplierDetailsColumnSection(
                          theme: theme,
                          title: 'State',
                          text:
                              (supplier.state != null &&
                                      supplier.state!
                                          .trim()
                                          .isNotEmpty)
                                  ? supplier.state!
                                  : 'Not Set',
                        ),
                      ),
                    ],
                  ),
                  Row(
                    spacing: 5,
                    children: [
                      Expanded(
                        flex: 3,
                        child: SupplierDetailsColumnSection(
                          theme: theme,
                          title: 'Address',
                          text:
                              (supplier.address != null &&
                                      supplier.address!
                                          .trim()
                                          .isNotEmpty)
                                  ? supplier.address!
                                  : 'Not Set',
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: SupplierDetailsColumnSection(
                          theme: theme,
                          title: 'City',
                          text:
                              (supplier.city != null &&
                                      supplier.city!
                                          .trim()
                                          .isNotEmpty)
                                  ? supplier.city!
                                  : 'Not Set',
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

class SupplierDetailsColumnSection extends StatelessWidget {
  const SupplierDetailsColumnSection({
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
