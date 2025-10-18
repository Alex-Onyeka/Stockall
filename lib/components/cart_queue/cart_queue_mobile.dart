import 'package:flutter/material.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/main.dart';

class CartQueueMobile extends StatelessWidget {
  const CartQueueMobile({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Container(
      height: 40,
      padding: EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 5,
      ),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount:
                  returnSalesProvider(
                    context,
                  ).cartQueue.length,
              itemBuilder: (context, index) {
                var salesP = returnSalesProvider(context);
                return Padding(
                  padding: const EdgeInsets.only(
                    right: 8.0,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: Ink(
                      decoration: BoxDecoration(
                        color:
                            salesP.cartIndex == index &&
                                    salesP
                                            .cartQueue
                                            .length >
                                        1
                                ? Colors.grey.shade100
                                : const Color.fromARGB(
                                  167,
                                  250,
                                  250,
                                  250,
                                ),
                        borderRadius: BorderRadius.circular(
                          3,
                        ),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(
                          3,
                        ),
                        onTap: () {
                          returnSalesProvider(
                            context,
                            listen: false,
                          ).selectCart(index);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal:
                                salesP.cartIndex == index &&
                                        salesP
                                                .cartQueue
                                                .length >
                                            1
                                    ? 8
                                    : 12,
                            vertical: 5,
                          ),

                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            // spacing:
                            //     10,
                            mainAxisAlignment:
                                salesP.cartIndex == index &&
                                        salesP
                                                .cartQueue
                                                .length >
                                            1
                                    ? MainAxisAlignment
                                        .spaceBetween
                                    : MainAxisAlignment
                                        .center,
                            children: [
                              Text(
                                style: TextStyle(
                                  fontSize:
                                      theme
                                          .mobileTexts
                                          .b4
                                          .fontSize,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                                'Cart ${index + 1}',
                              ),
                              Visibility(
                                visible:
                                    salesP.cartIndex ==
                                        index &&
                                    salesP
                                            .cartQueue
                                            .length >
                                        1,
                                child: SizedBox(width: 10),
                              ),
                              Visibility(
                                visible:
                                    salesP.cartIndex ==
                                        index &&
                                    salesP
                                            .cartQueue
                                            .length >
                                        1,
                                child: Material(
                                  color: Colors.transparent,
                                  child: Ink(
                                    decoration: BoxDecoration(
                                      shape:
                                          BoxShape.circle,
                                      color:
                                          theme
                                              .lightModeColor
                                              .secColor200,
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (
                                            context,
                                          ) {
                                            return ConfirmationAlert(
                                              theme: theme,
                                              message:
                                                  'You are about to Delete Entier Cart from the Queue, This action can not be reversed are you sure you want to proceed?',
                                              title:
                                                  'Are you sure?',
                                              action: () {
                                                returnSalesProvider(
                                                  context,
                                                  listen:
                                                      false,
                                                ).deleteCart(
                                                  index,
                                                );
                                                Navigator.of(
                                                  context,
                                                ).pop();
                                              },
                                            );
                                          },
                                        );
                                      },
                                      child: Container(
                                        padding:
                                            EdgeInsets.all(
                                              2,
                                            ),
                                        decoration:
                                            BoxDecoration(
                                              shape:
                                                  BoxShape
                                                      .circle,
                                            ),
                                        child: Icon(
                                          color:
                                              Colors.white,
                                          size: 11,
                                          Icons.clear,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(width: 10),
          Visibility(
            visible:
                returnSalesProvider(
                  context,
                ).cartQueue.length <=
                4,
            child: Material(
              color: Colors.transparent,
              child: Ink(
                decoration: BoxDecoration(
                  color: theme.lightModeColor.prColor300,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: InkWell(
                  onTap: () {
                    returnSalesProvider(
                      context,
                      listen: false,
                    ).addNewCart();
                  },
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        5,
                      ),
                    ),
                    child: Icon(
                      color: Colors.white,
                      size: 15,
                      Icons.add,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
