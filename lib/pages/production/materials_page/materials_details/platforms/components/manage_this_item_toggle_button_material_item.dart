import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_production_folder/temp_material_class/material_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/subscription/items_auth.dart';
import 'package:stockall/constants/subscription/subscription_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/theme_provider.dart';

class ManageThisItemToggleButtonMaterialItem extends StatelessWidget {
  final MaterialClass material;
  final ThemeProvider theme;
  final Function() setStataAction;
  const ManageThisItemToggleButtonMaterialItem({
    super.key,
    required this.theme,
    required this.material,
    required this.setStataAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            style: TextStyle(
              fontSize: theme.mobileTexts.b3.fontSize,
              fontWeight: FontWeight.normal,
            ),
            'Manage this Material?',
          ),
          InkWell(
            mouseCursor: SystemMouseCursors.click,
            onTap: () {
              ItemsAuthAction().allowStockallToManageItemAction(
                context: context,
                action: () async {
                  if (authorization(
                    authorized: Authorizations().updateMaterials,
                  )) {
                    var materialsProvider = returnMaterialsProvider();
                    showDialog(
                      context: context,
                      builder: (confirmDialog) {
                        return ConfirmationAlert(
                          theme: theme,
                          message:
                              material.isManaged
                                  ? 'This item quantity will no longer be automatically managed by Stockall, are you sure you want to proceed?'
                                  : 'This item quantity will now be automatically managed by Stockall, are you sure you want to proceed?',
                          title: 'Proceed with Action?',
                          action: () async {
                            Navigator.of(confirmDialog).pop();
                            // setState(() {
                            //   isLoading = true;
                            // });
                            await materialsProvider.updateMaterial(
                              isMultipleUpdate: false,
                              materialsItemHistory: null,
                              includeQuantity: false,
                              isIncrement: null,
                              isQuantityUpdate: false,
                              quantityChange: null,
                              material: MaterialClass(
                                unitsList: material.unitsList,
                                useGroupUnit: material.useGroupUnit,
                                categories: material.categories,
                                departmentName: material.departmentName,
                                departmentUuid: material.departmentUuid,
                                groupUnit: material.groupUnit,
                                qttyPerGroup: material.qttyPerGroup,
                                updatedAt: DateTime.now(),
                                isManaged: material.isManaged ? false : true,
                                name: material.name,
                                unit: material.unit,
                                costPrice: material.costPrice,
                                quantity:
                                    !material.isManaged &&
                                            material.quantity == null
                                        ? 0
                                        : material.quantity,
                                shopId: material.shopId,
                                barcode: material.barcode,
                                // categoryUuid:
                                //     material.categoryUuid,
                                createdAt: material.createdAt,
                                expiryDate: material.expiryDate,
                                lowQtty: (material.lowQtty ?? 10),
                                sizeType: material.sizeType,
                                uuid: material.uuid,
                              ),
                              oldMaterial: material,
                            );
                            setStataAction();
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
                        material.isManaged
                            ? theme.lightModeColor.prColor250
                            : Colors.grey,
                  ),
                  color:
                      material.isManaged
                          ? theme.lightModeColor.prColor250
                          : Colors.grey.shade200,
                ),
                child: Row(
                  mainAxisAlignment:
                      material.isManaged
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            material.isManaged
                                ? Colors.white
                                : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
