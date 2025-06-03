import 'package:flutter/material.dart';
import 'package:storrec/main.dart';

class PaymentTypeButton extends StatelessWidget {
  final int index;
  const PaymentTypeButton({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: InkWell(
          onTap:
              () => returnSalesProvider(
                context,
                listen: false,
              ).changeMethod(index),
          child: SizedBox(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                7,
                10,
                7,
              ),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        style: TextStyle(
                          fontSize:
                              theme.mobileTexts.b1.fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                        returnSalesProvider(
                          context,
                        ).paymentMethods[index]['method'],
                      ),
                      Text(
                        style: TextStyle(
                          fontSize:
                              theme.mobileTexts.b3.fontSize,
                          fontWeight: FontWeight.normal,
                          color:
                              theme
                                  .lightModeColor
                                  .secColor200,
                        ),
                        returnSalesProvider(
                          context,
                        ).paymentMethods[index]['subText'],
                      ),
                    ],
                  ),
                  Checkbox(
                    activeColor:
                        theme.lightModeColor.prColor250,
                    shape: CircleBorder(side: BorderSide()),
                    side: BorderSide(
                      width: 1,
                      color:
                          theme.lightModeColor.secColor200,
                    ),
                    value:
                        returnSalesProvider(
                          context,
                        ).currentPayment ==
                        index,
                    onChanged:
                        (value) => returnSalesProvider(
                          context,
                          listen: false,
                        ).changeMethod(index),
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
