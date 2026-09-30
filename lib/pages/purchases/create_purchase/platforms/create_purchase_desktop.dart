import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_purchase/temp_purchase.dart';
import 'package:stockall/components/major/desktop_center_container.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/purchases/create_purchase/components/purchase_bottom_total_section.dart';
import 'package:stockall/pages/purchases/create_purchase/components/purchase_cart_list_item_widget.dart';
import 'package:stockall/pages/purchases/create_purchase/components/purchase_select_supplier_widget.dart';
import 'package:stockall/pages/purchases/create_purchase/components/select_products_for_purchase_bottom_sheet.dart';

class CreatePurchaseDesktop extends StatefulWidget {
  final TempPurchase? purchase;
  final TextEditingController searchController;
  final TextEditingController priceController;
  final TextEditingController quantityController;

  const CreatePurchaseDesktop({
    super.key,
    this.purchase,
    required this.searchController,
    required this.priceController,
    required this.quantityController,
  });

  @override
  State<CreatePurchaseDesktop> createState() =>
      _CreatePurchaseDesktopState();
}

class _CreatePurchaseDesktopState
    extends State<CreatePurchaseDesktop> {
  bool isLoading = false;
  bool showSuccess = false;

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Scaffold(
      body: Stack(
        children: [
          DesktopCenterContainer(
            width: 650,
            mainWidget: Scaffold(
              appBar: AppBar(
                scrolledUnderElevation: 0,
                centerTitle: true,
                title: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.h4.fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                      widget.purchase != null
                          ? 'Edit Purchase'
                          : 'New Purchase',
                    ),
                    SizedBox(height: 5),
                    Text(
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b2.fontSize,
                      ),
                      widget.purchase != null
                          ? 'Edit Purchase details'
                          : 'Follow the Process to create new Purchase',
                    ),
                  ],
                ),
                actions: [
                  InkWell(
                    mouseCursor: SystemMouseCursors.click,
                    onTap: () {
                      selectProductsForPurchaseBottomSheet(
                        priceController:
                            widget.priceController,
                        quantityController:
                            widget.quantityController,
                        context: context,
                        action: () {
                          setState(() {});
                        },
                        searchController:
                            widget.searchController,
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        8,
                        8,
                        12,
                        8,
                      ),
                      child: Row(
                        spacing: 5,
                        children: [
                          Text(
                            style: TextStyle(
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b3
                                      .fontSize,
                            ),
                            'Add Item',
                          ),
                          Icon(size: 16, Icons.add),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              body: Stack(
                children: [
                  Column(
                    children: [
                      PurchaseSelectSupplierWidget(),
                      Expanded(
                        child: Padding(
                          padding:
                              const EdgeInsets.symmetric(
                                horizontal: 10.0,
                              ),
                          child: SingleChildScrollView(
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(
                                    top: 10.0,
                                  ),
                              child: Builder(
                                builder: (context) {
                                  if (returnPurchaseActionProvider(
                                        context: context,
                                      )
                                      .purchaseListItems
                                      .isEmpty) {
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(
                                            top: 100.0,
                                          ),
                                      child: Center(
                                        child: EmptyWidgetDisplayOnly(
                                          title:
                                              'No Items Selected',
                                          subText:
                                              'Click on "Add Items" to Start Selecing Items For Purchase',
                                          theme: theme,
                                          height: 25,
                                          icon: Icons.clear,
                                          altAction: () {
                                            selectProductsForPurchaseBottomSheet(
                                              priceController:
                                                  widget
                                                      .priceController,
                                              quantityController:
                                                  widget
                                                      .quantityController,
                                              context:
                                                  context,
                                              action: () {
                                                setState(
                                                  () {},
                                                );
                                              },
                                              searchController:
                                                  widget
                                                      .searchController,
                                            );
                                          },
                                          altActionText:
                                              'Add Item',
                                          altIcon:
                                              Icons.add,
                                        ),
                                      ),
                                    );
                                  } else {
                                    return Column(
                                      children:
                                          returnPurchaseActionProvider(
                                                context:
                                                    context,
                                              )
                                              .purchaseItemReversed()
                                              .map(
                                                (
                                                  item,
                                                ) => PurchaseCartListItemWidget(
                                                  item:
                                                      item,
                                                  priceController:
                                                      widget
                                                          .priceController,
                                                  quantityController:
                                                      widget
                                                          .quantityController,
                                                ),
                                              )
                                              .toList(),
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                      PurchaseBottomTotalSection(
                        toggleIsLoading: (value) {
                          setState(() {
                            isLoading = value;
                          });
                        },
                        showSuccess: (value) {
                          setState(() {
                            showSuccess = value;
                          });
                        },
                        priceController:
                            widget.priceController,
                        purchase: widget.purchase,
                        quantityController:
                            widget.quantityController,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Visibility(
            visible: isLoading,
            child: returnCompProvider(
              context,
              listen: false,
            ).showLoader(
              message:
                  widget.purchase != null
                      ? 'Updating Purchase'
                      : 'Creating Purchase',
            ),
          ),
          Visibility(
            visible: showSuccess,
            child: returnCompProvider(
              context,
              listen: false,
            ).showSuccess(
              widget.purchase != null
                  ? 'Purchase Updated Successfully'
                  : 'Purchase Created Successfully',
            ),
          ),
        ],
      ),
    );
  }
}
