import 'package:supabase_flutter/supabase_flutter.dart';

class SubmissionService {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  Future<List<Map<String, dynamic>>> getFacultyProfiles() async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('id, full_name')
          .eq('role', 'faculty');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching faculty: $e');
      return [];
    }
  }
  
  Future<void> submitRequirement({
    required String studentId, 
    required String courseName, 
    required String requirementSrNo, 
    required Map<String, dynamic> formData,
    required String assignedFacultyId,
  }) async {
    try {
      // 1. Check if it already exists to update instead of insert
      final existing = await _supabase
          .from('requirement_submissions')
          .select('id')
          .eq('student_id', studentId.trim())
          .eq('course_name', courseName.trim())
          .eq('requirement_sr_no', requirementSrNo.trim())
          .maybeSingle();

      print('SUBMITTING DATA for $studentId: ${formData.keys.length} fields');

      // 2. Prepare the update/insert data
      // We explicitly set evaluation-related fields to null during submission/resubmission
      // so that previous marks/remarks don't linger on a newly updated form.
      final Map<String, dynamic> submissionData = {
        'student_id': studentId.trim(),
        'course_name': courseName.trim(),
        'requirement_sr_no': requirementSrNo.trim(),
        'form_data': formData,
        'status': 'submitted',
        'assigned_faculty_id': assignedFacultyId,
        'marks_obtained': null,
        'max_marks': null,
        'faculty_remarks': null,
        'evaluation_data': null,
      };

      if (existing != null) {
        print('UPDATING existing record: ${existing['id']}');
        await _supabase.from('requirement_submissions').update(submissionData).eq('id', existing['id']);
      } else {
        print('INSERTING new record');
        await _supabase.from('requirement_submissions').insert(submissionData);
      }
    } catch (e) {
      print('CRITICAL ERROR during submission: $e');
      rethrow;
    }
  }
  
  Future<Map<String, dynamic>?> getSubmission(String studentId, String courseName, String requirementSrNo) async {
    try {
      final response = await _supabase
          .from('requirement_submissions')
          .select()
          .eq('student_id', studentId.trim())
          .eq('course_name', courseName.trim())
          .eq('requirement_sr_no', requirementSrNo.trim())
          .maybeSingle();
          
      return response;
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
