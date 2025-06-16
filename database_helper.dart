import 'dart:io' show Platform;
import 'package:sqflite/sqflite.dart' as sqflite; // Import sqflite với alias
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as sqflite_ffi; // Import sqflite_ffi với alias
import 'dart:developer' as developer;

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static sqflite.Database? _database; // Sử dụng sqflite.Database

  DatabaseHelper._init();

  // Khởi tạo databaseFactory
  static void initializeDatabaseFactory() {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      developer.log('Initializing sqflite_ffi for desktop');
      sqflite_ffi.sqfliteFfiInit();
      sqflite.databaseFactory = sqflite_ffi.databaseFactoryFfi; // Gán cho desktop
    } else {
      developer.log('Using default databaseFactory for Android/iOS');
      // Không cần gán lại, giữ mặc định của sqflite cho Android/iOS
    }
  }

  Future<sqflite.Database> get database async {
    if (_database != null) {
      developer.log('Database already initialized');
      return _database!;
    }

    developer.log('Initializing database...');
    initializeDatabaseFactory();
    final dbPath = await sqflite.getDatabasesPath(); // Sử dụng sqflite.getDatabasesPath
    final path = join(dbPath, 'user_database.db');
    developer.log('Database path: $path');

    _database = await sqflite.openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
    return _database!;
  }

  Future _createDB(sqflite.Database db, int version) async {
    developer.log('Creating database table...');
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fullName TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        phone TEXT NOT NULL,
        dob TEXT NOT NULL,
        gender TEXT NOT NULL,
        password TEXT NOT NULL,
        createdAt TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');
  }

  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await instance.database;
    developer.log('Inserting user: $user');

    try {
      // Kiểm tra xem email đã tồn tại chưa
      final existingUser = await db.query(
        'users',
        where: 'email = ?',
        whereArgs: [user['email']],
      );

      if (existingUser.isNotEmpty) {
        developer.log('Email already exists: ${user['email']}');
        throw Exception('Email đã được sử dụng');
      }

      return await db.insert('users', user);
    } catch (e) {
      developer.log('Error inserting user: $e');
      rethrow; // Ném lại ngoại lệ để xử lý ở cấp cao hơn
    }
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final db = await instance.database;
    developer.log('Fetching all users');
    return await db.query('users', orderBy: 'createdAt DESC');
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await instance.database;
    developer.log('Fetching user by email: $email');
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  Future<bool> validateUser(String email, String password) async {
    final db = await instance.database;
    developer.log('Validating user: $email, $password');
    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    return result.isNotEmpty;
  }

  // Thêm phương thức update
  Future<int> update(String table, Map<String, dynamic> values, {required String where, List<Object?>? whereArgs}) async {
    final db = await instance.database;
    developer.log('Updating table: $table, values: $values, where: $where, whereArgs: $whereArgs');
    return await db.update(table, values, where: where, whereArgs: whereArgs);
  }

  Future<int> deleteUser(int id) async {
    final db = await instance.database;
    developer.log('Deleting user with id: $id');
    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      developer.log('Closing database');
      await db.close();
      _database = null; // Đặt lại _database thành null sau khi đóng
    }
  }
}