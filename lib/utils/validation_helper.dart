import '../models/survey_data.dart';

class ValidationHelper {
  static String? validateSurvey(SurveyData data) {
    // Section 1: Basic Information
    if (_isEmpty(data.houseNo)) return "Section 1: House No. is required";
    if (_isEmpty(data.aadharNumber)) return "Section 1: Aadhar Card No. is required";
    if (data.aadharNumber!.length != 12) return "Section 1: Aadhar Card No. must be 12 digits";
    if (_isEmpty(data.areaName)) return "Section 1: Area Name is required";
    if (_isEmpty(data.areaType)) return "Section 1: Area Type is required";
    if (_isEmpty(data.healthCentreName)) return "Section 1: Health Centre Name is required";
    if (_isEmpty(data.headOfFamily)) return "Section 1: Head of Family is required";
    if (_isEmpty(data.familyType)) return "Section 1: Family Type is required";
    if (_isEmpty(data.religion)) return "Section 1: Religion is required";
    // Subcaste might be optional? User said "Section-1... mandatory". Assuming yes if text field.
    if (_isEmpty(data.subCaste)) return "Section 1: Sub Caste is required";

    // Section 2: Housing Condition
    if (_isEmpty(data.houseType)) return "Section 2: House Type is required";
    if (data.numberOfRooms == null) return "Section 2: Number of Rooms is required";
    if (_isEmpty(data.roomAdequacy)) return "Section 2: Room Adequacy is required";
    if (_isEmpty(data.occupancy)) return "Section 2: Occupancy is required";
    if (data.occupancy == 'Tenant' && _isEmpty(data.monthlyRent)) return "Section 2: Monthly Rent is required";
    if (_isEmpty(data.ventilation)) return "Section 2: Ventilation is required";
    if (_isEmpty(data.lighting)) return "Section 2: Lighting is required";
    if (_isEmpty(data.waterSupply)) return "Section 2: Water Supply is required";
    if (_isEmpty(data.kitchen)) return "Section 2: Kitchen is required";
    if (_isEmpty(data.drainage)) return "Section 2: Drainage is required";
    if (_isEmpty(data.lavatory)) return "Section 2: Lavatory is required";

    // Section 3: Family Composition
    if (data.familyMembers.isEmpty) return "Section 3: At least one family member is required";
    for (int i = 0; i < data.familyMembers.length; i++) {
      final member = data.familyMembers[i];
      if (_isEmpty(member.name)) return "Section 3: Member ${i + 1} Name is required";
      if (_isEmpty(member.relationship)) return "Section 3: Member ${i + 1} Relationship is required";
      if (member.age <= 0) return "Section 3: Member ${i + 1} Age is required";
      if (_isEmpty(member.gender)) return "Section 3: Member ${i + 1} Gender is required";
      if (_isEmpty(member.education)) return "Section 3: Member ${i + 1} Education is required";
      if (_isEmpty(member.occupation)) return "Section 3: Member ${i + 1} Occupation is required";
      if (_isEmpty(member.healthStatus)) return "Section 3: Member ${i + 1} Health Status is required";
    }

    // Section 4: Income & Socio-economic
    if (data.totalIncome == null) return "Section 4: Total Income is required";
    if (_isEmpty(data.socioEconomicClass)) return "Section 4: Socio-economic class is required";

    // Section 5: Transport & Communication
    if (data.communicationMedia.isEmpty) return "Section 5: Select at least one Communication Media";
    if (data.transportOptions.isEmpty) return "Section 5: Select at least one Transport Option";
    if (_isEmpty(data.motherTongue)) return "Section 5: Mother Tongue is required";
    if (data.languagesKnown.isEmpty) return "Section 5: Select at least one Language Known";

    // Section 6: Dietary Pattern
    // Ensure all initialized items have valid status if available
    for (var entry in data.dietaryPattern.entries) {
      if (entry.value.available) {
        if (!entry.value.traditional && !entry.value.ideal && !entry.value.unhygienic) {
          return "Section 6: Prep method for ${entry.key} is required";
        }
      }
    }

    // Section 7: Expenditure
    // Ensure total expenditure > 0 or at least one item > 0
    bool hasExpenditure = data.expenditureItems.any((item) => item.amount > 0);
    if (!hasExpenditure) return "Section 7: Expenditure details are required";
    
    // Section 9: Family Health Attitude (Index 8 in list, so Section 9 in user list?)
    // Note: User said "Section-9". In app sections list, index 8 is Family Health Attitude.
    // Index 7 is Health Conditions (User didn't list Section 8).
    // Section 9 is Family Health Attitude.
    if (_isEmpty(data.healthKnowledgeAttitude)) return "Section 9: Health Knowledge Attitude is required";
    if (_isEmpty(data.nutritionKnowledgeAttitude)) return "Section 9: Nutrition Knowledge Attitude is required";
    if (data.healthServiceUtilizationList == null || data.healthServiceUtilizationList!.isEmpty) {
      return "Section 9: Health Service Utilization is required";
    }
    if (_isEmpty(data.communityLeaders)) return "Section 9: Community Leaders information is required";

    // Section 15: Environmental Health (Index 14)
    // 21. Sewage
    if (data.sewageDisposalHygienic == null) return "Section 15: Sewage Disposal question is required (21)";
    if (data.sewageDisposalHygienic == false && _isEmpty(data.sewageDisposalReason)) return "Section 15: Sewage Disposal Reason is required";
    if (data.sewageDisposalHygienic == true && _isEmpty(data.sewageDisposalReason)) return "Section 15: Sewage Disposal Method is required";
    
    // 22. Waste
    // Logic: if not hygienic, reason required. But "hygienic" is determined by checkboxes?
    // Let's assume one of the methods (Composting, Burning...) OR a reason must be provided.
    if (data.wasteDisposalMethods.isEmpty && _isEmpty(data.wasteDisposalReason)) {
      return "Section 15: Waste Disposal Method or Reason is required (22)";
    }
    
    // 23. Excreta
    if (data.excretaDisposalHygienic == null) return "Section 15: Excreta Disposal question is required (23)";
    if (data.excretaDisposalHygienic == false && _isEmpty(data.excretaDisposalReason)) return "Section 15: Excreta Disposal Reason is required";
    
    // 24. Cattle
    if (data.cattlePoultryHygienic == null) return "Section 15: Cattle/Poultry question is required (24)";
    if (data.cattlePoultryHygienic == true && _isEmpty(data.cattlePoultryHousing)) return "Section 15: Cattle Housing type is required";
    if (data.cattlePoultryHygienic == false && _isEmpty(data.cattlePoultryReason)) return "Section 15: Cattle Housing Reason is required";
    
    // 25. Well
    if (data.hasWellOrHandPump == null) return "Section 15: Well/Handpump question is required (25)";
    if (data.hasWellOrHandPump == true) {
      if (data.wellMaintained == null) return "Section 15: Well Maintenance question is required (25.1)";
      if (data.wellMaintained == false && _isEmpty(data.wellMaintenanceReason)) return "Section 15: Well Maintenance Reason is required";
      // 25.2 Chlorination - Optional date? Let's skip strict date check, but maybe reason if not chlorinated.
      // But we don't have a bool for "is chlorinated". Just date and reason.
    }
    
    // 26. Clean House
    if (data.houseKeptClean == null) return "Section 15: House Cleanliness question is required (26)";
    if (data.houseKeptClean == false && _isEmpty(data.houseCleanReason)) return "Section 15: House Cleanliness Reason is required";

    // 27. Spray - Optional? User said Section 15 mandatory.
    // Let's enforce date or reason?
    // if (_isEmpty(data.houseSprayDate) && _isEmpty(data.houseSprayReason)) return "Section 15: House Spary Date or Reason is required (27)";

    // Section 16: Health Services (Index 15)
    if (_isEmpty(data.treatmentLocation)) return "Section 16: Treatment Location is required (30)";
    if (data.officialHealthAgenciesAdequate == null) return "Section 16: Official Health Agencies question required (31)";
    if (data.officialHealthAgenciesAdequate == false && _isEmpty(data.healthAgenciesReason)) return "Section 16: Health Agencies Reason is required";
    if (data.hasHealthInsurance == null) return "Section 16: Health Insurance question required (32)";
    if (data.hasHealthInsurance == true && _isEmpty(data.healthInsuranceDetails)) return "Section 16: Health Insurance Details required";
    
    // 38. Medicine
    if (_isEmpty(data.medicinePurchaseLocation)) return "Section 16: Medicine Purchase Location is required (38)";
    if (_isEmpty(data.medicineCompliance)) return "Section 16: Medicine Compliance is required (38.1)";

    // Section 17: Family Assessment (Index 16)
    // 35 & 36
    if (data.familyStrengths.isEmpty && _isEmpty(data.familyStrengthOther)) return "Section 17: Family Strength is required";
    if (data.familyWeaknesses.isEmpty && _isEmpty(data.familyWeaknessOther)) return "Section 17: Family Weakness is required";
    if (data.applicableProgrammes.isEmpty && _isEmpty(data.applicableProgrammeOther)) return "Section 17: Applicable Programme is required";
    
    // Section 18: Final Details (Index 17)
    if (_isEmpty(data.contactNumber)) return "Section 18: Contact Number is required";
    if (data.surveyDate == null) return "Section 18: Survey Date is required";
    if (_isEmpty(data.studentName)) return "Section 18: Student Name is required";
    if (_isEmpty(data.studentSignature)) return "Section 18: Student Signature is required";

    return null; // Valid
  }

  static bool _isEmpty(String? value) {
    return value == null || value.trim().isEmpty;
  }
}
