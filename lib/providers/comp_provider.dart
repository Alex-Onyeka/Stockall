import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:stockall/components/buttons/main_button_transparent.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/local_database/visibility_box/visibility_box.dart';
import 'package:stockall/providers/theme_provider.dart';

class CompProvider extends ChangeNotifier {
  ThemeProvider themeProvider = ThemeProvider();

  bool isLoaderOn = false;

  bool isLoadingLoaderOn = false;

  bool newNotif = true;
  void turnOffLoader() {
    isLoaderOn = false;
    notifyListeners();
  }

  void switchNotif() {
    newNotif = !newNotif;
    notifyListeners();
  }

  void switchLoadingLoader() {
    isLoaderOn = !isLoaderOn;
    notifyListeners();
  }

  void switchLoader() {
    isLoaderOn = !isLoaderOn;
    notifyListeners();
  }

  void successAction(Function action) {
    isLoaderOn = true;
    notifyListeners();

    Future.delayed(Duration(milliseconds: 2500), () {
      action();
      isLoaderOn = false;
      notifyListeners();
    });
  }

  Widget showLoader({
    required String message,
    Function()? action,
  }) {
    return Material(
      child: Container(
        color: const Color.fromARGB(245, 255, 255, 255),
        child: Center(
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment(0, 0),
                      child: SizedBox(
                        width: 180,
                        child: Lottie.asset(
                          mainLoader.isEmpty
                              ? 'assets/animations/main_loader.json'
                              : mainLoader,
                          height: 80,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment(0, 0.1),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 60.0,
                        ),
                        child: Column(
                          children: [
                            Text(
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color:
                                    themeProvider
                                        .lightModeColor
                                        .prColor300,
                                fontSize:
                                    themeProvider
                                        .mobileTexts
                                        .h4
                                        .fontSize,
                                fontWeight:
                                    themeProvider
                                        .mobileTexts
                                        .h2
                                        .fontWeightBold,
                              ),
                              message,
                            ),
                            Visibility(
                              visible: action != null,
                              child: MainButtonTransparent(
                                themeProvider:
                                    themeProvider,
                                constraints:
                                    BoxConstraints(),
                                text: 'LogOut',
                                action: () async {
                                  await action!();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget showSuccess(String? message) {
    return Material(
      child: Container(
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
                        child: Lottie.asset(
                          successAnim.isEmpty
                              ? 'assets/animations/check_animation.json'
                              : successAnim,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment(0, 0.2),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 60.0,
                        ),
                        child: Text(
                          message ?? 'Success',
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
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //
  //
  //
  // T A B  B A R  W I D G E T
  int activeTab = 0;

  void swtichTab(int index) {
    activeTab = index;
    notifyListeners();
  }

  //
  //
  //
  //
  //
  //
  //
  //  Money Visibility
  bool isVisible = false;
  void setVisible() async {
    final visible =
        await VisibilityBox().getDataVisibility();
    if (visible) {
      isVisible = true;
    } else {
      isVisible = false;
    }
    notifyListeners();
  }

  String returnMoney(String money) {
    if (isVisible) {
      return money.toString();
    }
    {
      return '*****';
    }
  }

  void toggleVisible() async {
    await VisibilityBox().toggleDataVisibility();
    isVisible = !isVisible;
    notifyListeners();
  }
}
