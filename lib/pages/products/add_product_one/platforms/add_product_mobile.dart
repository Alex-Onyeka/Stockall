import 'package:flutter/material.dart';
import 'package:stockitt/components/buttons/main_button_p.dart';
import 'package:stockitt/components/progress_bar.dart';
import 'package:stockitt/components/text_fields/general_textfield.dart';
import 'package:stockitt/main.dart';
import 'package:stockitt/pages/products/add_products_two/add_product_two.dart';

class AddProductMobile extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController descController;
  final TextEditingController brandController;

  const AddProductMobile({
    super.key,
    required this.nameController,
    required this.descController,
    required this.brandController,
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
                        percent: '0%',
                        title: 'Your Progress',
                        calcValue: 0.02,
                        position: -1,
                      ),
                      SizedBox(height: 20),
                      GeneralTextField(
                        theme: theme,
                        hint: 'Enter Product Name',
                        lines: 1,
                        title: 'Product Name',
                        controller: nameController,
                      ),
                      SizedBox(height: 20),
                      GeneralTextField(
                        theme: theme,
                        hint: 'Enter Product Desription',
                        lines: 4,
                        title: 'Description (Optional)',
                        controller: descController,
                      ),
                      SizedBox(height: 20),
                      GeneralTextField(
                        theme: theme,
                        hint: 'Brand',
                        lines: 1,
                        title: 'Enter Brand (Optional)',
                        controller: brandController,
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return AddProductTwo();
                      },
                    ),
                  );
                },
                text: 'Save and Continue',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
