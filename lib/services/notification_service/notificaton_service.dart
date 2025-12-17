// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// class NotificationService {
//   static final FlutterLocalNotificationsPlugin _plugin =
//       FlutterLocalNotificationsPlugin();

//   static Future<void> initialize() async {
//     // ANDROID
//     const AndroidInitializationSettings androidSettings =
//         AndroidInitializationSettings(
//           '@mipmap/ic_launcher',
//         );

//     // iOS
//     const DarwinInitializationSettings iosSettings =
//         DarwinInitializationSettings(
//           requestAlertPermission: true,
//           requestBadgePermission: true,
//           requestSoundPermission: true,
//         );

//     // WINDOWS
//     const WindowsInitializationSettings windowsSettings =
//         WindowsInitializationSettings(
//           appName: 'Stockall',
//           appUserModelId: 'com.stockallsolutions.stockall',
//           guid: '{14f3270b-4200-47fa-8cb9-4e176ebebec8}',
//           iconPath: 'assets/images/logos/fav_icon.png',
//         );

//     // COMBINED
//     const InitializationSettings settings =
//         InitializationSettings(
//           android: androidSettings,
//           iOS: iosSettings,
//           windows: windowsSettings,
//         );

//     await _plugin.initialize(
//       settings,
//       onDidReceiveNotificationResponse: (
//         NotificationResponse response,
//       ) {
//         print("ACTION PRESSED: ${response.actionId}");
//       },
//     );

//     final windows = WindowsNotificationDetails();

//     final notificationDetails = NotificationDetails(
//       windows: windows,
//     );

//     await _plugin.show(
//       10,
//       "Windows Notification",
//       "This works fine",
//       notificationDetails,
//     );
//   }
// }
