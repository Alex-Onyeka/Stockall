import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_suppliers/suppliers_class.dart';
import 'package:stockall/providers/theme_provider.dart';

class SupplierMainTile extends StatelessWidget {
  final Function()? action;
  final ThemeProvider theme;
  final SuppliersClass supplier;
  final bool? isPurchase;
  const SupplierMainTile({
    super.key,
    required this.theme,
    required this.supplier,
    required this.isPurchase,
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
            mouseCursor: SystemMouseCursors.click,
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
                        height: 40,
                        width: 40,
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.shade100,
                          // borderRadius:
                          //     BorderRadius.circular(5),
                        ),
                        child: Center(
                          child: Text(
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              height: 1,
                              color: Colors.black,
                            ),
                            supplier.name.characters.first
                                .toUpperCase(),
                          ),
                        ),
                        // Icon(
                        //   color:
                        //       theme
                        //           .lightModeColor
                        //           .prColor300,
                        //   Icons.person,
                        // ),
                      ),
                      Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        spacing: 3,
                        children: [
                          Text(
                            style: TextStyle(
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b2
                                      .fontSize,
                              fontWeight: FontWeight.bold,
                            ),

                            supplier.name,
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
                                      .b4
                                      .fontSize,
                            ),
                            supplier.email != null &&
                                    supplier
                                        .email!
                                        .isNotEmpty
                                ? supplier.email!
                                : 'Email Not Set',
                          ),
                        ],
                      ),
                    ],
                  ),
                  Icon(
                    color: theme.lightModeColor.secColor200,
                    size: 20,
                    isPurchase != null
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
