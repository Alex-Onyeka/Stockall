// import 'package:flutter/material.dart';
// import 'package:stockall/classes/temp_notification/temp_notification.dart';
// import 'package:stockall/constants/constants_main.dart';
// import 'package:stockall/pages/notifications/general_notif/platforms/general_notif_desktop.dart';
// import 'package:stockall/pages/notifications/general_notif/platforms/general_notif_mobile.dart';

// class GeneralNotif extends StatelessWidget {
//   final TempNotification notification;
//   const GeneralNotif({
//     super.key,
//     required this.notification,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         if (constraints.maxWidth < mobileScreen) {
//           return GeneralNotifMobile(
//             notification: notification,
//           );
//         } else {
//           return GeneralNotifDesktop(
//             notification: notification,
//           );
//         }
//       },
//     );
//   }
// }
