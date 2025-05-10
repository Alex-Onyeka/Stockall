import 'package:flutter/material.dart';
import 'package:stockitt/classes/temp_customers_class.dart';
import 'package:stockitt/providers/theme_provider.dart';

class CustomersMainTile extends StatelessWidget {
  final Function()? action;
  final ThemeProvider theme;
  final TempCustomersClass customer;
  final bool? isSales;
  const CustomersMainTile({
    super.key,
    required this.theme,
    required this.customer,
    required this.isSales,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: InkWell(
            onTap: action,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 15,
              ),
              //
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    spacing: 10,
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius:
                              BorderRadius.circular(5),
                        ),
                        child: Icon(
                          color:
                              theme
                                  .lightModeColor
                                  .prColor300,
                          Icons.person,
                        ),
                      ),
                      Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
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

                            customer.name,
                          ),
                          Text(
                            style: TextStyle(
                              color:
                                  theme
                                      .lightModeColor
                                      .secColor200,
                              fontWeight: FontWeight.normal,
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b2
                                      .fontSize,
                            ),
                            customer.email,
                          ),
                        ],
                      ),
                    ],
                  ),
                  Icon(
                    color: theme.lightModeColor.secColor200,
                    size: 20,
                    isSales != null
                        ? Icons.add
                        : Icons.arrow_forward_ios_rounded,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
