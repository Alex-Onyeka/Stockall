import 'dart:async';

import 'package:flutter/material.dart';
import 'package:stockall/pages/authentication/auth_landing/auth_landing.dart';
import 'package:stockall/services/auth_service.dart';

class TimerProvider extends ChangeNotifier {
  int time = 240;
  Timer? _timer;
  // bool isExpired = false;
  void cancelTimer() {
    _timer?.cancel();
  }

  void startCountDownTimer(BuildContext context) {
    time = 240;
    notifyListeners();
    _timer = Timer.periodic(Duration(seconds: 1), (
      timer,
    ) async {
      if (time > 0) {
        time--;
        notifyListeners();
      } else {
        timer.cancel();
        // isExpired = true;
        await Future.delayed(Duration(seconds: 2));
        await AuthService().signOut();
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) {
                return AuthLanding();
              },
            ),
          );
        }
      }
    });
  }
}
