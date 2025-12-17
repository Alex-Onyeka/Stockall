import 'dart:async';
// import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityProvider extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>>
  subscription;

  ConnectivityProvider() {
    init();
  }

  bool isConnected = false;

  void checkConnection(bool value) async {
    isConnected = value;
    print('Connection is Now $value');
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

      print('Connected: $isConnected');
    });
    // } else {
    //   // Fallback for Windows
    isOnline();
    // }
  }

  Stream<List<ConnectivityResult>>
  get connectivityStream => _connectivity
      .onConnectivityChanged
      .map(
        (results) =>
            results
                .where(
                  (result) =>
                      result != ConnectivityResult.none &&
                      result !=
                          ConnectivityResult.bluetooth &&
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
    final results = await _connectivity.checkConnectivity();
    print('Connectivity results: $results');
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
//             print('Connection is Now $connected');
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
