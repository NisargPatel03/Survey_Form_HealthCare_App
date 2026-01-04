import 'package:flutter/material.dart';
import '../models/survey_data.dart';
import '../services/storage_service.dart';
import '../widgets/survey_sections.dart';
import '../widgets/survey_sections_2.dart';
import '../widgets/survey_sections_3.dart';
import '../widgets/survey_sections_4.dart';
import '../widgets/survey_sections_5.dart';

class SurveyFormScreen extends StatefulWidget {
  final String? studentId;
  final SurveyData? existingSurvey;
  final int? surveyIndex;

  const SurveyFormScreen({super.key, this.studentId, this.existingSurvey, this.surveyIndex});

  @override
  State<SurveyFormScreen> createState() => _SurveyFormScreenState();
}

class _SurveyFormScreenState extends State<SurveyFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _storageService = StorageService();
  late SurveyData _surveyData;
  int _currentSection = 0;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.existingSurvey != null;
    _surveyData = widget.existingSurvey ?? SurveyData();
    if (!_isEditing && widget.studentId != null) {
      _surveyData.studentName = widget.studentId;
    }
  }

  final List<String> _sections = [
    'Basic Information',
    'Housing Condition',
    'Family Composition',
    'Income & Socio-economic',
    'Transport & Communication',
    'Dietary Pattern',
    'Expenditure',
    'Health Conditions',
    'Family Health Attitude',
    'Pregnant Women',
    'Vital Statistics',
    'Immunization',
    'Eligible Couples',
    'Malnutrition',
    'Environmental Health',
    'Health Services',
    'Family Assessment',
    'Final Details',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Survey' : 'Baseline Survey Form'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          if (_currentSection > 0)
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                setState(() {
                  _currentSection--;
                });
              },
            ),
          if (_currentSection < _sections.length - 1)
            IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: () {
                setState(() {
                  _currentSection++;
                });
              },
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Progress indicator
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.blue.shade50,
              child: Column(
                children: [
                  Text(
                    'Section ${_currentSection + 1} of ${_sections.length}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: (_currentSection + 1) / _sections.length,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _sections[_currentSection],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue.shade900,
                    ),
                  ),
                ],
              ),
            ),
            // Form content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: _buildSectionContent(),
              ),
            ),
            // Navigation buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentSection > 0)
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _currentSection--;
                        });
                      },
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Previous', style: TextStyle(fontSize: 16)),
                    )
                  else
                    const SizedBox(),
                  if (_currentSection < _sections.length - 1)
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _currentSection++;
                        });
                      },
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Next', style: TextStyle(fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                      ),
                    )
                  else
                    ElevatedButton.icon(
                      onPressed: _submitSurvey,
                      icon: const Icon(Icons.save),
                      label: Text(_isEditing ? 'Update Survey' : 'Submit Survey', style: const TextStyle(fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionContent() {
    switch (_currentSection) {
      case 0:
        return BasicInformationSection(surveyData: _surveyData);
      case 1:
        return HousingConditionSection(surveyData: _surveyData);
      case 2:
        return FamilyCompositionSection(surveyData: _surveyData);
      case 3:
        return IncomeSection(surveyData: _surveyData);
      case 4:
        return TransportCommunicationSection(surveyData: _surveyData);
      case 5:
        return DietaryPatternSection(surveyData: _surveyData);
      case 6:
        return ExpenditureSection(surveyData: _surveyData);
      case 7:
        return HealthConditionsSection(surveyData: _surveyData);
      case 8:
        return FamilyHealthAttitudeSection(surveyData: _surveyData);
      case 9:
        return PregnantWomenSection(surveyData: _surveyData);
      case 10:
        return VitalStatisticsSection(surveyData: _surveyData);
      case 11:
        return ImmunizationSection(surveyData: _surveyData);
      case 12:
        return EligibleCouplesSection(surveyData: _surveyData);
      case 13:
        return MalnutritionSection(surveyData: _surveyData);
      case 14:
        return EnvironmentalHealthSection(surveyData: _surveyData);
      case 15:
        return HealthServicesSection(surveyData: _surveyData);
      case 16:
        return FamilyAssessmentSection(surveyData: _surveyData);
      case 17:
        return FinalDetailsSection(surveyData: _surveyData);
      default:
        return const SizedBox();
    }
  }

  Future<void> _submitSurvey() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        if (_isEditing && widget.surveyIndex != null) {
          await _storageService.updateSurvey(widget.surveyIndex!, _surveyData);
        } else {
          await _storageService.saveSurvey(_surveyData);
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isEditing ? 'Survey updated successfully!' : 'Survey submitted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving survey: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

