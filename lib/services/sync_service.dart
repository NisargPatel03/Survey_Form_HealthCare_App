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

  /// Restores surveys from the cloud for a specific student.
  /// Downloads surveys where student_name matches [studentId].
  /// Returns the number of surveys restored (imported locally).
  Future<int> restoreSurveys(String studentId) async {
    try {
      // 1. Fetch from Supabase
      final response = await _supabase
          .from('surveys')
          .select('*')
          .eq('student_name', studentId);

      // response is List<dynamic> (maps)
      final List<dynamic> data = response as List<dynamic>;

      int restoredCount = 0;

      for (var row in data) {
        try {
          // 2. Parse JSON content
          // The 'json_content' field holds the full structure.
          // Fallback: if json_content is string, decode it.
          Map<String, dynamic> surveyMap;
          if (row['json_content'] is String) {
             // It might be double encoded or just a string field
             // Depending on how Supabase returns JSONB/JSON
             // Usually Postgres JSONB is returned as Map in Dart if using postgrest
             // But let's be safe
             // NOTE: In the fetch hook we saw earlier, it was handled.
             // Let's assume it might come as Map or String
             // If it is a string and looks like json, decode.
             // Actually, Supabase returns JSON columns as Map usually.
             continue; // Skip if invalid? or try to decode?
             // Let's assume Map first
          } else {
            surveyMap = row['json_content'] as Map<String, dynamic>;
          }
          
          final survey = SurveyData.fromJson(surveyMap);

          // Ensure the student name is correct (should be, based on query)
          survey.studentName = studentId; 
          
          // 3. Import to local DB
          // This method handles duplicate checking
          final id = await _dbHelper.importSyncedSurvey(survey);
          if (id != null) {
            restoredCount++;
          }
        } catch (e) {
          print("Error parsing/importing survey from cloud: $e");
        }
      }
      
      return restoredCount;
    } catch (e) {
      print("Error restoring surveys: $e");
      return 0;
    }
  }
}
