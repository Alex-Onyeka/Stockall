import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stockitt/classes/temp_customers_class.dart';
import 'package:stockitt/components/major/top_banner.dart';
import 'package:stockitt/constants/constants_main.dart';
import 'package:stockitt/main.dart';

class CustomerPageMobile extends StatelessWidget {
  final TempCustomersClass customer;
  const CustomerPageMobile({
    super.key,
    required this.customer,
  });

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            SizedBox(
              height: 600,
              child: Stack(
                alignment: Alignment(0, 1),
                children: [
                  Align(
                    alignment: Alignment(0, -1),
                    child: TopBanner(
                      subTitle:
                          'Full Details about customer',
                      title: 'Customer Details',
                      theme: theme,
                      bottomSpace: 100,
                      topSpace: 30,
                      iconData: Icons.person,
                    ),
                  ),
                  Positioned(
                    top: 110,
                    child: Container(
                      width:
                          MediaQuery.of(
                            context,
                          ).size.width -
                          40,
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          5,
                        ),
                        color: Colors.white,
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .spaceBetween,
                            children: [
                              Row(
                                spacing: 10,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(
                                      15,
                                    ),
                                    decoration:
                                        BoxDecoration(
                                          shape:
                                              BoxShape
                                                  .circle,
                                          color:
                                              Colors
                                                  .grey
                                                  .shade200,
                                        ),
                                    child: SvgPicture.asset(
                                      customersIconSvg,
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                    children: [
                                      Text(
                                        style: TextStyle(
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                          fontSize:
                                              theme
                                                  .mobileTexts
                                                  .b1
                                                  .fontSize,
                                        ),
                                        customer.name,
                                      ),
                                      Text(
                                        style: TextStyle(
                                          fontWeight:
                                              FontWeight
                                                  .normal,
                                          fontSize:
                                              theme
                                                  .mobileTexts
                                                  .b3
                                                  .fontSize,
                                        ),
                                        customer.email,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Container(
                                padding:
                                    EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(
                                        5,
                                      ),
                                  border: Border.all(
                                    color:
                                        Colors
                                            .grey
                                            .shade300,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    style: TextStyle(
                                      fontWeight:
                                          FontWeight.bold,
                                      fontSize:
                                          theme
                                              .mobileTexts
                                              .b3
                                              .fontSize,
                                      color:
                                          theme
                                              .lightModeColor
                                              .secColor200,
                                    ),
                                    'Customer',
                                  ),
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
            ),
          ],
        ),
      ),
    );
  }
}
