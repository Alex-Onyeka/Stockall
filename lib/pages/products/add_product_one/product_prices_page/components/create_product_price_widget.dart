import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_product_class/prices_class/product_prices_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/dialog_template.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/text_fields/edit_cart_text_field.dart';
import 'package:stockall/components/text_fields/general_textfield.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/products/add_product_one/platforms/components/markup_margin_fields.dart';
import 'package:stockall/pages/products/add_product_one/product_prices_page/components/price_type_selection_widget.dart';

class CreateProductPriceWidget extends StatefulWidget {
  final TextEditingController priceController;
  final TextEditingController nameController;
  final String productUuid;
  final double? costPrice;
  final Function() setStateAction;
  const CreateProductPriceWidget({
    super.key,
    required this.productUuid,
    required this.priceController,
    required this.nameController,
    this.costPrice,
    required this.setStateAction,
  });

  @override
  State<CreateProductPriceWidget> createState() =>
      _CreateProductPriceWidgetState();
}

class _CreateProductPriceWidgetState
    extends State<CreateProductPriceWidget> {
  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        mouseCursor: SystemMouseCursors.click,
        onTap: () {
          addProductPriceAction(
            context: context,
            nameController: widget.nameController,
            productUuid: widget.productUuid,
            priceController: widget.priceController,
            costPrice: widget.costPrice,
            setStateAction: widget.setStateAction,
          );
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: 6,
            horizontal: 15,
          ),
          child: Row(
            spacing: 5,
            children: [
              Text(
                style: theme.mobileTexts.b3.textStyleBold,
                "Add Price",
              ),
              Icon(color: Colors.grey, size: 20, Icons.add),
            ],
          ),
        ),
      ),
    );
  }
}

void addProductPriceAction({
  required BuildContext context,
  required TextEditingController priceController,
  required TextEditingController nameController,
  required String productUuid,
  ProductPricesClass? price,
  double? costPrice,
  required Function() setStateAction,
}) {
  var theme = returnTheme(context, listen: false);

  double? resolvedCostPrice = costPrice;
  if (resolvedCostPrice == null || resolvedCostPrice <= 0) {
    try {
      final matches = returnData(
        context: context,
        listen: false,
      ).productListMain.where((p) => p.uuid == productUuid);
      if (matches.isNotEmpty &&
          matches.first.costPrice > 0) {
        resolvedCostPrice = matches.first.costPrice;
      }
    } catch (_) {}
  }

  if (price != null) {
    priceController.text = price.priceValue.toString();
    nameController.text = price.name ?? 'Price';
  }
  // var isFixed = price?.isFixed ?? false;
  int currentSelection = price?.priceType ?? 1;
  void addAction() {
    final priceValue = double.tryParse(
      priceController.text.replaceAll(',', '').trim(),
    );
    if (priceValue == null || !priceValue.isFinite) {
      showDialog(
        context: context,
        builder: (context) {
          return InfoAlert(
            theme: theme,
            message:
                'Price Value Cannot Be Empty. Please enter a Value to Proceed',
            title: 'Invalid Price',
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (mainDialog) {
          return ConfirmationAlert(
            theme: theme,
            message: 'Are you sure you want to proceed?',
            title: 'Proceed with action?',
            action: () async {
              Navigator.of(mainDialog).pop();
              price?.name = nameController.text.trim();
              price?.priceValue = priceValue;
              price?.isFixed =
                  currentSelection == 1 ? false : true;
              price?.priceType = currentSelection;
              var priceListSingle = ProductPricesClass(
                uuid: uuidGen(),
                staffUuid: currentUser().userId!,
                createdAt: DateTime.now(),
                staffName: currentUser().name,
                priceValue: priceValue,
                name:
                    nameController.text.isEmpty
                        ? 'Price'
                        : nameController.text.trim(),
                isPrimary:
                    returnData().tempPricesList.isEmpty
                        ? true
                        : false,
                itemUuid: productUuid,
                isFixed:
                    currentSelection == 1 ? false : true,
                priceType: currentSelection,
              );
              returnData().createOrUpdatePriceList(
                priceListSingle: price ?? priceListSingle,
              );
              Navigator.of(mainDialog).pop();
            },
          );
        },
      );
    }
  }

  showDialog(
    context: context,
    builder: (confirmDialog) {
      return StatefulBuilder(
        builder: (context, setState) {
          return DialogTemplate(
            theme: theme,
            message: 'Enter Product Price Name',
            title:
                '${price == null ? 'Create' : 'Update'} Product Price',
            action: () async {
              addAction();
            },
            widget: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 500),
              child: Container(
                color: const Color.fromARGB(
                  47,
                  255,
                  255,
                  255,
                ),
                // height: 150,
                // width: 500,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30.0,
                    ),
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      spacing: 10,
                      children: [
                        GeneralTextField(
                          title: 'Price Name (Optional)',
                          hint: 'Enter Name',
                          controller: nameController,
                          lines: 1,
                          theme: theme,
                        ),
                        SizedBox(height: 5),
                        PriceTypeSelectionWidget(
                          theme: theme,
                          currentSelection:
                              currentSelection,
                          setPriceType: (index) {
                            setState(() {
                              currentSelection = index ?? 1;
                            });
                          },
                        ),
                        EditCartTextField(
                          title: 'Value',
                          autoFocus: false,
                          hint: 'Enter Value',
                          controller: priceController,
                          theme: theme,
                          onSubmitted: (p0) {
                            addAction();
                          },
                        ),
                        if (resolvedCostPrice != null &&
                            resolvedCostPrice > 0)
                          MarkupMarginFields(
                            sellingPriceController:
                                priceController,
                            fixedCostPrice:
                                resolvedCostPrice,
                            theme: theme,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  ).then((_) {
    priceController.clear();
    nameController.clear();
    setStateAction();
  });
}
