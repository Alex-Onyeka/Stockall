import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:stockall/classes/temp_user_class.dart';
import 'package:stockall/services/auth_service.dart';

class LocalUserDatabase extends ChangeNotifier {
  static final LocalUserDatabase _instance =
      LocalUserDatabase._internal();

  factory LocalUserDatabase() => _instance;

  LocalUserDatabase._internal();

  static const String _userBoxName = 'usersBox';
  static const String _visibilityBoxName = 'visibilityBox';
  static const String _visibilityKey = 'isDataVisible';

  Box<TempUserClass>? _userBox;
  Box<bool>? _visibilityBox;

  /// Initialize Hive and open user and visibility boxes
  Future<void> init() async {
    await Hive.initFlutter();

    // Register adapter (if not already done outside)
    // if (!Hive.isAdapterRegistered(0)) {
    //   Hive.registerAdapter(TempUserClassAdapter());
    // }

    _userBox ??= await Hive.openBox<TempUserClass>(
      _userBoxName,
    );
    _visibilityBox ??= await Hive.openBox<bool>(
      _visibilityBoxName,
    );

    // Set default value for visibility if not set
    if (!_visibilityBox!.containsKey(_visibilityKey)) {
      await _visibilityBox!.put(_visibilityKey, true);
    }

    print("✅ Hive boxes opened");
  }

  // ------------------- Visibility Methods -------------------
  Future<void> setDataVisibility(bool value) async {
    if (_visibilityBox == null) await init();
    await _visibilityBox!.put(_visibilityKey, value);
    notifyListeners();
  }

  Future<bool> getDataVisibility() async {
    if (_visibilityBox == null) await init();
    return _visibilityBox!.get(
      _visibilityKey,
      defaultValue: true,
    )!;
  }

  Future<void> toggleDataVisibility() async {
    final current = await getDataVisibility();
    await setDataVisibility(!current);
  }

  // ------------------- User CRUD -------------------

  /// Add or update a user (upsert)
  Future<void> upsertUser(TempUserClass user) async {
    if (_userBox == null) await init();
    if (user.userId == null) {
      throw Exception(
        "User must have a userId to be saved.",
      );
    }
    await _userBox!.put(user.userId, user);
    notifyListeners();
  }

  /// Get user by ID
  TempUserClass? getUserById() {
    return _userBox?.get(AuthService().currentUser!.id);
  }

  /// Get all users
  List<TempUserClass> getAllUsers() {
    if (_userBox == null) return [];
    return _userBox!.values.toList();
  }

  /// Delete user by ID
  Future<void> deleteUserById(String userId) async {
    if (_userBox == null) await init();
    await _userBox!.delete(userId);
    notifyListeners();
  }

  /// Delete all users
  Future<void> deleteAllUsers() async {
    if (_userBox == null) await init();
    await _userBox!.clear();
    notifyListeners();
  }

  /// Check if user exists
  bool userExists(String userId) {
    return _userBox?.containsKey(userId) ?? false;
  }
}
