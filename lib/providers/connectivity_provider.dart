import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:stockall/main.dart';

class ConnectivityProvider extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>>
  subscription;

  ConnectivityProvider() {
    init();
  }

  bool isConnected = false;
  // Future<void> toggleOnline() async {
  //   print('Trying to Check Connection');
  //   isConnected = await isOnline();
  //   print('Done Checking Connection: $isConnected');
  //   notifyListeners();
  // }

  void checkConnection(
    BuildContext context,
    bool value,
  ) async {
    isConnected = value;
    print('Connection is Now $value');
    await returnNavProvider(
      context,
      listen: false,
    ).validate(context);
    notifyListeners();
  }

  // Future<void> testBitch() async {
  //   print('Before three Seconds');
  //   Future.delayed(Duration(seconds: 3), () {
  //     print('After three Seconds');
  //   });
  // }

  String connectedText() {
    return isConnected ? 'Connected' : 'Not Connected';
  }

  Color connectedColor() {
    return isConnected ? Colors.green : Colors.grey;
  }

  // void init() {
  //   subscription = connectivityStream.listen((value) async {
  //     print(
  //       'Length of Connected Networks: ${value.length}',
  //     );
  //     checkConnection(value.length);
  //     print(isConnected.toString());
  //     notifyListeners();
  //   });
  // }

  // void checkShop() async {
  //   final userShop = await shopProvider.getUserShop(
  //     AuthService().currentUser!,
  //   );
  //   if (userShop == null) {
  //     // ignore: use_build_context_synchronously
  //     NavProvider().nullShop();
  //     return;
  //   }
  // }

  void init() {
    bool hasRun = false;

    subscription = connectivityStream.listen((value) async {
      final isNowConnected = value.isNotEmpty;

      if (isNowConnected && !hasRun) {
        hasRun = true;
        isConnected = true;

        notifyListeners();
      } else if (!isNowConnected) {
        hasRun =
            false; // Reset so it can run again on next reconnection
        isConnected = false;
        notifyListeners();
      }

      print('Connected: $isConnected');
    });
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

  Future<bool> isOnline(BuildContext context) async {
    final results = await _connectivity.checkConnectivity();
    print('Connectivity results: $results');
    bool anything = results.any(
      (result) =>
          result != ConnectivityResult.none &&
          result != ConnectivityResult.bluetooth &&
          result != ConnectivityResult.other &&
          result != ConnectivityResult.vpn,
    );
    checkConnection(context, anything);
    // if (anything) {
    //   var auth = AuthService();
    //   User? user = auth.currentUserAuth;
    //   TempUserClass? userClass = auth.currentUserOffline;
    //   if (user == null && userClass != null) {
    //     await auth.signIn(
    //       userClass.email,
    //       userClass.password,
    //     );
    //   }
    //   print(user?.email);
    // }
    return anything;
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }
}
