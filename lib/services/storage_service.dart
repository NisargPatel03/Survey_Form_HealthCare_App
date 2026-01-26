import '../models/survey_data.dart';
import 'database_helper.dart';

class StorageService {
  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<void> saveSurvey(SurveyData survey) async {
    await _db.create(survey);
  }

  Future<List<SurveyData>> getAllSurveys() async {
    return await _db.readAllSurveys();
  }

  Future<void> deleteSurvey(int id) async {
    await _db.delete(id);
  }

  // Updated to take the object directly, utilizing its ID
  Future<void> updateSurvey(SurveyData survey) async {
    if (survey.id != null) {
      await _db.update(survey);
    } else {
      // Fallback or error? If it's an update, it should have an ID.
      // If no ID, treat as create?
      await _db.create(survey);
    }
  }

  Future<void> clearAllSurveys() async {
    // This might need a method in DatabaseHelper or manual deletion
    // For now, iterate and delete or drop table (helper doesn't expose drop)
    // Let's just delete all rows
    final db = await _db.database;
    await db.delete('surveys');
  }
}
