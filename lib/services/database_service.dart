import 'dart:convert';
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
      version: 7,
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
    if (oldVersion < 5) {
      await db.execute('ALTER TABLE activities ADD COLUMN preAlertMinutes INTEGER DEFAULT 0');
    }
    if (oldVersion < 6) {
      await db.execute('ALTER TABLE activities ADD COLUMN snoozeMinutes INTEGER DEFAULT 5');
    }
    if (oldVersion < 7) {
      await db.execute('''
        CREATE TABLE sync_queue (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          operation TEXT NOT NULL,
          entity TEXT NOT NULL,
          entity_id INTEGER NOT NULL,
          payload TEXT,
          created_at TEXT NOT NULL,
          status TEXT DEFAULT 'pending'
        )
      ''');
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
        category TEXT DEFAULT "Umum",
        preAlertMinutes INTEGER DEFAULT 0,
        snoozeMinutes INTEGER DEFAULT 5
      )
    ''');
    await db.execute('''
      CREATE TABLE sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        operation TEXT NOT NULL,
        entity TEXT NOT NULL,
        entity_id INTEGER NOT NULL,
        payload TEXT,
        created_at TEXT NOT NULL,
        status TEXT DEFAULT 'pending'
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
    return await db.transaction((txn) async {
      final id = await txn.insert('activities', activity.toMap());
      final activityWithId = activity.copyWith(id: id);
      
      await txn.insert('sync_queue', {
        'operation': 'CREATE',
        'entity': 'activity',
        'entity_id': id,
        'payload': jsonEncode(activityWithId.toMap()),
        'created_at': DateTime.now().toIso8601String(),
        'status': 'pending'
      });
      return id;
    });
  }

  Future<List<Activity>> readAllActivities() async {
    final db = await instance.database;
    final result = await db.query('activities', orderBy: 'hour ASC, minute ASC');
    return result.map((json) => Activity.fromMap(json)).toList();
  }

  Future<int> updateActivity(Activity activity) async {
    final db = await instance.database;
    return await db.transaction((txn) async {
      final result = await txn.update(
        'activities',
        activity.toMap(),
        where: 'id = ?',
        whereArgs: [activity.id],
      );
      
      await txn.insert('sync_queue', {
        'operation': 'UPDATE',
        'entity': 'activity',
        'entity_id': activity.id!,
        'payload': jsonEncode(activity.toMap()),
        'created_at': DateTime.now().toIso8601String(),
        'status': 'pending'
      });
      return result;
    });
  }

  Future<int> deleteActivity(int id) async {
    final db = await instance.database;
    return await db.transaction((txn) async {
      final result = await txn.delete(
        'activities',
        where: 'id = ?',
        whereArgs: [id],
      );
      
      await txn.insert('sync_queue', {
        'operation': 'DELETE',
        'entity': 'activity',
        'entity_id': id,
        'payload': null,
        'created_at': DateTime.now().toIso8601String(),
        'status': 'pending'
      });
      return result;
    });
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
