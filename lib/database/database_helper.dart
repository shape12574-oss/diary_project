import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:diary_project/models/diary_entry.dart';

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


  Future<int> insertDiary(DiaryEntry entry) async {
    Database db = await database;
    final map = entry.toJson();


    map.remove('id');

    return await db.insert('diary_entries', map);
  }

  Future<List<DiaryEntry>> getAllDiaries() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('diary_entries');
    return List.generate(maps.length, (i) => DiaryEntry.fromJson(maps[i]));
  }

  Future<int> updateDiary(DiaryEntry entry) async {
    Database db = await database;
    return await db.update(
      'diary_entries',
      entry.toJson(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<int> deleteDiary(int id) async {
    Database db = await database;
    return await db.delete(
      'diary_entries',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}