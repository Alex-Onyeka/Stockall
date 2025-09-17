import 'dart:async';

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

  void checkConnection(int number) {
    if (number > 0) {
      isConnected = true;
    } else {
      isConnected = false;
    }
    notifyListeners();
  }

  String connectedText() {
    notifyListeners();
    return isConnected ? 'Connected' : 'Not Connected';
  }

  Color connectedColor() {
    notifyListeners();
    return isConnected ? Colors.green : Colors.amber;
  }

  void init() {
    subscription = connectivityStream.listen((value) async {
      print(
        'Length of Connected Networks: ${value.length}',
      );
      checkConnection(value.length);
      print(isConnected.toString());
      notifyListeners();
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

  Future<bool> isOnline() async {
    final results = await _connectivity.checkConnectivity();
    print('Connectivity results: $results');
    return results.any(
      (result) =>
          result != ConnectivityResult.none &&
          result != ConnectivityResult.bluetooth &&
          result != ConnectivityResult.other &&
          result != ConnectivityResult.vpn,
    );
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }
}
