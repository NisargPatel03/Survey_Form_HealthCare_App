import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/survey_data.dart';
import '../services/storage_service.dart';
import '../services/sync_service.dart';
import 'survey_form_screen.dart';
import 'survey_detail_screen.dart';
import 'faq_screen.dart';
import 'annexures_screen.dart';

class StudentDashboardScreen extends StatefulWidget {
  final String studentId;

  const StudentDashboardScreen({super.key, required this.studentId});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  final _storageService = StorageService();
  List<SurveyData> _surveys = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initialSync();
  }

  Future<void> _initialSync() async {
    setState(() => _isLoading = true);
    
    // Auto-restore data from cloud on first load
    await SyncService().restoreSurveys(widget.studentId);
    
    // Then load local surveys
    if (mounted) {
      _loadSurveys();
    }
  }

  Future<void> _loadSurveys() async {
    setState(() => _isLoading = true);
    final allSurveys = await _storageService.getAllSurveys();
    // Filter surveys by student ID
    setState(() {
      _surveys = allSurveys
          .where((s) => s.studentName == widget.studentId)
          .toList();
      _isLoading = false;
    });
  }

  Future<void> _deleteSurvey(SurveyData survey) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Survey', style: TextStyle(fontSize: 18)),
        content: const Text('Are you sure you want to delete this survey?', style: TextStyle(fontSize: 16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(fontSize: 16)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(fontSize: 16, color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Use ID if available
      if (survey.id != null) {
         await _storageService.deleteSurvey(survey.id!);
         _loadSurveys();
      } else {
         // Fallback legacy logic if ID missing for some reason
         // ... (existing logic or just error)
          if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(
               const SnackBar(content: Text('Cannot delete survey without ID')),
             );
          }
      }
    }
  }

  Future<void> _handleEdit(SurveyData survey) async {
      final navigator = Navigator.of(context);
      final messenger = ScaffoldMessenger.of(context);
      
      try {
        final allSurveys = await _storageService.getAllSurveys();
        // Find the survey by comparing unique fields
        int actualIndex = -1;
        for (int i = 0; i < allSurveys.length; i++) {
          final s = allSurveys[i];
          if (s.headOfFamily == survey.headOfFamily &&
              s.areaName == survey.areaName &&
              s.surveyDate?.millisecondsSinceEpoch == survey.surveyDate?.millisecondsSinceEpoch &&
              s.studentName == survey.studentName) {
            actualIndex = i;
            break;
          }
        }
        
        if (!mounted) return;
        
        if (actualIndex >= 0) {
          // Create a deep copy of the survey for editing
          final surveyToEdit = allSurveys[actualIndex];
          await navigator.push(
            MaterialPageRoute(
              builder: (context) => SurveyFormScreen(
                studentId: widget.studentId,
                existingSurvey: surveyToEdit,
                surveyIndex: actualIndex,
              ),
            ),
          );
          if (mounted) {
            _loadSurveys();
          }
        } else {
          if (mounted) {
            messenger.showSnackBar(
              const SnackBar(
                content: Text('Could not find survey to edit'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          messenger.showSnackBar(
            SnackBar(
              content: Text('Error opening edit: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
  }

  Future<void> _showApproveRejectDialog(SurveyData survey) async {
    // 1. Show selection dialog
    final action = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Select Action'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'approve'),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text('Approve Survey', style: TextStyle(fontSize: 16, color: Colors.green)),
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'reject'),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text('Reject Survey', style: TextStyle(fontSize: 16, color: Colors.red)),
            ),
          ),
        ],
      ),
    );

    if (action == null) return;

    // 2. Ask for Passkey
    final isAuthorized = await _promptForPasskey(action);
    if (!isAuthorized) return;

    // 3. Perform Action
    if (action == 'approve') {
       await _approveSurvey(survey);
    } else if (action == 'reject') {
       await _deleteSurvey(survey);
    }
  }

  Future<bool> _promptForPasskey(String action) async {
    final passwordController = TextEditingController();
    final actionLabel = action == 'approve' ? 'Approve' : 'Reject';
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$actionLabel Survey'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Enter Teacher Password to $action:'),
            const SizedBox(height: 8),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Password',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
               if (passwordController.text == 'admin123') { 
                 Navigator.pop(context, true);
               } else {
                 ScaffoldMessenger.of(context).showSnackBar(
                   const SnackBar(content: Text('Incorrect Password')),
                 );
               }
            },
            child: Text(actionLabel),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _approveSurvey(SurveyData survey) async {
      survey.isApproved = true;
      if (survey.id != null) {
         await _storageService.updateSurvey(survey);
         _loadSurveys();
         if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Survey Approved Successfully')),
           );
         }
      } else {
         // Handle case where ID is null if needed, though unlikely for saved survey
          ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Error: Survey ID not found')),
           );
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student: ${widget.studentId}', style: const TextStyle(fontSize: 18)),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSurveys,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FAQScreen()),
              );
            },
            tooltip: 'Help & FAQs',
          ),
          IconButton(
            icon: const Icon(Icons.book),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AnnexuresScreen()),
              );
            },
            tooltip: 'Annexures',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
              }
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text(
                            'Total Surveys',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          Text(
                            '${_surveys.length}',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _surveys.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.inbox,
                                size: 64,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'No surveys yet',
                                style: TextStyle(fontSize: 18, color: Colors.grey),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SurveyFormScreen(studentId: widget.studentId),
                                    ),
                                  ).then((_) => _loadSurveys());
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('Create New Survey', style: TextStyle(fontSize: 16)),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadSurveys,
                          child: ListView.builder(
                            itemCount: _surveys.length,
                            itemBuilder: (context, index) {
                              final survey = _surveys[index];
                                return Card(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: Theme.of(context).colorScheme.primary,
                                            child: Text(
                                              '${index + 1}',
                                              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                                            ),
                                          ),
                                          if (survey.isApproved)
                                            const Chip(
                                              label: Text('Approved', style: TextStyle(color: Colors.white)),
                                              backgroundColor: Colors.green,
                                            )
                                          else
                                            ActionChip(
                                              label: const Text('Approve / Reject'),
                                              backgroundColor: Colors.orange,
                                              onPressed: () => _showApproveRejectDialog(survey),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        survey.headOfFamily ?? 'Unknown Family',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text('Area: ${survey.areaName ?? 'N/A'}', style: const TextStyle(fontSize: 14)),
                                      if (survey.surveyDate != null)
                                        Text(
                                          'Date: ${survey.surveyDate!.day}/${survey.surveyDate!.month}/${survey.surveyDate!.year}',
                                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                                        ),
                                      const Divider(),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.visibility),
                                            tooltip: 'View',
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => SurveyDetailScreen(
                                                    survey: survey,
                                                    index: index,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.edit, color: survey.isApproved ? Colors.grey : null),
                                            tooltip: 'Edit',
                                            onPressed: () async {
                                              if (survey.isApproved) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('Approved surveys cannot be edited')),
                                                );
                                                return;
                                              }
                                              // Edit Logic
                                              await _handleEdit(survey);
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SurveyFormScreen(studentId: widget.studentId),
            ),
          ).then((_) => _loadSurveys());
        },
        icon: const Icon(Icons.add),
        label: const Text('New Survey', style: TextStyle(fontSize: 16)),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
    );
  }
}

