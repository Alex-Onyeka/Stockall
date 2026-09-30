import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/classes/temp_purchase/purchase_list_item/purchase_list_item.dart';
import 'package:stockall/classes/temp_storage_product/temp_storage_products.dart';
import 'package:stockall/components/text_fields/general_textfield_only.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/purchases/create_purchase/components/select_product_purchase.dart';

void selectProductsForPurchaseBottomSheet({
  required BuildContext context,
  Function()? action,
  required TextEditingController searchController,
  required TextEditingController priceController,
  required TextEditingController quantityController,
}) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(20),
      ),
    ),
    backgroundColor: Colors.white,
    builder: (BuildContext context) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.95,
        maxChildSize: 0.95,
        minChildSize: 0.3,
        builder: (context, scrollController) {
          List<TempProductClass> products = [];
          List<TempStorageProducts> storageProducts = [];
          if (returnShopProvider()
                  .userShop()
                  ?.manageInventoryStorage !=
              true) {
            products =
                returnData(
                  context: context,
                ).productListMain.where((item) {
                  if (returnPurchaseActionProvider()
                      .purchaseListItems
                      .where(
                        (purch) =>
                            purch.itemUuid == item.uuid,
                      )
                      .isEmpty) {
                    return true;
                  } else {
                    return false;
                  }
                }).toList();
            products.sort(
              (a, b) => a.name.toLowerCase().compareTo(
                b.name.toLowerCase(),
              ),
            );
          } else {
            storageProducts =
                returnStorageProductProvider()
                    .storageProductListMain
                    .where((item) {
                      if (returnPurchaseActionProvider()
                          .purchaseListItems
                          .where(
                            (purch) =>
                                purch.storageItemUuid ==
                                item.uuid,
                          )
                          .isEmpty) {
                        return true;
                      } else {
                        return false;
                      }
                    })
                    .toList();

            storageProducts.sort(
              (a, b) => a.name.toLowerCase().compareTo(
                b.name.toLowerCase(),
              ),
            );
          }

          return StatefulBuilder(
            builder:
                (context, setState) => Container(
                  padding: const EdgeInsets.fromLTRB(
                    30,
                    15,
                    30,
                    45,
                  ),
                  child: Column(
                    children: [
                      Center(
                        child: Container(
                          height: 4,
                          width: 70,
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(5),
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Select Items',
                              style: TextStyle(
                                fontSize:
                                    returnTheme(context)
                                        .mobileTexts
                                        .b1
                                        .fontSize,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(
                            child: SizedBox(
                              height: 30,
                              width: 200,
                              child: GeneralTextfieldOnly(
                                onChanged: (value) {
                                  setState(() {});
                                },
                                hint: 'Search Name',
                                controller:
                                    searchController,
                                lines: 1,
                                theme: returnTheme(
                                  context,
                                  listen: false,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  mouseCursor:
                                      SystemMouseCursors
                                          .click,
                                  onPressed: () {
                                    Navigator.of(
                                      context,
                                    ).pop();
                                    FocusScope.of(
                                      context,
                                    ).unfocus();
                                  },
                                  icon: Icon(Icons.check),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.grey.shade300,
                            ),
                          ),
                          child: ListView(
                            controller: scrollController,
                            children:
                                returnShopProvider()
                                            .userShop()
                                            ?.manageInventoryStorage ==
                                        true
                                    ? storageProducts
                                        .where(
                                          (prod) => prod
                                              .name
                                              .toLowerCase()
                                              .contains(
                                                searchController
                                                    .text
                                                    .toLowerCase(),
                                              ),
                                        )
                                        .map(
                                          (
                                            pro,
                                          ) => Container(
                                            decoration: BoxDecoration(
                                              border: Border(
                                                top: BorderSide(
                                                  color:
                                                      Colors
                                                          .grey
                                                          .shade300,
                                                ),
                                              ),
                                            ),
                                            child: Material(
                                              color:
                                                  Colors
                                                      .white,
                                              child: ListTile(
                                                title: Text(
                                                  style: TextStyle(
                                                    fontSize:
                                                        returnTheme(
                                                          context,
                                                          listen:
                                                              false,
                                                        ).mobileTexts.b2.fontSize,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                  ),
                                                  pro.name,
                                                ),
                                                onTap: () {
                                                  selectProductPurchase(
                                                    // storageProduct:
                                                    //     pro,
                                                    isEdit:
                                                        false,
                                                    purchaseItem: PurchaseListItem(
                                                      itemName:
                                                          pro.name,
                                                      itemUuid:
                                                          null,
                                                      totalPrice:
                                                          null,
                                                      quantity:
                                                          0,
                                                      unit:
                                                          pro.unit,
                                                      customPrice:
                                                          null,
                                                      originalPrice:
                                                          pro.costPrice,
                                                      storageItemUuid:
                                                          pro.uuid,
                                                      isGroup:
                                                          pro.useGroupUnit ??
                                                          false,
                                                      qttyPerGroup:
                                                          pro.qttyPerGroup,
                                                      unitsList:
                                                          pro.getUnitListFinal(),
                                                      unitUuid:
                                                          pro.getPrimaryUnit().uuid,
                                                    ),
                                                    closeAction:
                                                        () {},
                                                    priceController:
                                                        priceController,
                                                    quantityController:
                                                        quantityController,
                                                    context:
                                                        context,
                                                  );
                                                },
                                                trailing: Icon(
                                                  size: 18,
                                                  Icons.add,
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList()
                                    : products
                                        .where(
                                          (prod) => prod
                                              .name
                                              .toLowerCase()
                                              .contains(
                                                searchController
                                                    .text
                                                    .toLowerCase(),
                                              ),
                                        )
                                        .map(
                                          (
                                            pro,
                                          ) => Container(
                                            decoration: BoxDecoration(
                                              border: Border(
                                                top: BorderSide(
                                                  color:
                                                      Colors
                                                          .grey
                                                          .shade300,
                                                ),
                                              ),
                                            ),
                                            child: Material(
                                              color:
                                                  Colors
                                                      .white,
                                              child: ListTile(
                                                title: Text(
                                                  style: TextStyle(
                                                    fontSize:
                                                        returnTheme(
                                                          context,
                                                          listen:
                                                              false,
                                                        ).mobileTexts.b2.fontSize,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                  ),
                                                  pro.name,
                                                ),
                                                onTap: () {
                                                  selectProductPurchase(
                                                    // product:
                                                    //     pro,
                                                    isEdit:
                                                        false,
                                                    purchaseItem: PurchaseListItem(
                                                      itemName:
                                                          pro.name,
                                                      itemUuid:
                                                          null,
                                                      totalPrice:
                                                          null,
                                                      quantity:
                                                          0,
                                                      unit:
                                                          pro.unit,
                                                      customPrice:
                                                          null,
                                                      originalPrice:
                                                          pro.costPrice,
                                                      storageItemUuid:
                                                          pro.uuid,
                                                      isGroup:
                                                          pro.useGroupUnit ??
                                                          false,
                                                      qttyPerGroup:
                                                          pro.qttyPerGroup,
                                                      unitsList:
                                                          pro.getUnitListFinal(),
                                                      unitUuid:
                                                          pro.getPrimaryUnit().uuid,
                                                    ),
                                                    closeAction:
                                                        () {},
                                                    priceController:
                                                        priceController,
                                                    quantityController:
                                                        quantityController,
                                                    context:
                                                        context,
                                                  );
                                                },
                                                trailing: Icon(
                                                  size: 18,
                                                  Icons.add,
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
          );
        },
      );
    },
  ).then((_) {
    searchController.clear();
  });
  action!();
}
