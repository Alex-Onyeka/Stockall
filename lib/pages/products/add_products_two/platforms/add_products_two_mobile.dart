// import 'package:flutter/material.dart';
// import 'package:stockitt/components/alert_dialogues/info_alert.dart';
// import 'package:stockitt/components/buttons/main_button_p.dart';
// import 'package:stockitt/components/progress_bar.dart';
// import 'package:stockitt/components/text_fields/barcode_scanner.dart';
// import 'package:stockitt/components/text_fields/main_dropdown.dart';
// import 'package:stockitt/components/text_fields/money_textfield.dart';
// import 'package:stockitt/constants/bottom_sheet_widgets.dart';
// import 'package:stockitt/constants/scan_barcode.dart';
// import 'package:stockitt/main.dart';
// import 'package:stockitt/pages/products/add_products_three/add_products_three.dart';

// class AddProductsTwoMobile extends StatefulWidget {
//   final TextEditingController costController;
//   final TextEditingController sellingController;
//   final TextEditingController categoryController;
//   const AddProductsTwoMobile({
//     super.key,
//     required this.costController,
//     required this.sellingController,
//     required this.categoryController,
//   });

//   @override
//   State<AddProductsTwoMobile> createState() =>
//       _AddProductsTwoMobileState();
// }

// class _AddProductsTwoMobileState
//     extends State<AddProductsTwoMobile> {
//   //
//   //
//   //
//   bool barCodeSet = false;

//   String? barcode;

//   //
//   //
//   void checkFields() {
//     if (widget.costController.text.isEmpty ||
//         widget.sellingController.text.isEmpty ||
//         returnData(context, listen: false).selectedUnit ==
//             null) {
//       showDialog(
//         context: context,
//         builder: (context) {
//           var theme = returnTheme(context);
//           return InfoAlert(
//             theme: theme,
//             message:
//                 'Product Cost Price, Selling Price and Product Unit Must be set',
//             title: 'Empty Input',
//           );
//         },
//       );
//     } else {
//       returnData(context, listen: false).barcode =
//           barcode ?? '';
//       returnData(
//         context,
//         listen: false,
//       ).costPrice = double.parse(
//         widget.costController.text.replaceAll(',', ''),
//       );
//       returnData(
//         context,
//         listen: false,
//       ).sellingPrice = double.parse(
//         widget.sellingController.text.replaceAll(',', ''),
//       );
//       returnData(context, listen: false).unit =
//           returnData(context, listen: false).selectedUnit!;
//       returnData(context, listen: false).color =
//           returnData(
//             context,
//             listen: false,
//           ).selectedColor ??
//           '';

//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) {
//             return AddProductsThree();
//           },
//         ),
//       );
//     }
//   }
//   //
//   //
//   //
//   //

//   bool isOpen = false;
//   @override
//   Widget build(BuildContext context) {
//     var theme = returnTheme(context);
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           onPressed: () {
//             Navigator.of(context).pop();
//           },
//           icon: Padding(
//             padding: const EdgeInsets.only(
//               left: 20.0,
//               right: 10,
//             ),
//             child: Icon(Icons.arrow_back_ios_new_rounded),
//           ),
//         ),
//         centerTitle: true,
//         title: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               style: TextStyle(
//                 fontSize: theme.mobileTexts.h4.fontSize,
//                 fontWeight: FontWeight.bold,
//               ),
//               'New Product',
//             ),
//             SizedBox(height: 5),
//             Text(
//               style: TextStyle(
//                 fontSize: theme.mobileTexts.b2.fontSize,
//               ),
//               'Add New Product to you Store',
//             ),
//           ],
//         ),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(
//                 horizontal: 30.0,
//               ),
//               child: SingleChildScrollView(
//                 child: Padding(
//                   padding: const EdgeInsets.only(top: 10.0),
//                   child: Column(
//                     children: [
//                       ProgressBar(
//                         theme: theme,
//                         percent: '33.3%',
//                         title: 'Your Progress',
//                         calcValue: 0.25,
//                         position: -0.33,
//                       ),
//                       SizedBox(height: 20),
//                       BarcodeScanner(
//                         valueSet: barCodeSet,
//                         onTap: () async {
//                           String info = await scanCode(
//                             context,
//                             'failed',
//                           );
//                           setState(() {
//                             barcode = info;
//                             barCodeSet = true;
//                           });
//                         },
//                         title: 'Product Barcode',
//                         hint:
//                             barcode ??
//                             'Click to Scan Product Barcode',
//                         theme: theme,
//                       ),
//                       SizedBox(height: 20),
//                       MoneyTextfield(
//                         theme: theme,
//                         hint:
//                             'Enter the actual Amount of the Item',
//                         title: 'Cost - Price',
//                         controller: widget.costController,
//                       ),
//                       SizedBox(height: 20),
//                       MoneyTextfield(
//                         theme: theme,
//                         hint:
//                             'Enter the Amount you wish to sell this Product',
//                         title: 'Selling - Price',
//                         controller:
//                             widget.sellingController,
//                       ),
//                       SizedBox(height: 20),
//                       MainDropdown(
//                         valueSet:
//                             returnData(
//                               context,
//                             ).unitValueSet,
//                         onTap: () {
//                           unitsBottomSheet(context, () {
//                             setState(() {
//                               isOpen = !isOpen;
//                             });
//                           });
//                           setState(() {
//                             isOpen = !isOpen;
//                           });
//                         },
//                         isOpen: isOpen,
//                         title: 'Unit',
//                         hint:
//                             returnData(
//                               context,
//                             ).selectedUnit ??
//                             'Select Product Unit',
//                         theme: theme,
//                       ),
//                       SizedBox(height: 20),
//                       MainDropdown(
//                         valueSet:
//                             returnData(
//                               context,
//                             ).colorValueSet,
//                         onTap: () {
//                           colorsBottomSheet(context, () {
//                             setState(() {
//                               isOpen = !isOpen;
//                             });
//                           });
//                           setState(() {
//                             isOpen = !isOpen;
//                           });
//                         },
//                         isOpen: isOpen,
//                         title: 'Color (Optional)',
//                         hint:
//                             returnData(
//                               context,
//                             ).selectedColor ??
//                             'Select Product Color',
//                         theme: theme,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           Container(
//             color: Colors.white,
//             child: Padding(
//               padding: const EdgeInsets.only(
//                 bottom: 30.0,
//                 top: 20,
//                 left: 30,
//                 right: 30,
//               ),
//               child: MainButtonP(
//                 themeProvider: theme,
//                 action: () {
//                   checkFields();
//                 },
//                 text: 'Save and Continue',
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
