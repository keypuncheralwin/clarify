import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'user_history.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        history_json TEXT
      )
    ''');
  }

  Future<void> insertHistory(String historyJson) async {
    final db = await database;
    await db.insert(
      'history',
      {'history_json': historyJson},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<String>> getAllHistory() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('history');

    return List.generate(maps.length, (i) {
      return maps[i]['history_json'];
    });
  }

  Future<void> clearHistory() async {
    final db = await database;
    await db.delete('history');
  }
}
