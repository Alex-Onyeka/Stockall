import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_product_class/prices_class/product_prices_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/dialog_template.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/text_fields/edit_cart_text_field.dart';
import 'package:stockall/components/text_fields/general_textfield.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/subscription/items_auth.dart';
import 'package:stockall/main.dart';

class CreateProductPriceWidget extends StatefulWidget {
  final TextEditingController quantityController;
  final TextEditingController nameController;
  final String productUuid;
  final Function() setStateAction;
  const CreateProductPriceWidget({
    super.key,
    required this.productUuid,
    required this.quantityController,
    required this.nameController,
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
            quantityController: widget.quantityController,
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
  required TextEditingController quantityController,
  required TextEditingController nameController,
  required String productUuid,
  ProductPricesClass? price,
  required Function() setStateAction,
}) {
  var theme = returnTheme(context, listen: false);
  if (price != null) {
    quantityController.text = price.priceValue.toString();
    nameController.text = price.name ?? 'Price';
  }

  void addAction() {
    final priceValue = double.tryParse(
      quantityController.text.replaceAll(',', '').trim(),
    );
    if (nameController.text.trim().isEmpty ||
        priceValue == null ||
        !priceValue.isFinite ||
        priceValue <= 0) {
      showDialog(
        context: context,
        builder: (context) {
          return InfoAlert(
            theme: theme,
            message:
                'Enter a price name and a positive priceValue.',
            title: 'Invalid Price Details',
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
              var priceListSingle = ProductPricesClass(
                uuid: uuidGen(),
                staffUuid: currentUser().userId!,
                createdAt: DateTime.now(),
                staffName: currentUser().name,
                priceValue: priceValue,
                name: nameController.text.trim(),
                isPrimary:
                    returnData().tempPricesList.isEmpty
                        ? true
                        : false,
                itemUuid: productUuid,
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

  ItemsAuthAction().applyVariationsAction(
    context: context,
    action: () {
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
                  constraints: BoxConstraints(
                    maxWidth: 500,
                  ),
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
                            Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.end,
                              spacing: 5,
                              children: [
                                Expanded(
                                  child: GeneralTextField(
                                    title:
                                        'Product Price Name *',
                                    hint: 'Enter Name',
                                    controller:
                                        nameController,
                                    lines: 1,
                                    theme: theme,
                                  ),
                                ),
                              ],
                            ),
                            EditCartTextField(
                              title: 'Conversion',
                              autoFocus: false,
                              hint: 'Enter Conversion',
                              controller:
                                  quantityController,
                              theme: theme,
                              onSubmitted: (p0) {
                                addAction();
                              },
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
        quantityController.clear();
        nameController.clear();
        setStateAction();
      });
    },
  );
}
