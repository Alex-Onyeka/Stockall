// import 'package:flutter/material.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
// import 'package:storrec/classes/temp_user_class.dart';

// class LocalUserDatabase extends ChangeNotifier {
//   static final LocalUserDatabase _instance =
//       LocalUserDatabase._internal();

//   factory LocalUserDatabase() => _instance;

//   LocalUserDatabase._internal();

//   static Database? _database;

//   /// Ensure database is ready
//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDb();
//     return _database!;
//   }

//   double userTotalSale = 0;
//   void setUserTotalSale(double value) {
//     userTotalSale = value;
//     notifyListeners();
//   }

//   /// Initialize SQLite database
//   Future<Database> _initDb() async {
//     final dbPath = await getDatabasesPath();
//     final path = join(dbPath, 'user.db');

//     return await openDatabase(
//       path,
//       version: 1,
//       onCreate: (db, version) async {
//         await db.execute('''
//           CREATE TABLE user(
//             user_id TEXT PRIMARY KEY,
//             created_at TEXT,
//             name TEXT,
//             email TEXT,
//             phone TEXT,
//             role TEXT,
//             password TEXT,
//             auth_user_id TEXT
//           )
//         ''');
//         print("✅ Local DB created at $path");
//       },
//     );
//   }

//   /// Insert user record into local DB
//   Future<void> insertUser(TempUserClass user) async {
//     try {
//       final db = await database;

//       await db.insert('user', {
//         ...user.toJson(),
//         'created_at': user.createdAt?.toIso8601String(),
//         'auth_user_id': user.authUserId,
//       }, conflictAlgorithm: ConflictAlgorithm.replace);

//       currentEmployee = user; // ✅ Store user in memory
//       print("✅ User inserted locally: ${user.email}");
//       notifyListeners();
//     } catch (e) {
//       print("❌ Failed to insert user locally: $e");
//     }
//   }

//   TempUserClass? currentEmployee;

//   // TempUserClass(
//   //   password: 'myuzician',
//   //   name: 'Alex Onyeka',
//   //   email: 'alex@gmail.com',
//   //   role: 'Owner',
//   //   authUserId: '9e2686b0-edb0-4fc9-9b30-b5a8acc78cee',
//   //   userId: '9e2686b0-edb0-4fc9-9b30-b5a8acc78cee',
//   // );

//   List<TempUserClass> currentEmployees = [];

//   /// Get the first user (there should only be one)
//   Future<TempUserClass?> getUser() async {
//     try {
//       final db = await database;
//       final result = await db.query('user', limit: 1);

//       if (result.isNotEmpty) {
//         final user = TempUserClass.fromJson(result.first);
//         currentEmployee = user; // ✅ Store user in memory
//         print("✅ User fetched locally");
//         return user;
//       }

//       print("⚠️ No user found in local DB");
//       return null;
//     } catch (e) {
//       print("❌ Failed to fetch user locally: $e");
//       return null;
//     }
//   }

//   /// Delete all users (useful for logout)
//   Future<void> deleteUser() async {
//     try {
//       final db = await database;
//       await db.delete('user');
//       currentEmployee = null;
//       print("✅ Local user deleted");
//       notifyListeners();
//     } catch (e) {
//       print("❌ Failed to delete local user: $e");
//     }
//   }
// }

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:storrec/classes/temp_user_class.dart';

class LocalUserDatabase extends ChangeNotifier {
  static final LocalUserDatabase _instance =
      LocalUserDatabase._internal();

  factory LocalUserDatabase() => _instance;

  LocalUserDatabase._internal();

  static const String _boxName = 'usersBox';

  Box<TempUserClass>? _box;

  double userTotalSale = 0;

  void setUserTotalSale(double value) {
    userTotalSale = value;
    notifyListeners();
  }

  /// Initialize Hive and open the box
  Future<void> init() async {
    await Hive.initFlutter();

    // Register adapter only once
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TempUserClassAdapter());
    }

    _box = await Hive.openBox<TempUserClass>(_boxName);
    print("✅ Hive box '$_boxName' opened");
  }

  TempUserClass? currentEmployee;

  List<TempUserClass> currentEmployees = [];

  /// Insert or update a user
  Future<void> insertUser(TempUserClass user) async {
    try {
      if (_box == null) {
        await init();
      }

      // Use userId as key if available, else add automatically
      final key =
          user.userId ??
          DateTime.now().millisecondsSinceEpoch.toString();

      // Put user in box by key (replace if exists)
      await _box!.put(key, user);

      currentEmployee = user;
      print("✅ User inserted locally: ${user.email}");
      notifyListeners();
    } catch (e) {
      print("❌ Failed to insert user locally: $e");
    }
  }

  /// Get the first user (or null if empty)
  Future<TempUserClass?> getUser() async {
    try {
      if (_box == null) {
        await init();
      }

      if (_box!.isNotEmpty) {
        currentEmployee = _box!.values.first;
        print("✅ User fetched locally");
        return currentEmployee;
      } else {
        print("⚠️ No user found in local DB");
        return null;
      }
    } catch (e) {
      print("❌ Failed to fetch user locally: $e");
      return null;
    }
  }

  /// Delete all users (logout)
  Future<void> deleteUser() async {
    try {
      if (_box == null) {
        await init();
      }

      await _box!.clear();
      currentEmployee = null;
      print("✅ Local user deleted");
      notifyListeners();
    } catch (e) {
      print("❌ Failed to delete local user: $e");
    }
  }
}
