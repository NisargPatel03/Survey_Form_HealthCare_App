import 'package:flutter/material.dart';
import '../models/survey_data.dart';
import '../services/storage_service.dart';
import '../widgets/survey_sections.dart';
import '../widgets/survey_sections_2.dart';
import '../widgets/survey_sections_3.dart';
import '../widgets/survey_sections_4.dart';
import '../widgets/survey_sections_5.dart';
import '../utils/validation_helper.dart';

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
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
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
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                    const Color(0xFFF0F4F7),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              padding: const EdgeInsets.all(20),
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
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: (_currentSection + 1) / _sections.length,
                      backgroundColor: Theme.of(context).colorScheme.outline,
                      valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _sections[_currentSection],
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.primary,
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
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x33B0BEC5),
                    blurRadius: 8,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentSection > 0)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _currentSection--;
                          });
                        },
                        icon: const Icon(Icons.arrow_back, size: 18),
                        label: const Text('Previous', style: TextStyle(fontSize: 14), overflow: TextOverflow.ellipsis),
                      ),
                    ),
                  if (_currentSection > 0)
                    const SizedBox(width: 16),
                  if (_currentSection < _sections.length - 1)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _currentSection++;
                          });
                        },
                        icon: const Icon(Icons.arrow_forward, size: 18),
                        label: const Text('Next', style: TextStyle(fontSize: 14), overflow: TextOverflow.ellipsis),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _submitSurvey,
                        icon: const Icon(Icons.save, size: 18),
                        label: Text(_isEditing ? 'Update' : 'Submit', style: const TextStyle(fontSize: 14), overflow: TextOverflow.ellipsis),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                        ),
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
      // Custom validation for all sections
      String? validationError = ValidationHelper.validateSurvey(_surveyData);
      if (validationError != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(validationError),
              backgroundColor: Theme.of(context).colorScheme.error,
              duration: const Duration(seconds: 4),
            ),
          );
        }
        return;
      }

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
              backgroundColor: const Color(0xFF4CAF50),
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving survey: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }
}

