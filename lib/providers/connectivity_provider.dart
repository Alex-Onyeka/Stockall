import 'dart:async';
// import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stockall/main.dart';
import 'package:stockall/services/remote/remote_client.dart';

class ConnectivityProvider extends ChangeNotifier {
  static final ConnectivityProvider _instance =
      ConnectivityProvider._internal();
  factory ConnectivityProvider() => _instance;
  ConnectivityProvider._internal() {
    // Listening needs the platform channels. Where there are none (a test
    // without the Flutter binding) that failure is logged instead of
    // failing whoever first touched this provider; any other error goes
    // on as it would have.
    runZonedGuarded(init, (e, s) {
      if (!isPlatformChannelFailure(e)) Error.throwWithStackTrace(e, s);
      unawaited(mainLocalLog('Connectivity not watched: $e'));
    });
    // A LAN route change (server found or lost) changes [isConnected].
    RemoteRouter.addListener(notifyListeners);
  }

  /// The connectivity plugin can't be reached: no plugin, a platform
  /// error, or no Flutter binding for its channel.
  @visibleForTesting
  static bool isPlatformChannelFailure(Object e) =>
      e is MissingPluginException ||
      e is PlatformException ||
      (e is FlutterError &&
          e.message.contains('Binding has not yet been initialized'));
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> subscription;

  // ConnectivityProvider() {
  //   init();
  // }

  /// Whether a network interface is up (what [isConnected] meant before
  /// LAN sync).
  bool interfaceUp = false;

  /// Whether this device can reach its backend: on the LAN, whether the
  /// shop's server answers; otherwise, whether an interface is up. Every
  /// "online" check in the app reads this, so on the LAN with the server
  /// down the app works offline and queues.
  bool get isConnected => RemoteRouter.reachable(interfaceUp);
  set isConnected(bool value) => interfaceUp = value;

  void checkConnection(bool value) async {
    isConnected = value;
    await mainLocalLog('Connection is Now $value');
    notifyListeners();
  }

  String connectedText() {
    return isConnected ? 'Online' : 'Offline';
  }

  Color connectedColor() {
    return isConnected ? Colors.green : Colors.grey;
  }

  void init() {
    // if (platforms(context) != TargetPlatform.windows) {
    bool hasRun = false;

    subscription = connectivityStream.listen((value) async {
      final isNowConnected = value.isNotEmpty;

      if (isNowConnected && !hasRun) {
        hasRun = true;
        isConnected = true;
        notifyListeners();
      } else if (!isNowConnected) {
        hasRun = false;
        isConnected = false;
        notifyListeners();
      }

      await mainLocalLog('Connected: $isConnected');
    });
    // } else {
    //   // Fallback for Windows
    // isOnline();
    // }
  }

  Stream<List<ConnectivityResult>> get connectivityStream => _connectivity
      .onConnectivityChanged
      .map(
        (results) =>
            results
                .where(
                  (result) =>
                      result != ConnectivityResult.none &&
                      result != ConnectivityResult.bluetooth &&
                      result != ConnectivityResult.other &&
                      result != ConnectivityResult.vpn,
                )
                .toList(),
      )
      .distinct((prev, next) {
        // Prevent duplicates when the same state repeats
        return prev.toString() == next.toString();
      });

  Future<bool> isOnline() async {
    // final results = await _connectivity.checkConnectivity();
    // await mainLocalLog('Connectivity results: $results');
    // bool anything = results.any(
    //   (result) =>
    //       result != ConnectivityResult.none &&
    //       result != ConnectivityResult.bluetooth &&
    //       result != ConnectivityResult.other &&
    //       result != ConnectivityResult.vpn,
    // );
    // checkConnection(anything);
    // return anything;
    return isConnected;
  }

  Future<bool> isOnlineAction() async {
    final results = await _connectivity.checkConnectivity();
    await mainLocalLog('Connectivity results: $results');
    bool anything = results.any(
      (result) =>
          result != ConnectivityResult.none &&
          result != ConnectivityResult.bluetooth &&
          result != ConnectivityResult.other &&
          result != ConnectivityResult.vpn,
    );
    checkConnection(anything);
    return anything;
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }
}

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:internet_connection_checker/internet_connection_checker.dart'
//     show
//         InternetConnectionStatus,
//         InternetConnectionChecker;
// // import 'package:internet_connection_checker/internet_connection_checker.dart';

// class ConnectivityProvider extends ChangeNotifier {
//   late StreamSubscription<InternetConnectionStatus>
//   subscription;
//   bool isConnected = false;

//   ConnectivityProvider() {
//     init();
//   }

//   void init() {
//     subscription = InternetConnectionChecker
//         .instance
//         .onStatusChange
//         .listen((status) {
//           final connected =
//               status == InternetConnectionStatus.connected;
//           if (connected != isConnected) {
//             isConnected = connected;
//             await mainLocalLog('Connection is Now $connected');
//             notifyListeners();
//           }
//         });
//   }

//   String connectedText() =>
//       isConnected ? 'Connected' : 'Not Connected';
//   Color connectedColor() =>
//       isConnected ? Colors.green : Colors.grey;

//   Future<bool> isOnline() async {
//     final connected =
//         await InternetConnectionChecker
//             .instance
//             .hasConnection;
//     isConnected = connected;
//     notifyListeners();
//     return connected;
//   }

//   @override
//   void dispose() {
//     subscription.cancel();
//     super.dispose();
//   }
// }
