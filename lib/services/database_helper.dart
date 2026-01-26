import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/survey_data.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('surveys.db');
    return _database!;
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE surveys (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        studentName TEXT,
        headOfFamily TEXT,
        surveyDate TEXT,
        jsonContent TEXT,
        createdAt TEXT,
        isSynced INTEGER DEFAULT 0
      )
    ''');
  }

  // Handle migration for existing users
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE surveys ADD COLUMN isSynced INTEGER DEFAULT 0');
    }
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path, 
      version: 2, 
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<int> create(SurveyData survey) async {
    final db = await instance.database;
    
    final jsonContent = jsonEncode(survey.toJson());
    
    final id = await db.insert('surveys', {
      'studentName': survey.studentName,
      'headOfFamily': survey.headOfFamily,
      'surveyDate': survey.surveyDate?.toIso8601String(),
      'jsonContent': jsonContent,
      'createdAt': DateTime.now().toIso8601String(),
      'isSynced': 0, // Default to not synced
    });
    
    survey.id = id;
    return id;
  }

  // --- Sync Related Methods ---

  Future<List<SurveyData>> getPendingSurveys() async {
    final db = await instance.database;
    final result = await db.query(
      'surveys',
      where: 'isSynced = ?',
      whereArgs: [0], // 0 means false
    );

    return result.map((json) {
       final contentMap = jsonDecode(json['jsonContent'] as String);
       contentMap['id'] = json['id'];
       return SurveyData.fromJson(contentMap);
    }).toList();
  }

  Future<int> markAsSynced(int id) async {
    final db = await instance.database;
    return await db.update(
      'surveys',
      {'isSynced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<SurveyData?> read(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'surveys',
      columns: ['id', 'studentName', 'headOfFamily', 'surveyDate', 'jsonContent', 'createdAt'],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      final jsonMap = jsonDecode(maps.first['jsonContent'] as String);
      // Ensure the ID from the database column is used
      jsonMap['id'] = maps.first['id'];
      
      return SurveyData.fromJson(jsonMap);
    } else {
      return null;
    }
  }

  Future<List<SurveyData>> readAllSurveys() async {
    final db = await instance.database;
    final result = await db.query('surveys', orderBy: 'createdAt DESC');

    return result.map((json) {
       final contentMap = jsonDecode(json['jsonContent'] as String);
       // Ensure the ID from the database column is used
       contentMap['id'] = json['id'];
       return SurveyData.fromJson(contentMap);
    }).toList();
  }

  Future<int> update(SurveyData survey) async {
    final db = await instance.database;
    if (survey.id == null) {
      // If no ID, create instead
      return await create(survey);
    }

    final jsonContent = jsonEncode(survey.toJson());

    return db.update(
      'surveys',
      {
        'studentName': survey.studentName,
        'headOfFamily': survey.headOfFamily,
        'surveyDate': survey.surveyDate?.toIso8601String(),
        'jsonContent': jsonContent,
      },
      where: 'id = ?',
      whereArgs: [survey.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete(
      'surveys',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
