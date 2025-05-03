import 'package:flutter/material.dart';
import 'package:stockitt/components/buttons/main_button_p.dart';
import 'package:stockitt/components/progress_bar.dart';
import 'package:stockitt/components/text_fields/general_textfield.dart';
import 'package:stockitt/components/text_fields/main_dropdown.dart';
import 'package:stockitt/main.dart';

class AddProductsTwoMobile extends StatelessWidget {
  final TextEditingController costController;
  final TextEditingController sellingController;
  final TextEditingController categoryController;

  const AddProductsTwoMobile({
    super.key,
    required this.costController,
    required this.sellingController,
    required this.categoryController,
  });

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
                        percent: '33.3%',
                        title: 'Your Progress',
                        calcValue: 0.3,
                        position: -1,
                      ),
                      SizedBox(height: 20),
                      GeneralTextField(
                        theme: theme,
                        hint:
                            'N - Enter the actual Amount of the Item',
                        lines: 1,
                        title: 'Cost - Price',
                        controller: costController,
                      ),
                      SizedBox(height: 20),
                      GeneralTextField(
                        theme: theme,
                        hint:
                            'N - Enter the Amount you wish to sell this Product',
                        lines: 1,
                        title: 'Selling - Price',
                        controller: sellingController,
                      ),
                      SizedBox(height: 20),
                      MainDropdown(
                        title: 'Category',
                        hint: 'Select Product Category',
                        lines: 1,
                        theme: theme,
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
                text: 'Save and Continue',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
