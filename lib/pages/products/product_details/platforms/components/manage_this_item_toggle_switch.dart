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
            if (authorization(authorized: Authorizations().updateProduct)) {
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
                        product: widget.product.copyWith(
                          updatedAt: DateTime.now(),
                          isManaged: !widget.product.isManaged,
                          quantity:
                              !widget.product.isManaged &&
                                      widget.product.getActualQuantity() == null
                                  ? 0
                                  : widget.product.quantity,
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
            !ItemsAuthAction().allowStockallToManageItemAction(
              context: context,
            ),
        mainWidget: Container(
          width: 50,
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
