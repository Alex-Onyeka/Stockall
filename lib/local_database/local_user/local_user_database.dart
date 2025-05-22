import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:stockitt/classes/temp_user_class.dart';

class LocalUserDatabase extends ChangeNotifier {
  static final LocalUserDatabase _instance =
      LocalUserDatabase._internal();

  factory LocalUserDatabase() => _instance;

  LocalUserDatabase._internal();

  static Database? _database;

  /// Ensure database is ready
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  /// Initialize SQLite database
  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'user.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE user(
            user_id TEXT PRIMARY KEY,
            created_at TEXT,
            name TEXT,
            email TEXT,
            phone TEXT,
            role TEXT,
            password TEXT,
            auth_user_id TEXT
          )
        ''');
        print("✅ Local DB created at $path");
      },
    );
  }

  /// Insert user record into local DB
  Future<void> insertUser(TempUserClass user) async {
    try {
      final db = await database;

      await db.insert('user', {
        ...user.toJson(),
        'created_at': user.createdAt?.toIso8601String(),
        'auth_user_id': user.authUserId,
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      currentEmployee = user; // ✅ Store user in memory
      print("✅ User inserted locally: ${user.email}");
      notifyListeners();
    } catch (e) {
      print("❌ Failed to insert user locally: $e");
    }
  }

  TempUserClass? currentEmployee;

  /// Get the first user (there should only be one)
  Future<TempUserClass?> getUser() async {
    try {
      final db = await database;
      final result = await db.query('user', limit: 1);

      if (result.isNotEmpty) {
        final user = TempUserClass.fromJson(result.first);
        currentEmployee = user; // ✅ Store user in memory
        print("✅ User fetched locally");
        return user;
      }

      print("⚠️ No user found in local DB");
      return null;
    } catch (e) {
      print("❌ Failed to fetch user locally: $e");
      return null;
    }
  }

  /// Delete all users (useful for logout)
  Future<void> deleteUser() async {
    try {
      final db = await database;
      await db.delete('user');
      currentEmployee = null;
      print("✅ Local user deleted");
      notifyListeners();
    } catch (e) {
      print("❌ Failed to delete local user: $e");
    }
  }
}
