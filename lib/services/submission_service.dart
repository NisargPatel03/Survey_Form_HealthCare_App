import 'package:supabase_flutter/supabase_flutter.dart';

class SubmissionService {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  Future<void> submitRequirement(String studentId, String courseName, String requirementSrNo, Map<String, dynamic> formData) async {
    // Check if it already exists to update instead of insert (upsert logic based on student and requirement)
    final existing = await _supabase
        .from('requirement_submissions')
        .select('id')
        .eq('student_id', studentId)
        .eq('course_name', courseName)
        .eq('requirement_sr_no', requirementSrNo)
        .maybeSingle();

    if (existing != null) {
      await _supabase.from('requirement_submissions').update({
        'form_data': formData,
        'status': 'submitted',
      }).eq('id', existing['id']);
    } else {
      await _supabase.from('requirement_submissions').insert({
        'student_id': studentId,
        'course_name': courseName,
        'requirement_sr_no': requirementSrNo,
        'form_data': formData,
        'status': 'submitted',
      });
    }
  }
  
  Future<Map<String, dynamic>?> getSubmission(String studentId, String courseName, String requirementSrNo) async {
    try {
      final response = await _supabase
          .from('requirement_submissions')
          .select()
          .eq('student_id', studentId)
          .eq('course_name', courseName)
          .eq('requirement_sr_no', requirementSrNo)
          .maybeSingle();
          
      if (response != null) {
        return response['form_data'] as Map<String, dynamic>;
      }
    } catch (e) {
      print('Error fetching submission: $e');
    }
    return null;
  }
  
  Future<bool> hasSubmitted(String studentId, String courseName, String requirementSrNo) async {
    try {
      final response = await _supabase
          .from('requirement_submissions')
          .select('id')
          .eq('student_id', studentId)
          .eq('course_name', courseName)
          .eq('requirement_sr_no', requirementSrNo)
          .maybeSingle();
      return response != null;
    } catch (e) {
      return false;
    }
  }
}
