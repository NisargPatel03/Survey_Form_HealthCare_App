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

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE surveys (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        studentName TEXT,
        headOfFamily TEXT,
        surveyDate TEXT,
        jsonContent TEXT,
        createdAt TEXT
      )
    ''');
  }

  Future<int> create(SurveyData survey) async {
    final db = await instance.database;
    
    // We serialize the survey to JSON. 
    // The ID might be null initially in the JSON, but we will assign it after insertion.
    final jsonContent = jsonEncode(survey.toJson());
    
    final id = await db.insert('surveys', {
      'studentName': survey.studentName,
      'headOfFamily': survey.headOfFamily,
      'surveyDate': survey.surveyDate?.toIso8601String(),
      'jsonContent': jsonContent,
      'createdAt': DateTime.now().toIso8601String(),
    });
    
    survey.id = id;
    return id;
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
