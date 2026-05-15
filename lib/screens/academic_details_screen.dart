import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/course_requirement.dart';
import 'student_dashboard_screen.dart';

class AcademicDetailsScreen extends StatefulWidget {
  final String studentId;

  const AcademicDetailsScreen({super.key, required this.studentId});

  @override
  State<AcademicDetailsScreen> createState() => _AcademicDetailsScreenState();
}

class _AcademicDetailsScreenState extends State<AcademicDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedYear;
  String? _selectedSemester;

  final List<String> _academicYears = [
    '2024-25', '2025-26', '2026-27', '2027-28', '2028-29', 
    '2029-30', '2030-31', '2031-32', '2032-33', '2033-34', '2034-35'
  ];
  final List<String> _semesters = ['5th Sem', '7th Sem'];

  List<CourseRequirement> _currentRequirements = [];

  void _onSemesterChanged(String? newValue) {
    setState(() {
      _selectedSemester = newValue;
      if (newValue == '5th Sem') {
        _currentRequirements = CourseRequirementsData.nur303;
      } else if (newValue == '7th Sem') {
        _currentRequirements = CourseRequirementsData.nur401;
      } else {
        _currentRequirements = [];
      }
    });
  }

  Future<void> _saveAndContinue() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('academicYear_${widget.studentId}', _selectedYear!);
    await prefs.setString('semester_${widget.studentId}', _selectedSemester!);
    
    final courseName = _selectedSemester == '5th Sem' 
        ? 'NUR 303 - Community Health Nursing - I' 
        : 'NUR 401 - Community Health Nursing - II';
    await prefs.setString('courseName_${widget.studentId}', courseName);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => StudentDashboardScreen(studentId: widget.studentId),
        ),
      );
    }
  }

  List<Widget> _buildGroupedRequirements() {
    final List<Widget> items = [];
    String? currentPostingType;

    for (var i = 0; i < _currentRequirements.length; i++) {
      final req = _currentRequirements[i];
      if (req.postingType != currentPostingType) {
        currentPostingType = req.postingType;
        items.add(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.blue.shade100,
            child: Text(
              currentPostingType,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.blue.shade900,
              ),
            ),
          ),
        );
      }
      items.add(
        ListTile(
          leading: CircleAvatar(
            backgroundColor: req.isSurvey ? Colors.green.shade100 : Colors.blue.shade50,
            child: Text(
              req.srNo,
              style: TextStyle(fontSize: 12, color: req.isSurvey ? Colors.green.shade800 : Colors.blue.shade900),
            ),
          ),
          title: Text(req.name, style: TextStyle(fontWeight: req.isSurvey ? FontWeight.bold : FontWeight.normal)),
          subtitle: Text(req.category),
          trailing: Text('Qty: ${req.quantity}'),
        ),
      );
      if (i < _currentRequirements.length - 1 && _currentRequirements[i + 1].postingType == currentPostingType) {
         items.add(const Divider(height: 1));
      }
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Academic Details'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Please select your Academic Year and Semester to view course requirements.',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Academic Year',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_month),
                    ),
                    value: _selectedYear,
                    items: _academicYears.map((year) {
                      return DropdownMenuItem(value: year, child: Text(year));
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedYear = val),
                    validator: (val) => val == null ? 'Please select Academic Year' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Semester',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.school),
                    ),
                    value: _selectedSemester,
                    items: _semesters.map((sem) {
                      return DropdownMenuItem(value: sem, child: Text(sem));
                    }).toList(),
                    onChanged: _onSemesterChanged,
                    validator: (val) => val == null ? 'Please select Semester' : null,
                  ),
                ],
              ),
            ),
            if (_currentRequirements.isNotEmpty) ...[
              Container(
                width: double.infinity,
                color: Colors.blue.shade50,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Text(
                  _selectedSemester == '5th Sem' 
                      ? 'Requirements: NUR 303 (Community Health Nursing - I)'
                      : 'Requirements: NUR 401 (Community Health Nursing - II)',
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
            ] else ...[
              const Expanded(child: Center(child: Text('Select a semester to view requirements.'))),
            ],
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveAndContinue,
                  style: ElevatedButton.styleFrom(
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: const Text('Confirm & Continue'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
