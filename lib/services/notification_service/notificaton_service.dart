// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/browser.dart';
// import 'package:timezone/data/latest.dart';

// class NotificatonService {
//   static final NotificatonService instance =
//       NotificatonService._internal();
//   factory NotificatonService() => instance;
//   NotificatonService._internal();

//   FlutterLocalNotificationsPlugin notificationsPlugin =
//       FlutterLocalNotificationsPlugin();
//   Future<void> init() async {
//     initializeTimeZones();

//     setLocalLocation(getLocation('Africa/Lagos'));

//     const androidSettings = AndroidInitializationSettings(
//       '@mipmap/ic_launcher',
//     );

//     const DarwinInitializationSettings iosSettings =
//         DarwinInitializationSettings();

//     const InitializationSettings initializationSettings =
//         InitializationSettings(
//           android: androidSettings,
//           iOS: iosSettings,
//         );

//     await notificationsPlugin.initialize(
//       initializationSettings,
//     );
//   }
// }
