class SurveyData {
  // Section 1: Basic Information
  String? areaName;
  String? areaType; // Rural/Urban
  String? healthCentreName;
  String? headOfFamily;
  String? familyType; // Nuclear/Joint/Single
  String? religion;
  String? subCaste;

  // Section 6: Housing Condition
  String? houseType; // Pucca/Semi pucca/Kutcha
  int? numberOfRooms;
  String? roomAdequacy; // Adequate/Inadequate
  String? occupancy; // Tenant/Owner
  String? monthlyRent;
  String? ventilation; // Adequate/Inadequate/No Ventilation
  String? lighting; // Electricity/Gas lamp/Oil lamp
  String? waterSupply; // Tap/Hand pump/Well/Open Tank/Others
  String? kitchen; // Separate/Corner of the room/Veranda
  String? drainage; // Adequate/Inadequate/No Drainage
  String? lavatory; // Own Latrine/Public Latrine/Open air defecation

  // Section 7: Family Composition
  List<FamilyMember> familyMembers = [];

  // Section 7A & 7B: Income
  double? totalIncome;
  String? socioEconomicClass;

  // Section 8: Transport & Communication
  List<String> transportOptions = [];
  List<String> communicationMedia = [];
  String? motherTongue;
  List<String> languagesKnown = [];

  // Section 9: Dietary Pattern
  Map<String, DietaryInfo> dietaryPattern = {};

  // Section 10: Expenditure
  List<ExpenditureItem> expenditureItems = [];

  // Section 11-14: Health Conditions
  List<HealthCondition> feverCases = [];
  List<HealthCondition> skinDiseases = [];
  List<HealthCondition> coughCases = [];
  List<HealthCondition> otherIllnesses = [];

  // Section 15: Family Health Attitude
  String? healthKnowledgeAttitude;
  String? nutritionKnowledgeAttitude;
  String? healthServiceUtilization;
  List<String>? healthServiceUtilizationList;
  String? communityLeaders;

  // Section 16: Pregnant Women
  List<PregnantWoman> pregnantWomen = [];

  // Section 17: Vital Statistics
  List<BirthRecord> births = [];
  List<DeathRecord> deaths = [];
  List<MarriageRecord> marriages = [];

  // Section 18: Immunization
  List<ImmunizationRecord> immunizationRecords = [];

  // Section 19: Eligible Couples
  List<EligibleCouple> eligibleCouples = [];
  String? contraceptiveMethod;
  bool? intendingVasectomy;
  bool? intendingTubalLigation;
  String? notInterestedReason;

  // Section 20: Malnutrition
  List<MalnutritionCase> malnutritionCases = [];

  // Section 21-29: Environmental Health
  bool? sewageDisposalHygienic;
  String? sewageDisposalReason;
  List<String> wasteDisposalMethods = [];
  String? wasteDisposalReason;
  bool? excretaDisposalHygienic;
  String? excretaDisposalReason;
  bool? cattlePoultryHygienic;
  String? cattlePoultryHousing; // separate/within house
  String? cattlePoultryReason;
  bool? hasWellOrHandPump;
  bool? wellMaintained;
  String? wellMaintenanceReason;
  String? wellChlorinationDate;
  String? wellChlorinationReason;
  bool? houseKeptClean;
  String? houseCleanReason;
  String? houseSprayDate;
  String? houseSprayReason;
  bool? breedingPlaceInsectsRodents;
  bool? strayDogs;
  int? numberOfStrayDogs;

  // Section 30: Treatment Location
  String? treatmentLocation;

  // Section 31-32: Health Services
  bool? officialHealthAgenciesAdequate;
  String? healthAgenciesReason;
  bool? hasHealthInsurance;
  String? healthInsuranceDetails;

  // Section 35-36: Family Assessment
  List<String> familyStrengths = [];
  List<String> familyWeaknesses = [];

  // Section 37: National Health Programme
  List<String> applicableProgrammes = [];

  // New Fields
  String? houseNo;
  String? aadharNumber;
  bool isApproved = false;
  List<String> nonCommunicableDiseases = [];

  List<String> communicableDiseases = [];
  String? familyStrengthOther;
  String? familyWeaknessOther;
  String? applicableProgrammeOther;

  // Section 38: Medicine Purchase
  String? medicinePurchaseLocation;
  String? medicineCompliance; // Complete/Partial/Unfinished

  // Section 39: Contact
  String? contactNumber;

  // Metadata
  DateTime? surveyDate;
  String? studentName;
  String? studentSignature;

  Map<String, dynamic> toJson() {
    return {
      'areaName': areaName,
      'areaType': areaType,
      'healthCentreName': healthCentreName,
      'headOfFamily': headOfFamily,
      'familyType': familyType,
      'religion': religion,
      'subCaste': subCaste,
      'houseType': houseType,
      'numberOfRooms': numberOfRooms,
      'roomAdequacy': roomAdequacy,
      'occupancy': occupancy,
      'monthlyRent': monthlyRent,
      'ventilation': ventilation,
      'lighting': lighting,
      'waterSupply': waterSupply,
      'kitchen': kitchen,
      'drainage': drainage,
      'lavatory': lavatory,
      'familyMembers': familyMembers.map((m) => m.toJson()).toList(),
      'totalIncome': totalIncome,
      'socioEconomicClass': socioEconomicClass,
      'transportOptions': transportOptions,
      'communicationMedia': communicationMedia,
      'motherTongue': motherTongue,
      'languagesKnown': languagesKnown,
      'dietaryPattern': dietaryPattern.map((k, v) => MapEntry(k, v.toJson())),
      'expenditureItems': expenditureItems.map((e) => e.toJson()).toList(),
      'feverCases': feverCases.map((f) => f.toJson()).toList(),
      'skinDiseases': skinDiseases.map((s) => s.toJson()).toList(),
      'coughCases': coughCases.map((c) => c.toJson()).toList(),
      'otherIllnesses': otherIllnesses.map((o) => o.toJson()).toList(),
      'healthKnowledgeAttitude': healthKnowledgeAttitude,
      'nutritionKnowledgeAttitude': nutritionKnowledgeAttitude,
      'healthServiceUtilization': healthServiceUtilization,
      'healthServiceUtilizationList': healthServiceUtilizationList,
      'communityLeaders': communityLeaders,
      'pregnantWomen': pregnantWomen.map((p) => p.toJson()).toList(),
      'births': births.map((b) => b.toJson()).toList(),
      'deaths': deaths.map((d) => d.toJson()).toList(),
      'marriages': marriages.map((m) => m.toJson()).toList(),
      'immunizationRecords': immunizationRecords.map((i) => i.toJson()).toList(),
      'eligibleCouples': eligibleCouples.map((e) => e.toJson()).toList(),
      'contraceptiveMethod': contraceptiveMethod,
      'intendingVasectomy': intendingVasectomy,
      'intendingTubalLigation': intendingTubalLigation,
      'notInterestedReason': notInterestedReason,
      'malnutritionCases': malnutritionCases.map((m) => m.toJson()).toList(),
      'sewageDisposalHygienic': sewageDisposalHygienic,
      'sewageDisposalReason': sewageDisposalReason,
      'wasteDisposalMethods': wasteDisposalMethods,
      'wasteDisposalReason': wasteDisposalReason,
      'excretaDisposalHygienic': excretaDisposalHygienic,
      'excretaDisposalReason': excretaDisposalReason,
      'cattlePoultryHygienic': cattlePoultryHygienic,
      'cattlePoultryHousing': cattlePoultryHousing,
      'cattlePoultryReason': cattlePoultryReason,
      'hasWellOrHandPump': hasWellOrHandPump,
      'wellMaintained': wellMaintained,
      'wellMaintenanceReason': wellMaintenanceReason,
      'wellChlorinationDate': wellChlorinationDate,
      'wellChlorinationReason': wellChlorinationReason,
      'houseKeptClean': houseKeptClean,
      'houseCleanReason': houseCleanReason,
      'houseSprayDate': houseSprayDate,
      'houseSprayReason': houseSprayReason,
      'breedingPlaceInsectsRodents': breedingPlaceInsectsRodents,
      'strayDogs': strayDogs,
      'numberOfStrayDogs': numberOfStrayDogs,
      'treatmentLocation': treatmentLocation,
      'officialHealthAgenciesAdequate': officialHealthAgenciesAdequate,
      'healthAgenciesReason': healthAgenciesReason,
      'hasHealthInsurance': hasHealthInsurance,
      'healthInsuranceDetails': healthInsuranceDetails,
      'familyStrengths': familyStrengths,
      'familyStrengthOther': familyStrengthOther,
      'familyWeaknesses': familyWeaknesses,
      'familyWeaknessOther': familyWeaknessOther,
      'applicableProgrammes': applicableProgrammes,
      'applicableProgrammeOther': applicableProgrammeOther,
      'medicinePurchaseLocation': medicinePurchaseLocation,
      'medicineCompliance': medicineCompliance,
      'contactNumber': contactNumber,
      'houseNo': houseNo,
      'aadharNumber': aadharNumber,
      'isApproved': isApproved,
      'nonCommunicableDiseases': nonCommunicableDiseases,
      'communicableDiseases': communicableDiseases,
      'surveyDate': surveyDate?.toIso8601String(),
      'studentName': studentName,
      'studentSignature': studentSignature,
    };
  }
}

class FamilyMember {
  String name;
  String relationship;
  int age;
  String gender;
  String education;
  String occupation;
  double? income;
  String healthStatus;

  FamilyMember({
    required this.name,
    required this.relationship,
    required this.age,
    required this.gender,
    required this.education,
    required this.occupation,
    this.income,
    required this.healthStatus,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'relationship': relationship,
      'age': age,
      'gender': gender,
      'education': education,
      'occupation': occupation,
      'income': income,
      'healthStatus': healthStatus,
    };
  }
}

class DietaryInfo {
  bool available;
  bool used;
  bool traditional;
  bool ideal;
  bool unhygienic;

  DietaryInfo({
    this.available = false,
    this.used = false,
    this.traditional = false,
    this.ideal = false,
    this.unhygienic = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'available': available,
      'used': used,
      'traditional': traditional,
      'ideal': ideal,
      'unhygienic': unhygienic,
    };
  }
}

class ExpenditureItem {
  String item;
  double amount;
  double percentage;

  ExpenditureItem({
    required this.item,
    required this.amount,
    required this.percentage,
  });

  Map<String, dynamic> toJson() {
    return {
      'item': item,
      'amount': amount,
      'percentage': percentage,
    };
  }
}

class HealthCondition {
  String name;
  int age;
  String disease;
  String treatment;
  String remarks;

  HealthCondition({
    required this.name,
    required this.age,
    required this.disease,
    required this.treatment,
    required this.remarks,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'disease': disease,
      'treatment': treatment,
      'remarks': remarks,
    };
  }
}

class PregnantWoman {
  String name;
  int? gravida;
  bool? registered;
  bool? gettingIronFolicAcid;
  bool? hadTetanusToxoid;

  PregnantWoman({
    required this.name,
    this.gravida,
    this.registered,
    this.gettingIronFolicAcid,
    this.hadTetanusToxoid,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'gravida': gravida,
      'registered': registered,
      'gettingIronFolicAcid': gettingIronFolicAcid,
      'hadTetanusToxoid': hadTetanusToxoid,
    };
  }
}

class BirthRecord {
  DateTime? dateOfBirth;
  String gender;
  String parents;
  String remarks;

  BirthRecord({
    this.dateOfBirth,
    required this.gender,
    required this.parents,
    required this.remarks,
  });

  Map<String, dynamic> toJson() {
    return {
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'parents': parents,
      'remarks': remarks,
    };
  }
}

class DeathRecord {
  DateTime? dateOfDeath;
  String gender;
  String parents;
  String remarks;

  DeathRecord({
    this.dateOfDeath,
    required this.gender,
    required this.parents,
    required this.remarks,
  });

  Map<String, dynamic> toJson() {
    return {
      'dateOfDeath': dateOfDeath?.toIso8601String(),
      'gender': gender,
      'parents': parents,
      'remarks': remarks,
    };
  }
}

class MarriageRecord {
  String name;
  int age;
  DateTime? dateOfMarriage;
  String remarks;

  MarriageRecord({
    required this.name,
    required this.age,
    this.dateOfMarriage,
    required this.remarks,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'dateOfMarriage': dateOfMarriage?.toIso8601String(),
      'remarks': remarks,
    };
  }
}

class ImmunizationRecord {
  String childName;
  DateTime? dateOfBirth;
  Map<String, bool> vaccinations = {};
  String remarks;

  ImmunizationRecord({
    required this.childName,
    this.dateOfBirth,
    required this.remarks,
  });

  Map<String, dynamic> toJson() {
    return {
      'childName': childName,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'vaccinations': vaccinations,
      'remarks': remarks,
    };
  }
}

class EligibleCouple {
  String husbandName;
  int husbandAge;
  String wifeName;
  int wifeAge;
  bool priority1;
  bool priority2;

  EligibleCouple({
    required this.husbandName,
    required this.husbandAge,
    required this.wifeName,
    required this.wifeAge,
    this.priority1 = false,
    this.priority2 = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'husbandName': husbandName,
      'husbandAge': husbandAge,
      'wifeName': wifeName,
      'wifeAge': wifeAge,
      'priority1': priority1,
      'priority2': priority2,
    };
  }
}

class MalnutritionCase {
  String name;
  int age;
  bool kwashiorkor;
  bool marasmus;
  bool vitaminADeficiency;
  bool anemia;
  bool rickets;
  String remarks;

  MalnutritionCase({
    required this.name,
    required this.age,
    this.kwashiorkor = false,
    this.marasmus = false,
    this.vitaminADeficiency = false,
    this.anemia = false,
    this.rickets = false,
    required this.remarks,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'kwashiorkor': kwashiorkor,
      'marasmus': marasmus,
      'vitaminADeficiency': vitaminADeficiency,
      'anemia': anemia,
      'rickets': rickets,
      'remarks': remarks,
    };
  }
}

