import 'package:hive/hive.dart';
import 'package:stockall/classes/user_class/temp_user_class.dart';
import 'package:stockall/local_database/hive_box_helper.dart';
import 'package:stockall/main.dart';

class UserFunc {
  static final UserFunc instance = UserFunc._internal();
  factory UserFunc() => instance;
  UserFunc._internal();
  late Box<TempUserClass> userBox;
  final String userBoxName = 'userBoxStockall';

  Future<void> init() async {
    safeRegisterAdapter(TempUserClassAdapter());
    userBox = await openBoxSafely<TempUserClass>(
      userBoxName,
    );
    await mainLocalLog('User Box Initialized');
  }

  List<TempUserClass> getUsers() {
    try {
      List<TempUserClass> users = userBox.values.toList();
      return users;
    } catch (e, s) {
      mainLocalLog(
        'Error reading users: $e',
        error: e,
        stackTrace: s,
      );
      return [];
    }
  }

  TempUserClass? getUser(String userId) {
    try {
      return userBox.values.isNotEmpty
          ? userBox.values.firstWhere(
            (user) => user.userId == userId,
          )
          : null;
    } catch (e, s) {
      mainLocalLog(
        'Error reading single user: $e',
        error: e,
        stackTrace: s,
      );
      return null;
    }
  }

  TempUserClass? getUserByEmailandPassword(
    String userId,
    String email,
  ) {
    try {
      if (userBox.values.isNotEmpty) {
        if (userBox.values
            .where(
              (user) =>
                  user.userId == userId &&
                  user.email == email,
            )
            .isNotEmpty) {
          return userBox.values
              .where(
                (user) =>
                    user.userId == userId &&
                    user.email == email,
              )
              .first;
        } else {
          return null;
        }
      } else {
        return null;
      }
    } catch (e, s) {
      mainLocalLog(
        'Error reading user by email/password: $e',
        error: e,
        stackTrace: s,
      );
      return null;
    }
  }

  TempUserClass? offlineLoginByEmailandPassword(
    String password,
    String email,
  ) {
    // await mainLocalLog(userBox.values.length);
    if (userBox.values.isNotEmpty) {
      if (userBox.values
          .where(
            (user) =>
                user.password == password &&
                user.email == email,
          )
          .isNotEmpty) {
        return userBox.values
            .where(
              (user) =>
                  user.password == password &&
                  user.email == email,
            )
            .first;
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  Future<int> insertAllUsers(
    List<TempUserClass> users,
  ) async {
    await clearUsers();
    try {
      for (var user in users) {
        await userBox.put(user.userId, user);
      }
      await mainLocalLog('All Users Insert Success');
      return 1;
    } catch (e) {
      await mainLocalLog('Failed: ${e.toString()}');
      return 0;
    }
  }

  Future<int> insertUser(TempUserClass user) async {
    try {
      await userBox.put(user.userId, user);
      await mainLocalLog('User inserted Success');
      return 1;
    } catch (e) {
      await mainLocalLog(
        '❌❌ Insert User Offline Error: ${e.toString()}',
      );
      return 0;
    }
  }

  Future clearUsers() async {
    await userBox.clear();
    await mainLocalLog('Offline Users Cleared');
  }
}
