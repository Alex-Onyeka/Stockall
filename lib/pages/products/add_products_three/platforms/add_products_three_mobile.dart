import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stockitt/classes/temp_product_class.dart';
import 'package:stockitt/components/alert_dialogues/info_alert.dart';
import 'package:stockitt/components/buttons/main_button_p.dart';
import 'package:stockitt/components/progress_bar.dart';
import 'package:stockitt/components/text_fields/main_dropdown.dart';
import 'package:stockitt/components/text_fields/number_textfield.dart';
import 'package:stockitt/constants/bottom_sheet_widgets.dart';
import 'package:stockitt/main.dart';
import 'package:stockitt/providers/comp_provider.dart';

class AddProductsThreeMobile extends StatefulWidget {
  final TextEditingController sizeController;
  final TextEditingController quantityController;

  const AddProductsThreeMobile({
    super.key,
    required this.sizeController,
    required this.quantityController,
  });

  @override
  State<AddProductsThreeMobile> createState() =>
      _AddProductsThreeMobileState();
}

class _AddProductsThreeMobileState
    extends State<AddProductsThreeMobile> {
  //
  //
  bool isOpen = false;
  //
  //
  //
  //
  //
  void checkFields() {
    if (widget.quantityController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          var theme = returnTheme(context);
          return InfoAlert(
            theme: theme,
            message: 'Product Quantity Field Must be set',
            title: 'Empty Input',
          );
        },
      );
    } else {
      returnData(context, listen: false).size =
          widget.sizeController.text;
      returnData(
        context,
        listen: false,
      ).quantity = double.parse(
        widget.quantityController.text.replaceAll(',', ''),
      );
      returnData(context, listen: false).sizeType =
          returnData(context, listen: false).selectedSize ??
          '';
      returnData(context, listen: false).isRefundable =
          returnData(
            context,
            listen: false,
          ).isProductRefundable;

      returnData(context, listen: false).addProduct(
        TempProductClass(
          id: int.parse(
            "${DateTime.now().second} ${DateTime.now().minute}",
          ),
          barcode:
              returnData(context, listen: false).barcode,
          brand: returnData(context, listen: false).brand,
          color: returnData(context, listen: false).color,
          desc: returnData(context, listen: false).desc,
          size: returnData(context, listen: false).size,
          sizeType:
              returnData(context, listen: false).sizeType,
          name: returnData(context, listen: false).name,
          category:
              returnData(context, listen: false).category,
          unit: returnData(context, listen: false).unit,
          isRefundable:
              returnData(
                context,
                listen: false,
              ).isRefundable,
          costPrice:
              returnData(context, listen: false).costPrice,
          sellingPrice:
              returnData(
                context,
                listen: false,
              ).sellingPrice,
          quantity:
              returnData(context, listen: false).quantity,
        ),
      );

      returnData(context, listen: false).clearFields();

      Provider.of<CompProvider>(
        context,
        listen: false,
      ).successAction(() {
        Navigator.popUntil(
          context,
          ModalRoute.withName('/'),
        );
      });
    }
  }

  //
  //
  //
  //
  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return GestureDetector(
      onTap:
          () =>
              FocusManager.instance.primaryFocus?.unfocus(),
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              leading: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Padding(
                  padding: const EdgeInsets.only(
                    left: 20.0,
                    right: 10,
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                  ),
                ),
              ),
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
                    'New Product',
                  ),
                  SizedBox(height: 5),
                  Text(
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.b2.fontSize,
                    ),
                    'Add New Product to you Store',
                  ),
                ],
              ),
            ),
            body: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30.0,
                    ),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 10.0,
                        ),
                        child: Column(
                          children: [
                            ProgressBar(
                              theme: theme,
                              percent: '100%',
                              title: 'Your Progress',
                              calcValue: 0.8,
                              position: 1,
                            ),
                            SizedBox(height: 20),
                            NumberTextfield(
                              theme: theme,
                              hint: 'Enter Product Size',
                              title: 'Size  (Optional)',
                              controller:
                                  widget.sizeController,
                            ),
                            SizedBox(height: 20),
                            NumberTextfield(
                              theme: theme,
                              hint: 'Enter Quantity',
                              title: 'Quantity',
                              controller:
                                  widget.quantityController,
                            ),
                            SizedBox(height: 20),
                            MainDropdown(
                              valueSet:
                                  returnData(
                                    context,
                                  ).unitValueSet,
                              onTap: () {
                                sizeTypeBottomSheet(
                                  context,
                                  () {
                                    // FocusScope.of(
                                    //   context,
                                    // ).unfocus();
                                    setState(() {
                                      isOpen = !isOpen;
                                    });
                                  },
                                );
                                setState(() {
                                  isOpen = !isOpen;
                                });
                              },
                              isOpen: isOpen,
                              title: 'Size Name',
                              hint:
                                  returnData(
                                    context,
                                  ).selectedSize ??
                                  'Select Product Size Name (Optional)',
                              theme: theme,
                            ),
                            SizedBox(height: 20),
                            InkWell(
                              onTap: () {
                                returnData(
                                  context,
                                  listen: false,
                                ).toggleStock();
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment
                                        .spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                    children: [
                                      Text(
                                        style: TextStyle(
                                          fontSize:
                                              theme
                                                  .mobileTexts
                                                  .b1
                                                  .fontSize,
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                        ),
                                        'In-Stock',
                                      ),
                                      Text(
                                        'Track Stock Inventory',
                                      ),
                                    ],
                                  ),
                                  Checkbox(
                                    activeColor:
                                        theme
                                            .lightModeColor
                                            .secColor100,
                                    value:
                                        returnData(
                                          context,
                                        ).inStock,
                                    onChanged: (value) {
                                      returnData(
                                        context,
                                        listen: false,
                                      ).toggleStock();
                                    },
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 30),
                            InkWell(
                              onTap: () {
                                returnData(
                                  context,
                                  listen: false,
                                ).toggleRefundable();
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment
                                        .spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                    children: [
                                      Text(
                                        style: TextStyle(
                                          fontSize:
                                              theme
                                                  .mobileTexts
                                                  .b1
                                                  .fontSize,
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                        ),
                                        'Refundable?',
                                      ),
                                      Text(
                                        'Allow Customers return items',
                                      ),
                                    ],
                                  ),
                                  Checkbox(
                                    activeColor:
                                        theme
                                            .lightModeColor
                                            .secColor100,
                                    value:
                                        returnData(
                                          context,
                                        ).isProductRefundable,
                                    onChanged: (value) {
                                      returnData(
                                        context,
                                        listen: false,
                                      ).toggleRefundable();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      bottom: 30.0,
                      top: 20,
                      left: 30,
                      right: 30,
                    ),
                    child: MainButtonP(
                      themeProvider: theme,
                      action: () {
                        checkFields();
                      },
                      text: 'Complete and Save',
                    ),
                  ),
                ),
              ],
            ),
          ),
          Visibility(
            visible:
                Provider.of<CompProvider>(
                  context,
                ).isLoaderOn,
            child: Provider.of<CompProvider>(
              context,
              listen: false,
            ).showSuccess('Product Added Successfully'),
          ),
        ],
      ),
    );
  }
}
