import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app_islamic.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';
    const realType = 'REAL NOT NULL';

    // 1. Ibadah Logs Table (Ritual Engine - IBADAH_CORE_001)
    await db.execute('''
      CREATE TABLE ibadah_logs (
        id $idType,
        type $textType,         -- e.g., 'Salah', 'Dhikr', 'Quran'
        name $textType,         -- e.g., 'Subuh', 'Morning Dhikr'
        status $textType,       -- e.g., 'Completed', 'Missed', 'Late'
        performed_at $textType, -- ISO8601 String
        intensity $intType,     -- From blueprint logDeed
        metadata $textType      -- JSON String for extra data (rakaat, duration, etc.)
      )
    ''');

    // 2. Markov Transitions Table (Ritual State Machine - MARKOV_STATE_002)
    await db.execute('''
      CREATE TABLE behavior_transitions (
        state_from $textType,
        state_to $textType,
        transition_count $intType DEFAULT 0,
        PRIMARY KEY (state_from, state_to)
      )
    ''');

    // 3. DDA Stats Table (Dynamic Deed Analysis - DDA_LOGIC_003)
    await db.execute('''
      CREATE TABLE user_dda_stats (
        user_id $textType PRIMARY KEY,
        current_tolerance $intType DEFAULT 100, -- Mental HP
        consecutive_failures $intType DEFAULT 0,
        difficulty_tier $intType DEFAULT 1,
        spiritual_momentum $realType DEFAULT 0.0
      )
    ''');

    // 4. SRS Cards Table (Spaced Repetition for Memorization)
    await db.execute('''
      CREATE TABLE srs_cards (
        id $idType,
        target_id $textType,    -- ID of the ayah/hadith
        easiness_factor $realType DEFAULT 2.5,
        interval_days $intType DEFAULT 0,
        repetitions $intType DEFAULT 0,
        next_review_date $textType,
        last_quality_score $intType
      )
    ''');
  }

  // Helper methods for ibadah_logs
  Future<int> insertLog(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert('ibadah_logs', row);
  }

  Future<List<Map<String, dynamic>>> getLogsByDate(String date) async {
    Database db = await instance.database;
    // date format: YYYY-MM-DD
    return await db.query(
      'ibadah_logs',
      where: 'performed_at LIKE ?',
      whereArgs: ['$date%'],
    );
  }

  Future<int> deleteLog(String name, String date) async {
    Database db = await instance.database;
    return await db.delete(
      'ibadah_logs',
      where: 'name = ? AND performed_at LIKE ?',
      whereArgs: [name, '$date%'],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
