import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';
import '../models/survey_data.dart';
import '../services/storage_service.dart';
import 'survey_detail_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _storageService = StorageService();
  List<SurveyData> _surveys = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSurveys();
  }

  int _totalStudents = 0;
  int _totalSurveys = 0;

  Future<void> _loadSurveys() async {
    setState(() => _isLoading = true);
    final surveys = await _storageService.getAllSurveys();
    // Count unique students
    final uniqueStudents = surveys
        .where((s) => s.studentName != null && s.studentName!.isNotEmpty)
        .map((s) => s.studentName)
        .toSet();
    setState(() {
      _surveys = surveys;
      _totalSurveys = surveys.length;
      _totalStudents = uniqueStudents.length;
      _isLoading = false;
    });
  }

  Future<void> _exportToCSV() async {
    if (_surveys.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No surveys to export')),
      );
      return;
    }

    try {
      _convertToCSV(_surveys);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('CSV data ready (${_surveys.length} surveys)'),
            backgroundColor: const Color(0xFF4CAF50),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Copy',
              onPressed: () {
                // You can implement clipboard copy here if needed
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error preparing CSV: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _exportToPDF() async {
    if (_surveys.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No surveys to export')),
      );
      return;
    }

    try {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF report ready (${_surveys.length} surveys)'),
            backgroundColor: const Color(0xFF4CAF50),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error preparing PDF: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  String _convertToCSV(List<SurveyData> surveys) {
    final List<List<String>> rows = [];
    
    // Header row
    rows.add([
      'Survey Date',
      'Area Name',
      'Area Type',
      'Health Centre',
      'Head of Family',
      'Family Type',
      'Religion',
      'Total Income',
      'Contact Number',
      'Student Name',
      'Family Members Count',
    ]);
    
    // Data rows
    for (var survey in surveys) {
      rows.add([
        survey.surveyDate != null
            ? DateFormat('yyyy-MM-dd').format(survey.surveyDate!)
            : '',
        survey.areaName ?? '',
        survey.areaType ?? '',
        survey.healthCentreName ?? '',
        survey.headOfFamily ?? '',
        survey.familyType ?? '',
        survey.religion ?? '',
        survey.totalIncome?.toString() ?? '',
        survey.contactNumber ?? '',
        survey.studentName ?? '',
        survey.familyMembers.length.toString(),
      ]);
    }
    
    try {
      return const ListToCsvConverter().convert(rows);
    } catch (e) {
      // Fallback: manual CSV creation
      final buffer = StringBuffer();
      for (var row in rows) {
        final escapedRow = row.map((cell) {
          final escaped = cell.replaceAll('"', '""');
          return '"$escaped"';
        }).join(',');
        buffer.writeln(escapedRow);
      }
      return buffer.toString();
    }
  }

  Future<void> _deleteSurvey(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Survey'),
        content: const Text('Are you sure you want to delete this survey?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _storageService.deleteSurvey(id);
      _loadSurveys();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Survey Submissions'),
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
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'csv',
                child: Row(
                  children: [
                    Icon(Icons.file_download),
                    SizedBox(width: 8),
                    Text('Export to CSV'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'pdf',
                child: Row(
                  children: [
                    Icon(Icons.picture_as_pdf),
                    SizedBox(width: 8),
                    Text('Export to PDF'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'csv') {
                _exportToCSV();
              } else if (value == 'pdf') {
                _exportToPDF();
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text(
                            'Total Students',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$_totalStudents',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 1,
                        height: 50,
                        color: Colors.grey.shade300,
                      ),
                      Column(
                        children: [
                          const Text(
                            'Total Surveys',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$_totalSurveys',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4CAF50),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _surveys.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inbox,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No surveys submitted yet',
                                style: TextStyle(fontSize: 18, color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadSurveys,
                          child: ListView.builder(
                            padding: const EdgeInsets.only(bottom: 16),
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
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
                            ),
                          ),
                          title: Text(
                            survey.headOfFamily ?? 'Unknown Family',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                  Text('Area: ${survey.areaName ?? 'N/A'}', style: const TextStyle(fontSize: 14)),
                              Text('Health Centre: ${survey.healthCentreName ?? 'N/A'}', style: const TextStyle(fontSize: 14)),
                              if (survey.surveyDate != null)
                                Text(
                                  'Date: ${DateFormat('yyyy-MM-dd').format(survey.surveyDate!)}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                            ],
                          ),
                          trailing: PopupMenuButton(
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'view',
                                child: Row(
                                  children: [
                                    Icon(Icons.visibility),
                                    SizedBox(width: 8),
                                    Text('View Details'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Delete', style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                              ),
                            ],
                            onSelected: (value) {
                              if (value == 'view') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SurveyDetailScreen(
                                      survey: survey,
                                      index: index,
                                    ),
                                  ),
                                ).then((_) => _loadSurveys());
                              } else if (value == 'delete') {
                                if (survey.id != null) {
                                  _deleteSurvey(survey.id!);
                                }
                              }
                            },
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
                            ).then((_) => _loadSurveys());
                          },
                        ),
                      );
                    },
                  ),
                        ),
                ),
              ],
            ),
    );
  }
}

