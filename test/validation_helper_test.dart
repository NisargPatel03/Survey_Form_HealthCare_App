import 'package:flutter_test/flutter_test.dart';
import 'package:community_health_care_survey/models/survey_data.dart'; // Adjust import based on package name
import 'package:community_health_care_survey/utils/validation_helper.dart';

void main() {
  group('ValidationHelper', () {
    test('should return error for empty Section 1 fields', () {
      final data = SurveyData();
      final result = ValidationHelper.validateSurvey(data);
      expect(result, contains('Section 1'));
    });

    test('should return error for Section 2 when Section 1 is filled', () {
      final data = SurveyData();
      // Fill Section 1
      data.houseNo = '123';
      data.aadharNumber = '123456789012';
      data.areaName = 'Test Area';
      data.areaType = 'Rural';
      data.healthCentreName = 'HC';
      data.headOfFamily = 'Head';
      data.familyType = 'Nuclear';
      data.religion = 'Hindu';
      data.subCaste = 'SC';

      final result = ValidationHelper.validateSurvey(data);
      expect(result, contains('Section 2'));
    });

    test('should pass validation when all mandatory fields are filled', () {
      final data = SurveyData();
      // Section 1
      data.houseNo = '123';
      data.aadharNumber = '123456789012';
      data.areaName = 'Test Area';
      data.areaType = 'Rural';
      data.healthCentreName = 'HC';
      data.headOfFamily = 'Head';
      data.familyType = 'Nuclear';
      data.religion = 'Hindu';
      data.subCaste = 'SC';
      
      // Section 2
      data.houseType = 'Pucca';
      data.numberOfRooms = 2;
      data.roomAdequacy = 'Adequate';
      data.occupancy = 'Owner';
      data.ventilation = 'Adequate';
      data.lighting = 'Electricity';
      data.waterSupply = 'Tap';
      data.kitchen = 'Separate';
      data.drainage = 'Adequate';
      data.lavatory = 'Own Latrine';

      // Section 3
      data.familyMembers.add(FamilyMember(
        name: 'Member',
        relationship: 'Self',
        age: 30,
        gender: 'Male',
        education: 'Graduate',
        occupation: 'Service',
        healthStatus: 'Good',
      ));

      // Section 4
      data.totalIncome = 50000;
      data.socioEconomicClass = 'Class 1';

      // Section 5
      data.communicationMedia.add('Mobile');
      data.transportOptions.add('Bike');
      data.motherTongue = 'Gujarati';
      data.languagesKnown.add('Gujarati');

      // Section 6
      // Empty map is fine if keys iterate? No, map is empty by default? 
      // Widget initializes it. We must simulate that.
      data.dietaryPattern['Rice'] = DietaryInfo(available: true, ideal: true);

      // Section 7
      data.expenditureItems.add(ExpenditureItem(item: 'Food', amount: 500, percentage: 10));

      // Section 9
      data.healthKnowledgeAttitude = 'Good';
      data.nutritionKnowledgeAttitude = 'Good';
      data.healthServiceUtilizationList = ['Hospital'];
      data.communityLeaders = 'Leader';

      // Section 15
      data.sewageDisposalHygienic = true;
      data.sewageDisposalReason = 'Sewer';
      data.wasteDisposalMethods.add('Burning');
      data.excretaDisposalHygienic = true;
      data.cattlePoultryHygienic = true;
      data.cattlePoultryHousing = 'separate';
      data.hasWellOrHandPump = true;
      data.wellMaintained = true;
      data.wellChlorinationDate = '01/01/2023'; // Optional?
      data.houseKeptClean = true;
      // data.houseSprayDate...

      // Section 16
      data.treatmentLocation = 'Hospital';
      data.officialHealthAgenciesAdequate = true;
      data.hasHealthInsurance = true;
      data.healthInsuranceDetails = 'LIC';
      data.medicinePurchaseLocation = 'Store';
      data.medicineCompliance = 'Complete';

      // Section 17
      data.familyStrengths.add('Unity');
      data.familyWeaknesses.add('None');
      data.applicableProgrammes.add('None');

      // Section 18
      data.contactNumber = '1234567890';
      data.surveyDate = DateTime.now();
      data.studentName = 'Student';
      data.studentSignature = 'Sign';

      final result = ValidationHelper.validateSurvey(data);
      if (result != null) print('Validation failed with: $result');
      expect(result, isNull);
    });
  });
}
