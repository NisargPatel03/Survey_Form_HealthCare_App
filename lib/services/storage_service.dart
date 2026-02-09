import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
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

  // --- Draft Management ---

  static const String _draftKey = 'survey_draft';

  Future<void> saveDraft(SurveyData survey) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(survey.toJson());
    await prefs.setString(_draftKey, jsonString);
  }

  Future<SurveyData?> getDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_draftKey);
    if (jsonString != null) {
      try {
        final jsonMap = jsonDecode(jsonString);
        return SurveyData.fromJson(jsonMap);
      } catch (e) {
        // If draft is corrupted, clear it
        await clearDraft();
        return null;
      }
    }
    return null;
  }

  Future<void> clearDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_draftKey);
  }

  Future<bool> hasDraft() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_draftKey);
  }
}
