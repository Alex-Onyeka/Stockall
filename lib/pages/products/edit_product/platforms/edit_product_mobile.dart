// import 'package:flutter/material.dart';
// import 'package:stockall/classes/temp_product_class.dart';
// import 'package:stockall/components/alert_dialogues/info_alert.dart';
// import 'package:stockall/components/buttons/main_button_p.dart';
// import 'package:stockall/components/text_fields/barcode_scanner.dart';
// import 'package:stockall/components/text_fields/general_textfield.dart';
// import 'package:stockall/components/text_fields/main_dropdown.dart';
// import 'package:stockall/components/text_fields/money_textfield.dart';
// import 'package:stockall/components/text_fields/number_textfield.dart';
// import 'package:stockall/constants/bottom_sheet_widgets.dart';
// import 'package:stockall/constants/scan_barcode.dart';
// import 'package:stockall/main.dart';

// class EditProductMobile extends StatefulWidget {
//   final TempProductClass product;
//   final TextEditingController costController;
//   final TextEditingController sellingController;
//   final TextEditingController categoryController;
//   final TextEditingController sizeController;
//   final TextEditingController quantityController;
//   final TextEditingController nameController;
//   final TextEditingController brandController;

//   const EditProductMobile({
//     required this.nameController,
//     required this.brandController,
//     super.key,
//     required this.costController,
//     required this.sellingController,
//     required this.categoryController,
//     required this.sizeController,
//     required this.quantityController,
//     required this.product,
//   });

//   @override
//   State<EditProductMobile> createState() =>
//       _EditProductMobileState();
// }

// class _EditProductMobileState
//     extends State<EditProductMobile> {
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
//                 'Item Cost Price, Selling Price and Item Unit Must be set',
//             title: 'Empty Input',
//           );
//         },
//       );
//     } else {
//       returnData(context, listen: false).barcode = barcode!;
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
//           returnData(context, listen: false).selectedColor!;

//       // Navigator.push(
//       //   context,
//       //   MaterialPageRoute(
//       //     builder: (context) {
//       //       return AddProductsThree();
//       //     },
//       //   ),
//       // );
//     }
//   }
//   //
//   //
//   //
//   //

//   bool isOpen = false;

//   @override
//   void initState() {
//     super.initState();
//     barcode = widget.product.barcode;
//     barCodeSet =
//         widget.product.barcode != null ? true : false;
//   }

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
//               'Edit Item',
//             ),
//             SizedBox(height: 5),
//             Text(
//               style: TextStyle(
//                 fontSize: theme.mobileTexts.b2.fontSize,
//               ),
//               'Edit Item Info',
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
//                       GeneralTextField(
//                         theme: theme,
//                         hint: 'Enter Item Name',
//                         lines: 1,
//                         title: 'Item Name',
//                         controller: widget.nameController,
//                       ),
//                       SizedBox(height: 20),
//                       GeneralTextField(
//                         theme: theme,
//                         hint: 'Brand',
//                         lines: 1,
//                         title: 'Enter Brand (Optional)',
//                         controller: widget.brandController,
//                       ),
//                       SizedBox(height: 20),
//                       MainDropdown(
//                         valueSet:
//                             returnData(context).catValueSet,
//                         onTap: () {
//                           categoriesBottomSheet(
//                             context,
//                             () {
//                               setState(() {
//                                 isOpen = false;
//                               });
//                             },
//                           );
//                           setState(() {
//                             isOpen = !isOpen;
//                           });
//                         },
//                         isOpen: isOpen,
//                         title: 'Category',
//                         hint:
//                             returnData(
//                               context,
//                             ).selectedCategory ??
//                             'Select Item Category',
//                         theme: theme,
//                       ),
//                       SizedBox(height: 20),
//                       BarcodeScanner(
//                         valueSet: barCodeSet,
//                         onTap: () async {
//                           String? info = await scanCode(
//                             context,
//                             'failed',
//                           );
//                           setState(() {
//                             barcode = info;
//                             barCodeSet = true;
//                           });
//                         },
//                         title: 'Item Barcode',
//                         hint:
//                             barcode ??
//                             'Click to Scan Item Barcode',
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
//                             'Enter the Amount you wish to sell this Item',
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
//                             'Select Item Unit',
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
//                             'Select Item Color',
//                         theme: theme,
//                       ),
//                       NumberTextfield(
//                         theme: theme,
//                         hint: 'Enter Item Size',
//                         title: 'Size  (Optional)',
//                         controller: widget.sizeController,
//                       ),
//                       SizedBox(height: 20),
//                       NumberTextfield(
//                         theme: theme,
//                         hint: 'Enter Quantity',
//                         title: 'Quantity',
//                         controller:
//                             widget.quantityController,
//                       ),
//                       SizedBox(height: 20),
//                       MainDropdown(
//                         valueSet:
//                             returnData(
//                               context,
//                             ).unitValueSet,
//                         onTap: () {
//                           sizeTypeBottomSheet(context, () {
//                             // FocusScope.of(
//                             //   context,
//                             // ).unfocus();
//                             setState(() {
//                               isOpen = !isOpen;
//                             });
//                           });
//                           setState(() {
//                             isOpen = !isOpen;
//                           });
//                         },
//                         isOpen: isOpen,
//                         title: 'Size Name',
//                         hint:
//                             returnData(
//                               context,
//                             ).selectedSize ??
//                             'Select Item Size Name (Optional)',
//                         theme: theme,
//                       ),
//                       SizedBox(height: 20),
//                       InkWell(
//                         onTap: () {
//                           returnData(
//                             context,
//                             listen: false,
//                           ).toggleStock();
//                         },
//                         child: Row(
//                           mainAxisAlignment:
//                               MainAxisAlignment
//                                   .spaceBetween,
//                           children: [
//                             Column(
//                               crossAxisAlignment:
//                                   CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   style: TextStyle(
//                                     fontSize:
//                                         theme
//                                             .mobileTexts
//                                             .b1
//                                             .fontSize,
//                                     fontWeight:
//                                         FontWeight.bold,
//                                   ),
//                                   'In-Stock',
//                                 ),
//                                 Text(
//                                   'Track Stock Inventory',
//                                 ),
//                               ],
//                             ),
//                             Checkbox(
//                               activeColor:
//                                   theme
//                                       .lightModeColor
//                                       .secColor100,
//                               value:
//                                   returnData(
//                                     context,
//                                   ).inStock,
//                               onChanged: (value) {
//                                 returnData(
//                                   context,
//                                   listen: false,
//                                 ).toggleStock();
//                               },
//                             ),
//                           ],
//                         ),
//                       ),
//                       SizedBox(height: 30),
//                       InkWell(
//                         onTap: () {
//                           returnData(
//                             context,
//                             listen: false,
//                           ).toggleRefundable();
//                         },
//                         child: Row(
//                           mainAxisAlignment:
//                               MainAxisAlignment
//                                   .spaceBetween,
//                           children: [
//                             Column(
//                               crossAxisAlignment:
//                                   CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   style: TextStyle(
//                                     fontSize:
//                                         theme
//                                             .mobileTexts
//                                             .b1
//                                             .fontSize,
//                                     fontWeight:
//                                         FontWeight.bold,
//                                   ),
//                                   'Refundable?',
//                                 ),
//                                 Text(
//                                   'Allow Customers return items',
//                                 ),
//                               ],
//                             ),
//                             Checkbox(
//                               activeColor:
//                                   theme
//                                       .lightModeColor
//                                       .secColor100,
//                               value:
//                                   returnData(
//                                     context,
//                                   ).isProductRefundable,
//                               onChanged: (value) {
//                                 returnData(
//                                   context,
//                                   listen: false,
//                                 ).toggleRefundable();
//                               },
//                             ),
//                           ],
//                         ),
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
