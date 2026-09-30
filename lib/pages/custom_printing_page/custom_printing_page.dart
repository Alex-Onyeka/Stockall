import 'package:flutter/material.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/custom_printing_page/components/custom_label_print_widget.dart';
import 'package:stockall/pages/custom_printing_page/components/custom_receipt_print_widget.dart';

class CustomPrintingPage extends StatefulWidget {
  const CustomPrintingPage({super.key});

  @override
  State<CustomPrintingPage> createState() =>
      _CustomPrintingPageState();
}

class _CustomPrintingPageState
    extends State<CustomPrintingPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(backGroundImage),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        color: const Color.fromARGB(136, 255, 255, 255),
        padding: EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 15,
        ),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 15,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(15, 0, 0, 0),
                blurRadius: 10,
                spreadRadius: 5,
                offset: Offset(0, 0),
              ),
            ],
          ),
          child: Scaffold(
            appBar: appBar(
              backAction: () => Navigator.of(context).pop(),
              context: context,
              title: 'Custom Prints',
            ),
            body: Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Row(
                spacing: 10,
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: CustomLabelPrintWidget()),
                  Expanded(
                    child: CustomReceiptPrintWidget(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
