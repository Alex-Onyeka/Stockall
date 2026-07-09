import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/classes/temp_product_class/unsynced/quantity_update/quantity_update.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/local_database/products/unsync_funcs/quantity_update/quantity_update_func.dart';
import 'package:stockall/main.dart';

class QuantityUpdatesMobile extends StatefulWidget {
  final String? productUuid;
  const QuantityUpdatesMobile({
    super.key,
    required this.productUuid,
  });

  @override
  State<QuantityUpdatesMobile> createState() =>
      _QuantityUpdatesMobileState();
}

class _QuantityUpdatesMobileState
    extends State<QuantityUpdatesMobile> {
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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context, listen: false);
    List<QuantityUpdate> quantityUpdates =
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
    if (quantityUpdates.isEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('No Update Found'),
              MaterialButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    } else {
      return Stack(
        children: [
          Scaffold(
            appBar: appBar(
              context: context,
              title: 'Details',
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
                            Navigator.of(safeContext).pop();
                          },
                        );
                      },
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 5),
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
                            fontWeight: FontWeight.bold,
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b2
                                    .fontSize,
                          ),
                          'Sell Item',
                        ),
                        Icon(
                          size: 16,
                          Icons.shopping_cart_outlined,
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
              child: Column(children: [
                ],
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
      );
    }
  }
}
