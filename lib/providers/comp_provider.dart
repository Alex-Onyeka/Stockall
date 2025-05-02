import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';
import 'package:stockitt/constants/constants_main.dart';

class CompProvider extends ChangeNotifier {
  Widget loader = Container(
    color: const Color.fromARGB(228, 255, 255, 255),
    child: Center(
      child: SizedBox(
        width: 180,
        child: Lottie.asset(mainLoader),
      ),
    ),
  );
}
