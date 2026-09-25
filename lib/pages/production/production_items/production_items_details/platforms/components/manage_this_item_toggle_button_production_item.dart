import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_items/production_item.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/subscription/items_auth.dart';
import 'package:stockall/constants/subscription/subscription_func.dart';
import 'package:stockall/main.dart';

class ManageThisItemToggleButtonProductionItem
    extends StatelessWidget {
  final ProductionItem productionItem;
  final Function() setStateAction;
  const ManageThisItemToggleButtonProductionItem({
    super.key,
    required this.productionItem,
    required this.setStateAction,
  });

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context, listen: false);
    return InkWell(
      mouseCursor: SystemMouseCursors.click,
      onTap: () {
        ItemsAuthAction().allowStockallToManageItemAction(
          context: context,
          action: () async {
            if (authorization(
              authorized:
                  Authorizations().updateProductionItems,
            )) {
              var productionItemProvider =
                  returnProductionItemsProvider();
              showDialog(
                context: context,
                builder: (confirmDialog) {
                  return ConfirmationAlert(
                    theme: theme,
                    message:
                        productionItem.isManaged
                            ? 'This item quantity will no longer be automatically managed by Stockall, are you sure you want to proceed?'
                            : 'This item quantity will now be automatically managed by Stockall, are you sure you want to proceed?',
                    title: 'Proceed with Action?',
                    action: () async {
                      Navigator.of(confirmDialog).pop();
                      // setState(() {
                      //   isLoading = true;
                      // });
                      await productionItemProvider
                          .updateProductionItem(
                            productionItemHistory: null,
                            includeQuantity: false,
                            isIncrement: null,
                            isQuantityUpdate: false,
                            quantityChange: null,
                            productionItem: ProductionItem(
                              unitsList:
                                  productionItem.unitsList,
                              useGroupUnit:
                                  productionItem
                                      .useGroupUnit,
                              categories:
                                  productionItem.categories,
                              departmentName:
                                  productionItem
                                      .departmentName,
                              departmentUuid:
                                  productionItem
                                      .departmentUuid,
                              groupUnit:
                                  productionItem.groupUnit,
                              qttyPerGroup:
                                  productionItem
                                      .qttyPerGroup,
                              updatedAt: DateTime.now(),
                              isManaged:
                                  productionItem.isManaged
                                      ? false
                                      : true,
                              name: productionItem.name,
                              unit: productionItem.unit,
                              costPrice:
                                  productionItem.costPrice,
                              quantity:
                                  !productionItem
                                              .isManaged &&
                                          productionItem
                                                  .quantity ==
                                              null
                                      ? 0
                                      : productionItem
                                          .quantity,
                              shopId: productionItem.shopId,
                              barcode:
                                  productionItem.barcode,
                              // categoryUuid:
                              //     productionItem.categoryUuid,
                              createdAt:
                                  productionItem.createdAt,
                              expiryDate:
                                  productionItem.expiryDate,
                              sizeType:
                                  productionItem.sizeType,
                              uuid: productionItem.uuid,
                            ),
                            oldProductionItem:
                                productionItem,
                          );
                      setStateAction();
                    },
                  );
                },
              );
            }
          },
        );
      },
      child: SubWrapper(
        isVisible:
            !ItemsAuthAction()
                .allowStockallToManageItemAction(
                  context: context,
                ),
        mainWidget: Container(
          width: 50,
          padding: EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color:
                  productionItem.isManaged
                      ? theme.lightModeColor.prColor250
                      : Colors.grey,
            ),
            color:
                productionItem.isManaged
                    ? theme.lightModeColor.prColor250
                    : Colors.grey.shade200,
          ),
          child: Row(
            mainAxisAlignment:
                productionItem.isManaged
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      productionItem.isManaged
                          ? Colors.white
                          : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
