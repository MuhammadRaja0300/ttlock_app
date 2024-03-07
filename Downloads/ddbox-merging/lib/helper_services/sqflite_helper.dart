import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'notifications.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDb,
    );
  }

  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notifications(
        id INTEGER PRIMARY KEY,
        title TEXT,
        body TEXT,
        timestamp TEXT,
        timestamp_o INTEGER
      )
    ''');
  }

  Future<int> insertNotification(Map<String, dynamic> notification) async {
    Database db = await instance.database;
    return await db.insert('notifications', notification);
  }

  Future<List<Map<String, dynamic>>> fetchNotifications() async {
    Database db = await instance.database;
    return await db.query('notifications', orderBy: 'timestamp_o DESC');
  }
}
