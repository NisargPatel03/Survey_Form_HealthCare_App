import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/survey_data.dart';

class SurveyDetailScreen extends StatelessWidget {
  final SurveyData survey;
  final int index;

  const SurveyDetailScreen({
    super.key,
    required this.survey,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Survey #${index + 1}'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection('Basic Information', [
              _buildInfoRow('House No.', survey.houseNo),
              _buildInfoRow('Aadhar Number', survey.aadharNumber),
              _buildInfoRow('Area Name', survey.areaName),
              _buildInfoRow('Area Type', survey.areaType),
              _buildInfoRow('Health Centre', survey.healthCentreName),
              _buildInfoRow('Head of Family', survey.headOfFamily),
              _buildInfoRow('Family Type', survey.familyType),
              _buildInfoRow('Religion', survey.religion),
              _buildInfoRow('Sub Caste', survey.subCaste),
            ]),
            const SizedBox(height: 16),
            _buildSection('Housing Condition', [
              _buildInfoRow('House Type', survey.houseType),
              _buildInfoRow('Number of Rooms', survey.numberOfRooms?.toString()),
              _buildInfoRow('Room Adequacy', survey.roomAdequacy),
              _buildInfoRow('Occupancy', survey.occupancy),
              _buildInfoRow('Ventilation', survey.ventilation),
              _buildInfoRow('Lighting', survey.lighting),
              _buildInfoRow('Water Supply', survey.waterSupply),
              _buildInfoRow('Kitchen', survey.kitchen),
              _buildInfoRow('Drainage', survey.drainage),
              _buildInfoRow('Lavatory', survey.lavatory),
            ]),
            const SizedBox(height: 16),
            _buildSection('Family Composition', [
              Text('Total Members: ${survey.familyMembers.length}'),
              ...survey.familyMembers.map((member) => Card(
                    margin: const EdgeInsets.only(top: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Name: ${member.name}'),
                          Text('Relationship: ${member.relationship}'),
                          Text('Age: ${member.age}'),
                          Text('Gender: ${member.gender}'),
                          Text('Education: ${member.education}'),
                          Text('Occupation: ${member.occupation}'),
                          Text('Income: ${member.income ?? 'N/A'}'),
                          Text('Health Status: ${member.healthStatus}'),
                        ],
                      ),
                    ),
                  )),
            ]),
            const SizedBox(height: 16),
            _buildSection('Income & Socio-economic', [
              _buildInfoRow('Total Income', survey.totalIncome?.toString()),
              _buildInfoRow('Socio-economic Class', survey.socioEconomicClass),
            ]),
            const SizedBox(height: 16),
            _buildSection('Transport & Communication', [
              _buildInfoRow('Transport Options', survey.transportOptions.join(', ')),
              _buildInfoRow('Communication Media', survey.communicationMedia.join(', ')),
              _buildInfoRow('Mother Tongue', survey.motherTongue),
              _buildInfoRow('Languages Known', survey.languagesKnown.join(', ')),
            ]),
            const SizedBox(height: 16),
            _buildSection('Health Conditions', [
              if (survey.nonCommunicableDiseases.isNotEmpty)
                _buildInfoRow('Non-Communicable', survey.nonCommunicableDiseases.join(', ')),
              if (survey.communicableDiseases.isNotEmpty)
                _buildInfoRow('Communicable', survey.communicableDiseases.join(', ')),
              Text('Fever Cases: ${survey.feverCases.length}'),
              Text('Skin Diseases: ${survey.skinDiseases.length}'),
              Text('Cough Cases: ${survey.coughCases.length}'),
              Text('Other Illnesses: ${survey.otherIllnesses.length}'),
            ]),
            const SizedBox(height: 16),
            _buildSection('Vital Statistics', [
              Text('Births: ${survey.births.length}'),
              Text('Deaths: ${survey.deaths.length}'),
              Text('Marriages: ${survey.marriages.length}'),
            ]),
            const SizedBox(height: 16),
            _buildSection('Immunization', [
              Text('Children Records: ${survey.immunizationRecords.length}'),
            ]),
            const SizedBox(height: 16),
            _buildSection('Eligible Couples', [
              Text('Total Couples: ${survey.eligibleCouples.length}'),
              _buildInfoRow('Contraceptive Method', survey.contraceptiveMethod),
            ]),
            const SizedBox(height: 16),
            _buildSection('Malnutrition', [
              Text('Cases: ${survey.malnutritionCases.length}'),
            ]),
            const SizedBox(height: 16),
            _buildSection('Health Services', [
              _buildInfoRow('Treatment Location', survey.treatmentLocations.join(', ')),
              _buildInfoRow('Health Agencies Adequate', survey.officialHealthAgenciesAdequate?.toString()),
              _buildInfoRow('Has Health Insurance', survey.hasHealthInsurance?.toString()),
              _buildInfoRow('Medicine Purchase Location', survey.medicinePurchaseLocation),
              _buildInfoRow('Medicine Compliance', survey.medicineCompliance),
            ]),
            const SizedBox(height: 16),
            _buildSection('Contact & Details', [
              _buildInfoRow('Contact Number', survey.contactNumber),
              _buildInfoRow('Survey Date', survey.surveyDate != null
                  ? DateFormat('yyyy-MM-dd').format(survey.surveyDate!)
                  : null),
              _buildInfoRow('Student Name', survey.studentName),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value ?? 'N/A'),
          ),
        ],
      ),
    );
  }
}

