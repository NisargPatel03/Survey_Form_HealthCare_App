import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class AttachmentService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Uploads a file (like a sketch PNG or picked photo) to Supabase Storage.
  /// Returns the public URL of the uploaded file on success.
  /// If the upload fails (e.g. due to no internet connectivity or missing bucket configuration),
  /// it returns the local file path as an offline-first fallback.
  Future<String> uploadRequirementAttachment({
    required String studentId,
    required String requirementSrNo,
    required String localFilePath,
  }) async {
    final file = File(localFilePath);
    if (!await file.exists()) {
      throw Exception("Source file does not exist: $localFilePath");
    }

    try {
      final fileExtension = localFilePath.split('.').last;
      final fileName = 'sketch_${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
      // Segment path nicely: e.g. requirements/studentId/reqSrNo/sketch_1234.png
      final storagePath = 'requirements/$studentId/$requirementSrNo/$fileName';

      print('Uploading layout attachment to Supabase Storage bucket: requirement-attachments...');
      
      // Upload using Supabase storage client
      await _supabase.storage
          .from('requirement-attachments')
          .upload(storagePath, file);

      // Generate public URL
      final String publicUrl = _supabase.storage
          .from('requirement-attachments')
          .getPublicUrl(storagePath);

      print('Attachment successfully uploaded to Supabase Storage: $publicUrl');
      return publicUrl;
    } catch (e) {
      print('WARNING: Attachment upload to Supabase Storage failed: $e');
      print('Falling back to offline-first local file storage path: $localFilePath');
      // Offline fallback: return the original local filepath.
      // The form will store this path, allowing the student to see the local preview 
      // and re-trigger sync later.
      return localFilePath;
    }
  }
}
