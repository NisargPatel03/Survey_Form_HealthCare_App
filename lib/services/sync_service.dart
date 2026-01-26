import 'package:supabase_flutter/supabase_flutter.dart';
import 'database_helper.dart';
import '../models/survey_data.dart';

class SyncService {
  final _supabase = Supabase.instance.client;
  final _dbHelper = DatabaseHelper.instance;

  /// Uploads all pending surveys to Supabase.
  /// Returns the number of surveys successfully uploaded.
  Future<int> syncPendingSurveys() async {
    // 1. Fetch pending surveys from local DB
    final List<SurveyData> pendingSurveys = await _dbHelper.getPendingSurveys();
    
    if (pendingSurveys.isEmpty) {
      return 0; // Nothing to sync
    }

    int successCount = 0;

    for (var survey in pendingSurveys) {
      try {
        // 2. Insert into Supabase 'surveys' table
        // We match the columns defined in the Supabase SQL script
        await _supabase.from('surveys').insert({
          'student_name': survey.studentName,
          'head_of_family': survey.headOfFamily,
          'survey_date': survey.surveyDate?.toIso8601String(),
          // We store the full detailed JSON in the 'json_content' column
          // We must ensure 'toJson()' returns a Map<String, dynamic>
          'json_content': survey.toJson(), 
        });

        // 3. If successful, mark as synced in local DB
        if (survey.id != null) {
          await _dbHelper.markAsSynced(survey.id!);
          successCount++;
        }
      } catch (e) {
        print("Sync failed for survey ID ${survey.id}: $e");
        // We continue to the next one even if this one fails
      }
    }

    return successCount;
  }
}
