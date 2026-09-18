import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_orders/orders.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/orders/order_page/components/select_order_items_bottom_sheet.dart';
import 'package:stockall/pages/orders/order_page/deliver_order_items/platforms/components/order_comment_widget.dart';
import 'package:stockall/pages/orders/order_page/deliver_order_items/platforms/components/order_item_delivery_tile.dart';
import 'package:stockall/pages/orders/order_page/deliver_order_items/platforms/components/total_row_orders_delivery.dart';
import 'package:stockall/pages/orders/order_page/deliver_order_items/platforms/deliver_orders_desktop.dart';

class DeliverOrdersMobile extends StatefulWidget {
  final Orders order;
  final TextEditingController searchController;
  final TextEditingController priceController;
  final TextEditingController quantityController;
  final TextEditingController bankController;
  final TextEditingController cashController;

  const DeliverOrdersMobile({
    super.key,
    required this.order,
    required this.searchController,
    required this.priceController,
    required this.quantityController,
    required this.bankController,
    required this.cashController,
  });

  @override
  State<DeliverOrdersMobile> createState() =>
      DeliverOrdersMobileState();
}

class DeliverOrdersMobileState
    extends State<DeliverOrdersMobile> {
  bool isLoading = false;
  bool showSuccess = false;

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            scrolledUnderElevation: 0,
            centerTitle: true,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  style: TextStyle(
                    fontSize: theme.mobileTexts.h4.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                  'Select Items',
                ),
                SizedBox(height: 5),
                Text(
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b2.fontSize,
                  ),
                  'Select Items From Order to Deliver',
                ),
              ],
            ),
            actions: [
              InkWell(
                mouseCursor: SystemMouseCursors.click,
                onTap: () {
                  selectItemsForOrderDeliveryBottomSheet(
                    priceController: widget.priceController,
                    quantityController:
                        widget.quantityController,
                    context: context,
                    action: () {
                      setState(() {});
                    },
                    searchController:
                        widget.searchController,
                    order: widget.order,
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
                              theme.mobileTexts.b3.fontSize,
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
              Stack(
                children: [
                  Column(
                    children: [
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
                                  if (returnOrdersActionProvider(
                                        context: context,
                                      )
                                      .orderListItems
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
                                              'Click on "Add Items" to Start Selecing Items For Delivery',
                                          theme: theme,
                                          height: 25,
                                          icon: Icons.clear,
                                          altAction: () {
                                            selectItemsForOrderDeliveryBottomSheet(
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
                                              order:
                                                  widget
                                                      .order,
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
                                          returnOrdersActionProvider(
                                                context:
                                                    context,
                                              )
                                              .orderItemReversed()
                                              .map(
                                                (
                                                  item,
                                                ) => OrderItemDeliveryTile(
                                                  theme:
                                                      theme,
                                                  item:
                                                      item,
                                                  order:
                                                      widget
                                                          .order,
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
                      Container(
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            bottom: 10.0,
                            top: 10,
                            left: 20,
                            right: 20,
                          ),
                          child: Column(
                            children: [
                              OrderCommentWidget(
                                order: widget.order,
                                bankController:
                                    widget.bankController,
                                cashController:
                                    widget.cashController,
                              ),
                              TotalRowOrdersDelivery(
                                priceController:
                                    widget.priceController,
                              ),
                              MainButtonP(
                                themeProvider: theme,
                                action: () {
                                  checkFields(
                                    bankController:
                                        widget
                                            .bankController,
                                    cashController:
                                        widget
                                            .cashController,
                                    context: context,
                                    order: widget.order,
                                    toggleLoading: () {
                                      setState(() {
                                        isLoading = true;
                                      });
                                    },
                                  );
                                },
                                text: 'Create Delivery',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),

        Visibility(
          visible: isLoading,
          child: returnCompProvider(
            context,
            listen: false,
          ).showLoader(message: 'Creating Delivery'),
        ),
        Visibility(
          visible: showSuccess,
          child: returnCompProvider(
            context,
            listen: false,
          ).showSuccess('Delivery Created Successfully'),
        ),
      ],
    );
  }
}
