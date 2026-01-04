import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/survey_data.dart';

class StorageService {
  static const String _surveysKey = 'survey_submissions';

  Future<void> saveSurvey(SurveyData survey) async {
    final prefs = await SharedPreferences.getInstance();
    final surveys = await getAllSurveys();
    
    survey.surveyDate = DateTime.now();
    surveys.add(survey);
    
    final jsonList = surveys.map((s) => s.toJson()).toList();
    await prefs.setString(_surveysKey, jsonEncode(jsonList));
  }

  Future<List<SurveyData>> getAllSurveys() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_surveysKey);
    
    if (jsonString == null) {
      return [];
    }
    
    final jsonList = jsonDecode(jsonString) as List;
    return jsonList.map((json) => _surveyFromJson(json)).toList();
  }

  Future<void> deleteSurvey(int index) async {
    final surveys = await getAllSurveys();
    if (index >= 0 && index < surveys.length) {
      surveys.removeAt(index);
      final prefs = await SharedPreferences.getInstance();
      final jsonList = surveys.map((s) => s.toJson()).toList();
      await prefs.setString(_surveysKey, jsonEncode(jsonList));
    }
  }

  Future<void> updateSurvey(int index, SurveyData survey) async {
    final surveys = await getAllSurveys();
    if (index >= 0 && index < surveys.length) {
      survey.surveyDate = DateTime.now();
      surveys[index] = survey;
      final prefs = await SharedPreferences.getInstance();
      final jsonList = surveys.map((s) => s.toJson()).toList();
      await prefs.setString(_surveysKey, jsonEncode(jsonList));
    }
  }

  Future<void> clearAllSurveys() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_surveysKey);
  }

  SurveyData _surveyFromJson(Map<String, dynamic> json) {
    final survey = SurveyData();
    
    // Basic info
    survey.areaName = json['areaName'];
    survey.areaType = json['areaType'];
    survey.healthCentreName = json['healthCentreName'];
    survey.headOfFamily = json['headOfFamily'];
    survey.familyType = json['familyType'];
    survey.religion = json['religion'];
    survey.subCaste = json['subCaste'];
    
    // Housing
    survey.houseType = json['houseType'];
    survey.numberOfRooms = json['numberOfRooms'];
    survey.roomAdequacy = json['roomAdequacy'];
    survey.occupancy = json['occupancy'];
    survey.monthlyRent = json['monthlyRent'];
    survey.ventilation = json['ventilation'];
    survey.lighting = json['lighting'];
    survey.waterSupply = json['waterSupply'];
    survey.kitchen = json['kitchen'];
    survey.drainage = json['drainage'];
    survey.lavatory = json['lavatory'];
    
    // Family members
    if (json['familyMembers'] != null) {
      survey.familyMembers = (json['familyMembers'] as List)
          .map((m) => FamilyMember(
                name: m['name'] ?? '',
                relationship: m['relationship'] ?? '',
                age: m['age'] ?? 0,
                gender: m['gender'] ?? '',
                education: m['education'] ?? '',
                occupation: m['occupation'] ?? '',
                income: m['income']?.toDouble(),
                healthStatus: m['healthStatus'] ?? '',
              ))
          .toList();
    }
    
    survey.totalIncome = json['totalIncome']?.toDouble();
    survey.socioEconomicClass = json['socioEconomicClass'];
    survey.transportOptions = List<String>.from(json['transportOptions'] ?? []);
    survey.communicationMedia = List<String>.from(json['communicationMedia'] ?? []);
    survey.motherTongue = json['motherTongue'];
    survey.languagesKnown = List<String>.from(json['languagesKnown'] ?? []);
    
    // Dietary pattern
    if (json['dietaryPattern'] != null) {
      survey.dietaryPattern = (json['dietaryPattern'] as Map).map((k, v) => MapEntry(
            k.toString(),
            DietaryInfo(
              available: v['available'] ?? false,
              used: v['used'] ?? false,
              traditional: v['traditional'] ?? false,
              ideal: v['ideal'] ?? false,
              unhygienic: v['unhygienic'] ?? false,
            ),
          ));
    }
    
    // Expenditure
    if (json['expenditureItems'] != null) {
      survey.expenditureItems = (json['expenditureItems'] as List)
          .map((e) => ExpenditureItem(
                item: e['item'] ?? '',
                amount: e['amount']?.toDouble() ?? 0.0,
                percentage: e['percentage']?.toDouble() ?? 0.0,
              ))
          .toList();
    }
    
    // Health conditions
    if (json['feverCases'] != null) {
      survey.feverCases = (json['feverCases'] as List)
          .map((f) => HealthCondition(
                name: f['name'] ?? '',
                age: f['age'] ?? 0,
                disease: f['disease'] ?? '',
                treatment: f['treatment'] ?? '',
                remarks: f['remarks'] ?? '',
              ))
          .toList();
    }
    
    if (json['skinDiseases'] != null) {
      survey.skinDiseases = (json['skinDiseases'] as List)
          .map((s) => HealthCondition(
                name: s['name'] ?? '',
                age: s['age'] ?? 0,
                disease: s['disease'] ?? '',
                treatment: s['treatment'] ?? '',
                remarks: s['remarks'] ?? '',
              ))
          .toList();
    }
    
    if (json['coughCases'] != null) {
      survey.coughCases = (json['coughCases'] as List)
          .map((c) => HealthCondition(
                name: c['name'] ?? '',
                age: c['age'] ?? 0,
                disease: c['disease'] ?? '',
                treatment: c['treatment'] ?? '',
                remarks: c['remarks'] ?? '',
              ))
          .toList();
    }
    
    if (json['otherIllnesses'] != null) {
      survey.otherIllnesses = (json['otherIllnesses'] as List)
          .map((o) => HealthCondition(
                name: o['name'] ?? '',
                age: o['age'] ?? 0,
                disease: o['disease'] ?? '',
                treatment: o['treatment'] ?? '',
                remarks: o['remarks'] ?? '',
              ))
          .toList();
    }
    
    survey.healthKnowledgeAttitude = json['healthKnowledgeAttitude'];
    survey.nutritionKnowledgeAttitude = json['nutritionKnowledgeAttitude'];
    survey.healthServiceUtilization = json['healthServiceUtilization'];
    survey.communityLeaders = json['communityLeaders'];
    
    // Pregnant women
    if (json['pregnantWomen'] != null) {
      survey.pregnantWomen = (json['pregnantWomen'] as List)
          .map((p) => PregnantWoman(
                name: p['name'] ?? '',
                gravida: p['gravida'],
                registered: p['registered'],
                gettingIronFolicAcid: p['gettingIronFolicAcid'],
                hadTetanusToxoid: p['hadTetanusToxoid'],
              ))
          .toList();
    }
    
    // Births, deaths, marriages
    if (json['births'] != null) {
      survey.births = (json['births'] as List)
          .map((b) => BirthRecord(
                dateOfBirth: b['dateOfBirth'] != null
                    ? DateTime.parse(b['dateOfBirth'])
                    : null,
                gender: b['gender'] ?? '',
                parents: b['parents'] ?? '',
                remarks: b['remarks'] ?? '',
              ))
          .toList();
    }
    
    if (json['deaths'] != null) {
      survey.deaths = (json['deaths'] as List)
          .map((d) => DeathRecord(
                dateOfDeath: d['dateOfDeath'] != null
                    ? DateTime.parse(d['dateOfDeath'])
                    : null,
                gender: d['gender'] ?? '',
                parents: d['parents'] ?? '',
                remarks: d['remarks'] ?? '',
              ))
          .toList();
    }
    
    if (json['marriages'] != null) {
      survey.marriages = (json['marriages'] as List)
          .map((m) => MarriageRecord(
                name: m['name'] ?? '',
                age: m['age'] ?? 0,
                dateOfMarriage: m['dateOfMarriage'] != null
                    ? DateTime.parse(m['dateOfMarriage'])
                    : null,
                remarks: m['remarks'] ?? '',
              ))
          .toList();
    }
    
    // Immunization
    if (json['immunizationRecords'] != null) {
      survey.immunizationRecords = (json['immunizationRecords'] as List)
          .map((i) {
            final record = ImmunizationRecord(
              childName: i['childName'] ?? '',
              dateOfBirth: i['dateOfBirth'] != null
                  ? DateTime.parse(i['dateOfBirth'])
                  : null,
              remarks: i['remarks'] ?? '',
            );
            if (i['vaccinations'] != null) {
              record.vaccinations = Map<String, bool>.from(i['vaccinations']);
            }
            return record;
          })
          .toList();
    }
    
    // Eligible couples
    if (json['eligibleCouples'] != null) {
      survey.eligibleCouples = (json['eligibleCouples'] as List)
          .map((e) => EligibleCouple(
                husbandName: e['husbandName'] ?? '',
                husbandAge: e['husbandAge'] ?? 0,
                wifeName: e['wifeName'] ?? '',
                wifeAge: e['wifeAge'] ?? 0,
                priority1: e['priority1'] ?? false,
                priority2: e['priority2'] ?? false,
              ))
          .toList();
    }
    
    survey.contraceptiveMethod = json['contraceptiveMethod'];
    survey.intendingVasectomy = json['intendingVasectomy'];
    survey.intendingTubalLigation = json['intendingTubalLigation'];
    survey.notInterestedReason = json['notInterestedReason'];
    
    // Malnutrition
    if (json['malnutritionCases'] != null) {
      survey.malnutritionCases = (json['malnutritionCases'] as List)
          .map((m) => MalnutritionCase(
                name: m['name'] ?? '',
                age: m['age'] ?? 0,
                kwashiorkor: m['kwashiorkor'] ?? false,
                marasmus: m['marasmus'] ?? false,
                vitaminADeficiency: m['vitaminADeficiency'] ?? false,
                anemia: m['anemia'] ?? false,
                rickets: m['rickets'] ?? false,
                remarks: m['remarks'] ?? '',
              ))
          .toList();
    }
    
    // Environmental health
    survey.sewageDisposalHygienic = json['sewageDisposalHygienic'];
    survey.sewageDisposalReason = json['sewageDisposalReason'];
    survey.wasteDisposalMethods = List<String>.from(json['wasteDisposalMethods'] ?? []);
    survey.wasteDisposalReason = json['wasteDisposalReason'];
    survey.excretaDisposalHygienic = json['excretaDisposalHygienic'];
    survey.excretaDisposalReason = json['excretaDisposalReason'];
    survey.cattlePoultryHygienic = json['cattlePoultryHygienic'];
    survey.cattlePoultryHousing = json['cattlePoultryHousing'];
    survey.cattlePoultryReason = json['cattlePoultryReason'];
    survey.hasWellOrHandPump = json['hasWellOrHandPump'];
    survey.wellMaintained = json['wellMaintained'];
    survey.wellMaintenanceReason = json['wellMaintenanceReason'];
    survey.wellChlorinationDate = json['wellChlorinationDate'];
    survey.wellChlorinationReason = json['wellChlorinationReason'];
    survey.houseKeptClean = json['houseKeptClean'];
    survey.houseCleanReason = json['houseCleanReason'];
    survey.houseSprayDate = json['houseSprayDate'];
    survey.houseSprayReason = json['houseSprayReason'];
    survey.breedingPlaceInsectsRodents = json['breedingPlaceInsectsRodents'];
    survey.strayDogs = json['strayDogs'];
    survey.numberOfStrayDogs = json['numberOfStrayDogs'];
    
    survey.treatmentLocation = json['treatmentLocation'];
    survey.officialHealthAgenciesAdequate = json['officialHealthAgenciesAdequate'];
    survey.healthAgenciesReason = json['healthAgenciesReason'];
    survey.hasHealthInsurance = json['hasHealthInsurance'];
    survey.healthInsuranceDetails = json['healthInsuranceDetails'];
    survey.familyStrengths = List<String>.from(json['familyStrengths'] ?? []);
    survey.familyWeaknesses = List<String>.from(json['familyWeaknesses'] ?? []);
    survey.applicableProgrammes = List<String>.from(json['applicableProgrammes'] ?? []);
    survey.medicinePurchaseLocation = json['medicinePurchaseLocation'];
    survey.medicineCompliance = json['medicineCompliance'];
    survey.contactNumber = json['contactNumber'];
    
    if (json['surveyDate'] != null) {
      survey.surveyDate = DateTime.parse(json['surveyDate']);
    }
    survey.studentName = json['studentName'];
    survey.studentSignature = json['studentSignature'];
    
    return survey;
  }
}

