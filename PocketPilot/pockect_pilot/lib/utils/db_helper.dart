import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DbHelper {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  static Future<Database> _initDb() async {
    try {
      final dbPath = await getDatabasesPath();
      final pathString = join(dbPath, 'pocket_pilot.db');

      return await openDatabase(
        pathString,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE dwell_logs (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              placeName TEXT,
              latitude REAL,
              longitude REAL,
              entryTime TEXT,
              durationMinutes INTEGER,
              notified INTEGER
            )
          ''');
        },
      );
    } catch (e) {
      // Fallback in case SQLite is not supported/configured (e.g. mock db in memory or web test)
      print("DbHelper _initDb fallback: $e");
      return _createMockDatabase();
    }
  }

  static Future<Database> _createMockDatabase() async {
    // In memory mock database if standard sqflite fails (e.g. on web/desktop during initial setup)
    return openDatabase(inMemoryDatabasePath, version: 1, onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE dwell_logs (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          placeName TEXT,
          latitude REAL,
          longitude REAL,
          entryTime TEXT,
          durationMinutes INTEGER,
          notified INTEGER
        )
      ''');
    });
  }

  static Future<int> insertDwell(Map<String, dynamic> row) async {
    try {
      final db = await database;
      return await db.insert('dwell_logs', row);
    } catch (e) {
      print("SQLite insertDwell fallback error: $e");
      return -1;
    }
  }

  static Future<List<Map<String, dynamic>>> getDwells() async {
    try {
      final db = await database;
      return await db.query('dwell_logs', orderBy: 'id DESC');
    } catch (e) {
      print("SQLite getDwells fallback error: $e");
      return [];
    }
  }

  static Future<int> updateDwellNotified(int id) async {
    try {
      final db = await database;
      return await db.update(
        'dwell_logs',
        {'notified': 1},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print("SQLite updateDwellNotified fallback error: $e");
      return -1;
    }
  }

  static Future<void> clearDwells() async {
    try {
      final db = await database;
      await db.delete('dwell_logs');
    } catch (e) {
      print("SQLite clearDwells error: $e");
    }
  }
}
