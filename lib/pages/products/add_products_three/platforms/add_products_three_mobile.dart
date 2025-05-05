import 'package:flutter/material.dart';
import 'package:stockitt/components/buttons/main_button_p.dart';
import 'package:stockitt/components/progress_bar.dart';
import 'package:stockitt/components/text_fields/main_dropdown.dart';
import 'package:stockitt/components/text_fields/number_textfield.dart';
import 'package:stockitt/constants/bottom_sheet_widgets.dart';
import 'package:stockitt/main.dart';

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
  bool isOpen = false;
  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Scaffold(
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
            child: Icon(Icons.arrow_back_ios_new_rounded),
          ),
        ),
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
              'New Product',
            ),
            SizedBox(height: 5),
            Text(
              style: TextStyle(
                fontSize: theme.mobileTexts.b2.fontSize,
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
                  padding: const EdgeInsets.only(top: 10.0),
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
                        controller: widget.sizeController,
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
                          sizeTypeBottomSheet(context, () {
                            setState(() {
                              isOpen = !isOpen;
                            });
                          });
                          setState(() {
                            isOpen = !isOpen;
                          });
                        },
                        isOpen: isOpen,
                        title: 'Size Name',
                        hint:
                            returnData(
                              context,
                            ).selectedUnit ??
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
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  style: TextStyle(
                                    fontSize:
                                        theme
                                            .mobileTexts
                                            .b1
                                            .fontSize,
                                    fontWeight:
                                        FontWeight.bold,
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
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  style: TextStyle(
                                    fontSize:
                                        theme
                                            .mobileTexts
                                            .b1
                                            .fontSize,
                                    fontWeight:
                                        FontWeight.bold,
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
                action: () {},
                text: 'Complete and Save',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
