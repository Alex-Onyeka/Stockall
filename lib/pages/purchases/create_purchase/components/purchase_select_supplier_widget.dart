import 'package:flutter/material.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/suppliers/supplier_list/supplier_list.dart';

class PurchaseSelectSupplierWidget extends StatelessWidget {
  const PurchaseSelectSupplierWidget({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
      child: InkWell(
        mouseCursor: SystemMouseCursors.click,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return SupplierList(isPurchase: true);
              },
            ),
          );
        },
        borderRadius: BorderRadius.circular(5),
        child: Container(
          height: 40,
          padding: EdgeInsets.only(left: 20, right: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: Colors.grey,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Text(
                style: TextStyle(
                  fontSize: theme.mobileTexts.b3.fontSize,
                  fontWeight: FontWeight.bold,
                ),
                returnPurchaseActionProvider(
                      context: context,
                    ).tempSupplier?.name ??
                    'Select Supplier',
              ),
              InkWell(
                mouseCursor: SystemMouseCursors.click,
                onTap: () {
                  if (returnPurchaseActionProvider()
                          .tempSupplier !=
                      null) {
                    returnPurchaseActionProvider()
                        .selectSupplier();
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return SupplierList(
                            isPurchase: true,
                          );
                        },
                      ),
                    );
                  }
                },
                child: Padding(
                  padding: EdgeInsetsGeometry.all(7),
                  child: Icon(
                    size: 18,
                    returnPurchaseActionProvider(
                              context: context,
                            ).tempSupplier ==
                            null
                        ? Icons.arrow_forward_ios_rounded
                        : Icons.clear,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
