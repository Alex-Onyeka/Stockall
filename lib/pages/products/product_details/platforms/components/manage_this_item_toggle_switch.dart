import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/subscription/items_auth.dart';
import 'package:stockall/constants/subscription/subscription_func.dart';
import 'package:stockall/main.dart';

class ManageThisItemToggleSwitch extends StatefulWidget {
  final TempProductClass product;
  final Function() setStateAction;
  const ManageThisItemToggleSwitch({
    super.key,
    required this.product,
    required this.setStateAction,
  });

  @override
  State<ManageThisItemToggleSwitch> createState() =>
      _ManageThisItemToggleSwitchState();
}

class _ManageThisItemToggleSwitchState
    extends State<ManageThisItemToggleSwitch> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return InkWell(
      mouseCursor: SystemMouseCursors.click,
      onTap: () {
        ItemsAuthAction().allowStockallToManageItemAction(
          context: context,
          action: () async {
            if (authorization(
              authorized: Authorizations().updateProduct,
            )) {
              var dataProvider = returnData();
              showDialog(
                context: context,
                builder: (confirmDialog) {
                  return ConfirmationAlert(
                    theme: theme,
                    message:
                        widget.product.isManaged
                            ? 'This item quantity will no longer be automatically managed by Stockall, are you sure you want to proceed?'
                            : 'This item quantity will now be automatically managed by Stockall, are you sure you want to proceed?',
                    title: 'Proceed with Action?',
                    action: () async {
                      Navigator.of(confirmDialog).pop();
                      setState(() {
                        isLoading = true;
                      });
                      await dataProvider.updateProduct(
                        itemHistory: null,
                        includeQuantity: false,
                        isIncrement: null,
                        isQuantityUpdate: false,
                        quantityChange: null,
                        product: TempProductClass(
                          manageSalesWastage:
                              widget
                                  .product
                                  .manageSalesWastage,
                          heightDimension:
                              widget
                                  .product
                                  .heightDimension,
                          widthDimension:
                              widget.product.widthDimension,
                          quantityType:
                              widget.product.quantityType,
                          pricesList:
                              widget.product.pricesList,
                          unitsList:
                              widget.product.unitsList,
                          categories:
                              widget.product.categories,
                          useGroupUnit:
                              widget.product.useGroupUnit,
                          storageUuid:
                              widget.product.storageUuid,
                          departmentName:
                              widget.product.departmentName,
                          departmentUuid:
                              widget.product.departmentUuid,
                          groupUnit:
                              widget.product.groupUnit,
                          qttyPerGroup:
                              widget.product.qttyPerGroup,
                          updatedAt: DateTime.now(),
                          totalQttyInStorageDouble:
                              widget
                                  .product
                                  .totalQttyInStorageDouble,
                          setCustomPrice:
                              widget.product.setCustomPrice,
                          isManaged:
                              widget.product.isManaged
                                  ? false
                                  : true,
                          // id:
                          //     product.id,
                          name: widget.product.name,
                          unit: widget.product.unit,
                          isRefundable:
                              widget.product.isRefundable,
                          costPrice:
                              widget.product.costPrice,
                          sellingPrice:
                              widget.product.sellingPrice,
                          wholeSalePrice:
                              widget.product.wholeSalePrice,
                          quantity:
                              !widget.product.isManaged &&
                                      widget.product
                                              .getActualQuantity() ==
                                          null
                                  ? 0
                                  : widget.product
                                      .getActualQuantity(),
                          shopId: widget.product.shopId,
                          barcode: widget.product.barcode,
                          // categoryUuid:
                          //     product.categoryUuid,
                          createdAt:
                              widget.product.createdAt,
                          discount: widget.product.discount,
                          endDate: widget.product.endDate,
                          expiryDate:
                              widget.product.expiryDate,
                          lowQtty: widget.product.lowQtty,
                          sizeType: widget.product.sizeType,
                          startDate:
                              widget.product.startDate,
                          uuid: widget.product.uuid,
                        ),
                        oldProduct: widget.product,
                      );
                      widget.setStateAction();
                      setState(() {
                        isLoading = false;
                      });
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
                  widget.product.isManaged
                      ? theme.lightModeColor.prColor250
                      : Colors.grey,
            ),
            color:
                widget.product.isManaged
                    ? theme.lightModeColor.prColor250
                    : Colors.grey.shade200,
          ),
          child: Row(
            mainAxisAlignment:
                widget.product.isManaged
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      widget.product.isManaged
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
