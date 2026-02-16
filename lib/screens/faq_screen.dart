import 'package:flutter/material.dart';

class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

  final List<Map<String, String>> _faqs = const [
    {
      'question': 'How do I log in?',
      'answer':
          'If it\'s your first time, tap "Don\'t have an account? Sign Up" at the bottom of the login screen. You must use your valid @charusat.edu.in email and Student ID. After signing up, you can log in using your Student ID and the password you set (your Date of Birth in DDMMYYYY format).',
    },
    {
      'question': 'Can I use the app without the internet?',
      'answer':
          'Yes! The app is designed to work offline. You can fill out surveys and save them locally. However, you will need an internet connection to Log In initially and to Sync your approved data to the server.',
    },
    {
      'question': 'How do I start a new survey?',
      'answer':
          'From the Dashboard, tap the "+" button or "New Survey". You will be guided through various sections (Basic Info, Family, Housing, etc.).',
    },
    {
      'question': 'Can I save a survey halfway?',
      'answer':
          'Yes. If you press the "Back" button or try to exit during a survey, you will be prompted to save a Draft. When you open the form again, you can resume from where you left off.',
    },
    {
      'question': 'What if I make a mistake?',
      'answer':
          'You can edit a survey before it is approved. Go to your Dashboard, find the survey in the list, and tap the edit icon.',
    },
    {
      'question': 'How do I save my data to the cloud?',
      'answer':
          'Data is only synced to the server when it is Approved.\n1. Get your survey approved by a teacher (see below).\n2. Go to the Home Screen (the main screen with the Login button).\n3. Tap the "Sync to Server" button. This will upload all your approved surveys.',
    },
    {
      'question': 'How do I get a survey approved?',
      'answer':
          'A teacher must review the survey on your device. On your Dashboard, tap the "Approve" button on a survey. The teacher will enter their password to mark it as approved.',
    },
    {
      'question': 'Can I edit or delete a survey?',
      'answer':
          'You can edit or delete a survey only if it is not yet approved. Once a survey is approved, it is locked to ensure data integrity and cannot be changed or removed.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Frequently Asked Questions'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _faqs.length,
        itemBuilder: (context, index) {
          final faq = _faqs[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12.0),
            child: ExpansionTile(
              title: Text(
                faq['question']!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  child: Text(
                    faq['answer']!,
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
