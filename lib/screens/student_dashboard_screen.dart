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

  Future<void> _deleteSurvey(int index) async {
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
      // Find the actual index in all surveys
      final allSurveys = await _storageService.getAllSurveys();
      final surveyToDelete = _surveys[index];
      final actualIndex = allSurveys.indexWhere((s) => s == surveyToDelete);
      if (actualIndex >= 0) {
        await _storageService.deleteSurvey(actualIndex);
        _loadSurveys();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student: ${widget.studentId}', style: const TextStyle(fontSize: 18)),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
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
                  color: Colors.blue.shade50,
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
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
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
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.blue.shade700,
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(color: Colors.white, fontSize: 16),
                                    ),
                                  ),
                                  title: Text(
                                    survey.headOfFamily ?? 'Unknown Family',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Area: ${survey.areaName ?? 'N/A'}', style: const TextStyle(fontSize: 14)),
                                      if (survey.surveyDate != null)
                                        Text(
                                          'Date: ${survey.surveyDate!.day}/${survey.surveyDate!.month}/${survey.surveyDate!.year}',
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.visibility),
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
                                        onPressed: () async {
                                          if (!mounted) return;
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
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () => _deleteSurvey(index),
                                      ),
                                    ],
                                  ),
                                  onTap: () {
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
        backgroundColor: Colors.blue.shade700,
      ),
    );
  }
}

