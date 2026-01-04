import 'package:flutter/material.dart';
import '../models/survey_data.dart';

// Section 16: Health Services
class HealthServicesSection extends StatefulWidget {
  final SurveyData surveyData;

  const HealthServicesSection({super.key, required this.surveyData});

  @override
  State<HealthServicesSection> createState() => _HealthServicesSectionState();
}

class _HealthServicesSectionState extends State<HealthServicesSection> {
  final _healthAgenciesReasonController = TextEditingController();
  final _healthInsuranceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _healthAgenciesReasonController.text = widget.surveyData.healthAgenciesReason ?? '';
    _healthInsuranceController.text = widget.surveyData.healthInsuranceDetails ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '30. If any one falls ill where do they go for treatment?',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        RadioListTile<String>(
          title: const Text('30.1 Hospital / Community Health Centre'),
          value: 'Hospital / Community Health Centre',
          groupValue: widget.surveyData.treatmentLocation,
          onChanged: (value) {
            setState(() => widget.surveyData.treatmentLocation = value);
          },
        ),
        RadioListTile<String>(
          title: const Text('30.2 Primary Health Centre/ Sub Health Centre'),
          value: 'Primary Health Centre/ Sub Health Centre',
          groupValue: widget.surveyData.treatmentLocation,
          onChanged: (value) {
            setState(() => widget.surveyData.treatmentLocation = value);
          },
        ),
        RadioListTile<String>(
          title: const Text('30.3 Private Nursing Home'),
          value: 'Private Nursing Home',
          groupValue: widget.surveyData.treatmentLocation,
          onChanged: (value) {
            setState(() => widget.surveyData.treatmentLocation = value);
          },
        ),
        RadioListTile<String>(
          title: const Text('30.4 Indigenous Doctor/ Local vaidya / Homeopathy / Ayurvedic'),
          value: 'Indigenous Doctor/ Local vaidya / Homeopathy / Ayurvedic',
          groupValue: widget.surveyData.treatmentLocation,
          onChanged: (value) {
            setState(() => widget.surveyData.treatmentLocation = value);
          },
        ),
        const SizedBox(height: 16),
        const Text(
          '31. Is official health agencies service adequate?',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        Row(
          children: [
            Radio<bool>(
              value: true,
              groupValue: widget.surveyData.officialHealthAgenciesAdequate,
              onChanged: (value) {
                setState(() => widget.surveyData.officialHealthAgenciesAdequate = value);
              },
            ),
            const Text('Yes'),
            Radio<bool>(
              value: false,
              groupValue: widget.surveyData.officialHealthAgenciesAdequate,
              onChanged: (value) {
                setState(() => widget.surveyData.officialHealthAgenciesAdequate = value);
              },
            ),
            const Text('No'),
          ],
        ),
        TextFormField(
          controller: _healthAgenciesReasonController,
          decoration: const InputDecoration(
            labelText: 'If no state reasons',
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
          onChanged: (value) => widget.surveyData.healthAgenciesReason = value,
        ),
        const SizedBox(height: 16),
        const Text(
          '32. Health insurance:',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        Row(
          children: [
            Radio<bool>(
              value: true,
              groupValue: widget.surveyData.hasHealthInsurance,
              onChanged: (value) {
                setState(() => widget.surveyData.hasHealthInsurance = value);
              },
            ),
            const Text('Yes'),
            Radio<bool>(
              value: false,
              groupValue: widget.surveyData.hasHealthInsurance,
              onChanged: (value) {
                setState(() => widget.surveyData.hasHealthInsurance = value);
              },
            ),
            const Text('No'),
          ],
        ),
        TextFormField(
          controller: _healthInsuranceController,
          decoration: const InputDecoration(
            labelText: 'Specify',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) => widget.surveyData.healthInsuranceDetails = value,
        ),
        const SizedBox(height: 16),
        const Text(
          '38. Where do they go to purchase the prescribed drug.',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        TextFormField(
          initialValue: widget.surveyData.medicinePurchaseLocation,
          decoration: const InputDecoration(
            labelText: 'Location',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) => widget.surveyData.medicinePurchaseLocation = value,
        ),
        const SizedBox(height: 16),
        const Text(
          '38.1 Compliance to medicine:',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        RadioListTile<String>(
          title: const Text('1. Complete'),
          value: 'Complete',
          groupValue: widget.surveyData.medicineCompliance,
          onChanged: (value) {
            setState(() => widget.surveyData.medicineCompliance = value);
          },
        ),
        RadioListTile<String>(
          title: const Text('2. Partial/ Few dose'),
          value: 'Partial/ Few dose',
          groupValue: widget.surveyData.medicineCompliance,
          onChanged: (value) {
            setState(() => widget.surveyData.medicineCompliance = value);
          },
        ),
        RadioListTile<String>(
          title: const Text('3. Unfinished'),
          value: 'Unfinished',
          groupValue: widget.surveyData.medicineCompliance,
          onChanged: (value) {
            setState(() => widget.surveyData.medicineCompliance = value);
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _healthAgenciesReasonController.dispose();
    _healthInsuranceController.dispose();
    super.dispose();
  }
}

// Section 17: Family Assessment
class FamilyAssessmentSection extends StatefulWidget {
  final SurveyData surveyData;

  const FamilyAssessmentSection({super.key, required this.surveyData});

  @override
  State<FamilyAssessmentSection> createState() => _FamilyAssessmentSectionState();
}

class _FamilyAssessmentSectionState extends State<FamilyAssessmentSection> {
  final List<String> _strengthOptions = [
    'Good Interpersonal relationship',
    'Positive attitude and response',
    'Good communication',
    'Good behavior with naivous',
    'Good relation with community',
  ];

  final List<String> _weaknessOptions = [
    'Lack of awareness about their health condition',
    'Breeding of insects around the house & in house',
    'Not well managed house condition',
    'Poor hygiene',
    'Not proper use of food hygiene',
  ];

  final List<String> _programmeOptions = [
    'National vector house disease control programme',
    'Suatish khazat district',
    'Kuvkman khazat region',
    'Madhu wants local know young',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '35. Strength of the family.',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ..._strengthOptions.map((option) {
            return CheckboxListTile(
              title: Text(option),
              value: widget.surveyData.familyStrengths.contains(option),
              onChanged: (value) {
                setState(() {
                  if (value ?? false) {
                    widget.surveyData.familyStrengths.add(option);
                  } else {
                    widget.surveyData.familyStrengths.remove(option);
                  }
                });
              },
            );
          }).toList(),
          const SizedBox(height: 16),
          const Text(
            '36. Weakness of the family.',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ..._weaknessOptions.map((option) {
            return CheckboxListTile(
              title: Text(option),
              value: widget.surveyData.familyWeaknesses.contains(option),
              onChanged: (value) {
                setState(() {
                  if (value ?? false) {
                    widget.surveyData.familyWeaknesses.add(option);
                  } else {
                    widget.surveyData.familyWeaknesses.remove(option);
                  }
                });
              },
            );
          }).toList(),
          const SizedBox(height: 16),
          const Text(
            '37. National health programme applicable to the family.',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ..._programmeOptions.map((option) {
            return CheckboxListTile(
              title: Text(option),
              value: widget.surveyData.applicableProgrammes.contains(option),
              onChanged: (value) {
                setState(() {
                  if (value ?? false) {
                    widget.surveyData.applicableProgrammes.add(option);
                  } else {
                    widget.surveyData.applicableProgrammes.remove(option);
                  }
                });
              },
            );
          }).toList(),
        ],
      ),
    );
  }
}

// Section 18: Final Details
class FinalDetailsSection extends StatefulWidget {
  final SurveyData surveyData;

  const FinalDetailsSection({super.key, required this.surveyData});

  @override
  State<FinalDetailsSection> createState() => _FinalDetailsSectionState();
}

class _FinalDetailsSectionState extends State<FinalDetailsSection> {
  final _contactController = TextEditingController();
  final _studentNameController = TextEditingController();
  final _studentSignatureController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _contactController.text = widget.surveyData.contactNumber ?? '';
    _studentNameController.text = widget.surveyData.studentName ?? '';
    _studentSignatureController.text = widget.surveyData.studentSignature ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '39. Contact Number of head of the family.',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _contactController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Contact Number',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) => widget.surveyData.contactNumber = value,
        ),
        const SizedBox(height: 24),
        const Text(
          'Survey Completion Details:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ListTile(
          title: const Text('Date of survey'),
          subtitle: Text(widget.surveyData.surveyDate != null
              ? '${widget.surveyData.surveyDate!.day}/${widget.surveyData.surveyDate!.month}/${widget.surveyData.surveyDate!.year}'
              : 'Not set'),
          trailing: const Icon(Icons.calendar_today),
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
            );
            if (date != null) {
              setState(() => widget.surveyData.surveyDate = date);
            }
          },
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _studentNameController,
          decoration: const InputDecoration(
            labelText: 'Name and signature of the student',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) => widget.surveyData.studentName = value,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _studentSignatureController,
          decoration: const InputDecoration(
            labelText: 'Student Signature',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) => widget.surveyData.studentSignature = value,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _contactController.dispose();
    _studentNameController.dispose();
    _studentSignatureController.dispose();
    super.dispose();
  }
}

