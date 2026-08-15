import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/constants/subscription/items_auth.dart';
import 'package:stockall/constants/subscription/subscription_func.dart';
import 'package:stockall/main.dart';

class IsManagedToggleWidget extends StatefulWidget {
  final TempProductClass product;
  const IsManagedToggleWidget({
    super.key,
    required this.product,
  });

  @override
  State<IsManagedToggleWidget> createState() =>
      _IsManagedToggleWidgetState();
}

class _IsManagedToggleWidgetState
    extends State<IsManagedToggleWidget> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context, listen: false);
    return InkWell(
      mouseCursor: SystemMouseCursors.click,
      onTap: () {
        ItemsAuthAction().allowStockallToManageItemAction(
          context: context,
          action: () async {
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
                        useGroupUnit:
                            widget.product.useGroupUnit,
                        categories:
                            widget.product.categories,
                        departmentName:
                            widget.product.departmentName,
                        departmentUuid:
                            widget.product.departmentUuid,
                        groupUnit: widget.product.groupUnit,
                        qttyPerGroup:
                            widget.product.qttyPerGroup,
                        updatedAt: DateTime.now(),
                        setCustomPrice:
                            widget.product.setCustomPrice,
                        isManaged:
                            widget.product.isManaged
                                ? false
                                : true,
                        name: widget.product.name,
                        totalQttyInStorageDouble:
                            widget
                                .product
                                .totalQttyInStorageDouble,
                        unit: widget.product.unit,
                        isRefundable:
                            widget.product.isRefundable,
                        costPrice: widget.product.costPrice,
                        sellingPrice:
                            widget.product.sellingPrice,
                        wholeSalePrice:
                            widget.product.wholeSalePrice,
                        quantity:
                            !widget.product.isManaged &&
                                    widget
                                            .product
                                            .quantity ==
                                        null
                                ? 0
                                : widget.product.quantity,
                        shopId: widget.product.shopId,
                        barcode: widget.product.barcode,
                        // categoryUuid:
                        //     widget.product.categoryUuid,
                        createdAt: widget.product.createdAt,
                        discount: widget.product.discount,
                        endDate: widget.product.endDate,
                        expiryDate:
                            widget.product.expiryDate,
                        lowQtty: widget.product.lowQtty,
                        sizeType: widget.product.sizeType,
                        startDate: widget.product.startDate,
                        uuid: widget.product.uuid,
                        storageUuid:
                            widget.product.storageUuid,
                      ),
                      oldProduct: widget.product,
                    );
                    setState(() {
                      isLoading = false;
                    });
                  },
                );
              },
            );
          },
        );
      },
      child: SubWrapper(
        isVisible:
            !ItemsAuthAction()
                .allowStockallToManageItemAction(
                  context: context,
                ),
        mainWidget: Stack(
          children: [
            Visibility(
              visible: !isLoading,
              child: Container(
                width: 38,
                padding: EdgeInsets.symmetric(
                  horizontal: 7,
                  vertical: 3.5,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color:
                        widget.product.isManaged
                            ? theme
                                .lightModeColor
                                .prColor300
                            : Colors.grey,
                  ),
                  color:
                      widget.product.isManaged
                          ? theme.lightModeColor.prColor300
                          : Colors.grey.shade200,
                ),
                child: Row(
                  mainAxisAlignment:
                      widget.product.isManaged
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(4),
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
            Visibility(
              visible: isLoading,
              child: SizedBox(
                height: 15,
                width: 15,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: theme.lightModeColor.secColor200,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
