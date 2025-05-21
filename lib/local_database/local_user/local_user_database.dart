import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:stockitt/classes/temp_user_class.dart';
import 'package:stockitt/services/auth_service.dart';

class LocalUserDatabase {
  static final LocalUserDatabase _instance =
      LocalUserDatabase._internal();
  factory LocalUserDatabase() => _instance;
  LocalUserDatabase._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDb();
    return _database!;
  }

  Future<Database> initDb() async {
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
      },
    );
  }

  Future<void> insertUser(TempUserClass user) async {
    final db = await database;
    await db.insert('user', {
      ...user.toJson(),
      'created_at': user.createdAt?.toIso8601String(),
      'auth_user_id': AuthService().currentUser!.id,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<TempUserClass?> getUser() async {
    final db = await database;
    final result = await db.query('user', limit: 1);
    if (result.isNotEmpty) {
      return TempUserClass.fromJson(result.first);
    }
    return null;
  }

  Future<void> deleteUser() async {
    final db = await database;
    await db.delete('user');
  }
}
