import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/classes/temp_product_class/unsynced/quantity_update/quantity_update.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/local_database/products/unsync_funcs/quantity_update/quantity_update_func.dart';
import 'package:stockall/main.dart';

class QuantityUpdatesDesktop extends StatefulWidget {
  final String? productUuid;
  const QuantityUpdatesDesktop({
    super.key,
    this.productUuid,
  });

  @override
  State<QuantityUpdatesDesktop> createState() =>
      _QuantityUpdatesDesktopState();
}

class _QuantityUpdatesDesktopState
    extends State<QuantityUpdatesDesktop> {
  late Future<TempProductClass> productFuture;

  bool isLoading = false;
  bool showSuccess = false;
  bool setDate = false;

  TextEditingController searchController =
      TextEditingController();

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context, listen: false);
    List<QuantityUpdate>? quantityUpdates =
        QuantityUpdateFunc()
            .getQuantitiesUpdate()
            .where(
              (update) =>
                  widget.productUuid != null
                      ? (update.productUuid ==
                          widget.productUuid)
                      : true,
            )
            .toList();
    // if (quantityUpdates.isEmpty) {
    //   return Scaffold(
    //     body: Center(
    //       child: Column(
    //         mainAxisSize: MainAxisSize.min,
    //         children: [
    //           Text('No Update Found'),
    //           MaterialButton(
    //             onPressed: () {
    //               Navigator.of(context).pop();
    //             },
    //             child: Text('Go Back'),
    //           ),
    //         ],
    //       ),
    //     ),
    //   );
    // } else {
    return Scaffold(
      key: _scaffoldKey,
      body: Row(
        spacing: 15,
        children: [
          Container(
            width:
                screenWidth(context) < tabletScreenSmall
                    ? 50
                    : (screenWidth(context) >
                            tabletScreenSmall &&
                        screenWidth(context) <
                            tabletScreen + 100)
                    ? 100
                    : 230,
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 15),
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(
                      39,
                      4,
                      1,
                      41,
                    ),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Scaffold(
                    appBar: appBar(
                      context: context,
                      title: 'Item Details',
                      widget: Visibility(
                        visible: !isStoreKeeper(),
                        child: InkWell(
                          onTap: () {
                            var safeContext = context;
                            showDialog(
                              context: safeContext,
                              builder: (context) {
                                return ConfirmationAlert(
                                  theme: theme,
                                  message:
                                      'This item is going to be added to your cart. Are you sure you want to proceed with this action?',
                                  title: 'Add Item to Cart',
                                  action: () async {
                                    Navigator.of(
                                      safeContext,
                                    ).pop();
                                  },
                                );
                              },
                            );
                          },
                          child: Container(
                            margin: EdgeInsets.only(
                              right: 5,
                            ),
                            padding: EdgeInsets.only(
                              right: 15,
                              left: 15,
                              top: 5,
                              bottom: 5,
                            ),
                            decoration: BoxDecoration(),
                            child: Row(
                              spacing: 3,
                              children: [
                                Text(
                                  style: TextStyle(
                                    fontWeight:
                                        FontWeight.bold,
                                    fontSize:
                                        theme
                                            .mobileTexts
                                            .b2
                                            .fontSize,
                                  ),
                                  'Add to Cart',
                                ),
                                Icon(
                                  size: 17,
                                  Icons
                                      .shopping_cart_outlined,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    body: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15.0,
                      ),
                      child: Builder(
                        builder: (context) {
                          if (quantityUpdates.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisSize:
                                    MainAxisSize.min,
                                children: [
                                  Text('No Update Found'),
                                  MaterialButton(
                                    onPressed: () {
                                      Navigator.of(
                                        context,
                                      ).pop();
                                    },
                                    child: Text('Go Back'),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            return Column(
                              children:
                                  quantityUpdates
                                      .map(
                                        (item) => Container(
                                          margin:
                                              EdgeInsets.symmetric(
                                                vertical: 5,
                                              ),
                                          padding:
                                              EdgeInsets.symmetric(
                                                vertical:
                                                    10,
                                                horizontal:
                                                    15,
                                              ),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(
                                                  5,
                                                ),
                                            border: Border.all(
                                              color:
                                                  Colors
                                                      .grey
                                                      .shade200,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Text(
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
                                                "${item.productUuid} | ${item.quantity} | ${item.isIncrement}",
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                      .toList(),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                  Visibility(
                    visible: isLoading,
                    child: returnCompProvider(
                      context,
                      listen: false,
                    ).showLoader(message: 'Updating'),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width:
                screenWidth(context) < tabletScreenSmall
                    ? 50
                    : (screenWidth(context) >
                            tabletScreenSmall &&
                        screenWidth(context) <
                            tabletScreen + 100)
                    ? 100
                    : 230,
          ),
        ],
      ),
    );
  }
}

// }
