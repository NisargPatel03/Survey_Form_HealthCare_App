import 'package:flutter/material.dart';
import 'screens/survey_form_screen.dart';
import 'screens/login_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase
import 'services/sync_service.dart'; // Import SyncService
import 'screens/student_dashboard_screen.dart';
import 'screens/splash_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://bptrstciuoaaqutanmal.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJwdHJzdGNpdW9hYXF1dGFubWFsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk0MzI0NDEsImV4cCI6MjA4NTAwODQ0MX0.hBL1YcChvPruPh7mGCFkV6HCkMsPjx7cEofbiI0DoJc',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      title: 'Community Health Care Survey',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF00796B),
          primaryContainer: Color(0xFF26A69A),
          secondary: Color(0xFF0097A7),
          secondaryContainer: Color(0xFF4DB6AC),
          surface: Color(0xFFFAFAFA),
          surfaceContainerHighest: Color(0xFFF5F7FA),
          error: Color(0xFFD32F2F),
          onPrimary: Color(0xFFFFFFFF),
          onSecondary: Color(0xFFFFFFFF),
          onSurface: Color(0xFF263238),
          onSurfaceVariant: Color(0xFF37474F),
          onError: Color(0xFFFFFFFF),
          outline: Color(0xFFB0BEC5),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF00796B),
          foregroundColor: Color(0xFFFFFFFF),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFFFFFFFF),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00796B),
            foregroundColor: const Color(0xFFFFFFFF),
            elevation: 3,
            shadowColor: const Color(0x4D00796B),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        cardTheme: const CardThemeData(
          elevation: 4,
          shadowColor: Color(0x1A00796B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFB0BEC5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF00796B), width: 2),
          ),
          filled: true,
          fillColor: const Color(0xFFFAFAFA),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF26A69A),
          foregroundColor: Color(0xFFFFFFFF),
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: Color(0xFF0097A7),
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: Color(0xFF37474F),
          contentTextStyle: TextStyle(color: Color(0xFFFFFFFF)),
        ),
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/home': (context) => const HomeScreen(),
        '/dashboard': (context) {

           // Retrieve user metadata if available, otherwise just pass a default 'Student'
           // Ideally we would get the ID from local storage or user metadata
           final user = Supabase.instance.client.auth.currentUser;
           final studentId = user?.userMetadata?['student_id'] as String? ?? 'Student';
           return StudentDashboardScreen(studentId: studentId);
        },
        '/survey': (context) => const SurveyFormScreen(),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Health Care Survey'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo.jpg',
              height: 120, // Adjusted height for logo
            ),
            const SizedBox(height: 30),
            const Text(
              'MANIKAKA TOPAWALA INSTITUTE OF NURSING',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'CHARUSAT - CAMPUS, CHANGA',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 5),
            const Text(
              'COMMUNITY HEALTH NURSING - I',
              style: TextStyle(
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 5),
            const Text(
              'Baseline Survey Form',
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 50),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.person),
              label: const Text('Login', style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 18,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Sync Button
            ElevatedButton.icon(
              onPressed: () async {
                // Show loading indicator or simple snackbar
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Syncing data to server...')),
                );
                
                final count = await SyncService().syncPendingSurveys();
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                   if (count > 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Successfully synced $count surveys!')),
                    );
                   } else {
                     ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No pending surveys to sync.')),
                    );
                   }
                }
              },
              icon: const Icon(Icons.cloud_upload),
              label: const Text('Sync to Server', style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 18,
                ),
                backgroundColor: const Color(0xFF2196F3), // Blue color
              ),
            ),
          ],
        ),
      ),
    );
  }
}

