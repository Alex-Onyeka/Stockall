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
          final bool manageStorage =
              returnShopProvider()
                  .userShop()
                  ?.manageInventoryStorage ==
              true;
          // When manageInventoryStorage is enabled, default to Storage
          // Items, and allow switching between Storage Items and Sales Items.
          bool showStorageItems = manageStorage;

          List<TempProductClass> products =
              returnData(
                  context: context,
                ).productListMain.where((item) {
                  return returnPurchaseActionProvider()
                      .purchaseListItems
                      .where(
                        (purch) =>
                            purch.itemUuid == item.uuid,
                      )
                      .isEmpty;
                }).toList()
                ..sort(
                  (a, b) => a.name.toLowerCase().compareTo(
                    b.name.toLowerCase(),
                  ),
                );

          List<TempStorageProducts> storageProducts =
              manageStorage
                  ? (returnStorageProductProvider()
                      .storageProductListMain
                      .where((item) {
                        return returnPurchaseActionProvider()
                            .purchaseListItems
                            .where(
                              (purch) =>
                                  purch.storageItemUuid ==
                                  item.uuid,
                            )
                            .isEmpty;
                      })
                      .toList()
                    ..sort(
                      (a, b) => a.name
                          .toLowerCase()
                          .compareTo(b.name.toLowerCase()),
                    ))
                  : [];

          return StatefulBuilder(
            builder: (context, setState) {
              final theme = returnTheme(
                context,
                listen: false,
              );
              return Container(
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
                      spacing: 10,
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 36,
                            child: GeneralTextfieldOnly(
                              onChanged: (value) {
                                setState(() {});
                              },
                              hint: 'Search Name',
                              controller: searchController,
                              lines: 1,
                              theme: theme,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (manageStorage)
                              PopupMenuButton<bool>(
                                offset: const Offset(
                                  -20,
                                  35,
                                ),
                                color: Colors.white,
                                onSelected: (val) {
                                  setState(() {
                                    showStorageItems = val;
                                  });
                                },
                                itemBuilder: (context) {
                                  return [
                                    PopupMenuItem<bool>(
                                      value: false,
                                      child: Text(
                                        'Sales Items',
                                        style: TextStyle(
                                          fontSize:
                                              theme
                                                  .mobileTexts
                                                  .b2
                                                  .fontSize,
                                          fontWeight:
                                              !showStorageItems
                                                  ? FontWeight
                                                      .bold
                                                  : null,
                                        ),
                                      ),
                                    ),
                                    PopupMenuItem<bool>(
                                      value: true,
                                      child: Text(
                                        'Storage Items',
                                        style: TextStyle(
                                          fontSize:
                                              theme
                                                  .mobileTexts
                                                  .b2
                                                  .fontSize,
                                          fontWeight:
                                              showStorageItems
                                                  ? FontWeight
                                                      .bold
                                                  : null,
                                        ),
                                      ),
                                    ),
                                  ];
                                },
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 6,
                                      ),
                                  child: Row(
                                    mainAxisSize:
                                        MainAxisSize.min,
                                    spacing: 4,
                                    children: [
                                      Text(
                                        showStorageItems
                                            ? 'Storage'
                                            : 'Sales',
                                        style: TextStyle(
                                          fontSize:
                                              theme
                                                  .mobileTexts
                                                  .b3
                                                  .fontSize,
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                        ),
                                      ),
                                      const Icon(
                                        Icons
                                            .keyboard_arrow_down_rounded,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            IconButton(
                              mouseCursor:
                                  SystemMouseCursors.click,
                              onPressed: () {
                                Navigator.of(context).pop();
                                FocusScope.of(
                                  context,
                                ).unfocus();
                              },
                              icon: const Icon(Icons.clear),
                            ),
                          ],
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
                              showStorageItems
                                  ? storageProducts
                                      .where(
                                        (prod) => prod.name
                                            .toLowerCase()
                                            .contains(
                                              searchController
                                                  .text
                                                  .toLowerCase(),
                                            ),
                                      )
                                      .map(
                                        (pro) => Container(
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
                                                      FontWeight
                                                          .bold,
                                                ),
                                                pro.name,
                                              ),
                                              onTap: () {
                                                final units =
                                                    pro.getUnitListFinal();
                                                final primaryUnitUuid =
                                                    units
                                                        .where(
                                                          (
                                                            u,
                                                          ) =>
                                                              u.isPrimary,
                                                        )
                                                        .firstOrNull
                                                        ?.uuid ??
                                                    units
                                                        .firstOrNull
                                                        ?.uuid ??
                                                    pro
                                                        .getPrimaryUnit()
                                                        .uuid;
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
                                                        false,
                                                    qttyPerGroup:
                                                        pro.qttyPerGroup,
                                                    unitsList:
                                                        units,
                                                    unitUuid:
                                                        primaryUnitUuid,
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
                                        (prod) => prod.name
                                            .toLowerCase()
                                            .contains(
                                              searchController
                                                  .text
                                                  .toLowerCase(),
                                            ),
                                      )
                                      .map(
                                        (pro) => Container(
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
                                                      FontWeight
                                                          .bold,
                                                ),
                                                pro.name,
                                              ),
                                              onTap: () {
                                                final units =
                                                    pro.getUnitListFinal();
                                                final primaryUnitUuid =
                                                    units
                                                        .where(
                                                          (
                                                            u,
                                                          ) =>
                                                              u.isPrimary,
                                                        )
                                                        .firstOrNull
                                                        ?.uuid ??
                                                    units
                                                        .firstOrNull
                                                        ?.uuid ??
                                                    pro
                                                        .getPrimaryUnit()
                                                        .uuid;
                                                selectProductPurchase(
                                                  // product:
                                                  //     pro,
                                                  isEdit:
                                                      false,
                                                  purchaseItem: PurchaseListItem(
                                                    itemName:
                                                        pro.name,
                                                    itemUuid:
                                                        pro.uuid,
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
                                                        null,
                                                    isGroup:
                                                        false,
                                                    qttyPerGroup:
                                                        pro.qttyPerGroup,
                                                    unitsList:
                                                        units,
                                                    unitUuid:
                                                        primaryUnitUuid,
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
              );
            },
          );
        },
      );
    },
  ).then((_) {
    searchController.clear();
  });
  action!();
}
