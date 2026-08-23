import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/alt_display/alt_display.dart';

class MultiDisplayProvider extends ChangeNotifier {
  static final MultiDisplayProvider _instance =
      MultiDisplayProvider._internal();
  factory MultiDisplayProvider() => _instance;
  MultiDisplayProvider._internal();

  Future<bool> isAllowed() async {
    // if (returnShopProvider().isDesktop() &&
    //     currentUser().role != 'Store Keeper') {
    //   var screen = await getAltDisplay();
    //   if (screen == null) {
    //     return false;
    //   }
    //   for (var win in windows) {
    //     await win.controller.setFrame(
    //       screen.visiblePosition! & screen.visibleSize!,
    //     );
    //   }
    //   return true;
    // } else {
    return false;
    // }
  }

  List<WindowInfo> windows = [];

  void deleteWindow(String cartId) {
    windows.removeWhere((win) => win.id == cartId);
    notifyListeners();
  }

  List<int> displayIds = [];

  Future<void> getAllSubWindows() async {
    var yes = await isAllowed();
    if (yes) {
      displayIds =
          await DesktopMultiWindow.getAllSubWindowIds();
      notifyListeners();
    }
  }

  Display? altDisplay;
  Future<Display?> getAltDisplay() async {
    bool yes = await isAllowed();
    if (yes) {
      var displays = await screenRetriever.getAllDisplays();
      if (displays.length > 1) {
        altDisplay = displays[1];
        notifyListeners();
        return displays[1];
      } else {
        altDisplay = null;
        notifyListeners();
        return null;
      }
    } else {
      return null;
    }
  }

  bool checkIfWindowExists(String cartId) {
    if (returnShopProvider().isDesktop()) {
      try {
        var displayId =
            windows
                    .where((win) => win.id == cartId)
                    .isNotEmpty
                ? windows
                    .firstWhere((win) => win.id == cartId)
                    .controller
                    .windowId
                : [];
        return displayIds.contains(displayId);
      } catch (e) {
        mainLocalLog(
          'Error Occured Checking if Window Exists: ${e.toString()}',
        );
        return true;
      }
    } else {
      return true;
    }
  }

  Future<void> createWindow({
    required String cartId,
    int? newCartIndex,
  }) async {
    var yes = await isAllowed();
    if (yes) {
      try {
        final name =
            'Cart ${newCartIndex ?? windows.length + 1}';
        final windowConfig = {
          'name': name,
          'type': 'alt',
          'cart_id': cartId,
        };
        final windowController =
            await DesktopMultiWindow.createWindow(
              jsonEncode(windowConfig),
            );

        windowController
          ..setFrame(
            Offset(
                  altDisplay!.visiblePosition!.dx - 10,
                  altDisplay!.visiblePosition!.dy - 25,
                ) &
                Size(
                  altDisplay!.visibleSize!.width + 20,
                  altDisplay!.visibleSize!.height + 35,
                ),
          )
          ..setTitle(name)
          ..show();

        windows.add(
          WindowInfo(
            id: cartId,
            name: name,
            controller: windowController,
          ),
        );
        notifyListeners();
        for (var win in windows.where(
          (win) =>
              win.controller.windowId !=
              windowController.windowId,
        )) {
          await win.controller.hide();
        }
      } catch (e) {
        await mainLocalLog(
          'Failed to Create Window: ${e.toString()}',
        );
      }
    }
    await getAllSubWindows();
  }

  Future<void> updateWindow({
    required AltCartClass cartClass,
    bool? showCart,
  }) async {
    var yes = await isAllowed();
    if (yes) {
      int? windowId =
          windows
                  .where(
                    (win) => win.id == cartClass.cartId,
                  )
                  .toList()
                  .isNotEmpty
              ? windows
                  .where(
                    (win) => win.id == cartClass.cartId,
                  )
                  .toList()
                  .first
                  .controller
                  .windowId
              : null;
      if (windowId != null) {
        try {
          if (showCart == null) {
            await DesktopMultiWindow.invokeMethod(
              windowId,
              'update_cart',
              jsonEncode(cartClass.toJson()),
            );
          } else {
            await DesktopMultiWindow.invokeMethod(
              windowId,
              'show_cart',
              jsonEncode(cartClass.toJson()),
            );
          }
        } catch (e) {
          await mainLocalLog(
            'Error Updating Cart: ${e.toString()}',
          );
        }
      } else {
        await mainLocalLog(
          'Error: Window Id does not exists',
        );
      }
    }
  }

  Future<void> selectWindow({
    required String cartId,
    int? cartIndex,
    required AltCartClass cartClass,
  }) async {
    var yes = await isAllowed();
    await getAllSubWindows();
    // await mainLocalLog(cartId);
    // await mainLocalLog(cartIndex);
    if (yes) {
      var selWins = windows.where(
        (win) => win.id == cartId,
      );
      if (selWins.isEmpty) {
        await returnSalesProvider().createWindow();
      } else {
        var selWin = selWins.first;
        if (cartIndex !=
            int.parse(selWin.name.split(' ').last)) {
          await selWin.controller.setTitle(
            'Cart $cartIndex',
          );
          selWin.name = 'Cart $cartIndex';
          await mainLocalLog(
            'Updated Window Name and Title Numbers to $cartIndex',
          );
        }
        await updateWindow(
          cartClass: cartClass,
          // showCart: true,
        );
        await selWin.controller.setFrame(
          Offset(
                altDisplay!.visiblePosition!.dx - 10,
                altDisplay!.visiblePosition!.dy - 25,
              ) &
              Size(
                altDisplay!.visibleSize!.width + 20,
                altDisplay!.visibleSize!.height + 35,
              ),
        );
        await selWin.controller.show();

        for (var win in windows.where(
          (win) =>
              win.controller.windowId !=
              selWin.controller.windowId,
        )) {
          await win.controller.hide();
        }

        notifyListeners();
      }
    }
  }

  Future<void> closeWindow({required String cartId}) async {
    var yes = await isAllowed();
    await getAllSubWindows();
    if (yes) {
      await mainLocalLog(windows.length.toString());
      await windows
          .where((win) => win.id == cartId)
          .first
          .controller
          .close();
      windows.removeWhere((win) => win.id == cartId);
      notifyListeners();
    }
  }
}

class WindowInfo {
  final String id;
  String name;
  WindowController controller;

  WindowInfo({
    required this.id,
    required this.name,
    required this.controller,
  });
}

class UserClass {
  String name;
  String email;
  String phoneNumber;

  UserClass({
    required this.name,
    required this.email,
    required this.phoneNumber,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'phoneNumber': phoneNumber,
  };

  // Create from JSON
  factory UserClass.fromJson(Map<String, dynamic> json) {
    return UserClass(
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
    );
  }
}
