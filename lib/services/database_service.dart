import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/activity.dart';
import '../models/habit.dart';
import '../models/task.dart';

/// Database version history:
///   v1 – activities table
///   v2 – users + connections tables
///   v3 – activities.recurrenceRule
///   v4 – activities.category
///   v5 – activities.preAlertMinutes
///   v6 – activities.snoozeMinutes
///   v7 – (no structural change logged, bump only)
///   v8 – moods table
///   v9 – activities.duration, activities.reminderOffset, activities.isCompleted
///         + habits table + tasks table
const int _kDbVersion = 9;

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
      version: _kDbVersion,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SCHEMA CREATION (fresh install)
  // ══════════════════════════════════════════════════════════════════════════
  Future<void> _createDB(Database db, int version) async {
    await db.execute(_activitiesDDL);
    await db.execute(_syncQueueDDL);
    await db.execute(_moodsDDL);
    await db.execute(_habitsDDL);
    await db.execute(_tasksDDL);
    await _createUsersTable(db);
  }

  static const _activitiesDDL = '''
    CREATE TABLE activities (
      id               INTEGER PRIMARY KEY AUTOINCREMENT,
      title            TEXT    NOT NULL,
      description      TEXT,
      hour             INTEGER NOT NULL,
      minute           INTEGER NOT NULL,
      isAlarmEnabled   INTEGER NOT NULL DEFAULT 1,
      date             TEXT    NOT NULL,
      recurrenceRule   TEXT,
      category         TEXT    DEFAULT "Umum",
      preAlertMinutes  INTEGER DEFAULT 0,
      snoozeMinutes    INTEGER DEFAULT 5,
      duration         INTEGER DEFAULT 60,
      reminderOffset   INTEGER DEFAULT 0,
      isCompleted      INTEGER DEFAULT 0
    )
  ''';

  static const _syncQueueDDL = '''
    CREATE TABLE sync_queue (
      id         INTEGER PRIMARY KEY AUTOINCREMENT,
      operation  TEXT    NOT NULL,
      entity     TEXT    NOT NULL,
      entity_id  INTEGER NOT NULL,
      payload    TEXT,
      created_at TEXT    NOT NULL,
      status     TEXT    DEFAULT 'pending'
    )
  ''';

  static const _moodsDDL = '''
    CREATE TABLE moods (
      id      INTEGER PRIMARY KEY AUTOINCREMENT,
      score   INTEGER NOT NULL,
      date    TEXT    NOT NULL UNIQUE,
      comment TEXT
    )
  ''';

  static const _habitsDDL = '''
    CREATE TABLE habits (
      id               INTEGER PRIMARY KEY AUTOINCREMENT,
      title            TEXT    NOT NULL,
      type             TEXT    NOT NULL DEFAULT "boolean",
      currentProgress  REAL    DEFAULT 0,
      targetProgress   REAL    DEFAULT 1,
      streak           INTEGER DEFAULT 0,
      isCompleted      INTEGER DEFAULT 0,
      date             TEXT    NOT NULL
    )
  ''';

  static const _tasksDDL = '''
    CREATE TABLE tasks (
      id           INTEGER PRIMARY KEY AUTOINCREMENT,
      title        TEXT    NOT NULL,
      time         TEXT    NOT NULL DEFAULT "",
      isCompleted  INTEGER DEFAULT 0,
      date         TEXT    NOT NULL
    )
  ''';

  Future<void> _createUsersTable(Database db) async {
    await db.execute('''
      CREATE TABLE users (
        id        TEXT PRIMARY KEY,
        name      TEXT NOT NULL,
        avatarUrl TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE connections (
        id        TEXT PRIMARY KEY,
        name      TEXT NOT NULL,
        avatarUrl TEXT
      )
    ''');
  }

  // ══════════════════════════════════════════════════════════════════════════
  // MIGRATIONS
  // ══════════════════════════════════════════════════════════════════════════
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createUsersTable(db);
    }
    if (oldVersion < 3) {
      await _safeAlter(db, 'ALTER TABLE activities ADD COLUMN recurrenceRule TEXT');
    }
    if (oldVersion < 4) {
      await _safeAlter(db, 'ALTER TABLE activities ADD COLUMN category TEXT DEFAULT "Umum"');
    }
    if (oldVersion < 5) {
      await _safeAlter(db, 'ALTER TABLE activities ADD COLUMN preAlertMinutes INTEGER DEFAULT 0');
    }
    if (oldVersion < 6) {
      await _safeAlter(db, 'ALTER TABLE activities ADD COLUMN snoozeMinutes INTEGER DEFAULT 5');
    }
    if (oldVersion < 8) {
      await _safeCreateTable(db, 'moods', _moodsDDL);
    }
    if (oldVersion < 9) {
      // New activity columns missing in v1–v8
      await _safeAlter(db, 'ALTER TABLE activities ADD COLUMN duration INTEGER DEFAULT 60');
      await _safeAlter(db, 'ALTER TABLE activities ADD COLUMN reminderOffset INTEGER DEFAULT 0');
      await _safeAlter(db, 'ALTER TABLE activities ADD COLUMN isCompleted INTEGER DEFAULT 0');
      // New tables
      await _safeCreateTable(db, 'habits', _habitsDDL);
      await _safeCreateTable(db, 'tasks', _tasksDDL);
    }
  }

  /// ALTER TABLE — ignores "duplicate column" errors so reruns are safe.
  Future<void> _safeAlter(Database db, String sql) async {
    try {
      await db.execute(sql);
    } catch (e) {
      debugPrint('[DB] safeAlter skipped (likely already exists): $e');
    }
  }

  /// CREATE TABLE IF NOT EXISTS — idempotent table creation.
  Future<void> _safeCreateTable(Database db, String name, String ddl) async {
    final safe = ddl.replaceFirst('CREATE TABLE $name', 'CREATE TABLE IF NOT EXISTS $name');
    await db.execute(safe);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // USER PROFILE
  // ══════════════════════════════════════════════════════════════════════════
  Future<int> saveUser(Map<String, dynamic> user) async {
    final db = await database;
    return db.insert('users', user, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, dynamic>?> getUser() async {
    final db = await database;
    final result = await db.query('users', limit: 1);
    return result.isNotEmpty ? result.first : null;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ACTIVITIES
  // ══════════════════════════════════════════════════════════════════════════
  Future<int> createActivity(Activity activity) async {
    final db = await database;
    return db.transaction((txn) async {
      final id = await txn.insert('activities', activity.toMap());
      final withId = activity.copyWith(id: id);
      await txn.insert('sync_queue', _syncPayload('CREATE', 'activity', id, withId.toMap()));
      return id;
    });
  }

  Future<List<Activity>> readAllActivities() async {
    final db = await database;
    final rows = await db.query('activities', orderBy: 'hour ASC, minute ASC');
    return rows.map(Activity.fromMap).toList();
  }

  Future<List<Activity>> readActivitiesByDate(String date) async {
    final db = await database;
    final rows = await db.query(
      'activities',
      where: 'date = ?',
      whereArgs: [date],
      orderBy: 'hour ASC, minute ASC',
    );
    return rows.map(Activity.fromMap).toList();
  }

  Future<int> updateActivity(Activity activity) async {
    final db = await database;
    return db.transaction((txn) async {
      final rows = await txn.update(
        'activities',
        activity.toMap(),
        where: 'id = ?',
        whereArgs: [activity.id],
      );
      await txn.insert('sync_queue', _syncPayload('UPDATE', 'activity', activity.id!, activity.toMap()));
      return rows;
    });
  }

  Future<int> deleteActivity(int id) async {
    final db = await database;
    return db.transaction((txn) async {
      final rows = await txn.delete('activities', where: 'id = ?', whereArgs: [id]);
      await txn.insert('sync_queue', _syncPayload('DELETE', 'activity', id, null));
      return rows;
    });
  }

  // ══════════════════════════════════════════════════════════════════════════
  // HABITS
  // ══════════════════════════════════════════════════════════════════════════
  Future<int> createHabit(Habit habit) async {
    final db = await database;
    return db.insert('habits', habit.toMap());
  }

  Future<List<Habit>> readAllHabits() async {
    final db = await database;
    final rows = await db.query('habits', orderBy: 'id ASC');
    return rows.map(Habit.fromMap).toList();
  }

  Future<int> updateHabit(Habit habit) async {
    final db = await database;
    return db.update(
      'habits',
      habit.toMap(),
      where: 'id = ?',
      whereArgs: [habit.id],
    );
  }

  Future<int> deleteHabit(int id) async {
    final db = await database;
    return db.delete('habits', where: 'id = ?', whereArgs: [id]);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TASKS
  // ══════════════════════════════════════════════════════════════════════════
  Future<int> createTask(Task task) async {
    final db = await database;
    return db.insert('tasks', task.toMap());
  }

  Future<List<Task>> readAllTasks() async {
    final db = await database;
    final rows = await db.query('tasks', orderBy: 'id ASC');
    return rows.map(Task.fromMap).toList();
  }

  Future<List<Task>> readTasksByDate(String date) async {
    final db = await database;
    final rows = await db.query(
      'tasks',
      where: 'date = ?',
      whereArgs: [date],
      orderBy: 'id ASC',
    );
    return rows.map(Task.fromMap).toList();
  }

  Future<int> updateTask(Task task) async {
    final db = await database;
    return db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> deleteTask(int id) async {
    final db = await database;
    return db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // MOODS
  // ══════════════════════════════════════════════════════════════════════════
  Future<int> saveMood(Map<String, dynamic> mood) async {
    final db = await database;
    return db.insert('moods', mood, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, dynamic>?> getMoodByDate(String date) async {
    final db = await database;
    final result = await db.query('moods', where: 'date = ?', whereArgs: [date]);
    return result.isNotEmpty ? result.first : null;
  }

  Future<List<Map<String, dynamic>>> getAllMoods() async {
    final db = await database;
    return db.query('moods', orderBy: 'date DESC');
  }

  Future<int> deleteMoodByDate(String date) async {
    final db = await database;
    return db.delete('moods', where: 'date = ?', whereArgs: [date]);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // HELPERS
  // ══════════════════════════════════════════════════════════════════════════
  Map<String, dynamic> _syncPayload(
    String operation,
    String entity,
    int entityId,
    Map<String, dynamic>? data,
  ) {
    return {
      'operation': operation,
      'entity': entity,
      'entity_id': entityId,
      'payload': data != null ? jsonEncode(data) : null,
      'created_at': DateTime.now().toIso8601String(),
      'status': 'pending',
    };
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
