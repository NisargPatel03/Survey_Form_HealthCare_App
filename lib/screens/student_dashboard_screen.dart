import 'package:flutter/material.dart';
import '../models/survey_data.dart';
import '../services/storage_service.dart';
import 'survey_form_screen.dart';
import 'survey_detail_screen.dart';

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
    _loadSurveys();
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

  Future<void> _deleteSurvey(int index, SurveyData survey) async {
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
      final allSurveys = await _storageService.getAllSurveys();
      // Robust matching
      final actualIndex = allSurveys.indexWhere((s) =>
          s.headOfFamily == survey.headOfFamily &&
          s.areaName == survey.areaName &&
          s.surveyDate?.millisecondsSinceEpoch == survey.surveyDate?.millisecondsSinceEpoch &&
          s.studentName == survey.studentName);
          
      if (actualIndex >= 0) {
        await _storageService.deleteSurvey(actualIndex);
        _loadSurveys();
      } else {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Could not find original survey to delete')),
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

  Future<void> _showApprovalDialog(SurveyData survey, int index) async {
    final passwordController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Survey'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter Teacher Password to approve:'),
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
               if (passwordController.text == 'admin123') { // Simple password
                 Navigator.pop(context, true);
               } else {
                 ScaffoldMessenger.of(context).showSnackBar(
                   const SnackBar(content: Text('Incorrect Password')),
                 );
               }
            },
            child: const Text('Approve'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      survey.isApproved = true;
      // We need to save this update to storage
       final allSurveys = await _storageService.getAllSurveys();
       final actualIndex = allSurveys.indexWhere((s) =>
          s.headOfFamily == survey.headOfFamily &&
          s.areaName == survey.areaName &&
          s.surveyDate?.millisecondsSinceEpoch == survey.surveyDate?.millisecondsSinceEpoch &&
          s.studentName == survey.studentName);
       
       if (actualIndex >= 0) {
         await _storageService.updateSurvey(actualIndex, survey);
         _loadSurveys();
         if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Survey Approved Successfully')),
           );
         }
       }
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
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
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
                                              label: const Text('Approve'),
                                              backgroundColor: Colors.orange,
                                              onPressed: () => _showApprovalDialog(survey, index),
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
                                            icon: const Icon(Icons.edit),
                                            tooltip: 'Edit',
                                            onPressed: () async {
                                              // Edit Logic
                                              await _handleEdit(survey);
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete, color: Colors.red),
                                            tooltip: 'Delete',
                                            onPressed: () => _deleteSurvey(index, survey),
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

