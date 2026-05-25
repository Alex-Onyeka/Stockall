// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:stockall/classes/checkout_response.dart';
// import 'package:stockall/classes/temp_customers/temp_customers_class.dart';
// import 'package:stockall/classes/temp_main_receipt/temp_main_receipt.dart';
// import 'package:stockall/classes/temp_product_slaes_record/temp_product_sale_record.dart';
// import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
// import 'package:stockall/constants/calculations.dart';
// import 'package:stockall/constants/functions.dart';
// import 'package:stockall/constants/subscription/sales_auth.dart';
// import 'package:stockall/main.dart';
// import 'package:stockall/pages/authentication/base_page/base_page.dart';
// import 'package:stockall/pages/sales/sales_page/sales_page.dart';

// class ReceiptPageDesktop extends StatefulWidget {
//   final bool isMain;
//   final CheckoutResponse response;
//   // final bool? isComingFromReceipt;
//   const ReceiptPageDesktop({
//     super.key,
//     required this.response,
//     required this.isMain,
//     // this.isComingFromReceipt,
//   });

//   @override
//   State<ReceiptPageDesktop> createState() =>
//       _ReceiptPageDesktopState();
// }

// class _ReceiptPageDesktopState
//     extends State<ReceiptPageDesktop> {
//   bool isLoading = false;
//   bool isDeleteLoading = false;
//   bool isPrintLoading = false;
//   bool isDownloadLoading = false;

//   @override
//   Widget build(BuildContext context) {
//     var theme = returnTheme(context);
//     List<TempProductSaleRecord> saleRecords =
//         returnReceiptProvider(context, listen: false)
//             .produtRecordSalesMain
//             .where(
//               (record) =>
//                   record.receiptUuid ==
//                   widget.response.resUuid,
//             )
//             .toList();
//     var invs =
//         returnReceiptProviderSingle().receipts
//             .where(
//               (inv) => inv.uuid == widget.response.resUuid,
//             )
//             .toList();

//     TempMainReceipt? receipt =
//         invs.isNotEmpty ? invs.first : null;
//     var custs =
//         returnCustomers(context, listen: false)
//             .customersMain()
//             .where(
//               (cus) => cus.uuid == receipt?.customerUuid,
//             )
//             .toList();
//     TempCustomersClass? customer =
//         custs.isNotEmpty ? custs.first : null;
//     // getSalesRecords();
//     return Builder(
//       builder: (context) {
//         if (receipt == null) {
//           return Scaffold(
//             body: Column(
//               spacing: 15,
//               children: [
//                 Container(
//                   padding: EdgeInsets.symmetric(
//                     horizontal: 30,
//                     vertical: 20,
//                   ),
//                   decoration: BoxDecoration(
//                     border: Border(
//                       bottom: BorderSide(
//                         color: Colors.grey.shade200,
//                       ),
//                     ),
//                     color: Colors.white,
//                   ),
//                   child: Row(
//                     mainAxisAlignment:
//                         MainAxisAlignment.spaceBetween,
//                     spacing: 10,
//                     children: [
//                       Row(
//                         spacing: 10,
//                         children: [
//                           InkWell(
//                             onTap: () {
//                               if (Navigator.canPop(
//                                 context,
//                               )) {
//                                 Navigator.pop(context);
//                               } else {
//                                 Navigator.pushReplacement(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) {
//                                       return BasePage();
//                                     },
//                                   ),
//                                 );
//                               }
//                             },
//                             borderRadius:
//                                 BorderRadius.circular(30),
//                             child: Container(
//                               padding: EdgeInsets.all(15),
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 border: Border.all(
//                                   color:
//                                       Colors.grey.shade200,
//                                   width: 1,
//                                 ),
//                               ),
//                               child: Icon(
//                                 size: 18,
//                                 color: Colors.grey.shade700,
//                                 Icons
//                                     .arrow_back_ios_new_outlined,
//                               ),
//                             ),
//                           ),
//                           Column(
//                             crossAxisAlignment:
//                                 CrossAxisAlignment.start,
//                             spacing: 5,
//                             children: [
//                               Text(
//                                 style: TextStyle(
//                                   fontSize:
//                                       theme
//                                           .mobileTexts
//                                           .b3
//                                           .fontSize,
//                                 ),
//                                 'Receipt',
//                               ),
//                               Text(
//                                 style: TextStyle(
//                                   fontSize:
//                                       theme
//                                           .mobileTexts
//                                           .b2
//                                           .fontSize,
//                                   fontWeight:
//                                       FontWeight.bold,
//                                 ),
//                                 'Customer Name',
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                       Row(
//                         spacing: 5,
//                         children: [
//                           ActionButtonSmall(
//                             action: () {},
//                             text: 'Print',
//                           ),
//                           ActionButtonSmall(
//                             action: () {},
//                             text: 'Edit',
//                           ),
//                           ActionButtonSmall(
//                             action: () {},
//                             text: 'Dowmload',
//                           ),
//                           ActionButtonSmall(
//                             action: () {},
//                             text: 'Delete',
//                             textColor: Colors.red.shade300,
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//                 Expanded(
//                   child: Center(
//                     child: returnCompProvider(
//                       context,
//                     ).showLoader(message: ''),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         } else {
//           return Scaffold(
//             backgroundColor: const Color.fromARGB(
//               255,
//               253,
//               254,
//               255,
//             ),
//             body: Column(
//               spacing: 15,
//               children: [
//                 Container(
//                   padding: EdgeInsets.symmetric(
//                     horizontal: 30,
//                     vertical: 20,
//                   ),
//                   decoration: BoxDecoration(
//                     border: Border(
//                       bottom: BorderSide(
//                         color: Colors.grey.shade200,
//                       ),
//                     ),
//                     color: Colors.white,
//                   ),
//                   child: Row(
//                     mainAxisAlignment:
//                         MainAxisAlignment.spaceBetween,
//                     spacing: 10,
//                     children: [
//                       Row(
//                         spacing: 10,
//                         children: [
//                           InkWell(
//                             onTap: () {
//                               if (Navigator.canPop(
//                                 context,
//                               )) {
//                                 Navigator.pop(context);
//                               } else {
//                                 Navigator.pushReplacement(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) {
//                                       return BasePage();
//                                     },
//                                   ),
//                                 );
//                               }
//                             },
//                             borderRadius:
//                                 BorderRadius.circular(30),
//                             child: Container(
//                               padding: EdgeInsets.all(15),
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 border: Border.all(
//                                   color:
//                                       Colors.grey.shade200,
//                                   width: 1,
//                                 ),
//                               ),
//                               child: Icon(
//                                 size: 18,
//                                 color: Colors.grey.shade700,
//                                 Icons
//                                     .arrow_back_ios_new_outlined,
//                               ),
//                             ),
//                           ),
//                           Column(
//                             crossAxisAlignment:
//                                 CrossAxisAlignment.start,
//                             spacing: 5,
//                             children: [
//                               Text(
//                                 style: TextStyle(
//                                   fontSize:
//                                       theme
//                                           .mobileTexts
//                                           .b3
//                                           .fontSize,
//                                 ),
//                                 'Receipt',
//                               ),
//                               Text(
//                                 style: TextStyle(
//                                   fontSize:
//                                       theme
//                                           .mobileTexts
//                                           .b2
//                                           .fontSize,
//                                   fontWeight:
//                                       FontWeight.bold,
//                                 ),
//                                 customer?.name ??
//                                     'Customer Name',
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                       Row(
//                         spacing: 5,
//                         children: [
//                           ActionButtonSmall(
//                             isLoading: isPrintLoading,
//                             action: () {
//                               showDialog(
//                                 context: context,
//                                 builder: (confirmDialog) {
//                                   return ConfirmationAlert(
//                                     theme: theme,
//                                     message:
//                                         'You are about to Print This Receipt. Are you sure you want to Proceed?',
//                                     title: 'Print Receipt',
//                                     action: () async {
//                                       setState(() {
//                                         isPrintLoading =
//                                             true;
//                                       });
//                                       Navigator.of(
//                                         confirmDialog,
//                                       ).pop();
//                                       if (kIsWeb) {
//                                         downloadPdfWebRoll(
//                                           receipt: receipt,
//                                           staffName:
//                                               receipt
//                                                   .staffName ??
//                                               'Staff Name',
//                                           filename:
//                                               'Stockall_Receipt_${DateTime.now().millisecondsSinceEpoch}.pdf',
//                                           context: context,
//                                           records:
//                                               saleRecords,
//                                           shop:
//                                               returnShopProvider()
//                                                   .userShop()!,
//                                           printType:
//                                               returnShopProvider()
//                                                   .userShop()!
//                                                   .printType!,
//                                         );
//                                       } else {
//                                         await generateAndPreviewPdfRoll(
//                                           receipt: receipt,
//                                           printerType:
//                                               returnShopProvider()
//                                                   .userShop()!
//                                                   .printType ??
//                                               1,
//                                           staffName:
//                                               receipt
//                                                   .staffName ??
//                                               'Staff Name',
//                                           context: context,
//                                           records:
//                                               saleRecords,

//                                           shop:
//                                               returnShopProvider()
//                                                   .userShop()!,
//                                         );
//                                       }
//                                       setState(() {
//                                         isPrintLoading =
//                                             false;
//                                       });
//                                     },
//                                   );
//                                 },
//                               );
//                             },
//                             text: 'Print',
//                           ),
//                           ActionButtonSmall(
//                             isLoading: isDownloadLoading,
//                             action: () {
//                               SalesAuthAction().downloadReceiptAction(
//                                 context: context,
//                                 action: () async {
//                                   // var safeContext = context;

//                                   showDialog(
//                                     context: context,
//                                     builder: (
//                                       confirmDialog,
//                                     ) {
//                                       return ConfirmationAlert(
//                                         theme: theme,
//                                         message:
//                                             'You are about to download This Receipt. Are you sure you want to Proceed?',
//                                         title:
//                                             'Download Receipt',
//                                         action: () async {
//                                           setState(() {
//                                             isDownloadLoading =
//                                                 true;
//                                           });
//                                           Navigator.of(
//                                             confirmDialog,
//                                           ).pop();
//                                           if (kIsWeb) {
//                                             downloadPdfWeb(
//                                               receipt:
//                                                   receipt,
//                                               staffName:
//                                                   receipt
//                                                       .staffName ??
//                                                   'Staff Name',
//                                               filename:
//                                                   'Stockall_Receipt_${DateTime.now().millisecondsSinceEpoch}.pdf',
//                                               context:
//                                                   context,
//                                               shop:
//                                                   shop(
//                                                     context,
//                                                   )!,
//                                               records:
//                                                   saleRecords,
//                                             );
//                                           }
//                                           if (!kIsWeb) {
//                                             await generateAndPreviewPdf(
//                                               shop:
//                                                   shop(
//                                                     context,
//                                                   )!,
//                                               receipt:
//                                                   receipt,
//                                               staffName:
//                                                   receipt
//                                                       .staffName ??
//                                                   'Staff Name',
//                                               context:
//                                                   context,

//                                               records:
//                                                   saleRecords,
//                                             );
//                                           }
//                                           await Future.delayed(
//                                             Duration(
//                                               seconds: 1,
//                                             ),
//                                           );
//                                           if (context
//                                               .mounted) {
//                                             actionResultDialog(
//                                               context:
//                                                   context,
//                                               message:
//                                                   'Receipt Downloaded',
//                                               isSuccess:
//                                                   true,
//                                             );
//                                           }
//                                           setState(() {
//                                             isDownloadLoading =
//                                                 false;
//                                           });
//                                         },
//                                       );
//                                     },
//                                   );
//                                 },
//                               );
//                             },
//                             text: 'Download',
//                           ),
//                           Visibility(
//                             visible:
//                                 returnReceiptProvider(
//                                       context,
//                                     )
//                                     .returnOwnReceiptsByDayOrWeek()
//                                     .where(
//                                       (rec) =>
//                                           rec.uuid ==
//                                           widget
//                                               .response
//                                               .resUuid,
//                                     )
//                                     .isEmpty,
//                             child: ActionButtonSmall(
//                               action: () {
//                                 showDialog(
//                                   context: context,
//                                   builder: (confirmDialog) {
//                                     return ConfirmationAlert(
//                                       theme: theme,
//                                       message:
//                                           'You are about to edit this Receipt. Are you sure you want to proceed?',
//                                       title: 'Edit Receipt',
//                                       action: () {
//                                         Navigator.of(
//                                           confirmDialog,
//                                         ).pop();
//                                         returnSalesProvider()
//                                             .onEditReceipt(
//                                               receipt:
//                                                   receipt,
//                                               context:
//                                                   context,
//                                             );
//                                       },
//                                     );
//                                   },
//                                 );
//                               },
//                               text: 'Edit',
//                             ),
//                           ),
//                           ActionButtonSmall(
//                             isLoading: isDeleteLoading,
//                             action: () {
//                               showDialog(
//                                 context: context,
//                                 builder: (confirmDialog) {
//                                   return ConfirmationAlert(
//                                     theme: theme,
//                                     message:
//                                         'You are about to delete this Receipt, are you sure you want to proceed?',
//                                     title:
//                                         'Delete Receipt?',
//                                     action: () async {
//                                       Navigator.of(
//                                         confirmDialog,
//                                       ).pop();
//                                       setState(() {
//                                         isDeleteLoading =
//                                             true;
//                                       });
//                                       var res = await returnReceiptProviderSingle()
//                                           .deleteReceipt(
//                                             receipt,
//                                             saleRecords
//                                                 .map(
//                                                   (rec) =>
//                                                       rec.productName,
//                                                 )
//                                                 .toList(),
//                                           );
//                                       await actionResultDialog(
//                                         // ignore: use_build_context_synchronously
//                                         context: context,
//                                         message:
//                                             res == 1
//                                                 ? 'Deleted Successfully'
//                                                 : 'Failed',
//                                         isSuccess:
//                                             res == 1
//                                                 ? true
//                                                 : false,
//                                       );
//                                       setState(() {
//                                         isDeleteLoading =
//                                             false;
//                                       });
//                                       if (res == 1 &&
//                                           context.mounted) {
//                                         if (Navigator.of(
//                                           context,
//                                         ).canPop()) {
//                                           Navigator.of(
//                                             context,
//                                           ).pop();
//                                         } else {
//                                           Navigator.pushReplacement(
//                                             context,
//                                             MaterialPageRoute(
//                                               builder: (
//                                                 context,
//                                               ) {
//                                                 return SalesPage();
//                                               },
//                                             ),
//                                           );
//                                         }
//                                       }
//                                     },
//                                   );
//                                 },
//                               );
//                             },
//                             text: 'Delete',
//                             textColor: Colors.red.shade300,
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//                 Expanded(
//                   child: ListView(
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 30.0,
//                         ),
//                         child: Row(
//                           crossAxisAlignment:
//                               CrossAxisAlignment.start,
//                           spacing: 20,
//                           mainAxisAlignment:
//                               MainAxisAlignment
//                                   .spaceBetween,
//                           children: [
//                             Expanded(
//                               child: Container(
//                                 padding: EdgeInsets.all(30),
//                                 decoration: BoxDecoration(
//                                   border: Border.all(
//                                     color:
//                                         Colors
//                                             .grey
//                                             .shade100,
//                                   ),
//                                   borderRadius:
//                                       BorderRadius.circular(
//                                         3,
//                                       ),
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color:
//                                           const Color.fromARGB(
//                                             10,
//                                             0,
//                                             0,
//                                             0,
//                                           ),
//                                       blurRadius: 20,
//                                       spreadRadius: 5,
//                                     ),
//                                   ],
//                                   color: Colors.white,
//                                 ),
//                                 child: Column(
//                                   spacing: 5,
//                                   children: [
//                                     Row(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment
//                                               .start,
//                                       mainAxisAlignment:
//                                           MainAxisAlignment
//                                               .spaceBetween,
//                                       spacing: 5,
//                                       children: [
//                                         Expanded(
//                                           child: Column(
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment
//                                                     .start,
//                                             spacing: 5,
//                                             children: [
//                                               Text(
//                                                 style: TextStyle(
//                                                   fontSize:
//                                                       theme
//                                                           .mobileTexts
//                                                           .b3
//                                                           .fontSize,
//                                                   fontWeight:
//                                                       FontWeight
//                                                           .bold,
//                                                 ),
//                                                 'Cashier:',
//                                               ),
//                                               Text(
//                                                 style: TextStyle(
//                                                   fontSize:
//                                                       theme
//                                                           .mobileTexts
//                                                           .b3
//                                                           .fontSize,
//                                                   fontWeight:
//                                                       FontWeight
//                                                           .normal,
//                                                 ),
//                                                 receipt.staffName ??
//                                                     'Staff Name',
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                         Expanded(
//                                           child: Column(
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment
//                                                     .start,
//                                             spacing: 5,
//                                             children: [
//                                               Text(
//                                                 style: TextStyle(
//                                                   fontSize:
//                                                       theme
//                                                           .mobileTexts
//                                                           .b3
//                                                           .fontSize,
//                                                   fontWeight:
//                                                       FontWeight
//                                                           .bold,
//                                                 ),
//                                                 'Date:',
//                                               ),
//                                               Row(
//                                                 spacing: 5,
//                                                 children: [
//                                                   Flexible(
//                                                     child: Text(
//                                                       style: TextStyle(
//                                                         fontSize:
//                                                             theme.mobileTexts.b3.fontSize,
//                                                         fontWeight:
//                                                             FontWeight.normal,
//                                                       ),
//                                                       "${formatDateTime(receipt.createdAt)}  |  ${formatTime(receipt.createdAt)}",
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                     Divider(
//                                       color:
//                                           Colors
//                                               .grey
//                                               .shade200,
//                                       height: 50,
//                                     ),
//                                     Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment
//                                               .spaceBetween,
//                                       spacing: 10,
//                                       children: [
//                                         Expanded(
//                                           flex: 10,
//                                           child: Text(
//                                             style: TextStyle(
//                                               fontSize:
//                                                   theme
//                                                       .mobileTexts
//                                                       .b3
//                                                       .fontSize,
//                                               fontWeight:
//                                                   FontWeight
//                                                       .bold,
//                                             ),
//                                             'Items',
//                                           ),
//                                         ),
//                                         Expanded(
//                                           flex: 5,
//                                           child: Text(
//                                             style: TextStyle(
//                                               fontSize:
//                                                   theme
//                                                       .mobileTexts
//                                                       .b3
//                                                       .fontSize,
//                                               fontWeight:
//                                                   FontWeight
//                                                       .bold,
//                                             ),
//                                             'Price',
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                     Divider(
//                                       color:
//                                           Colors
//                                               .grey
//                                               .shade400,
//                                       height: 5,
//                                     ),
//                                     Column(
//                                       children:
//                                           saleRecords
//                                               .map(
//                                                 (
//                                                   record,
//                                                 ) => Padding(
//                                                   padding:
//                                                       const EdgeInsets.only(
//                                                         top:
//                                                             15.0,
//                                                       ),
//                                                   child: Row(
//                                                     crossAxisAlignment:
//                                                         CrossAxisAlignment.start,
//                                                     mainAxisAlignment:
//                                                         MainAxisAlignment.spaceBetween,
//                                                     spacing:
//                                                         10,
//                                                     children: [
//                                                       Expanded(
//                                                         flex:
//                                                             10,
//                                                         child: Column(
//                                                           spacing:
//                                                               2,
//                                                           crossAxisAlignment:
//                                                               CrossAxisAlignment.start,
//                                                           children: [
//                                                             Text(
//                                                               style: TextStyle(
//                                                                 fontSize:
//                                                                     theme.mobileTexts.b3.fontSize,
//                                                                 fontWeight:
//                                                                     FontWeight.bold,
//                                                               ),
//                                                               record.productName,
//                                                             ),
//                                                             Row(
//                                                               spacing:
//                                                                   3,
//                                                               children: [
//                                                                 Text(
//                                                                   style: TextStyle(
//                                                                     fontSize:
//                                                                         theme.mobileTexts.b3.fontSize,
//                                                                     fontWeight:
//                                                                         FontWeight.normal,
//                                                                   ),
//                                                                   'Qtty: ',
//                                                                 ),
//                                                                 Text(
//                                                                   style: TextStyle(
//                                                                     fontSize:
//                                                                         theme.mobileTexts.b3.fontSize,
//                                                                     fontWeight:
//                                                                         FontWeight.bold,
//                                                                   ),
//                                                                   '[ ${formatLargeNumberDouble(record.quantity)} ]',
//                                                                 ),
//                                                               ],
//                                                             ),
//                                                           ],
//                                                         ),
//                                                       ),
//                                                       Expanded(
//                                                         flex:
//                                                             5,
//                                                         child: Column(
//                                                           crossAxisAlignment:
//                                                               CrossAxisAlignment.start,
//                                                           children: [
//                                                             Text(
//                                                               style: TextStyle(
//                                                                 fontSize:
//                                                                     theme.mobileTexts.b3.fontSize,
//                                                                 fontWeight:
//                                                                     FontWeight.bold,
//                                                               ),
//                                                               formatMoneyBig(
//                                                                 amount:
//                                                                     (receipt.fixedDiscount ==
//                                                                                     null &&
//                                                                                 receipt.generalDiscount ==
//                                                                                     null) &&
//                                                                             record.discount !=
//                                                                                 null
//                                                                         ? ((record.originalCost ??
//                                                                                 0) -
//                                                                             (record.discountedAmount ??
//                                                                                 0))
//                                                                         : (record.originalCost ??
//                                                                             0),
//                                                                 context:
//                                                                     context,
//                                                               ),
//                                                             ),
//                                                             Visibility(
//                                                               visible:
//                                                                   record.discount !=
//                                                                       null &&
//                                                                   !record.customPriceSet &&
//                                                                   (receipt.fixedDiscount ==
//                                                                           null &&
//                                                                       receipt.generalDiscount ==
//                                                                           null),
//                                                               child: Text(
//                                                                 style: TextStyle(
//                                                                   decoration:
//                                                                       TextDecoration.lineThrough,
//                                                                   fontSize:
//                                                                       theme.mobileTexts.b4.fontSize,
//                                                                   fontWeight:
//                                                                       FontWeight.normal,
//                                                                 ),
//                                                                 formatMoneyMid(
//                                                                   amount:
//                                                                       record.originalCost!,
//                                                                   context:
//                                                                       context,
//                                                                 ),
//                                                               ),
//                                                             ),
//                                                           ],
//                                                         ),
//                                                       ),
//                                                     ],
//                                                   ),
//                                                 ),
//                                               )
//                                               .toList(),
//                                     ),
//                                     SizedBox(height: 15),
//                                     Divider(
//                                       color:
//                                           Colors
//                                               .grey
//                                               .shade400,
//                                       height: 5,
//                                     ),
//                                     SizedBox(height: 15),
//                                     Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment
//                                               .end,
//                                       children: [
//                                         SizedBox(
//                                           width: 240,
//                                           child: Column(
//                                             crossAxisAlignment:
//                                                 CrossAxisAlignment
//                                                     .start,
//                                             spacing: 3,
//                                             children: [
//                                               Row(
//                                                 mainAxisAlignment:
//                                                     MainAxisAlignment
//                                                         .end,
//                                                 spacing: 20,
//                                                 children: [
//                                                   Expanded(
//                                                     flex: 4,
//                                                     child: Text(
//                                                       style: TextStyle(
//                                                         fontSize:
//                                                             theme.mobileTexts.b4.fontSize,
//                                                         fontWeight:
//                                                             FontWeight.normal,
//                                                       ),
//                                                       'Subtotal:',
//                                                     ),
//                                                   ),
//                                                   Expanded(
//                                                     flex: 5,
//                                                     child: Text(
//                                                       style: TextStyle(
//                                                         fontSize:
//                                                             theme.mobileTexts.b4.fontSize,
//                                                         fontWeight:
//                                                             FontWeight.bold,
//                                                       ),
//                                                       formatMoneyBig(
//                                                         amount:
//                                                             receipt.originalCost ??
//                                                             0,
//                                                         context:
//                                                             context,
//                                                       ),
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                               Visibility(
//                                                 visible:
//                                                     receipt
//                                                         .vat !=
//                                                     null,
//                                                 child: Row(
//                                                   mainAxisAlignment:
//                                                       MainAxisAlignment
//                                                           .end,
//                                                   spacing:
//                                                       20,
//                                                   children: [
//                                                     Expanded(
//                                                       flex:
//                                                           4,
//                                                       child: Row(
//                                                         children: [
//                                                           Text(
//                                                             style: TextStyle(
//                                                               fontSize:
//                                                                   theme.mobileTexts.b4.fontSize,
//                                                               fontWeight:
//                                                                   FontWeight.normal,
//                                                             ),
//                                                             'VAT: ',
//                                                           ),
//                                                           Text(
//                                                             style: TextStyle(
//                                                               fontSize:
//                                                                   theme.mobileTexts.b4.fontSize,
//                                                               fontWeight:
//                                                                   FontWeight.normal,
//                                                             ),
//                                                             '[ ${receipt.vat ?? 0}% ]',
//                                                           ),
//                                                         ],
//                                                       ),
//                                                     ),
//                                                     Expanded(
//                                                       flex:
//                                                           5,
//                                                       child: Text(
//                                                         style: TextStyle(
//                                                           fontSize:
//                                                               theme.mobileTexts.b4.fontSize,
//                                                           fontWeight:
//                                                               FontWeight.bold,
//                                                         ),
//                                                         formatMoneyBig(
//                                                           amount: returnReceiptProviderSingle().getVATForReceipt(
//                                                             receipt,
//                                                           ),
//                                                           context:
//                                                               context,
//                                                         ),
//                                                       ),
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ),
//                                               Visibility(
//                                                 visible:
//                                                     receipt.fixedDiscount !=
//                                                         null ||
//                                                     receipt.generalDiscount !=
//                                                         null,
//                                                 child: Row(
//                                                   mainAxisAlignment:
//                                                       MainAxisAlignment
//                                                           .end,
//                                                   spacing:
//                                                       20,
//                                                   children: [
//                                                     Expanded(
//                                                       flex:
//                                                           4,
//                                                       child: Row(
//                                                         children: [
//                                                           Text(
//                                                             style: TextStyle(
//                                                               fontSize:
//                                                                   theme.mobileTexts.b4.fontSize,
//                                                               fontWeight:
//                                                                   FontWeight.normal,
//                                                             ),
//                                                             'Discount: ',
//                                                           ),
//                                                           Visibility(
//                                                             visible:
//                                                                 receipt.generalDiscount !=
//                                                                 null,
//                                                             child: Text(
//                                                               style: TextStyle(
//                                                                 fontSize:
//                                                                     theme.mobileTexts.b4.fontSize,
//                                                                 fontWeight:
//                                                                     FontWeight.normal,
//                                                               ),
//                                                               '[ ${receipt.generalDiscount}% ]',
//                                                             ),
//                                                           ),
//                                                           // Visibility(
//                                                           //   visible:
//                                                           //       receipt.fixedDiscount !=
//                                                           //       null,
//                                                           //   child: Text(
//                                                           //     style: TextStyle(
//                                                           //       fontSize:
//                                                           //           theme.mobileTexts.b4.fontSize,
//                                                           //       fontWeight:
//                                                           //           FontWeight.normal,
//                                                           //     ),
//                                                           //     '[ ${receipt.fixedDiscount} ]',
//                                                           //   ),
//                                                           // ),
//                                                         ],
//                                                       ),
//                                                     ),
//                                                     Expanded(
//                                                       flex:
//                                                           5,
//                                                       child: Text(
//                                                         style: TextStyle(
//                                                           fontSize:
//                                                               theme.mobileTexts.b4.fontSize,
//                                                           fontWeight:
//                                                               FontWeight.bold,
//                                                         ),
//                                                         formatMoneyBig(
//                                                           amount: returnReceiptProviderSingle().getDiscountAmountForReceipt(
//                                                             receipt,
//                                                           ),
//                                                           context:
//                                                               context,
//                                                         ),
//                                                       ),
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ),
//                                               Divider(
//                                                 color:
//                                                     Colors
//                                                         .grey
//                                                         .shade200,
//                                                 height: 5,
//                                               ),
//                                               Row(
//                                                 mainAxisAlignment:
//                                                     MainAxisAlignment
//                                                         .end,
//                                                 spacing: 20,
//                                                 children: [
//                                                   Expanded(
//                                                     flex: 4,
//                                                     child: Text(
//                                                       style: TextStyle(
//                                                         fontSize:
//                                                             theme.mobileTexts.b3.fontSize,
//                                                         fontWeight:
//                                                             FontWeight.bold,
//                                                       ),
//                                                       'Total:',
//                                                     ),
//                                                   ),
//                                                   Expanded(
//                                                     flex: 5,
//                                                     child: Text(
//                                                       style: TextStyle(
//                                                         fontSize:
//                                                             theme.mobileTexts.b2.fontSize,
//                                                         fontWeight:
//                                                             FontWeight.bold,
//                                                       ),
//                                                       formatMoneyBig(
//                                                         amount: returnReceiptProviderSingle().getTotalMainRevenueReceipt(
//                                                           receipt,
//                                                         ),
//                                                         context:
//                                                             context,
//                                                       ),
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                     // SizedBox(height: 20),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                             Container(
//                               width: 300,
//                               padding: EdgeInsets.symmetric(
//                                 // horizontal: 20,
//                                 vertical: 10,
//                               ),
//                               child: Column(
//                                 spacing: 5,
//                                 children: [
//                                   Container(
//                                     width: double.infinity,
//                                     padding: EdgeInsets.all(
//                                       15,
//                                     ),
//                                     decoration: BoxDecoration(
//                                       borderRadius:
//                                           BorderRadius.circular(
//                                             5,
//                                           ),
//                                       border: Border.all(
//                                         color:
//                                             const Color.fromARGB(
//                                               118,
//                                               134,
//                                               155,
//                                               173,
//                                             ),
//                                       ),
//                                       color:
//                                           const Color.fromARGB(
//                                             31,
//                                             173,
//                                             182,
//                                             209,
//                                           ),
//                                     ),
//                                     child: Column(
//                                       children: [
//                                         Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment
//                                                   .spaceBetween,
//                                           children: [
//                                             Column(
//                                               crossAxisAlignment:
//                                                   CrossAxisAlignment
//                                                       .start,
//                                               children: [
//                                                 Row(
//                                                   children: [
//                                                     SizedBox(
//                                                       width:
//                                                           50,
//                                                       child: Text(
//                                                         style: TextStyle(
//                                                           fontSize:
//                                                               theme.mobileTexts.b4.fontSize,
//                                                           fontWeight:
//                                                               FontWeight.normal,
//                                                           // color:
//                                                           //     Colors
//                                                           //         .green,
//                                                         ),
//                                                         'Amount:',
//                                                       ),
//                                                     ),
//                                                     Text(
//                                                       style: TextStyle(
//                                                         fontSize:
//                                                             theme.mobileTexts.b4.fontSize,
//                                                         fontWeight:
//                                                             FontWeight.bold,
//                                                         // color:
//                                                         //     Colors
//                                                         //         .green,
//                                                       ),
//                                                       formatMoneyMid(
//                                                         amount: returnReceiptProviderSingle().getTotalMainRevenueReceipt(
//                                                           receipt,
//                                                         ),
//                                                         context:
//                                                             context,
//                                                       ),
//                                                     ),
//                                                   ],
//                                                 ),
//                                                 Row(
//                                                   children: [
//                                                     SizedBox(
//                                                       width:
//                                                           50,
//                                                       child: Text(
//                                                         style: TextStyle(
//                                                           fontSize:
//                                                               theme.mobileTexts.b4.fontSize,
//                                                           fontWeight:
//                                                               FontWeight.normal,
//                                                           // color:
//                                                           //     Colors
//                                                           //         .green,
//                                                         ),
//                                                         'Paid:',
//                                                       ),
//                                                     ),
//                                                     Text(
//                                                       style: TextStyle(
//                                                         fontSize:
//                                                             theme.mobileTexts.b4.fontSize,
//                                                         fontWeight:
//                                                             FontWeight.bold,
//                                                         // color:
//                                                         //     Colors
//                                                         //         .green,
//                                                       ),
//                                                       // formatMoneyMid(
//                                                       //   amount: returnReceiptProviderSingle().(
//                                                       //     receipt:
//                                                       //         receipt,
//                                                       //   ),
//                                                       //   context:
//                                                       //       context,
//                                                       // ),
//                                                       '0000',
//                                                     ),
//                                                   ],
//                                                 ),
//                                                 Row(
//                                                   children: [
//                                                     SizedBox(
//                                                       width:
//                                                           50,
//                                                       child: Text(
//                                                         style: TextStyle(
//                                                           fontSize:
//                                                               theme.mobileTexts.b4.fontSize,
//                                                           fontWeight:
//                                                               FontWeight.normal,
//                                                           // color:
//                                                           //     Colors
//                                                           //         .green,
//                                                         ),
//                                                         'Balance:',
//                                                       ),
//                                                     ),
//                                                     Text(
//                                                       style: TextStyle(
//                                                         fontSize:
//                                                             theme.mobileTexts.b4.fontSize,
//                                                         fontWeight:
//                                                             FontWeight.bold,
//                                                         // color:
//                                                         //     Colors
//                                                         //         .green,
//                                                       ),
//                                                       // formatMoneyMid(
//                                                       //   amount: returnReceiptProviderSingle().getBalance(
//                                                       //     receipt:
//                                                       //         receipt,
//                                                       //   ),
//                                                       //   context:
//                                                       //       context,
//                                                       // ),
//                                                       '0000',
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ],
//                                             ),
//                                             Container(
//                                               padding:
//                                                   EdgeInsets.symmetric(
//                                                     vertical:
//                                                         3,
//                                                     horizontal:
//                                                         10,
//                                                   ),
//                                               decoration: BoxDecoration(
//                                                 borderRadius:
//                                                     BorderRadius.circular(
//                                                       3,
//                                                     ),
//                                                 border: Border.all(
//                                                   color:
//                                                       // returnReceiptProvider(
//                                                       //               context,
//                                                       //         ).getReceiptStatus(
//                                                       //           receipt:
//                                                       //               receipt,
//                                                       //         ) ==
//                                                       //         0
//                                                       //     ? Colors.red
//                                                       //     : returnReceiptProvider(
//                                                       //               context,
//                                                       //         ).getReceiptStatus(
//                                                       //           receipt:
//                                                       //               receipt,
//                                                       //         ) ==
//                                                       //         1
//                                                       //     ? const Color.fromARGB(
//                                                       //       255,
//                                                       //       255,
//                                                       //       223,
//                                                       //       126,
//                                                       //     )
//                                                       //     :
//                                                       Colors
//                                                           .green,
//                                                 ),
//                                               ),
//                                               child: Text(
//                                                 style: TextStyle(
//                                                   fontSize:
//                                                       theme
//                                                           .mobileTexts
//                                                           .b4
//                                                           .fontSize,
//                                                   fontWeight:
//                                                       FontWeight
//                                                           .bold,
//                                                   color:
//                                                       // returnReceiptProvider(context).getReceiptStatus(
//                                                       //           receipt:
//                                                       //               receipt,
//                                                       //         ) ==
//                                                       //         0
//                                                       //     ? Colors.red
//                                                       //     : returnReceiptProvider(
//                                                       //           context,
//                                                       //         ).getReceiptStatus(
//                                                       //           receipt:
//                                                       //               receipt,
//                                                       //         ) ==
//                                                       //         1
//                                                       //     ? const Color.fromARGB(
//                                                       //       255,
//                                                       //       245,
//                                                       //       185,
//                                                       //       6,
//                                                       //     )
//                                                       //     :
//                                                       Colors
//                                                           .green,
//                                                 ),
//                                                 // returnReceiptProvider(
//                                                 //           context,
//                                                 //         ).getReceiptStatus(
//                                                 //           receipt:
//                                                 //               receipt,
//                                                 //         ) ==
//                                                 //         0
//                                                 //     ? 'Unpaid'
//                                                 //     : returnReceiptProvider(
//                                                 //           context,
//                                                 //         ).getReceiptStatus(
//                                                 //           receipt:
//                                                 //               receipt,
//                                                 //         ) ==
//                                                 //         1
//                                                 //     ? 'Partial'
//                                                 //     :
//                                                 'Paid',
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                         SizedBox(
//                                           height: 10,
//                                         ),
//                                         Divider(
//                                           color:
//                                               Colors
//                                                   .grey
//                                                   .shade300,
//                                           height: 1,
//                                         ),
//                                         SizedBox(
//                                           height: 10,
//                                         ),
//                                         Column(
//                                           spacing: 7,
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment
//                                                   .start,
//                                           children: [
//                                             Row(
//                                               spacing: 10,
//                                               children: [
//                                                 Icon(
//                                                   size: 16,
//                                                   color:
//                                                       Colors
//                                                           .grey
//                                                           .shade600,
//                                                   Icons
//                                                       .person,
//                                                 ),
//                                                 Text(
//                                                   style: TextStyle(
//                                                     fontSize:
//                                                         theme.mobileTexts.b4.fontSize,
//                                                     fontWeight:
//                                                         FontWeight.bold,
//                                                   ),
//                                                   customer?.name ??
//                                                       'Name',
//                                                 ),
//                                               ],
//                                             ),
//                                             Row(
//                                               spacing: 10,
//                                               children: [
//                                                 Icon(
//                                                   size: 16,
//                                                   color:
//                                                       Colors
//                                                           .grey,
//                                                   Icons
//                                                       .phone,
//                                                 ),
//                                                 Text(
//                                                   style: TextStyle(
//                                                     fontSize:
//                                                         theme.mobileTexts.b4.fontSize,
//                                                     fontWeight:
//                                                         FontWeight.normal,
//                                                   ),
//                                                   customer?.phone ??
//                                                       'Phone Number',
//                                                 ),
//                                               ],
//                                             ),
//                                             Visibility(
//                                               visible:
//                                                   customer
//                                                       ?.email !=
//                                                   null,
//                                               child: Row(
//                                                 spacing: 10,
//                                                 children: [
//                                                   Icon(
//                                                     size:
//                                                         16,
//                                                     color:
//                                                         Colors.grey,
//                                                     Icons
//                                                         .email_outlined,
//                                                   ),
//                                                   Text(
//                                                     style: TextStyle(
//                                                       fontSize:
//                                                           theme.mobileTexts.b4.fontSize,
//                                                       fontWeight:
//                                                           FontWeight.normal,
//                                                     ),
//                                                     customer?.email ??
//                                                         'Email',
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                   SizedBox(height: 15),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(height: 30),
//               ],
//             ),
//           );
//         }
//       },
//     );
//   }

//   Future<dynamic> actionResultDialog({
//     required BuildContext context,
//     required String message,
//     required bool isSuccess,
//   }) async {
//     await showDialog(
//       barrierDismissible: false,
//       // ignore: use_build_context_synchronously
//       context: context,
//       builder: (dialogContext) {
//         Future.delayed(const Duration(seconds: 3), () {
//           if (dialogContext.mounted) {
//             if (Navigator.of(dialogContext).canPop()) {
//               Navigator.of(dialogContext).pop();
//             }
//           }
//         });

//         return AlertDialog(
//           backgroundColor: Colors.white,
//           content: Container(
//             height: 400,
//             width: 400,
//             color: Colors.white,
//             child: Builder(
//               builder: (context) {
//                 if (!isSuccess) {
//                   return returnCompProvider(
//                     context,
//                     listen: false,
//                   ).showError(message);
//                 } else {
//                   return returnCompProvider(
//                     context,
//                     listen: false,
//                   ).showSuccess(message);
//                 }
//               },
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// class ActionButtonSmall extends StatelessWidget {
//   final Function()? action;
//   final Color? textColor;
//   final String text;
//   final bool? isLoading;
//   const ActionButtonSmall({
//     super.key,
//     this.textColor,
//     required this.action,
//     required this.text,
//     this.isLoading,
//   });

//   @override
//   Widget build(BuildContext context) {
//     var theme = returnTheme(context);
//     return Material(
//       type: MaterialType.transparency,
//       child: InkWell(
//         onTap: action,
//         borderRadius: BorderRadius.circular(3),
//         child: Container(
//           padding: EdgeInsets.symmetric(
//             vertical: 5,
//             horizontal: 20,
//           ),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(3),
//             border: Border.all(
//               color: textColor ?? Colors.grey.shade200,
//             ),
//           ),
//           child: Builder(
//             builder: (context) {
//               if (isLoading != null && isLoading == true) {
//                 return Padding(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 10.0,
//                   ),
//                   child: SizedBox(
//                     width: 15,
//                     height: 15,
//                     child: CircularProgressIndicator(
//                       color:
//                           theme.lightModeColor.secColor200,
//                       strokeWidth: 2.5,
//                     ),
//                   ),
//                 );
//               } else {
//                 return Text(
//                   style: TextStyle(
//                     fontSize: theme.mobileTexts.b3.fontSize,
//                     fontWeight: FontWeight.bold,
//                     color: textColor,
//                   ),
//                   text,
//                 );
//               }
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }
