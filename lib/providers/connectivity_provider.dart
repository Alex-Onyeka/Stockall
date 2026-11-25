import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:stockall/main.dart';

class ConnectivityProvider extends ChangeNotifier {
  static final ConnectivityProvider _instance =
      ConnectivityProvider._internal();
  factory ConnectivityProvider() => _instance;
  ConnectivityProvider._internal() {
    init();
  }

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  Timer? _fallbackPollTimer;
  Future<bool>? _inFlightCheck;
  DateTime? _lastCheckedAt;

  bool isConnected = false;

  static bool _hasValidConnection(
    List<ConnectivityResult> results,
  ) {
    return results.any(
      (result) =>
          result != ConnectivityResult.none &&
          result != ConnectivityResult.bluetooth &&
          result != ConnectivityResult.other,
    );
  }

  static Future<bool> _hasInternetReachability() async {
    if (kIsWeb) return false;
    try {
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 2));
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  void _updateConnection(bool value) {
    _lastCheckedAt = DateTime.now();
    if (isConnected == value) return;
    isConnected = value;
    mainLocalLog('Connection is Now $value');
    notifyListeners();
  }

  void checkConnection(bool value) {
    _updateConnection(value);
  }

  String connectedText() {
    return isConnected ? 'Online' : 'Offline';
  }

  Color connectedColor() {
    return isConnected ? Colors.green : Colors.grey;
  }

  void _startFallbackPolling() {
    if (_fallbackPollTimer?.isActive ?? false) return;
    _fallbackPollTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => unawaited(isOnlineAction()),
    );
  }

  void _stopFallbackPolling() {
    _fallbackPollTimer?.cancel();
    _fallbackPollTimer = null;
  }

  void init() {
    _subscription?.cancel();
    _stopFallbackPolling();
    try {
      _subscription = connectivityStream.listen(
        (value) async {
          _stopFallbackPolling();
          final isNowConnected = value.isNotEmpty;
          if (isNowConnected) {
            _updateConnection(true);
            await mainLocalLog('Connected: $isConnected');
          } else {
            // Verify with actual reachability before marking offline, since
            // connectivity_plus on Windows can spuriously emit [none].
            await isOnlineAction();
          }
        },
        onError: (Object error, StackTrace stackTrace) {
          // On Windows, hot/debug restarts can cause connectivity_plus's
          // native EventChannel (NetworkManager::StartListen) to throw
          // PlatformException because the previous listener wasn't torn down.
          // Fall back to periodic checkConnectivity() polling so connectivity
          // keeps working without restarting the app.
          mainLocalLog(
            'Connectivity stream error (using fallback polling): $error',
          );
          _startFallbackPolling();
          unawaited(isOnlineAction());
        },
      );
    } catch (e) {
      mainLocalLog('Connectivity init error: $e');
      _startFallbackPolling();
    }
    // Check initial connectivity immediately so we don't stay stuck at false
    // if onConnectivityChanged doesn't emit an initial event (e.g. on Windows
    // or after a hot/debug restart).
    unawaited(isOnlineAction());
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
                      result != ConnectivityResult.other,
                )
                .toList(),
      )
      .distinct((prev, next) {
        // Prevent duplicates when the same state repeats
        return prev.toString() == next.toString();
      });

  Future<bool> isOnline() async {
    if (isConnected &&
        _lastCheckedAt != null &&
        DateTime.now().difference(_lastCheckedAt!) <
            const Duration(seconds: 2)) {
      return true;
    }
    return isOnlineAction();
  }

  Future<bool> isOnlineAction() async {
    if (_inFlightCheck != null) {
      return _inFlightCheck!;
    }
    final completer = Completer<bool>();
    _inFlightCheck = completer.future;
    try {
      final results = await _connectivity.checkConnectivity();
      await mainLocalLog('Connectivity results: $results');
      var anything = _hasValidConnection(results);
      if (!anything) {
        // connectivity_plus on Windows can spuriously return [none] even when
        // the system is online; verify actual reachability before going offline.
        anything = await _hasInternetReachability();
      }
      _updateConnection(anything);
      completer.complete(anything);
      return anything;
    } catch (e) {
      await mainLocalLog('Connectivity check error: $e');
      completer.complete(isConnected);
      return isConnected;
    } finally {
      _inFlightCheck = null;
    }
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
