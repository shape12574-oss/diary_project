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
    String path = join(await getDatabasesPath(), 'travel_snap.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDb,
    );
  }


  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE diary_entries(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        address TEXT NOT NULL,
        activity TEXT NOT NULL,
        photoPath TEXT NOT NULL,
        aiTags TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');
  }


  Future<int> insertDiary(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert('diary_entries', row);
  }

  Future<List<Map<String, dynamic>>> getDiaries() async {
    Database db = await database;
    return await db.query('diary_entries');
  }
}