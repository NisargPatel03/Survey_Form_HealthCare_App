import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static final AuthService instance = AuthService._internal();

  factory AuthService() {
    return instance;
  }

  AuthService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;

  User? get currentUser => _supabase.auth.currentUser;
  Session? get currentSession => _supabase.auth.currentSession;

  String _normalizeStudentId(String studentId) {
    return studentId.trim().toLowerCase();
  }

  String _constructEmail(String studentId) {
    return '${_normalizeStudentId(studentId)}@charusat.edu.in';
  }

  /// Signs up a new student.
  /// Requires [email] to end with @charusat.edu.in and match [studentId].
  /// Uses [dob] to generate the password in DDMMYYYY format.
  Future<AuthResponse> signUp({
    required String email,
    required DateTime dob,
    required String studentId,
  }) async {
    final normalizedId = _normalizeStudentId(studentId);
    final normalizedEmail = email.trim().toLowerCase();

    if (!normalizedEmail.endsWith('@charusat.edu.in')) {
      throw const AuthException('Email must end with @charusat.edu.in');
    }

    // Verify email prefix matches student ID
    final emailPrefix = normalizedEmail.split('@')[0];
    if (emailPrefix != normalizedId) {
      throw const AuthException(
          'Email prefix must match Student ID (e.g., ID: D23IT123 -> Email: d23it123@charusat.edu.in)');
    }

    // Format DOB as DDMMYYYY
    final password = _formatDob(dob);

    return await _supabase.auth.signUp(
      email: normalizedEmail,
      password: password,
      data: {'student_id': studentId.toUpperCase()}, // Store as uppercase for display
    );
  }

  /// Signs in using Student ID and DOB (entered as password).
  /// Constructs the email automatically from the ID.
  Future<AuthResponse> signIn({
    required String studentId,
    required String password, // This is the DOB entered by user
  }) async {
    final email = _constructEmail(studentId);
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  String _formatDob(DateTime dob) {
    final day = dob.day.toString().padLeft(2, '0');
    final month = dob.month.toString().padLeft(2, '0');
    final year = dob.year.toString();
    return '$day$month$year';
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}
