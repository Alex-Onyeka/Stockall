import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';
import 'package:stockitt/constants/constants_main.dart';
import 'package:stockitt/providers/theme_provider.dart';

class CompProvider extends ChangeNotifier {
  ThemeProvider themeProvider = ThemeProvider();

  bool isLoaderOn = false;

  void successAction(Function action) {
    isLoaderOn = true;
    notifyListeners();

    Future.delayed(Duration(seconds: 3), () {
      isLoaderOn = false;
      notifyListeners();
      action();
    });
  }

  Widget showLoader(String message) {
    return Container(
      color: const Color.fromARGB(245, 255, 255, 255),
      child: Center(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment(0, -0.1),
                    child: SizedBox(
                      width: 180,
                      child: Lottie.asset(mainLoader),
                    ),
                  ),
                  Align(
                    alignment: Alignment(0, 0.1),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 50.0,
                      ),
                      child: Text(
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color:
                              themeProvider
                                  .lightModeColor
                                  .prColor300,
                          fontSize:
                              themeProvider
                                  .mobileTexts
                                  .h2
                                  .fontSize,
                          fontWeight:
                              themeProvider
                                  .mobileTexts
                                  .h2
                                  .fontWeightBold,
                        ),
                        message,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget showSuccess(String message) {
    return Container(
      color: const Color.fromARGB(251, 255, 255, 255),
      child: Center(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment(0, -0.2),
                    child: SizedBox(
                      width: 180,
                      child: Lottie.asset(successAnim),
                    ),
                  ),
                  Align(
                    alignment: Alignment(0, 0.2),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 50.0,
                      ),
                      child: Text(
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color:
                              themeProvider
                                  .lightModeColor
                                  .prColor300,
                          fontSize:
                              themeProvider
                                  .mobileTexts
                                  .h2
                                  .fontSize,
                          fontWeight:
                              themeProvider
                                  .mobileTexts
                                  .h2
                                  .fontWeightBold,
                        ),
                        message,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
