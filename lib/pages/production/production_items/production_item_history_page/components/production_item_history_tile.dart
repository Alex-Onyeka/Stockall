// import 'package:flutter/material.dart';
// import 'package:stockall/classes/temp_production_item_history/production_item_history.dart';
// import 'package:stockall/components/alert_dialogues/dialog_template.dart';
// import 'package:stockall/components/buttons/main_button_p.dart';
// import 'package:stockall/components/buttons/main_button_transparent.dart';
// import 'package:stockall/constants/calculations.dart';
// import 'package:stockall/constants/constants_main.dart';
// import 'package:stockall/constants/functions.dart';
// import 'package:stockall/main.dart';
// import 'package:stockall/pages/products/product_details/product_details_page.dart';

// class ProductionItemHistoryTile extends StatefulWidget {
//   const ProductionItemHistoryTile({
//     super.key,
//     required this.productionItemHistory,
//     required this.fromProductionItemDetails,
//   });

//   final ProductionItemHistory productionItemHistory;
//   final bool fromProductionItemDetails;

//   @override
//   State<ProductionItemHistoryTile> createState() =>
//       ProductionItemHistoryTileState();
// }

// class ProductionItemHistoryTileState
//     extends State<ProductionItemHistoryTile> {
//   String cutLongText(String text) {
//     if (text.length >
//         (screenWidth(context) > mobileScreen ? 25 : 15)) {
//       return '${text.substring(0, (screenWidth(context) > mobileScreen ? 25 : 15))}...';
//     } else {
//       return text;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     var theme = returnTheme(context);
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 5.0),
//       child: Ink(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(5),
//           border: Border.all(color: Colors.grey.shade200),
//         ),
//         child: InkWell(
//           mouseCursor: SystemMouseCursors.click,
//           onTap: () {
//             showDialog(
//               context: context,
//               builder: (firstContext) {
//                 return DialogTemplate(
//                   theme: theme,
//                   message: 'View Item History Details',
//                   title: 'History Details',
//                   action: () {},
//                   showBottomActionButtons: false,
//                   widget: SizedBox(
//                     height: screenHeight(context) - 200,
//                     child:
//                         ProductionItemHistoryDetailsWidget(
//                           productionItemHistory:
//                               widget.productionItemHistory,
//                           fromProductionItemDetails:
//                               widget
//                                   .fromProductionItemDetails,
//                         ),
//                   ),
//                 );
//               },
//             );
//           },
//           borderRadius: BorderRadius.circular(5),
//           child: Container(
//             padding: EdgeInsets.fromLTRB(8, 15, 15, 15),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               spacing: 10,
//               children: [
//                 Visibility(
//                   visible:
//                       screenWidth(context) >
//                       mobileScreenSmall,
//                   child: Container(
//                     padding: EdgeInsets.all(5),
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       color:
//                           widget
//                                       .productionItemHistory
//                                       .isIncreased ==
//                                   true
//                               ? Colors.green.shade100
//                               : Colors.red.shade100,
//                     ),
//                     child: Icon(
//                       color:
//                           widget
//                                       .productionItemHistory
//                                       .isIncreased ==
//                                   true
//                               ? Colors.green
//                               : Colors.red,
//                       size: 20,
//                       widget
//                                   .productionItemHistory
//                                   .isIncreased ==
//                               true
//                           ? Icons.add
//                           : Icons.clear,
//                     ),
//                   ),
//                 ),
//                 Flexible(
//                   child: Column(
//                     children: [
//                       Row(
//                         spacing: 15,
//                         crossAxisAlignment:
//                             CrossAxisAlignment.start,
//                         mainAxisAlignment:
//                             MainAxisAlignment.spaceBetween,
//                         children: [
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment:
//                                   CrossAxisAlignment.start,
//                               spacing: 5,
//                               children: [
//                                 Row(
//                                   crossAxisAlignment:
//                                       CrossAxisAlignment
//                                           .start,
//                                   spacing: 5,
//                                   children: [
//                                     Expanded(
//                                       child: Text(
//                                         style: TextStyle(
//                                           fontWeight:
//                                               FontWeight
//                                                   .bold,
//                                           fontSize:
//                                               theme
//                                                   .mobileTexts
//                                                   .b2
//                                                   .fontSize,
//                                         ),
//                                         widget
//                                             .productionItemHistory
//                                             .title,
//                                       ),
//                                     ),
//                                     Text(
//                                       style: TextStyle(
//                                         fontWeight:
//                                             FontWeight.bold,
//                                         fontSize:
//                                             theme
//                                                 .mobileTexts
//                                                 .b2
//                                                 .fontSize,
//                                         color:
//                                             widget.productionItemHistory.isIncreased ==
//                                                     true
//                                                 ? Colors
//                                                     .green
//                                                 : Colors
//                                                     .redAccent,
//                                       ),
//                                       returnHistoryQuantity(
//                                         quantityChange:
//                                             widget
//                                                 .productionItemHistory
//                                                 .quantityChange,
//                                         isIncreased:
//                                             widget
//                                                 .productionItemHistory
//                                                 .isIncreased,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 Text(
//                                   style: TextStyle(
//                                     fontSize:
//                                         theme
//                                             .mobileTexts
//                                             .b3
//                                             .fontSize,
//                                     fontWeight:
//                                         FontWeight.normal,
//                                     color:
//                                         Colors
//                                             .grey
//                                             .shade700,
//                                   ),
//                                   widget
//                                           .productionItemHistory
//                                           .desc ??
//                                       'Description Not Set',
//                                 ),
//                               ],
//                             ),
//                           ),
//                           Row(
//                             children: [
//                               Visibility(
//                                 visible:
//                                     screenWidth(context) >
//                                     mobileScreenSmall,
//                                 child: Padding(
//                                   padding:
//                                       const EdgeInsets.only(
//                                         right: 4.0,
//                                       ),
//                                   child: Text(
//                                     style: TextStyle(
//                                       fontSize:
//                                           theme
//                                               .mobileTexts
//                                               .b4
//                                               .fontSize,
//                                       fontWeight:
//                                           FontWeight.normal,
//                                       color:
//                                           Colors
//                                               .grey
//                                               .shade700,
//                                     ),
//                                     'View More',
//                                   ),
//                                 ),
//                               ),
//                               Icon(
//                                 size: 15,
//                                 color: Colors.grey.shade400,
//                                 Icons
//                                     .arrow_forward_ios_rounded,
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 5),
//                       Divider(
//                         color: Colors.grey.shade400,
//                         thickness: 0.5,
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.only(
//                           // top: 5.0,
//                           // bottom: 5,
//                           right: 15,
//                         ),
//                         child: Row(
//                           mainAxisAlignment:
//                               MainAxisAlignment
//                                   .spaceBetween,
//                           children: [
//                             Expanded(
//                               child: Row(
//                                 crossAxisAlignment:
//                                     CrossAxisAlignment
//                                         .start,
//                                 spacing: 5,
//                                 children: [
//                                   Text(
//                                     style: TextStyle(
//                                       fontSize:
//                                           theme
//                                               .mobileTexts
//                                               .b3
//                                               .fontSize,
//                                       color:
//                                           Colors
//                                               .grey
//                                               .shade600,
//                                     ),
//                                     'Item:',
//                                   ),
//                                   Flexible(
//                                     child: Text(
//                                       style: TextStyle(
//                                         fontSize:
//                                             theme
//                                                 .mobileTexts
//                                                 .b3
//                                                 .fontSize,
//                                         color:
//                                             theme
//                                                 .lightModeColor
//                                                 .prColor300,
//                                         fontWeight:
//                                             FontWeight.bold,
//                                       ),
//                                       cutLongText(
//                                         widget
//                                                 .productionItemHistory
//                                                 .itemName ??
//                                             'Item Name Not Set',
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             Row(
//                               spacing: 3,
//                               children: [
//                                 Visibility(
//                                   visible:
//                                       screenWidth(context) >
//                                       mobileScreenSmall,
//                                   child: Text(
//                                     style: TextStyle(
//                                       fontSize:
//                                           theme
//                                               .mobileTexts
//                                               .b3
//                                               .fontSize,
//                                       color:
//                                           Colors
//                                               .grey
//                                               .shade600,
//                                     ),
//                                     'Date:',
//                                   ),
//                                 ),
//                                 Text(
//                                   style: TextStyle(
//                                     fontSize:
//                                         theme
//                                             .mobileTexts
//                                             .b4
//                                             .fontSize,
//                                     color:
//                                         theme
//                                             .lightModeColor
//                                             .prColor300,
//                                     fontWeight:
//                                         FontWeight.bold,
//                                   ),
//                                   formatDateTimeTime(
//                                     widget
//                                             .productionItemHistory
//                                             .createdAt ??
//                                         DateTime.now(),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class ProductionItemHistoryDetailsWidget
//     extends StatefulWidget {
//   final ProductionItemHistory productionItemHistory;
//   final bool fromProductionItemDetails;

//   const ProductionItemHistoryDetailsWidget({
//     super.key,
//     required this.productionItemHistory,
//     required this.fromProductionItemDetails,
//   });

//   @override
//   State<ProductionItemHistoryDetailsWidget> createState() =>
//       _ProductionItemHistoryDetailsWidgetState();
// }

// class _ProductionItemHistoryDetailsWidgetState
//     extends State<ProductionItemHistoryDetailsWidget> {
//   @override
//   Widget build(BuildContext context) {
//     var theme = returnTheme(context);
//     return Scaffold(
//       body: Column(
//         spacing: 10,
//         children: [
//           Divider(height: 1),
//           Expanded(
//             child: ListView(
//               children: [
//                 ProductionItemHistorySectionWidget(
//                   title: 'Item Name',
//                   message:
//                       widget
//                           .productionItemHistory
//                           .itemName ??
//                       'Not Set',
//                 ),
//                 ProductionItemHistorySectionWidget(
//                   title: 'Title',
//                   message:
//                       widget.productionItemHistory.title,
//                 ),
//                 ProductionItemHistorySectionWidget(
//                   title: 'Description',
//                   message:
//                       widget.productionItemHistory.desc ??
//                       'Description Not Set',
//                 ),
//                 ProductionItemHistorySectionWidget(
//                   title: 'Created Date',
//                   message: formatDateWithTime(
//                     widget
//                             .productionItemHistory
//                             .createdAt ??
//                         DateTime.now(),
//                   ),
//                 ),
//                 ProductionItemHistorySectionWidget(
//                   title: 'Quantity Change',
//                   message: returnHistoryQuantity(
//                     isIncreased:
//                         widget
//                             .productionItemHistory
//                             .isIncreased,
//                     quantityChange:
//                         widget
//                             .productionItemHistory
//                             .quantityChange,
//                   ),
//                 ),
//                 ProductionItemHistorySectionWidget(
//                   title: 'New Value',
//                   message: formatLargeNumber(
//                     widget.productionItemHistory.newValue ??
//                         '',
//                   ),
//                 ),
//                 ProductionItemHistorySectionWidget(
//                   title: 'Old Value',
//                   message: formatLargeNumber(
//                     widget.productionItemHistory.oldValue ??
//                         '0',
//                   ),
//                 ),
//                 ProductionItemHistorySectionWidget(
//                   title: 'Creator',
//                   message:
//                       widget
//                           .productionItemHistory
//                           .staffName ??
//                       'Not Set',
//                 ),
//                 Visibility(
//                   visible:
//                       widget
//                           .productionItemHistory
//                           .departmentName !=
//                       null,
//                   child: ProductionItemHistorySectionWidget(
//                     title: 'Department Name',
//                     message:
//                         widget
//                             .productionItemHistory
//                             .departmentName ??
//                         'Not Set',
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Visibility(
//             visible:
//                 !widget.fromProductionItemDetails &&
//                 widget.productionItemHistory.itemUuid !=
//                     null,
//             child: MainButtonP(
//               themeProvider: theme,
//               action: () {
//                 Navigator.of(context).pop();
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) {
//                       return ProductDetailsPage(
//                         productUuid:
//                             widget
//                                 .productionItemHistory
//                                 .itemUuid ??
//                             '',
//                       );
//                     },
//                   ),
//                 );
//               },
//               text: 'View Item',
//             ),
//           ),
//           MainButtonTransparent(
//             themeProvider: theme,
//             constraints: BoxConstraints(),
//             text: 'Cancel',
//           ),
//         ],
//       ),
//     );
//   }
// }

// class ProductionItemHistorySectionWidget
//     extends StatelessWidget {
//   final String title;
//   final String message;
//   const ProductionItemHistorySectionWidget({
//     super.key,
//     required this.title,
//     required this.message,
//   });

//   @override
//   Widget build(BuildContext context) {
//     var theme = returnTheme(context);
//     return Container(
//       margin: EdgeInsets.symmetric(vertical: 3),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             padding: EdgeInsetsGeometry.fromLTRB(
//               10,
//               7,
//               10,
//               5,
//             ),
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.only(
//                 topLeft: Radius.circular(5),
//                 topRight: Radius.circular(5),
//               ),
//               color: Colors.grey.shade200,
//             ),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: Text(
//                     style: TextStyle(
//                       fontSize:
//                           theme.mobileTexts.b4.fontSize,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.grey.shade900,
//                     ),
//                     '$title:',
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Container(
//             padding: EdgeInsetsGeometry.fromLTRB(
//               10,
//               5,
//               10,
//               10,
//             ),
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(2),
//               color: Colors.grey.shade100,
//             ),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: Text(
//                     style: TextStyle(
//                       fontSize:
//                           theme.mobileTexts.b3.fontSize,
//                       fontWeight: FontWeight.normal,
//                       color: Colors.grey.shade700,
//                     ),
//                     message,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// String returnHistoryQuantity({
//   required double? quantityChange,
//   required bool? isIncreased,
// }) {
//   final quantity = quantityChange ?? 0;

//   if (isIncreased == false) {
//     return '-${quantity.abs()}';
//   }

//   return '+${quantity.abs()}';
// }
