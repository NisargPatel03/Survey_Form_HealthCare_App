import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/survey_data.dart';
import '../services/storage_service.dart';
import '../services/sync_service.dart';
import 'survey_form_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'survey_detail_screen.dart';
import 'faq_screen.dart';
import 'annexures_screen.dart';
import 'academic_details_screen.dart';
import '../models/course_requirement.dart';
import 'dynamic_form_screen.dart';

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
  String? _academicYear;
  String? _semester;
  String? _courseName;
  int _unreadCount = 0;
  List<Map<String, dynamic>> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadAcademicDetails();
    _initialSync();
    _fetchNotifications();
  }

  Future<void> _loadAcademicDetails() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _academicYear = prefs.getString('academicYear_${widget.studentId}');
        _semester = prefs.getString('semester_${widget.studentId}');
        _courseName = prefs.getString('courseName_${widget.studentId}');
      });
    }

    try {
      final response = await Supabase.instance.client
          .from('profiles')
          .select('semester, academic_year')
          .eq('student_id', widget.studentId)
          .maybeSingle();

      if (response != null) {
        final serverSemester = response['semester'] as String?;
        final serverYear = response['academic_year'] as String?;
        
        if (serverSemester != null && serverYear != null) {
          final localSemester = prefs.getString('semester_${widget.studentId}');
          final localYear = prefs.getString('academicYear_${widget.studentId}');
          
          if (serverSemester != localSemester || serverYear != localYear) {
            String serverCourse = '';
            if (serverSemester == '5th Sem') {
              serverCourse = 'NUR 303 - Community Health Nursing - I';
            } else if (serverSemester == '7th Sem') {
              serverCourse = 'NUR 401 - Community Health Nursing - II';
            }
            
            await prefs.setString('semester_${widget.studentId}', serverSemester);
            await prefs.setString('academicYear_${widget.studentId}', serverYear);
            await prefs.setString('courseName_${widget.studentId}', serverCourse);
            
            if (mounted) {
              setState(() {
                _semester = serverSemester;
                _academicYear = serverYear;
                _courseName = serverCourse;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Academic records updated: Promoted to $serverSemester ($serverYear)'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          }
        }
      }
    } catch (e) {
      print('Error syncing academic details from server: $e');
    }
  }

  Future<void> _fetchNotifications() async {
    try {
      final data = await Supabase.instance.client
          .from('notifications')
          .select('*')
          .eq('student_id', widget.studentId)
          .order('created_at', ascending: false);
      
      if (mounted) {
        setState(() {
          _notifications = List<Map<String, dynamic>>.from(data);
          _unreadCount = _notifications.where((n) => n['is_read'] == false).length;
        });
      }
    } catch (e) {
      print('Error fetching notifications: $e');
    }
  }

  Future<void> _markNotificationsAsRead() async {
    if (_unreadCount == 0) return;
    try {
      await Supabase.instance.client
          .from('notifications')
          .update({'is_read': true})
          .eq('student_id', widget.studentId);
      
      if (mounted) {
        setState(() {
          _unreadCount = 0;
          for (var n in _notifications) {
            n['is_read'] = true;
          }
        });
      }
    } catch (e) {
      print('Error marking notifications as read: $e');
    }
  }

  void _showNotificationsDialog() {
    _markNotificationsAsRead();
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              titlePadding: const EdgeInsets.fromLTRB(24, 20, 16, 0),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Notifications',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              content: SizedBox(
                width: double.maxFinite,
                height: 350,
                child: _notifications.isEmpty
                    ? const Center(
                        child: Text(
                          'No notifications yet',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _notifications.length,
                        itemBuilder: (context, index) {
                          final n = _notifications[index];
                          final createdAt = DateTime.parse(n['created_at']).toLocal();
                          final dateStr = '${createdAt.day}/${createdAt.month}/${createdAt.year} ${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
                          
                          return Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Colors.grey.shade200),
                              ),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: n['title'].toString().contains('Promotion') 
                                    ? Colors.amber.shade100 
                                    : Colors.blue.shade100,
                                child: Icon(
                                  n['title'].toString().contains('Promotion') 
                                      ? Icons.military_tech
                                      : Icons.assignment_turned_in,
                                  color: n['title'].toString().contains('Promotion') 
                                      ? Colors.amber.shade900 
                                      : Colors.blue.shade900,
                                ),
                              ),
                              title: Text(
                                n['title'] ?? 'Notification',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    n['message'] ?? '',
                                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    dateStr,
                                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close', style: TextStyle(fontSize: 16)),
                ),
              ],
            );
          },
        );
      },
    );
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

  List<CourseRequirement> get _currentRequirements {
    if (_semester == '5th Sem') return CourseRequirementsData.nur303;
    if (_semester == '7th Sem') return CourseRequirementsData.nur401;
    return [];
  }

  List<Widget> _buildGroupedRequirements() {
    final List<Widget> items = [];
    final requirements = _currentRequirements;
    if (requirements.isEmpty) {
      return [const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('No requirements available yet.')))];
    }
    
    String? currentPostingType;
    for (var i = 0; i < requirements.length; i++) {
      final req = requirements[i];
      if (req.postingType != currentPostingType) {
        currentPostingType = req.postingType;
        items.add(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.blue.shade100,
            child: Text(
              currentPostingType,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue.shade900),
            ),
          ),
        );
      }
      items.add(
        ListTile(
          leading: CircleAvatar(
            backgroundColor: req.isSurvey ? Colors.green.shade100 : Colors.blue.shade50,
            child: Text(req.srNo, style: TextStyle(fontSize: 12, color: req.isSurvey ? Colors.green.shade800 : Colors.blue.shade900)),
          ),
          title: Text(req.name, style: TextStyle(fontWeight: req.isSurvey ? FontWeight.bold : FontWeight.normal)),
          subtitle: Text(req.category),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Qty: ${req.quantity}'),
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward_ios, size: 14, color: Colors.blue.shade300),
            ],
          ),
          onTap: () {
            if (req.isSurvey) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SurveyFormScreen(studentId: widget.studentId)),
              ).then((_) => _loadSurveys());
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DynamicFormScreen(
                    studentId: widget.studentId,
                    courseName: _courseName ?? 'Unknown',
                    semester: _semester ?? '5th Sem',
                    requirementSrNo: req.srNo,
                  ),
                ),
              );
            }
          },
        ),
      );
      if (i < requirements.length - 1 && requirements[i + 1].postingType == currentPostingType) {
         items.add(const Divider(height: 1));
      }
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Student: ${widget.studentId}', style: const TextStyle(fontSize: 18)),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(icon: Icon(Icons.assignment), text: 'My Surveys'),
              Tab(icon: Icon(Icons.checklist), text: 'Requirements'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                _loadSurveys();
                _loadAcademicDetails();
                _fetchNotifications();
              },
              tooltip: 'Refresh',
            ),
            Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications),
                  onPressed: _showNotificationsDialog,
                  tooltip: 'Notifications',
                ),
                if (_unreadCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 14,
                        minHeight: 14,
                      ),
                      child: Text(
                        '$_unreadCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
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
            : TabBarView(
                children: [
                  // Tab 1: Surveys
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${_academicYear ?? 'N/A'} | ${_semester ?? 'N/A'}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                  if (_courseName != null)
                                    Text(
                                      _courseName!,
                                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                const Text(
                                  'Total Surveys',
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                                Text(
                                  '${_surveys.length}',
                                  style: TextStyle(
                                    fontSize: 20,
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
                  // Tab 2: Requirements
                  Column(
                    children: [
                      Container(
                        width: double.infinity,
                        color: Colors.blue.shade50,
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        child: Text(
                          _semester == '5th Sem' 
                              ? 'Requirements: NUR 303 (Community Health Nursing - I)'
                              : _semester == '7th Sem' 
                                  ? 'Requirements: NUR 401 (Community Health Nursing - II)' 
                                  : 'Requirements',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView(
                          children: _buildGroupedRequirements(),
                        ),
                      ),
                    ],
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
      ),
    );
  }
}

