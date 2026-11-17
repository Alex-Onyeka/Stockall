import 'dart:convert';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/alt_display/alt_display.dart';

class MultiDisplayProvider extends ChangeNotifier {
  static final MultiDisplayProvider _instance =
      MultiDisplayProvider._internal();
  factory MultiDisplayProvider() => _instance;
  MultiDisplayProvider._internal();

  WindowController? _activeController;
  List<WindowInfo> windows = [];
  List<int> displayIds = [];
  Display? altDisplay;

  Future<bool> isAllowed() async {
    if (returnShopProvider().isDesktop() &&
        currentUser().role != 'Store Keeper') {
      final screen = await getAltDisplay();
      return screen != null;
    }
    return false;
  }

  void deleteWindow(String cartId) {
    windows.removeWhere((win) => win.id == cartId);
    notifyListeners();
  }

  Future<void> getAllSubWindows() async {
    final yes = await isAllowed();
    if (!yes) return;
    final ids =
        await DesktopMultiWindow.getAllSubWindowIds();
    final changed =
        ids.length != displayIds.length ||
        !ids.every((id) => displayIds.contains(id));
    displayIds = ids;
    if (_activeController != null &&
        !displayIds.contains(_activeController!.windowId)) {
      _activeController = null;
      windows.clear();
    }
    if (changed) {
      notifyListeners();
    }
  }

  Future<Display?> getAltDisplay() async {
    final displays = await screenRetriever.getAllDisplays();
    final Display? next =
        displays.length > 1 ? displays[1] : null;
    final changed =
        altDisplay?.id != next?.id ||
        altDisplay?.size != next?.size;
    altDisplay = next;
    if (changed) {
      notifyListeners();
    }
    return next;
  }

  Rect _fullScreenFrame(Display display) {
    final pos = display.visiblePosition ?? Offset.zero;
    return pos & display.size;
  }

  bool checkIfWindowExists(String cartId) {
    if (!returnShopProvider().isDesktop()) return true;
    try {
      if (_activeController == null) return false;
      return displayIds.contains(
        _activeController!.windowId,
      );
    } catch (e) {
      mainLocalLog(
        'Error Occured Checking if Window Exists: ${e.toString()}',
      );
      return false;
    }
  }

  Future<void> createWindow({
    required String cartId,
    int? newCartIndex,
  }) async {
    final yes = await isAllowed();
    if (!yes || altDisplay == null) return;

    try {
      final name = 'Cart ${newCartIndex ?? 1}';
      displayIds =
          await DesktopMultiWindow.getAllSubWindowIds();

      if (_activeController != null &&
          displayIds.contains(
            _activeController!.windowId,
          )) {
        await _activeController!.setFrame(
          _fullScreenFrame(altDisplay!),
        );
        await _activeController!.setTitle(name);
        await _activeController!.show();
        windows = [
          WindowInfo(
            id: cartId,
            name: name,
            controller: _activeController!,
          ),
        ];
        notifyListeners();
        return;
      }

      final windowConfig = {
        'name': name,
        'type': 'alt',
        'cart_id': cartId,
      };
      final windowController =
          await DesktopMultiWindow.createWindow(
            jsonEncode(windowConfig),
          );

      await windowController.setFrame(
        _fullScreenFrame(altDisplay!),
      );
      await windowController.setTitle(name);
      await windowController.show();

      _activeController = windowController;
      windows = [
        WindowInfo(
          id: cartId,
          name: name,
          controller: windowController,
        ),
      ];
      displayIds =
          await DesktopMultiWindow.getAllSubWindowIds();
      notifyListeners();
    } catch (e) {
      await mainLocalLog(
        'Failed to Create Window: ${e.toString()}',
      );
    }
  }

  Future<void> updateWindow({
    required AltCartClass cartClass,
    bool? showCart,
  }) async {
    final yes = await isAllowed();
    if (!yes) return;

    final windowId = _activeController?.windowId;
    if (windowId == null) {
      await mainLocalLog(
        'Error: Window Id does not exists',
      );
      return;
    }

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
          jsonEncode({
            'show_cart': showCart,
            'cart': cartClass.toJson(),
          }),
        );
      }
    } catch (e) {
      await mainLocalLog(
        'Error Updating Cart: ${e.toString()}',
      );
      displayIds =
          await DesktopMultiWindow.getAllSubWindowIds();
      if (!displayIds.contains(windowId)) {
        _activeController = null;
        windows.clear();
        notifyListeners();
      }
    }
  }

  Future<void> selectWindow({
    required String cartId,
    int? cartIndex,
    required AltCartClass cartClass,
  }) async {
    final yes = await isAllowed();
    if (!yes || altDisplay == null) return;

    await getAllSubWindows();
    if (_activeController == null ||
        !displayIds.contains(_activeController!.windowId)) {
      await createWindow(
        cartId: cartId,
        newCartIndex: cartIndex,
      );
    } else {
      final name = 'Cart ${cartIndex ?? 1}';
      if (windows.isEmpty) {
        windows = [
          WindowInfo(
            id: cartId,
            name: name,
            controller: _activeController!,
          ),
        ];
      } else {
        windows.first = WindowInfo(
          id: cartId,
          name: name,
          controller: _activeController!,
        );
      }
      try {
        await _activeController!.setTitle(name);
        await _activeController!.setFrame(
          _fullScreenFrame(altDisplay!),
        );
        await _activeController!.show();
      } catch (e) {
        await mainLocalLog(
          'Error selecting window: ${e.toString()}',
        );
      }
    }

    await updateWindow(cartClass: cartClass);
    notifyListeners();
  }

  Future<void> closeWindow({required String cartId}) async {
    final hasMatchingCart = windows.any(
      (win) => win.id == cartId,
    );
    if (!hasMatchingCart) return;
    await closeAllWindows();
  }

  Future<void> closeAllWindows() async {
    try {
      if (_activeController != null) {
        await _activeController!.close();
      }
    } catch (e) {
      await mainLocalLog(
        'Error Closing Window: ${e.toString()}',
      );
    }
    _activeController = null;
    windows.clear();
    try {
      if (returnShopProvider().isDesktop()) {
        displayIds =
            await DesktopMultiWindow.getAllSubWindowIds();
      } else {
        displayIds.clear();
      }
    } catch (_) {
      displayIds.clear();
    }
    notifyListeners();
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
