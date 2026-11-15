import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_purchase/purchase_list_item/purchase_list_item.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/purchases/create_purchase/components/select_product_purchase.dart';

class PurchaseCartListItemWidget extends StatelessWidget {
  final TextEditingController quantityController;
  final TextEditingController priceController;
  final PurchaseListItem item;
  const PurchaseCartListItemWidget({
    super.key,
    required this.item,
    required this.quantityController,
    required this.priceController,
  });

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Container(
      margin: EdgeInsets.symmetric(vertical: 3),
      color: Colors.grey.shade100,
      padding: EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 20,
      ),
      child: Row(
        spacing: 5,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 5,
            children: [
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                spacing: 5,
                children: [
                  Text(
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.b1.fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                    item.itemName,
                  ),
                ],
              ),
              Row(
                spacing: 10,
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.b3.fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                    '${formatLargeNumberDouble(item.quantity)} ${returnPurchaseActionProvider().itemUnit(purchaseItem: item)}',
                  ),
                  Text(
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.b2.fontSize,
                      color: Colors.grey,
                    ),
                    '|',
                  ),
                  Text(
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.b3.fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                    formatMoneyBig(
                      amount: item.getPrice(),
                      context: context,
                    ),
                  ),
                ],
              ),
              if (item.supplierName != null ||
                  (item.trackingNumber != null &&
                      item.trackingNumber!.isNotEmpty))
                Wrap(
                  spacing: 8,
                  runSpacing: 2,
                  children: [
                    if (item.supplierName != null)
                      Text(
                        'Supplier: ${item.supplierName}',
                        style: TextStyle(
                          fontSize:
                              theme.mobileTexts.b4.fontSize,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    if (item.trackingNumber != null &&
                        item.trackingNumber!.isNotEmpty)
                      Text(
                        'Tracking: ${item.trackingNumber}',
                        style: TextStyle(
                          fontSize:
                              theme.mobileTexts.b4.fontSize,
                          color: Colors.grey.shade700,
                        ),
                      ),
                  ],
                ),
            ],
          ),
          Row(
            spacing: 5,
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  mouseCursor: SystemMouseCursors.click,
                  onTap: () {
                    selectProductPurchase(
                      isEdit: true,
                      closeAction: () {},
                      priceController: priceController,
                      quantityController:
                          quantityController,
                      context: context,
                      purchaseItem: item,
                    );
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      size: 20,
                      color: Colors.grey.shade700,
                      Icons.mode_edit_outlined,
                    ),
                  ),
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  mouseCursor: SystemMouseCursors.click,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (confirmContext) {
                        return ConfirmationAlert(
                          theme: theme,
                          message:
                              'You are about to remove this item from purchase list. Are you sure you want to proceed?',
                          title: 'Remove From List',
                          action: () {
                            returnPurchaseActionProvider()
                                .addItemToList(item: item);
                            Navigator.of(context).pop();
                          },
                        );
                      },
                    );
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(size: 20, Icons.clear),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
