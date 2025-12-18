// import 'package:flutter/material.dart';
// import 'package:stockall/classes/temp_notification/temp_notification.dart';
// import 'package:stockall/constants/app_bar.dart';
// import 'package:stockall/constants/constants_main.dart';
// import 'package:stockall/main.dart';

// class GeneralNotifDesktop extends StatelessWidget {
//   final TempNotification notification;
//   const GeneralNotifDesktop({
//     super.key,
//     required this.notification,
//   });

//   @override
//   Widget build(BuildContext context) {
//     var theme = returnTheme(context);
//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           image: DecorationImage(
//             image: AssetImage(backGroundImage),
//             fit: BoxFit.cover,
//           ),
//         ),
//         child: Stack(
//           children: [
//             Container(
//               color: const Color.fromARGB(
//                 201,
//                 255,
//                 255,
//                 255,
//               ),
//             ),
//             Center(
//               child: SingleChildScrollView(
//                 child: Column(
//                   mainAxisAlignment:
//                       MainAxisAlignment.center,
//                   children: [
//                     Center(
//                       child: Container(
//                         margin: EdgeInsets.symmetric(
//                           vertical: 40,
//                         ),
//                         height: 550,
//                         width: 550,
//                         padding: EdgeInsets.symmetric(
//                           horizontal: 50,
//                           vertical: 30,
//                         ),
//                         decoration: BoxDecoration(
//                           borderRadius:
//                               BorderRadius.circular(20),
//                           color: Colors.white,
//                           boxShadow: [
//                             BoxShadow(
//                               color: const Color.fromARGB(
//                                 46,
//                                 0,
//                                 0,
//                                 0,
//                               ),
//                               blurRadius: 10,
//                               spreadRadius: 5,
//                               offset: Offset(0, 0),
//                             ),
//                           ],
//                         ),
//                         child: Column(
//                           mainAxisAlignment:
//                               MainAxisAlignment.start,
//                           children: [
//                             appBar(
//                               context: context,
//                               title: 'title',
//                             ),
//                             Padding(
//                               padding:
//                                   const EdgeInsets.symmetric(
//                                     horizontal: 50.0,
//                                   ),
//                               child: Column(
//                                 children: [
//                                   Text(
//                                     textAlign:
//                                         TextAlign.center,
//                                     'Enter Code Below',
//                                     style: TextStyle(
//                                       color:
//                                           theme
//                                               .lightModeColor
//                                               .prColor300,
//                                       fontSize:
//                                           theme
//                                               .mobileTexts
//                                               .h2
//                                               .fontSize,
//                                       fontWeight:
//                                           FontWeight.bold,
//                                     ),
//                                   ),
//                                   SizedBox(height: 20),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
