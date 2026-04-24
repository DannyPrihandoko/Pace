import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/activity.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('pace_database.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 4,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createUsersTable(db);
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE activities ADD COLUMN recurrenceRule TEXT');
    }
    if (oldVersion < 4) {
      await db.execute('ALTER TABLE activities ADD COLUMN category TEXT DEFAULT "Umum"');
    }
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE activities (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        hour INTEGER NOT NULL,
        minute INTEGER NOT NULL,
        isAlarmEnabled INTEGER NOT NULL,
        date TEXT NOT NULL,
        recurrenceRule TEXT,
        category TEXT DEFAULT "Umum"
      )
    ''');
    await _createUsersTable(db);
  }

  Future _createUsersTable(Database db) async {
     await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        avatarUrl TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE connections (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        avatarUrl TEXT
      )
    ''');
  }

  // User Profile Methods
  Future<int> saveUser(Map<String, dynamic> user) async {
    final db = await instance.database;
    return await db.insert('users', user, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, dynamic>?> getUser() async {
    final db = await instance.database;
    final result = await db.query('users', limit: 1);
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> createActivity(Activity activity) async {
    final db = await instance.database;
    return await db.insert('activities', activity.toMap());
  }

  Future<List<Activity>> readAllActivities() async {
    final db = await instance.database;
    final result = await db.query('activities', orderBy: 'hour ASC, minute ASC');
    return result.map((json) => Activity.fromMap(json)).toList();
  }

  Future<int> updateActivity(Activity activity) async {
    final db = await instance.database;
    return db.update(
      'activities',
      activity.toMap(),
      where: 'id = ?',
      whereArgs: [activity.id],
    );
  }

  Future<int> deleteActivity(int id) async {
    final db = await instance.database;
    return await db.delete(
      'activities',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
